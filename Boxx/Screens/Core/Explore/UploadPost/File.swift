//
//  File.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 20.11.2023.
//

import Foundation
import Firebase

struct Order: Identifiable {
    
    
    var id: String = UUID().uuidString
    var login: String
    var numbkilo: String
    var price: String
    var freeForm: String
    var startDate: Date
    
    var representation : [String: Any]{
        var repres = [String : Any]()
        repres["id"] = id
        repres["login"] = login
        repres["startDate"] = startDate
        repres["numbkilo"] = numbkilo
        repres["price"] = price
        repres["freeForm"] = freeForm
        return repres
    }
    }

