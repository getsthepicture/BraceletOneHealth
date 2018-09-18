//
//  Activity.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit
import SwiftyJSON


enum ActivityType: String {
        case Intervention
        case Assessment
}

enum ScheduleType: String {
    case Weekly
    case Daily
}

protocol Activity {
    
    var activityType: ActivityType { get set}
    
    func carePlanActivity() -> OCKCarePlanActivity
}

/**
 Struct that conforms to the Activity protocol to define either an intervention or assessment activity.
 */
struct ZCActivity : Activity {
    
    let identifier : String
    let title : String
    let text : String
    let startDate : Date
    let schedule : [NSNumber]
    let scheduleType : ScheduleType
    var instructions : String?
    let imageURL : NSURL?
    var activityType: ActivityType
    
    init(fromJSON json: JSON, activityType: ActivityType) {
        self.identifier = json["identifier"].string!
        self.title = json["title"].string!
        if let instructionString = json["instructions"].string {
            self.instructions = instructionString
        }
        //self.instructions = json["instructions"].string!
        self.text = json["text"].string!
        if let imageString = json["imageURL"].string {
            self.imageURL = NSURL(string: imageString)
        }
        else {
            self.imageURL = nil
        }
        
        self.startDate = dateFromString(string: json["startdate"].string!)!
        self.scheduleType = ScheduleType(rawValue: json["scheduletype"].string!)!
        
        self.schedule = json["schedule"].string!.components(separatedBy: ",").map ( {
            NSNumber(value: Int32($0)!)
        })
        
        self.activityType = activityType
    }
    
    func carePlanActivity() -> OCKCarePlanActivity {
        
        let startDateComponents = NSDateComponents.init(date: self.startDate, calendar: Calendar.init(identifier: .gregorian))
        
        let activitySchedule: OCKCareSchedule!
        
        switch self.scheduleType {
        case .Weekly:
            activitySchedule = OCKCareSchedule.weeklySchedule(withStartDate: startDateComponents as DateComponents, occurrencesOnEachDay: self.schedule)
        case .Daily:
            activitySchedule = OCKCareSchedule.weeklySchedule(withStartDate: startDateComponents as DateComponents, occurrencesOnEachDay: [self.schedule[0]])
        }
        
        switch activityType {
        case .Intervention:
            
            let activity = OCKCarePlanActivity.intervention(withIdentifier: identifier, groupIdentifier: nil, title: title, text: text, tintColor: UIColor.green, instructions: instructions, imageURL: nil, schedule: activitySchedule, userInfo: nil, optional: false)
            
            return activity
        case .Assessment:
            let activity = OCKCarePlanActivity.assessment(withIdentifier: identifier, groupIdentifier: nil, title: title, text: text, tintColor: UIColor.green, resultResettable: true, schedule: activitySchedule, userInfo: nil, optional: false)
            
            return activity
        }
    }
}


