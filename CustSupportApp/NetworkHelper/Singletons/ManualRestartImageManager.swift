//
//  ManualRestartImageManager.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 05/04/23.
//

import Foundation

class ManualRestartImageManager {
    
    class var shared: ManualRestartImageManager {
        struct Singleton {
            static let instance = ManualRestartImageManager()
        }
        return Singleton.instance
    }
    
    func getManualRestartImage(equipmentType: String) -> String {
        switch equipmentType {
        case "D-Link":
            return "device_Router_Dlink"
        case "Sagemcom":
            return "device_Router_Sagemcom"
        case "FTTH Gateway Gen 7":
            return "device_FiberGatewayGen7"
        case "FTTH Gateway Gen 8", "Multi Gig FTTH XGSPON":
            return "device_FiberGatewayGen8"
        case "Altice One Box Gateway":
            return "deviceIAltice1"
        case "Ubee 1319", "Ubee 1326", "Ubee 1338":
            return "device_Ubee1319_1326"
        case "Ubee 1322":
            return "device_Ubee1322"
        case "FTTH Gateway Gen 9", "Multi Gig FTTH XGSPON Gen 9":
            return "Gateway_6E"
        case "Ubee 1340":
            return "Gateway_6E_Docsis"
        default:
            return ""
        }
    }
    
    func getCableImageForRouter(equipmentType: String) -> String {
        switch equipmentType {
        case "D-Link":
            return "device_Router_Dlink_Back"
        case "Sagemcom":
            return "device_Router_Sagemcom_Back"
        default:
            return ""
        }
    }
}
