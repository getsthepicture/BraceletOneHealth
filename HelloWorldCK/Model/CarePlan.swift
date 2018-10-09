//
//  CarePlan.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation
import CareKit
import SwiftyJSON

/**
    Struct which encapsulates the CarePlan
*/
public struct CarePlan {
    
     let planID: Int
     let title : String
     var activities : [Activity] = []
    
    init (planID:Int, title:String) {
        
        self.planID = planID
        self.title = title
    }
    
    func findAssessmentActivity(assessmentActivity: OCKCarePlanActivity) -> Assessment? {
        
        let activity = self.activities.filter(){ $0.identifier == assessmentActivity.identifier}
        
        guard activity.count == 1 else {return nil}
        
        let act = activity[0] as? Assessment
        
        return act
    }
    
    //Returns all CareKit activities
    func allActivities(completion:(_ activities: [OCKCarePlanActivity])-> Void) {
        
        
        let ckallActivities = activities.map( {
            
            $0.createCareKitActivity()
            
        })
        
        
        completion(ckallActivities)
    }
    
    // Filters and returns an array of CareKit Intervention OCKCarePlanActivity objects
    
    func interventionActivities(completion:(_ activities: [OCKCarePlanActivity])-> Void) {
    
        let interventionActivities = activities.filter(){$0.activityType == .Intervention}
        
        let ckinterventionActivities = interventionActivities.map( {
            
            $0.createCareKitActivity()
        
        })
        
        
        completion(ckinterventionActivities)
    }
    
    // Filters and returns an array of CareKit assessment OCKCarePlanActivity objects
    
    func assessmentActivities(completion:([OCKCarePlanActivity])-> Void) {
        
        let assessmentActivities = activities.filter(){$0.activityType == .Assessment}
        
        let ckassessmentActivities = assessmentActivities.map( {
            
            $0.createCareKitActivity()
            
        })
        
        
        completion(ckassessmentActivities)
    }
}

extension CarePlan : Equatable {}

public func ==(lhs: CarePlan, rhs: CarePlan) -> Bool {
    return lhs.planID == rhs.planID &&
        lhs.title == rhs.title
}


/**
 CarePlan conforms to the ZCAPIResponse protocol.  tthis implementation parses the json  careplan  and maps activities to local immutable Activity Struct

 */
extension CarePlan : ZCAPIResponse {
    
    init?(data:Data?) {
        
        do {
        
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
            
            guard
                let planID = json["planID"] as? Int,
                let title = json["title"] as? String,
                let intervention_activities = json["intervention_activities"] as? Array<NSDictionary>,
                let assessment_activities = json["assessment_activities"] as? Array<NSDictionary>
                
            else { return nil }
            
            self.planID = planID
            self.title = title
            
            for intervention in intervention_activities {
                //let activity = ZCActivity.init()
                let activity = ZCActivity(json: JSON(intervention))
                //let activity = ZCActivity(fromJSON: JSON(intervention), activityType: .Intervention)
                activities.append(activity)
            }
            
            for assessment in assessment_activities {
                //let activity = ZCAssessment.init()
                let activity = ZCAssessment(json: JSON(assessment))
                //let activity = ZCActivity(fromJSON: JSON(assessment), activityType: .Assessment)
                activities.append(activity)
            }
            
        }
        catch {
            print("Failed to initialise CarePlan")
            return nil
        }
        
    }
    
}
