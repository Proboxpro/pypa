//
//  Inbox.swift
//  Boxx
//
//  Created by Nikita Larin on 17.11.2023.
//

import SwiftUI
import SDWebImageSwiftUI


@available(iOS 17.0, *)
struct Inbox: View {
    @State var shouldShowNewMessageScreen = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser{
            NavigationStack{
                ScrollView{
                    Text("")
                    
                    List{
                        ForEach (0 ... 10, id: \.self) { message in
                            InboxRowView()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height:UIScreen.main.bounds.height - 120)
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        VStack{
                            HStack{
                                WebImage(url: URL(string: user.imageUrl ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(50)
                                    .shadow(radius: 5)

                                Text(user.login)
                                    .font(.title)
                                    .fontWeight(.semibold)
                            }
                            
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        Button{
                            Profile()
                        }label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}
@available(iOS 17.0, *)
struct Inbox_Previews: PreviewProvider {
    static var previews: some View {
        Inbox()
    }
}
