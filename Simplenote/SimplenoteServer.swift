//
//  SimplenoteServer.swift
//  Simplenote server access
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import Alamofire
import SwiftyJSON

// MARK: Simplenoteサーバーへのアクセスを管理するクラス
final class SimplenoteServer {

    let serverUrl = "https://simple-note.appspot.com/"
    var token: String = "" // トークン
    var email: String = "" // E-mailアドレス
    var password: String = "" // パスワード

    // MARK: ノートの属性情報
    struct NoteAttributes {
        var key: String // キー (ノートの固有ID)
        var syncnum: Int32 // 同期回数
        var createdate: NSTimeInterval // 作成日時
        var modifydate: NSTimeInterval // 最終変更日時
        var version: Int32 // バージョン
        var deleted: Int32 // 削除済みフラグ
        var markdown: Bool // マークダウン表示モードフラグ
    }

    // MARK: サーバーの応答結果
    enum Result: String {
        case Success = "Success" // 成功
        case NoAccountInformation = "No Account Information" // アカウント情報なし
        case ServerConnectionError = "Server Connection Error" // サーバー接続エラー
        case UserAuthenticationError = "User Authentication Error" // 認証エラー
        case UnknownError = "Unknown Error" // その他の不明なエラー

        func success() -> Bool { return (self == Success) }
    }

    class var sharedInstance: SimplenoteServer {
        struct Static {
            static let instance = SimplenoteServer()
        }
        return Static.instance
    }
    private init(){}

    // MARK: サーバアクセス時に必要なアカウント情報をセットする
    func setAccountInfo(email: String, password: String){
        println(__FUNCTION__, "email: \(email) password: \(password)")
        self.email = email
        self.password = password
        self.token = "" // アカウント情報が変更されたらトークンをリセット
    }

    // MARK: HTTPステータスコードをResultに変換する
    private func statusCodeToResult(statusCode: Int) -> Result {
        // ステータスコードに応じてresultを設定
        switch statusCode {
        case 200:
            return .Success
        case 400:
            // ユーザー認証失敗の場合は400が返る
            return .UserAuthenticationError
        default:
            // それ以外は一律サーバー接続エラーとする
            return .ServerConnectionError
        }
    }

    // MARK: トークンをサーバーから取得する
    private func getToken(completion: ((Result, String)->Void)!) {
        // トークンを取得済みの場合は、サーバーから取得しないで再利用する
        // TODO: トークンがexpireしていた場合の対応が必要
        if !self.token.isEmpty {
            completion?(.Success, self.token)
            return
        }
        // アカウント情報が設定されているかを確認
        if email.isEmpty || password.isEmpty {
            completion?(.NoAccountInformation, "")
            return
        }
        // パラメータを生成する (URLエンコード＆base64エンコード)
        let str = "email=\(email)&password=\(password)"
        let encodedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let data = encodedStr?.dataUsingEncoding(NSUTF8StringEncoding)
        let base64data = data?.base64EncodedStringWithOptions(nil)
        let url = serverUrl + "api/login"
        let params = [ base64data!: "" ]
        // サーバーにリクエストを送信してレスポンスを取得
        Alamofire.request(.POST, url, parameters: params, encoding: .URL).responseString {
            (_, res, data, _) in
            var statusCode = (res == nil ? 0 : res!.statusCode)
            println(__FUNCTION__, "Status Code: \(statusCode)")
            var result = self.statusCodeToResult(statusCode)
            if result.success() {
                println(__FUNCTION__, "Token: \(data)")
                if data == nil || data!.isEmpty {
                    result = .UnknownError
                } else {
                    result = .Success
                    self.token = data!
                }
            }
            completion?(result, self.token)
        }
    }

    // MARK: 応答のJSONデータからノート属性情報を生成する
    private func makeNoteAttributes(data: JSON) -> NoteAttributes {
        let systemtags = data["systemtags"].arrayValue
        let markdown = (systemtags.filter { $0.stringValue == "markdown" }.count > 0)
        return NoteAttributes(key: data["key"].stringValue,
                              syncnum: data["syncnum"].int32Value,
                              createdate: data["createdate"].doubleValue,
                              modifydate: data["modifydate"].doubleValue,
                              version: data["version"].int32Value,
                              deleted: data["deleted"].int32Value,
                              markdown: markdown)
    }

