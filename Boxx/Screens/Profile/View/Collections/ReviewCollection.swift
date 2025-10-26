//
//  LikesCollection.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 19.12.2023.
//

import Foundation
import SwiftUI

struct ReviewCollection: View {
    var body: some View {
        VStack(spacing: 15) {
            ForEach(0..<8, id: \.self) { _ in
                FeedbackView()
            }
        }
        .padding(15)
    }
}

#Preview {
    ReviewCollection()
}
