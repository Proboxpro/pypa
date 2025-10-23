//
//  Feedback.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 19.12.2023.
//

import Foundation


struct Feedback: Identifiable, Codable, Hashable {
    var id: String
    var UserLogin: String
    var text: String
    var rating: String
    var imageUrl: String
    var imageUrls: String
}
