//
//  File.swift
//  
//
//  Created by vsamikeri on 6/29/22.
//

import Foundation

struct IdentityCheck: Codable {
    let serialNumber: String?
    let eqModel: String?
    let wifiFreqSupported: [String]?
}

struct GenerateToken: Codable {
    let tk: String?
}

public struct SignalQuality: Codable {
    public let rssi_cat: [String]?
    public let sn: String?
}

struct ValidateToken: Codable {
    
}

struct Logout: Codable {
    
}

