//
//  Assessment.swift
//  Bracelet One
//
//  Created by Laurence Wingo on 10/8/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation
import CareKit
import ResearchKit
import SwiftyJSON


/*
 A protocol for Assessment Activities that extends the Actvity protocol
 */
protocol Assessment : Activity {
    
    var taskIdentifier : String  { get set }
    
    var steps : [ActivityStep] {get set}
    
}

/*
 A protocol for Activity Steps.
 */
protocol ActivityStep {
    
    var stepIdentifier : String  { get set }
    var question : String  { get set }
    var format :  StepFormat {get set}
    var unit : String  { get set }
    var maxValueDescription : String  { get set }
    var minValueDescription : String  { get set }
    var defaultValue : Int  { get set }
    var maxValue : Int  { get set }
    var minValue : Int  { get set }
    var step : Int  { get set }
    var vertical : Bool  { get set }
    
    init()
    init(json:JSON)
}

/*
 This extension provides an initaliser for Activty steps to parde the json
 */
extension ActivityStep {
    
    init(json:JSON) {
        
        self.init()
        
        self.stepIdentifier = json["identifier"].string!
        
        self.question = json["title"].string!
        
        self.format = StepFormat(rawValue: json["format"].string!)!
        
        switch self.format {
        case .Quantity:
            
            self.unit = json["unit"].string!
            
        case .Scale:
            
            self.maxValueDescription = json["maxvaluedescription"].string!
            self.minValueDescription = json["minvaluedescription"].string!
            self.defaultValue = json["defaultvalue"].int!
            self.minValue = json["minvalue"].int!
            self.maxValue = json["maxvalue"].int!
            self.step =  json["stepvalue"].int!
            self.vertical =  json["vertical"].bool!
            
            
        }
        
    }
}

/*
 The Assessment extension provides an initaliser for parsing json. It has overrides the createCareKitActivity function
 to provide is own implemnetation as well as additional createTask() fucntion as it adopts the Assessment protocol
 */

extension Assessment {
    
    
    
    init(json: JSON) {
        
        self.init()
        
        self.parseActivityFields(json: json)
        
        
        let task = json["task"]
        
        self.taskIdentifier = task["identifier"].string!
        
        
        let taskSteps = task["steps"].array!
        
        for step in  taskSteps{
            
            let stepJson = step
            
            let zcStep = ZCActivityStep(json: stepJson)
            
            self.steps.append(zcStep)
        }
        
        
        
    }
    
    func createCareKitActivity() -> OCKCarePlanActivity{
        
        //creates a schedule based on the internal values for start and end dates
        let startDateComponents = NSDateComponents(date: self.startDate, calendar: NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)! as Calendar)
        
        let activitySchedule: OCKCareSchedule!
        
        switch self.scheduleType {
        case .Weekly :
            activitySchedule = OCKCareSchedule.weeklySchedule(withStartDate: startDateComponents as DateComponents, occurrencesOnEachDay: self.schedule)
            
        case .Daily:
            activitySchedule = OCKCareSchedule.dailySchedule(withStartDate: startDateComponents as DateComponents, occurrencesPerDay: self.schedule[0].uintValue)
            
        }
        let activity = OCKCarePlanActivity.assessment(withIdentifier: identifier, groupIdentifier: groupIdentifier, title: title, text: text, tintColor: colour, resultResettable: true, schedule: activitySchedule, userInfo: nil, optional: false)
        
        
        return activity
        
    }
    
    
    
    
}

/*
 ZCActivityStep struct provides a concrete implemtaiton for Activty Steps
 */
struct ZCActivityStep : ActivityStep {
    var stepIdentifier : String
    var question : String
    var format :  StepFormat
    var unit : String
    var maxValueDescription : String
    var minValueDescription : String
    var defaultValue : Int
    var maxValue : Int
    var minValue : Int
    var step : Int
    var vertical : Bool
    
    init() {
        stepIdentifier = ""
        question = ""
        format = .Quantity
        unit = ""
        maxValueDescription = ""
        minValueDescription = ""
        defaultValue = -1
        maxValue = 10
        minValue = 1
        step = 1
        vertical = true
    }
    
}

/*
 ZCAssessment struct provides a concrete implemtnation for Activty and Assessment protocols
 */

struct ZCAssessment : Activity, Assessment {
    var identifier : String
    var groupIdentifier: String
    var title : String
    var colour : UIColor? = nil
    var text : String
    var startDate : Date = Date()
    var schedule : [NSNumber] = []
    var scheduleType : ScheduleType
    var instructions : String? = nil
    var imageURL : NSURL? = nil
    var activityType: ActivityType = .Assessment
    var medication : Medication? = nil
    
    var taskIdentifier: String
    var steps : [ActivityStep] = []
    
    init() {
        
        identifier = ""
        groupIdentifier = ""
        title = ""
        text = ""
        scheduleType = .Daily
        taskIdentifier = ""
        
    }
    
    
}

