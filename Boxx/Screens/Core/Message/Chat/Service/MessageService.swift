//
//  MessageService.swift
//  Boxx
//
//  Created by Максим Алексеев  on 28.02.2024.
//

import Foundation
import FirebaseFirestore
import Firebase

class MessageService {
    @Published var users: [User] = [] // not including current user
    @Published var allUsers: [User] = []

    @Published var conversations: [Conversation] = []
    
    static var shared = MessageService()
    
    func getConversations() async {
        let snapshot = try? await Firestore.firestore()
            .collection("conversations")
            .whereField("users", arrayContains: Auth.auth().currentUser?.uid)
            .getDocuments()
        storeConversations(snapshot)
    }
    
    func getUsers() async {
        let snapshot = try? await Firestore.firestore()
            .collection("users")
            .getDocuments()
        storeUsers(snapshot)
    }
    
    func subscribeToUpdates() {
        Firestore.firestore()
            .collection("users")
            .addSnapshotListener { [weak self] (snapshot, _) in
                guard let self else { return }
                self.storeUsers(snapshot)
                Task {
                    await self.getConversations() // update in case some new user didn't make it in time for conversations subscription
                }
            }

        Firestore.firestore()
            .collection("conversations")
            .whereField("users", arrayContains: Auth.auth().currentUser?.uid)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                self?.storeConversations(snapshot)
            }
    }
    
    private func storeUsers(_ snapshot: QuerySnapshot?) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.main.async { [weak self] in
            let users: [User] = snapshot?.documents
                .compactMap { document in
                    let dict = document.data()
//                    if document.documentID == currentUserId {
//                        return nil // skip current user
//                    }
//                    if let name = dict["nickname"] as? String {
//                        let avatarURL = dict["avatarURL"] as? String
//                        
////                        return User(id: document.documentID, name: name, avatarURL: URL(string: avatarURL ?? ""), isCurrentUser: currentUserId == document.documentID)
//                        return User(id: document.documentID, fullname: name, login: , email: , imageUrl: nil)
//                    }
                    
                    let fullname = dict["fullname"] as? String ?? ""
                    let login = dict["login"] as? String ?? ""
                    let email = dict["email"] as? String ?? ""
                    let number = dict["number"] as? String ?? ""
                    let profileImageUrlString = dict["imageUrl"] as? String
                    
                    if let uid = dict["id"] as? String {
                        return User(id: uid, fullname: fullname, login: login, email: email, imageUrl: profileImageUrlString, number: number)
                    }
                    
                    return nil
                } ?? []

            self?.users = users.filter { !$0.isCurrentUser }
            self?.allUsers = users
        }
    }
    
    private func storeConversations(_ snapshot: QuerySnapshot?) {
        DispatchQueue.main.async { [weak self] in
            self?.conversations = snapshot?.documents
                .compactMap { [weak self] document in
                    do {
                        let firestoreConversation = try document.data(as: FirestoreConversation.self)
                        return self?.makeConversation(document.documentID, firestoreConversation)
                    } catch {
                        print(error)
                    }

                    return nil
                }.sorted {
                    if let date1 = $0.latestMessage?.createdAt, let date2 = $1.latestMessage?.createdAt {
                        return date1 > date2
                    }
                    return $0.displayTitle < $1.displayTitle
                }
            ?? []
            print("----------")
            print(self?.conversations.count)
        }
    }
    
    /// maps FirestoreConversation into conversation
    private func makeConversation(_ id: String, _ firestoreConversation: FirestoreConversation) -> Conversation {
        var message: LatestMessageInChat? = nil
        if let flm = firestoreConversation.latestMessage,
           let user = allUsers.first(where: { $0.id == flm.userId }) {
            var subtext: String?
            
            message = LatestMessageInChat(
                senderName: user.fullname,
                createdAt: flm.createdAt,
                text: flm.text.isEmpty ? nil : flm.text,
                subtext: subtext
            )
        }
        let users = firestoreConversation.users.compactMap { id in
            allUsers.first(where: { $0.id == id })
        }
        
        if let pictureURLString = firestoreConversation.pictureURL,
           let url = URL(string: pictureURLString) {
            let conversation = Conversation(
                id: id,
                users: users,
                pictureURL: url,
                title: firestoreConversation.title,
                latestMessage: message,
                isGroup: firestoreConversation.isGroup
            )
            return conversation
        } else {
            let conversation = Conversation(
                id: id,
                users: users,
                pictureURL: nil,
                title: firestoreConversation.title,
                latestMessage: message,
                isGroup: firestoreConversation.isGroup
            )
            return conversation
        }
    }
}
