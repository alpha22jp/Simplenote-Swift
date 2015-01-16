//
//  Settings.swift
//  Simplenote
//
//  Created by alpha22jp on 2015/01/15.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import Foundation

class Setting<T> {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var key: String
    var initialValue: AnyObject

    init(key: String, initialValue: AnyObject){
        self.key = key
        self.initialValue = initialValue
        userDefaults.registerDefaults([key: initialValue])
    }
    func set(value: AnyObject) { userDefaults.setObject(value, forKey: key) }
    func get() -> T { return userDefaults.objectForKey(key) as T }
}

class Settings {
    let email = Setting<String>(key: "email", initialValue: "")
    let password = Setting<String>(key: "password", initialValue: "")
    let sort = Setting<Int>(key: "sort", initialValue: 0)
    let order = Setting<Int>(key: "order", initialValue: 0)

    class var sharedInstance: Settings {
        struct Static {
            static let instance = Settings()
        }
        return Static.instance
    }
    private init() {}
}
