//
//  SettingViewController.swift
//  Simplenote
//
//  Created by alpha22jp on 2015/01/10.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    let setting = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func okButtonTapped(sender: AnyObject) {
        println("email: \(email.text) password: \(password.text)")
        setting.setObject(email.text, forKey: "email")
        setting.setObject(password.text, forKey: "password")

        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let emailSaved = setting.stringForKey("email") {
            email.text = emailSaved
        }
        if let passwordSaved = setting.stringForKey("password") {
            password.text = passwordSaved
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
