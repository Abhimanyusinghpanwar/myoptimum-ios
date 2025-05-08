//
//  AccountsResponseModel.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 09/09/22.
//

import Foundation

// MARK: - Accounts API Response
struct AccountsAPIResponse: Decodable {
    let homeId: String?
    let users: [User]?
    let map: [Map]?
    let firstName: String?
    let lastName: String?
    let username: String?
    let hasVideo: Bool?
    let hasInternet: Bool?
    let hasVoice: Bool?
    let region: String?
    let sessionId: String?
    let bwDown: Int?
    let bwUp: Int?
    let isMaster: Bool?
    let accountTime: String?
    // For authentication error scenarios
    let code: String?
    let message: String?
    let tvPackage: String?
    let displayAccountNumber: String?
    
    struct User: Decodable {
        let username: String?
        let isPrimary: Bool?
        let hasBillPay: Bool?
    }
    
    struct Map: Decodable {
        let accesstech: String?
        let cma_display_name: String?
        let cma_equipment_type: String?
        let cma_equipment_type_display: String?
        let device_mac: String?
        let device_serial: String?
        let device_type: String?
        let function: String?
        let ip: String?
        let long_desc: String?
        let short_desc: String?
        let smartwifi: String?
        let status: String?
        let uploadSpeedSupported: Bool?
        let downloadSpeedSupported: Bool?
        let DTM_DATE_CREATED: String?
        let isInternetMasterDevice: Bool?
    }
}
