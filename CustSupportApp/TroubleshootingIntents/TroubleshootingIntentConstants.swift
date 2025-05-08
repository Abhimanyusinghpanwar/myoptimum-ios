//
//  TroubleshootingIntentConstants.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 03/11/23.
//

import Foundation
enum ContactUsScreenFlowTypes {
    case noInternetAtAll
    case myInternetIsSlow
    case mySpeedStillLessThan80
    case restartMyInternetEquipment
    case extenderIsOfflineFlow
    case extenderIsWeakFlow
    case iHaveADifferentProblem
    case checkIntSpeed
    case wiFiCannotLoadAnything
    case networkDown
    case none
    case paymentFailed
    case deAuthServiceBlocked
    case manualBlock
    case paymentSysytemDown
    case unableToLoadBill
    case billHelp
    case streamTroubleshoot
    case remoteTroubleshoot
    case streamInstallFailure
    case extenderInstallFailure
}

enum IntentCode: String {
    case OPTAPP_TSINTCONN
    case OPTAPP_TSINTSPEED
    case OPTAPP_TSEXTENDSPEED
    case OPTAPP_TSWIFI
    case OPTAPP_TSINT
    case OPTAPP_TSEXTENDER
    case OPTAPP_TSROUTER
    case OPTAPP_TSINTSPEED1
    case OPTAPP_TSINTCONN1
    case OPTAPP_PAYMENTFAILED
    case OPTAPP_NONPAY
    case OPTAPP_MANUALBLOCK
    case OPTAPP_PAYMENTSYSDOWN
    case OPTAPP_VIEWBILL
    case OPTAPP_BILLHELP
    case OPTAPP_TSSTREAM
    case OPTAPP_TSREMOTE
    case OPTAPP_SEIQ_STREAM
    case OPTAPP_SIEQ_EXTENDER
}

// Removing the enum as the key should not be altered for ASAPP it should be "Code" always refer IntentsManager
//enum IntentDescription : String{
//    case NO_INTERNET_FROM_OPTIMUM_APP_AFTER_REBOOT = "No Internet from Optimum App after reboot"
//    case Slow_Speeds_From_Optimum_App_After_Reboot = "Slow speeds from Optimum App after reboot"
//    case SLOW_SPEEDS_FROM_OPTIMUM_APP_WITH_EXTENDER = "Slow speeds from Optimum App with Extender"
//    case EXTENDER_OFFLINE_OR_WEAK_SIGNAL_FROM_OPTIMUM_APP = "Extender offline or weak signal from Optimum App"
//    case NO_WIFI_CONNECTION_FROM_OPTIMUM_APP_AFTER_REBOOT = "No WiFi connection from Optimum App after reboot"
//    case TROUBLESHOOT_INTERNET_FROM_OPTIMUM_APP_AFTER_REBOOT = "Troubleshoot Internet from Optimum App after reboot"
//    case REBOOT_OF_GATEWAY_ROUTER_BUT_UNABLE_TO_CONNECT_FROM_OPTIMUM_APP = "Reboot of gateway/router but unable to connect from Optimum App"
//    case SLOW_SPEEDS_FROM_OPTIMUM_APP_AFTER_REBOOT_AND_SPEED_TEST_SHOWS_LESS_THAN_80  = "Slow speeds from Optimum App after reboot and speed test shows less than 80%"
//    case NO_INTERNET_REPORTED_FROM_OPTIMUM_APP_AFTER_REBOOT = "No Internet reported from Optimum App after reboot"
//    case PAYMENT_FAILED_IN_THE_PAYNOW_SECTION = "Payment failed in the Pay Now section"
//    case ACCOUNT_IS_IN_NONPAY_DEAUTH_STATUS_SERVICE_BLOCKED = "Account is in non-pay deauth status - service blocked"
//    case ACCOUNT_IS_IN_MANUAL_BLOCK_STATUS = "Account is in manual block status"
//    case PAYMENT_SYSTEM_NOT_AVAILABLE = "Payment system not available"
//    case FAILED_TO_LOAD_BILLING_PDF = "Failed to load billing PDF"
//    case GENERAL_BILLING_HELP_FROM_BILLING_SECTION_IN_APP = "General billing help from Billing section in app"
//}

