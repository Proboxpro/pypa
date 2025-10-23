//
//  ListingitemView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ListingitemView: View {
    var item: ListingItem
    
    var body: some View {
        ZStack(alignment: .top){
            HStack{
                VStack(spacing: 8){

                     //details
                    HStack(){
                        VStack(alignment: .leading){
                            HStack{
                                VStack{
                                    Text("из \(item.cityFrom)")
                                        .fontWeight(.semibold)
                                        .background(.black)
                                        .foregroundStyle(.white)
                                }}
                            HStack{
                                Text(item.startdate)
                                    .fontWeight(.semibold)
                                    .background(.black)
                                    .foregroundStyle(.white)
                            }
                            HStack(alignment: .bottom ){
                                Text("\(item.pricePerKillo)")
                                    .fontWeight(.semibold)
                                    .background(.black)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        
                        //rating
                        
                        HStack(spacing: 2){
                            Text(item.ownerName)
                        } .fontWeight(.heavy)
                            .background(Color(.black))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }.font(.footnote)
                }
                .padding( )
                //Images
            }.background(WebImage(url: URL(string: item.imageUrls)))
                .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            //CityTO
            HStack{
                
                Text("")
                .frame(height: 10)
                .padding(.horizontal, 70)
                .padding(.vertical)
                .overlay {Rectangle()
                        .stroke(lineWidth:1)
                        .background(Color(.systemGray6))
                        .shadow(color: .black.opacity(3), radius: 2)
                    Text("\(item.cityTo)")
                }
            }
        }
    }
    
}





    
