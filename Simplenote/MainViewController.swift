//
//  MainViewController.swift
//  View controller for main list view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let simplenote = Simplenote()
    let note_db = NoteDatabase(context: (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!)
    var fetchedResultController = NSFetchedResultsController()

    @IBAction func refreshTapped(sender: AnyObject) {
        simplenote.simplenote_get_index(updateNoteDatabase)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        fetchedResultController = NSFetchedResultsController(fetchRequest: note_db.fetchRequest(), managedObjectContext: note_db.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateNoteDatabase(note_array: [Simplenote.Note]) {
        for note in note_array {
            let date = NSDate(timeIntervalSince1970: note.modifydate)
            println("date: \(date), key: \(note.key)")

            note_db.update(note.key, createdate: note.createdate,
                           modifydate: note.modifydate, version: note.version)
            simplenote.simplenote_get_note(note.key, {self.note_db.update_body(note.key, body: $0)})
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return fetchedResultController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return fetchedResultController.sections![section].numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let note = fetchedResultController.objectAtIndexPath(indexPath) as Note

        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier:"ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let date = NSDate(timeIntervalSince1970: note.modifydate)
        cell.textLabel?.text = formatter.stringFromDate(date)
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
            let note = fetchedResultController.objectAtIndexPath(indexPath!) as Note
            println("note.body: \(note.body)")
            let controller = segue.destinationViewController as NoteViewController
            controller.note = note
        }
    }

}
