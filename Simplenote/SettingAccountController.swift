//
//  SettingAccountController.swift
//  Simplenote
//
//  Created by alpha22jp on 2015/01/17.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

class SettingAccountController: UITableViewController {

    let settings = Settings.sharedInstance
    let simplenote = Simplenote.sharedInstance
    let database = NoteDatabase.sharedInstance

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @IBAction func didCancelButtonTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didSaveButtonTap(sender: AnyObject) {
        if emailField.text == "" || passwordField.text == "" {
            showAlert("Error", message: "E-mail or Password field is empty")
            return
        }
        if emailField.text != settings.email.get() {
            if database.isEmpty() {
                resetAccount()
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                showActionSheet("Confirmation", message: "Account changed. Are you sure to clear cached note data?") {
                    self.resetAccount()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        } else {
            if passwordField.text != settings.password.get() {
                settings.password.set(passwordField.text)
                simplenote.setAccountInfo(emailField.text, password: passwordField.text)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    private func resetAccount() {
        database.deleteAllNotes()
        settings.email.set(emailField.text)
        settings.password.set(passwordField.text)
        simplenote.setAccountInfo(emailField.text, password: passwordField.text)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func showActionSheet(title: String, message: String, handler: ()->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let action = UIAlertAction(title: "OK", style: .Default) {
            (_) -> Void in handler()
        }
        alert.addAction(cancel)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailField.text = settings.email.get()
        passwordField.text = settings.password.get()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

}
