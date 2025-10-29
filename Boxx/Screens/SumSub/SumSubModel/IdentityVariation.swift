//
//  IdentityVariation.swift
//  sumsub test_UIKIT
//
//  Created by Namerei on 28.04.24.
//
import Foundation
import IdensicMobileSDK

struct IdentityVerification {
    var user: User?
        
    static var sdk: SNSMobileSDK!
        
    static func launch(
        from yourVC: UIViewController,
        for user: User?,
        accessToken: String = "",
        locale: String? = nil)
    {

        // Notes:
        //
        // 1. The applicant to be verified (a user) and the steps the verification process consists of (an applicant level)
        //    are defined by the `accessToken` you take from your backend and pass over to the sdk initialization.
        //
        //    The access token is valid for a rather short period of time and when it's expired
        //    you must provide another one. In order to do so you will ask your backend and most likely the backend
        //    will need to know the user's identifier. This is the only reason we have passed down `User` here.
        //    It's used within `tokenExpirationHandler` in order to communicate to `YourBackend`.
        //
        // 2. You can either provide the `accessToken` right at the initializaton stage,
        //    or pass it as an empty string initially and supply it later on with `tokenExpirationHandler`.
        //    The second way allows you not to worry about spinners and so on. We'll go this way below.
        //
        // 3. The `locale` parameter can be nil or any string in a form of "en" or "en_US".
        //    In the case of nil, the system locale will be used automatically.
                
        // MARK: Initialization
        //
        log("Initialization")
        
        // Most likely you will integrate the sdk using the production/sandbox environment,
        // thus there will be no need to pass the `environment` parameter at the initialization method.
        // This way the sdk will work in the production or in the sandbox environment
        // depend on which one the `accessToken` has been generated on.
        let environment = SumSubAccount.getEnvironment()
        
        sdk = SNSMobileSDK(
            accessToken: accessToken,
            environment: environment
        )
        
        guard sdk.isReady else {
            logAndAlert("Initialization failed: " + sdk.verboseStatus)
            return
        }
        
        // MARK: tokenExpirationHandler
        //
        // The access token has a limited lifespan and when it's expired, you must provide another one.
        // Get a new token using your backend, then call `onComplete` to pass the new token back.
        //
        sdk.tokenExpirationHandler { (onComplete) in
            
            YourBackend.getAccessToken(for: user) { (error, newToken) in
                
                if let error = error {
                    log("Failed to get new access token from the backend: \(error.localizedDescription)")
                }
                
                onComplete(newToken)
            }
        }

        // MARK: Advanced Setup
        //
        // It's optional and could be skipped
        //
        setupLogging()
        setupHandlers()
        setupCallbacks()
        setupSupportItems()
        setupLocalization(locale)
        setupTheme()

        // MARK: Presentation
        //
        log("Presentation")
        
        yourVC.present(sdk.mainVC, animated: true, completion: nil)
    }

    static func setupLogging() {
        
        #if DEBUG
        
        // MARK: logLevel
        //
        // Change `logLevel` to see more info in the console (the default level is `.error`)
        //
        sdk.logLevel = .info
        
        // MARK: logHandler
        //
        // By default, the SDK uses `NSLog` for logging purposes. If it doesn't work, you may use `logHandler`.
        //
        sdk.logHandler { (level, message) in
            print(Date.formatted, "[Idensic] \(message)")
        }
        
        #else
        
        // Perhaps it's a good idea to shut the logs down in production
        sdk.logLevel = .off
        
        #endif
    }
    
