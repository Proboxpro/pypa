//
//  SearchAndFilter.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI

struct SearchAndFilter: View {
    @Binding var SearchBarIsEmpty: Bool
    @Binding var showDestinationSearchView : Bool
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
            VStack(alignment: .leading, spacing: 2) {
                Text("Куда отправить?")
                    .font(.footnote)
                    .fontWeight(.semibold )
                Text("Быстро - Просто - Надежно")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {}, label: {
                Image(systemName:"line.3.horizontal.decrease.circle")
                    .foregroundStyle(.black)
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay {Capsule()
                .stroke(lineWidth:0.5)
                .foregroundStyle(Color(.systemGray4))
                .shadow(color: .black.opacity(0.4), radius: 2)
        }
        .padding()
        .onTapGesture {
            withAnimation{
                showDestinationSearchView.toggle()
                SearchBarIsEmpty.toggle()
            }
        }
    }
}

struct SearchAndFilterWithCity: View {
    var cityName : String
//    @Binding var eraseSearchBar : Bool
    @Binding var SearchBarIsEmpty: Bool
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
            VStack(alignment: .leading, spacing: 2) {
                Text(cityName)
                    .font(.footnote)
                    .fontWeight(.semibold )
                Text("Очистить")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            Spacer()
            Button(action: {
                eraseResult()
            }, label: {
                Image(systemName:"x.circle")
                    .foregroundStyle(.black)
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay {Capsule()
                .stroke(lineWidth:0.5)
                .foregroundStyle(Color(.systemGray4))
                .shadow(color: .black.opacity(0.4), radius: 2)
        }
        .padding()
        .onTapGesture {
            withAnimation{
                eraseResult()
            }
        }
    }
    
    func eraseResult() {
        withAnimation {
            SearchBarIsEmpty = true
        }
        print("SEARCHBAR IS EMPTY:\(SearchBarIsEmpty)")
    }
}

//struct SearchAndFilter_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchAndFilter()
//    }
//}
