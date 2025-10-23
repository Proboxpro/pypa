//
//  CreateNewMessageView.swift
//  Boxx
//
//  Created by Nikita Larin on 11.12.2023.
//

import SwiftUI

struct CreateNewMessageView: View {
    @EnvironmentObject var viewModel: AuthViewModel
 
    var body: some View {
        NavigationView
        {
            ScrollView {
                ForEach (0..<10) { num in
                    Text ("New user")
                }.navigationTitle("New Message")
            }
        }
    }
}

#Preview {
    CreateNewMessageView()
}
