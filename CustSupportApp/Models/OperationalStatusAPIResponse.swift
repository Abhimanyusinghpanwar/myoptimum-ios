//
//  OperationalStatusAPIResponse.swift
//  CustSupportApp
//
//  Created by Namarta on 04/08/22.
//

import Foundation

// MARK: - Operational Status API Response
struct OperationalStatusAPIResponse: Decodable {
    var cm: CMValues?
    
    init(cm: CMValues?) {
        self.cm = cm
    }
    
   enum CodingKeys: String, CodingKey {
     case cm
   }
}

struct CMValues: Decodable {
    var cmip: String?
    var cmtsInfo: CMstInfo?
    

    init(cmip: String, cmtsInfo: CMstInfo?) {
        self.cmip = cmip
        self.cmtsInfo = cmtsInfo
    }

    enum CodingKeys: String, CodingKey {
        case cmip,cmtsInfo
    }
}

struct CMstInfo: Decodable {
    var cmStatus: String?
    var cmtsIp: String?

    init(cmStatus: String?, cmtsIp: String?) {
        self.cmStatus = cmStatus
        self.cmtsIp = cmtsIp
    }

    enum CodingKeys: String, CodingKey {
        case cmStatus,cmtsIp
    }
}

struct OperationalStatusAPIResponseFiber: Decodable {
    var equipId: String?
    var firmware: String?
    var hwVersion: String?
    var name: String?
    var oltcardid: String?
    var oltip: String?
    var oltname: String?
    var oltonuid: String?
    var oltponportid: String?
    var operationalStatus: String?
}

struct RebootAPIResponse: Decodable {
    var desc : String?
    var error : Int?
    var request_id : String?
}
