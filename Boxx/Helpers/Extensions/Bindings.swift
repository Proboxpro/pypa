//
//  Bindings.swift
//  Boxx
//
//  Created by Nikita Evdokimov on 11.04.24.
//

import SwiftUI

extension Binding {
    static func mock(_ value: Value) -> Self {
        var value = value
        return Binding(get: { value },
                       set: { value = $0 })
    }
}
