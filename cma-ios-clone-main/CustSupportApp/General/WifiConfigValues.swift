//
//  WifiConfigValues.swift
//  CustSupportApp
//
//  Created by Namarta on 01/08/22.
//

import Foundation
///Keys constants For Live Topology
public var LT_extender_status = "extender_status"
public var LT_links = "links"
public var LT_nodes = "nodes"
public var LT_rec_disconn = "rec_disconn"

enum WifiOptionDisplayType{
    case Gateway
    case ManagedLegacyRouter
    case Other
    case None
}
public let energyBlueRGB = UIColor(red: 39.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)
public let midnightBlueRGB = UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 100.0/255.0, alpha: 1.0)
public let pauseBgColor = UIColor(red: 0.443, green: 0.443, blue: 0.443, alpha: 1)
public let pauseIndicatorColor = UIColor(red: 152.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1)
public let btnBgOrangeColorRGB = UIColor.init(red: 246/255, green: 102/255, blue: 8/255, alpha: 1)//CMAIOS-2591

extension String {
    func isMatching(_ str:String?) -> Bool {
        guard str != nil else {
            return false
        }
        let string1 = self.lowercased()
        let string2 = str!.lowercased()
        if string1 == string2 {
            return true
        } else {
            return false
        }
    }
}

enum MyWifiStates {
    case offlineExtendersFound
    case weakExtenderFound
    case runningSmoothly
    case wifiDown // Network down (CMA-67)
    case backendFailure // (CMA-83)
    case waitToRefresh
}

enum LightSpeedAPIState {
    case failedOperationalStatus
    case failedLiveTopology
    case firstLiveTopologyCallInProgress
    case completed
    case none
    case opCallInProgress
}

///Reference confluence link: https://confluence.cablevision.com/display/CMA/Equipment+Connection+Status
class WifiConfigValues {
    // MARK: - Utility Methods
    static func getFormattedMACAddress(_ mac: String) -> String {
        guard let macString = MyWifiManager.shared.deviceMAC, macString.count == 12 else {
            return ""
        }
        var macID = (mac.isEmpty) ? macString : mac
        
        ///Check If the mac is already formatted, If yes then return
        if !macID.isEmpty && macID.contains(":") {
            return macID.uppercased()
        }
        // Offsets for 12 Character string
        let offsets = [2,5,8,11,14]
        for offset in offsets {
            let index = macID.index(macID.startIndex, offsetBy: offset)
            macID.insert(":", at: index)
        }
        return macID.uppercased()
    }
    static func checkMACFormat(mac:String) -> String {
        var formattedMac = ""
        if !mac.isEmpty { //If MAC is coming from Accounts map response
            if !mac.contains(":"), mac.count == 12 {
                formattedMac = getFormattedMACAddress(mac)
                return formattedMac
            } else {
                return mac
            }
            
        } else {
            return mac
        }
    }
    
    static func getDisconnectedDateFromString(disconnectDate: String) -> Date? {
        if disconnectDate.isEmpty {
            return nil
        }
        let dateFormatter = DateFormatter()
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'ZH'"
        dateFormatter.locale = en_US_POSIX
        return dateFormatter.date(from: disconnectDate)
    }
    
    static func getDisconnectedTime(timestamp: Double) -> Date? {
        if timestamp == 0 {
            return nil
        }
        let date = Date(timeIntervalSince1970: timestamp)
        return date
    }
    
