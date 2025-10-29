//
//  UIVC+EXT.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//

import UIKit

protocol Stringable {
    var toString: String? { get }
}

protocol Selectable: CaseIterable, Stringable {
    var name: String { get }
}

extension Selectable where Self: RawRepresentable, Self.RawValue == String {
    var name: String {
        return self.rawValue
    }
    var toString: String? {
        return name
    }
}


extension UIViewController {
    func hideKeyboard() {
        
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
