//
//  Medication.swift
//  Bracelet One
//
//  Created by Laurence Wingo on 10/8/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation

/*
 This class is used to encapsulate some additonal medical  infomation that can be used by the userinfo property for an OCKCarePlanActivity
 
 It has to support NSCOding so it can sotred by the Care Plan Store
 
 */
class Medication : NSObject,  NSCoding {
    
    let medication : String
    let imageURL : NSURL
    
    init?(medication : String, imageURL : NSURL ) {
        
        self.medication = medication
        self.imageURL = imageURL
    }
    
    
    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        
        let medication = decoder.decodeObject(forKey: "medication") as! String
        let imageURL = decoder.decodeObject(forKey: "imageURL")as! NSURL
        
        self.init(medication:medication, imageURL: imageURL)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.medication, forKey: "medication")
        aCoder.encode(self.imageURL, forKey: "imageURL")
    }
}
