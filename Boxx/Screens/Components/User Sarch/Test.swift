//
//  Test.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 30.12.2023.
//

import SwiftUI
import Firebase

struct Test: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var search = ""
    var filtereduser: [User] {
        guard !search.isEmpty else { return viewModel.users}
        return viewModel.users.filter{ $0.login.localizedCaseInsensitiveContains (search) }
    }
    var body: some View {
        HStack{
            NavigationView{
                ScrollView{
                    ForEach(filtereduser) { item in
                        CardView(user: item)
                    }
                }.searchable (text: $search)
            }.onAppear{
//                viewModel.users
            }
        }      
        .frame(width: 220, height: 200)
        .scaledToFit()

    }
}


