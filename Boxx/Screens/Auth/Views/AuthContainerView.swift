//
//  AuthContainerView.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

struct AuthContainerView: View {
    enum Tab { case login, register }
    var initialTab: Tab = .login
    
    @State private var selected: Tab
    
    init(initialTab: Tab = .login) {
        self.initialTab = initialTab
        _selected = State(initialValue: initialTab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selected) {
                Login()
                    .tag(Tab.login)
                    .tabItem { EmptyView() }
                Registration()
                    .tag(Tab.register)
                    .tabItem { EmptyView() }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct AuthContainerView_Previews: PreviewProvider {
    static var previews: some View {
        AuthContainerView()
    }
}


