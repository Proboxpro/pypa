//
//  OrderViewModel.swift
//  Boxx
//
//  Created by Максим Алексеев  on 04.03.2024.
//  Changed by Руслан Парастаев on 14.04.2024.
//  Edited by Sasha Soldatov on 29.10.2025.
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
    
    func conversationForUsers(orderDocumentId: String? = nil) async -> Conversation? {
        // Ищем существующую conversation с теми же участниками и тем же orderDocumentId
        let selectedUserIds = Set(selectedUsers.map { $0.id })
        
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("conversations")
                .whereField("users", arrayContains: currentUserId)
                .getDocuments()
            
            for document in snapshot.documents {
                let data = document.data()
                if let userIds = data["users"] as? [String],
                   let isGroup = data["isGroup"] as? Bool,
                   isGroup == true {
                    let conversationUserIds = Set(userIds)
                    let conversationOrderId = data["orderDocumentId"] as? String
                    
                    // Сравниваем участников и orderDocumentId (если он указан)
                    if conversationUserIds == selectedUserIds && conversationUserIds.count == selectedUserIds.count {
                        // Если orderDocumentId указан, то чат должен иметь тот же orderDocumentId
                        if let orderDocumentId = orderDocumentId {
                            if conversationOrderId != orderDocumentId {
                                continue // Пропускаем чаты с другими orderDocumentId
                            }
                        }
                        
                        await MessageService.shared.getConversations()
                        
                        // Ищем в загруженных conversations
                        if let found = MessageService.shared.conversations.first(where: { $0.id == document.documentID }) {
                            return found
                        } else {
                            let users = selectedUsers.filter { conversationUserIds.contains($0.id) }
                            if users.count == conversationUserIds.count {
                                let title = users.map { $0.login }.joined(separator: " ")
                                let pictureURL = data["pictureURL"] as? String
                                let picURL = pictureURL.flatMap { URL(string: $0) }
                                let conversation = Conversation(
                                    id: document.documentID,
                                    users: users,
                                    pictureURL: picURL,
                                    title: title,
                                    isGroup: true
                                )
                                return conversation
                            }
                        }
                    }
                }
            }
        } catch {
        }
        
        // Также проверяем в загруженных conversations (если там есть orderDocumentId)
        for conversation in MessageService.shared.conversations {
            let conversationUserIds = Set(conversation.users.map { $0.id })
            if conversationUserIds == selectedUserIds && conversationUserIds.count == selectedUserIds.count {
                // Если orderDocumentId указан, нужно проверить его в Firestore
                // Для простоты пропускаем этот путь, если orderDocumentId указан
                // и продолжаем к созданию нового чата
                if orderDocumentId != nil {
                    continue
                }
                return conversation
            }
        }
        
        if selectedUsers.count >= 2 {
            return await createConversation(selectedUsers, orderDocumentId: orderDocumentId)
        }
        
        return nil
    }
    
    func createConversation(_ users: [User], orderDocumentId: String? = nil) async -> Conversation? {
        //        let pictureURL = await UploadingManager.uploadImageMedia(picture)
        if let image = await createPictureForUsers(),
           let data = image.jpegData(compressionQuality: 0.8),
           let url = try? await authViewModel.saveConversationImage(data: data) {
            return await createConversation(users, pictureURL: url, orderDocumentId: orderDocumentId)
        } else {
            return await createConversation(users, pictureURL: nil, orderDocumentId: orderDocumentId)
        }
    }
    
    private func createConversation(_ users: [User], pictureURL: URL?, orderDocumentId: String?) async -> Conversation? {
        let allUserIds = users.map { $0.id }
        let title = users.map { $0.login }.joined(separator: " ")
        var dict: [String : Any] = [
            "users": allUserIds,
            //            "usersUnreadCountInfo": Dictionary(uniqueKeysWithValues: allUserIds.map { ($0, 0) } ),
            "isGroup": true,
            "pictureURL": pictureURL?.absoluteString ?? "",
            "title": title
        ]
        
        // Добавляем orderDocumentId если он указан
        if let orderDocumentId = orderDocumentId {
            dict["orderDocumentId"] = orderDocumentId
        }
        
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
