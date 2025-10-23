//
//  MessageField.swift
//  Boxx
//
//  Created by Nikita Larin on 22.12.2023.
//

import SwiftUI

struct MessageField: View {
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




    @State private var message = ""

    var body: some View {
        HStack {
            // Custom text field created below
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
                .frame(height: 52)
                .disableAutocorrection(true)
            Button {
                viewModel.createNewOrder(senderName: senderName, senderUid: senderUid, ownerUid: ownerUid, ownerName: ownerName, description: description, value: value, cityFrom: cityFrom, cityTo: cityTo, imageUrls: imageUrls, recipient: recipient, ownerImageUrl: ownerImageUrl, text: message)
                message = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("Peach"))
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(50)
        .padding()
    }
}



struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            // If text is empty, show the placeholder on top of the TextField
            if text.isEmpty {
                placeholder
                .opacity(0.5)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
