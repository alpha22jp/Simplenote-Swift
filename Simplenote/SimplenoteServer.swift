//
//  SimplenoteServer.swift
//  Simplenote server access
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

final class SimplenoteServer {
    var token: String!
    var email: String!
    var password: String!

    struct NoteAttributes {
        var key: String
        var createdate: NSTimeInterval
        var modifydate: NSTimeInterval
        var version: Int32
        var deleted: Int32
        var markdown: Bool
    }

    enum Result: String {
        case Success = "Success"
        case NoAccountInformation = "No Account Information"
        case ServerConnectionError = "Server Connection Error"
        case UserAuthenticationError = "User Authentication Error"
        case UnknownError = "Unknown Error"

        func success() -> Bool { return (self == Success) }
    }

    class var sharedInstance: SimplenoteServer {
        struct Static {
            static let instance = SimplenoteServer()
        }
        return Static.instance
    }
    private init(){}

    func setAccountInfo(email: String, password: String){
        println(__FUNCTION__, "email: \(email) password: \(password)")
        self.email = email
        self.password = password
        self.token = nil // アカウント情報が変更されたらトークンをリセット
    }

    private func statusCodeToResult(statusCode: Int) -> Result {
        // ステータスコードに応じてresultを設定
        switch statusCode {
        case 200:
            return Result.Success
        case 400:
            // ユーザー認証失敗の場合は400が返る
            return Result.UserAuthenticationError
        default:
            // それ以外は一律サーバー接続エラーとする
            return Result.ServerConnectionError
        }
    }

    private func getToken(completion: ((Result, String?)->Void)!) {
        // トークンを取得済みの場合は、サーバーから取得しないで再利用する
        // TODO: トークンがexpireしていた場合の対応が必要
        if self.token != nil {
            completion?(Result.Success, self.token)
            return
        }
        // アカウント情報が設定されているかを確認
        if email == nil || password == nil {
            completion?(Result.NoAccountInformation, nil)
            return
        }
        // パラメータを生成する (URLエンコード＆base64エンコード)
        let str = "email=\(email)&password=\(password)"
        let encodedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let data = encodedStr?.dataUsingEncoding(NSUTF8StringEncoding)
        let base64data = data?.base64EncodedStringWithOptions(nil)
        let url = "http://simple-note.appspot.com/api/login"
        let params = [ base64data!: "" ]
        // サーバーにリクエストを送信してレスポンスを取得
        Alamofire.request(.POST, url, parameters: params, encoding: .URL).responseString {
            (_, res, data, _) in
            println(__FUNCTION__, "Status Code: \(res?.statusCode)")
            var statusCode = 0
            if let _res = res {
                statusCode = _res.statusCode
            }
            var result = self.statusCodeToResult(statusCode)
            if result.success() {
                result = Result.UnknownError
                println(__FUNCTION__, "Token: \(data)")
                if let _data = data {
                    if _data != "" {
                        result = Result.Success
                        self.token = _data
                    }
                }
            }
            completion?(result, self.token ?? "")
        }
    }

    private func makeNoteAttributes(data: JSON) -> NoteAttributes {
        let systemtags = data["systemtags"]
        var markdown = false
        for i in 0 ..< systemtags.count {
            if systemtags[i].stringValue == "markdown" { markdown = true }
        }
        return NoteAttributes(key: data["key"].stringValue,
                              createdate: data["createdate"].doubleValue,
                              modifydate: data["modifydate"].doubleValue,
                              version: data["version"].int32Value,
                              deleted: data["deleted"].int32Value,
                              markdown: markdown)
    }

    func getIndex(completion: ((Result, [NoteAttributes]!)->Void)!) {
        getToken { (result, token) in
            if !result.success() {
                completion?(result, nil)
                return
            }
            let url = "http://simple-note.appspot.com/api2/index"
            let params = [ "auth": token, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, res, json, _) in
                println(__FUNCTION__, "Status Code: \(res?.statusCode)")
                var statusCode = 0
                if let _res = res {
                    statusCode = _res.statusCode
                }
                var result = self.statusCodeToResult(statusCode)
                if !result.success() {
                    completion?(result, nil)
                    return
                }
                let count: Int = json["count"].intValue
                println(__FUNCTION__, "Note count: \(count)")
                let data = json["data"]
                var noteAttrList: [NoteAttributes] = []
                for i in 0 ..< count {
                    let attr = self.makeNoteAttributes(data[i])
                    noteAttrList.append(attr)
                }
                completion?(Result.Success, noteAttrList)
            }
        }
    }

    func getNote(key: String, completion: ((Result, NoteAttributes!, String!)->Void)!) {
        getToken { (result, token) in
            if !result.success() {
                completion?(result, nil, nil)
                return
            }
            let url = "https://simple-note.appspot.com/api2/data/" + key
            let params = [ "auth": token, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, res, json, _) in
                println(__FUNCTION__, "Status Code: \(res?.statusCode)")
                var statusCode = 0
                if let _res = res {
                    statusCode = _res.statusCode
                }
                var result = self.statusCodeToResult(statusCode)
                if !result.success() {
                    completion?(result, nil, nil)
                    return
                }
                println(__FUNCTION__, "Note: \(json)")
                let attr = self.makeNoteAttributes(json)
                let content = json["content"].stringValue
                completion?(Result.Success, attr, content)
            }
        }
    }
}
