//
//  MainViewController.swift
//  View controller for main list view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {

    @IBOutlet var noteListTable: UITableView!

    @IBAction func didRefreshButtonTap(sender: AnyObject) {
        syncWithServer()
    }

    let simplenote = Simplenote()
    let database = NoteDatabase(context: (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!)
    var fetchedResultsController: NSFetchedResultsController!
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        fetchedResultsController = getDefaultFetchedResultsController()
        fetchedResultsController.performFetch(nil)

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true // default
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.noteListTable.tableHeaderView = searchController.searchBar

        // これを設定しないと、検索状態から詳細画面に遷移した際に検索バーが残ってしまう。
        definesPresentationContext = true

        var refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Loading...")
        refresh.addTarget(self, action: "syncWithServer", forControlEvents:.ValueChanged)
        self.refreshControl = refresh
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func getDefaultFetchedResultsController() -> NSFetchedResultsController {
        let sort = NSSortDescriptor(key: "modifydate", ascending: false)
        let predicate = NSPredicate(format: "%K = FALSE", "isdeleted")
        let controller = database.getFetchedResultsController(sort, predicate: predicate)
        controller.delegate = self
        return controller
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        println("Search text = \(searchController.searchBar.text)")
        if searchController.searchBar.text == "" {
            fetchedResultsController = getDefaultFetchedResultsController()
        } else {
            let sort = NSSortDescriptor(key: "modifydate", ascending: false)
            let predicate = NSPredicate(format: "%K = FALSE && %K CONTAINS %@", "isdeleted", "content", searchController.searchBar.text)
            fetchedResultsController = database.getFetchedResultsController(sort, predicate: predicate)
            fetchedResultsController.delegate = self
        }
        fetchedResultsController.performFetch(nil)
        tableView.reloadData()
    }

    func syncWithServer() {
        let setting = NSUserDefaults.standardUserDefaults()
        let email = setting.stringForKey("email")
        let password = setting.stringForKey("password")
        if email == nil || password == nil {
            refreshControl?.endRefreshing()
            var settingView = self.storyboard!.instantiateViewControllerWithIdentifier("setting") as UIViewController
            self.presentViewController(settingView, animated: true, completion: nil)
            return
        }
        simplenote.setAccountInfo(email!, password: password!)
        simplenote.getIndex(analyzeNoteIndex)
    }

    func analyzeNoteIndex(result: Simplenote.Result, noteArray: [Simplenote.Note]!) {
        if result != Simplenote.Result.Success {
            println(__FUNCTION__, ": result = \(result.rawValue)")
            refreshControl?.endRefreshing()
            let alert = UIAlertController(title: "Error", message: result.rawValue, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        for note in noteArray {
            println("Search \(note.key)...")
            var entity: Note? = database.searchEntity(note.key)
            println("Version check, local:\(entity?.version), remote:\(note.version)")
            if note.version > entity?.version {
                simplenote.getNote(note.key) { (result, note, content) in
                    if result != Simplenote.Result.Success {
                        return
                    }
                    if entity == nil {
                        println("Creating new entity...")
                        entity = self.database.createEntity(note.key)
                    }
                    self.database.updateEntity(entity!, note: note, content: content)
                }
            }
        }
        refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let note = fetchedResultsController.objectAtIndexPath(indexPath) as Note
        cell.textLabel?.text = note.content
        return cell
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    	
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        println("segue.identifier: \(segue.identifier)")
        if segue.identifier == "select" {
            let cell = sender as UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let note = fetchedResultsController.objectAtIndexPath(indexPath!) as Note
            println("Content: \(note.content)")
            let controller = segue.destinationViewController as NoteViewController
            controller.note = note
        }
    }

}
