//
//  ChatMessageCell.swift
//  Boxx
//
//  Created by Nikita Larin on 25.12.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatMessageCell: View {
    let isFromCurrentUser: Bool
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        HStack{
            if isFromCurrentUser {
               Spacer()
                Text("This is a test message for now")
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment:.trailing)
            } else {
                HStack(alignment:.bottom, spacing: 8) {
                    WebImage(url: URL(string: viewModel.currentUser?.imageUrl ?? ""))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                        .clipShape (Capsule())

                    
                    Text("This is a test message for now")
                        .font (. subheadline)
                        .padding(12)
                        .background (Color(.systemGray5))
                        .foregroundColor (.black)
                        .clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment:.leading)
                    
                        Spacer()
                }
            }
        }.padding(.horizontal, 8)
    }
}

struct ChatMessageCe11_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageCell (isFromCurrentUser: false)
    }
    }
