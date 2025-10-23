//
//  SearchButton.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI

struct SearchButton: View {
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "magnifyingglass")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Откуда выезжате?")
                        .font(.footnote)
                        .fontWeight(.semibold )
                    Text("Укажите город и время отправления")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {}, label: {
                    Image(systemName:"line.3.horizontal.decrease.circle")
                        .foregroundStyle(.black)
                })
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .overlay {Capsule()
                    .stroke(lineWidth:0.5)
                    .foregroundStyle(Color(.systemGray4))
                    .shadow(color: .black.opacity(0.4), radius: 2)
            }
            .padding()
        }
    }
    
    
}

struct SearchButton_Previews: PreviewProvider {
    static var previews: some View {
        SearchButton()
    }
}
