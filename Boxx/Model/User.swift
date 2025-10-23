//
//  User.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import Foundation
import FirebaseFirestore
import Firebase
import ExyteChat

struct User: Identifiable, Codable, Hashable{
    let id: String
    let fullname: String
    var login: String
    let email: String
    var imageUrl: String?
    let number: String
    // вериф 10 урок странного чела
    
    var isCurrentUser: Bool  {
        return Auth.auth().currentUser?.uid == id 
    }
    
    var initials: String{
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string (from: components)
        }
        
        return ""
    }
    
    func asExyteUser() -> ExyteChat.User {
        let isCurrentUser = Auth.auth().currentUser?.uid == self.id
        if let imageUrl = self.imageUrl {
            return ExyteChat.User(id: self.id, name: self.fullname, avatarURL: URL(string: imageUrl), isCurrentUser: isCurrentUser)
        } else {
            return ExyteChat.User(id: self.id, name: self.fullname, avatarURL: nil, isCurrentUser: isCurrentUser)
        }
    }
}

extension User {
    static var TEST_USER = User(id: NSUUID().uuidString, fullname:"Никита Ларин",login:"Slam", email: "test@mail.ru", imageUrl: "sdcsdc", number: "89533453471")
}
