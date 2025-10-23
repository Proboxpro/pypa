//
//  PostViewModel.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 19.11.2023.
//

import Foundation
import Firebase



class PostViewModel: ObservableObject {
    
    func AddInfo(freeForm: String, numbkilo: Int, data.name: String, )
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let db = Firestore.firestore()
        db.collection("Customers").document().setData([ "uid": uid, "KG": numbkilo, "FreeForm": freeForm, "Date": startdate, "City": data.name, "Price": price])
    }
}
