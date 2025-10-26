//
//  BottomCollections.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 18.12.2023.
//


import SwiftUI

struct BottomCollections: View {
    @State var tabSelection: Int = 0
    
    var body: some View {
        TabBarView(currentTab: self.$tabSelection, tabBarOptions: ["Collects", "Feedback"])
        
        TabView(selection: self.$tabSelection) {
            ColletCollection()
                .tag(0)
            ReviewCollection()
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BottomCollections()
}
