//
//  CenterButtonView.swift
//  Boxx
//
//  Created by Sasha Soldatov on 23.10.2025.
//

import SwiftUI

struct CenterButton: View {
    let item: TabItem
    let height: CGFloat
    @Binding var selectedTab: TabItem?
    
    var body: some View {
        Image(item.title == "Главная" ? "ball_center" : "ball_white")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: height)
            .onTapGesture {
                selectedTab = TabItem(title: "Главная", color: .baseMint, icon: "")
           }
         }
}
