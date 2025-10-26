//
//  HeaderView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 18.12.2023.
//

import Foundation
import SwiftUI
import CachedAsyncImage


struct HeaderView: View {
    var user: User
    var offsetY: CGFloat
    var safeArea: EdgeInsets
    var size: CGSize
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Rectangle()
                    .fill(.black.gradient)
                
                //MARK: - image profile
//                CachedAsyncImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/newboc-ae213.appspot.com/o/City%2F360_F_571834789_ujYbUnH190iUokdDhZq7GXeTBRgqYVwa.jpg?alt=media&token=4ec96c2f-7218-41f6-96e1-c39d58f74895")) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } placeholder: {
//                    Color.gray
//                }
//                .frame(width: UIScreen.main.bounds.width)
//                .opacity(1 - progress)
                
                VStack(spacing: 15) {
                    GeometryReader {
                        let rect = $0.frame(in: .global)
                        let halfScaledHeight = (rect.height * 0.3) * 0.5
                        let midY = rect.midY
                        let bottomPadding: CGFloat = 15
                        let resizedOffsetY = (midY - (minimumHeaderHeight - halfScaledHeight - bottomPadding))
                        
                        AsyncImage(url: URL(string: user.imageUrl ?? "")) { image in
                        
                            image
                                .profileImageStyling(rect: rect)
                                .scaleEffect(1 - (progress * 0.7), anchor: .leading)
                                .offset(x: -(rect.minX - 15) * progress, y: -resizedOffsetY * progress)
                        } placeholder: {
                            Color.gray
                                .clipShape(Circle())
                        }
                    }
                    .onAppear(perform: {
                        print(user.imageUrl!)
                    })
                    
                    .padding(.top, 20)
                    .frame(width: headerHeight * 0.4, height: headerHeight * 0.4)
                    
                    Text("@" + user.login)
                        .profileNameStyling()
                        .moveText(progress, headerHeight, minimumHeaderHeight)
                }
                .padding(.top, safeArea.top)
                .padding(.bottom, 15)
            }
            .frame(height: (headerHeight + offsetY) < minimumHeaderHeight ? minimumHeaderHeight : (headerHeight + offsetY), alignment: .bottom)
            .offset(y: -offsetY)             // Sticking to the Top
        }
        .frame(height: headerHeight)
    }
}

extension HeaderView {
    var minimumHeaderHeight: CGFloat {65 + safeArea.top}
    var headerHeight: CGFloat {(size.height * 0.3) + safeArea.top}
    var progress: CGFloat {max(min(-offsetY / (headerHeight - minimumHeaderHeight), 1), 0)}
}
