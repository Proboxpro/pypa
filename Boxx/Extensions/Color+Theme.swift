//
//  Color+Theme.swift
//  Boxx
//
//  Created by Assistant on 02.10.2025.
//

import SwiftUI

extension Color {
    static var baseMint: Color {
        if let uiColor = UIColor(named: "baseMint") {
            return Color(uiColor)
        } else {
            return Color(.systemTeal)
        }
    }
}


