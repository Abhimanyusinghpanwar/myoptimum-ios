//
//  Constants.swift
//  CustSupportApp
//
//  Created by Namarta on 18/05/22.
//

import Foundation
import Alamofire
import UIKit

//For development and testing purposes only
// MARK: - Enable/Disable Features
/* Uncomment  to simulate First user experience.*/
public var enableFirstUserExperience = false
/* Uncomment  to simulate static add devices screen.
public let hasHouseholdProfiles = true*/
/* Temp: True for DEV and False for Stage/Production, Should be removed once Quickpay moved to Staging/Production */
public let enableQuickPayFeature = true
public var enableDeAuth = false
public var simulatePastDue = false
public var enablePreDeAuth = false

// MARK: - Device details
public let MYDEVICE = UIDevice.current
public let DEVICE_PLATFORM = "iOS"

public var DEVICE_TOKEN : String?

public let OPTIMUM_BRAND = "OPT"
public let SUDDENLINK_BRAND = "SDL"
public let CONFIG_UPDATED_TIMESTAMP_OPT = "BrandSpecificConfigOPT"
public let CONFIG_UPDATED_TIMESTAMP_SDL = "BrandSpecificConfigSDL"

//public let GoogleBannerID = "ca-app-pub-3940256099942544/2934735716"
public let GoogleAdaptiveBannerID = "/4051/mobile_app_test"//"ca-app-pub-3940256099942544/"
//CMAIOS-2225 Invalid char set for SSID
public let INVALID_SSID_CHARS =  "\\//~@#$%^&*+=[]{};:|‘`<>,?\"\'"
//CMAIOS-2224 Invalid char set for SSID
public let INVALID_SSID_PWD_CHARS =  "  \\$& "

// MARK: - Screen Sizes
public let currentScreenWidth = UIScreen.main.bounds.width
public let currentScreenHeight = UIScreen.main.bounds.height
struct CurrentDevice {
    // If the device is iPhone 11 Pro Max, iPhone 12 Pro Max,
    static func isLargeScreenDevice() -> Bool {
        return currentScreenHeight >= 896.0
        ///Large Screen Devices:  iPhone 11 Pro Max, iPhone 14 Plus, iPhone 14 Pro Max
        ///Small Screen Devices: iPhone SE 2nd Gen, iPhone 8, iPhone 11, 13
    }
    
    static func forLargeSpotlights() ->Bool {
        return currentScreenHeight >= 844.0
        ///Large Screen Devices:  iPhone 11 Pro Max, iPhone 14 Plus, iPhone 14 Pro Max, iphone 12, 13 and pro
        ///Small Screen Devices: iPhone SE 2nd Gen, iPhone 8, iphone 6s
    }
    
    static func isSmallScreenDevice() ->Bool
    {
        return currentScreenHeight <= 736.0
    }
    static func isSmallScreenDeviceSEFirstGen() ->Bool
    {
        return currentScreenHeight <= 568
    }
    
}

// MARK: - Struck constants to get NSBundle
struct App {
    static func versionNumber() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return version
        } else {
            return "1.0.0"
        }
    }
    
    static func getDeviceTypeInfo() -> String?
    {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    static func shortVersionNumber() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "1.0.0"
        }
    }
    
    static func getDeviceIdFromKeychain() -> String? {
        var deviceToken:String? = ""
        do {
            deviceToken = try KeychainWrapper.read(forKey: "deviceId")
        }
        catch {
            return nil
        }
        return deviceToken
    }
    
    static func getBrandInfo() -> String
    {
        var brand : String
        if true //DVRSubscription.sharedInstance.isOptimumUser
        {
            brand = OPTIMUM_BRAND
        } else
        {
            brand = SUDDENLINK_BRAND
        }
        return brand
    }
    
    //Using bundle identifier to set environment
    static func getGatewayURLForEnv() -> String
    {
        var gatewayURL : String
        let bundleID = Bundle.main.bundleIdentifier?.lowercased()
        
        if bundleID!.contains("dev")
        {
            gatewayURL = "https://dev.cma.alticeusa.com/"
        }//DEV
        else if bundleID!.contains("stage")
        {
            gatewayURL = "https://stage.cma.alticeusa.com/"
        }//Stage
        else if bundleID!.contains("prod") || bundleID!.compare("com.optimum.cma") == .orderedSame
        {
            gatewayURL = "https://cma.alticeusa.com/"
        }//Prod
        else{
            gatewayURL = "https://dev.cma.alticeusa.com/"
        }//Default
//        gatewayURL = "https://cma.alticeusa.com/"
        return gatewayURL
    }
    
    static func endSimulationForDeAuth() {
        enableDeAuth = false
        simulatePastDue = false
    }
    
    static func addQueryStrings(to url: String, queryParams: [String: String]) -> String {
        let keys = queryParams.keys
        var newURLString = url.appending("?")
        for queryString in keys {
            let val:String = queryParams[queryString] ?? ""
            if newURLString.last != "?" {
                newURLString.append("&")
            }
            newURLString.append("\(queryString)=\(val)")
        }
        return newURLString
    }
    
    static func checkCurrentTimeForSalutation() -> Salutation {
        /*
        1. Good morning! : 2:00am – 11:59am
        2. Good Afternoon! : 12:00pm – 5:59pm
        3. Good Evening! : 6:00pm – 1:59am
         */
        let currentDate = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        
        if (hour >= 02 && minute >= 0) && (hour <= 11 && minute <= 59) {
            return Salutation.morning
        } else if (hour >= 12 && minute >= 0) && (hour <= 17 && minute <= 59) {
            return Salutation.afternoon
        } else {
            return Salutation.night
        }
    }
}

