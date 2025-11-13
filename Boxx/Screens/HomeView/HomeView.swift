//
//  HomeView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var orderWithListing: OrderWithListing? = nil
    
//    private let trips: [ListingItem] = [
//        .init(id: UUID().uuidString, ownerUid: "u1", ownerName: "Alexander", imageUrl: "", pricePerKillo: 6000, cityFrom: "Мурманск", cityTo: "Санкт-Петербург", imageUrls: "https://picsum.photos/seed/1/600/400", startdate: "2025-10-02"),
//        .init(id: UUID().uuidString, ownerUid: "u2", ownerName: " ", imageUrl: "", pricePerKillo: 3500, cityFrom: "Мурманск", cityTo: "Торжок", imageUrls: "https://picsum.photos/seed/2/600/400", startdate: "2025-10-03")
//    ]
//    
//    private let deals: [DealItem] = [
//        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
//        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile")
//    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Последние поездки")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 16)
                
                ParallaxScrollView()
//                    .padding(.leading, 16)
                
                Text("Последние сделки")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 16)
                
                VStack() {
                    ScrollView {
                        ForEach(viewModel.ownerOrderDescription.filter({$0.isDelivered == false}), id: \.hashValue) { order in
                            DealRowView(item: order)
                                .padding(.horizontal)
                                .onTapGesture {
                                    Task {
                                        await loadListingItemAndSetOrder(order)
                                    }
                                }
                        }
                    }
                }
            }
            .background(Color.white)
            //MARK: убрал отступы для корректного отображения цвета
//            .padding(.vertical)
//            .padding(.horizontal, 10)
            .navigationDestination(item: $orderWithListing) { item in
                OrderDetailView(
                    orderItem: item.orderItem,
                    listingItem: item.listingItem
                )
                .environmentObject(viewModel)
            }
            .onAppear {
                viewModel.orderDescription.forEach({print($0)})
                viewModel.fetchOrderDescription()
                viewModel.fetchOrderDescriptionAsOwner()
                viewModel.fetchOrderDescriptionAsRecipient()
                Task {
                    await viewModel.fetchOrder() // Загружаем orders для получения правильных imageUrls
                }
            }
        }
    }
    
    private func loadListingItemAndSetOrder(_ order: OrderDescriptionItem) async {
        var listing = await viewModel.fetchListingItem(by: order.announcementId)
        
        // Если не нашли в Firestore, создаем минимальный ListingItem из OrderDescriptionItem
        if listing == nil {
            let priceDouble = order.price.map { Double($0) } ?? 0
            listing = ListingItem(
                id: order.announcementId,
                ownerUid: order.ownerId,
                ownerName: order.ownerName,
                imageUrl: order.image?.absoluteString ?? "",
                pricePerKillo: priceDouble,
                cityFrom: order.cityFrom,
                cityTo: order.cityTo,
                imageUrls: order.image?.absoluteString ?? "",
                description: order.description ?? "",
                startdate: "",
                conversation: nil
            )
        }
        
        guard let listing = listing else { return }
        
        await MainActor.run {
            orderWithListing = OrderWithListing(
                id: order.documentId,
                orderItem: order,
                listingItem: listing
            )
        }
    }
      
}

// TripItem removed in favor of using ListingItem

struct DealItem: Hashable {
    var id: String
    var thumbnail: String
    var title: String
    var subtitle: String
    var timeAgo: String
    var price: String
    var avatar: String
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


struct ParallaxScrollView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        GeometryReader { outerGeo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -8) {
                    ForEach(viewModel.myorder) { item in
                        GeometryReader { geo in
                            let midX = geo.frame(in: .global).midX
                            let screenMidX = outerGeo.size.width / 2
                            // расстояние от центра
                            let distance = abs(screenMidX - midX)
                            // масштаб уменьшается с ростом дистанции
                            let scale = max(0.88, 1 - (distance / outerGeo.size.width) * 0.3)
                            
                            NavigationLink {
                                CreateDealView(item: item)
                            } label: {
                                TripCardView(width: 260, item: item)
                                    .scaleEffect(scale)
                                    .animation(.easeOut(duration: 0.3), value: scale)
                            }
                        }
                        .frame(width: 260, height: 190)
                    }
                    Spacer()
                }
//                .padding(.horizontal, (outerGeo.size.width - 240) / 2)
            }
        }
        .frame(height: 200)
    }
}
