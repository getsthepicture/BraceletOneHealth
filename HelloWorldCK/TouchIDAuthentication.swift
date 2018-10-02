//
//  TouchIDAuthentication.swift
//  HelloWorldCK
//
//  Created by Laurence Wingo on 10/2/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation
import LocalAuthentication

//using this enum to determine which biometric type is available on the device
enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricIDAuth {
    let context = LAContext()
    let loginReason = "Logging in with Touch ID"
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        }
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {//1 this function takes a closure which serves as the completion handler
        //2 guard if canEvaluatePolicy returns true else return out of the function
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        //3 if the device supports biometric ID, then we call the following method to begin the policy evaluation by prompting the user for biometric ID authentication.
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            //4 if the authentication is successfull then we will dismiss the login view
            if success {
                DispatchQueue.main.async {
                    //User authenticated successfully, take appropriate action
                    completion(nil)
                }
            }else{
                // TODO: deal with local authentication error cases
                let message: String
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                case LAError.biometryNotAvailable?:
                    message = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled?:
                    message = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout?:
                    message = "Face ID/Touch ID is locked."
                default:
                    message = "Face ID/Touch ID may not be configured"
                }
                completion(message)
            }
        }
    }
}
