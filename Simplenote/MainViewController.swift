//
//  MainViewController.swift
//  View controller for main list view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var token: String?
    let email = "abc@example.com"
    let password = "password"
    let note_db = NoteDatabase()
    var fetchedResultController = NSFetchedResultsController()

    @IBAction func refreshTapped(sender: AnyObject) {
        self.simplenote_get_index(updateNoteDatabase)
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

    // MARK: - Simplenote access

    func simplenote_get_token(completion: (()->Void)!) {
        if self.token != nil {
            completion?()
            return
        }
        let str = "email=\(email)&password=\(password)"
        let encodedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let data = encodedStr?.dataUsingEncoding(NSUTF8StringEncoding)
        let base64data = data?.base64EncodedStringWithOptions(nil)
        let url = "http://simple-note.appspot.com/api/login"
        let params = [ base64data!: "" ]
        Alamofire.request(.POST, url, parameters: params, encoding: .URL).responseString {
            (_, _, res, _) in
            self.token = res
            println("Token: \(self.token)")
            completion?()
        }
    }

    func simplenote_get_index(completion: ((SwiftyJSON.JSON)->Void)!) {
        simplenote_get_token { () in
            let url = "http://simple-note.appspot.com/api2/index"
            let params = [ "auth": self.token!, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                println("Index: \(json)")
                completion?(json)
            }
        }
    }

    func simplenote_get_note(key: String, completion: (()->Void)!) {
        simplenote_get_token { () in
            let url = "https://simple-note.appspot.com/api2/data/" + key
            let params = [ "auth": self.token!, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                let body = json["content"].stringValue
                println("Body: \(body)")
                self.note_db.update_body(key, body: body)
                completion?()
            }
        }
    }

    func updateNoteDatabase(json: SwiftyJSON.JSON) {
        let count: Int = json["count"].intValue
        println("Note count: \(count)")

        let data = json["data"]
        for i in 0 ..< count {
            let key = data[i]["key"].stringValue
            let createdate: NSTimeInterval = data[i]["createdate"].doubleValue
            let modifydate: NSTimeInterval = data[i]["modifydate"].doubleValue
            let version = data[i]["version"].int32Value

            let date = NSDate(timeIntervalSince1970: modifydate)
            println("date: \(date), key: \(key)")

            note_db.update(key, createdate: createdate, modifydate: modifydate,
                           version: version)
            simplenote_get_note(key, nil)
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
