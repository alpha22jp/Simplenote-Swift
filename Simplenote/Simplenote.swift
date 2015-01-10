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
    }

    init(){}

    func setAccountInfo(email: String, password: String){
        self.email = email
        self.password = password
    }

    private func getToken(completion: ((token: String?)->Void)!) {
        if self.token != nil {
            completion?(token: self.token)
            return
        }
        if email == nil || password == nil { return }
        let str = "email=\(email!)&password=\(password!)"
        let encodedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let data = encodedStr?.dataUsingEncoding(NSUTF8StringEncoding)
        let base64data = data?.base64EncodedStringWithOptions(nil)
        let url = "http://simple-note.appspot.com/api/login"
        let params = [ base64data!: "" ]
        Alamofire.request(.POST, url, parameters: params, encoding: .URL).responseString {
            (_, _, res, _) in
            self.token = res
            println("Token: \(self.token)")
            completion?(token: res)
        }
    }

    func getIndex(completion: (([Note])->Void)!) {
        getToken { (token) in
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
                                    version: data[i]["version"].int32Value)
                    note_array.append(note)
                }
                completion?(note_array)
            }
        }
    }

    func getNote(key: String, completion: ((note: Note, content: String)->Void)!) {
        getToken { (token) in
            let url = "https://simple-note.appspot.com/api2/data/" + key
            let params = [ "auth": token!, "email": self.email! ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                println("Note: \(json)")
                let note = Note(key: json["key"].stringValue,
                                createdate: json["createdate"].doubleValue,
                                modifydate: json["modifydate"].doubleValue,
                                version: json["version"].int32Value)
                let content = json["content"].stringValue
                completion?(note: note, content: content)
            }
        }
    }
}
