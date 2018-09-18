//
//  MockResource.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation

struct MockResource : ZCAPIResource {
    
    let path: String
    let method: String?
    let headers: [String : String]?
    let parameters: [String : AnyObject]?
    
    init(path: String,
         method: String? = "GET",
         headers: [String: String]? = nil,
         parameters: [String: AnyObject]? = nil) {
        
        
        self.path = path
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
}


// MARK: - Equatable
extension MockResource: Equatable {}

func ==(lhs: MockResource, rhs: MockResource) -> Bool {
    return lhs.path == rhs.path &&
        lhs.method == rhs.method &&
        lhs.headers! == rhs.headers! &&
        lhs.parameters as NSDictionary? == rhs.parameters as NSDictionary?
}
