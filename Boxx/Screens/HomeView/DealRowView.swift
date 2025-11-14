//
//  DealRowView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

/*
 struct OrderDescriptionItem: Identifiable, Codable, Hashable {
     let id: String
     let documentId: String
     
     let announcementId: String
     let ownerId: String
     let recipientId: String
     
 //    let creationLat: Double?
 //    let creationLon: Double?
     let cityFromLat: Double?
     let cityFromLon: Double?
     let cityToLat: Double?
     let cityToLon: Double?
     
     let cityFrom: String
     let cityTo: String
     let ownerName: String
     let creationTime: Date
     
     let description: String?
     let image: URL?
     let price: Int?
     
     var isSent: Bool
     var isPickedUp: Bool
     var isInDelivery: Bool
     var isDelivered: Bool
     
     var pickedUpDate: Date?
     var deliveredDate: Date?
     
     let isCompleted: Bool
 }

 enum OrderStatus: String, CaseIterable, Identifiable {
     var id: String {
         return self.rawValue
     }
     
     case isSent = "Отправлен"
     case isPickedUp = "Забран"
     case isInDelivery = "Актуальные"
     case isDelivered = "Доставлен"
 }

 */

import SwiftUI
import Nuke
import NukeUI

struct DealRowView: View {
    
    private var isDealDeclinedOrExpired: Bool {
        order.ownerDealStatus == .declined ||
        order.recipientDealStatus == .declined ||
        order.recipientDealStatus == .expired
    }
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var order: OrderDescriptionItem
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: isDealDeclinedOrExpired
                    ? [.red.opacity(0.0), .red.opacity(0.2)]
                    : [.clear.opacity(0.0), .clear.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(12)
//            .frame(width: width, height: 170)
            
            HStack(alignment: .top, spacing: 12) {
                //            Image(item.thumbnail)
                //            Image("Background")
                //                .resizable()
                //                .scaledToFill()
                //                .frame(width: 72, height: 72)
                //                .clipped()
                //                .cornerRadius(8)
                //            let urlString = item.image
                //            let
                
                let toCity = viewModel.allPosibleCityes.filter({$0.name == order.cityTo}).first
                let urlCityStringImage = URL(string: toCity!.reg)
                
                LazyImage(request: ImageRequest(
                    url: urlCityStringImage,
                    processors: [
                        ImageProcessors.Resize(
                            size: CGSize(width: 92, height: 82),
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
                .frame(width: 92, height: 82)
                .onAppear {
                    //                print("URL:", urlCityStringImage)
                    print("ALL Cityes:", viewModel.allPosibleCityes)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(order.cityFrom)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(order.cityTo)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        
                    }
                    //                Spacer()
                    
                    //                HStack {
                    VStack(alignment: .leading) {
                        Text(order.description ?? "-")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(order.creationTime.timeAgoDisplay())
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    //                    Spacer()
                    //                    Circle().fill(.gray).frame(width: 50, height: 50)
                    //                }
                }
                
                Spacer()
                
                VStack {
                    Text("\(order.price!) ₽")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.baseMint)
                    Spacer()
                    
                    //                Circle().fill(.gray).frame(width: 45, height: 45)
                    
                    //MARK: - test
                    let senderImageURL = viewModel.getUserImageURLFrom(id: order.ownerId)
                    
                    LazyImage(request: ImageRequest(
                        url: senderImageURL,
                        processors: [
                            ImageProcessors.Resize(
                                size: CGSize(width: 48, height: 48),
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
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)
                    
                    //                let ownerId = item.ownerId
                    
                    //MARK: - Debug
                    //                let owner =
                    
                    //MARK: - Debug
                    //                Image(item.avatar)
                    //                    .resizable()
                    //                    .scaledToFill()
                    //                    .frame(width: 36, height: 36)
                    //                    .clipShape(Circle())
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                //                .fill(Color(.secondarySystemBackground))
                    .stroke(lineWidth: 0.8).fill(.gray.opacity(0.5))
            )
        }
    }
}

//struct DealRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        DealRowView(item: DealItem(id: "1", thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"))
//            .padding()
//    }
//}


