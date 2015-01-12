//
//  Simplenote.swift
//  Simplenote server access
//
//  Created by alpha22jp on 2015/01/01.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class Simplenote {
    var token: String?
    var email: String?
    var password: String?

    struct Note {
        var key: String
        var createdate: NSTimeInterval
        var modifydate: NSTimeInterval
        var version: Int32
        var deleted: Int32
    }

    enum Result: String {
        case Success = "Success"
        case NoAccountInformation = "No Account Information"
        case ServerConnectionError = "Server Connection Error"
        case UserAuthenticationError = "User Authentication Error"
        case UnknownError = "Unknown Error"
    }

    init(){}

    func setAccountInfo(email: String, password: String){
        self.email = email
        self.password = password
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
        let str = "email=\(email!)&password=\(password!)"
        let encodedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let data = encodedStr?.dataUsingEncoding(NSUTF8StringEncoding)
        let base64data = data?.base64EncodedStringWithOptions(nil)
        let url = "http://simple-note.appspot.com/api/login"
        let params = [ base64data!: "" ]
        // サーバーにリクエストを送信してレスポンスを取得
        Alamofire.request(.POST, url, parameters: params, encoding: .URL).responseString {
            (_, res, data, _) in
            println("Status Code: \(res?.statusCode)")
            println("Data: \(data)")
            var statusCode = 0
            var result = Result.UnknownError
            if let _res = res {
                statusCode = _res.statusCode
            }
            // ステータスコードに応じてresultを設定
            switch statusCode {
            case 200:
                if let _data = data {
                    if _data != "" {
                        result = Result.Success
                        self.token = _data
                    }
                }
            case 400: // ユーザー認証失敗の場合は400が返る
                result = Result.UserAuthenticationError
            default: // それ以外は一律サーバー接続エラーとする
                result = Result.ServerConnectionError
            }
            completion?(result, result == Result.Success ? self.token : nil)
        }
    }

    func getIndex(completion: ((Result, [Note]!)->Void)!) {
        getToken { (result, token) in
            if result != Result.Success {
                completion?(result, nil)
                return
            }
            let url = "http://simple-note.appspot.com/api2/index"
            let params = [ "auth": token!, "email": self.email! ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                println("Index: \(json)")
                let count: Int = json["count"].intValue
                println("Note count: \(count)")
                let data = json["data"]
                var note_array: [Note] = []
                for i in 0 ..< count {
                    let note = Note(key: data[i]["key"].stringValue,
                                    createdate: data[i]["createdate"].doubleValue,
                                    modifydate: data[i]["modifydate"].doubleValue,
                                    version: data[i]["version"].int32Value,
                                    deleted: data[i]["deleted"].int32Value)
                    note_array.append(note)
                }
                completion?(Result.Success, note_array)
            }
        }
    }

    func getNote(key: String, completion: ((Result, Note!, String!)->Void)!) {
        getToken { (result, token) in
            if result != Result.Success {
                completion?(result, nil, nil)
                return
            }
            let url = "https://simple-note.appspot.com/api2/data/" + key
            let params = [ "auth": token!, "email": self.email! ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                println("Note: \(json)")
                let note = Note(key: json["key"].stringValue,
                                createdate: json["createdate"].doubleValue,
                                modifydate: json["modifydate"].doubleValue,
                                version: json["version"].int32Value,
                                deleted: json["deleted"].int32Value)
                let content = json["content"].stringValue
                completion?(Result.Success, note, content)
            }
        }
    }
}
