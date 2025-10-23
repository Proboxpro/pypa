//
//  ChatViewModel.swift
//  Boxx
//
//  Created by Nikita Larin on 26.12.2023.
//

import Foundation

class ChatViewModel: ObservableObject {
    

    @Published var text = ""
    let user: User
    init(user: User) {
        self.user = user
    }
    func sendMessage(){
        MessageService.sendMessage(text, toUser: user)
    }
    
}
