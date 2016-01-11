//
//  Settings.swift
//  Setting values control
//
//  Created by alpha22jp on 2015/01/15.
//  Copyright (c) 2015 alpha22jp@gmail.com. All rights reserved.
//

import Foundation

// MARK: - 個々の設定値を保持するクラス
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
    func get() -> T { return userDefaults.objectForKey(key) as! T }
}

// MARK: - 設定値を管理するクラス
class Settings {
    let email = Setting<String>(key: "email", initialValue: "")
    let password = Setting<String>(key: "password", initialValue: "")
    let sort = Setting<Int>(key: "sort", initialValue: 0)
    let order = Setting<Int>(key: "order", initialValue: 0)

    static let instance = Settings()
    class var sharedInstance: Settings { return instance }
    private init(){}
}
