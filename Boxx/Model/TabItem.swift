//
//  TabItem.swift
//  Boxx
//
//  Created by Sasha Soldatov on 23.10.2025.
//

import Foundation
import SwiftUI

struct TabItem: Identifiable, Equatable {
   let id: UUID = UUID()
   let title: String
   let color: Color
   let icon: String
}
