//
//  MainViewController.swift
//  View controller for main list view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit
import CoreData

// MARK: - メインのノート一覧画面を管理するクラス
class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let settings = Settings.sharedInstance
    let simplenote = SimplenoteServer.sharedInstance
    let database = NoteDatabase.sharedInstance
    var fetchedResultsController: NSFetchedResultsController!

    // MARK: - Storyboard connection

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // SimplenoteServerにアカウント情報を設定
        let email = settings.email.get()
        let password = settings.password.get()
        simplenote.setAccountInfo(email, password: password)

        // デフォルト状態の検索結果をセット
        fetchedResultsController = getDefaultFetchedResultsController()
        fetchedResultsController.performFetch(nil)

        // リフレッシュコントロールを追加
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Loading...")
        refresh.addTarget(self, action: "syncWithServer", forControlEvents:.ValueChanged)
        self.refreshControl = refresh
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // 設定の変更を反映するために必要
        fetchedResultsController = getDefaultFetchedResultsController()
        fetchedResultsController.performFetch(nil)
        tableView.reloadData()
    }

    // MARK: - Simplenote server access

    // MARK: エラーを通知するアラート (OKボタンのみ) を表示する
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: データベースに保存している全ノートの情報をサーバーと同期する
    func syncWithServer() {
        println(__FUNCTION__, "Start syncing cached note data with server...")
        // 全ノートの属性情報を取得
        simplenote.getIndex { (result, noteAttrList) in
            if !result.success() {
                println(__FUNCTION__, "result = \(result.rawValue)")
                self.refreshControl?.endRefreshing()
                self.showAlert("Error", message: result.rawValue)
                return
            }
            for attr in noteAttrList {
                var note: Note! = self.database.searchNote(attr.key)
                println(__FUNCTION__, "Version check, local:\(note?.version), remote:\(attr.version), key:\(note?.key)")
                // サーバーの方がバージョンが新しいか、ローカルに存在しないときだけ更新
                if note == nil || attr.version > note.version {
                    // ノートの本体を取得
                    self.simplenote.getNote(attr.key) { (result, attr, content) in
                        if !result.success() {
                            // TODO: ノート本体の取得に失敗、ここでもエラー通知が必要か？
                            return
                        }
                        if note == nil {
                            println(__FUNCTION__, "Creating new note in DB...")
                            note = self.database.createNote(attr.key)
                        }
                        // データベースのノート情報を更新
                        note.createdate = attr.createdate
                        note.modifydate = attr.modifydate
                        note.version = attr.version
                        note.isdeleted = (attr.deleted == 1)
                        note.markdown = attr.markdown
                        note.content = content
                        self.database.saveContext()
                    }
                }
            }
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - NSFetchedResultsController

    // MARK: 現在の設定に従った検索条件 (NSFetchedResultsController) を取得する
    private func getDefaultFetchedResultsController() -> NSFetchedResultsController {
        let key = (settings.sort.get() == 0 ? "modifydate" : "createdate")
        let ascending = (settings.order.get() == 1)
        let sort = NSSortDescriptor(key: key, ascending: ascending)
        let predicate = NSPredicate(format: "%K = FALSE", "isdeleted")
        return database.getFetchedResultsController(sort, predicate: predicate, delegate: self)
    }

    // MARK: コンテンツ変更時に呼ばれる
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    // MARK: セクション数を返す
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return fetchedResultsController.sections!.count
    }

    // MARK: 各セクションの行数を返す
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return fetchedResultsController.sections![section].numberOfObjects
    }

    // MARK: 各セルの内容を設定する
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let note = fetchedResultsController.objectAtIndexPath(indexPath) as Note
        cell.textLabel?.text = note.content

        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier:"ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = NSDate(timeIntervalSince1970: note.modifydate)
        cell.detailTextLabel?.text = formatter.stringFromDate(date)

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(__FUNCTION__, "segue.identifier: \(segue.identifier)")
        if segue.identifier == "note" {
            // Navigate to NoteView (show (e.g. push))
            let cell = sender as UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let note = fetchedResultsController.objectAtIndexPath(indexPath!) as Note
            let controller = segue.destinationViewController as NoteViewController
            // 選択されているcellに対応するnoteをNoteViewに渡す
            controller.note = note
        } else if segue.identifier == "settings" {
            // Navigate to SettingView (present modally)
        }
    }

}

// MARK: - 検索バー付きのノート一覧画面を管理する拡張クラス
class MainViewControllerWithSearchBar: MainViewController, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // 検索バーの初期設定、delegateの設定、テーブルとの関連付けを行う
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        // FIXME: これを設定してもキャンセルボタンが消えない...バグ？
        searchController.searchBar.showsCancelButton = false
        self.navigationItem.titleView = searchController.searchBar

        // これを設定しないと、検索状態から詳細画面に遷移した際に検索バーが残ってしまう
        definesPresentationContext = true
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text.isEmpty {
            fetchedResultsController = getDefaultFetchedResultsController()
        } else {
            println(__FUNCTION__, "Search text = \(searchController.searchBar.text)")
            let key = (settings.sort.get() == 0 ? "modifydate" : "createdate")
            let ascending = (settings.order.get() == 1)
            let sort = NSSortDescriptor(key: key, ascending: ascending)
            let predicate = NSPredicate(format: "%K = FALSE && %K CONTAINS[cd] %@", "isdeleted", "content", searchController.searchBar.text)
            fetchedResultsController = database.getFetchedResultsController(sort, predicate: predicate, delegate: self)
        }
        fetchedResultsController.performFetch(nil)
        tableView.reloadData()
    }

}
