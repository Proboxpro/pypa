//
//  YouAreLeavingView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct YouAreLeavingView: View {
    
    var body: some View {
        VStack {
            ZStack {
                BackTopLeftButtonView()
                AskQuestionButton()
            }
            
            Spacer()
            Text("You are leaving")
            Spacer()
        }
    }
}

