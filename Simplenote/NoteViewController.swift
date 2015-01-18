//
//  NoteViewController.swift
//  View controller for each note view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UIWebViewDelegate {

    var note: Note!
    let webView = UIWebView()
    let textView = UITextView()

    func dismissViewController() {
        navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var view: UIView!

        if note.markdown {
            var markdown = Markdown()
            let text = markdown.transform(note.content)
            webView.delegate = self
            webView.loadHTMLString(text, baseURL: nil)
            view = webView
        } else {
            textView.text = note.content
            textView.editable = false
            view = textView
        }

        view.frame = self.view.bounds
        self.view.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        return true
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
