////
////  Message.swift
////  Boxx
////
////  Created by Максим Алексеев  on 28.02.2024.
////
//
import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import ExyteChat

public struct FirestoreMessage: Codable, Hashable {
    
    /// message id
    @DocumentID public var messageId: String?
    /// user's id
    var userId: String
    @ServerTimestamp  var createdAt: Date?

    var text: String
    var replyMessage: FirestoreReply?
    var attachments: [FirestoreAttachment]

}

public struct FirestoreReply: Codable, Hashable {

    @DocumentID public var id: String?
    public var userId: String

    var text: String
}

public struct FirestoreAttachment: Codable, Hashable {
    public let thumbURL: String
    public let url: String
    public let type: AttachmentType
}
