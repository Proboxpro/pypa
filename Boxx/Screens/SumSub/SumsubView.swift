//
//  SumsubVC.swift
//  sumsub test
//
//  Created by Nikita Evdokimov on 27.04.24.
//

import UIKit
import IdensicMobileSDK
import SwiftUI

struct SumsubView: UIViewControllerRepresentable, View {
    @Binding var user: User?
    @State var backend = YourBackend()
    @EnvironmentObject var viewModel : AuthViewModel
    
    func makeUIViewController(context: Context) -> ViewController {
        
//        guard let user = user else {
//            return ViewController(backend: backend)
//        }
//        print(user)
        
        let viewController = ViewController(backend: backend, user: user!)
//        viewController.startIdentify()
//        viewController.view.backgroundColor = .green
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        print("UPDATE")

    }
    
}


