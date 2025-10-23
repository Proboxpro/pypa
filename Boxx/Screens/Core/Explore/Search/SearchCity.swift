//
//  MainSearch.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI
@available(iOS 17.0, *)
struct SearchCity: View {
    @State private  var showDestinationSearchView = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    
    var body: some View {
      
                ScrollView{
                    LazyVStack(spacing: 5){
                       
                        ForEach(viewModel.orders) {item in NavigationLink(value: item){ ListingitemView(item: item)}
                        }
                        .frame(height: 160)
                    }
                }  .navigationDestination(for: ListingItem.self){ item in
//                    ListingDetail(item: item)
                    ListingDetail(item: item)
                        .environmentObject(ListingViewModel(authViewModel: self.viewModel))
                        .navigationBarBackButtonHidden()
                    
                }.onAppear{
                    viewModel.fetchOrder()
                }
            }
            
        
}



