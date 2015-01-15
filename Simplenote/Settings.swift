//
//  Settings.swift
//  Simplenote
//
//  Created by alpha22jp on 2015/01/15.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import Foundation

class Settings {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let initialValue = ["email":"", "password":"", "sort":0, "order":0]

    var getUserDefaults: NSUserDefaults { get { return userDefaults } }

    var email: String {
        get { return userDefaults.stringForKey("email")! }
        set(val) { userDefaults.setObject(val, forKey: "email") }
    }
    var password: String {
        get { return userDefaults.stringForKey("password")! }
        set(val) { userDefaults.setObject(val, forKey: "password") }
    }
    var sort: Int {
        get { return userDefaults.integerForKey("sort") }
        set(val) { userDefaults.setObject(val, forKey: "sort") }
    }
    var order: Int {
        get { return userDefaults.integerForKey("order") }
        set(val) { userDefaults.setObject(val, forKey: "order") }
    }

    class var sharedInstance: Settings {
        struct Static {
            static let instance = Settings()
        }
        return Static.instance
    }
    private init() {
        userDefaults.registerDefaults(initialValue)
    }

}
