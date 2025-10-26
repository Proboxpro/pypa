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
            VStack(spacing: 30) {
                NavigationLink("Уезжаете") {
                    YouAreSendingView()
                }
                
                NavigationLink("Отправляете") {
                    YouAreLeavingView()
                }
            }
        }
    }
}

#Preview {
    DeparturesView()
}
