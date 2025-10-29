//
//  AutocompleteTextField.swift
//  Boxx
//
//  Created by namerei on 29.10.2025.
//

import SwiftUI

struct AutocompleteTextField: View {
    var placeholder: String
    
//    @FocusState var focus: Bool
    
    @Binding var textToSave: String
    @State var text: String = ""
    
    var suggestions : [String]
    @State private var selected = false

    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
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
                                textToSave = text
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
//        .focused($focus)
//        .onChange(of: focus) { newValue in
//            if newValue == false && !selected {
//                text = ""
//            }
//        }
        .onChange(of: text) { newValue in
            if newValue == "" {
                selected = false
            }
        }
        .animation(.bouncy, value: text.isEmpty)
        .allowsHitTesting(true)
    }
}

//#Preview {
//    AutocompleteTextField()
//}
