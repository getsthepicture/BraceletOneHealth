//
//  ZCCarePlanStoreManager.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit

class ZCCarePlanStoreManager : NSObject, OCKCarePlanStoreDelegate {
    
    
    
    // MARK: Properties
    
    weak var delegate: ZCCarePlanStoreManagerDelegate?
    
    let store: OCKCarePlanStore
    let carePlan : CarePlan!
    
    init(carePlan:CarePlan) {
    
    
        // Determine the file URL for the store.
        let searchPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = searchPaths[0]
        let persistenceDirectoryURL = NSURL(fileURLWithPath: applicationSupportPath)
        
        if !FileManager.default.fileExists(atPath: persistenceDirectoryURL.absoluteString!, isDirectory: nil) {
            try! FileManager.default.createDirectory(at: persistenceDirectoryURL as URL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create the store.
        store = OCKCarePlanStore(persistenceDirectoryURL: persistenceDirectoryURL as URL)
        
        self.carePlan = carePlan
        
        super.init()
        
        store.delegate = self
        
        
        //Populate the care plan store with all activities
        self.updateStore()
        
        
        store.activities { (success, activities, error) in
            
            for a in activities {
                print("No. \(a.identifier) - \(a.title) - \(a.text)")
            }
        }
    }
    
    private func updateStore()-> Void {
        
      
        
        carePlan.allActivities { (activities) in
            
            for newactivity in activities {
                
                //Thsi is safe as we're running on the main thread
                self.store.activity(forIdentifier: newactivity.identifier, completion: { (success, activity, error) in
                    
                    if success && activity != nil {
                        
                        self.store.remove(activity!, completion: { (success, error) in
                            
                            if success {
                                self.addActivityToStore(activity: newactivity)
                            }
                            
                        })
                    }
                    else {
                        self.addActivityToStore(activity: newactivity)
                    }
                    
                })
                
                
            }
            
            
        }
        
        
        
    }
    
    private func addActivityToStore(activity: OCKCarePlanActivity) {
        
        self.store.add(activity) { success, error in
            if !success {
                print(error?.localizedDescription)
            }
            else {
                print("Activity \(activity.identifier)  added to careplan store")
            }
        }
    }

}



extension ZCCarePlanStoreManager {
    private func _clearStore() {
        print("*** CLEANING STORE DEBUG ONLY ****")
        
        let deleteGroup = DispatchGroup()
        let store = self.store
        
        deleteGroup.enter()
        store.activities { (success, activities, errorOrNil) in
            
            guard success else {
                // Perform proper error handling here...
                fatalError(errorOrNil!.localizedDescription)
            }
            
            for activity in activities {
                
                deleteGroup.enter()
                store.remove(activity) { (success, error) -> Void in
                    
                    print("Removing \(activity)")
                    guard success else {
                        fatalError("*** An error occurred: \(error!.localizedDescription)")
                    }
                    print("Removed: \(activity)")
                    deleteGroup.leave()
                }
            }
            
            deleteGroup.leave()
        }
        
        // Wait until all the asynchronous calls are done.
        _ = deleteGroup.wait(timeout: .distantFuture)
       
        //dispatch_group_wait(deleteGroup, DispatchTime.distantFuture.uptimeNanoseconds)
    }
    
    func carePlanStoreActivityListDidChange(store: OCKCarePlanStore) {
        print("Care Plan Store Activity list updated")
    }
    
    func carePlanStore(store: OCKCarePlanStore, didReceiveUpdateOfEvent event: OCKCarePlanEvent) {
        print("Care Plan Store event updated")
    }
}

protocol ZCCarePlanStoreManagerDelegate: class {
    func zcCarePlanStoreManager(manager: ZCCarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem])
}
