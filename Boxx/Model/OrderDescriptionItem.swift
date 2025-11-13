//
//  OrderDescriptionItem.swift
//  Boxx
//
//  Created by Руслан Парастаев on 17.04.2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum OwnerDealStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
}

enum RecipientDealStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case expired = "expired"
}

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
    var isPickedUp: Bool
    var isInDelivery: Bool
    var isDelivered: Bool
    
    var pickedUpDate: Date?
    var deliveredDate: Date?
    
    let isCompleted: Bool
    
    var ownerDealStatus: OwnerDealStatus = .pending
    var recipientDealStatus: RecipientDealStatus = .pending
    var recipientResponseDeadline: Date? // Время истечения для recipient (creationTime + 1 час)
}

enum OrderStatus: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    
    case isSent = "Отправлен"
    case isPickedUp = "Забран"
    case isInDelivery = "Актуальные"
    case isDelivered = "Завершённые"
}
