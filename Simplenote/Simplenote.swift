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

    init(){}
    func simplenote_get_token(completion: (()->Void)!) {
        if self.token != nil {
            completion?()
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
            completion?()
        }
    }

    func simplenote_get_index(completion: ((SwiftyJSON.JSON)->Void)!) {
        simplenote_get_token { () in
            let url = "http://simple-note.appspot.com/api2/index"
            let params = [ "auth": self.token!, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                println("Index: \(json)")
                completion?(json)
            }
        }
    }

    func simplenote_get_note(key: String, completion: ((content: String)->Void)!) {
        simplenote_get_token { () in
            let url = "https://simple-note.appspot.com/api2/data/" + key
            let params = [ "auth": self.token!, "email": self.email ]
            Alamofire.request(.GET, url, parameters: params).responseSwiftyJSON {
                (_, _, json, _) in
                let content = json["content"].stringValue
                println("Content: \(content)")
                completion?(content: content)
            }
        }
    }
}
