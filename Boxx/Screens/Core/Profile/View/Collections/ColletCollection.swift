//
//  ColletCollection.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 19.12.2023.
//



import SwiftUI

struct ColletCollection: View {
    var body: some View {
        VStack(spacing: 15) {
            ForEach(0..<8, id: \.self) { _ in
                HStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 150)
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 150)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 150)
                }
            }
        }
        .padding(15)
    }
}

#Preview {
    ColletCollection()
}
