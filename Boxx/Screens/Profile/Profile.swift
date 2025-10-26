//
//  Profile.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI
import PhotosUI
import Firebase
import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI
@available(iOS 17.0, *)

@MainActor
struct Profile: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var avatar: UIImage? = nil
    @State private var isUploading = false
    @State var imageURL: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок экрана
                HStack {
                    Text("Профиль")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Основной контент
                VStack(spacing: 30) {
                    photoPicker
//                    ProfilePhotoPickerView(
//                        currentUserImageUrl: $imageURL,
//                        saveProfileImage: { data in
//                            await viewModel.saveProfileImage(item: data)
//                        }
//                    )
                    
                    VStack(spacing: 10) {
//                        Text((viewModel.currentUser!.login.isEmpty ?  "login" : viewModel.currentUser?.login) ?? "")
                        Text(viewModel.currentUser?.login ?? "")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: UIScreen.main.bounds.width - 50)
                        
                        Text("Статус")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    VStack(spacing: 22) {
                        NavigationLink(destination: PersonalInfoView()) {
                            rowNavigationLink(image: "weui_contacts-filled", description: "Личная информация")
                        }
                        
                        NavigationLink(destination: SumSubStatusView()) {
                            rowNavigationLink(image: "funding", description: "SumSub статус")
                        }
                        
                        NavigationLink(destination: GradesView()) {
                            rowNavigationLink(image: "material-symbols-light_account-balance-wallet", description: "Грейды")
                        }
                        
                        
                        Button(action: { viewModel.showExitFromAccAlert.toggle() }){
                            Text("Выход")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.red)
                        }
                        .offset(y: 90)
                        
                    }
                    .padding(.horizontal, 20)
                }
                .offset(y: -50)
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
        .onChange(of: viewModel.currentUser) { oldValue, newValue in
            imageURL = viewModel.currentUser?.imageUrl
        }
        .onAppear {
            imageURL = viewModel.currentUser?.imageUrl
        }
    }
    
//    @ViewBuilder
    @ViewBuilder
    var photoPicker: some View {
        ZStack {
            PhotosPicker(selection: $photosPickerItem) {
                if let imageUrl = viewModel.currentUser?.imageUrl, !imageUrl.isEmpty {
                    WebImage(url: URL(string: imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Image(systemName: "photo.badge.plus.fill")
                        .font(.system(size: 140))
                        .foregroundColor(.gray)
                }
            }
            .shadow(color: .gray.opacity(0.8), radius: 3, x: 2, y: 2)

            if isUploading {
                Color.black.opacity(0.3)
                    .frame(width: 130, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .onChange(of: photosPickerItem) { newItem in
            guard let newItem else { return }

            Task {
                isUploading = true
                defer { isUploading = false }

                // Загружаем локально выбранное фото
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {

                    let resizedImage = image.resize(to: CGSize(width: 120, height: 120))
                    let compressionQuality: CGFloat = 0.1
                    if let compressedImage = resizedImage?.compressed(to: compressionQuality) {
                        // Показываем локально выбранное фото сразу
                        avatar = compressedImage

                        // Загружаем на Firebase
                        if let compressedData = compressedImage.jpegData(compressionQuality: compressionQuality) {
                            await viewModel.saveProfileImage(item: compressedData)
                        }

                        // После успешной загрузки обновляем avatar из Firebase
                        if let imageUrlString = viewModel.currentUser?.imageUrl,
                           let imageUrl = URL(string: imageUrlString) {
                            do {
                                let (data, _) = try await URLSession.shared.data(from: imageUrl)
                                if let downloadedImage = UIImage(data: data) {
                                    // Обновляем avatar на серверный вариант
                                    avatar = downloadedImage
                                }
                            } catch {
                                print("Ошибка загрузки аватара из Firebase: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func rowNavigationLink(image: String, description: String)-> some View {
        HStack {
            Image(image)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.black)
                .padding(.trailing, 10)
            Text(description)
                .foregroundColor(.black.opacity(0.9))
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
//        .padding(.leading, 15)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.7), lineWidth: 0.9)
        )
    }
    
}


//import SwiftUI
//import PhotosUI
//import Nuke
//import NukeUI
//
//
////@MainActor
//struct ProfilePhotoPickerView: View {
//    @Binding var currentUserImageUrl: String?
//    var saveProfileImage: (Data) async -> Void
//
//    @State private var photosPickerItem: PhotosPickerItem?
//    @State private var avatar: UIImage? = nil
//    @State private var isUploading: Bool = false
//
//    var body: some View {
//        ZStack {
//            PhotosPicker(selection: $photosPickerItem) {
//                Group {
//                    if let urlString = currentUserImageUrl,
//                              let url = URL(string: urlString) {
//                        // Используем LazyImage напрямую
////                        LazyImage(url: url)
////                            .scaledToFit()
//                        LazyImage(request: ImageRequest(
//                            url: URL(string: urlString),
//                            processors: [
//                                ImageProcessors.Resize(
//                                    size: CGSize(width: 140, height: 140),
//                                    contentMode: .aspectFill
//                                )
//                            ]
//                        ))
//                        
//                    } else {
//                        Image(systemName: "photo.badge.plus.fill")
//                            .font(.system(size: 140))
//                            .foregroundColor(.gray)
//                    }
//                }
//                .frame(width: 130, height: 140)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .shadow(color: .gray.opacity(0.8), radius: 3, x: 2, y: 2)
//            }
//
//            if isUploading {
//                Color.black.opacity(0.3)
//                    .frame(width: 130, height: 140)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//            }
//        }
//        .onChange(of: photosPickerItem) { newItem in
//            guard let newItem else { return }
//
//            Task {
//                isUploading = true
//                defer { isUploading = false }
//
//                if let data = try? await newItem.loadTransferable(type: Data.self),
//                   let image = UIImage(data: data) {
//
//                    let resizedImage = image.resize(to: CGSize(width: 120, height: 120))
//                    let compressionQuality: CGFloat = 0.1
//                    if let compressedImage = resizedImage?.compressed(to: compressionQuality),
//                       let compressedData = compressedImage.jpegData(compressionQuality: compressionQuality) {
//
//                        avatar = compressedImage
//                        await saveProfileImage(compressedData)
//
//                        // Подгружаем из Firebase асинхронно
//                        if let urlString = currentUserImageUrl,
//                           let url = URL(string: urlString) {
//                            do {
//                                let (data, _) = try await URLSession.shared.data(from: url)
//                                if let downloadedImage = UIImage(data: data) {
//                                    avatar = downloadedImage
//                                }
//                            } catch {
//                                print("Ошибка загрузки аватара из Firebase: \(error)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
