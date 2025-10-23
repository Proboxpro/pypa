//
//  DealRowView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct DealRowView: View {
    var item: DealItem
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(item.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipped()
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                }
                Spacer()
                Text(item.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text(item.timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text(item.price)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.baseMint)
                Spacer()
                Image(item.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.secondarySystemBackground))
                .stroke(lineWidth: 0.8).fill(.gray.opacity(0.5))
        )
    }
}

struct DealRowView_Previews: PreviewProvider {
    static var previews: some View {
        DealRowView(item: DealItem(id: "1", thumbnail: "Image", title: "Platdo", subtitle: "Футболка", timeAgo: "1 час назад", price: "3200₽", avatar: "profile"))
            .padding()
    }
}


