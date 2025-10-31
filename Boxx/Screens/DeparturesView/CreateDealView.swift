//
//  CreateDealView.swift
//  Boxx
//
//  Created by Sasha Soldatov on 27.10.2025.
//

import SwiftUI
import Nuke
import NukeUI

struct CreateDealView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    let item: ListingItem
    @State private var weight: String = ""
    @State private var recipientLogin: String = ""
    @State private var isKilloButtonShowing: Bool = false
    @State private var owner: User?
    
    @State private var recipient: User?
    @State private var createdOrderItem: OrderDescriptionItem?
    @State private var isNavigatingToDeal: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    var totalprice: Int {
        let price = item.pricePerKillo.replacingOccurrences(of: " ₽", with: "").replacingOccurrences(of: " ", with: "")
        guard let priceValue = Int(price), let weightValue = Int(weight) else { return 0 }
        return priceValue * weightValue
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .bottomLeading) {
                    backgroundImage
                        .frame(width: SizeConstants.screenWidth, height: SizeConstants.avatarHeight)
                        .clipped()
                        .overlay {
                            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                .cornerRadius(12)
                            //.frame(width: SizeConstants.screenWidth, height: 150)
                            
                        }
                        .overlay {
                            BackTopLeftWhiteButtonView()
                                .offset(y: -60)
                        }
                    
                    //MARK: HStack с ценой и маршрутом
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.pricePerKillo + " ₽")
                                .font(.system(size: 20, weight:.bold))
                                .foregroundStyle(.white)
                                .padding(16)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(item.cityFrom) - \(item.cityTo)")
                                .font(.system(size: 16, weight:.semibold))
                                .foregroundStyle(.white)
                                .padding(16)
                        }
                    }
                }
                //MARK: HStack с двумя полями ввода кг и получателем
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Кол-во КГ")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                        TextField("Введите вес", text: $weight)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Логин получателя")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                        TextField("Введите логин получателя", text: $recipientLogin)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                if let owner = owner {
                    travelerProfileCard(owner: owner)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                
                Spacer(minLength: 100)
            }
            
            //MARK: - нижняя кнопка ПУП
            VStack {
                Spacer()
                
                HStack{
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Image("airplane.up.right")
                                .resizable().scaledToFit()
                                .frame(width: 24, height: 24)
                                
                            Text("\(totalprice)руб.")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text(item.startdate)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    
                    NavigationLink(destination: destinationView, isActive: $isNavigatingToDeal) {
                        EmptyView()
                    }
                    
                    Button {
                        handleButtonTap()
                    } label: {
                        Text("ПУП")
                             .font(.system(size: 18, weight: .semibold))
                             .foregroundStyle(.white)
                             .frame(width: 120, height: 50)
                             .background(Color.colorButton)
                             .cornerRadius(16)

                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 1)
                    )
                }
                .frame(height: 40)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.baseMint)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(radius: 8, y: 5)
                .padding(.horizontal, 20)
                
                
            }
            .padding(.bottom, 20)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                owner = await viewModel.fetchUser(by: item.ownerUid)
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("ОК") { }
        } message: {
            Text(errorMessage ?? "Произошла ошибка")
        }
        
    }
    
    private func handleButtonTap() {
        guard !weight.isEmpty else {
            errorMessage = "Введите вес посылки"
            showError = true
            return
        }
        
        guard !recipientLogin.isEmpty else {
                errorMessage = "Введите логин получателя"
                showError = true
                return
            }
            
            guard owner != nil else {
                errorMessage = "Информация о путешественнике не загружена"
                showError = true
                return
            }
        Task {
            await createDeal()
        }
    }
    
    private func createDeal() async {
        guard let currentUser = viewModel.currentUser, let owner = owner else { return }
        
        await withCheckedContinuation { continuation in
            viewModel.fetchUser(by: recipientLogin) { user in
                self.recipient = user
                continuation.resume()
            }
        }
        
        guard let recipient = recipient else {
            await MainActor.run {
                errorMessage = "Получатель с логином \(recipientLogin) не найден"
                showError = true
            }
            return
        }
        
        let description = "Посылка весом \(weight) кг"
        let price = totalprice
        let cityFrom = item.cityFrom
        let cityTo = item.cityTo
        
        let emptyImageData = Data()
        
        do {
            let orderItem = try await viewModel.saveOrder(
                ownerId: item.ownerUid,      // ID путешественника
                recipientId: recipient.id,   // ID получателя
                announcementId: item.id,     // ID объявления о поездке
                cityFrom: cityFrom,
                cityTo: cityTo,
                ownerName: owner.fullname,
                imageData: emptyImageData,   // Пока пусто, фото загрузится позже
                description: description,     // "Посылка весом X кг"
                price: price                 // Итоговая цена
            )
            
            guard let orderItem = orderItem else {
                await MainActor.run {
                    errorMessage = "Не удалось создать сделку"
                    showError = true
                }
                return
            }
            
            // Сохранение созданного orderItem и переход на экран деталей
            await MainActor.run {
                createdOrderItem = orderItem  // Сохраняем в @State
                isNavigatingToDeal = true    // Активируем NavigationLink
            }
        } catch {
            await MainActor.run {
                errorMessage = "Ошибка создания сделки: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let orderItem = createdOrderItem {
            OrderDetailView(orderItem: orderItem, listingItem: item)
                .environmentObject(viewModel)
        } else {
            EmptyView()
        }
    }
    
    
    @ViewBuilder
    private func travelerProfileCard(owner: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        //MARK: - Name
                        Text(owner.fullname)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.leading, 40)
                            .padding(.top, -10)
                        Spacer()
                        //MARK: - Rating
                        HStack(spacing: 2) {
                            ForEach(0..<4) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.yellow)
                            }
                            Image(systemName: "star")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    //MARK: - Delivery time
                    Text("Доставлю через 2-3 дня")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.leading, -10)
                }
                Spacer()
            }
            Divider()
                .padding(.vertical, 8)
            
            //MARK: - traveller message
            Text("Еду на поезде, готов взять с собой до 10 кг, аллергий нет, уезжаю с Ладожского :) Могу захватить животных.")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(nil)
        }
        .padding(16)
        .background(
            Image("backInfo")
                .resizable()
                .cornerRadius(16)
                .shadow(radius: 8, y: 5)
        )
        .overlay {
            // Avatar
            AsyncImage(url: URL(string: owner.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .offset(x: -140, y: -80)
        }
        
    }
    
    private var backgroundImage: some View {
        let urlString = item.imageUrl.isEmpty ? item.imageUrls : item.imageUrl
        
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
}
    

    



#Preview {
    CreateDealView(item: ListingItem(
        id: "1",
        ownerUid: "123",
        ownerName: "Test User",
        imageUrl: "https://example.com/image.jpg",
        pricePerKillo: "100",
        cityFrom: "Moscow",
        cityTo: "Berlin",
        imageUrls: "https://example.com/image.jpg",
        startdate: "2025-01-01",
        conversation: nil,
        isAuthorized: false,
        dateIsExpired: false
    ))
    .environmentObject(AuthViewModel())
}

