//
//  PersonalInfoView.swift
//  Boxx
//
//  Created by Assistant on 2024.
//


import SwiftUI
import SDWebImageSwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с кнопкой назад
            HStack {
                Button { dismiss() } label: {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                Text("Информация")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Невидимая кнопка для центрирования заголовка
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .navigationBarBackButtonHidden()
                
                Spacer()
                
            // Аватарка
//            if let imageUrl = viewModel.currentUser?.imageUrl, !imageUrl.isEmpty {
//                WebImage(url: URL(string: imageUrl))
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 160, height: 160)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .shadow(color: .gray, radius: 2, x: 1, y: 2)
//            } else {
//                Image(systemName: "person.circle.fill")
//                    .font(.system(size: 160))
//                    .foregroundColor(.gray)
//            }
            AvatarImageView(width: 160, height: 160)
                
            Spacer()
            
            // Карточка с информацией
            VStack(spacing: 0) {
                // Имя пользователя
                HStack {
//                    StrokeText(name: (viewModel.currentUser!.fullname.isEmpty ?  "Имя Пользователя" : viewModel.currentUser?.fullname)!)
                    StrokeText(name: (viewModel.currentUser!.login.isEmpty ?  "login" : viewModel.currentUser?.login)!)
                    
                    Spacer()
                    
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 50, height: 50)
                        .offset(y: -5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                    
                    // Поля информации
                    VStack(spacing: 0) {
                        // Дата рождения
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Дата Рождения")
                                .font(.caption)
                                .foregroundColor(.black)
                                .fontWeight(.medium)

                            Text("05 Ноября 1993")
                                .font(.body)
                                .foregroundColor(.teal)
                                .fontWeight(.semibold)
//                                .underline()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 20)
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Почта")
                                .font(.caption)
                                .foregroundColor(.black)
                                .fontWeight(.medium)

                            Text(viewModel.currentUser?.email ?? "warren.buff@invest.ai")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.teal)
//                                .underline()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 20)
                        
                        // Номер телефона
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Номер телефона")
                                .font(.caption)
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                            
                            Text(viewModel.currentUser?.number ?? "-")
                                .font(.body)
                               .fontWeight(.semibold)
                                .foregroundColor(.teal)
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
            }
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 1)
            )
            .shadow(color: .gray.opacity(0.5), radius: 5, x: 1, y: 2)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
    
}

#Preview {
    PersonalInfoView()
        .environmentObject(AuthViewModel())
}

struct AvatarImageView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var width: Double
    var height: Double
    
    var body: some View {
        if let imageUrl = viewModel.currentUser?.imageUrl, !imageUrl.isEmpty {
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .gray, radius: 2, x: 1, y: 2)
        } else {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 160))
                .foregroundColor(.gray)
        }
    }
}
