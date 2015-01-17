//
//  SettingViewController.swift
//  Simplenote
//
//  Created by alpha22jp on 2015/01/10.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {

    let settings = Settings.sharedInstance
    let sortItems = ["Modify Date", "Create Date"]
    let orderItems = ["Newest First", "Oldest First"]

    @IBAction func didDoneButtonTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let email = settings.email.get()
            if email != "" { cell.detailTextLabel?.text = email }
        case (1, 0): cell.detailTextLabel?.text = sortItems[settings.sort.get()]
        case (1, 1): cell.detailTextLabel?.text = orderItems[settings.order.get()]
        default: break
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        println("segue.identifier: \(segue.identifier)")
        // Navigate to SettingDetail (show (e.g. push))
        if segue.identifier == "sortByDetail" {
            let controller = segue.destinationViewController as SettingDetailController
            controller.setting = settings.sort
            controller.items = sortItems
        } else if segue.identifier == "orderDetail" {
            let controller = segue.destinationViewController as SettingDetailController
            controller.setting = settings.order
            controller.items = orderItems
        }
    }

}
