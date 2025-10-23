//
//  MainTabBar.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI
import Firebase

struct TestView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

//@available(iOS 17.0, *)
struct MainTabBar: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var selectedTab: Int = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.gray.withAlphaComponent(0.1)  // фон таббара

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        if let user = viewModel.currentUser{
            //            if true {
            ZStack {
                TabView(selection: $selectedTab) {
                    //                Color.gray
                    //                MainSearch(user: user)
                    //                MainSearch(user: User(id: "123", fullname: "vsy", login: "sa", email: "santa51@amil.ru"))
                    HomeView()
                        .tag(1)
                        .tabItem { tabElem(name: "Посылки", imageName: "Home 1") }
                    Search()
                        .tag(2)
                        .tabItem {
                            Image(systemName: "plus.circle")
                        }
                    
                    HomeView()
                        .tag(3)
                        .tabItem {
//                            Image("ball_center")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 80, height: 80)
//                                .offset(y: -100)
                        }
                    
                    OrdersList()
                        .tag(4)
                        .tabItem {
                            Image(systemName: "message")
                        }
                    Profile()
                        .tag(5)
                        .tabItem { tabElem(name: "Профиль", imageName: "Profile 1") }
                }
                .accentColor(.baseMint)
                
                VStack {
                    Spacer()
                    //                    Button(action: {
                    //                        selectedTab = 3
                    //                    }) {
                    Image(selectedTab == 3  ? "ball_center" : "ball_white")
//                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(Color.gray)
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            selectedTab = 3
                        }
//                        .tag("3")
                    //                            .shadow(radius: 5)
                    //                    }
                        .offset(y: -25) // поднимаем над таббаром
                }
            }
        }
    }
    
    @ViewBuilder
    private func tabElem(name: String, imageName: String)->some View {
        Label {
            Text(name)
                .font(.system(size: 18))
        } icon: {
            tabBarImage(name: imageName)
//                                .scaleEffect(0.3)
        }
    }
    
    @ViewBuilder
    private func tabBarImage(name: String)-> some View {
        Image(name)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 30, height: 30)
    }
}


#Preview {
    MainTabBar().environmentObject(AuthViewModel())
}
