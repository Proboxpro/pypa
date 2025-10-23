//
//  HotelListViewModel.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 20.03.2024.
//

import Foundation

class HotelListViewModel: ObservableObject {
    
    @Published var hotels: [HotelViewModel] = []
    
    func populateHotels (filter: FilterViewState? = nil) async {
        do{
            hotels = try await Webservice().getAllHotels(url: Constants.Urls.allHotels)
        }
