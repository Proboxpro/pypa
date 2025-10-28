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
                //MARK: HStack с двумя кнопками ввода кг и получателем
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            isKilloButtonShowing.toggle()
                            print("Нажали Кол-во кг")
                        } label: {
                            HStack {
                                Text("Кол-во КГ")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding()
                            .frame(minWidth: 160)
                            .background(.baseMint)
                            .cornerRadius(12)
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            print("Нажали Получатель")
                        } label: {
                            HStack {
                                Text("Получатель")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding()
                            .frame(minWidth: 160)
                            .background(.baseMint)
                            .cornerRadius(12)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
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
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                owner = await viewModel.fetchUser(by: item.ownerUid)
            }
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
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                            }
                            Image(systemName: "star")
                                .font(.system(size: 12))
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
                .shadow(radius: 8, y: 10)
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

