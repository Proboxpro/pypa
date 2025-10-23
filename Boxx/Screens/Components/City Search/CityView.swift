//
//  CityView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 15.03.2024.
import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct CityView: View {
    var city: City
    @EnvironmentObject var viewModel: AuthViewModel
 
    var body: some View {
        VStack(alignment: .leading){
                HStack(spacing: 15){
                    Text(city.name)
                       
                }
                .frame (height: 44)
                .scaledToFill()
            }  .padding(.horizontal)
              
        
    }
    }


