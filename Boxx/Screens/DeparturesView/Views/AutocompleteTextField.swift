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
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
//                .padding(.horizontal)
//                .zIndex(1)
            
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
                        }
                    }
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//                    .padding(.horizontal, 25)
                }
            }
        }
        .animation(.bouncy, value: text.isEmpty)
//        .background(Color.green)
        .allowsHitTesting(true)
    }
}

#Preview {
    AutocompleteTextField()
}
