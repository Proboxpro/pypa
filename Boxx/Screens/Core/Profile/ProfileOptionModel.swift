//
//  SwiftUIView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI
enum SettingOptionViewModel: Int, CaseIterable, Identifiable{
case darkmode
    case verif
    case privacy
    case notification
    var title: String{
        switch self {
        case .darkmode: return "Темная тема"
        case .verif: return "Верификация"
        case .privacy: return "Правила"
        case .notification: return "Уведомления"
            
        }
    }
    var imageName: String{
        switch self {
        case .darkmode: return "moon.circle.fill"
        case .verif: return "person.circle.fill"
        case .privacy: return "lock.circle"
        case .notification: return "bell.fill"
            
        }
    }
    var imageBackgroundColor: Color{
        switch self {
        case .darkmode: return Color.black
        case .verif: return Color(.systemGreen)
        case .privacy: return Color.blue
        case .notification: return Color(.systemPurple)
            
        }
    }
    var id: Int { return self .rawValue}
}
