//
//  ConversationsListView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 17.11.2023.
//  Edited by Sasha Soldatov on 29.10.2025.
//

import SwiftUI
import SDWebImageSwiftUI

//enum OrderStatus: String, CaseIterable, Identifiable  {
//    var id: String {
////        DispatchQueue.main.async {
//            return self.rawValue
////        }
//    }
//    
//    case generated = "generated"
//    case scanned = "scanned"
//}





struct OrderWithListing: Identifiable, Hashable {
    let id: String
    let orderItem: OrderDescriptionItem
    let listingItem: ListingItem
}

@available(iOS 17.0, *)
struct OrdersList: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var orderWithListing: OrderWithListing? = nil

    var body: some View {
        if let user = viewModel.currentUser {
           NavigationStack {
               TypePickerView()
               
               VStack {
                   switch viewModel.orderStatus {
                   case .isInDelivery:
                       AnyView(ScrollViewWithOrders(isIncluded: {!$0.isDelivered}))
                   default:
                       AnyView(ScrollViewWithOrders(isIncluded: {$0.isDelivered}))
                   }
               }
               .toolbar {
                   ToolbarItem(placement: .navigationBarLeading)
                   {
                       VStack{
                           HStack{
                               //MARK: - image profile
//                               WebImage(url: URL(string: user.imageUrl ?? ""))
//                                   .resizable()
//                                   .scaledToFill()
//                                   .frame(width: 50, height: 50)
//                                   .clipped()
//                                   .cornerRadius(50)
//                                   .shadow(radius: 5)
                               
                               Text(user.login)
                                   .font(.title)
                                   .fontWeight(.semibold)
                           }
                       }
                   }
               }
               .navigationDestination(item: $orderWithListing) { item in
                   OrderDetailView(
                       orderItem: item.orderItem,
                       listingItem: item.listingItem
                   )
                   .environmentObject(viewModel)
               }
               
           }
           .onAppear {
               viewModel.fetchOrderDescription()
               viewModel.fetchOrderDescriptionAsOwner()
               viewModel.fetchOrderDescriptionAsRecipient()
           }
           .onDisappear {
//               viewModel = nil
//               orderItem = nil
//               viewModel.orderDescription.removeAll()
           }
       }
    }
    
    
    private func ScrollViewWithOrders(isIncluded: (OrderDescriptionItem) -> Bool)->some View {
        ScrollView {
            
            if !viewModel.ownerOrderDescription.filter(isIncluded).isEmpty {
                    Text("Мои поездки")
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                }
            ForEach(viewModel.ownerOrderDescription.filter(isIncluded), id: \.hashValue) { order in
                    OrderRow(isCompleted: order.isCompleted,
                             orderImageURL: order.image,
                             profileName: "В \(order.cityTo)",
                             orderDescription: order.description ?? "Описание",
                             date: order.creationTime)
                    .onTapGesture {
                        Task {
                            await loadListingItemAndSetOrder(order)
                        }
                    }
                }
                
            if !viewModel.orderDescription.filter(isIncluded).isEmpty {
                    Text("Заказанные товары")
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                }
            ForEach(viewModel.orderDescription.filter(isIncluded), id: \.hashValue) { order in
                    OrderRow(isCompleted: order.isCompleted,
                             orderImageURL: order.image,
                             profileName: "В \(order.cityTo)",
                             orderDescription: order.description ?? "Описание",
                             date: order.creationTime)
                    .onTapGesture {
                        Task {
                            await loadListingItemAndSetOrder(order)
                        }
                    }
                }

                
             ///   if !viewModel.orderDescription.filter(isIncluded).isEmpty {
             ///       Text("Заказанные товары")
             ///           .fontWeight(.medium)
             ///           .foregroundStyle(.black)
             ///   }
            ///ForEach(viewModel.orderDescription.filter(isIncluded), id: \.hashValue) { order in
             ///       OrderRow(isCompleted: order.isCompleted,
             ///                orderImageURL: order.image,
             ///                profileName: "В \(order.cityTo)",
             ///                orderDescription: order.description ?? "Описание",
             ///                date: order.creationTime)
             ///       .onTapGesture {
             ///           self.orderItem = order
             ///       }
             ///   }
                
                
                if !viewModel.recipientOrderDescription.filter(isIncluded).isEmpty {
                    Text("Нужно получить")
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                }
                ForEach(viewModel.recipientOrderDescription.filter(isIncluded), id: \.hashValue) { order in
                    OrderRow(isCompleted: order.isCompleted,
                             orderImageURL: order.image,
                             profileName: "В \(order.cityTo)",
                             orderDescription: order.description ?? "Описание",
                             date: order.creationTime)
                    .onTapGesture {
                        Task {
                            await loadListingItemAndSetOrder(order)
                        }
                    }
                }
        }
    }
    
    private func TypePickerView()-> some View {
        Picker("type", selection: $viewModel.orderStatus) {
            ForEach(OrderStatus.AllCases(arrayLiteral: .isInDelivery,.isDelivered)) { type in
                withAnimation {
                    Text(type.rawValue).tag(type)
                }
            }
        }
        .pickerStyle(.segmented)
        .padding()
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

//@available(iOS 17.0, *)
//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationsListView()
//    }
//}
