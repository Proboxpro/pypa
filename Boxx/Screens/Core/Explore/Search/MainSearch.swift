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
    @Environment(\.dismiss) private var dismiss
    var showMainSearchView: Binding<Bool>? = nil
    
    @State var showingCreateDealView = false
    @State var currentItem : ListingItem?
    
//    @State var filteredOnParamOrder = [ListingItem]()
//    @State var ordersToShow = [ListingItem]()
//    @State var isOrderFound: Bool = false
    
    let user: User
    
    var body: some View {
        if viewModel.currentUser != nil {
            ZStack {
                VStack {
                    if showingCreateDealView {
                        CreateDealView(item: currentItem!, showCreateDealView: $showingCreateDealView)
                    } else {
                        MainScrollView()
                            .id("\(searchParameters.cityName)-\(searchBarIsEmpty)-\(searchParameters.datesIsSelected)")
                            .blur(radius: showDestinationSearchView ? 5 : 0)
                            .opacity(showDestinationSearchView ? 0.3 : 1.0)
                    }
                }
                
                if showDestinationSearchView {
                    DestinationSearchView(show: $showDestinationSearchView, parameters: $searchParameters)
                        .navigationBarBackButtonHidden()
                        .onChange(of: showDestinationSearchView) { oldValue, newValue in
                            if newValue {
                                viewModel.myOrder()
                            } else {
                                if !searchParameters.cityName.isEmpty {
                                    searchBarIsEmpty = false
                                }
                                viewModel.myOrder()
                            }
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
                } else if !searchBarIsEmpty {
                    SearchAndFilterWithCity(cityName: searchParameters.cityName, SearchBarIsEmpty: $searchBarIsEmpty)
                    //SearchAndFilter(SearchBarIsEmpty: $searchBarIsEmpty, showDestinationSearchView: $showDestinationSearchView)
                } else {
                    SearchAndFilter(SearchBarIsEmpty: $searchBarIsEmpty, showDestinationSearchView: $showDestinationSearchView)
                }
                
//                SearchBarView()
                
                if ordersToShow.isEmpty {
                    OrdersNotFoundView()
                        .navigationBarBackButtonHidden()
                } else {
                    VStack(spacing: 10) {

                        ForEach(ordersToShow.sorted(by: {$0.startdate.toDate()! < $1.startdate.toDate()!})) {item in
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25)) {
                                    self.currentItem = item
                                    self.showingCreateDealView = true
                                }
                            } label: {
                                TripCardView(width: screenWidth - 20, item: item )
                            }
                            .scrollTransition{
                                content, phase in content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                    .opacity(phase.isIdentity ? 1 : 0.85)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        

                    }
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onAppear{
            viewModel.myOrder()
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


 
