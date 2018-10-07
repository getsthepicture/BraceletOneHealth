//
//  EmoryHealthViewController.swift
//  HelloWorldCK
//
//  Created by Laurence Wingo on 9/13/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import UIKit

class EmoryHealthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let service = newZCService(type: .Mock)
        let mockResource = MockResource.init(path: "careplan", method: nil, headers: nil, parameters: nil)
        service.request(resource: mockResource) { (response : CarePlan?, error) in
            if error == nil {
                print("\(response!.title) loaded.")
                _ = ZCCarePlanStoreManager.init(carePlan: response!)
            }
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
