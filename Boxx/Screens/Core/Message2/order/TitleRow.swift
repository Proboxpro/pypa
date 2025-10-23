//
//  TitleRow.swift
//  Boxx
//
//  Created by Nikita Larin on 22.12.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct TitleRow: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
 
    var body: some View {
            HStack(spacing: 20) {
                WebImage(url: URL(string: viewModel.order?.ownerImageUrl ?? ""))
                    .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
                
                
                VStack(alignment: .leading) {
                    Text(viewModel.order?.ownerName ?? "")
                        .font(.title).bold()
                    
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "plus")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(50)
            }
            .padding()
        }
    }

struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        TitleRow()
            .background(Color("Peach"))
    }
}
