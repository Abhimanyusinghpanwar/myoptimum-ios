//
//  CMAAnalyticsManager.swift
//  CustSupportApp
//
//  Created by vishali Test on 20/06/23.
//

import Foundation
import FirebaseAnalytics

public typealias EventParamDetails = [String:Any]
    
class CMAAnalyticsManager {
    static let sharedInstance = CMAAnalyticsManager()
    
    func trackAction(eventParam : EventParamDetails)
    {
        var globalContextData = self.addDefaultEventParameters()
        for (key, value) in eventParam {
            globalContextData[key.lowercased()] = value
        }
        Analytics.logEvent(EVENT_SCREEN_VIEW, parameters: globalContextData)
    }
    func addDefaultEventParameters() -> EventParamDetails
    {
        var defaultParameter = [String:Any]()
        if !LoginPreferenceManager.sharedInstance.getLoggedInUsername().isEmpty {
            defaultParameter["user_id"] = LoginPreferenceManager.sharedInstance.getEncryptedUserID().lowercased()
        }
        
        if let deviceId = DEVICE_TOKEN {
            defaultParameter["device_id"] = deviceId
        }
        
        if !MyWifiManager.shared.smartWifiType.isEmpty {
            defaultParameter["wifi"] = MyWifiManager.shared.smartWifiType
        }
        
        defaultParameter["tv_only"] = MyWifiManager.shared.isTVOnlyService()
        
        defaultParameter["bill_pay_state"] = QuickPayManager.shared.getPaymentStateForAnalytics().rawValue
        return defaultParameter
    }
    func setUserIDForAnalytics(_ id: String) {
        Analytics.setUserID(id)
        Analytics.setUserProperty(id, forName: "optimum_id")
    }
    
    func trackButtonOnClickEvent(eventParam : EventParamDetails)
    {
        var globalContextData = self.addDefaultEventParameters()
        for (key, value) in eventParam {
            globalContextData[key.lowercased()] = value
        }
        Analytics.logEvent(EVENT_BUTTON_ON_CLICK, parameters: globalContextData)
    }
}
