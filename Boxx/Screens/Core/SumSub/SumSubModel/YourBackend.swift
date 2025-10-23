//
//  YourBackend.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//

import Foundation
import IdensicMobileSDK

typealias LevelName = String
typealias AccessToken = String
typealias BearerToken = String

protocol YourBackendProtocol {
    static var bearerToken: BearerToken? { get set }
    static var client: String? { get set }
//    static var isApproved: Bool { get set }

    static func logIntoSumSubAccount(delay: TimeInterval, onComplete: @escaping (Error?, Bool) -> Void)
    static func checkIsAuthorized(onComplete: @escaping (Error?, Bool) -> Void)
    static func getAccessToken(for user: User?, onComplete: @escaping (Error?, AccessToken?) -> Void)
    static func getApplicantLevels(forNewUser: Bool, onComplete: @escaping (Error?, [ApplicantLevel]?) -> Void)
}


struct ApplicantLevel: Stringable {
    var name: LevelName
    var isAction: Bool = false
    var toString: String? { return name }
}

struct YourBackend : YourBackendProtocol {
    
//    var isApproved = false
    // Your backend is involved into the verification process as well. In particular it is responsible for the providing of "access tokens" for the applicants to be verified.
    // For the demo purposes we have implemented the corresponding routines on the client side, but please, in the real life use your backend and never store your credentials on the devices.
    
    // In case you are curious about, you can find the implementation details in YourBackend+Details.swift
}


extension YourBackend {
    
    static var bearerToken: BearerToken?
    static var client: String?

    
    // MARK: - Authorization
    
    static func logIntoSumSubAccount(delay: TimeInterval = 0, onComplete: @escaping (Error?, Bool) -> Void) {
        
        if delay > 0 {
            logIntoSumSubAccount { (error, isAuthorized) in
                DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
                    onComplete(error, isAuthorized)
                }
            }
            return
        }

