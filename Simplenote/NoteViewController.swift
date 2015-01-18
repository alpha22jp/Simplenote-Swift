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

        // ノートを表示するビュー (textView or webView) を追加
        view.frame = self.view.bounds
        self.view.addSubview(view)
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

}