// MARK: - Alamofire Constants
public let REQUEST_TIMEOUT_TIME:TimeInterval = 40
public let NETWORK_MANAGER = Alamofire.Session.self

// MARK: - Enum to define Service Type
// This enum to be passed to all API calls to set Access token and Device Token
enum ServiceKey {
    case login
    case mauiToken
    case logout
    case device
    case account
    case lightSpeed
    case operationalStatus
    case configAPI
    case configAPIBrandSpecific
    case ssidInfo
    case setWlanInfo
    case getLightspeedProfiles
    case setProfiles
    case postNode
    case reboot
    case speedTest
    case deviceIcons
    case clientUsage
    case mauiAccounts
    case mauiCustomer
    case mauiPayMethods
    case mauiListBills
    case mauiGetBill
    case mauiGetAccountBill
    case mauiBillAccountActivity
    case mauiNextPaymentDue
    case mauiBillPreferences
    case mauiUpdateBillPreferences
    case mauiCreatePayment
    case mauiSetDefaultPayMethod
    case mauiGetAutoPay
    case accessProfile
    case mauiAccountRestriction
    case mauiOutageAlert
    case mauiImmediatePayment
    case mauiCreateAutoPay
    case mauiCreateOneTimePayment
    case mauiListPayment
    case deadZone
    case lightSpeedRouter
    case errorLogging
    case mauiPdfDownload
    case mauiConsolidatedDetails
    case settings
    case mauiGetBankImageRoutNum
    case metricAPI
    case mauiSpotLightCards
    case mauiUpdateSpotlightCards
    case mauiDeleteMOP //CMAIOS-2578
}
// MARK: - Enum to define Salutations
// This enum  is to be get and map data related to greeting salutations
enum Salutation: String {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case night = "Night"
    
    func getLottieName() -> String {
        switch rawValue {
        case "Morning" :
            return "01_Morning_Text"
        case "Afternoon":
            return "02_Afternoon_Text"
        case "Night":
            return "03_Evening_text"
        default:
            return ""
        }
    }
    
    func getGreetingText() -> String {
        switch rawValue {
        case "Morning" :
            return "Good morning"
        case "Afternoon":
            return "Good afternoon"
        case "Night":
            return "Good evening"
        default:
            return ""
        }
    }
}
// MARK: - Constants
func getAuthorizationHeader() -> String {
#if DEBUG
    let baseURL = App.getGatewayURLForEnv().lowercased()
    let isProductionEnv = !baseURL.contains("dev.") && !baseURL.contains("stage.") && baseURL.contains("https://cma.alticeusa.com/")
    if isProductionEnv {
        return "Basic Q01BLWlPUy1UZXN0Oml6QzhMcldAQiE="
    } else {
        return "Basic Q01BLWlPUzpDTUEtaU9T"
    }
#else
    return "Basic Q01BLWlPUzpDTUEtaU9T"
#endif
}
let AUTHHEADER_AUTHORIZATION = getAuthorizationHeader()
