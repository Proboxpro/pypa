//
//  TabItemView.swift
//  Boxx
//
//  Created by Sasha Soldatov on 23.10.2025.
//

import SwiftUI

struct TabItemView: View {
    let item: TabItem
    @Binding var selectedTab: TabItem?
    var tabHeight: CGFloat
    
    private var isSelected: Bool {
        selectedTab == item
    }
    
    var body: some View {
        Button {
            selectedTab = item
        } label: {
            VStack {
                tabBarImage(name: item.icon)
                Text(item.title)
                    .font(.caption)
            }
            .foregroundStyle(isSelected ? .baseMint : .gray)
        }
        .frame(maxWidth: .infinity, maxHeight: tabHeight)
    }
}


@ViewBuilder
   private func tabBarImage(name: String) -> some View {
       Image(name)
           .resizable()
           .renderingMode(.template)
           .scaledToFit()
           .frame(width: 25, height: 25)
   }
