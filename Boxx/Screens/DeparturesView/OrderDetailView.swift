//
//  DealDetailsView.swift
//  Boxx
//
//  Created by Sasha Soldatov on 29.10.2025.
//

import SwiftUI
import Nuke
import NukeUI
import PhotosUI
import FirebaseFirestore
import ExyteChat
import Combine

class RecipientTimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    private var timer: Timer?
    private var deadline: Date?
    
    func startTimer(deadline: Date?, onExpired: @escaping () -> Void) {
        stopTimer()
        guard let deadline = deadline else { return }
        self.deadline = deadline
        
        updateTimeRemaining()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.updateTimeRemaining()
                
                if Date() >= deadline {
                    timer.invalidate()
                    self.timer = nil
                    onExpired()
                }
            }
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimeRemaining() {
        guard let deadline = deadline else {
            timeRemaining = 0
            return
        }
        timeRemaining = max(0, deadline.timeIntervalSince(Date()))
    }
}

struct OrderDetailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let orderItem: OrderDescriptionItem
    let listingItem: ListingItem
    var onDismiss: (() -> Void)? = nil
    
    @State private var owner: User?
    @State private var recipient: User?
    @State private var sender: User?
    @State private var conversation: Conversation?
    @State private var chatViewModel: ChatViewModel?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var isLoadingImage: Bool = false
    @State private var orderStatusListener: ListenerRegistration?
    @State private var currentOrderItem: OrderDescriptionItem
    @State private var currentOwnerDealStatus: OwnerDealStatus
    @State private var currentRecipientDealStatus: RecipientDealStatus
    @State private var recipientDeadline: Date?
    @State private var ownerTimerUpdateTrigger: Date = Date()
    
    @StateObject private var timerManager = RecipientTimerManager()
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
    
    // MARK: - Computed Properties для статусов сделки
    var isDealAcceptedByBoth: Bool {
        currentOwnerDealStatus == .accepted && currentRecipientDealStatus == .accepted
    }
    
    var isPendingOwnerDecision: Bool {
        isOwner && !isSender && currentOwnerDealStatus == .pending
    }
    
    var isPendingRecipientDecision: Bool {
        isRecipient && !isOwner && !isSender && currentRecipientDealStatus == .pending
    }
    
    var isSenderWaitingForOwner: Bool {
        guard !isDealDeclined else { return false }
        
        if isSender && !isOwner {
            return currentOwnerDealStatus == .pending || currentRecipientDealStatus == .pending
        }
        
        if isOwner && !isSender {
            return currentOwnerDealStatus == .accepted && currentRecipientDealStatus == .pending
        }
        
        return false
    }
    
    var isDealDeclined: Bool {
        currentOwnerDealStatus == .declined || currentRecipientDealStatus == .declined || currentRecipientDealStatus == .expired
    }
    
    var recipientTimeRemainingString: String {
        if timerManager.timeRemaining <= 0 {
            return "00:00"
        }
        let minutes = Int(timerManager.timeRemaining) / 60
        let seconds = Int(timerManager.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var recipientTimeRemainingForOwner: TimeInterval {
        _ = ownerTimerUpdateTrigger
        guard let deadline = recipientDeadline else { return 0 }
        return max(0, deadline.timeIntervalSince(Date()))
    }
    
    var recipientTimeRemainingStringForOwner: String {
        let timeRemaining = recipientTimeRemainingForOwner
        if timeRemaining <= 0 {
            return "00:00"
        }
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var mapView: MapView {
        let fromLat = orderItem.cityFromLat ?? 0
        let fromLon = orderItem.cityFromLon ?? 0
        let toLat = orderItem.cityToLat ?? 0
        let toLon = orderItem.cityToLon ?? 0
        
        return MapView(coordinates: ((fromLat, fromLon), (toLat, toLon)),
                names: (orderItem.cityFrom, orderItem.cityTo))
    }
    
    init(orderItem: OrderDescriptionItem, listingItem: ListingItem, onDismiss: (() -> Void)? = nil) {
        self.orderItem = orderItem
        self.listingItem = listingItem
        self.onDismiss = onDismiss
        _currentOrderItem = State(initialValue: orderItem)
        _currentOwnerDealStatus = State(initialValue: orderItem.ownerDealStatus)
        _currentRecipientDealStatus = State(initialValue: orderItem.recipientDealStatus)
        _recipientDeadline = State(initialValue: orderItem.recipientResponseDeadline)
        _orderViewModel = StateObject(wrappedValue: OrderViewModel(authViewModel: AuthViewModel.shared))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                
                ZStack(alignment: .bottomLeading) {
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
                ZStack {
                    mapView
                        .frame(height: 270)
                        .padding(.top, -10)
                        .zIndex(0)
                    
                    
                    // Секция "Отдайте посылку" - только для sender, когда посылка еще не отправлена и сделка принята обеими сторонами
                    if isSender && !isOwner && !currentOrderItem.isSent && isDealAcceptedByBoth {
                        // Отправитель должен загрузить фото посылки
                        sendParcelSection
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .zIndex(1)
                    }
                    
                    // Кнопка подтверждения для owner: "Забрал" — после того, как sender отправил фото и сделка принята
                    if isOwner && !isSender && currentOrderItem.isSent && !currentOrderItem.isPickedUp && isDealAcceptedByBoth {
                        confirmPickedUpButton
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .zIndex(1)
                    }
                    
                    // Кнопка подтверждения для owner: "Я в пути" — после того, как подтвердил забор
                    if isOwner && !isSender && currentOrderItem.isPickedUp && !currentOrderItem.isInDelivery && isDealAcceptedByBoth {
                        confirmOnTheWayButton
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .zIndex(1)
                    }
                    
                    // Секция для recipient: загрузка фото получения, затем меняем статус isDelivered
                    if isRecipient && !isSender && !isOwner && currentOrderItem.isInDelivery && !currentOrderItem.isDelivered && isDealAcceptedByBoth {
                        receiveParcelSection
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .zIndex(1)
                    }
                    
                }
                
                if isPendingOwnerDecision {
                    ownerDecisionButtons
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                //Spacer(minLength: 100)
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        .safeAreaInset(edge: .bottom) {
            ZStack(alignment: .bottom) {
                statusBarSection
                    .zIndex(1)
                
                if let owner = owner, let recipient = recipient, let sender = sender {
                    chatSectionWithoutButton(owner: owner, recipient: recipient, sender: sender)
                        .offset(y: -75)
                        .zIndex(0)
                        .overlay(alignment: .topLeading) {
                            chatButton
                                .padding(.leading, 16)
                                .padding(.top, 16)
                                .offset(x:-5, y: -70)
                        }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
            //.shadow(radius: 8, y: -2)
        }
        .overlay {
            if isPendingRecipientDecision {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        recipientDecisionButtons
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                }
                .zIndex(9999)
            }

            if isDealDeclined {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        declinedDealMessage
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                }
                .zIndex(9999)
            } else if isSenderWaitingForOwner {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
                        senderWaitingMessage
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                }
                .zIndex(9999)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await loadUsers()
                setupStatusListener()
                
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                if isPendingRecipientDecision, let deadline = recipientDeadline {
                    if Date() >= deadline {
                        await expireRecipientDeal()
                    } else {
                        // Запускаем таймер для recipient
                        startRecipientTimer()
                    }
                }
            }
        }
        .onDisappear {
            orderStatusListener?.remove()
            stopRecipientTimer()
        }
        .onChange(of: currentRecipientDealStatus) { oldValue, newValue in
            if newValue != .pending {
                stopRecipientTimer()
            } else if newValue == .pending && isPendingRecipientDecision {
                startRecipientTimer()
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photosPickerItem, matching: .images)
        .onChange(of: photosPickerItem) { oldValue, newValue in
            Task {
                await handleImageSelection(newValue)
            }
        }
    }
    
    // MARK: - Chat Section без кнопки
    @ViewBuilder
    private func chatSectionWithoutButton(owner: User, recipient: User, sender: User) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Color.clear
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(owner.fullname)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(recipient.fullname)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                Text(sender.fullname)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            Spacer()
            
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
        }
        .offset(y: -30)
        .frame(height: 120)
        .padding(16)
        .background(Color.baseMint).cornerRadius(16)
    }
    
    // MARK: - Кнопка чата (отдельно, на верхнем слое)
    private var chatButton: some View {
        Button {
            openChat()
        } label: {
            Image(systemName: "ellipsis.message")
                .foregroundStyle(.black)
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(.white)
                }
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .allowsHitTesting(true)
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
    
    // MARK: - раздел с отправкой посылки (у sender)
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

    // MARK: - раздел с подтверждением получения (у recipient)
    private var receiveParcelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let owner = owner {
                Text("Сделайте фото полученной посылки у \(owner.fullname)")
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
                    Text("Сделать фото получения")
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
        //.shadow(radius: 8, y: 5)
    }
    
    // MARK: - кнопка подтверждения у owner
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
    
    private var confirmOnTheWayButton: some View {
        Button {
            Task {
                await confirmOnTheWay()
            }
        } label: {
            Text("Подтвердите, что вы в пути")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.baseMint)
                .cornerRadius(12)
        }
        .shadow(radius: 8, y: 5)
    }
    
    // MARK: - UI элементы для deal status
    
    private var ownerDecisionButtons: some View {
        VStack(spacing: 16) {
            Text("Принять или отклонить сделку?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button {
                    Task {
                        await acceptDealByOwner()
                    }
                } label: {
                    Text("Принять")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.baseMint)
                        .cornerRadius(12)
                }
                
                Button {
                    Task {
                        await declineDealByOwner()
                    }
                } label: {
                    Text("Отклонить")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 5)
    }
    
    private var recipientDecisionButtons: some View {
        VStack(spacing: 16) {
            Text("Принять или отклонить сделку?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Осталось времени:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(recipientTimeRemainingString)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(timerManager.timeRemaining > 300 ? .baseMint : .red) // Красный если меньше 5 минут
                    .monospacedDigit()
            }
            .padding(.vertical, 8)
            
            HStack(spacing: 20) {
                Button {
                    Task {
                        await acceptDealByRecipient()
                    }
                } label: {
                    Text("Принять")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.baseMint)
                        .cornerRadius(12)
                }
                
                Button {
                    Task {
                        await declineDealByRecipient()
                    }
                } label: {
                    Text("Отклонить")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 5)
    }
    
    private var senderWaitingMessage: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Ожидание подтверждения")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                if let owner = owner {
                    HStack {
                        Text("Путешественник:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(owner.fullname)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
                
                if let recipient = recipient {
                    HStack {
                        Text("Получатель:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(recipient.fullname)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
                
                if let deadline = recipientDeadline {
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 8) {
                        Text("Осталось времени для получателя:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Text(recipientTimeRemainingStringForOwner)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(recipientTimeRemainingForOwner > 300 ? .baseMint : .red) // Красный если меньше 5 минут
                            .monospacedDigit()
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 8)
            
            // Статус ожидания
            if currentOwnerDealStatus == .pending && currentRecipientDealStatus == .pending {
                Text("Ожидаем подтверждения от путешественника и получателя")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if currentOwnerDealStatus == .pending {
                Text("Ожидаем подтверждения от путешественника")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if currentRecipientDealStatus == .pending {
                Text("Ожидаем подтверждения от получателя")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 5)
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            // Обновляем UI каждую секунду для обновления таймера
            ownerTimerUpdateTrigger = Date()
        }
    }
    
    private var declinedDealMessage: some View {
        VStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            
            Text("Сделка отклонена")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
            
            if currentRecipientDealStatus == .declined {
                Text("Получатель отклонил сделку.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if currentRecipientDealStatus == .expired {
                Text("Время на подтверждение истекло.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if currentOwnerDealStatus == .declined {
                Text("Путешественник отклонил сделку.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Text("Она больше не активна.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 5)
    }
    
    // MARK: - статус бар у всех
    private var statusBarSection: some View {
        VStack(spacing: 24) {
            ZStack {
                HStack {
                    Spacer()
                    // Линия между "Забрал" и "Доставка" - зеленая после подтверждения забора (isPickedUp)
                    Rectangle()
                        .foregroundColor(currentOrderItem.isPickedUp ? .baseMint : .black)
                        .frame(width: 128, height: 2)
                        .padding(.bottom, 62)
                    // Линия между "Доставка" и "Получено" - зеленая когда recipient подтвердил (isDelivered)
                    Rectangle()
                        .foregroundColor(currentOrderItem.isDelivered ? .baseMint : .black)
                        .frame(width: 128, height: 2)
                        .padding(.bottom, 62)
                    Spacer()
                }
                
                ZStack {
                    HStack {
                        // Забрал - подсвечивается только после подтверждения owner (isPickedUp)
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.tabBackground)
                                    .frame(width: 32, height: 32)
                                Image(currentOrderItem.isPickedUp ? "box_hand_mint" : "box_hand_black")
                                    .resizable().scaledToFill()
                                    .frame(width: 24, height: 24)
                                    
                            
                                }
                            Text("Забрал")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(currentOrderItem.isPickedUp ? .baseMint : .black)
                            
                            // Фиксированное пространство для даты
                            Group {
                                if let pickedUpDate = currentOrderItem.pickedUpDate {
                                    Text(pickedUpDate.convertToMonthYearFormat())
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(.gray)
                                } else {
                                    Text(" ")
                                        .font(.system(size: 10, weight: .regular))
                                        .opacity(0)
                                }
                            }
                            .frame(height: 12)
                        }
                        
                        Spacer()
                        
                        // Получено (isDelivered)
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.tabBackground)
                                    .frame(width: 32, height: 32)
                                Image(currentOrderItem.isDelivered ? "box_checkmark_mint" : "box_checkmark_black")
                                    .resizable().scaledToFill()
                                    .frame(width: 18, height: 18)
                                    
                            }
                            Text("Получено")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(currentOrderItem.isDelivered ? .baseMint : .black)
                            
                            // Фиксированное пространство для даты
                            Group {
                                if let deliveredDate = currentOrderItem.deliveredDate {
                                    Text(deliveredDate.convertToMonthYearFormat())
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(.gray)
                                } else {
                                    Text(" ")
                                        .font(.system(size: 10, weight: .regular))
                                        .opacity(0)
                                }
                            }
                            .frame(height: 12)
                        }
                    }
                    
                    // Доставка (isInDelivery)
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.tabBackground)
                                .frame(width: 32, height: 32)
                            Image(currentOrderItem.isInDelivery ? "box_with_clock_mint" : "box_with_clock_black")
                                .resizable().scaledToFill()
                                .frame(width: 20, height: 20)
                                
                        }
                        Text("Доставка")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(currentOrderItem.isInDelivery ? .baseMint : .black)
                        
                        Text(" ")
                            .font(.system(size: 10, weight: .regular))
                            .opacity(0)
                            .frame(height: 12)
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        //.shadow(radius: 8, y: 5)
    }
    
    private var backgroundImage: some View {
        let urlString = listingItem.imageUrls
        
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
    
    // MARK: - Методы
    private func loadUsers() async {
        owner = await viewModel.fetchUser(by: orderItem.ownerId)
        recipient = await viewModel.fetchUser(by: orderItem.recipientId)
        sender = await viewModel.fetchUser(by: orderItem.id)
    }
    
    private func openChat() {
        Task { @MainActor in
            guard let currentUser = viewModel.currentUser else {
                print("❌ openChat: currentUser is nil")
                return
            }
            print("✅ openChat: currentUser найден")
            
            // Загружаем всех участников, если они еще не загружены
            if owner == nil {
                owner = await viewModel.fetchUser(by: orderItem.ownerId)
            }
            if recipient == nil {
                recipient = await viewModel.fetchUser(by: orderItem.recipientId)
            }
            
            // Создаем групповой чат между тремя участниками:
            // 1. owner (путешественник) - orderItem.ownerId
            // 2. recipient (получатель посылки) - orderItem.recipientId
            // 3. sender (отправитель, который создал сделку) - orderItem.id
            // ВСЕГДА должны быть все трое участников!
            var usersForChat: [User] = []
            var addedUserIds = Set<String>()
            
            let ownerId = orderItem.ownerId
            let recipientId = orderItem.recipientId
            let senderId = orderItem.id
            
            if let ownerUser = owner {
                if !addedUserIds.contains(ownerUser.id) {
                    usersForChat.append(ownerUser)
                    addedUserIds.insert(ownerUser.id)
                }
            } else {
                if let ownerUser = await viewModel.fetchUser(by: ownerId) {
                    await MainActor.run { self.owner = ownerUser }
                    if !addedUserIds.contains(ownerUser.id) {
                        usersForChat.append(ownerUser)
                        addedUserIds.insert(ownerUser.id)
                    }
                }
            }
            
            if let recipientUser = recipient {
                if !addedUserIds.contains(recipientUser.id) {
                    usersForChat.append(recipientUser)
                    addedUserIds.insert(recipientUser.id)
                }
            } else {
                if let recipientUser = await viewModel.fetchUser(by: recipientId) {
                    await MainActor.run { self.recipient = recipientUser }
                    if !addedUserIds.contains(recipientUser.id) {
                        usersForChat.append(recipientUser)
                        addedUserIds.insert(recipientUser.id)
                    }
                }
            }
            

            if !addedUserIds.contains(senderId) {
                if let sender = await viewModel.fetchUser(by: senderId) {
                    usersForChat.append(sender)
                    addedUserIds.insert(sender.id)
                }
            }
            
            guard usersForChat.count >= 2 else {
                return
            }
        
            await orderViewModel.fetchData()
            
            for user in usersForChat {
                if !MessageService.shared.allUsers.contains(where: { $0.id == user.id }) {
                    await MessageService.shared.getUsers()
                    break
                }
            }

            await MessageService.shared.getConversations()

            orderViewModel.selectedUsers = []
            orderViewModel.selectedUsers = usersForChat
            
            var conversation = await orderViewModel.conversationForUsers(orderDocumentId: orderItem.documentId)
            
            if conversation == nil {
                conversation = await orderViewModel.createConversation(usersForChat, orderDocumentId: orderItem.documentId)
                
                await orderViewModel.fetchData()
            }
            
            guard let conversation = conversation else {
                await orderViewModel.fetchData()
                let foundConversation = await orderViewModel.conversationForUsers(orderDocumentId: orderItem.documentId)
                guard let conversation = foundConversation else {
                    return
                }
                
                self.conversation = conversation
                self.chatViewModel = ChatViewModel(auth: viewModel, conversation: conversation)
                self.orderViewModel.selectedUsers = []
                return
            }
            
            self.conversation = conversation
            let newChatViewModel = ChatViewModel(auth: viewModel, conversation: conversation)
            self.chatViewModel = newChatViewModel
            self.orderViewModel.selectedUsers = []
        }
    }
    
    private func handleImageSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoadingImage = true
        
        do {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                
                if let imageURL = try await viewModel.saveOrderImage(data: data) {
                    await sendImageToChat(imageURL: imageURL)

                    if isSender && !isOwner {
                        try await viewModel.updateOrderStatus(
                            type: .isSent,
                            value: true,
                            id: currentOrderItem.id,
                            documentId: currentOrderItem.documentId
                        )
                    } else if isRecipient && !isOwner {
                        try await viewModel.updateOrderStatus(
                            type: .isDelivered,
                            value: true,
                            id: currentOrderItem.id,
                            documentId: currentOrderItem.documentId
                        )
                    }
                }
            }
        } catch {
        }
        
        isLoadingImage = false
    }
    
    private func sendImageToChat(imageURL: URL) async {
        guard let owner = owner, let recipient = recipient,
              let currentUser = viewModel.currentUser else { return }
        
        await orderViewModel.fetchData()
        
        var usersForChat: [User] = [owner, recipient]
        
        // Добавляем sender
        if let sender = await viewModel.fetchUser(by: orderItem.id) {
            if !usersForChat.contains(where: { $0.id == sender.id }) {
                usersForChat.append(sender)
            }
        }
        
        guard usersForChat.count == 3 else { return }
        await orderViewModel.selectUsers(usersForChat.map { $0.id })
        var conversation = await orderViewModel.conversationForUsers(orderDocumentId: orderItem.documentId)
        
        if conversation == nil {
            conversation = await orderViewModel.createConversation(usersForChat, orderDocumentId: orderItem.documentId)
        }
        
        guard let conversation = conversation else { return }
        
        let chatVM = ChatViewModel(auth: viewModel, conversation: conversation)
        
        let draft = DraftMessage(
            text: (currentUser.id == orderItem.recipientId) ? "Посылка получена" : "Посылка передана",
            medias: [],
            recording: nil,
            replyMessage: nil,
            createdAt: Date.now
        )
        
        chatVM.sendMessage(draft, usingDefaultImageURL: imageURL)
        
        await MainActor.run {
            self.conversation = conversation
            self.chatViewModel = chatVM
            self.orderViewModel.selectedUsers = []
        }
    }
    
    private func confirmPickedUp() async {
        do {
            try await viewModel.updateOrderStatus(
                type: .isPickedUp,
                value: true,
                id: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            await MainActor.run {
                currentOrderItem.isPickedUp = true
                currentOrderItem.pickedUpDate = Date()
            }
        } catch {
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
            
            await MainActor.run {
                currentOrderItem.isDelivered = true
                currentOrderItem.deliveredDate = Date()
            }
        } catch {
        }
    }

    private func confirmOnTheWay() async {
        do {
            try await viewModel.updateOrderStatus(
                type: .isInDelivery,
                value: true,
                id: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            currentOrderItem.isInDelivery = true
        } catch {
        }
    }
    
    // MARK: - Функции для owner
    private func acceptDealByOwner() async {
        do {
            try await viewModel.updateOwnerDealStatus(
                status: .accepted,
                orderId: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            await MainActor.run {
                currentOwnerDealStatus = .accepted
                currentOrderItem.ownerDealStatus = .accepted
            }
        } catch {
            print("Ошибка принятия сделки owner: \(error.localizedDescription)")
        }
    }
    
    private func declineDealByOwner() async {
        do {
            try await viewModel.updateOwnerDealStatus(
                status: .declined,
                orderId: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            await MainActor.run {
                currentOwnerDealStatus = .declined
                currentOrderItem.ownerDealStatus = .declined
            }
        } catch {
            print("Ошибка отклонения сделки owner: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Функции для recipient
    private func acceptDealByRecipient() async {
        timerManager.stopTimer()
        do {
            try await viewModel.updateRecipientDealStatus(
                status: .accepted,
                orderId: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            await MainActor.run {
                currentRecipientDealStatus = .accepted
                currentOrderItem.recipientDealStatus = .accepted
            }
        } catch {
            print("Ошибка принятия сделки recipient: \(error.localizedDescription)")
        }
    }
    
    private func declineDealByRecipient() async {
        timerManager.stopTimer()
        do {
            try await viewModel.updateRecipientDealStatus(
                status: .declined,
                orderId: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            await MainActor.run {
                currentRecipientDealStatus = .declined
                currentOrderItem.recipientDealStatus = .declined
            }
        } catch {
            print("Ошибка отклонения сделки recipient: \(error.localizedDescription)")
        }
    }
    
    private func startRecipientTimer() {
        guard let deadline = recipientDeadline else { return }
        guard currentRecipientDealStatus == .pending else { return }
        
        let orderId = currentOrderItem.id
        let documentId = currentOrderItem.documentId
        let vm = viewModel
        
        timerManager.startTimer(deadline: deadline) {
            Task {
                try? await vm.updateRecipientDealStatus(
                    status: .expired,
                    orderId: orderId,
                    documentId: documentId
                )
            }
        }
    }
    
    private func stopRecipientTimer() {
        timerManager.stopTimer()
    }
    
    private func expireRecipientDeal() async {
        timerManager.stopTimer()
        do {
            try await viewModel.updateRecipientDealStatus(
                status: .expired,
                orderId: currentOrderItem.id,
                documentId: currentOrderItem.documentId
            )
            
            await MainActor.run {
                currentRecipientDealStatus = .expired
                currentOrderItem.recipientDealStatus = .expired
            }
        } catch {
            print("Ошибка автоматического отклонения сделки: \(error.localizedDescription)")
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
                currentOrderItem.isPickedUp = data["isPickedUp"] as? Bool ?? false
                currentOrderItem.isInDelivery = data["isInDelivery"] as? Bool ?? false
                currentOrderItem.isDelivered = data["isDelivered"] as? Bool ?? false
                
                // Читаем ownerDealStatus
                if let ownerDealStatusString = data["ownerDealStatus"] as? String,
                   let status = OwnerDealStatus(rawValue: ownerDealStatusString) {
                    let oldStatus = currentOwnerDealStatus
                    currentOrderItem.ownerDealStatus = status
                    currentOwnerDealStatus = status
                    
                    if oldStatus == .pending && status != .pending {
                    }
                }
                
                if let recipientDealStatusString = data["recipientDealStatus"] as? String,
                   let status = RecipientDealStatus(rawValue: recipientDealStatusString) {
                    let oldStatus = currentRecipientDealStatus
                    currentOrderItem.recipientDealStatus = status
                    currentRecipientDealStatus = status
                    
                    if oldStatus == .pending && status != .pending {
                        stopRecipientTimer()
                    } else if status == .pending && isPendingRecipientDecision {
                        startRecipientTimer()
                    }
                }
                
                if let deadlineTimestamp = data["recipientResponseDeadline"] as? Timestamp {
                    let newDeadline = deadlineTimestamp.dateValue()
                    recipientDeadline = newDeadline
                    currentOrderItem.recipientResponseDeadline = newDeadline
                    
                    // Автоматически проверяем истечение времени, даже если экран не открыт
                    if currentRecipientDealStatus == .pending && Date() >= newDeadline {
                        // Время истекло - автоматически обновляем статус
                        let orderId = self.currentOrderItem.id
                        let documentId = self.currentOrderItem.documentId
                        let vm = self.viewModel
                        
                        Task {
                            try? await vm.updateRecipientDealStatus(
                                status: .expired,
                                orderId: orderId,
                                documentId: documentId
                            )
                        }
                    } else if currentRecipientDealStatus == .pending && isPendingRecipientDecision {
                        // Если время еще не истекло и получатель на экране - запускаем таймер
                        let orderId = self.currentOrderItem.id
                        let documentId = self.currentOrderItem.documentId
                        let vm = self.viewModel
                        
                        self.timerManager.startTimer(deadline: newDeadline) {
                            Task {
                                try? await vm.updateRecipientDealStatus(
                                    status: .expired,
                                    orderId: orderId,
                                    documentId: documentId
                                )
                            }
                        }
                    }
                }
                
                if let pickedUpTimestamp = data["pickedUpDate"] as? Timestamp {
                    currentOrderItem.pickedUpDate = pickedUpTimestamp.dateValue()
                }
                if let deliveredTimestamp = data["deliveredDate"] as? Timestamp {
                    currentOrderItem.deliveredDate = deliveredTimestamp.dateValue()
                }
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
            isPickedUp: false,
            isInDelivery: false,
            isDelivered: false,
            isCompleted: false,
            ownerDealStatus: .pending,
            recipientDealStatus: .pending,
            recipientResponseDeadline: nil
        ),
        listingItem: ListingItem(
            id: "ann1",
            ownerUid: "owner1",
            ownerName: "Иван",
            imageUrl: "",
            pricePerKillo: 100,
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
