//
//  SettingDetailViewController.swift
//  View controller for setting detail screen
//
//  Created by alpha22jp on 2015/01/13.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

// MARK: - 設定の詳細画面 (選択項目の設定) を管理するクラス
class SettingDetailViewController: UITableViewController {

    var setting: Setting<Int>! // 対象となる設定値 (画面遷移時にセットされる)
    var items: [String]! // 選択項目のリスト (画面遷移時にセットされる)

    // MARK: - UIViewController

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let indexPath = NSIndexPath(forRow: setting.get(), inSection: 0)
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    // MARK: - Table view operation

    // MARK: セルが選択された時に呼ばれる
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark

        setting.set(indexPath.row)
    }

    // MARK: セルの選択が解除された時に呼ばれる
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }

    // MARK: - Table view data source

    // MARK: セクション数を返す
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    // MARK: 各セクションの行数を返す
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count
    }

    // MARK: 各セルの内容を設定する
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = items[indexPath.row]
        if setting.get() == indexPath.row {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

}
