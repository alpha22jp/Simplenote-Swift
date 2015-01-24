//
//  SettingMainViewController.swift
//  View controller for setting main screen
//
//  Created by alpha22jp on 2015/01/10.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

// MARK: - 設定のメイン画面を管理するクラス
class SettingMainViewController: UITableViewController {

    let settings = Settings.sharedInstance
    let sortItems = ["Modify Date", "Create Date"]
    let orderItems = ["Newest First", "Oldest First"]

    // MARK: - Storyboard connection

    // MARK: Doneボタンがタップされたときに呼ばれる
    @IBAction func didDoneButtonTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UIViewController

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    // MARK: 各セルの内容を設定する
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let email = settings.email.get()
            if !email.isEmpty { cell.detailTextLabel?.text = email }
        case (1, 0): cell.detailTextLabel?.text = sortItems[settings.sort.get()]
        case (1, 1): cell.detailTextLabel?.text = orderItems[settings.order.get()]
        default: break
        }
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(__FUNCTION__, "segue.identifier: \(segue.identifier)")
        if segue.identifier == "sortByDetail" {
            // Navigate to SettingDetailView (show (e.g. push))
            let controller = segue.destinationViewController as SettingDetailViewController
            controller.setting = settings.sort
            controller.items = sortItems
        } else if segue.identifier == "orderDetail" {
            // Navigate to SettingDetailView (show (e.g. push))
            let controller = segue.destinationViewController as SettingDetailViewController
            controller.setting = settings.order
            controller.items = orderItems
        } else if segue.identifier == "setAccount" {
            // Navigate to SettingAccountView (present modally)
        }
    }

}
