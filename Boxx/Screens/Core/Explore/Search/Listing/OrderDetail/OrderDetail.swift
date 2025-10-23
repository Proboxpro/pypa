//
//  OderDetail.swift
//  Boxx
//
//  Created by Руслан Парастаев on 14.04.2024.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import PhotosUI
import CachedAsyncImage


@available(iOS 17.0, *)
struct OrderDetail: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
//    var viewModel : AuthViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State var orderItem: OrderDescriptionItem
    
    private var item: ListingItem? {
        let items = viewModel.orders
        let item = items.filter{ $0.id == orderItem.announcementId }.last
        return item
    }
    private var mapView: MapView {
        MapView(coordinates: ((orderItem.cityFromLat ?? 0, orderItem.cityToLon ?? 0), (orderItem.cityToLat ?? 0, orderItem.cityToLon ?? 0)),
                names: (orderItem.cityFrom, orderItem.cityTo))
    }
    
    @State private var showingProfile = false
    @State private var vstackYOffset: CGFloat = 0
    @State private var whiteScreenHeight: CGFloat = 0
    
    @State private var conversation: Conversation? = nil
    @State private var chatViewModel: ChatViewModel? = nil
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    dismiss()
                }  label: { Image(systemName:"chevron.left")
                        .foregroundStyle(.black)
                        .background{
                            Circle()
                                .fill(.white)
                                .frame(width: 32, height: 32)
                        }
                }
                .padding(32)
                .contentShape(Rectangle())
                Spacer()
                Button{
                    
                }  label: { Image(systemName:"scope")
                        .foregroundStyle(.white)
                        .background{
                            Circle()
                                .fill(.red)
                                .frame(width: 32, height: 32)
                        }
                }
                .padding(32)
            }
            Spacer()
            VStack{
                HStack(spacing: 8){
                    HStack{
                        //MARK: - profile image
                        if let image = item?.imageUrl {
                            Button{
                                showingProfile.toggle()
                            } label: {
                                WebImage(url: URL(string: image))
//                                Image(systemName: "person")
                                    .resizable()
                                    .foregroundColor(.blue)
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            }.sheet(isPresented: $showingProfile, content: {
                                ProfileView()
                            })
                        }
//                        Image(systemName: "person")
                        
                        VStack(alignment: .leading, spacing: 0){
                            Text(item?.ownerName ?? "")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            HStack(spacing: 8){
                                
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.yellow)
                                Text("4.4 · Рейтинг")
                                    .fontWeight(.regular)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(maxHeight: 32)
                    }
                    Spacer()
                    Button {
                        Task{
                            do {
                                await orderViewModel.selectUsers([item?.ownerUid ?? "", orderItem.id] + [orderItem.recipientId])
                                
                                if let conversation = await orderViewModel.conversationForUsers() {
                                    self.conversation = conversation
                                    self.chatViewModel = ChatViewModel(auth: viewModel, conversation: conversation)
                                    self.orderViewModel.selectedUsers = []
                                }
                            }
                        }
                    } label: {
                        Image(systemName:"message.fill")
                            .foregroundStyle(.black)
                            .background{
                                Circle()
                                    .fill(.white)
                                    .frame(width: 32, height: 32)
                            }
                            .sheet(item: $chatViewModel, onDismiss: {
                                orderViewModel.fetchData()
                            }, content: { chatViewModel in
                                NavigationView {
                                    ChatViewContainer()
                                        .environmentObject(chatViewModel)
                                        .navigationBarItems(trailing: AsyncImage(url: URL(string: item?.imageUrl ?? ""), content: { image in
                                            image
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .clipShape(Circle())
                                        }, placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(Color(.systemGray))
                                        }))
                                        .navigationTitle(item?.ownerName ?? "")
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                            })
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                    
                //   Button{
                //        guard let url = URL(string: "tel://89205707541") else { return }
                //        UIApplication.shared.open(url)
                //    }  label: { Image(systemName:"phone.fill")
                //           .foregroundStyle(.white)
                //           .background{
                //                Circle()
                //                    .fill(.red)
                //                    .frame(width: 32, height: 32)
                //         }
                //  }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(32)
                
                VStack(alignment: .leading, spacing: 24) {
                    ZStack{
                        HStack{
                            Spacer()
                            Rectangle()
                                .foregroundColor((orderItem.isInDelivery) ? .green : .gray)
                                .frame(width: 128, height: 2)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 36, trailing: 0))
                            Rectangle()
                                .foregroundColor((orderItem.isDelivered) ? .green : .gray)
                                .frame(width: 128, height: 2)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 36, trailing: 0))
                            Spacer()
                        }
                        HStack{
                            VStack(spacing: 16){
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                                    .background(
                                        Circle()
                                        //MARK: - orderItem is sent
//                                        orderItem.isSent
                                            .fill((true) ? .green : .gray)
                                            .frame(width: 32, height: 32)
                                    )
                                Text("Отправлен")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                            VStack(spacing: 16){
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                                    .background(
                                        Circle()
                                        //MARK: - orderItem.isInDelivery
                                            .fill((false) ? .green : .gray)
                                            .frame(width: 32, height: 32)
                                    )
                                Text("В доставке")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                            VStack(spacing: 16){
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                                    .background(
                                        Circle()
                                            .fill((orderItem.isDelivered) ? .green : .gray)
                                            .frame(width: 32, height: 32)
                                    )
                                Text("Получен")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    
//                    if (orderItem.ownerId == viewModel.currentUser?.id && !orderItem.isSent) {
//                        Button {
//                            Task{
//                                try await viewModel.updateOrderStatus(type: .isDelivered, value: true, id: orderItem.id, documentId: orderItem.documentId)
//                                orderItem.isDelivered = true
//                            }
//                        } label: {
//                            Text("Подтвердить получение")
//                                .frame(maxWidth: .infinity)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                                .padding(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
//                                .background {
//                                    RoundedRectangle(cornerRadius: 16, style: .circular)
//                                        .frame(maxWidth: .infinity)
//                                        .foregroundColor(.green)
//                                }
//                        }
//                    }
//                    if (orderItem.id == viewModel.currentUser?.id && !orderItem.isInDelivery) && orderItem.isSent {
//                        Button {
//                            Task{
//                                try await viewModel.updateOrderStatus(type: .isDelivered, value: true, id: orderItem.id, documentId: orderItem.documentId)
//                                orderItem.isDelivered = true
//                            }
//                        } label: {
//                            Text("Подтвердить отправление")
//                                .frame(maxWidth: .infinity)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                                .padding(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
//                                .background {
//                                    RoundedRectangle(cornerRadius: 16, style: .circular)
//                                        .frame(maxWidth: .infinity)
//                                        .foregroundColor(.green)
//                                }
//                        }
//                    }
//                    if (orderItem.recipientId == viewModel.currentUser?.id && !orderItem.isDelivered) && orderItem.isSent && orderItem.isInDelivery {
//                        Button {
//                            Task{
//                                try await viewModel.updateOrderStatus(type: .isDelivered, value: true, id: orderItem.id, documentId: orderItem.documentId)
//                                orderItem.isDelivered = true
//                            }
//                        } label: {
//                            Text("Подтвердить получение")
//                                .frame(maxWidth: .infinity)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                                .padding(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
//                                .background {
//                                    RoundedRectangle(cornerRadius: 16, style: .circular)
//                                        .frame(maxWidth: .infinity)
//                                        .foregroundColor(.green)
//                                }
//                        }
//                    }
                    
                    HStack(spacing: 16){
                        if let url = orderItem.image {
                            WebImage(url: url)
//                            Image(systemName; "doc")
                                .resizable()
                                .frame(maxWidth: 80, maxHeight: 80)
                        }
                        
                        if let description = orderItem.description {
                            Text("Описание: \(description)")
                                .fontWeight(.regular)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(32)
                .background(GeometryReader { geometry -> Color in
                    DispatchQueue.main.async {
                        self.whiteScreenHeight = geometry.size.height
                    }
                    return Color.white
                }
                    .cornerRadius(12)
                )
                
            }
            .background(Rectangle()
                .foregroundColor(.black)
                .cornerRadius(12))
            .offset(y: vstackYOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // As the gesture changes, adjust the offset and opacity
                        let verticalMovement = value.translation.height
                        if verticalMovement > 0 { // Only allow downward movement
                            vstackYOffset = verticalMovement
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 50 { // Check if swipe down is enough to dismiss
                            withAnimation {
                                vstackYOffset = whiteScreenHeight
                            }
                        } else {
                            // Reset if not enough swipe down
                            withAnimation {
                                vstackYOffset = 0
                            }
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            orderViewModel.fetchData()
//            viewModel.fetchOrderDescription()
            Task {
            await    viewModel.fetchOrder()
            }
        }
        .navigationBarHidden(true)
        .background {
            mapView
        }
    }
}


//extension UIImage {
//    func resize(to targetSize: CGSize) -> UIImage? {
//        let size = self.size
//
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//
//        // Определяем новое размерное соотношение
//        var newSize: CGSize
//        if widthRatio > heightRatio {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
//        }
//
//        // Начинаем рисование нового изображения
//        let rect = CGRect(origin: .zero, size: newSize)
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        self.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage
//    }
//}
