//
//  ConversationsListView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 17.11.2023.
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





@available(iOS 17.0, *)
struct OrdersList: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var orderItem: OrderDescriptionItem? = nil

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
               .fullScreenCover(item: $orderItem, onDismiss: {
//                   viewModel.fetchOrderDescription()
               }, content: { item in
                   NavigationView{
                       OrderDetail(orderItem: item)
                           .environmentObject(OrderViewModel(authViewModel: self.viewModel))
                           .navigationBarBackButtonHidden()
                   }
               })
               
           }
           .onAppear {
               viewModel.fetchOrderDescription()
//               viewModel.fetchOrderDescriptionAsOwner()
//               viewModel.fetchOrderDescriptionAsRecipient()
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
//            ForEach(viewModel.ownerOrderDescription.filter(isIncluded), id: \.hashValue) { order in
                ForEach(viewModel.orderDescription.filter(isIncluded), id: \.hashValue) { order in
                    OrderRow(isCompleted: order.isCompleted,
                             orderImageURL: order.image,
                             profileName: "В \(order.cityTo)",
                             orderDescription: order.description ?? "Описание",
                             date: order.creationTime)
                    .onTapGesture {
                        self.orderItem = order
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
                        self.orderItem = order
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
}

//@available(iOS 17.0, *)
//struct Inbox_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationsListView()
//    }
//}
