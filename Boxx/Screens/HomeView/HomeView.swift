//
//  HomeView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    private let trips: [ListingItem] = [
        .init(id: UUID().uuidString, ownerUid: "u1", ownerName: "Alexander", imageUrl: "", pricePerKillo: "6000 ₽", cityFrom: "Мурманск", cityTo: "Санкт-Петербург", imageUrls: "https://picsum.photos/seed/1/600/400", startdate: "2025-10-02"),
        .init(id: UUID().uuidString, ownerUid: "u2", ownerName: " ", imageUrl: "", pricePerKillo: "3500 ₽", cityFrom: "Мурманск", cityTo: "Торжок", imageUrls: "https://picsum.photos/seed/2/600/400", startdate: "2025-10-03")
    ]
    
    private let deals: [DealItem] = [
        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"),
        .init(id: UUID().uuidString, thumbnail: "Background", title: "Slam", subtitle: "Чемодан", timeAgo: "3 часа назад", price: "17500 ₽", avatar: "profile")
    ]
    
    var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("Последние поездки")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
//                        ForEach(trips, id: \.id) { item in
                        ForEach(viewModel.myorder) { item in
                            TripCardView(width: 240, item: item)
                        }
                    }
                    .frame(height: 180)
                    .padding(.horizontal, 16)
                }
                
                Text("Последние сделки")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal, 16)
                
                VStack() {
                    ScrollView {
                        ForEach(deals, id: \.id) { deal in
                            DealRowView(item: deal)
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 10)
            .onAppear {
                viewModel.orderDescription.forEach({print($0)})
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