    static func getDisconnectedTimeString(timestamp: Double) -> String {
        if timestamp == 0 {
            return ""
        }
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return "Disconnected at \(timeString) today"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Disconnected at \(timeString) yesterday"
        }
        ///Backup
        formatter.dateStyle = .full
        return "Disconnected at \(formatter.string(from: date))"
    }
    
    //Method to return extender name with fallback value rule
    static func getExtenderName(offlineExtNode:LightSpeedAPIResponse.extender_status.Nodes?, onlineExtNode:LightSpeedAPIResponse.Nodes?) -> String {
        var extenderName = "Unknown"
        if let node = offlineExtNode {
            if let friendlyName = node.friendly_name, !friendlyName.isEmpty {
                extenderName = friendlyName
            } else if let displayName = node.cma_display_name, !displayName.isEmpty {
                extenderName = displayName
            } else if let hostName = node.hostname  {
                extenderName = hostName
            } else {
                var macAddressData = node.device_mac!.replacingOccurrences(of: ":", with: "")
                macAddressData = macAddressData.uppercased()
                let fallbackName = MyWifiManager.shared.getEquipmentNameFromAccountsResponse(mac: macAddressData)
                extenderName = fallbackName
            }
            return extenderName
        }  else if let node = onlineExtNode {
            if let friendlyName = node.friendly_name, !friendlyName.isEmpty {
                extenderName = friendlyName
            } else if let displayName = node.cma_display_name, !displayName.isEmpty {
                extenderName = displayName
            } else if let hostName = node.hostname  {
                extenderName = hostName
            } else {
                var macAddressData = node.mac!.replacingOccurrences(of: ":", with: "")
                macAddressData = macAddressData.uppercased()
                let fallbackName = MyWifiManager.shared.getEquipmentNameFromAccountsResponse(mac: macAddressData)
                extenderName = fallbackName
            }
            return extenderName
        }
        return extenderName
    }
}
// MARK: - Text Constants
struct MyWiFiConstants {
    static let lets_fix             :  String         = "Let’s fix it!"
    static let wifi_smoothly        :  String         = "Your WiFi is running smoothly"
    static let view_my_network      :  String         = "View my network"
    static let trouble_my_internet  :  String         = "Troubleshoot my Internet"
    static let more_options         :  String         = "More options"
    static let wifi_down            :  String         = " network is down"
    static let multiple_ext_offline :  String         = " of your Extenders are offline"
    static let one_ext_offline      :  String         = " Extender is offline"
    static let multiple_ext_weak    :  String            = " of your Extenders have a weak signal"
    static let one_ext_weak         :  String            = " Extender has a weak signal"
    static let check_back_later     :  String         = "We are experiencing technical difficulties and can’t communicate with your network. \n\n Please check back later."
    static let check_accounts_later :  String          = "We are experiencing technical difficulties, and cannot access your account at this time.  Please check back later."
}
struct MyInternetConstants {
    static let internet_smoothly    :   String        = "Your Internet is running smoothly"
    static let internet_down        :   String        = "There seems to be a problem with your Internet equipment"
}

struct AvatarConstants {
    static let names = ["Bird", "Book", "Brush+Pallete", "Cat", "Chess", "Coffee", "Crown", "Dog", "Fox", "Guitar", "Lotus", "Owl"]
}

// MARK: - Connected extender and devices data model
struct Extender {
    let title: String
    let colorName: String
    let status: String
    let device_type: String
    let conn_type: String
    let macAddress: String
    let ipAddress: String
    let band: String
    let image: UIImage
    let hostname: String
    let category: String
    func getColor() -> (color:UIColor,status:String) {
        switch self.colorName {
        case "red":
            return (.StatusOffline,"Offline")
            
        case "green":
            return (.StatusOnline,"Online")
            
        case "orange":
            return (.StatusWeak,"Weak signal")
            
        default:
            return (.clear,"")
        }
    }
    func getThemeColor() -> UIColor {
        switch self.status {
        case "Offline":
            return midnightBlueRGB
        case "Online": // Weak extender return online status
            if !colorName.isEmpty && colorName.isMatching("orange") {
                return midnightBlueRGB
            } else if !colorName.isEmpty && colorName.isMatching("green") {
                return energyBlueRGB
            }
            return energyBlueRGB
        case "Weak", "Weak signal": //CMAIOS-2355
            return midnightBlueRGB
        default:
            return .clear
        }
    }
}
struct ConnectedDevice {
    let title: String
    let deviceImage_Gray: UIImage
    let deviceImage_White: UIImage
    let colorName: String
    let device_type: String
    let conn_type: String
    let vendor: String
    let macAddress: String
    let ipAddress: String
    let profileName: String
    let band: String
    let sectionTitle:String
    let pid:Int
    //let avatarId: String
    
    func getColor() -> (color:UIColor,status:String) {
        switch self.colorName {
        case "red":
            return (.StatusOffline,"Offline")
            
        case "green":
            return (.StatusOnline,"Online")
            
        case "orange":
            return (.StatusWeak,"Weak signal")
            
        default:
            return (.clear,"")
        }
    }
}

struct OnlineActivityDevice {
    let deviceName: String
    let deviceIcon: String
    var totalProgress: Float
    let connectedTime: Int
}

struct StreamSTB {
    let dtm_date_created: String
    let device_mac: String
    var device_serial: String
    let device_type: String
    let downloadSpeedSupported: Bool
    let function: String
    let long_desc: String
    let short_desc: String
    let uploadSpeedSupported: Bool
}

struct RecentlyDisconnected {
    let deviceName: String
    let dateString: String
    let deviceIcon_white: UIImage
    let deviceIcon_gray: UIImage
    let deviceCategory: String
    let connectionType: String
    let deviceType: String
    let profile: String
    let mac: String
    let vendor: String
    let lanIP: String
    let band: String
    let pid: Int
    let disConnectDate: Date?
}
