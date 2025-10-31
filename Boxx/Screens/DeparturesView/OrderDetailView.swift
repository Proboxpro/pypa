//
//  DealDetailsView.swift
//  Boxx
//
//  Created on 2025.
//

import SwiftUI
import Nuke
import NukeUI
import PhotosUI
import FirebaseFirestore
import ExyteChat

struct OrderDetailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let orderItem: OrderDescriptionItem
    let listingItem: ListingItem
    var onDismiss: (() -> Void)? = nil
    
    @State private var owner: User?
    @State private var recipient: User?
    @State private var conversation: Conversation?
    @State private var chatViewModel: ChatViewModel?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var isLoadingImage: Bool = false
    @State private var orderStatusListener: ListenerRegistration?
    @State private var currentOrderItem: OrderDescriptionItem
    
    @StateObject private var orderViewModel: OrderViewModel
    
    private var currentUserId: String {
        viewModel.currentUser?.id ?? ""
    }
    
    var isSender: Bool {
        currentUserId == orderItem.id  // ← Сравнивать с id, а не recipientId!
    }

    var isOwner: Bool {
        currentUserId == orderItem.ownerId
    }

    var isRecipient: Bool {
        currentUserId == orderItem.recipientId
    }
    
    init(orderItem: OrderDescriptionItem, listingItem: ListingItem, onDismiss: (() -> Void)? = nil) {
        self.orderItem = orderItem
        self.listingItem = listingItem
        self.onDismiss = onDismiss
        _currentOrderItem = State(initialValue: orderItem)
        _orderViewModel = StateObject(wrappedValue: OrderViewModel(authViewModel: AuthViewModel.shared))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .bottomLeading) {
                    // Верхняя секция с изображением города
                    backgroundImage
                        .frame(width: SizeConstants.screenWidth, height: SizeConstants.avatarHeight)
                        .clipped()
                        .overlay {
                            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                .cornerRadius(12)
                        }
                        .overlay {
                            HStack {
                                Button(action: {
                                    if let onDismiss = onDismiss {
                                        onDismiss()
                                    } else {
                                        dismiss()
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "chevron.left")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            .offset(y: -60)
                        }
                    
                    // HStack с ценой и маршрутом
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if let price = currentOrderItem.price {
                                Text("\(price) ₽")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(16)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(currentOrderItem.cityFrom) - \(currentOrderItem.cityTo)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(16)
                        }
                    }
                }
                
                // Секция с кнопкой чата
                if let owner = owner {
                    chatSection(owner: owner)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                
                // Секция "Отдайте посылку" - только для sender, когда посылка еще не отправлена
                if isSender && !isOwner && !currentOrderItem.isSent {
                    // Отправитель должен загрузить фото посылки
                    sendParcelSection
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                
                // Кнопка подтверждения для owner - только после того, как sender отправил фото
                if isOwner && !isSender && currentOrderItem.isSent && !currentOrderItem.isInDelivery {
                    // Путешественник подтверждает, что забрал посылку
                    confirmPickedUpButton
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                
                // Кнопка подтверждения для recipient
                if isRecipient && !isSender && !isOwner && currentOrderItem.isSent && currentOrderItem.isInDelivery && !currentOrderItem.isDelivered {
                    // Получатель подтверждает получение посылки
                    confirmDeliveredButton
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                
                // Бар статусов
                if currentOrderItem.isSent {
                    statusBarSection
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                
                Spacer(minLength: 100)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await loadUsers()
                setupStatusListener()
            }
        }
        .onDisappear {
            orderStatusListener?.remove()
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photosPickerItem, matching: .images)
        .onChange(of: photosPickerItem) { oldValue, newValue in
            Task {
                await handleImageSelection(newValue)
            }
        }
    }
    
    // MARK: - Chat Section
    @ViewBuilder
    private func chatSection(owner: User) -> some View {
        HStack(spacing: 16) {
            // Аватар owner
            AsyncImage(url: URL(string: owner.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(owner.fullname)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                if let recipient = recipient {
                    Text(recipient.fullname)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Кнопка чата
            Button {
                openChat()
            } label: {
                Image(systemName: "message.fill")
                    .foregroundStyle(.black)
                    .frame(width: 32, height: 32)
                    .background {
                        Circle()
                            .fill(.white)
                    }
            }
            .sheet(item: $chatViewModel, onDismiss: {
                orderViewModel.fetchData()
            }) { chatViewModel in
                NavigationView {
                    ChatViewContainer()
                        .environmentObject(chatViewModel)
                        .navigationTitle("Чат")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(false)
                }
            }
        }
        .padding(16)
        .background(
            Image("backInfo")
                .resizable()
                .cornerRadius(16)
        )
    }
    
    // MARK: - Send Parcel Section
    private var sendParcelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let owner = owner {
                Text("Отдайте посылку \(owner.fullname) и сделайте фото")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }
            
            Button {
                showImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20))
                    Text("Сделать фото")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.baseMint)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .disabled(isLoadingImage)
            
            if isLoadingImage {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 5)
    }
    
    // MARK: - Confirm Buttons
    private var confirmPickedUpButton: some View {
        Button {
            Task {
                await confirmPickedUp()
            }
        } label: {
            Text("Подтвердить, что забрал посылку")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.baseMint)
                .cornerRadius(12)
        }
        .shadow(radius: 8, y: 5)
    }
    
    private var confirmDeliveredButton: some View {
        Button {
            Task {
                await confirmDelivered()
            }
        } label: {
            Text("Подтвердить получение")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.baseMint)
                .cornerRadius(12)
        }
        .shadow(radius: 8, y: 5)
    }
    
    // MARK: - Status Bar Section
    private var statusBarSection: some View {
        VStack(spacing: 24) {
            ZStack {
                HStack {
                    Spacer()
                    // Линия между "Забрал" и "Доставка" - зеленая когда owner подтвердил (isInDelivery)
                    Rectangle()
                        .foregroundColor(currentOrderItem.isInDelivery ? .green : .gray)
                        .frame(width: 128, height: 2)
                        .padding(.bottom, 36)
                    // Линия между "Доставка" и "Получено" - зеленая когда recipient подтвердил (isDelivered)
                    Rectangle()
                        .foregroundColor(currentOrderItem.isDelivered ? .green : .gray)
                        .frame(width: 128, height: 2)
                        .padding(.bottom, 36)
                    Spacer()
                }
                
                HStack {
                    // Забрал - подсвечивается только после подтверждения owner (isInDelivery), а не после отправки фото
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(currentOrderItem.isInDelivery ? .green : .gray)
                            }
                        Text("Забрал")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    
                    // Доставка (isInDelivery) - подсвечивается когда owner подтвердил
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(currentOrderItem.isInDelivery ? .green : .gray)
                            }
                        Text("Доставка")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    
                    // Получено (isDelivered)
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(currentOrderItem.isDelivered ? .green : .gray)
                            }
                        Text("Получено")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 5)
    }
    
    // MARK: - Background Image
    private var backgroundImage: some View {
        let urlString = listingItem.imageUrl.isEmpty ? listingItem.imageUrls : listingItem.imageUrl
        
        return LazyImage(request: ImageRequest(
            url: URL(string: urlString),
            processors: [
                ImageProcessors.Resize(
                    size: CGSize(width: 240, height: 170),
                    contentMode: .aspectFill
                )
            ]
        )) { state in
            if let image = state.image {
                image.resizable().scaledToFill()
            } else if state.error != nil {
                Color.gray.opacity(0.3)
            } else {
                Color.gray.opacity(0.2)
            }
        }
    }
    
    // MARK: - Methods
    private func loadUsers() async {
        owner = await viewModel.fetchUser(by: orderItem.ownerId)
        recipient = await viewModel.fetchUser(by: orderItem.recipientId)
    }
    
    private func openChat() {
        print("🔵 [openChat] Начало открытия чата")
        Task { @MainActor in
            guard let currentUser = viewModel.currentUser else {
                print("❌ [openChat] currentUser is nil")
                return
            }
            print("✅ [openChat] currentUser: \(currentUser.id) - \(currentUser.fullname)")
            print("📋 [openChat] orderItem.id (sender): \(orderItem.id)")
            print("📋 [openChat] orderItem.ownerId: \(orderItem.ownerId)")
            print("📋 [openChat] orderItem.recipientId: \(orderItem.recipientId)")
            
            // Загружаем всех участников, если они еще не загружены
            if owner == nil {
                print("⏳ [openChat] Загружаем owner...")
                owner = await viewModel.fetchUser(by: orderItem.ownerId)
            }
            if recipient == nil {
                print("⏳ [openChat] Загружаем recipient...")
                recipient = await viewModel.fetchUser(by: orderItem.recipientId)
            }
            
            print("👤 [openChat] owner: \(owner?.id ?? "nil") - \(owner?.fullname ?? "nil")")
            print("👤 [openChat] recipient: \(recipient?.id ?? "nil") - \(recipient?.fullname ?? "nil")")
            
            // Создаем групповой чат между тремя участниками:
            // 1. owner (путешественник) - orderItem.ownerId
            // 2. recipient (получатель посылки) - orderItem.recipientId
            // 3. sender (отправитель, который создал сделку) - orderItem.id
            // ВСЕГДА должны быть все трое участников!
            var usersForChat: [User] = []
            var addedUserIds = Set<String>()
            
            // Сначала определяем всех трех участников - их ID
            let ownerId = orderItem.ownerId
            let recipientId = orderItem.recipientId
            let senderId = orderItem.id
            
            print("📋 [openChat] ID участников:")
            print("   - ownerId: \(ownerId)")
            print("   - recipientId: \(recipientId)")
            print("   - senderId: \(senderId)")
            
            // Загружаем owner
            if let ownerUser = owner {
                if !addedUserIds.contains(ownerUser.id) {
                    usersForChat.append(ownerUser)
                    addedUserIds.insert(ownerUser.id)
                    print("✅ [openChat] Добавлен owner: \(ownerUser.id) - \(ownerUser.fullname)")
                }
            } else {
                if let ownerUser = await viewModel.fetchUser(by: ownerId) {
                    await MainActor.run { self.owner = ownerUser }
                    if !addedUserIds.contains(ownerUser.id) {
                        usersForChat.append(ownerUser)
                        addedUserIds.insert(ownerUser.id)
                        print("✅ [openChat] Загружен и добавлен owner: \(ownerUser.id) - \(ownerUser.fullname)")
                    }
                } else {
                    print("❌ [openChat] Не удалось загрузить owner с ID: \(ownerId)")
                }
            }
            
            // Загружаем recipient
            if let recipientUser = recipient {
                if !addedUserIds.contains(recipientUser.id) {
                    usersForChat.append(recipientUser)
                    addedUserIds.insert(recipientUser.id)
                    print("✅ [openChat] Добавлен recipient: \(recipientUser.id) - \(recipientUser.fullname)")
                }
            } else {
                if let recipientUser = await viewModel.fetchUser(by: recipientId) {
                    await MainActor.run { self.recipient = recipientUser }
                    if !addedUserIds.contains(recipientUser.id) {
                        usersForChat.append(recipientUser)
                        addedUserIds.insert(recipientUser.id)
                        print("✅ [openChat] Загружен и добавлен recipient: \(recipientUser.id) - \(recipientUser.fullname)")
                    }
                } else {
                    print("❌ [openChat] Не удалось загрузить recipient с ID: \(recipientId)")
                }
            }
            
            // Загружаем sender - ВСЕГДА добавляем, даже если он может совпадать с owner
            // Но проверяем, чтобы не было дубликатов
            if !addedUserIds.contains(senderId) {
                if let sender = await viewModel.fetchUser(by: senderId) {
                    usersForChat.append(sender)
                    addedUserIds.insert(sender.id)
                    print("✅ [openChat] Добавлен sender: \(sender.id) - \(sender.fullname)")
                } else {
                    print("❌ [openChat] Не удалось загрузить sender с ID: \(senderId)")
                }
            } else {
                print("⚠️ [openChat] sender (id: \(senderId)) уже в списке (совпадает с owner или другим участником)")
            }
            
            print("👥 [openChat] Всего уникальных пользователей для чата: \(usersForChat.count)")
            usersForChat.forEach { user in
                print("   - \(user.id): \(user.fullname)")
            }
            
            // Проверяем, что у нас есть хотя бы 2 участника
            guard usersForChat.count >= 2 else {
                print("❌ [openChat] Недостаточно участников. Ожидалось минимум 2, найдено: \(usersForChat.count)")
                return
            }
            
            // Убеждаемся, что все три ID были проверены (даже если некоторые совпадают)
            print("✅ [openChat] Проверены все участники:")
            print("   - ownerId присутствует: \(addedUserIds.contains(ownerId))")
            print("   - recipientId присутствует: \(addedUserIds.contains(recipientId))")
            print("   - senderId присутствует: \(addedUserIds.contains(senderId))")
            
            // Сначала загружаем users и conversations
            print("⏳ [openChat] Загружаем данные через fetchData()...")
            await orderViewModel.fetchData()
            print("✅ [openChat] fetchData() завершен")
            print("📊 [openChat] MessageService.allUsers.count: \(MessageService.shared.allUsers.count)")
            print("📊 [openChat] MessageService.conversations.count: \(MessageService.shared.conversations.count)")
            
            // Убеждаемся, что все пользователи загружены в MessageService.allUsers
            // Это важно для правильного создания Conversation с полными данными пользователей
            for user in usersForChat {
                if !MessageService.shared.allUsers.contains(where: { $0.id == user.id }) {
                    print("⚠️ [openChat] Пользователь \(user.id) не найден в MessageService.allUsers, обновляем...")
                    // Если пользователь не в списке, ждем обновления
                    await MessageService.shared.getUsers()
                    break
                }
            }
            
            // Обновляем conversations еще раз после загрузки всех пользователей
            print("⏳ [openChat] Обновляем conversations...")
            await MessageService.shared.getConversations()
            print("✅ [openChat] Conversations обновлены: \(MessageService.shared.conversations.count)")
            
            // Очищаем предыдущие выбранные пользователи
            orderViewModel.selectedUsers = []
            
            // Выбираем пользователей для conversation (передаем уже загруженные User объекты)
            orderViewModel.selectedUsers = usersForChat
            print("✅ [openChat] selectedUsers установлен, количество: \(orderViewModel.selectedUsers.count)")
            
            // Ищем существующую conversation или создаем новую
            print("🔍 [openChat] Ищем существующую conversation...")
            var conversation = await orderViewModel.conversationForUsers()
            
            if conversation == nil {
                print("❌ [openChat] Conversation не найдена, создаем новую...")
                // Если conversation не существует, создаем новую групповую
                conversation = await orderViewModel.createConversation(usersForChat)
                
                if conversation != nil {
                    print("✅ [openChat] Новая conversation создана: \(conversation!.id)")
                } else {
                    print("❌ [openChat] Не удалось создать conversation")
                }
                
                // После создания обновляем список conversations, чтобы она была доступна
                await orderViewModel.fetchData()
                print("✅ [openChat] fetchData() после создания conversation завершен")
            } else {
                print("✅ [openChat] Найдена существующая conversation: \(conversation!.id)")
                print("   - users: \(conversation!.users.map { "\($0.id):\($0.fullname)" }.joined(separator: ", "))")
            }
            
            guard let conversation = conversation else {
                print("❌ [openChat] conversation все еще nil, пытаемся найти еще раз...")
                // Если conversation все еще nil, попробуем еще раз найти после обновления
                await orderViewModel.fetchData()
                let foundConversation = await orderViewModel.conversationForUsers()
                guard let conversation = foundConversation else {
                    print("❌ [openChat] conversation не найдена после повторного поиска. Выход.")
                    return
                }
                
                print("✅ [openChat] conversation найдена после повторного поиска: \(conversation.id)")
                self.conversation = conversation
                self.chatViewModel = ChatViewModel(auth: viewModel, conversation: conversation)
                print("✅ [openChat] chatViewModel установлен: \(self.chatViewModel?.id ?? "nil")")
                self.orderViewModel.selectedUsers = []
                return
            }
            
            // Создаем ChatViewModel и открываем чат
            // Так как мы уже на MainActor, можем напрямую установить значения
            print("🏗️ [openChat] Создаем ChatViewModel...")
            self.conversation = conversation
            // Создаем ChatViewModel с conversation, чтобы он правильно инициализировался
            let newChatViewModel = ChatViewModel(auth: viewModel, conversation: conversation)
            self.chatViewModel = newChatViewModel
            print("✅ [openChat] ChatViewModel создан и установлен:")
            print("   - chatViewModel.id: \(newChatViewModel.id)")
            print("   - chatViewModel.conversationId: \(newChatViewModel.conversationId ?? "nil")")
            print("   - chatViewModel != nil: \(self.chatViewModel != nil)")
            self.orderViewModel.selectedUsers = []
            print("✅ [openChat] Метод завершен. chatViewModel должен открыться в sheet.")
        }
    }
    
    private func handleImageSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoadingImage = true
        
        do {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                
                // Загружаем изображение на сервер
                if let imageURL = try await viewModel.saveOrderImage(data: data) {
                    // Отправляем в чат
                    await sendImageToChat(imageURL: imageURL)
                    
                    // Обновляем статус
                    try await viewModel.updateOrderStatus(
                        type: .isSent,
                        value: true,
                        id: currentOrderItem.id,
                        documentId: currentOrderItem.documentId
                    )
                }
            }
        } catch {
            print("Ошибка загрузки изображения: \(error.localizedDescription)")
        }
        
        isLoadingImage = false
    }
    
    private func sendImageToChat(imageURL: URL) async {
        guard let owner = owner, let recipient = recipient,
              let currentUser = viewModel.currentUser else { return }
        
        // Сначала обновляем список conversations
        await orderViewModel.fetchData()
        
        // Создаем групповой чат для троих: owner, recipient, sender
        var usersForChat: [User] = [owner, recipient]
        
        // Добавляем sender (отправителя)
        if let sender = await viewModel.fetchUser(by: orderItem.id) {
            if !usersForChat.contains(where: { $0.id == sender.id }) {
                usersForChat.append(sender)
            }
        }
        
        // Убеждаемся, что все три участника в списке
        guard usersForChat.count == 3 else { return }
        
        // Выбираем пользователей для conversation
        await orderViewModel.selectUsers(usersForChat.map { $0.id })
        
        // Ищем существующую conversation или создаем новую
        var conversation = await orderViewModel.conversationForUsers()
        
        if conversation == nil {
            // Создаем новую групповую conversation с всеми участниками
            conversation = await orderViewModel.createConversation(usersForChat)
        }
        
        guard let conversation = conversation else { return }
        
        // Создаем ChatViewModel и отправляем изображение
        let chatVM = ChatViewModel(auth: viewModel, conversation: conversation)
        
        // Создаем DraftMessage с текстом
        let draft = DraftMessage(
            text: "Посылка передана",
            medias: [],
            recording: nil,
            replyMessage: nil,
            createdAt: Date.now
        )
        
        // Отправляем сообщение с изображением
        chatVM.sendMessage(draft, usingDefaultImageURL: imageURL)
        
        // Обновляем conversation в UI
        await MainActor.run {
            self.conversation = conversation
            self.chatViewModel = chatVM
            self.orderViewModel.selectedUsers = []
        }
    }
    
    private func confirmPickedUp() async {
        do {
            try await viewModel.updateOrderStatus(
                type: .isInDelivery,
                value: true,
                id: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            // Обновляем локальное состояние
            currentOrderItem.isInDelivery = true
        } catch {
            print("Ошибка обновления статуса: \(error.localizedDescription)")
        }
    }
    
    private func confirmDelivered() async {
        do {
            try await viewModel.updateOrderStatus(
                type: .isDelivered,
                value: true,
                id: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            // Обновляем локальное состояние
            currentOrderItem.isDelivered = true
        } catch {
            print("Ошибка обновления статуса: \(error.localizedDescription)")
        }
    }
    
    private func setupStatusListener() {
        let docRef = Firestore.firestore()
            .collection("orderDescription")
            .document(currentOrderItem.id)
            .collection("information")
            .document(currentOrderItem.documentId)
        
        orderStatusListener = docRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot,
                  let data = snapshot.data() else { return }
            
            DispatchQueue.main.async {
                currentOrderItem.isSent = data["isSent"] as? Bool ?? false
                currentOrderItem.isInDelivery = data["isInDelivery"] as? Bool ?? false
                currentOrderItem.isDelivered = data["isDelivered"] as? Bool ?? false
            }
        }
    }
}

#Preview {
    OrderDetailView(
        orderItem: OrderDescriptionItem(
            id: "1",
            documentId: "doc1",
            announcementId: "ann1",
            ownerId: "owner1",
            recipientId: "recipient1",
            cityFromLat: nil,
            cityFromLon: nil,
            cityToLat: nil,
            cityToLon: nil,
            cityFrom: "Москва",
            cityTo: "Санкт-Петербург",
            ownerName: "Иван",
            creationTime: Date(),
            description: nil,
            image: nil,
            price: 1000,
            isSent: false,
            isInDelivery: false,
            isDelivered: false,
            isCompleted: false
        ),
        listingItem: ListingItem(
            id: "ann1",
            ownerUid: "owner1",
            ownerName: "Иван",
            imageUrl: "",
            pricePerKillo: "100",
            cityFrom: "Москва",
            cityTo: "Санкт-Петербург",
            imageUrls: "",
            startdate: "2025-01-01",
            conversation: nil,
            isAuthorized: false,
            dateIsExpired: false
        )
    )
    .environmentObject(AuthViewModel.shared)
}
