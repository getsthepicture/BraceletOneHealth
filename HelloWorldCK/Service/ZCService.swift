//
//  ZCService.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation

/**
 Protocols whihc define the ZCService, Resource and Responses.
 
 These protocols define how a remote, test or even a mock  service can be implemented
 */

public enum ZCServiceType: String {
    case Mock = "Mock"
    
    //Others
    
    public static let allCases = [ Mock]
}

// Defines the request method that all services should use to load data
protocol ZCService {
    
    func request<T: ZCAPIResource, R: ZCAPIResponse>(resource:T, completion:(_ response:R?, _ error:NSError?)->Void)
}

//defines the service request configuration

protocol ZCAPIResource {
    init(path:String, method:String?, headers:[String:String]?, parameters:[String:AnyObject]?)
    
    var path: String { get }
    var method: String? { get }
    var headers: [String:String]? { get }
    var parameters: [String:AnyObject]? { get }
}

//defines a response initialiser

protocol ZCAPIResponse {
    init?(data:Data?)
}