        checkIsAuthorized { error, isAuthorized in
            
            onComplete(error, isAuthorized)
        }
    }

    static func checkIsAuthorized(onComplete: @escaping (Error?, Bool) -> Void) {
                
        guard SumSubAccount.hasBearerToken else {
            onComplete(nil, false)
            return
        }
        
        get("/resources/auth/-/isLoggedIn") { (error, json, statusCode) in
         
            if let error = error {
                onComplete(error, false)
            }
            else if let isLoggedIn = json?["loggedIn"] as? Bool {
                log(isLoggedIn ? "Authorization is confirmed" + (SumSubAccount.isSandbox ? " (sandbox)" : "") : "Not authorized")
                onComplete(nil, isLoggedIn)
            }
            else {
                onComplete(NSError("Unable to check if we are logged in"), true)
            }
        }
    }
    
    // MARK: - Required routines
    
    static func getAccessToken(for user: User?, onComplete: @escaping (Error?, AccessToken?) -> Void) {
        
        guard let userId = user?.id else {
            onComplete(NSError("User is not created yet"), nil)
            return
        }
        
        var path: String = "/resources/accessTokens?&userId=\(userId.urlQueryEncoded)&ttlInSecs=600"
        
        if let levelName = StorageUserDefaults.levelName {
            path = path + "&levelName=\(levelName.urlQueryEncoded)"
        }
//        if let externalActionId = user?.externalActionId {
//            path = path + "&externalActionId=\(externalActionId.urlQueryEncoded)"
//        }
        
        print("PATH_get access token: \(path)")
        post(path) { (error, json, statusCode) in

//            if statusCode == 401 {
//                App.checkAutorizationStatus()
//            }
            
            if let error = error {
                onComplete(error, nil)
            }
            else if let token = json?["token"] as? String {
                onComplete(nil, token)
            }
            else {
                onComplete(NSError("Unable to get access token"), nil)
            }
        }
    }

    // MARK: - SumSub API
    
    private static var sumsubApiURL: URL? { return URL(string: SumSubAccount.apiUrl) }
    
    static func getApplicantLevels(forNewUser: Bool, onComplete: @escaping (Error?, [ApplicantLevel]?) -> Void) {
        
        get("/resources/applicants/-/levels") { (error, json, statusCode) in
            
            if let error = error {
                onComplete(error, nil)
                return
            }

            if
                let list = json?["list"] as? Json,
                let items = list["items"] as? [Json]
            {
                let levels = items.map { (item) -> ApplicantLevel in
                    return ApplicantLevel(
                        name: item["name"] as? LevelName ?? "noname",
                        isAction: item["type"] as? String ?? "" == "actions"
                    )
                } .filter { level in
                    return forNewUser ? !level.isAction : true
                }
                
                onComplete(nil, levels)
            }
            else {
                onComplete(NSError("Unable to get applicant levels"), nil)
            }
        }
    }
    
    // MARK: - Low level

    private typealias Json = Dictionary<AnyHashable,Any>
    private typealias StatusCode = Int
    private typealias ResponseCallback = (Error?, Json?, StatusCode) -> Void
    
    private static var session = URLSession(configuration: URLSessionConfiguration.ephemeral)

    private static func get(_ path: String, onComplete: @escaping ResponseCallback) {
        
        request("GET", path, onComplete: onComplete)
    }
    
    private static func post(_ path: String, _ json: Json? = nil, onComplete: @escaping ResponseCallback) {
        
        request("POST", path, json, onComplete: onComplete)
    }
    
    private static func request(_ method: String, _ path: String, _ json: Json? = nil, onComplete: @escaping ResponseCallback) {
        
        guard sumsubApiURL != nil, let url = URL(string: path, relativeTo: sumsubApiURL) else {
            onComplete(NSError("Unable to create URLRequest for path: \(path)"), nil, 0)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let bearerToken = bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        else if let signature = sign(method: method, uri: path) {
            request.setValue(signature.token, forHTTPHeaderField: "X-App-Token")
            request.setValue(signature.ts, forHTTPHeaderField: "X-App-Access-Ts")
            request.setValue(signature.sig, forHTTPHeaderField: "X-App-Access-Sig")
            
            print("REQUEST, signature:", request.allHTTPHeaderFields!, "\n")
        }
        
        if let client = client {
            request.setValue(client.urlQueryEncoded, forHTTPHeaderField: "X-Impersonate")
        }
        
        if SumSubAccount.isSandbox {
            request.setValue("_ss_route=sbx", forHTTPHeaderField: "Cookie")
        }
        
//        print("JSON:", json!)
        print("REQUEST, url", request.description, "\n")

        send(request, json, onComplete: onComplete)
    }
        
    private static func send(_ request: URLRequest, _ json: Json? = nil, onComplete: @escaping ResponseCallback) {
        
        log("%@ %@", request.httpMethod ?? "Send", request.url?.absoluteString ?? "?")
        
        var request = request
        
        if let json = json {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        }
        
        request.setValue("msdkDemo", forHTTPHeaderField: "X-Client-Id")
        request.setValue("iOS", forHTTPHeaderField: "X-Mob-OS")
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Mob-App")
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(version, forHTTPHeaderField: "X-Mob-App-Ver")
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            request.setValue(build, forHTTPHeaderField: "X-Mob-App-Build")
        }

        let fail = { (_ error: Any?, _ statusCode: StatusCode) in
            DispatchQueue.main.async {
                if let error = error as? Error {
                    log(error.localizedDescription)
                    onComplete(error, nil, statusCode)
                }
                else if let reason = error as? String {
                    log(reason)
                    onComplete(NSError(reason), nil, statusCode)
                }
                else {
                    onComplete(NSError("Failed for unknown reason"), nil, statusCode)
                }
            }
        }
        
        let success = { (_ json: Json?, _ statusCode: StatusCode) in
            DispatchQueue.main.async {
                onComplete(nil, json, statusCode)
            }
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                fail(error, 0)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                fail("HTTPURLResponse is expected, but \(type(of: response)) found", 0)
                return
            }
            
            let statusCode = httpResponse.statusCode
            let responseBody = data == nil ? nil : String(data: data!, encoding: .utf8)
            var json: Json?
            
            log("%@ %@ -> %li", request.httpMethod ?? "Got", response?.url?.absoluteString ?? "?", statusCode)
            
            switch statusCode {
            case 200...299:
                
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Json
                    } catch {
                        fail("JSON is expected but [\(responseBody ?? "")] found", statusCode)
                        return
                    }
                }
                
                success(json, statusCode)
                
            case 401:
                bearerToken = nil
                fallthrough

            default:
                
                fail("Request failed: \(responseBody ?? "")", statusCode)
            }
            
        }.resume()
    }
    
    private static func sign(method: String, uri: String) -> (token: String, ts: String, sig: String)? {
        
        guard let appToken = SumSubAccount.appToken,
              let secretKey = SumSubAccount.secretKey
        else {
            return nil
        }
        
        print("SIGN:\n method: \(method), path(uri): \(uri)")
        //MARK: - sig form - ts+, method
        let ts = String(Int(Date().timeIntervalSince1970))
        let sig = "\(ts)\(method)\(uri)".hmac256(key: secretKey)
        
        print("Before sig:", "\(ts)\(method)\(uri)", "\n")
        print("SIG:", sig, "\n")
                
        return (token: appToken, ts: ts, sig: sig)
    }
    
    // MARK: - Logging
    
    private static func log(_ format: String, _ args: CVarArg...) {
        
        print(Date.formatted, "[YourBackend] " + String(format: format, arguments: args))
    }
}
