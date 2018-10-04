//
//  CognitoUserPoolController.swift
//  Bracelet One
//
//  Created by Laurence Wingo on 10/4/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//
//this class will be a singleton design pattern and will deal with all the logic that deals with the Amazon Cognito user pool for Bracelet One
import Foundation
import AWSCognitoIdentityProvider


class CognitoUserPoolController {
    let userPoolRegion: AWSRegionType = .USEast2
    let userPoolID = "us-east-2_8HngeMx7i"
    let appClientID = "557bu6l1ktvcldetvursq6o40v"
    let appClientSecret = "1ftnk2ers58mr5mdeejt669sfceavih0kf1l6dbj8r9fqha3m24k"
    //the private variable below is an instance of the AWSCognitoIdentityUserPool class that represents the user pool that this class manages.
    private var userPool: AWSCognitoIdentityUserPool?
    //this read-only variable called 'currentUser' is an instance of the AWSCognitoIdentityUser class; it represents the authenticated user.
    var currentUser: AWSCognitoIdentityUser?{
        get {
            return userPool?.currentUser()
        }
    }
    //to ensure this class 'CognitoUserPoolController' is a singleton, the static variable below does this along with the private init method.
    static let sharedInstance: CognitoUserPoolController = CognitoUserPoolController()
    private init() {
        let serviceConfiguration = AWSServiceConfiguration.init(region: userPoolRegion, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration.init(clientId: appClientID, clientSecret: appClientSecret, poolId: userPoolID)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: "BraceletOneAWSAppClient")
        userPool = AWSCognitoIdentityUserPool.init(forKey: "BraceletOneAWSAppClient")
        AWSDDLog.sharedInstance.logLevel = .verbose
    }
    
    //the method below allows users to log in to the Bracelet One app:
    func login(username: String, password: String, completion: @escaping (Error?)->Void) {
        let user = self.userPool?.getUser(username)
        let task = user?.getSession(username, password: password, validationData: nil)
        task?.continueWith(block: { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        })
    }
    //the method below allows users to sign up for the Bracelet One app:
    func signup(username: String, password: String, emailAddress: String, completion: @escaping (Error?, AWSCognitoIdentityUser?) -> Void) {
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        let emailAttribute = AWSCognitoIdentityUserAttributeType.init(name: "email", value: emailAddress)
        attributes.append(emailAttribute)
        let task = self.userPool?.signUp(username, password: password, userAttributes: attributes, validationData: nil)
        task?.continueWith(block: { (task) -> Any? in
            if let error = task.error {
                completion(error, nil)
                return nil
            }
            guard let result = task.result else {
                let error = NSError.init(domain: "com.cosmicarrows.Intellect", code: 100, userInfo: ["__type":"Unknown Error", "message":"Cognito user pool error."])
                completion(error, nil)
                return nil
            }
            completion(nil, result.user)
            return nil
        })
    }
    //the method below handles the task of sending the confirmation code that has been entered by the user to the Amazon Cognito service:
    func confirmSignup(user: AWSCognitoIdentityUser, confirmationCode: String, completion: @escaping (Error?) -> Void) {
        let task = user.confirmSignUp(confirmationCode)
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        }
    }
    //the method below allows the user to resend the confirmation code to the e-mail address used during signup:
    func resendConfirmationCode(user: AWSCognitoIdentityUser, completion: @escaping (Error?) -> Void) {
        let task = user.resendConfirmationCode()
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        }
    }
    //the method below allows another view controller to log some information on the authenticated user to the Xcode console:
    func getUserDetails(user: AWSCognitoIdentityUser, completion: @escaping (Error?, AWSCognitoIdentityUserGetDetailsResponse?) -> Void) {
        let task = user.getDetails()
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error, nil)
                return nil
            }
            guard let result = task.result else {
                let error = NSError.init(domain: "com.cosmicarrows.Intellect", code: 100, userInfo: ["__type":"Unknown Error", "message":"Cognito user pool error."])
                completion(error, nil)
                return nil
            }
            completion(nil, result)
            return nil
        }
    }
    

}

