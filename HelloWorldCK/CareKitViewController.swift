//
//  CareKitViewController.swift
//  HelloWorldCK
//
//  Created by Laurence Wingo on 9/13/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import UIKit
import CareKit

class CareKitViewController: UIViewController {
    
    let store: OCKCarePlanStore
    
    required init?(coder aDecoder: NSCoder) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last else {
            fatalError("*** Error: Unable to get the document directory! ***")
        }
        let storeURL = documentDirectory.appendingPathComponent("HelloCareKitStore")
        if !fileManager.fileExists(atPath: storeURL.path) {
            try! fileManager.createDirectory(at: storeURL, withIntermediateDirectories: true, attributes: nil)
        }
        store = OCKCarePlanStore.init(persistenceDirectoryURL: storeURL)
        super.init(coder: aDecoder)
    }
    
    func createActivity(){
        let myMedicationIdentifier = "HelloActivity"
        store.activity(forIdentifier: myMedicationIdentifier) { (success, foundActivity, error) in
            guard success else {
                //perform real error handling here.
                fatalError("*** An error occurred \(error?.localizedDescription) ***")
            }
            if let activity = foundActivity{
                //activity already exists
                print("Activity found - \(activity.identifier)")
            }else{
                let startDay = DateComponents.init(calendar: nil, timeZone: nil, era: nil, year: 2018, month: 9, day: 13, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                let thriceADay = OCKCareSchedule.dailySchedule(withStartDate: startDay, occurrencesPerDay: 3)
                let medication = OCKCarePlanActivity.init(identifier: myMedicationIdentifier, groupIdentifier: nil, type: OCKCarePlanActivityType.intervention, title: "Hello World", text: "Say it out lound!", tintColor: nil, instructions: "Say Hello to the world 3 times a day.  This should make you feel better.  It is not recommended to drive with this medication.  For any severe side effects, please contact your physician in the INSIGHTS section of the app.", imageURL: nil, schedule: thriceADay, resultResettable: true, userInfo: nil)
                self.store.add(medication, completion: { (success, error) in
                    guard success else {
                        //perform real error handling here if unsuccessful...
                        fatalError("*** An error occurred \(error?.localizedDescription)")
                    }
                })
                
            }
        }
    }
    
    @IBAction func showCareCard(_ sender: UIButton) {
        let careCardViewController = OCKCareCardViewController.init(carePlanStore: store)
        self.navigationController?.pushViewController(careCardViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createActivity()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
