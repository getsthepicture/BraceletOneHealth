//
//  CarePlanViewController.swift
//  Bracelet One
//
//  Created by Laurence Wingo on 10/6/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation
import UIKit
import CareKit

class CarePlanViewController: UIViewController {
    
    @IBOutlet weak var carePlanTitle: UILabel!
    @IBOutlet weak var carePlanDescription: UILabel!
    
    var careplanManager : ZCCarePlanStoreManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let service = newZCService(type: .Mock)
        
        let mockResource = MockResource(path: "careplan", method: "GET", headers: nil, parameters: nil)
        
        service.request(resource: mockResource) { (response:CarePlan?, error) in
            if error == nil {
                print("\(response!.title) loaded")
                self.careplanManager = ZCCarePlanStoreManager.init(carePlan: response!)
                self.carePlanTitle.text = self.careplanManager?.carePlan.title
                //self.carePlanDescription.text = self.careplanManager?.carePlan.carePlanDescription
            }
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BuildCareCard(sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let tabbarcontroller = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let careCardViewController = createCareCardViewController()
        tabbarcontroller.viewControllers = [UINavigationController(rootViewController: careCardViewController)]
        self.present(tabbarcontroller, animated: true, completion: nil)
    }
    
    private func createCareCardViewController() -> OCKCareCardViewController{
        let viewController = OCKCareCardViewController.init(carePlanStore: careplanManager!.store)
        //Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Care Plan", comment: "")
        viewController.tabBarItem = UITabBarItem.init(title: viewController.title, image: UIImage.init(named: "carecard"), selectedImage: UIImage.init(named: "carecard-filled"))
        return viewController
    }
    
    
}
