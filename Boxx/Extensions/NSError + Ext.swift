//
//  NSError + Ext.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//

import Foundation

extension NSError {
    
    convenience init(_ message: String?) {
        
        self.init(domain: "demoErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Unknown error"])
    }
}
