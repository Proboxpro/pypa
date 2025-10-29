//
//  Language.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//

import Foundation

enum Language: String, Selectable {
    case system
    case preferred
    case en
    case de
    case fr
    case ru
}

extension Language {
    
    static var locale: String { current.identifier }
    
    static func setCurrent(_ lang: Language) {
        StorageUserDefaults.set(lang.rawValue, for: .lang)
    }
    
    static var current: Language {
        if let rawValue = StorageUserDefaults.getString(.lang) {
            return Language(rawValue: rawValue) ?? .system
        } else {
            return .system
        }
    }
    
    var identifier: String {
        switch self {
        case .system:
            return Locale.current.identifier
        case .preferred:
            return Locale.preferredLanguages.first ?? Locale.current.identifier
        default:
            return rawValue
        }
    }
    
    var name: String {
        switch self {
        case .system:
            return "Current Locale"
        case .preferred:
            return "Preferred Language"
        default:
            return Locale(identifier: identifier).localizedString(forLanguageCode: rawValue)?.capitalized ?? rawValue
        }
    }
}
