//
//  NoteViewController.swift
//  View controller for each note view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var textview: UITextView!
    var note: Note?

    func dismissViewController() {
        navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textview.text = note!.body
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
