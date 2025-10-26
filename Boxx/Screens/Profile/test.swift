//
//  test.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 12.12.2023.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import PhotosUI

@available(iOS 17.0, *)
struct test: View {
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var avatar: UIImage? = nil


    @EnvironmentObject var viewModel: AuthViewModel
  
    
    
    
    var body: some View {
        VStack{
            if let user = viewModel.currentUser{
                PhotosPicker(selection: $photosPickerItem){
                    Image (uiImage: avatar ?? UIImage (resource: .person ))
                        .resizable()
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode:.fill)
                        .clipShape(Circle())
                        .font(.system(size: 80))
                    
                }.onChange(of: photosPickerItem) { _, _ in
                    Task{
                        if let photosPickerItem,
                           let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                avatar = image
                                viewModel.saveProfileImage(item: photosPickerItem)
                                
                    }
                }
   
                            Text (user.login)
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            Text (user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(user.email)
                                . font (.footnote)
                                . accentColor(.gray)
                        }    }
                }
            }
        }

}

