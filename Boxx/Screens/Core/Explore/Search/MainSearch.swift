//
//  MainSearch.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI

struct SearchParameters  {
    var cityName: String = ""
    var startDate = Date()
    var endDate = Date()
    var datesIsSelected = false
}


@available(iOS 17.0, *)
struct MainSearch: View {
    @State private var showDestinationSearchView = false
    @State private var searchBarIsEmpty = true
    @EnvironmentObject var viewModel: AuthViewModel
    @State var searchParameters = SearchParameters()
    
    @State var showingListingDetailView = false
    @State var currentItem : ListingItem?
    
//    @State var filteredOnParamOrder = [ListingItem]()
//    @State var ordersToShow = [ListingItem]()
//    @State var isOrderFound: Bool = false
    
    let user: User
    
    var body: some View {
        if viewModel.currentUser != nil {
            VStack {
                if showingListingDetailView {
                    ListingDetail(item: currentItem!, showingListingDetailView: $showingListingDetailView)
                } else {
                    if showDestinationSearchView{
                        DestinationSearchView(show: $showDestinationSearchView, parameters: $searchParameters)
                    } else {
                        MainScrollView()
                    }
                }
                
            }
//            Text("jer")
        }
    }
    
    
    //MARK: - Views
    func MainScrollView()->some View {
       
        ScrollView{
            LazyVStack(spacing: 5){
                
                let filteredOnParamOrder = searchParameters.cityName == "" ? viewModel.myorder : viewModel.filteredOnParam(searchParameters, searchBarIsEmpty: searchBarIsEmpty)
                
                let ordersToShow = filteredOnParamOrder.filter({$0.startdate.toDate() ?? Date() > Date()}).filter({$0.ownerUid != viewModel.currentUser!.id})
            
                let isOrderFound = !filteredOnParamOrder.isEmpty && searchParameters.cityName != ""
                
                if isOrderFound && !searchBarIsEmpty {
                     SearchAndFilterWithCity(cityName: searchParameters.cityName, SearchBarIsEmpty: $searchBarIsEmpty)
                } else {
                    SearchAndFilter(SearchBarIsEmpty: $searchBarIsEmpty, showDestinationSearchView: $showDestinationSearchView)
                }
                
//                SearchBarView()
                
                if ordersToShow.isEmpty {
                    OrdersNotFoundView()
                } else {
                    ForEach(ordersToShow.sorted(by: {$0.startdate.toDate()! < $1.startdate.toDate()!})) {item in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25)) {
                                self.currentItem = item
                                self.showingListingDetailView = true
                            }
                        } label: {
                            ListingitemView(item: item)
                        }
                        .scrollTransition{
                            content, phase in content
                                .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                .opacity(phase.isIdentity ? 1 : 0.85)
                        }
                        .frame(height: 160)
                    }
                }
            }
        }
        .onAppear{
            print("APPEAR")
//            viewModel.myOrder()
//            calculateOrdersToShow()
            viewModel.myOrder()
//            Task {
//                await viewModel.fetchOrder()
//            }
        }
    }
    
    //MARK: - Views
    func OrdersNotFoundView()->some View {
        VStack {
            HStack {
                Image(systemName: "rectangle.and.text.magnifyingglass")
                Text("отправлений не найдено")
            }
            .foregroundColor(.gray)
        }
    }
    
    //MARK: - helpers:
//    func SearchBarView()->some View {
//        if self.isOrderFound && !searchBarIsEmpty {
//            return AnyView(SearchAndFilterWithCity(cityName: searchParameters.cityName, SearchBarIsEmpty: $searchBarIsEmpty))
//        }
//        return AnyView(SearchAndFilter(SearchBarIsEmpty: $searchBarIsEmpty, showDestinationSearchView: $showDestinationSearchView))
//    }
//    
//    func calculateOrdersToShow() {
//        let filteredOnParamOrder = searchParameters.cityName == "" ? viewModel.myorder : viewModel.filteredOnParam(searchParameters, searchBarIsEmpty: searchBarIsEmpty)
//        
//        self.ordersToShow = filteredOnParamOrder.filter({$0.startdate.toDate() ?? Date() > Date()})
//    
//        self.isOrderFound = !filteredOnParamOrder.isEmpty && searchParameters.cityName != ""
//    }
}

