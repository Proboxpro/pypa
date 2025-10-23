//
//  File.swift
//  BoxxTests
//
//  Created by Supunme Nanayakkarami on 05.12.2023.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import PhotosUI
@available(iOS 17.0, *)

struct ListingDetail: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    var item: OrderViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var product: UIImage? = nil
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var recipient: String = ""
    @State private var imageUrls: String = ""
    @State private var ownerImageUrl: String = ""
    @State private var text = ""
    @State var search = ""
    var filtereduser: [User] {
        guard !search.isEmpty else { return viewModel.users}
        return viewModel.users.filter{ $0.login.localizedCaseInsensitiveContains (search) }
    }

    
    
    @State private var showingOrder = false
    @State private var showingProfile = false
    
    var body: some View {
        ScrollView{
            ZStack(alignment:.topLeading ){
                WebImage(url: URL(string: item.imageUrls))
                .resizable()
                .frame(maxHeight: 350)


                
                Button{
                    dismiss()
                }  label: { Image(systemName:"chevron.left")
                        .foregroundStyle(.black)
                        .background{
                            Circle()
                                .fill(.white)
                                .frame(width: 32, height: 32)
                        }
                        .padding(50)
                }
            }
            VStack(alignment: .leading, spacing: 8){
                Text("в город  \(item.cityTo)")
                    .font(.title)
                    .fontWeight(.semibold)
                VStack(alignment: .leading){
                    HStack(spacing: 2){
                        Image(systemName: "star.fill")
                        Text("4.4")
                        Text(" - " )
                        
                        Text("23 отзыва")
                            .underline()
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black )
                    Text("из \(item.cityFrom)")
                    
                }                    .font(.caption)
                
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            HStack{
                VStack(alignment: .leading, spacing: 4 ){
                    Text("Размещено пользователем @ \(item.ownerName)")
                        .font(.headline)
                        .frame(width: 250, alignment: .leading )
                    
                    
                        .font(.caption)
                }
                .frame(width: 300, alignment: .leading )
                Spacer()
                Button{
                    showingProfile.toggle()
                } label: {
                    WebImage(url: URL(string: item.imageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                }.sheet(isPresented: $showingProfile, content: {
                    ProfileView()
                })
            }
            .padding()
            
            Divider()
            VStack(alignment: .leading, spacing: 4 ){
                Text("Укажите стоимость описание и добавьте фотографию товара")
                    .font(.headline)
                    .frame(width: 350, alignment: .leading )
                

                .font(.caption)
            }
            HStack(spacing: 10){
                
                VStack(alignment: .center, spacing: 5 ){
                    HStack(alignment: .center){
                        Image(systemName: "magnifyingglass")
                        TextField("Добавить", text: self.$search)
                            .font(.footnote)
                            .fontWeight(.semibold )
                    } .frame(width: 340, height: 44 )
                        .padding(.horizontal)
                        .overlay{RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(Color(.systemGray4))
                        }
                    if self.search != ""{
                        if  self.viewModel.users.filter({$0.login.lowercased().contains(self.search.lowercased())}).count == 0{
                            Text("Такого пользователя нет").foregroundColor(Color.black.opacity(0.5)).padding()
                        }
                        else{
                                ForEach(filtereduser) { item in
                                    CardView(item: item)
                                }
                            }
                    }
                    HStack{
                        
                        HStack{
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .imageScale(.small)
                            TextField("Стоимость", text: $value)
                                .font(.subheadline)
                        }
                        .frame(width: 150, height: 44 )
                        .padding(.horizontal)
                        .overlay{RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(Color(.systemGray4))
                        }
                        HStack{
                            Image(systemName: "note")
                                .imageScale(.small)
                            TextField("Получатель", text: $recipient)
                                .font(.subheadline)
                        }
                        .frame(width: 150, height: 44 )
                        .padding(.horizontal)
                        .overlay{RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(Color(.systemGray4))
                        }
                    }
                    
                
                    Spacer()
                    PhotosPicker(selection: $photosPickerItem){
                        Image (uiImage: product ?? UIImage (resource: .plus ))
                            .resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode:.fill)
                            .clipShape(Rectangle())
                            .font(.system(size: 80))
                    }.onChange(of: photosPickerItem) { _, _ in
                        Task{
                            if let photosPickerItem,
                               let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    product = image
                                    viewModel.saveOrderImage(item: photosPickerItem)
                                    self.product
                                }
                            }
                        }
                    }
                }
                .frame(width: 300, alignment: .leading )
                Spacer()
            }
            .padding()
            Divider()

        }  .toolbar(.hidden, for:  .tabBar)
            .edgesIgnoringSafeArea(.all)
        .padding(.bottom, 70)
        .overlay(alignment: .bottom) {
            VStack{
                Divider()
                    .padding(.bottom)
                HStack{
                    VStack(alignment: .leading){
                        Text(item.pricePerKillo)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Цена за кг.")
                            .font(.footnote)
                        Text(item.startdate)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .underline()
                    }
                    Spacer()
                    Button{ Task{
                        viewModel.createNewOrder(senderName: viewModel.currentUser?.login ?? "", senderUid: viewModel.currentUser?.id ?? "", ownerUid: item.ownerUid, ownerName: item.ownerName, description: description, value: value, cityFrom: item.cityFrom, cityTo: item.cityTo, imageUrls: item.imageUrls, recipient: recipient, ownerImageUrl: item.imageUrl, text: text)
                        do{
                            showingOrder.toggle()
                        }
                    }
                    } label: {
                        Text ("Отправить")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 140, height: 40 )
                            .background(.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .sheet(isPresented: $showingOrder, content: {
                                ChatView(senderName: viewModel.currentUser?.login ?? "", senderUid: viewModel.currentUser?.id ?? "",ownerUid: item.ownerUid, ownerName: item.ownerName, description:description, value:value, cityFrom:item.cityFrom, cityTo: item.cityTo, imageUrls:item.imageUrls, recipient:recipient, ownerImageUrl:item.imageUrl)
                            })
                    }
                } .padding(.horizontal, 32)
            } .background(.white)
        }
        
    }
    
}
