//
//  ChatViewModel.swift
//  Boxx
//
//  Created by Максим Алексеев  on 28.02.2024.
//

import Foundation
import ExyteChat
import FirebaseFirestore
import Firebase
import Combine

@MainActor
class ChatViewModel: ObservableObject, Identifiable {
    // MARK: - Properties
    var authViewModel: AuthViewModel
    
    @Published var messages: [Message] = []
    
    var users: [User] = [] // not including current user
    var allUsers: [User] = []
    
    var conversationId: String?
    var conversation: Conversation? {
        if let id = conversationId {
            return MessageService.shared.conversations.first(where: { $0.id == id })
        }
        return nil
    }
    @Published var initialMessageText: String?
    var initialImageURL: URL?
    
    private var lock = NSRecursiveLock()
    
    private var subscriptions = Set<AnyCancellable>()
    private var subscriptionToConversationCreation: ListenerRegistration?
    
    private var conversationDocument: DocumentReference?
    private var messagesCollection: CollectionReference?
    
    
    // MARK: - Inits
    init(auth: AuthViewModel, receiverUser: User, initialMessageText: String? = nil, initialImageURL: URL? = nil) {
        self.authViewModel = auth
        self.users = [receiverUser]
        self.allUsers = [receiverUser]
        Task {
            if let currentUser = authViewModel.currentUser {
                self.allUsers.append(currentUser)
            }
        }
        subscribeToConversationCreation(user: receiverUser)
        
        self.initialMessageText = initialMessageText
        self.initialImageURL = initialImageURL
        self.initialMessageText
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { err in
                
            }, receiveValue: { text in
                self.sendInitialMessage(text)
            })
            .store(in: &subscriptions)
    }
    
    init(auth: AuthViewModel, conversation: Conversation, initialMessageText: String? = nil, initialImageURL: URL? = nil) {
        print(#function)
        self.authViewModel = auth
        self.allUsers = conversation.users
        self.users = conversation.users.filter { $0.id != auth.currentUser?.id }
        updateForConversation(conversation)
        
        self.initialMessageText = initialMessageText
        self.initialImageURL = initialImageURL
        self.initialMessageText
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { err in
                
            }, receiveValue: { text in
                self.sendInitialMessage(text)
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Iternal methods
    func subscribeToConversationCreation(user: User) {
        Task {
            subscriptionToConversationCreation = Firestore.firestore()
                .collection("conversations")
                .whereField("users", arrayContains: authViewModel.currentUser?.id)
                .addSnapshotListener() { [weak self] (snapshot, _) in
                    // check if this conversation was created by another user already
                    if let conversation = self?.conversationForUser(user) {
                        self?.updateForConversation(conversation)
                        self?.subscriptionToConversationCreation = nil
                    }
                }
        }
    }
    
    func updateForConversation(_ conversation: Conversation) {
        self.conversationId = conversation.id
        makeFirestoreReferences(conversation.id)
        subscribeToMessages()
    }
    
    func makeFirestoreReferences(_ conversationId: String) {
        self.conversationDocument = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
        
        self.messagesCollection = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
    }
    
    func sendMessage(_ draft: DraftMessage, usingDefaultImageURL: URL? = nil) {
        Task {
            /// create conversation in Firestore if needed
            if conversation == nil,
               users.count == 1,
               let user = users.first,
               let conversation = await createIndividualConversation(user) {
                updateForConversation(conversation)
            }
            
            guard let user = self.authViewModel.currentUser else { return }
            let id = UUID().uuidString
            
            if let imageUrl = user.imageUrl {
                
                let message = await Message.makeMessage(id: id, user: ExyteChat.User(id: user.id, name: user.fullname, avatarURL: URL(string: imageUrl), isCurrentUser: true), status: .sending, draft: draft, imageURL: usingDefaultImageURL)
                lock.withLock {
                    messages.append(message)
                }
            } else {
                let message = await Message.makeMessage(id: id, user: ExyteChat.User(id: user.id, name: user.fullname, avatarURL: nil, isCurrentUser: true), status: .sending, draft: draft, imageURL: usingDefaultImageURL)
                lock.withLock {
                    messages.append(message)
                }
            }
            
            /// convert to Firestore dictionary: replace users with userIds, upload medias and get urls, replace urls with strings
            let dict = await makeDraftMessageDictionary(draft, usingImageURL: usingDefaultImageURL )
            
            /// upload dictionary with the same id we fixed earlier, so Chat knows it's still the same message
            do {
                try await messagesCollection?.document(id).setData(dict)
            } catch {
                print("Error adding document: \(error)")
                lock.withLock {
                    if let index = messages.lastIndex(where: { $0.id == id }) {
                        messages[index].status = .error(draft)
                        print("alisaM error ", messages)
                    }
                }
            }
            
            /// update latest message in current conversation to be this one
            if let id = conversation?.id {
                try await Firestore.firestore()
                    .collection("conversations")
                    .document(id)
                    .updateData(["latestMessage" : dict])
            }
        }
    }
    
    func conversationForUsers(_ users: [User]) async -> Conversation? {
        // search in existing conversations
        for conversation in MessageService.shared.conversations {
            if conversation.users.count - 1 == users.count { // without current user
                var foundIt = true
                for user in users {
                    if !conversation.users.contains(user) {
                        foundIt = false
                        break
                    }
                }
                if foundIt {
                    return conversation
                }
            }
        }
        
        // create new one for group
        if users.count > 1 {
            return await createConversation(users)
        }
        
        // only create individual when first message is sent, not here (ConversationViewModel)
        return nil
    }
    
    // MARK: - Private
    private func sendInitialMessage(_ message: String?) {
        guard let message = message else { return }
        let draft = DraftMessage(text: message, medias: [], recording: nil, replyMessage: nil, createdAt: Date.now)
        if let initialImageURL = initialImageURL {
            sendMessage(draft, usingDefaultImageURL: initialImageURL)
        } else {
            sendMessage(draft)
        }
        subscriptions.removeAll()
    }
    
    private func makeDraftMessageDictionary(_ draft: DraftMessage, usingImageURL: URL? = nil) async -> [String: Any] {
        guard let user = authViewModel.currentUser else { return [:] }
        
        var attachments = [[String: Any]]()
        for media in draft.medias {
            var thumbURL, fullURL : URL?
            
            switch media.type {
            case .image:
                do {
                    if let data = await media.getData() {
                        thumbURL = try await authViewModel.saveOrderImage(data: data)
                        fullURL = thumbURL
                    }
                } catch {
                    print(error.localizedDescription)
                }
            case .video:
                break
            }
            
            if let thumbURL, let fullURL {
                attachments.append([
                    "thumbURL": thumbURL.absoluteString,
                    "url": fullURL.absoluteString,
                    "type": AttachmentType(mediaType: media.type).rawValue
                ])
            }
        }
        
        if let defaultImageURL = usingImageURL {
            attachments.append([
                "thumbURL": defaultImageURL.absoluteString,
                "url": defaultImageURL.absoluteString,
                "type": AttachmentType(mediaType: .image).rawValue
            ])
        }
        
        var replyDict: [String: Any]? = nil
        if let reply = draft.replyMessage {
            var replyRecordingDict: [String: Any]? = nil
            
            replyDict = [
                "id": reply.id,
                "userId": reply.user.id,
                "text": reply.text,
                "attachments": reply.attachments.map { [
                    "url": $0.full.absoluteString,
                    "type": $0.type.rawValue
                ] }
            ]
        }
        
        return [
            "userId": user.id,
            "createdAt": Timestamp(date: draft.createdAt),
            "isRead": Timestamp(date: draft.createdAt),
            "text": draft.text,
            "replyMessage": replyDict as Any,
            "attachments": attachments,
        ]
    }
    
    private func subscribeToMessages() {
        messagesCollection?
            .order(by: "createdAt", descending: false)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                guard let self = self else { return }
                let messages = snapshot?.documents
                    .compactMap { try? $0.data(as: FirestoreMessage.self) }
                    .compactMap { firestoreMessage -> ExyteChat.Message? in
                        let fmessage = firestoreMessage
                        guard
                            let messageId = fmessage.messageId,
                            let user = self.allUsers.first(where: { $0.id == fmessage.userId }),
                            let date = fmessage.createdAt
                        else { return nil }
                        
                        let convertAttachments: ([FirestoreAttachment]) -> [Attachment] = { attachments in
                            attachments.compactMap {
                                if let thumbURL = URL(string: $0.thumbURL), let url = URL(string: $0.url) {
                                    return Attachment(id: UUID().uuidString, thumbnail: thumbURL, full: url, type: $0.type)
                                }
                                return nil
                            }
                        }
                        
                        var replyMessage: ReplyMessage?
                        if let reply = fmessage.replyMessage,
                           let replyId = reply.id,
                           let replyUser = self.allUsers.first(where: { $0.id == reply.userId })
                        {
                            if let imageUrl = replyUser.imageUrl {
                                replyMessage = ReplyMessage(
                                    id: replyId,
                                    user: ExyteChat.User(id: replyUser.id, name: replyUser.fullname, avatarURL: URL(string: imageUrl), isCurrentUser: false),
                                    text: reply.text)
                            } else {
                                replyMessage = ReplyMessage(
                                    id: replyId,
                                    user: ExyteChat.User(id: replyUser.id, name: replyUser.fullname, avatarURL: nil, isCurrentUser: false),
                                    text: reply.text)
                            }
                        }
                        
                        return Message(
                            id: messageId,
                            user: user.asExyteUser(),
                            status: .sent,
                            createdAt: date,
                            text: fmessage.text,
                            attachments: convertAttachments(fmessage.attachments),
                            replyMessage: replyMessage)
                    } ?? []
                self.lock.withLock {
                    let localMessages = self.messages
                        .filter { $0.status != .sent }
                        .filter { localMessage in
                            messages.firstIndex { message in
                                message.id == localMessage.id
                            } == nil
                        }
                        .sorted { $0.createdAt < $1.createdAt }
                    self.messages = messages + localMessages
                }
            }
    }
    
    private func conversationForUser(_ user: User) -> Conversation? {
        // check in case the other user sent a message while this user had the empty conversation open
        for conversation in MessageService.shared.conversations {
            if !conversation.isGroup, conversation.users.contains(user) {
                return conversation
            }
        }
        return nil
    }
    
    private func createIndividualConversation(_ user: User) async -> Conversation? {
        subscriptionToConversationCreation = nil
        let allUserIds = allUsers.map { $0.id }
        let dict: [String : Any] = [
            "users": allUserIds,
            //            "usersUnreadCountInfo": Dictionary(uniqueKeysWithValues: allUserIds.map { ($0, 0) } ),
            "isGroup": false,
            "title": user.fullname
        ]
        
        return await withCheckedContinuation { continuation in
            var ref: DocumentReference? = nil
            ref = Firestore.firestore()
                .collection("conversations")
                .addDocument(data: dict) { err in
                    if let id = ref?.documentID {
                        continuation.resume(returning: Conversation(id: id, users: self.allUsers, isGroup: false))
                    }
                }
        }
    }
    
    private func createConversation(_ users: [User]) async -> Conversation? {
        let allUserIds = allUsers.map { $0.id }
        let dict: [String : Any] = [
            "users": allUserIds,
            //            "usersUnreadCountInfo": Dictionary(uniqueKeysWithValues: allUserIds.map { ($0, 0) } ),
            "isGroup": true,
            //            "pictureURL": pictureURL?.absoluteString ?? "",
            "title": allUsers.map { $0.fullname }.joined(separator: " ")
        ]
        
        return await withCheckedContinuation { continuation in
            var ref: DocumentReference? = nil
            ref = Firestore.firestore()
                .collection("conversations")
                .addDocument(data: dict) { err in
                    if let id = ref?.documentID {
                        if let current = self.authViewModel.currentUser {
                            continuation.resume(returning: Conversation(id: id, users: self.allUsers, pictureURL: nil, title: self.allUsers.map { $0.fullname }.joined(separator: " "), isGroup: true))
                        }
                    }
                }
        }
    }
}
