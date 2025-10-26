//
//  TripCardView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI
import Nuke
import NukeUI

struct TripCardView: View {
    var item: ListingItem
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundImage
                .frame(width: 240, height: 170)
                .clipped()
                .cornerRadius(12)
            
            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                .cornerRadius(12)
                .frame(width: 240, height: 140)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(item.cityFrom) - \(item.cityTo)")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                HStack {
                    Text("\(item.pricePerKillo)")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text(item.ownerName)
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
            }
            .padding(12)
        }
        .frame(width: 240, height: 170)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    
    private var backgroundImage: some View {
        let urlString = item.imageUrl.isEmpty ? item.imageUrls : item.imageUrl
        
        return LazyImage(request: ImageRequest(
            url: URL(string: urlString),
            processors: [
                ImageProcessors.Resize(
                    size: CGSize(width: 240, height: 170),
                    contentMode: .aspectFill
                )
            ]
        )) { state in
            if let image = state.image {
                image.resizable().scaledToFill()
            } else if state.error != nil {
                Color.gray.opacity(0.3)
            } else {
                Color.gray.opacity(0.2)
            }
        }
    }
    
    struct TripCardView_Previews: PreviewProvider {
        static var previews: some View {
            TripCardView(item: ListingItem(id: "1", ownerUid: "u1", ownerName: "Alexander", imageUrl: "", pricePerKillo: "6000 ₽", cityFrom: "Мурманск", cityTo: "Санкт-Петербург", imageUrls: "", startdate: ""))
        }
    }
    
    
}
