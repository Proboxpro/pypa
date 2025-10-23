//
//  StartView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 24)
                
                Text("PYPA")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(Color.baseMint)
                    .padding(.top, 24)
                
                VStack(spacing: 8) {
                    Text("Путешествуй и\nторгуй с нами.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Мы совершаем сделки безопасно и\nпомогаем зарабатывать путешественникам")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.8))
                }
                .offset(y: 20)
//                .padding()
//                .padding(.top, 1)
                
                Spacer()
                
                NavigationLink(destination: AuthContainerView().navigationBarBackButtonHidden(true)) {
                    AuthButtonLabel(title: "Войти", style: .filled)
                }
                
                NavigationLink(destination: AuthContainerView(initialTab: .register).navigationBarBackButtonHidden(true)) {
                    Text("Зарегестрироваться")
                        .foregroundStyle(Color.baseMint)
                        .padding(.horizontal, 30)
                        .padding(.top, 12)
                }
                
                Spacer(minLength: 32)
            }
            .padding(.horizontal, 30)
            
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}


