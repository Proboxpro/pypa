//
//  MessageService.swift
//  Boxx
//
//  Created by Nikita Larin on 26.12.2023.
//

import Foundation
import Firebase

struct MessageService {
    let messagesCollection = Firestore.firestore().collection("order")
    
    static let messagesCollection = Firestore.firestore().collection("order")
    
    static func sendMessage(_ text: String, toUser user: User) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = user.id
        let currentUserRef = messagesCollection.document (uid).collection(chatPartnerId).document()
        let chatPartnerRef = messagesCollection .document (chatPartnerId) .collection(uid)
        let id = currentUserRef.documentID
        let message = NewOrder(
            senderUid:uid,
            ownerUid: chatPartnerId,
            text: text,
            timestamp: Timestamp()
        )
        guard let messageData = try? Firestore.Encoder ().encode (message) else {return}
        currentUserRef.setData(messageData)
        chatPartnerRef.document(id).setData(messageData)
    }
    
    

}
