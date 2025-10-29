//
//  ContentView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 16.11.2023.
//

import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    @EnvironmentObject var viewModel:  AuthViewModel

    var body: some View {
        Group{
            //DEBUG: _
            if viewModel.userSession != nil {
                MainTabBar()
                    .ignoresSafeArea(.keyboard)
                    .environmentObject(viewModel)
                
//                    .alert(viewModel.activeAlert?.title ?? "Сообщение", isPresented: $viewModel.isAlertPresented) {
//                        Button("OK") { viewModel.dismissAlert() }
//                    } message: {
//                        Text(viewModel.activeAlert?.message ?? "")
//                    }
                
                    .confirmationDialog("Вы уверены, что хотите выйти из аккаунта?", isPresented: $viewModel.showExitFromAccAlert, titleVisibility: .visible) {
                        Button("Да", role: .destructive) { viewModel.signOut() } // слева
                        Button("Отмена", role: .cancel) { viewModel.dismissAlert() } // справа
                    }
            } else {
                StartView()
//                    .alert(viewModel.activeAlert?.title ?? "Сообщение", isPresented: $viewModel.isAlertPresented) {
//                        Button("OK") { viewModel.dismissAlert() }
//                    } message: {
//                        Text(viewModel.activeAlert?.message ?? "")
//                    }
            }
        }
        .alert(viewModel.activeAlert?.title ?? "Сообщение", isPresented: $viewModel.isAlertPresented) {
            Button("OK") { viewModel.dismissAlert() }
        } message: {
            Text(viewModel.activeAlert?.message ?? "")
        }
    }
}

@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthViewModel())
    }
}
