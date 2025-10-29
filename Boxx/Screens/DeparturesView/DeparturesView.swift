//
//  DeparturesView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct DeparturesView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        
        NavigationStack {
            VStack {
                BaseTitle("Выберите вариант")
                    .padding(.top)
                
                Spacer()
                
                VStack(spacing: 10) {
                    NavigationLink {
                        YouAreLeavingView()
                            .ignoresSafeArea(.keyboard)
                    } label: {
                        PypLabelRightImage(text: "Уезжаете", image: Image("car_frong"))
                    }
                    
                    NavigationLink {
                        YouAreSendingView()
                    } label: {
                        PypLabelRightImage(text: "Отправляете", image: Image("box_with_clock"))
                    }
                }
                .offset(y: -30)
                
                Spacer()
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    DeparturesView()
}
