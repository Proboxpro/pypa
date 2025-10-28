//
//  YouAreLeavingView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

let screenWidth: CGFloat = UIScreen.main.bounds.width

struct YouAreLeavingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            ZStack {
                BackTopLeftButtonView()
                AskQuestionButton()
            }
            
            VStack(spacing: 10) {
                Text("search")
                
                ScrollView() {
                    ForEach(viewModel.myorder) { item in
                        NavigationLink(destination: CreateDealView(item: item).navigationBarBackButtonHidden(true)) {
                            TripCardView(width: screenWidth - 20, item: item)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
//            .padding(.horizontal, 16)
            
            Spacer()
//            Text("You are leaving")
//            Spacer()
        }
    }
}