    static func setupHandlers() {
        
        // MARK: verificationHandler
        //
        // Fired when the verification process is completed and a final decision has been made
        //
        sdk.verificationHandler { (isApproved) in
            log("verificationHandler: Applicant is " + (isApproved ? "approved" : "finally rejected"))
        }
        
        // MARK: dismissHandler
        //
        // If `dismissHandler` is assigned, it's up to you to dismiss the `mainVC` controller.
        //
        sdk.dismissHandler { (sdk, mainVC) in
            mainVC.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        // MARK: actionResultHandler
        //
        // An optional way to get notified when a Face Auth action's result has arrived from the backend.
        // The user sees the "Processing..." screen at this moment.
        //
        sdk.actionResultHandler { (sdk, result, onComplete) in
            
            log("Face Auth action result handler: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
            
            // You are allowed to process the result asynchronously, just don't forget to call `onComplete` when you finished,
            // you could pass `.cancel` to force the user interface to be closed, or `.continue` to proceed as usual
            onComplete(.continue)
        }
    }
        
    static func setupCallbacks() {
        
        // MARK: onStatusDidChange
        //
        // Fired when the SDK's status has been updated
        //
        sdk.onStatusDidChange { (sdk, prevStatus) in
                        
            let prevStatusDesc = sdk.description(for: prevStatus)
            let lastStatusDesc = sdk.description(for: sdk.status)
            let failReasonDesc = sdk.description(for: sdk.failReason)

            let description: String
            
            switch sdk.status {
            case .ready:
                description = "Ready to be presented"
                
            case .failed:
                description = "failReason: [\(failReasonDesc)] \(sdk.verboseStatus)"
                
            case .initial:
                description = "No verification steps are passed yet"
                
            case .incomplete:
                description = "Some but not all of the verification steps have been passed over"
                
            case .pending:
                description = "Verification is pending"
                
            case .temporarilyDeclined:
                description = "Applicant has been declined temporarily"
                
            case .finallyRejected:
                description = "Applicant has been finally rejected"
                
            case .approved:
                description = "Applicant has been approved"
                
            case .actionCompleted:
                description = "Face Auth action has been completed (see `sdk.actionResult` for details"
            }
            
            log("onStatusDidChange: [\(prevStatusDesc)] -> [\(lastStatusDesc)] \(description)")
        }
        
        // MARK: onEvent
        //
        // Subscribing to `onEvent` allows you to be aware of the events happening along the processing
        //
        sdk.onEvent { (sdk, event) in
            
            switch event.eventType {
            
            case .applicantLoaded:
                if let event = event as? SNSEventApplicantLoaded {
                    log("onEvent: Applicant [\(event.applicantId)] has been loaded")
                }
                
            case .stepInitiated:
                if let event = event as? SNSEventStepInitiated {
                    log("onEvent: Step [\(event.idDocSetType)] has been initiated")
                }
                
            case .stepCompleted:
                if let event = event as? SNSEventStepCompleted {
                    log("onEvent: Step [\(event.idDocSetType)] has been \(event.isCancelled ? "cancelled" : "fulfilled")")
                }
                
            case .analytics:
                // Uncomment to see the details
                // if let event = event as? SNSEventAnalytics {
                //     log("onEvent: Analytics event [\(event.eventName)] has occured with payload=\(event.eventPayload ?? [:])")
                // }
                break

            @unknown default:
                log("onEvent: eventType=[\(event.description(for: event.eventType))] payload=\(event.payload)")
            }
            
        }

        // MARK: onDidDismiss
        //
        // A way to be notified when `mainVC` is dismissed
        //
        sdk.onDidDismiss { (sdk) in

            let lastStatusDesc = sdk.description(for: sdk.status)
            let failReasonDesc = sdk.description(for: sdk.failReason)
            
            var description: String
            
            switch sdk.status {
            case .actionCompleted:
                if let result = sdk.actionResult {
                    description = "Face Auth action result: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")"
                } else {
                    description = "Face Auth action was cancelled"
                }
                    
            default:
                description = "Identity verification status is "
                if sdk.isFailed {
                    description += "[\(lastStatusDesc):\(failReasonDesc)] \(sdk.verboseStatus)"
                } else {
                    description += "[\(lastStatusDesc)]"
                }
            }
            
            log("onDidDismiss: \(description)")
            
//            App.showToast(description)
        }
    }
    
    static func setupSupportItems() {
        
        // MARK: addSupportItem
        //
        // Add Support Items if required
        //
        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("URL Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to open an url", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionURL = URL(string: "https://google.com")
        }
        
        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("Callback Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to get callback fired", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionHandler { (supportVC, item) in
                logAndAlert("[\(item.title)] tapped")
            }
        }
    }
    
    static func setupLocalization(_ locale: String?) {
        
        // MARK: locale
        //
        // Set the locale the sdk should use for texts (the system locale will be used by default)
        // Use locale in a form of `en` or `en_US`
        //
        sdk.locale = locale
    }

    static func setupTheme() {
        
        // MARK: theme
        //
        // You could either adjust UI in place,
        //
        sdk.theme.fonts.headline1 = .systemFont(ofSize: 24, weight: .bold)
        
        // or apply your own Theme if it's more convenient
        sdk.theme = OwnTheme()
    }
}

// MARK: -

fileprivate class OwnTheme: SNSTheme {
    override init() {
        super.init()
        
        fonts.headline1 = .systemFont(ofSize: 24, weight: .bold)
    }
}

// MARK: - Helpers

extension IdentityVerification {
    
    static func log(_ message: String) {
        print(Date.formatted, "[IdentityVerification] " + message)
    }
    
    static func logAndAlert(_ message: String) {
        log(message)
//        App.showAlert(message)
    }
}

