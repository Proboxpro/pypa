//
//  OrderViewModel.swift
//  Boxx
//
//  Created by Максим Алексеев  on 04.03.2024.
//  Changed by Руслан Парастаев on 14.04.2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import UIKit

class OrderViewModel: ObservableObject {
    var selectedUsers: [User] = []
    var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        //        self.selectedUsers = selectedUsers
        self.authViewModel = authViewModel
    }
    
    func fetchData() {
        Task {
            await MessageService.shared.getUsers()
            await MessageService.shared.getConversations()
        }
    }
    
    func selectUsers(_ userIds: [String]) async {
        //        userIds.forEach { id in
        for id in userIds {
            let userr = await authViewModel.fetchUser(by: id)
            if let user = userr, !user.id.isEmpty {
                selectedUsers.append(user)
            }
        }
    }
    
    func conversationForUsers() async -> Conversation? {
        // search in existing conversations
        print(111111111)
        print("Convs: \(MessageService.shared.conversations)")
        for conversation in MessageService.shared.conversations {
            print("pass 0")
            print("\(conversation.users.count) - \(selectedUsers.count)")
            if conversation.users.count == selectedUsers.count {
                print("pass 1")
                if conversation.users.sorted(by: { $0.fullname > $1.fullname }) == self.selectedUsers.sorted(by: { $0.fullname > $1.fullname }) {
                    print("pass 2")
                    print(conversation)
                    return conversation
                }
            }
        }
        
        // create new one for group
        if selectedUsers.count > 1 {
            return await createConversation(selectedUsers)
        }
        
        
        // only create individual when first message is sent, not here (ConversationViewModel)
        return nil
    }
    
    func createConversation(_ users: [User]) async -> Conversation? {
        //        let pictureURL = await UploadingManager.uploadImageMedia(picture)
        if let image = await createPictureForUsers(),
           let data = image.jpegData(compressionQuality: 0.8),
           let url = try? await authViewModel.saveConversationImage(data: data) {
            return await createConversation(users, url)
        } else {
            return await createConversation(users, nil)
        }
    }
    
    private func createConversation(_ users: [User], _ pictureURL: URL?) async -> Conversation? {
        let allUserIds = users.map { $0.id }
        let title = users.map { $0.login }.joined(separator: " ")
        let dict: [String : Any] = [
            "users": allUserIds,
            //            "usersUnreadCountInfo": Dictionary(uniqueKeysWithValues: allUserIds.map { ($0, 0) } ),
            "isGroup": true,
            "pictureURL": pictureURL?.absoluteString ?? "",
            "title": title
        ]
        
        return await withCheckedContinuation { continuation in
            var ref: DocumentReference? = nil
            ref = Firestore.firestore()
                .collection("conversations")
                .addDocument(data: dict) { err in
                    Task {
                        if let id = ref?.documentID {
                            if let current = await self.authViewModel.currentUser {
                                continuation.resume(returning: Conversation(id: id, users: users, pictureURL: pictureURL, title: title, isGroup: true))
                            }
                        }
                    }
                }
        }
    }
    
    private func createPictureForUsers() async -> UIImage? {
        await Task { () -> UIImage? in
            let filteredUsers = selectedUsers.filter { $0.id != Auth.auth().currentUser?.uid }
            var images: [UIImage] = []
            
            for user in filteredUsers {
                if let imageUrlString = user.imageUrl,
                   let url = URL(string: imageUrlString) {
                    let image = await UIImage.downloaded(from: url)
                    images.append(image)
                }
            }
            
            if images.isEmpty {
                return nil
            }
            
            return images.count == 1 ? images[0] : images[0].mergedSideBySide(with: images[1])
        }.value
    }
}
