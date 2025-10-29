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
        ZStack{
            Color.white.ignoresSafeArea()
            Text("Hello, World!")
                .frame(maxHeight: .infinity)
        }
    }
        
}

//@available(iOS 17.0, *)
struct MainTabBar: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State var selectedTab: TabItem?
    private let tabHeight: CGFloat = 50
    private let tabWidth: CGFloat = 50
    @State var items = [
        TabItem(title: "Посылки", color: .baseMint, icon: "Home 1"),
        TabItem(title: "Сделки", color: .baseMint, icon: "circle.plus.custom"),
        TabItem(title: "Партнёры", color: .baseMint, icon: "person.2.circle"),
        TabItem(title: "Профиль", color: .baseMint, icon: "Profile 1"),
        
    ]
    
    
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
        if viewModel.currentUser != nil {
            ZStack(alignment: .bottom) {
                Color.clear.ignoresSafeArea()
                VStack(spacing: 5) {
                    if let selectedTab = selectedTab {
                        switch selectedTab.title {
                        case "Посылки":
                            DeparturesView()
                                .ignoresSafeArea(.keyboard)
                        case "Сделки":
                            OrdersList()
                        case "Главная":
                            HomeView()
                        case "Партнёры":
//                            TestView()
                            Search()
                        case "Профиль":
                            Profile()
                        default:
                            Text("Unknown tab")
                        }
                    } else {
                        Text("Select a Tab")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    }
                    HStack {
                        HStack {
                            TabItemView(item: items[0], selectedTab: $selectedTab, tabHeight: tabHeight)
                            TabItemView(item: items[1], selectedTab: $selectedTab, tabHeight: tabHeight)
                        }
                        
                        Spacer()
                          .frame(width: tabWidth, alignment: .center)
                        
                        HStack {
                            TabItemView(item: items[2], selectedTab: $selectedTab, tabHeight: tabHeight)
                            TabItemView(item: items[3], selectedTab: $selectedTab, tabHeight: tabHeight)
                        }
                    }
                    .background(Color.tabBackground)
                    .padding(.horizontal, 10)
                }
                .onAppear {
                    selectedTab = items[0]
                }
                CenterButton(item: selectedTab ?? items[0], height: 100, selectedTab: $selectedTab)
                    .offset(y: -4)
            }
            .background(Color.tabBackground)
        }
    }
}
#Preview {
    MainTabBar().environmentObject(AuthViewModel())
}
