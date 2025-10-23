//
//  AuthButton.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct AuthButton: View {
    var title: String
    var style: Style = .filled
    var action: () -> Void
    
    enum Style {
        case filled
        case outline
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 56)
                .foregroundColor(foregroundColor)
                .overlay(overlay)
        }
        .background(background)
        .cornerRadius(14)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .filled: return .white
        case .outline: return .baseMint
        }
    }
    
    private var background: some View {
        Group {
            switch style {
            case .filled:
                Color.baseMint
            case .outline:
                Color.clear
            }
        }
    }
    
    private var overlay: some View {
        Group {
            switch style {
            case .filled:
                EmptyView().eraseToAnyView()
            case .outline:
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.baseMint, lineWidth: 1)
                    .eraseToAnyView()
            }
        }
    }
}

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}


