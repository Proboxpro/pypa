//
//  AutocompleteTextField.swift
//  Boxx
//
//  Created by namerei on 29.10.2025.
//

import SwiftUI

struct AutocompleteTextField: View {
    @State private var text = ""
    @State private var suggestions = ["V1", "V2", "V$", "Мадрид", "Минск"]
    @State private var selected = false

    var body: some View {
        VStack {
            TextField("Куда", text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )

            if !text.isEmpty && !selected {
                let filtered = suggestions.filter { $0.lowercased().contains(text.lowercased()) }.prefix(1)
                if !filtered.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filtered, id: \.self) { item in
                            Button {
                                text = item
                                selected = true
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            } label: {
                                Text(item)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: text) { newValue in
            if newValue == "" {
                selected = false
            }
        }
        .animation(.bouncy, value: text.isEmpty)
        .allowsHitTesting(true)
    }
}

#Preview {
    AutocompleteTextField()
}
