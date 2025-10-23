//
//  SwiftUIView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 20.03.2024.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var speed = 5.0
    @State private var isEditing = false
    var body: some View {
        VStack {
                Slider(
                    value: $speed,
                    in: 0...10,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                )
                Text("\(speed)")
                    .foregroundColor(isEditing ? .red : .blue)
            }
    }
}

#Preview {
    SwiftUIView()
}
