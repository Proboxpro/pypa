//
//  AuthViewModel.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import Foundation
import PhotosUI
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage


protocol AuthenticationFormProtocol{
    var formIsValid: Bool {get}
}


@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
//    @Published var imageUrl: String?
    @Published var StatusMessage = ""
    @Published var orders: [ListingItem] = []
    @Published var myorder: [ListingItem] = []
    
    @Published var feedback: [Feedback] = []
    @Published var order: Order?
//    @Published var user: [User] = []
    @Published var users: [User] = []
    @Published var allPosibleCityes: [City] = []
    
    @Published var orderDescription: [OrderDescriptionItem] = []
    @Published var ownerOrderDescription: [OrderDescriptionItem] = []
    @Published var recipientOrderDescription: [OrderDescriptionItem] = []
    
//    @Publisher var currentCity: City?
//    @Published var destinationSearchViewModel = DestinationSearchViewModel(

    
    @Published var profile: ListingItem?
//    @Published var sumSubApproved = false
    
    
    //    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    
    
    static let shared = AuthViewModel()
    private let storage = Storage.storage().reference()
    let db = Firestore.firestore()
    let messagesCollection = Firestore.firestore().collection("order")
    
    // MARK: - Alert state
    struct AuthAlert: Identifiable, Equatable {
        enum Kind { case info, success, warning, error }
        let id = UUID()
        var kind: Kind
        var title: String
        var message: String
    }
    @Published var activeAlert: AuthAlert?
    @Published var isAlertPresented: Bool = false
    @Published var showExitFromAccAlert: Bool = false
    
    @Published var showErrorDepartureAlert: Bool = false

    func presentAlert(kind: AuthAlert.Kind = .info, title: String? = nil, message: String) {
        let defaultTitle: String
        switch kind {
        case .info: defaultTitle = "Сообщение"
        case .success: defaultTitle = "Успешно"
        case .warning: defaultTitle = "Внимание"
        case .error: defaultTitle = "Ошибка"
        }
        activeAlert = AuthAlert(kind: kind, title: title ?? defaultTitle, message: message)
        isAlertPresented = true
    }

    func dismissAlert() {
        isAlertPresented = false
        activeAlert = nil
    }

    
    init() {
        
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchOrder()
        }
        usersearch()
        citysearch()
        myOrder()
        self.order = order
        
        Task {
            await fetchUser()
        }
    }
    func signIn (withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            
        } catch {
            self.presentAlert(kind: .error, title: "Ошибка", message: error.localizedDescription)
            
        }
    }
    
    func createUser(withEmail email:String, password: String, fullname: String, login: String, imageUrl: String, number: String) async throws{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User (id: result.user.uid, fullname: fullname, login: login, email: email, imageUrl: imageUrl, number: number)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            
            
        } catch {
            self.presentAlert(kind: .error, title: "Ошибка", message: error.localizedDescription)
        }
        
    }
    func signOut() {
        do{
            try Auth.auth().signOut() //выходбек
            self.userSession = nil
            self.currentUser = nil
            self.sumSubResetApprove()
        } catch {
            self.presentAlert(kind: .error, title: "Ошибка", message: error.localizedDescription)
//            print("bags \(error.localizedDescription)")
        }
    }
    func fetchUser () async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func fetchUser(by id: String) async -> User? {
        guard id != "" else { return nil }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(id).getDocument()
        else { return nil }
        //        guard let user = try? snapshot.data(as: User.self) else { return nil }
        let dict = snapshot.data()
        let fullname = dict?["fullname"] as? String ?? ""
        let login = dict?["login"] as? String ?? ""
        let email = dict?["email"] as? String ?? ""
        let number = dict?["number"] as? String ?? ""
        
        let profileImageUrlString = dict?["imageUrl"] as? String
        let uid = dict?["id"] as? String
        return User(id: uid ?? "", fullname: fullname, login: login, email: email, imageUrl: profileImageUrlString, number: number)
    }
    
    func fetchUser(by login: String, completion: @escaping (User?) -> Void) {
        guard !login.isEmpty else {
            completion(nil)
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .whereField( "login", isEqualTo: login)
            .limit(to: 1)
            .getDocuments() { snapshot, error in
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion(nil)
                    return
                }
                let data = documents[0].data()
                let fullname = data["fullname"] as? String ?? ""
                let loginValue = data["login"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let number = data["number"] as? String ?? ""
                let profileImageUrlString = data["imageUrl"] as? String
                let uid = data["id"] as? String ?? documents[0].documentID
                let user = User(id: uid, fullname: fullname, login: loginValue, email: email, imageUrl: profileImageUrlString, number: number)
                completion(user)
                        }
            }
        
    
    
    
    //MARK: fetch user to show
    func fetchUserToShow(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        let userRef = db.collection("users").document(id)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error)) // Если произошла ошибка, вызываем замыкание с ошибкой
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "DocumentNotFound", code: 404, userInfo: nil)
                completion(.failure(error)) // Если документ не найден, вызываем замыкание с ошибкой
                return
            }
            
            guard let data = document.data() else {
                let error = NSError(domain: "DocumentDataError", code: 500, userInfo: nil)
                completion(.failure(error)) // Если данные не найдены, вызываем замыкание с ошибкой
                return
            }
            
            let fullname = data["fullname"] as? String ?? ""
            let id = data["id"] as? String ?? ""
            let login = data["login"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrlString = data["imageUrl"] as? String
            let uid = data["id"] as? String
            let number = data["number"] as? String ?? ""
            
            let user = User(id: uid ?? "", fullname: fullname, login: login, email: email, imageUrl: profileImageUrlString, number: number)
            
            completion(.success(user)) // Вызываем замыкание с объектом User в качестве успешного результата
        }
    }
    
    
    func usersearch(){
        users.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection( "users")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"]as? String ?? ""
                    let fullname = data["fullname"]as? String ?? ""
                    let login = data["login"]as? String ?? ""
                    let email = data["email"]as? String ?? ""
                    let imageUrl = data["imageUrl"]as? String ?? ""
                    let number = data["number"] as? String ?? ""
                    
                    let user = User(id: id, fullname: fullname, login: login, email: email, imageUrl: imageUrl, number: number)
                    
                    self.users.append(user)
                }
            }
        }
    }
    
    func citysearch(){
        let db = Firestore.firestore()
        let ref = db.collection( "city")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"]as? String ?? ""
                    let name = data["name"]as? String ?? ""
                    let reg = data["reg"]as? String ?? ""
                    let city = City(id: id, name: name, reg: reg)
                    
                    self.allPosibleCityes.append(city)
                }
            }
        }
    }
    
    
    // MARK: ЗАКАЗЫ
    func fetchOrder() async {
        orders.removeAll()
        do {
            let db = Firestore.firestore()
            let ref = db.collection("Customers")
            let snapshot = try await ref.getDocuments()
            for document in snapshot.documents {
                let data = document.data()
                let id = data["id"] as? String ?? ""
                let ownerUid = data["ownerUid"] as? String ?? ""
                let ownerName = data["ownerName"] as? String ?? ""
                let imageUrl = data["imageUrl"] as? String ?? ""
                let pricePerKillo = data["pricePerKillo"] as? Double ?? 0
                let cityFrom = data["cityFrom"] as? String ?? ""
                let cityTo = data["cityTo"] as? String ?? ""
                let imageUrls = data["imageUrls"] as? String ?? ""
                let startdate = data["startdate"] as? String ?? ""
                let description = data["descrtiption"] as? String ?? ""
                let order = ListingItem(id: id, ownerUid: ownerUid, ownerName: ownerName, imageUrl: imageUrl, pricePerKillo: pricePerKillo, cityFrom: cityFrom, cityTo: cityTo, imageUrls: imageUrls, description: description, startdate: startdate)
                orders.append(order)
            }
        } catch {
            self.presentAlert(kind: .error, title: "Error fetching orders", message: error.localizedDescription)
//            print("Error fetching orders: \(error.localizedDescription)")
        }
    }
    
    func fetchListingItem(by id: String) async -> ListingItem? {
        // Сначала проверяем, есть ли уже в загруженных orders
        if let existing = orders.first(where: { $0.id == id }) {
            return existing
        }
        
        // Если нет, загружаем из Firestore
        do {
            let db = Firestore.firestore()
            let ref = db.collection("Customers")
            let query = ref.whereField("id", isEqualTo: id).limit(to: 1)
            let snapshot = try await query.getDocuments()
            
            guard let document = snapshot.documents.first else { return nil }
            let data = document.data()
            
            let itemId = data["id"] as? String ?? ""
            let ownerUid = data["ownerUid"] as? String ?? ""
            let ownerName = data["ownerName"] as? String ?? ""
            let imageUrl = data["imageUrl"] as? String ?? ""
            let pricePerKillo = data["pricePerKillo"] as? Double ?? 0
            let cityFrom = data["cityFrom"] as? String ?? ""
            let cityTo = data["cityTo"] as? String ?? ""
            let imageUrls = data["imageUrls"] as? String ?? ""
            let startdate = data["startdate"] as? String ?? ""
            let description = data["descrtiption"] as? String ?? ""
            let conversation = data["conversation"] as? FirestoreConversation
            
            return ListingItem(
                id: itemId,
                ownerUid: ownerUid,
                ownerName: ownerName,
                imageUrl: imageUrl,
                pricePerKillo: pricePerKillo,
                cityFrom: cityFrom,
                cityTo: cityTo,
                imageUrls: imageUrls,
                description: description,
                startdate: startdate,
                conversation: conversation
            )
        } catch {
            return nil
        }
    }
    
    func deleteOrder(id:String)  {
        let db = Firestore.firestore()
        db.collection ("Customers").whereField("id", isEqualTo: id).getDocuments{(snap,
            err) in
            if
                err != nil {
                print ("Error")
                return
            }
            for i in snap!.documents {
                DispatchQueue.main.async {
                    i.reference.delete()
                }
            }
        }
        
    }
    
    func myOrder(){
        myorder.removeAll()
        //MARK: - Debug
//        guard let uid = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore()
        let ref = db.collection( "Customers")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"]as? String ?? ""
                    let ownerUid = data["ownerUid"]as? String ?? ""
                    let ownerName = data["ownerName"]as? String ?? ""
                    let imageUrl = data["imageUrl"]as? String ?? ""
                    let pricePerKillo = data["pricePerKillo"]as? Double ?? 0
                    let cityFrom = data["cityFrom"]as? String ?? ""
                    let cityTo = data["cityTo"]as? String ?? ""
                    let imageUrls = data[ "imageUrls"]as? String ?? ""
                    let startdate = data[ "startdate"]as? String ?? ""
                    let description = data["descrtiption"] as? String ?? ""
                    let conversation = data["conversation"] as? FirestoreConversation
                    var myorder = ListingItem(id: id, ownerUid: ownerUid, ownerName: ownerName, imageUrl: imageUrl, pricePerKillo: pricePerKillo,cityFrom: cityFrom, cityTo: cityTo, imageUrls: imageUrls, description: description, startdate: startdate, conversation: conversation)
                    print(cityFrom)
                    
                    //MARK: - Debug
//                    if ownerUid == uid {
//                        myorder.isAuthorized = true
//                    }
                    
                    if let startDate = startdate.toDate()  {
                        if startDate < Date() {
                            myorder.dateIsExpired = true
                        }
                    }
                    
                    self.myorder.append(myorder)
                }
            }
        }
        
    }
    
    func fetchOrderDescription(){
        orderDescription.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore()
        let ref = db.collection( "orderDescription")
        let infoRef = ref.document(uid).collection("information")
        fetchInnerCollection(ref: infoRef) { (documentId, announcementId, ownerId, recipientId,
                                              cityFrom, cityFromCoordinates, cityTo, cityToCoordinates, ownerName, creationTime,
                                              description, url, price,
                                              isSent, isPickedUp, isInDelivery, isDelivered,
                                              isCompleted, ownerDealStatus, recipientDealStatus, recipientDeadline) in
            var finalRecipientStatus = recipientDealStatus
            if recipientDealStatus == .pending, let deadline = recipientDeadline, Date() >= deadline {
                finalRecipientStatus = .expired
                Task {
                    try? await self.updateRecipientDealStatus(
                        status: .expired,
                        orderId: uid,
                        documentId: documentId
                    )
                }
            }
            
            let order = OrderDescriptionItem(id: uid,
                                             documentId: documentId,
                                             announcementId: announcementId,
                                             ownerId: ownerId,
                                             recipientId: recipientId,
                                             cityFromLat: cityFromCoordinates.coordinate.latitude,
                                             cityFromLon: cityFromCoordinates.coordinate.longitude,
                                             cityToLat: cityToCoordinates.coordinate.latitude,
                                             cityToLon: cityToCoordinates.coordinate.longitude,
                                             cityFrom: cityFrom,
                                             cityTo: cityTo,
                                             ownerName: ownerName,
                                             creationTime: creationTime,
                                             description: description,
                                             image: url,
                                             price: price,
                                             isSent: isSent,
                                             isPickedUp: isPickedUp,
                                             isInDelivery: isInDelivery,
                                             isDelivered: isDelivered,
                                             isCompleted: isCompleted,
                                             ownerDealStatus: ownerDealStatus,
                                             recipientDealStatus: finalRecipientStatus,
                                             recipientResponseDeadline: recipientDeadline)
            self.orderDescription.append(order)
        }
    }
    
    func fetchOrderDescriptionAsOwner(){
        ownerOrderDescription.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore()
        let ref = db.collection( "orderDescription")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"]as? String ?? ""
                    let infoRef = ref.document(id).collection("information")
                    self.fetchInnerCollection(ref: infoRef) { (documentId, announcementId, ownerId, recipientId,
                                                               cityFrom, cityFromCoordinates, cityTo, cityToCoordinates, ownerName, creationTime,
                                                               description, url, price,
                                                               isSent, isPickedUp, isInDelivery, isDelivered,
                                                               isCompleted, ownerDealStatus, recipientDealStatus, recipientDeadline) in
                        if ownerId == uid {
                            var finalRecipientStatus = recipientDealStatus
                            if recipientDealStatus == .pending, let deadline = recipientDeadline, Date() >= deadline {
                        
                                finalRecipientStatus = .expired
                                Task {
                                    try? await self.updateRecipientDealStatus(
                                        status: .expired,
                                        orderId: id,
                                        documentId: documentId
                                    )
                                }
                            }
                            
                            let order = OrderDescriptionItem(id: id,  // id из документа - это sender ID
                                                             documentId: documentId,
                                                             announcementId: announcementId,
                                                             ownerId: ownerId,
                                                             recipientId: recipientId,
                                                             cityFromLat: cityFromCoordinates.coordinate.latitude,
                                                             cityFromLon: cityFromCoordinates.coordinate.longitude,
                                                             cityToLat: cityToCoordinates.coordinate.latitude,
                                                             cityToLon: cityToCoordinates.coordinate.longitude,
                                                             cityFrom: cityFrom,
                                                             cityTo: cityTo,
                                                             ownerName: ownerName,
                                                             creationTime: creationTime,
                                                             description: description,
                                                             image: url,
                                                             price: price,
                                                             isSent: isSent,
                                                             isPickedUp: isPickedUp,
                                                             isInDelivery: isInDelivery,
                                                             isDelivered: isDelivered,
                                                             isCompleted: isCompleted,
                                                             ownerDealStatus: ownerDealStatus,
                                                             recipientDealStatus: finalRecipientStatus,
                                                             recipientResponseDeadline: recipientDeadline)
                            self.ownerOrderDescription.append(order)
                        }
                    }
                }
            }
        }
    }
    
    
    func fetchOrderDescriptionAsRecipient(){
        recipientOrderDescription.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let ref = db.collection("orderDescription")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? ""
                    let infoRef = ref.document(id).collection("information")
                    self.fetchInnerCollection(ref: infoRef) { (documentId, announcementId, ownerId, recipientId, 
                                                               cityFrom, cityFromCoordinates, cityTo, cityToCoordinates, ownerName, creationTime,
                                                               description, url, price,
                                                               isSent, isPickedUp, isInDelivery, isDelivered,
                                                               isCompleted, ownerDealStatus, recipientDealStatus, recipientDeadline) in
                        if recipientId == uid {
                         
                            var finalRecipientStatus = recipientDealStatus
                            if recipientDealStatus == .pending, let deadline = recipientDeadline, Date() >= deadline {
                               
                                finalRecipientStatus = .expired
                                Task {
                                    try? await self.updateRecipientDealStatus(
                                        status: .expired,
                                        orderId: id,
                                        documentId: documentId
                                    )
                                }
                            }
                            
                            let order = OrderDescriptionItem(id: id,  // id документа = senderId
                                                             documentId: documentId,
                                                             announcementId: announcementId,
                                                             ownerId: ownerId,
                                                             recipientId: recipientId,
                                                             cityFromLat: cityFromCoordinates.coordinate.latitude,
                                                             cityFromLon: cityFromCoordinates.coordinate.longitude,
                                                             cityToLat: cityToCoordinates.coordinate.latitude,
                                                             cityToLon: cityToCoordinates.coordinate.longitude,
                                                             cityFrom: cityFrom,
                                                             cityTo: cityTo,
                                                             ownerName: ownerName,
                                                             creationTime: creationTime,
                                                             description: description,
                                                             image: url,
                                                             price: price,
                                                             isSent: isSent,
                                                             isPickedUp: isPickedUp,
                                                             isInDelivery: isInDelivery,
                                                             isDelivered: isDelivered,
                                                             isCompleted: isCompleted,
                                                             ownerDealStatus: ownerDealStatus,
                                                             recipientDealStatus: finalRecipientStatus,
                                                             recipientResponseDeadline: recipientDeadline)
                            DispatchQueue.main.async {
                                self.recipientOrderDescription.append(order)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func fetchInnerCollection(ref: CollectionReference, completion: @escaping ((String, String, String, String, 
                                                                                        String, CLLocation, String, CLLocation, String, Date,
                                                                                        String, URL?, Int,
                                                                                        Bool, Bool, Bool, Bool,
                                                                                        Bool, OwnerDealStatus, RecipientDealStatus, Date?) -> Void)) {
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let announcementId = data["announcementId"]as? String ?? ""
                    let ownerId = data["ownerId"]as? String ?? ""
                    let recipientId = data["recipientId"]as? String ?? ""
                    
                    let cityFrom = data["cityFrom"]as? String ?? ""
                    let cityFromLat = data["cityFromLat"]as? Double ?? 0
                    let cityFromLon = data["cityFromLon"]as? Double ?? 0
                    let cityFromCoordinates = CLLocation(latitude: cityFromLat, longitude: cityFromLon)
                    let cityTo = data["cityTo"]as? String ?? ""
                    let cityToLat = data["cityToLat"]as? Double ?? 0
                    let cityToLon = data["cityToLon"]as? Double ?? 0
                    let cityToCoordinates = CLLocation(latitude: cityToLat, longitude: cityToLon)
                    let ownerName = data["ownerName"]as? String ?? ""
                    let timestampTime = data["creationTime"]as? Timestamp ?? Timestamp()
            let creationTime = timestampTime.dateValue()
            
            let description = data["description"]as? String ?? ""
            let image = data["image"]as? String ?? ""
            let url = URL(string: image)
            let price = data["price"]as? Int ?? 0
            
            let isSent = data["isSent"]as? Bool ?? false
            let isPickedUp = data["isPickedUp"]as? Bool ?? false
            let isInDelivery = data["isInDelivery"]as? Bool ?? false
            let isDelivered = data["isDelivered"]as? Bool ?? false
            
            let isCompleted = data["isCompleted"]as? Bool ?? false
            
            let ownerDealStatusString = data["ownerDealStatus"] as? String ?? "pending"
            let ownerDealStatus = OwnerDealStatus(rawValue: ownerDealStatusString) ?? .pending
            
            let recipientDealStatusString = data["recipientDealStatus"] as? String ?? "pending"
            let recipientDealStatus = RecipientDealStatus(rawValue: recipientDealStatusString) ?? .pending
            
            var recipientDeadline: Date? = nil
            if let deadlineTimestamp = data["recipientResponseDeadline"] as? Timestamp {
                recipientDeadline = deadlineTimestamp.dateValue()
            }
            
            completion(document.documentID, announcementId, ownerId, recipientId, 
                       cityFrom, cityFromCoordinates, cityTo, cityToCoordinates, ownerName, creationTime,
                       description, url, price,
                       isSent, isPickedUp, isInDelivery, isDelivered,
                       isCompleted, ownerDealStatus, recipientDealStatus, recipientDeadline)
                }
            }
        }
    }
    
    
    func filteredOnParam(_ searchParameters: SearchParameters, searchBarIsEmpty: Bool) -> [ListingItem] {
        
        var filteredItems = [ListingItem]()
        
        if searchBarIsEmpty {
            return myorder
        }
        
        if searchParameters.datesIsSelected {
        //MARK: - показываем результа по датам и городу
            filteredItems  =    myorder.filter({$0.cityTo == searchParameters.cityName}).filter({$0.startdate.toDate()! >= searchParameters.startDate && $0.startdate.toDate()! <= searchParameters.endDate})
        } else if (searchParameters.cityName != "") {
            //MARK: - результат если даты не выбраны город есть
            filteredItems  =    myorder.filter({$0.cityTo == searchParameters.cityName})
        } 
//        else if(searchParameters.cityName == "" && searchParameters.datesIsSelected) {
//            //MARK: - когда выбраны даты но не выбран город
//            filteredItems = myorder.filter({$0.startdate.toDate()! > searchParameters.startDate && $0.startdate.toDate()! < searchParameters.endDate})
//        }
        else {
            //MARK: - результат если даты не выбраны и город не выбран
            filteredItems = myorder
        }
        
        return filteredItems
    }
    
    private func userReference(UserId:String) -> StorageReference{
        storage.child("user").child(UserId)
    }
    
    func saveImage (data: Data, UserId: String) async throws -> (name:String, path: String){
        let meta = StorageMetadata()
        
        meta.contentType = "image/jpeg"
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(UserId:UserId).child(path).putDataAsync(data, metadata: meta)
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError (.badServerResponse)
        }
        return (returnedName, returnedPath)
        
    }
    
    func saveConversationImage(data: Data) async throws -> URL? {
        try await Task { () -> URL? in
            guard let UserId = Auth.auth().currentUser?.uid else { return nil }
//            guard let data = try await item.loadTransferable(type: Data.self) else {return}
            let (path,name) = try await AuthViewModel.shared.saveImage(data: data, UserId: UserId)
            print ("SUCCESS!")
            print (path)
            print (name)
            do {
                let storageRef = Storage.storage().reference(withPath: (name))
                let url = try await storageRef.downloadURL()
                print (url)
                
                try await  Firestore.firestore().collection("users").document(UserId).updateData([
                    "imageUrl": url.absoluteString
                ])
                return url
            } catch {
                print("bags \(error.localizedDescription)")
                return nil
            }
        }.value
    }
    
    
    func saveProfileImage(item: Data) {
        guard let UserId = Auth.auth().currentUser?.uid else {return}
        Task {
//            guard let data = try await item.loadTransferable(type: Data.self) else {return}
            let (path,name) = try await AuthViewModel.shared.saveImage (data: item, UserId: UserId)
            print ("SUCCESS!")
            print (path)
            print (name)
            do {
                let storageRef = Storage.storage().reference(withPath: (name))
                let url = try await storageRef.downloadURL()
                print (url)
                
                try await  Firestore.firestore().collection("users").document(UserId).updateData([
                    "imageUrl": url.absoluteString
                ])
                await self.fetchUser()
                
            } catch {
                print("bags \(error.localizedDescription)")
                
            }
        }
    }
    
    func saveImage (image: UIImage, UserId: String) async throws -> (name:String, path: String){
        guard let data = image.jpegData (compressionQuality: 1) else {
            throw URLError (.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage (data:data, UserId: UserId)
    }
    
    func getData (UserId: String, path: String) async throws -> Data {
        try await userReference (UserId: UserId).child(path).data (maxSize: 3 * 1024 * 1024)
        
    }
    
    // MAKR Post Feedback
    func uploadFeedback() async{
        
    }
    
    func getFeedback() {
        guard (Auth.auth().currentUser?.uid) != nil else {return}
        feedback.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection( "feedback")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"]as? String ?? ""
                    let UserLogin = data["UserLogin"]as? String ?? ""
                    let text = data["text"]as? String ?? ""
                    let rating = data["rating"]as? String ?? ""
                    let imageUrl = data["imageUrl"]as? String ?? ""
                    let imageUrls = data["imageUrls"]as? String ?? ""
                    let feedback = Feedback(id: id, UserLogin: UserLogin, text: text, rating: rating, imageUrl: imageUrl, imageUrls: imageUrls)
                    
                    self.feedback.append(feedback)
                }
            }
        }
    }
    
    //MARK: Create order
    private func orderReference(UserId:String) -> StorageReference{
        storage.child("order").child(UserId)
    }
    
    func saveOrderImage (data: Data, UserId: String) async throws -> (name:String, path: String){
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await orderReference(UserId:UserId).child(path).putDataAsync(data, metadata: meta)
        guard let returnedPath = returnedMetaData.path,
              let returnedName = returnedMetaData.name
        else {
            throw URLError (.badServerResponse)
        }
        return (returnedName, returnedPath)
        
    }
    
    func saveOrderImage(data: Data) async throws -> URL? {
        try await Task { () -> URL? in
            guard let UserId = Auth.auth().currentUser?.uid else { return nil }
            let (path,name) = try await AuthViewModel.shared.saveOrderImage (data: data, UserId: UserId)
            print ("SUCCESS!")
            print (path)
            print (name)
            do {
                let storageRef = Storage.storage().reference(withPath: (name))
                let url = try await storageRef.downloadURL()
                print (url)
                try await  Firestore.firestore().collection("orderimg").document(UserId).setData([
                    "orderimageUrl": url.absoluteString,
                    "UserId": UserId
                ])
                return url
            } catch {
                print("bags \(error.localizedDescription)")
                return nil
            }
        }.value
    }
    
    func saveOrder(ownerId: String, recipientId: String, announcementId: String, 
                   cityFrom: String, cityTo: String, ownerName: String,
                   imageData: Data, description: String, price: Int) async throws -> OrderDescriptionItem? {
        guard let UserId = Auth.auth().currentUser?.uid else { return nil }
        
        do {
            let url: URL? = imageData.isEmpty ? nil : try await getImageUrl(imageData: imageData)
            
            let doc = Firestore.firestore()
                .collection("orderDescription")
                .document(UserId)
            let document = try await doc.getDocument()
            let infoDoc = Firestore.firestore()
                .collection("orderDescription")
                .document(UserId)
                .collection("information")
                .document()
            
            var cityFromCoordinates: [CLPlacemark]
            do {
                cityFromCoordinates = try await CLGeocoder().geocodeAddressString(cityFrom)
            } catch {
                cityFromCoordinates = []
            }
            
            var cityToCoordinates: [CLPlacemark]
            do {
                cityToCoordinates = try await CLGeocoder().geocodeAddressString(cityTo)
            } catch {
                cityToCoordinates = []
            }
            
            let cityFromLat = cityFromCoordinates.first?.location?.coordinate.latitude ?? 0.0
            let cityFromLon = cityFromCoordinates.first?.location?.coordinate.longitude ?? 0.0
            let cityToLat = cityToCoordinates.first?.location?.coordinate.latitude ?? 0.0
            let cityToLon = cityToCoordinates.first?.location?.coordinate.longitude ?? 0.0
            
            let creationTime = Date()
            let recipientDeadline = creationTime.addingTimeInterval(3600)
            
            let orderData: [String: Any] = [
                "ownerId": ownerId,
                "recipientId": recipientId,
                "announcementId": announcementId,
                "cityFrom": cityFrom,
                "cityFromLat": cityFromLat,
                "cityFromLon": cityFromLon,
                "cityTo": cityTo,
                "cityToLat": cityToLat,
                "cityToLon": cityToLon,
                "ownerName": ownerName,
                "creationTime": creationTime,
                "description": description,
                "image": url?.absoluteString ?? "",
                "price": price,
                "isSent": false,
                "isPickedUp": false,
                "isInDelivery": false,
                "isDelivered": false,
                "isCompleted": false,
                "ownerDealStatus": "pending",
                "recipientDealStatus": "pending",
                "recipientResponseDeadline": Timestamp(date: recipientDeadline)
            ]
            
            if document.exists {
                try await infoDoc.setData(orderData)
            } else {
                try await doc.setData([
                    "id": UserId
                ])
                try await infoDoc.setData(orderData)
            }
            
            let order = OrderDescriptionItem(
                id: UserId,
                documentId: infoDoc.documentID,
                announcementId: announcementId,
                ownerId: ownerId,
                recipientId: recipientId,
                cityFromLat: cityFromCoordinates.first?.location?.coordinate.latitude,
                cityFromLon: cityFromCoordinates.first?.location?.coordinate.longitude,
                cityToLat: cityToCoordinates.first?.location?.coordinate.latitude,
                cityToLon: cityToCoordinates.first?.location?.coordinate.longitude,
                cityFrom: cityFrom,
                cityTo: cityTo,
                ownerName: ownerName,
                creationTime: creationTime,
                description: description,
                image: url,
                price: price,
                isSent: false,
                isPickedUp: false,
                isInDelivery: false,
                isDelivered: false,
                isCompleted: false,
                ownerDealStatus: .pending,
                recipientDealStatus: .pending,
                recipientResponseDeadline: recipientDeadline)
            return order
        } catch {
            throw error
        }
    }
    
    func updateOrderStatus(type: OrderStatus, value: Bool, id: String, documentId: String) async throws {
        do {
            let infoDoc = Firestore.firestore()
                .collection("orderDescription")
                .document(id)
                .collection("information")
                .document(documentId)
            
            var updateData: [String: Any] = [:]
            
            switch type {
            case .isSent:
                updateData["isSent"] = value
            case .isPickedUp:
                updateData["isPickedUp"] = value
                if value {
                    updateData["pickedUpDate"] = Timestamp(date: Date())
                }
            case .isInDelivery:
                updateData["isInDelivery"] = value
            case .isDelivered:
                updateData["isDelivered"] = value
                if value {
                    updateData["deliveredDate"] = Timestamp(date: Date())
                }
            }
            
            try await infoDoc.updateData(updateData)
        } catch {
            print("bags \(error.localizedDescription)")
            return
        }
    }
    
    // MARK: - Deal Status Functions
    func updateOwnerDealStatus(status: OwnerDealStatus, orderId: String, documentId: String) async throws {
        do {
            let infoDoc = Firestore.firestore()
                .collection("orderDescription")
                .document(orderId)
                .collection("information")
                .document(documentId)

            var updateData: [String: Any] = ["ownerDealStatus": status.rawValue]

            if status != .pending {
                updateData["ownerResponseDate"] = Timestamp(date: Date())
            }
            try await infoDoc.updateData(updateData)
        } catch {
            print("Ошибка обновления статуса owner: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateRecipientDealStatus(status: RecipientDealStatus, orderId: String, documentId: String) async throws {
        do {
            let infoDoc = Firestore.firestore()
                .collection("orderDescription")
                .document(orderId)
                .collection("information")
                .document(documentId)

            var updateData: [String: Any] = ["recipientDealStatus": status.rawValue]

            if status != .pending {
                updateData["recipientResponseDate"] = Timestamp(date: Date())
            }

            // Если статус expired, также обновляем ownerDealStatus на declined (так как сделка не состоялась)
            if status == .expired || status == .declined {
                updateData["ownerDealStatus"] = "declined"
            }

            try await infoDoc.updateData(updateData)
        } catch {
            print("Ошибка обновления статуса recipient: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getImageUrl(imageData: Data) async throws -> URL? {
        guard let UserId = Auth.auth().currentUser?.uid else { return nil }
        guard imageData != Data() else { return nil }
        let (path, name) = try await AuthViewModel.shared.saveOrderImage (data: imageData, UserId: UserId)
        do {
            let storageRef = Storage.storage().reference(withPath: (name))
            let url = try await storageRef.downloadURL()
            return url
        } catch {
            print("bags \(error.localizedDescription)")
            return nil
        }
    }
    
    func createOrder(senderName: String, senderUid: String,ownerUid: String,  ownerName: String, description: String, value: String, cityFrom: String, cityTo: String, imageUrls: String, recipient: String, ownerImageUrl: String,text: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        do{
            let order = Order (senderName: senderName, ownerName: ownerName, senderUid: senderUid, ownerUid: ownerUid, description:description, value:value, cityFrom: cityFrom,  cityTo:cityTo, imageUrls: imageUrls, recipient: recipient, ownerImageUrl: ownerImageUrl, timestamp: Timestamp())
            let encodedUser = try Firestore.Encoder().encode(order)
            try await Firestore.firestore().collection("order").document(uid).setData(encodedUser)
            await fetchP2Porder()
        } catch {
            self.presentAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }
    
    func fetchP2Porder () async{
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let snapshot = try? await Firestore.firestore().collection("order").document(uid).getDocument() else {return}
        self.order = try? snapshot.data(as: Order.self)
    }
    
    
    // Add a message in Firestore
    func createNewOrder(senderName: String, senderUid: String,ownerUid: String,  ownerName: String, description: String, value: String, cityFrom: String, cityTo: String, imageUrls: String, recipient: String, ownerImageUrl: String,text: String) {
        
        let orderCollection = Firestore.firestore().collection("order")
        guard (Auth.auth().currentUser?.uid) != nil else {return}
        
        let currentUserRef = orderCollection.document(ownerUid).collection(senderUid).document()
        let chatPartnerRef = orderCollection.document(senderUid).collection(ownerUid)
        let orderId = currentUserRef.documentID
        let neworder = Order(senderName: senderName, ownerName: ownerName, senderUid: senderUid, ownerUid: ownerUid, description:description, value:value, cityFrom: cityFrom,  cityTo:cityTo, imageUrls: imageUrls, recipient: recipient, ownerImageUrl: ownerImageUrl, timestamp: Timestamp())
        guard let messageData = try? Firestore.Encoder().encode(neworder) else {return}
        
        currentUserRef.setData((messageData))
        chatPartnerRef.document(orderId).setData(messageData)
    }
    
    func observeOrder(chatPartner: User, completion: @escaping ([Order]) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        _ = chatPartner.id
        let query = messagesCollection
            .document(uid)
            .collection(uid)
            .order (by: "timestamp", descending: false)
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added}) else {return}
            let order = changes.compactMap({ try? $0.document.data(as: Order.self) })
            for (_, order) in order.enumerated() where order.ownerUid != uid {
            }
            completion(order)
        }
    }
    
    
    //MARK: - UserDefaults
    func checkIsApproved()->Bool {
        let sumSubApproved = UserDefaults.standard.bool(forKey: "sumSubApproved")
        
        //MARK: RELEASE
//        return sumSubApproved ? true : false
        //MARK: DEBUG
        return true
    }
    
    func sumSubApprove() {
        UserDefaults.standard.set(true, forKey: "sumSubApproved")
    }
    
    func sumSubResetApprove() {
        UserDefaults.standard.set(false, forKey: "sumSubApproved")
    }
    
    //MARK: - OrderStatus handling message screen
    @Published var orderStatus: OrderStatus = .isInDelivery
    
    
    //MARK: - DeparturesView:
    func uploadPostservice(cityTo: String, cityFrom: String,/*data: City,*/ startdate: Date, pricePerKillo: Double, transport: String, description: String) async
    {
        guard let uid = currentUser?.id else {return}
        let ownerUid = uid
        let ownerName = currentUser?.login
        let imageUrl = currentUser?.imageUrl
        
        
//        let db = Firestore.firestore()
//        db.collection("Customers").document().setData([ "id": NSUUID().uuidString,  "ownerUid": ownerUid, "ownerName": ownerName ?? "-", "pricePerKillo": pricePerKillo, "cityFrom": data.name, "cityTo": cityTo, "startdate":startdate.convertToMonthYearFormat(), "imageUrls": data.reg, "imageUrl": imageUrl ?? "-"]) {error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }
        guard let city = allPosibleCityes.filter({$0.name == cityFrom}).first else { return }
        
        await addCustomer(ownerUid: ownerUid, ownerName: ownerName, pricePerKillo: pricePerKillo, data: city, cityTo: cityTo, startdate: startdate, imageUrl: imageUrl, transport: transport, description: description)
    }
    
    func addCustomer(
        ownerUid: String,
        ownerName: String?,
        pricePerKillo: Double,
        data: City, // замени на свою структуру
        cityTo: String,
        startdate: Date,
        imageUrl: String?,
        transport: String,
        description: String
    ) async {
        let db = Firestore.firestore()
        let doc = db.collection("Customers").document()
        
        do {
            try await doc.setData([
                "id": UUID().uuidString,
                "ownerUid": ownerUid,
                "ownerName": ownerName ?? "-",
                "pricePerKillo": pricePerKillo,
                "cityFrom": data.name,
                "cityTo": cityTo,
                "startdate": startdate.convertToMonthYearFormat(),
                "imageUrls": data.reg,
                "imageUrl": imageUrl ?? "-",
                "transport": transport,
                "descrtiption": description
            ])
            presentAlert(kind: .success, message: "✅ Обьявление успешно создано!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.isAlertPresented = false
            })
                                          
        } catch {
            presentAlert(kind: .error, message: "❌ Firestore error: \(error.localizedDescription)")
        }
    }
    
    func getUserFrom(id: String) -> User! {
        self.users.filter({$0.id == id}).first
    }
    
    func getUserImageURLFrom(id: String) -> URL!  {
        guard let user = getUserFrom(id: id) else { return nil }
        guard let stringURL = user.imageUrl else { return nil }
        return URL(string: stringURL)
    }
}

