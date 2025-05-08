//
//  ExtenderDataManager.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/5/22.
//

import Foundation
import UIKit

enum IntelligentTroubleshoot {
    case troubleshoot, healthCheck
}
class ExtenderDataManager: NSObject {

    static let shared: ExtenderDataManager = {
        let instance = ExtenderDataManager()
        return instance
    }()
    var extenderType: Int?
    var extenderFriendlyName: String?
    var extendersDeviceMac: [String] = []
    var extenderAPIFailure = false
    var extenderPairingStatus = false
    var extenderHomeNetwork = false
    var extenderCheckLightsFirst = false
    var isExtenderTroubleshootFlow = false
    var flowType: TroubleshootExtenders = .weakFlow
    var iTroubleshoot: IntelligentTroubleshoot = .troubleshoot
    var offlineExtenderCount = 0
    var wpsAPIFail = false
    var wpsFailCount = 0
    var gwEquipType: String?
    
    func clearData() {
        self.wpsAPIFail = false
        self.extenderAPIFailure = false
        self.extenderPairingStatus = false
        self.extenderHomeNetwork = false
        self.extenderCheckLightsFirst = false
        self.extenderType = nil
        self.extenderFriendlyName = ""
        self.extendersDeviceMac = []
        self.isExtenderTroubleshootFlow = false
        self.offlineExtenderCount = 0
        self.gwEquipType = nil
        self.wpsFailCount = 0
    }
    
}
