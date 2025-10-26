//
//  UserProfileHome.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 18.12.2023.
//

import Foundation
import SwiftUI

struct UserProfileHome: View {
    var size: CGSize
    var safeArea: EdgeInsets
    var user: User
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var offsetY: CGFloat = 0
    
    @State var tabSelection: Int = 0
    
    
    var body: some View {
//        if let user = viewModel.currentUser {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        HeaderView(user: user, offsetY: offsetY, safeArea: safeArea, size: size)
                            .zIndex(1000)
                        
                        TabBarView(currentTab: self.$tabSelection, tabBarOptions: ["Награды", "Отзывы"])
                            .padding(.leading, -30)
                            .padding(.top, 15)
                        
                        if tabSelection == 0 {
                            ColletCollection()
                        } else {
                            ReviewCollection()
                        }
                        
                    }
                    .id("SCROLLVIEW")
                    .background {
                        ScrollDetector { offset in
                            offsetY = -offset
                        } onDraggingEnd: { offset, velocity in
                            let headerHeight = (size.height * 0.3) + safeArea.top
                            let minimumHeaderHeight = 65 + safeArea.top
                            
                            let targetEnd = offset + (velocity * 45)
                            if targetEnd < (headerHeight - minimumHeaderHeight) && targetEnd > 0 {
                                withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.65, blendDuration: 0.65)) {
                                    scrollProxy.scrollTo("SCROLLVIEW", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
        }
//    }
}
//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
