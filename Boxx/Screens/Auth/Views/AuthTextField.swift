//
//  AuthTextField.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct AuthTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.baseMint.opacity(0.2), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                )
        )
    }
}

struct AuthTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AuthTextField(text: .constant(""), placeholder: "Логин")
            AuthTextField(text: .constant(""), placeholder: "Пароль", isSecure: true)
        }
        .padding()
    }
}



