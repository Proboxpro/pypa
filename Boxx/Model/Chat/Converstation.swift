//
//  Converstation.swift
//  Boxx
//
//  Created by Максим Алексеев  on 28.02.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

public struct Conversation: Identifiable, Hashable {
    public let id: String
    let users: [User]
//    let usersUnreadCountInfo: [String: Int]
    let pictureURL: URL?
    let isGroup: Bool
    let title: String
    
    let latestMessage: LatestMessageInChat?
    
    init(id: String, users: [User], usersUnreadCountInfo: [String: Int]? = nil, pictureURL: URL? = nil, title: String = "", latestMessage: LatestMessageInChat? = nil, isGroup: Bool) {
        self.id = id
        self.users = users
//        self.usersUnreadCountInfo = usersUnreadCountInfo ?? Dictionary(uniqueKeysWithValues: users.map { ($0.id, 0) } )
        self.pictureURL = pictureURL
        self.title = title
        self.latestMessage = latestMessage
        self.isGroup = isGroup
    }
    
    var notMeUsers: User? {
        users.filter { $0.id != Auth.auth().currentUser?.uid }.first
    }
    
    var displayTitle: String {
        return notMeUsers?.fullname ?? ""
    }
}
    
public struct LatestMessageInChat: Hashable {
    var senderName: String
    var createdAt: Date?
    var text: String?
    var subtext: String?
    
    var isMyMessage: Bool {
        Auth.auth().currentUser?.displayName == senderName
    }
}

public struct FirestoreConversation: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?
    let users: [String]
    let usersUnreadCountInfo: [String: Int]?
    let isGroup: Bool
    let pictureURL: String?
    let title: String
    let latestMessage: FirestoreMessage?
    
//    func asConversation() -> Conversation {
//        let users =
//        return Conversation(id: id, users: <#T##[User]#>, usersUnreadCountInfo: <#T##[String : Int]?#>, pictureURL: <#T##URL?#>, title: <#T##String#>, latestMessage: <#T##LatestMessageInChat?#>)
//    }
}
