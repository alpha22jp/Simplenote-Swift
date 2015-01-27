//
//  NoteViewController.swift
//  View controller for each note view screen
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

// MARK: - ノート表示画面を管理するクラス
class NoteViewController: UIViewController, UIWebViewDelegate {

    var note: Note! // 表示する対象のノート (画面遷移時にセットされる)
    let webView = UIWebView()
    let textView = UITextView()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var view: UIView!

        if note.markdown {
            webView.delegate = self
            view = webView
        } else {
            textView.editable = false
            view = textView
        }

        // ノートを表示するビュー (textView or webView) を追加
        view.frame = self.view.bounds
        self.view.addSubview(view)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // ノート編集画面から戻った時の再描画に必要
        if note.markdown {
            var markdown = Markdown()
            let cssPath = NSBundle.mainBundle().pathForResource("default", ofType: "css")
            let htmlHeader = "<head><link href='\(cssPath!)' rel='stylesheet'/></head>"
            let html = htmlHeader + markdown.transform(note.content)
            webView.loadHTMLString(html, baseURL: NSBundle.mainBundle().bundleURL)
        } else {
            textView.text = note.content
        }
    }

    // MARK: - UIWebViewDelegate

    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            // リンクのクリックはSafariで開く
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        return true
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(__FUNCTION__, "segue.identifier: \(segue.identifier)")
        if segue.identifier == "toNoteEditView" {
            // Navigate to NoteEditView (present modally)
            let navi = segue.destinationViewController as UINavigationController
            let controller = navi.topViewController as NoteEditViewController
            controller.note = note
        }
    }

}
