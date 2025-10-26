//
//  Login.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("PYPA")
                    .font(.system(size: 52, weight: .heavy))
                    .foregroundColor(.baseMint)
                    .padding(.vertical, 40)
                
                VStack(spacing: 24){
                    AuthTextField(text: $email, placeholder: "Email", keyboard: .emailAddress)
                    AuthTextField(text: $password, placeholder: "Пароль", isSecure: true)
                    
                    AuthButton(title: "Войти", style: .filled) {
                        Task.init(operation: {
                            try await viewModel.signIn(withEmail: email, password: password)
                        })
                    }
                }
                .padding(30)
                .offset(y: 30)
                
                
                Spacer()
                
                NavigationLink{ RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text ("Нет аккаунта?")
                        Text ("Регистрация")
                            .fontWeight(.bold)
                    }
                    .font (.system(size: 14))
                    .foregroundColor(.baseMint)
                }

            }
        }
    }
}

extension Login : AuthenticationFormProtocol{
    var formIsValid: Bool{
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
