//
//  HWCareMonthlySchedule.swift
//  HelloWorldCK
//
//  Created by Chris Baxter on 31/05/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit

public class ZCCareMonthlySchedule : OCKCareSchedule  {
    
    var calendar: NSCalendar?
    
    public class func monthlyScheduleWithStartDate(startDate: NSDateComponents,  occurrencesFromJanuaryToDecember: [NSNumber], monthsToSkip: UInt, endDate: NSDateComponents?) -> ZCCareMonthlySchedule? {
        
        guard occurrencesFromJanuaryToDecember.count == 12
            else { return nil}
        
        //TODO: Requires fixing after CareKit is updated to handle sub classes
        
//        let schedule = super.initWithStartDate(startDate: startDate, endDate: endDate, occurrences: occurrencesFromJanuaryToDecember, timeUnitsToSkip: monthsToSkip)
       
    
        
       
        return nil
        
    }
    

    
    override public var type: OCKCareScheduleType {
        return OCKCareScheduleType.other
    }
    
    
    
    override public func numberOfEvents(onDate date: DateComponents) -> UInt {
        
        calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        calendar!.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        
        
        let startMonth = calendar?.ordinality(of: NSCalendar.Unit.month, in: NSCalendar.Unit.era, for: self.startDate.date! )
        let endMonth = calendar?.ordinality(of: NSCalendar.Unit.month, in: NSCalendar.Unit.era, for: date.date! )
        let monthsSinceStart = startMonth! - endMonth!
        let month = calendar?.component(NSCalendar.Unit.month, from: date.date!)
        
        //TODO:  Add a unit test to verify this works
        let occurrences : UInt = ((UInt(monthsSinceStart) % (self.timeUnitsToSkip + 1)) == 0) ? self.occurrences[month!-1].uintValue : 0;
        
        return occurrences;
    }
    
    
    
    //MARK: NSSecureCoding Support
    
    
    override public static var supportsSecureCoding: Bool{
        return true
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        
        self.init(coder: aDecoder)
        
    }
    
    //MARK: NSCopying Support
    override public func copy(with zone: NSZone?) -> Any {
        
        let theCopy = super.copy(with: zone) as! ZCCareMonthlySchedule
        
        return theCopy
    }
    
}
