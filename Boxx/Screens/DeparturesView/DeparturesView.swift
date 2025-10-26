//
//  DeparturesView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct DeparturesView: View {
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 30) {
                NavigationLink("YouAreLeavingView") {
                    YouAreLeavingView()
                }
                
                NavigationLink("YouAreSendingView") {
                    YouAreSendingView()
                }
            }
        }
    }
}

#Preview {
    DeparturesView()
}
