//
//  IntentsManager.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 06/11/23.
//

import Foundation
import ASAPPSDK

class IntentsManager {
    static let sharedInstance = IntentsManager()
    var screenFlow = ContactUsScreenFlowTypes.none
    private let intentKey = "Code"
    
    func getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes) -> [String:Any] {
        let intentCode = mapIntentCode(screenFlow: screenFlow)
        addUserContext(intent: intentCode?.rawValue ?? "")
        return [intentKey:intentCode?.rawValue ?? ""]
    }
    
    func mapIntentCode(screenFlow: ContactUsScreenFlowTypes) -> IntentCode? {
        switch screenFlow {
        case .noInternetAtAll:
            return .OPTAPP_TSINTCONN
        case .restartMyInternetEquipment:
            return .OPTAPP_TSROUTER
        case .myInternetIsSlow:
            return .OPTAPP_TSINTSPEED
        case .iHaveADifferentProblem:
            return .OPTAPP_TSINT
        case .checkIntSpeed, .mySpeedStillLessThan80:
            return .OPTAPP_TSINTSPEED1
        case .wiFiCannotLoadAnything:
            return .OPTAPP_TSWIFI
        case .networkDown:
            return .OPTAPP_TSINTCONN1
        case .extenderIsOfflineFlow:
            return .OPTAPP_TSEXTENDER
        case .extenderIsWeakFlow:
            return .OPTAPP_TSEXTENDER
        case .none:
            return nil
        case .paymentFailed:
            return .OPTAPP_PAYMENTFAILED
        case .deAuthServiceBlocked:
            return .OPTAPP_NONPAY
        case .manualBlock:
            return .OPTAPP_MANUALBLOCK
        case .paymentSysytemDown:
            return .OPTAPP_PAYMENTSYSDOWN
        case .unableToLoadBill:
            return .OPTAPP_VIEWBILL
        case .billHelp:
            return .OPTAPP_BILLHELP
        case .streamTroubleshoot:
            return .OPTAPP_TSSTREAM
        case .remoteTroubleshoot:
            return .OPTAPP_TSREMOTE
        case .streamInstallFailure:
            return .OPTAPP_SEIQ_STREAM
        case .extenderInstallFailure:
            return .OPTAPP_SIEQ_EXTENDER
        }
    }
    
    func addUserContext(intent: String) {
        ASAPP.user = ASAPPUser(
            userIdentifier: LoginPreferenceManager.sharedInstance.getMauiEOID(),
            requestContextProvider: { needsRefresh in
                return [
                    "Auth": [
                        "Token": LoginPreferenceManager.sharedInstance.getMauiToken()
                    ], "CustomerInfo": [
                        "externalIntent": "\(intent)"
                    ]]
            })
    }
}
