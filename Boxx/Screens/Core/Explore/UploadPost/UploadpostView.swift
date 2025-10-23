//
//  UploadpostView.swift
//  Boxx
//
//  Created by Nikita Larin on 16.11.2023.
//

import SwiftUI

struct UploadpostView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
//        VStack{
//            HStack{
                VStack {
//                    Text("Добавьте свою поездку уже сегодня")
//                    Divider()
//            Spacer()
                    SearchButton()
                } 
                .navigationTitle("Вы уезжаете?")
//            }
//        }
//        .onDisappear {
//            viewModel.myOrder()
//        }
    }
    
}

struct UploadpostView_Previews: PreviewProvider {
    static var previews: some View {
        UploadpostView()
    }
}
