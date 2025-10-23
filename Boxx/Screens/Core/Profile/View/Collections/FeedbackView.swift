//
//  FeedbackView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 19.12.2023.
//

import SwiftUI

struct FeedbackView: View {
   // var feedback: Feedback

    var body: some View {
        ZStack(alignment: .top){
            HStack{ 
                VStack(spacing: 8){
                    HStack(){
                        VStack(alignment: .leading){
                            HStack{
                                VStack{
                                    Image(.profile)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                }}
                            HStack{
                                Text("Login")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                            }
                            HStack(alignment: .bottom ){
                                Text("Date")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                            }
                        }
                        Spacer()
                        HStack(spacing: 2){
                           Image(systemName: "star")
                            Text("4.5")
                        } .fontWeight(.heavy)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }.font(.footnote)
                }
                .padding( )
                //Images
            }.background(Color(.systemGray5))
                .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            //CityTO
            HStack(){
                
                Text("sdcscsdsc")
                .frame(height: 80)
                .padding(.horizontal, 50)
                .padding(.vertical)
                .overlay {Rectangle()
                        .stroke(lineWidth:1)
                        .background(Color(.systemGray6))
                        .shadow(color: .black.opacity(3), radius: 2)
                    Text("sdcsd")
                        
                }.frame(width: 220, height: 180)
            }
        }
    }
    
}

#Preview {
    FeedbackView()
}
