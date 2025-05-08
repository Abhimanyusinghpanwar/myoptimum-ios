//
//  MAUITokenResponse.swift
//  CustSupportApp
//
//  Created by Namarta on 10/11/22.
//

import Foundation
struct MAUITokenResponse: Decodable {
    var access_token: String?
    var token_type: String?
    var timestamp: String?
    var error: String?
    var error_description: String?
    var eoid: String?

    var dictionary: [String: Any] {
        return ["access_token":access_token as Any, "token_type":token_type as Any, "timestamp":timestamp as Any, "eoid":eoid as Any]
    }

    init(access_token: String, token_type: String, expires_in: Int64, scope: String, timestamp: String, error: String, error_description: String, eoid: String) {
        self.access_token = access_token
        self.token_type = token_type
        self.timestamp = timestamp
        self.error_description = error
        self.error_description = error_description
        self.eoid = eoid
    }
    
   enum CodingKeys: String, CodingKey {
       case access_token, token_type, timestamp, error, error_description, eoid
   }
}
