//
//  ConversationRowView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 17.11.2023.
//

import SwiftUI
import ExyteChat

struct OrderRow: View {
    var isCompleted: Bool
    var orderImageURL: URL?
    var profileName: String
    var orderDescription: String
    var date: Date
    
    var body: some View {
        HStack(alignment: .top, spacing: 15){
           
             Image(systemName: "shippingbox.fill")
                 .resizable()
                 .frame(width: 64, height: 64)
                 .aspectRatio(contentMode: .fill)
                 .foregroundColor(Color(.systemGray))
                 
            VStack(alignment: .leading, spacing: 4){
                Text(profileName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(orderDescription)
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
            }
            
            Spacer()
            HStack {
                Text(date.timeAgoDisplay())
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .gray : .green)
                    .lineLimit(2)
                Image(systemName: "chevron.right")
                    .foregroundColor(isCompleted ? .gray : .green)
            }
        }
        .background(.clear)
        .padding()
        .frame(height: 72)
    }
}

//struct InboxRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationRowView(conversationTitle: "Вася Пупкин", latestMessageText: "Привет спишь?)", formattedDateString: "Yesterday")
//    }
//}
