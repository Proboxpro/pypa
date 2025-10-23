//
//  CiityView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 14.03.2024.
//

import Foundation
import FirebaseFirestore
import Firebase

struct City: Identifiable, Codable, Hashable{
    let id: String
    let name: String
    let reg: String
    }
