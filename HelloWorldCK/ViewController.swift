//
//  ViewController.swift
//  HelloWorldCK
//
//  Created by Laurence Wingo on 9/13/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import UIKit
import ResearchKit
import CareKit
import AWSCognitoIdentityProvider


class ViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    @IBOutlet var reserachKitExampleButton: UIButton!
    
    @IBOutlet var careKitExampleButton: UIButton!
    
    @IBOutlet var zombieHealthCareButton: UIButton!
    
    var isAuthenticated = false
    var didReturnFromBackground = false
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showCareCard(_ sender: UIButton) {
        print("Care Card Presentation...")
        
    }
    
    @IBAction func assesmentOneButtonPressed(_ sender: UIButton) {
        showHelloWorld()
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        isAuthenticated = false
        performSegue(withIdentifier: "loginView", sender: self)
    }
    
    func showHelloWorld(){
        let step1 = ORKInstructionStep.init(identifier: "step1")
        step1.title = "Hello World"
        let step2 = ORKInstructionStep.init(identifier: "step2")
        step2.title = "ByE!"
        
        let task = ORKOrderedTask.init(identifier: "Task", steps: [step1, step2])
        
        let taskViewController = ORKTaskViewController.init(task: task, taskRun: nil)
        taskViewController.view.backgroundColor = UIColor.red
        
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        reserachKitExampleButton.layer.cornerRadius = 10
        careKitExampleButton.layer.cornerRadius = 10
        zombieHealthCareButton.layer.cornerRadius = 10
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        showLoginView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

