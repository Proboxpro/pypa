//
//  OrderView.swift
//  Boxx
//
//  Created by Nikita Larin on 20.12.2023.
//

import SwiftUI
import Firebase

struct OrderView: View {

    @EnvironmentObject var viewModel: AuthViewModel
    let senderName : String
    let senderUid : String
    let ownerUid : String
    let ownerName : String
    let description : String
    let value : String
    let cityFrom : String
    let cityTo : String
    let imageUrls : String
    let recipient : String
    let ownerImageUrl : String

    var body: some View {
        VStack {
            VStack {
                TitleRow()
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(viewModel.messages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight]) // Custom cornerRadius modifier added in Extensions file
                    .onChange(of: viewModel.lastMessageId) { id in
                        // When the lastMessageId changes, scroll to the bottom of the conversation
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color("Peach"))
            
            MessageField(senderName: senderName, senderUid: senderUid, ownerUid: ownerUid, ownerName: ownerName, description: description, value: value, cityFrom: cityFrom, cityTo: cityTo, imageUrls: imageUrls, recipient: recipient, ownerImageUrl: ownerImageUrl)
                .environmentObject(viewModel)
        }
    }
}

