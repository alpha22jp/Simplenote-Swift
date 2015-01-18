//
//  SettingAccountViewController.swift
//  View controller for setting acccount screen
//
//  Created by alpha22jp on 2015/01/17.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import UIKit

// MARK: - アカウント設定画面を管理するクラス
class SettingAccountViewController: UITableViewController {

    let settings = Settings.sharedInstance
    let simplenote = SimplenoteServer.sharedInstance
    let database = NoteDatabase.sharedInstance

    // MARK: - Storyboard connection

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    // MARK: Cancelボタンがタップされたときに呼ばれる
    @IBAction func didCancelButtonTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Saveボタンがタップされたときに呼ばれる
    @IBAction func didSaveButtonTap(sender: AnyObject) {
        if emailField.text == "" || passwordField.text == "" {
            showAlert("Error", message: "E-mail or Password field is empty")
            return
        }
        if emailField.text != settings.email.get() {
            // E-mailが変更されたときはデータベースをクリアする必要がある
            if database.isEmpty() {
                // データベースが空なのでクリアの必要なし
                resetAccount()
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                // アクションシートを表示して”OK"が押されたらデータベースをクリア
                showActionSheet("Confirmation", message: "Account changed. Are you sure to clear cached note data?") {
                    self.resetAccount()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        } else {
            // パスワードの変更だけのときはデータベースはクリアしない
            if passwordField.text != settings.password.get() {
                settings.password.set(passwordField.text)
                simplenote.setAccountInfo(emailField.text, password: passwordField.text)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // E-mailとPasswordのフィールドに現在の設定値をセット
        emailField.text = settings.email.get()
        passwordField.text = settings.password.get()
    }

    // MARK: - Utility functions

    // MARK: アカウント情報のリセットとデータベースのクリアを行う
    private func resetAccount() {
        database.deleteAllNotes()
        settings.email.set(emailField.text)
        settings.password.set(passwordField.text)
        simplenote.setAccountInfo(emailField.text, password: passwordField.text)
    }

    // MARK: エラーを通知するアラート (OKボタンのみ) を表示する
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: 問い合わせのためのアクションシート (OK,Cancelボタン) を表示する
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

}
