//
//  BackTopLeftButtonView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct BackTopLeftButtonView: View {
    // dismiss передаём через Environment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .navigationBarBackButtonHidden()
    }
}

struct BackTopLeftWhiteButtonView: View {
    // dismiss передаём через Environment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .navigationBarBackButtonHidden()
    }
}

struct AskQuestionButton: View {
    var body: some View {
        HStack {
            Spacer()
            Button {print("question")} label: {
                Text("задать вопрос")
                    .foregroundStyle(Color.gray)
                    .underline()
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
    }
}