    private func getIndexInternal(noteAttrList: [NoteAttributes], mark: String,
                                  completion: ((Result, [NoteAttributes]!)->Void)!) {
        let url = self.serverUrl + "api2/index"
        var params = ["length": "100", "auth": token, "email": self.email]
        if !mark.isEmpty { params["mark"] = mark }
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            (_, res, resData, _) in
            var statusCode = (res == nil ? 0 : res!.statusCode)
            println(__FUNCTION__, "Status Code: \(statusCode)")
            var result = self.statusCodeToResult(statusCode)
            if resData == nil { result = .UnknownError }
            if !result.success() {
                completion?(result, nil)
                return
            }
            let json = JSON(resData!)
            var newNoteAttrList: [NoteAttributes] = noteAttrList
            json["data"].arrayValue.map { newNoteAttrList.append(self.makeNoteAttributes($0)) }
            let newMark = json["mark"].stringValue
            if newMark.isEmpty {
                completion?(.Success, newNoteAttrList)
            } else {
                self.getIndexInternal(newNoteAttrList, mark: newMark, completion: completion)
            }
        }
    }

    // MARK: 全ノートの属性情報をサーバーから取得する
    func getIndex(completion: ((Result, [NoteAttributes]!)->Void)!) {
        getToken { (result, token) in
            if !result.success() {
                completion?(result, nil)
                return
            }
            self.getIndexInternal([], mark: "", completion: completion)
        }
    }

    // MARK: ノートの内容 (＋属性情報) をサーバーから取得する
    func getNote(key: String, completion: ((Result, NoteAttributes!, String!)->Void)!) {
        getToken { (result, token) in
            if !result.success() {
                completion?(result, nil, nil)
                return
            }
            let url = self.serverUrl + "api2/data/" + key
            let params = [ "auth": token, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseJSON {
                (_, res, data, _) in
                println(__FUNCTION__, "Status Code: \(res?.statusCode)")
                var statusCode = (res == nil ? 0 : res!.statusCode)
                var result = self.statusCodeToResult(statusCode)
                if data == nil { result = .UnknownError }
                if !result.success() {
                    completion?(result, nil, nil)
                    return
                }
                let json = JSON(data!)
                println(__FUNCTION__, "Note: \(json)")
                let attr = self.makeNoteAttributes(json)
                let content = json["content"].stringValue
                completion?(.Success, attr, content)
            }
        }
    }

    // MARK: ノートを指定した内容で更新 (または作成) する
    func updateNote(key: String, content: String, version: Int32, modifydate: NSTimeInterval,
                    completion: ((Result, NoteAttributes!, String!)->Void)!) {
        getToken { (result, token) in
            if !result.success() {
                completion?(result, nil, nil)
                return
            }
            let url = self.serverUrl + "api2/data" +
            (key.isEmpty ? "" : "/\(key)") + "?auth=\(token)&emil=\(self.email)"
            let params = [ "content": content, "version": String(version),
                           "modifydate": NSString(format: "%.6f", modifydate) ]
            Alamofire.request(.POST, url, parameters: params, encoding: .JSON).responseJSON {
                (req, res, data, _) in
                var statusCode = (res == nil ? 0 : res!.statusCode)
                println(__FUNCTION__, "Status Code: \(statusCode)")
                var result = self.statusCodeToResult(statusCode)
                if data == nil { result = .UnknownError }
                if !result.success() {
                    completion?(result, nil, nil)
                    return
                }
                let json = JSON(data!)
                println(__FUNCTION__, "Note: \(json)")
                let attr = self.makeNoteAttributes(json)
                // マージが発生したときだけ、レスポンスにcontentが含まれる
                let contentUpdated = (json["content"].stringValue.isEmpty ?
                                      content : json["content"].stringValue)
                completion?(.Success, attr, contentUpdated)
            }
        }
    }
}
