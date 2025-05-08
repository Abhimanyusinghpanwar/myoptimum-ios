//
//  SpeedTestRequest.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/18/22.
//

import Foundation

struct SpeedTestRequest: Codable {
    let accessTech: String
    let gwip: String?
    let olt: String? // required only if accessTech is gpon
    let onu: String? // required only if accessTech is gpon
    let bw: String? // required only if accessTech is gpon 
    let region: String?
    let deviceType: String
    let oltIP: String?
    let bwUp: Int?
    let bwDown: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessTech, gwip, olt, onu, bw, region
        case deviceType = "device_type"
        case oltIP = "olt_ip"
        case bwUp = "bw_up"
        case bwDown = "bw_down"
    }
}


struct SpeepTestResponse: Codable {
    let downloadPercentage: Double?
    let uploadPercentage: Double?
    let downloadSpeed: Double
    let uploadSpeed: Double?
    let bw: String?
    let prov_bwdn: Int?
    
    enum CodingKeys: String, CodingKey {
        case downloadPercentage = "download_percentage"
        case uploadPercentage = "upload_percentage"
        case downloadSpeed = "speedy_avg"
        case uploadSpeed = "upload_speedy_avg"
        case bw
        case prov_bwdn
    }
}
