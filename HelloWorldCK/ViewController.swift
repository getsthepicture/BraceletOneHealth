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

class ViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    @IBOutlet var reserachKitExampleButton: UIButton!
    
    @IBOutlet var careKitExampleButton: UIButton!
    
    @IBOutlet var zombieHealthCareButton: UIButton!
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showCareCard(_ sender: UIButton) {
        print("Care Card Presentation...")
        
    }
    
    @IBAction func assesmentOneButtonPressed(_ sender: UIButton) {
        showHelloWorld()
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
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

