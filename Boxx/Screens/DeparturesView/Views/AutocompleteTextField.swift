//
//  AutocompleteTextField.swift
//  Boxx
//
//  Created by namerei on 29.10.2025.
//

import SwiftUI

struct AutocompleteTextField: View {
    @State private var text = ""
//    @State private var suggestions = ["Москва", "Мюнхен", "Милан", "Мадрид", "Минск"]
    @State private var suggestions = ["V1", "V2", "V$", "Мадрид", "Минск"]

    var body: some View {
//        ZStack(alignment: .topLeading) {
        VStack {
            TextField("Куда", text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
                .padding(.horizontal)
                .zIndex(1)
            
            if !text.isEmpty {
//                let filtered = suggestions.prefix(1)
                let filtered = suggestions.filter { $0.lowercased().contains(text.lowercased()) }.prefix(1)
                if !filtered.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filtered, id: \.self) { item in
                            Button {
                                text = item
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            } label: {
                                Text(item)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                            }
//                            Divider()
                        }
                    }
//                    .transition(.opacity.combined(with: .move(edge: .bottom)))
//                    .opacity(filtered.isEmpty ? 1 : 0)
                    .animation(.default, value: text.isEmpty)
//                        .hidden(!text.isEmpty)
//                    .background(Color.green)
//                    .frame(height: 54 * 1)
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                            .background(Color.white)
//                            .cornerRadius(10).padding(.horizontal)
//                    )
                    .padding(.horizontal, 25)
//                    .padding(.top, 54)
//                    .overlay(RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                        .background(Color.white)
//                        .cornerRadius(10).padding(.horizontal))
                    //                    .shadow(radius: 3)
//                    .zIndex(1000)
                }
//                    .frame(height: 54 * 4)
            }
        }
//        .frame(height: 54 * 2)
        .background(Color.green)
        .allowsHitTesting(true)
    }
}

#Preview {
    AutocompleteTextField()
}
