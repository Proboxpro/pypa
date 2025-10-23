//
//  SumSubAccount.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//

import Foundation
import IdensicMobileSDK

struct SumSubAccount {
    //
    // If you'd like to run the demo on the simulator, you can use App Tokens authorization approach.
    // See https://developers.sumsub.com/api-reference/#app-tokens for details.
    //
    // Pay attention please that in your intergation all the sensitive things should be done on your backend.
    // For the demo purposes we have implemented the corresponding routines on the client side, but please,
    // in the real life use your backend and never store your credentials on the devices.
    //
    static var apiUrl: String = SumSubEnvironment.prod.apiUrl
    static var isSandbox: Bool = true
    
    //MARK: - fetch from Backend needed
    static let appToken: String? = "sbx:ztTqiWxU9mToSJuIadSufAS9.RxyY2R6lvY4fkRYWqzbfRcP2RofGNn1A"
    static let secretKey: String? = "t6HdsXMr2pC126iWhNcetskLVWdUFu49"
}

enum SumSubEnvironment: String, Selectable {
    
    case prod = "https://api.sumsub.com"
    case sandbox = "sandbox"
}


extension SumSubAccount {
            
    static var isRegularIntegration: Bool {
        return SumSubEnvironment(rawValue: apiUrl) == .prod
    }

    static func getEnvironment() -> SNSEnvironment {
        return isRegularIntegration ? .production : SNSEnvironment(apiUrl)
    }
    
    static var isAuthorized: Bool { return hasBearerToken || hasAppToken }
    static var hasBearerToken: Bool { return YourBackend.bearerToken != nil }
    static var hasAppToken: Bool { return appToken != nil && !appToken!.isEmpty && secretKey != nil && !secretKey!.isEmpty }
    
    static func linkTo(_ path: String) -> URL? {
        
        return URL(string: path, relativeTo: URL(string: apiUrl))
    }
    
    static func setEnvironment(_ environment: SumSubEnvironment) {
        
        apiUrl = environment.apiUrl
        isSandbox = environment.isSandbox
    }
    
    static var environmentName: String {
        
        if isSandbox {
            return SumSubEnvironment.sandbox.name
        } else {
            return SumSubEnvironment(rawValue: apiUrl)?.name ?? apiUrl
        }
    }
    
    static func save() {
        
        StorageUserDefaults.set(apiUrl, for: .apiUrl)
        StorageUserDefaults.set(isSandbox, for: .isSandbox)
        StorageUserDefaults.set(YourBackend.bearerToken, for: .bearerToken)
        StorageUserDefaults.set(YourBackend.client, for: .client)
    }
    
    static func restore() {
        
        if let apiUrl = StorageUserDefaults.getString(.apiUrl) {
            SumSubAccount.apiUrl = apiUrl
        }
        if let isSandbox = StorageUserDefaults.getBool(.isSandbox) {
            SumSubAccount.isSandbox = isSandbox
        }
        if let bearerToken = StorageUserDefaults.getString(.bearerToken) {
            YourBackend.bearerToken = bearerToken
        }
        if let client = StorageUserDefaults.getString(.client) {
            YourBackend.client = client
        }
    }
    
    private static let initialApiUrl = apiUrl
    private static let initialSandbox = isSandbox
    
    static func useAppToken() {
        
        apiUrl = initialApiUrl
        isSandbox = initialSandbox
        YourBackend.bearerToken = nil
        YourBackend.client = nil
        
        save()
    }
}

extension SumSubEnvironment {
    
    var isSandbox: Bool { self == .sandbox }
    
    var apiUrl: String {
        if isSandbox {
            return Self.prod.apiUrl
        } else {
            return rawValue
        }
    }
    
    var name: String {
        if isSandbox {
            return "sandbox"
        } else {
            return apiUrl.domain ?? apiUrl
        }
    }
}
