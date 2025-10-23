//
//  AuthButtonLabel.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct AuthButtonLabel: View {
    var title: String
    var style: AuthButton.Style = .filled
    
    var body: some View {
        Text(title)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: 56)
            .foregroundColor(style == .filled ? .white : .baseMint)
            .overlay(
                Group {
                    if style == .outline {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.baseMint, lineWidth: 1)
                    }
                }
            )
            .background(style == .filled ? Color.baseMint : Color.clear)
            .cornerRadius(14)
    }
}

struct AuthButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AuthButtonLabel(title: "Filled", style: .filled)
            AuthButtonLabel(title: "Outline", style: .outline)
        }
        .padding()
    }
}


