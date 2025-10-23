//
//  GradesView.swift
//  Boxx
//
//  Created by Assistant on 2024.
//

import SwiftUI

struct GradesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с кнопкой назад
            HStack {
                Button { dismiss() } label: {
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
                
                Text("Грейды")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Невидимая кнопка для центрирования заголовка
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 1)
                
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "star.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                Text("Грейды")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Функция в разработке")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .background(Color(.systemBackground))
    }
}

#Preview {
    GradesView()
}

