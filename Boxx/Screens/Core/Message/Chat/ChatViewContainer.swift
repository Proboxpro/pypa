//
//  ChatView.swift
//  Boxx
//
//  Created by Максим Алексеев  on 28.02.2024.
//

import SwiftUI
import ExyteChat

struct ChatViewContainer: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ChatView(messages: viewModel.messages) { draft in
            viewModel.sendMessage(draft)
        } 
        .interactiveDismissDisabled()
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }, label: {
            Text("Back")
        }))
    }
}
//
//#Preview {
//    ChatViewContainer()
//        .environmentObject(ChatViewModel())
//}
