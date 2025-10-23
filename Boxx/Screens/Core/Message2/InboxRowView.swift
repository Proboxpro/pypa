//
//  InboxRowView.swift
//  Boxx
//
//  Created by Nikita Larin on 17.11.2023.
//

import SwiftUI

struct InboxRowView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 15){
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(Color(.systemGray))
            VStack(alignment: .leading, spacing: 4){
                Text("Петров Иван")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("А теперь какой то текст ")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
            }
            HStack{
                Text("Yesterday")
                Image(systemName: "chevron.right")
                
            }
            .font(.footnote)
            .foregroundColor(.gray)
            
        }.padding()
            .frame(height: 72)
        
    }
}    

struct InboxRowView_Previews: PreviewProvider {
    static var previews: some View {
        InboxRowView()
    }
}
