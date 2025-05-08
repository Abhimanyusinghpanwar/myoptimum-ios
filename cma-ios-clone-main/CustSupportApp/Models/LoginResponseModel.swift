//
//  LoginResponseModel.swift
//  CustSupportApp
//
//  Created by Namarta on 20/05/22.
//

import Foundation

// MARK: - Login Response
struct LoginResponse: Decodable {
    var access_token: String?
    var token_type: String?
    var expires_in: Int64?
    var scope: String?
    var timestamp: String?
    var error: String?
    var error_description: String?
    var dictionary: [String: Any] {
        return ["access_token":access_token as Any, "token_type":token_type as Any,"expires_in":expires_in as Any,"scope":scope as Any,"timestamp":timestamp as Any]
    }

    init(access_token: String, token_type: String, expires_in: Int64, scope: String, timestamp: String, error:String, error_description:String) {
        self.access_token = access_token
        self.token_type = token_type
        self.expires_in = expires_in
        self.scope = scope
        self.timestamp = timestamp
        self.error_description = error
        self.error_description = error_description
    }
    
   enum CodingKeys: String, CodingKey {
       case access_token, token_type, expires_in, scope, timestamp, error, error_description
   }
}
// MARK: - Logout Response
struct LogoutResponse: Decodable {
    var code: String?
    var message: String?
    
    var dictionary: [String: Any] {
        return ["code":code as Any, "message":message as Any]
    }

    init(code: String, message: String) {
        self.code = code
        self.message = message
    }
    
   enum CodingKeys: String, CodingKey {
       case code, message
   }
}

// MARK: - Device Registration Response
struct DeviceRegistrationResponse: Decodable {
    var id: String
    var app_version: String
    var created: String
    var device_name: String
    var device_type: String
    var device_type_info: String
    var os_version: String
    var platform: String
    var username: String

    init(id: String, app_version: String, created: String, device_name: String, device_type: String, device_type_info: String, os_version: String, platform: String, username: String) {
        self.id = id
        self.app_version = app_version
        self.device_type_info = device_type_info
        self.device_type = device_type
        self.platform = platform
        self.device_name = device_name
        self.created = created
        self.username = username
        self.os_version = os_version
    }
    
   enum CodingKeys: String, CodingKey {
     case id,app_version,device_type_info,device_type,platform,device_name,created,username,os_version
   }
}

struct ErrorLoggingResponse: Decodable {
    
}
