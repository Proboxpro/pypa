//
//  ProfileView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 18.12.2023.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var userToShow: User? // Сделаем переменную @State
    
    var ownerUid: String?
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let safeArea = geometry.safeAreaInsets
            
            if let user = userToShow { // Проверяем, есть ли пользователь для отображения
                UserProfileHome(size: size, safeArea: safeArea, user: user)
                    .ignoresSafeArea(.all, edges: .top)
            } else {
                ProgressView()// Отображаем индикатор загрузки, пока пользователь загружается
            }
        }
        .onAppear {
            viewModel.fetchUserToShow(id: ownerUid ?? viewModel.currentUser!.id) { result in // Вызываем fetchUserToShow с блоком завершения
                switch result {
                case .success(let user):
                    userToShow = user // Сохраняем полученного пользователя в userToShow
                case .failure(let error):
                    print("Failed to fetch user: \(error.localizedDescription)")
                    // Обработка ошибки, если не удалось загрузить пользователя
                }
            }
        }
    }
    
}
