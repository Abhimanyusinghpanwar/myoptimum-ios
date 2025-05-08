//
//  XCTestConstants.swift
//  CustSupportAppUITests
//
//  Created by vengatesh.c on 16/05/24.
//

import Foundation

struct XCTestConstants
{
    struct LoginCredentials
    {
//        static let OptimumID = "gen7dev"
//        static let Password = "Altice123098"
//        static let OptimumID = "XGS6E43"
//        static let Password = "MOAgk250"
        static let OptimumID = "myoptdevtest3"
        static let Password = "CMAmyoptimum23"
        
        
        static let DummyID = "userID"
        static let DummyPassword = "Password"
    }
    
    func getLoginParams(id:String,password:String) -> [String: AnyObject]
    {
        var params = [String: AnyObject]()
        params["grant_type"] = "password" as AnyObject?
        params["username"] = id as AnyObject?
        params["username"] = params["username"]?.trimmingCharacters(in: .whitespaces) as AnyObject?
        params["password"] = password as AnyObject?
        return params
    }
}
