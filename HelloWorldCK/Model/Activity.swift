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
    let instructions : String?
    let imageURL : NSURL?
    var activityType: ActivityType
    let colorcolorcolor: UIColor?
    
    init(fromJSON json: JSON, activityType: ActivityType) {
        self.identifier = json["identifier"].string!
        self.title = json["title"].string!
        self.text = json["text"].string!
        let colorcolorcolorString = json["color"].string!
        let eventColor = UIColor.colorWithString(colorcolorcolorString)
        self.colorcolorcolor = eventColor
        //self.colorcolorcolor = json["color"].string!
        
        if let instructionString = json["instructions"].string {
            self.instructions = instructionString
        }
        else {
            self.instructions = nil
        }
        
        
        if let imageString = json["imageURL"].string {
            self.imageURL = NSURL(string: imageString)
        }
        else {
            self.imageURL = nil
        }
        self.startDate = dateFromString(string: json["startdate"].string!)!
        self.scheduleType = ScheduleType(rawValue: json["scheduletype"].string!)!
        
        self.schedule = (json["schedule"].string?.components(separatedBy: ",").map( {
            NSNumber(value: Int32($0)!)
        }))!
       
        
        self.activityType = activityType
    }
    
    func carePlanActivity() -> OCKCarePlanActivity {
        
        //creates a schedule based on the internal values for start and end dates
  
        let startDateComponents = NSDateComponents(date: self.startDate, calendar: NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)! as Calendar)
        
        
        let activitySchedule: OCKCareSchedule!
        
        switch self.scheduleType {
        case .Weekly :
            activitySchedule = OCKCareSchedule.weeklySchedule(withStartDate: startDateComponents as DateComponents, occurrencesOnEachDay: self.schedule)
            
        case .Daily:
            activitySchedule = OCKCareSchedule.dailySchedule(withStartDate: startDateComponents as DateComponents, occurrencesPerDay: self.schedule[0].uintValue)
            
        }
        
        
        //creates and returns the approprate CareKit OCKCarePlanActivity
        switch activityType {
        case .Intervention:
            let activity = OCKCarePlanActivity.intervention(withIdentifier: identifier, groupIdentifier: nil, title: title, text: text, tintColor: colorcolorcolor, instructions: instructions, imageURL: nil, schedule: activitySchedule, userInfo: nil, optional: false)
           
            
            return activity
        case .Assessment:
            let activity = OCKCarePlanActivity.assessment(withIdentifier: identifier, groupIdentifier: nil, title: title, text: text, tintColor: UIColor.red, resultResettable: true, schedule: activitySchedule, userInfo: nil, optional: false)
            
            
            return activity
        }
        
    }
    
 
}


