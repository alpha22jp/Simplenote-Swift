//
//  NoteEditViewController.swift
//  View controller for note edit screen
//
//  Created by alpha22jp on 2015/01/25.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

class NoteEditViewController: UIViewController {

    var note: Note? // 編集する対象のノート (画面遷移時にセットされる)
    let database = NoteDatabase.sharedInstance

    // MARK: - Storyboard connection

    @IBOutlet weak var textView: UITextView!

    @IBAction func didSaveButtonTap(sender: AnyObject) {
        let date = NSDate().timeIntervalSince1970 // 現在時刻を取得
        if note == nil {
            print(__FUNCTION__, "Create new note")
            note = self.database.addNote("")
            note!.createdate = date
        }
        note!.modifydate = date
        note!.content = textView.text
        note!.ismodified = true // ローカル変更フラグを立てる
        self.database.saveContext()

        performSegueWithIdentifier("noteEditToMain", sender: nil)
    }

    @IBAction func didCancelButtonTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.text = note?.content ?? ""
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
