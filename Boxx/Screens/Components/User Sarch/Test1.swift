//
//  Test1.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 02.01.2024.
//

import SwiftUI
import Firebase



struct Test1: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                HStack(alignment: .bottom){
                    UserSearch()
                }
            }
        }
    }
        
        }
    

        struct Test1_Previews: PreviewProvider {
            static var previews: some View {
                Search()
            }
        }

        struct UserSearch : View {
            @EnvironmentObject var viewModel: AuthViewModel
            @State var search = ""
            var filtereduser: [User] {
                guard !search.isEmpty else { return viewModel.users}
                return viewModel.users.filter{ $0.login.localizedCaseInsensitiveContains (search) }
            }
            var body : some View{
                VStack(alignment: .leading){
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
                            VStack{
                                ForEach(filtereduser) { item in
                                    CardView(user: item)
                                }
                            }
                        }
                    }
                }.background(Color.red)
                .scaledToFit()
                .padding()
                
            }
        }




