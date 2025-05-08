//
//  AccessProfileAPIResponseModel.swift
//  CustSupportApp
//
//  Created by vishali Test on 05/01/23.
//

import Foundation

// MARK: - Get API Response
struct AccessProfileGetResponse: Decodable {
    let desc : String?
    let data : [ProfileData]?
    let request_id : String?
    
    struct ProfileData: Decodable {
        let entity : String?
        let householdId : String?
        let icon : String?
        let id : String?
        let pid : Int?
        let clients : [String]?
        let restrictionRules : [Rules]?
        let type : String?
    }
    
    struct Rules: Decodable {
        let enabled : Bool?
        let id : String?
        let type : String?
        let startTime: String?
        let endTime: String?
    }
}

struct PauseProfileGetResponse: Decodable {
    
    let isProfilePaused : Bool?
    let restrictionRules : [Rules]?
    let devices : [ProfileData]?
    let data : [ProfileData]? // either devices / data might come
    let request_id : String?

    struct Rules: Decodable {
        let days : [String]?
        let startTime: String?
        let endTime: String?
    }
    
    struct ProfileData: Decodable {
        let mac : String?
        let paused : Bool?
        let pausedBy : String?
        let type : String?
    }
}

// MARK: - PUT API Response
struct AccessProfilePutResponse: Decodable {
    let desc : String?
    let profile : ProfileData?
    let request_id : String?
    
    struct ProfileData: Decodable {
        let entity : String?
        let householdId : String?
        let icon : String?
        let id : String?
        let pid : Int
        let clients : [String]?
        let restrictionRules : [Rules]?
        let type : String?
    }
    
    struct Rules: Decodable {
        let enabled : Bool?
        let id : String?
        let type : String?
    }
}

// MARK: - Delete API Response

struct AccessProfileDeleteResponse: Decodable {
    let data: String?
    let desc: String?
}

// MARK: - Get Paused Devices Response
struct PausedDevices: Decodable {
    let data: [PausedDevice]?
    let request_id: String?
    struct PausedDevice: Decodable {
        let mac : String?
        let paused : Bool?
    }
}

struct DevicePauseState: Decodable {
    let request_id: String?
    let mac : String?
    let paused : Bool?
}
