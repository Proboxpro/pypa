//
//  Buttons.swift
//  Boxx
//
//  Created by namerei on 29.10.2025.
//

import SwiftUI

struct PypButtonRightImage: View {
    let text: String
    let image: Image?      // можно передать nil, если не нужен
    let action: () -> Void
    var backgroundColor: Color = .baseMint
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

struct PypLabelRightImage: View {
    let text: String
    let image: Image?      // можно передать nil, если не нужен
    var backgroundColor: Color = .baseMint
    
    var body: some View {
            HStack {
                Text(text)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

#Preview {
    PypButtonRightImage(text: "ПУП", image: Image("chevron_right"), action: {})
}
