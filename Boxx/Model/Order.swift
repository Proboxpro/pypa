//
//  Order.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 19.12.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Order: Identifiable, Codable, Hashable {
    
    @DocumentID var orderId: String?
    let senderName: String
    let ownerName: String
    let senderUid: String
    let ownerUid: String
    let description: String
    let value: String
    let cityFrom: String
    let cityTo: String
    let imageUrls: String
    let recipient: String
    let ownerImageUrl: String
    let timestamp: Timestamp
    
    var id: String {
        return orderId ?? NSUUID().uuidString
    }
}
