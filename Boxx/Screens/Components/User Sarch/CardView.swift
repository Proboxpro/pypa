//
//  CardView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 29.12.2023.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct CardView: View {
    var user: User
    @EnvironmentObject var viewModel: AuthViewModel
 
    var body: some View {
        VStack(alignment: .leading){
                HStack(spacing: 15){
                    WebImage(url: URL(string: user.imageUrl ?? ""))
                        .resizable()
                        .frame (width: 35, height: 35)
                        .clipShape(Circle())
                    Text(user.login)
                        .font(.subheadline)
                        .fontWeight(.semibold )
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .scaledToFit()
                }
                .frame (width: 150, height: 44)
                .scaledToFill()
            }  .padding(.horizontal)
                .overlay{RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1.0)
                        .foregroundStyle(Color(.systemGray4))
        }
    }
    }


