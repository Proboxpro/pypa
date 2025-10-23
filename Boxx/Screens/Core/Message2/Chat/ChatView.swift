//
//  ChatView.swift
//  Boxx
//
//  Created by Nikita Larin on 25.12.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State  var senderName : String
    @State  var senderUid : String
    @State  var ownerUid : String
    @State  var ownerName : String
    @State  var description : String
    @State  var value : String
    @State  var cityFrom : String
    @State  var cityTo : String
    @State  var imageUrls : String
    @State  var recipient : String
    @State  var ownerImageUrl : String
    @State  var message = ""

    
    var body: some View {
        VStack{
            ScrollView{
                VStack{
                    WebImage(url: URL(string: viewModel.order?.ownerImageUrl ?? ""))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    
                    VStack(spacing: 4){
                        Text ("Bruce Wayne")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text ("Messenger")
                            .font (.footnote)
                            .foregroundColor(.gray)
                    }
                }
                
                ForEach(0...15, id: \.self) { message in
                    ChatMessageCell(isFromCurrentUser: Bool.random())
                }
            }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("Message…..", text: $message, axis: .vertical)
                    .padding (12)
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape (Capsule())
                    .font (.subheadline)
                Button {
                    viewModel.createNewOrder(senderName: senderName, senderUid: senderUid, ownerUid: ownerUid, ownerName: ownerName, description: description, value: value, cityFrom: cityFrom, cityTo: cityTo, imageUrls: imageUrls, recipient: recipient, ownerImageUrl: ownerImageUrl, text: message)
                    message = ""

                } label:{
                    Text("Send")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}


