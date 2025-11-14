//
//  OrderRow2.swift
//  Boxx
//
//  Created by Sasha Soldatov on 12.11.2025.
//

import SwiftUI
import Nuke
import NukeUI

struct OrderRow2: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    var width: CGFloat
    var order: OrderDescriptionItem
    @State private var sender: User?
    @State private var ownerDealStatus: OwnerDealStatus
    @State private var isProcessingOwnerAction = false
    
    init(width: CGFloat, order: OrderDescriptionItem) {
        self.width = width
        self.order = order
        _ownerDealStatus = State(initialValue: order.ownerDealStatus)
    }
    
    var body: some View {
        ZStack {
            backgroundImage
                .frame(width: width, height: 170)
                .clipped()
                .cornerRadius(12)
            
            LinearGradient(
                colors: isDealDeclinedOrExpired 
                    ? [.red.opacity(0.0), .red.opacity(0.7)] 
                    : [.black.opacity(0.0), .black.opacity(0.6)], 
                startPoint: .top, 
                endPoint: .bottom
            )
            .cornerRadius(12)
            .frame(width: width, height: 170)
            
            VStack(alignment: .center, spacing: 0) {
                VStack(alignment: .center) {
                    if let fullname = sender?.fullname, !fullname.isEmpty {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.green)
                                .frame(height: 25)
                            Text(fullname)
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                        .fixedSize()
                    }
                    
                    Spacer(minLength: 10)
                    if isDealDeclinedOrExpired {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.red)
                                .frame(height: 25)
                            Text("Сделка не состоялась 😒")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                        .fixedSize()
                    }
                   
                    if shouldShowOwnerActions {
                        ownerActionButtons
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                Spacer(minLength: 0)
                
                VStack(alignment: .leading, spacing: 6) {
                    if let startDateText = orderStartDateText {
                        Text(startDateText)
                            .foregroundColor(.white.opacity(0.85))
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                    }
                    
                    HStack {
                        if let price = order.price {
                            Text(String(Int(price)) + " ₽")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Text("\(order.cityFrom) - \(order.cityTo)")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(12)
            }
        }
        .frame(width: width, height: 170)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .onAppear {
            Task {
                await loadUsers()
            }
        }
        .onChange(of: order.ownerDealStatus) { newValue in
            ownerDealStatus = newValue
        }
        .onChange(of: order.recipientDealStatus) { newValue in
            // Обновляем UI при изменении статуса recipient
        }
    }
    
    private func loadUsers() async {
        let user = await viewModel.fetchUser(by: order.id)
        await MainActor.run {
            sender = user
        }
    }
    
    private var relatedListing: ListingItem? {
        viewModel.orders.first(where: { $0.id == order.announcementId } )
    }
    
    private var orderStartDateText: String? {
        guard let starDate = relatedListing?.startdate else { return nil }
        return starDate
    }
    
    private var backgroundImage: some View {
        let listingImageURL = viewModel.orders.first(where: { $0.id == order.announcementId })?.imageUrls ?? ""
        let urlString = listingImageURL.isEmpty ? (order.image?.absoluteString ?? "") : listingImageURL
        
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

private extension OrderRow2 {
    private var isDealDeclinedOrExpired: Bool {
        order.ownerDealStatus == .declined || 
        order.recipientDealStatus == .declined || 
        order.recipientDealStatus == .expired
    }
    
    private var shouldShowOwnerActions: Bool {
        guard let currentUserId = viewModel.currentUser?.id else { return false }
        return currentUserId == order.ownerId && ownerDealStatus == .pending
    }
    
    private var ownerActionButtons: some View {
        HStack(spacing: 100) {
            Button {
                Task {
                    await acceptDeal()
                }
            } label: {
                ZStack{
                    Text("V")
                        .font(.system(size: 55))
                        .background{
                            Circle().fill(Color.baseMint.opacity(0.5))
                                .frame(width: 75, height: 75)
                        }
                        .foregroundStyle(Color.white)
                }
//                Text("Принять")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(.baseMint)
//                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(isProcessingOwnerAction)

            
            Button {
                Task {
                    await declineDeal()
                }
            } label: {
                ZStack{
                    Text("X")
                        .font(.system(size: 55))
                        .background{
                            Circle().fill(Color.red.opacity(0.5))
                                .frame(width: 75, height: 75)
                        }
                        .foregroundStyle(Color.white)
                }
//                Text("Отклонить")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(Color.red)
//                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .disabled(isProcessingOwnerAction)
        }
        .padding(.vertical, 2)
        .opacity(isProcessingOwnerAction ? 0.7 : 1)
    }
    
    private func acceptDeal() async {
        await handleOwnerDecision(targetStatus: .accepted)
    }
    
    private func declineDeal() async {
        await handleOwnerDecision(targetStatus: .declined)
    }
    
    private func handleOwnerDecision(targetStatus: OwnerDealStatus) async {
        await MainActor.run {
            isProcessingOwnerAction = true
        }
        
        defer {
            Task { @MainActor in
                isProcessingOwnerAction = false
            }
        }
        
        do {
            try await viewModel.updateOwnerDealStatus(
                status: targetStatus,
                orderId: order.id,
                documentId: order.documentId
            )
            
            await MainActor.run {
                updateLocalOwnerDealStatus(to: targetStatus)
            }
        } catch {
            print("Ошибка обновления статуса сделки владельца: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func updateLocalOwnerDealStatus(to status: OwnerDealStatus) {
        ownerDealStatus = status
        
        if let index = viewModel.ownerOrderDescription.firstIndex(where: { $0.id == order.id && $0.documentId == order.documentId }) {
            viewModel.ownerOrderDescription[index].ownerDealStatus = status
        }
        
        if let index = viewModel.orderDescription.firstIndex(where: { $0.id == order.id && $0.documentId == order.documentId }) {
            viewModel.orderDescription[index].ownerDealStatus = status
        }
        
        if let index = viewModel.recipientOrderDescription.firstIndex(where: { $0.id == order.id && $0.documentId == order.documentId }) {
            viewModel.recipientOrderDescription[index].ownerDealStatus = status
        }
    }
}
