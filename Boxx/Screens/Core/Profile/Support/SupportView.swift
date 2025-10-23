//
//  SupportView.swift
//  Boxx
//
//  Created by Nikita Evdokimov on 25.05.24.
//


import SwiftUI
import WebKit

struct SupportView: View {
    var body: some View {
//        Text("her")
        WebView(url: URL(string: "https://1767.3cx.cloud/callus/#box")!)
//            .edgesIgnoringSafeArea(.all)
    }
}


struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
