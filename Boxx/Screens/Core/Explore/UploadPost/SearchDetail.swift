//
//  SearchDetail.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 17.11.2023.
//

import SwiftUI

struct SearchDetail: View {
    
    @State var txt = ""


    var body: some View {
        

            VStack{
                HStack{
                    TextField("Search", text: self.$txt)
                    
                    if self.txt  != ""{
                        Button (action: {
                            
                        }){ }
                        
                        Text ("Cancel")
                            .foregroundColor(.black)
                    }
                        .foregroundColor(.black)
                }.padding()
            } .backgroundStyle(Color.white)
                .padding()
        
    }
}

struct SearchDetail_Previews: PreviewProvider {
    static var previews: some View {
        SearchDetail()
    }
}
