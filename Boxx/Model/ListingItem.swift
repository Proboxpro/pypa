//
//  ListingItem.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.12.2023.
//


import Foundation
import ExyteChat

struct ListingItem: Identifiable, Codable, Hashable{
    let id: String
    let ownerUid: String
    let ownerName: String
    let imageUrl: String
    var pricePerKillo: String
    let cityFrom: String
    let cityTo: String
    var imageUrls: String
    var startdate: String
    var conversation: FirestoreConversation?
    var isAuthorized: Bool = false
    var dateIsExpired: Bool = false
}
