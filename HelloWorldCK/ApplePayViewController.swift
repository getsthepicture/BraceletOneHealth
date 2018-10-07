//
//  ApplePayViewController.swift
//  AcceptSDKSampleApp
//
//  Created by Ramamurthy, Rakesh Ramamurthy on 8/4/16.
//  Copyright © 2016 Ramamurthy, Rakesh Ramamurthy. All rights reserved.
//

import Foundation
import PassKit
import AWSCognitoIdentityProvider

class ApplePayViewController:UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    @IBOutlet weak var applePayButton:UIButton!
    var isAuthenticated = false
    var didReturnFromBackground = false

    @objc let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        isAuthenticated = false
        performSegue(withIdentifier: "loginView", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoginView()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.headerView.backgroundColor = UIColor.init(red: 48.0/255.0, green: 85.0/255.0, blue: 112.0/255.0, alpha: 1.0)
//        self.applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillResignActive(_:)),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appDidBecomeActive(_:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        //write user's email address to console log
        let userpoolController = CognitoUserPoolController.sharedInstance
        
        userpoolController.getUserDetails(user: userpoolController.currentUser!) { (error: Error?, details: AWSCognitoIdentityUserGetDetailsResponse?) in
            if let userAttributes = details?.userAttributes {
                for attribute in userAttributes {
                    if attribute.name?.compare("email") == .orderedSame {
                        print("Email address of logged-in user is \(attribute.value!)")
                    }
                }
            }
        }
    }
    
    @IBAction func payWithApplePay(_ sender: AnyObject) {
        
        let supportedNetworks = [ PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa ]
        
        if PKPaymentAuthorizationViewController.canMakePayments() == false {
            let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) == false {
            let alert = UIAlertController(title: "No Apple Pay payment methods available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }

        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = "merchant.authorize.net.test.dev15"
        request.supportedNetworks = SupportedPaymentNetworks
        // DO NOT INCLUDE PKMerchantCapability.capabilityEMV
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: 40.00)
        ]

        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        
        self.present(applePayController!, animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        print("paymentAuthorizationViewController delegates called")

        if payment.token.paymentData.count > 0 {
            let base64str = self.base64forData(payment.token.paymentData)
            let messsage = String(format: "Data Value: %@", base64str)
            let alert = UIAlertController(title: "Authorization Success", message: messsage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.performApplePayCompletion(controller, alert: alert)
        } else {
            let alert = UIAlertController(title: "Authorization Failed!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            return self.performApplePayCompletion(controller, alert: alert)
        }
    }
    
    @objc func performApplePayCompletion(_ controller: PKPaymentAuthorizationViewController, alert: UIAlertController) {
        controller.dismiss(animated: true, completion: {() -> Void in
            self.present(alert, animated: false, completion: nil)
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
    @objc func base64forData(_ theData: Data) -> String {
        let charSet = CharacterSet.urlQueryAllowed

        let paymentString = NSString(data: theData, encoding: String.Encoding.utf8.rawValue)!.addingPercentEncoding(withAllowedCharacters: charSet)
        
        return paymentString!
    }
    
    @objc func appWillResignActive(_ notification : Notification) {
        view.alpha = 0
        isAuthenticated = false
        didReturnFromBackground = true
    }
    
    @objc func appDidBecomeActive(_ notification : Notification) {
        if didReturnFromBackground {
            showLoginView()
            view.alpha = 1
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        isAuthenticated = true
        view.alpha = 1.0
    }
    
    
    
    func showLoginView() {
        if !isAuthenticated {
            performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    
    func writeUsersEmailToConsole() {
        let userpoolController = CognitoUserPoolController.sharedInstance
        userpoolController.getUserDetails(user: userpoolController.currentUser!) {
            (error: Error?,
            details) in
            if let userAttributes = details?.userAttributes {
                for attribute in userAttributes {
                    if attribute.name?.compare("email") == .orderedSame {
                        print ("Email address of logged-in user is \(attribute.value!)")
                    }
                }
            }}
    }
    
    
}
