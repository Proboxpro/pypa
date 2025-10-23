//
//  Storage.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//

import Foundation

class StorageUserDefaults: UserDefaults {
    
//    static var levelName: LevelName? = "basic-kyc-level"
    static var levelName: LevelName? = "test"

    enum Key: String {
        case apiUrl
        case bearerToken
        case client
        case userId
        case levelName
        case externalActionId
        case lang
        case isSandbox
    }
    
    static func getString(_ key: Key) -> String? {
        return get(key) as? String
    }
    
    static func getBool(_ key: Key) -> Bool? {
        return get(key) as? Bool
    }

    static func get(_ key: Key) -> Any? {
        return standard.value(forKey: key.rawValue)
    }
    
    static func set(_ value: Any?, for key: Key) {
        standard.set(value, forKey: key.rawValue)
    }
}
