//
//  NewOrder.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 24.12.2023.
//

import Foundation

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct NewOrder: Identifiable, Codable, Hashable{
    @DocumentID var orderId: String?
    let senderUid: String
    let ownerUid: String
    let text: String
    let timestamp: Timestamp

    var id: String {
        return orderId ?? NSUUID().uuidString
    }
    var chatPartnerId: String {
        return senderUid == Auth.auth().currentUser?.uid ? senderUid: ownerUid}

    var isFromCurrentUser: Bool {
        return senderUid == Auth.auth().currentUser?.uid
    }
}
