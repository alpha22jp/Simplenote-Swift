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
    let email = "abc@example.com"
    let password = "password"

    struct Note {
        var key: String
        var createdate: NSTimeInterval
        var modifydate: NSTimeInterval
        var version: Int32
    }

    init(){}
    func simplenote_get_token(completion: ((token: String?)->Void)!) {
        if self.token != nil {
            completion?(token: self.token)
            return
        }
        let str = "email=\(email)&password=\(password)"
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

    func simplenote_get_index(completion: (([Note])->Void)!) {
        simplenote_get_token { (token) in
            let url = "http://simple-note.appspot.com/api2/index"
            let params = [ "auth": token!, "email": self.email ]
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

    func simplenote_get_note(key: String, completion: ((content: String)->Void)!) {
        simplenote_get_token { (token) in
            let url = "https://simple-note.appspot.com/api2/data/" + key
            let params = [ "auth": token!, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                let content = json["content"].stringValue
                println("Content: \(content)")
                completion?(content: content)
            }
        }
    }
}
