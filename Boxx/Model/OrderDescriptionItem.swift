//
//  OrderDescriptionItem.swift
//  Boxx
//
//  Created by Руслан Парастаев on 17.04.2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct OrderDescriptionItem: Identifiable, Codable, Hashable {
    let id: String
    let documentId: String
    
    let announcementId: String
    let ownerId: String
    let recipientId: String
    
//    let creationLat: Double?
//    let creationLon: Double?
    let cityFromLat: Double?
    let cityFromLon: Double?
    let cityToLat: Double?
    let cityToLon: Double?
    
    let cityFrom: String
    let cityTo: String
    let ownerName: String
    let creationTime: Date
    
    let description: String?
    let image: URL?
    let price: Int?
    
    var isSent: Bool
    var isInDelivery: Bool
    var isDelivered: Bool
    
    let isCompleted: Bool
}

enum OrderStatus: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    
    case isSent = "Отправлен"
    case isInDelivery = "Актуальные"
    case isDelivered = "Доставлен"
}
