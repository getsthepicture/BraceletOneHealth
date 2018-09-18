//
//  ZCServiceProvider.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation

// Helper method to create a particular service.

func newZCService(type: ZCServiceType) -> ZCService {
    
    switch type {
        
    //TODO: Addother type . i.e test, real back end etc
    case .Mock:
        return MockService()
    }
}

func dateFromString(string: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
    if let date = dateFormatter.date(from: string) {
        return date
    }
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
    if let date = dateFormatter.date(from: string) {
        return date
    }
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = dateFormatter.date(from: string) {
        return date
    }
    return nil
}
