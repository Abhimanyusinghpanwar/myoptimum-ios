//
//  MyWifiManager.swift
//  CustSupportApp
//
//  Created by Namarta on 8/11/22.
//

import Foundation

typealias DeviceDetails = (dictOfDevicesWithSections: [String : [ConnectedDevice]]?,
                                       arrOfSections:[String]?,
                                       arrOfConnectedDevices:[ConnectedDevice]?)
class MyWifiManager {
    @Published var lightSpeedData: [String:AnyObject]?
    var clientUsage: [ClientUsageResponse.Client]?
    var pausedClientData: PausedDevices?
    var pausedProfileIds: [Int] = []
    var sessionID: String = ""
    var smartWifiType = "" //Either Wifi6 or Wifi5
    var wifiDisplayType: WifiOptionDisplayType = .None
    var pollingLTNotRequired = false
    var lightSpeedAPIState: LightSpeedAPIState = .none
    var isOperationalStatusOnline = false
    var reCallFromMyWifiJumpLink = false // This boolean is ON when the state is either failedOP or failed LT to show "Still Checking My Wifi status" progress UI
    var recallSpotlights = false
    var deviceMAC: String?
    var deviceType: String?
    var deviceIP: String?
    var isUploadSupported: Bool = false
    var isDownloadSupported: Bool = false
    var twoGHome: NSMutableDictionary?
    var fiveGHome: NSMutableDictionary?
    var stalenessType: String?
    var accessTech = ""
    var fiberOperationalStatus: NSMutableDictionary?
    var cmtsipoltip = ""
    var cmipOnu = ""
    var networkName = ""
    var bwUp = 0
    var bwDown = 0
    var refreshLTDataRequired = false
    var isClientUsageAPISucceeded : Bool = true
    var isMaster: Bool = false
    var outageTitle = ""
    var isFromHealthCheck = false
    var isFromSpeedTest = false
    var equipmentTypeDictionary = NSDictionary()
    var isCloseButtonClicked = false
    var supressPHCalls = false
    var gwDisplayType6E = ""
    var unProvisionedSTBs : [AccountsAPIResponse.Map] = []
    var newProvisionedSTBs: [MapCPEInforResponse] = []
    var displayAccountNumber: String = ""

   class var shared: MyWifiManager {
        struct Singleton {
            static let instance = MyWifiManager()
        }
        return Singleton.instance
    }
    
    func saveAccountsAPIResponse(value: AccountsAPIResponse) {
        self.accountsStruct = value
        self.sessionID = value.sessionId ?? ""
        self.accountsNetworkPoints = value.map
        self.saveWifiDisplayType()
        self.bwUp = value.bwUp ?? 0
        self.bwDown = value.bwDown ?? 0
        //CMA-559
        self.isMaster =  value.isMaster ?? false
        self.displayAccountNumber = value.displayAccountNumber ?? ""
        checkForStreamCard()
    }
    func checkForStreamCard() {
        let stbs = self.getSTBs()
        let unprovStbs = stbs.filter({$0.device_mac == nil || (($0.device_mac?.isEmpty) == true)})
        if !unprovStbs.isEmpty  {
            SpotLightsManager.shared.configureSpotLightsForSelfInstall()
            self.unProvisionedSTBs = unprovStbs
        }
    }
    
    //CMA-559
    func getIsMasterProfileCreated()->Bool{
        return self.isMaster
    }
    
    func saveLightspeedAPIResponse(value: LightSpeedAPIResponse) -> Bool {
        var success = true
        var dict: [String:AnyObject] = [:]
        if let extenderStatus = value.extender_status {
            dict[LT_extender_status] = extenderStatus as AnyObject
        }
        if let links = value.links {
            dict[LT_links] = links as AnyObject
        }
        if var nodes = value.nodes {
            if isTVPackage() { // Added for CMAIOS-1877
                nodes.removeAll { node in
                    node.cma_dev_type?.isMatching("stream_stb") ?? false || node.cma_dev_type?.isMatching("stream") ?? false
                }
//                let arrStbs = self.getStreamDevicesFromAccounts()
//                for stb in arrStbs  {
//                    nodes.removeAll { node in
//                        WifiConfigValues.checkMACFormat(mac: node.mac ?? "").isMatching(WifiConfigValues.checkMACFormat(mac: stb.mac ?? ""))
//                    }
//                }
            }
            dict[LT_nodes] = nodes as AnyObject
            if let masterNode = (nodes.filter{($0).isMaster?.isMatching("true") ?? false }) as [Any]?, !masterNode.isEmpty {
                success = true
            } else {
                success = false
            }
        } else { success = false }
        if let recDisc = value.rec_disconn {
            dict[LT_rec_disconn] = recDisc as AnyObject
        }
        if success == true { // Save LT data only if Master gateway node exists
            self.lightSpeedData = dict
        }
        return success
    }
    
    func saveClientUsageData(value: [ClientUsageResponse.Client]) {
        self.clientUsage = value
    }
    // MARK: -
    // MARK: - Live Topology Data Handling
    // MARK: -
    // MARK: -
    
    /// Fallback handling for the node values
    lazy var masterGatewayNode: DeviceNodeStruct = {
        var name = ""
        var statusString = ""
        var statusColorString = ""
        var equipmentTypeString = ""
        var conn_type = ""
        var mac = ""
        var ipAdd = ""
        var band = ""

        if let array = self.getMasterGateway() as? [LightSpeedAPIResponse.Nodes], !array.isEmpty {
            let node = array.first
            var name = "Unknown"
            //Display Name
            if let friendlyName = node?.friendly_name, !friendlyName.isEmpty {
                name = friendlyName
            } else if let cmaDisName = node?.cma_display_name, !cmaDisName.isEmpty {
                name = cmaDisName
            } else if let hostname = node?.hostname, !hostname.isEmpty {
                name = hostname
            }
            equipmentTypeString = node?.cma_equipment_type_display ?? node?.cma_dev_type ?? node?.device_type ?? "Unknown"
            statusColorString = node?.color ?? ""
            statusString = node?.status ?? ""
            conn_type = node?.conn_type ?? ""
            mac = node?.mac ?? ""
            ipAdd = node?.ip ?? ""
            band = node?.band ?? ""
        }
        return DeviceNodeStruct(deviceName: name,
                                    deviceType: equipmentTypeString,
                                    statusColor: statusColorString,
                                    statusString: statusString,
                                    conn_type: conn_type,
                                    macAddress: mac,
                                    ipAddress: ipAdd,
                                    band: band)
    }()
    
    func getMasterGateway() -> [Any] {
        guard let nodesData = self.lightSpeedData?[LT_nodes] as? NSArray else {
            return []
        }
        if let nodes = (nodesData.filter{($0 as! LightSpeedAPIResponse.Nodes).isMaster?.isMatching("true") ?? false }) as [Any]? {
            return nodes
        }
        return []
    }
    
    func getMasterGatewayDetails() -> (name:String, statusText:String, statusColor:UIColor?, bgColor:UIColor?, equipmentImage:UIImage, equipmentDisplay: String, equipmentType: String, gatewayDetails:[DeviceDetail], gatewayFormattedMac:String){
        var name = ""
        var statusText = ""
        var equipImage: UIImage! = UIImage(named: "icon_wifi_white")
        var equipmentDisplayName = ""
        var equipmentType = ""
        var imgColor: UIColor?
        var bgColor: UIColor?
        if let array = self.getMasterGateway() as? [LightSpeedAPIResponse.Nodes] {
            if array.isEmpty {
                let values = self.getFallbackValuesForGateway()
                var image: UIImage?
                var imageName = ""
                if values.image.isEmpty {
                    image = UIImage(named: "icon_wifi_white")
                    imageName = "unknown"
                } else {
                    imageName = values.image
                    image = DeviceManager.shared.getGatewayImage(equipmentType: imageName)
                    if image == nil {
                        image = UIImage(named: "icon_wifi_white")
                    }
                }
                return (values.name,"Offline",.StatusOffline,midnightBlueRGB,image!,values.type,imageName,[],"")
            }
            let node = array.first
            ///Gateway Name
            if let friendlyName = node?.friendly_name, !friendlyName.isEmpty {
                name = friendlyName
            } else if let displayName = node?.cma_display_name, !displayName.isEmpty {
                name = displayName
            } else if let hostname = node?.hostname, !hostname.isEmpty {
                name = hostname
            } else if let mac = node?.mac, !mac.isEmpty {
                name = mac
            }
            
            ///Gateway status
            if let color = node?.color, !color.isEmpty {
                if color == "green" {
                    statusText = "Online"
                    imgColor = .StatusOnline
                    bgColor = energyBlueRGB
                } else if color == "red" {
                    statusText = "Offline"
                    imgColor = .StatusOffline
                    bgColor = midnightBlueRGB
                } else {
                    statusText = "Weak signal"
                    imgColor = .StatusWeak
                    bgColor = midnightBlueRGB
                }
            }
            
            //Equipment Type / Image
            if let cma_equipment_type = node?.cma_equipment_type {
                equipImage = DeviceManager.shared.getGatewayImage(equipmentType: cma_equipment_type)
                equipmentType = cma_equipment_type
            }
            
            if let cma_equipment_display_type = node?.cma_equipment_type_display {
                equipmentDisplayName = cma_equipment_display_type
            }
            let deviceDetails = getDeviceDetails(nodeReference: node)
            return (name,statusText, imgColor, bgColor, equipImage, equipmentDisplayName, equipmentType,deviceDetails.0, deviceDetails.1)
        } else {
            let values = self.getFallbackValuesForGateway()
            var image: UIImage?
            var imageName = ""
            if values.image.isEmpty {
                image = UIImage(named: "icon_wifi_white")
                imageName = "unknown"
            } else {
                imageName = values.image
                image = DeviceManager.shared.getGatewayImage(equipmentType: imageName)
                if image == nil {
                    image = UIImage(named: "icon_wifi_white")
                }
            }
            return (values.name,"Offline",.StatusOffline,midnightBlueRGB,image!,values.type,imageName,[], "")
        }
    }
    
    func getDeviceDetails(nodeReference:LightSpeedAPIResponse.Nodes?) -> ([DeviceDetail], String){
        var arrDetails : [DeviceDetail] = []
        guard let node = nodeReference else {
            return ([], "")
        }
        
        var formattedMacAddress = ""
        if let deviceType = node.cma_equipment_type_display, !deviceType.isEmpty {
            arrDetails.append(DeviceDetail(title: "Equipment Type", value: deviceType))
        }

        if let macAddress = node.mac, !macAddress.isEmpty {
            formattedMacAddress = WifiConfigValues.getFormattedMACAddress(macAddress)
            arrDetails.append(DeviceDetail(title: "MAC Address", value: formattedMacAddress))
        }
        //added WAN IP for Gateway
        if let iPAddress = MyWifiManager.shared.deviceIP, !iPAddress.isEmpty { //CMA-926
            arrDetails.append(DeviceDetail(title: "WAN IP Address", value: iPAddress))
        }
        if let iPAddress = node.ip, !iPAddress.isEmpty {
            arrDetails.append(DeviceDetail(title: "LAN IP Address", value: iPAddress))
        }
        if let band = node.band, !band.isEmpty {
            var replaced = ""
            if band.contains("6") {
                if let range = band.range(of: ",", options: .backwards) {
                    replaced = band.replacingOccurrences(of: ",", with: " and ", range: range)
                    replaced = replaced.replacingOccurrences(of: "," , with: ", ")
                }
            } else {
               replaced = band.replacingOccurrences(of: ",", with: " and ")
            }
            if band == "2" || band == "2 and 5" {
                replaced = replaced.replacingOccurrences(of: "2", with: "2.4")
            }
            let strFrequency = replaced.appending(" GHz")
            arrDetails.append(DeviceDetail(title: "Frequency Band", value: strFrequency))
        }
        return (arrDetails, formattedMacAddress)
    }
    
    func getExtendersFromNodes() -> [LightSpeedAPIResponse.Nodes] {
        var nodesArray = [LightSpeedAPIResponse.Nodes]()
        guard let nodesData = self.lightSpeedData?[LT_nodes] as? NSArray else {
            return []
        }
        if let nodes = (nodesData.filter{($0 as! LightSpeedAPIResponse.Nodes).isMaster?.isMatching("false") ?? false && ($0 as! LightSpeedAPIResponse.Nodes).device_type?.isMatching("Extender") ?? false}) as! [LightSpeedAPIResponse.Nodes]? {
            nodesArray = nodes
        }
        return nodesArray
    }
    
    func getSTBs() -> [AccountsAPIResponse.Map] {
        ///Use this filter to simulate CMA-2137
        //accountsNetworkPoints?.filter({($0.function?.isMatching("stb") ?? false && $0.device_type?.isMatching("stream_stb") ?? false) && $0.device_mac == nil})
        guard let function = accountsNetworkPoints?.filter({$0.function?.isMatching("stb") ?? false && $0.device_type?.isMatching("stream_stb") ?? false}) as [AccountsAPIResponse.Map]?, !function.isEmpty else {
            return []
        }
        return function
    }
    
    func getTVPackageName() -> String {
        return accountsStruct?.tvPackage ?? ""
    }
    
    func isTVPackage() -> Bool {
        if let tvPackage = accountsStruct?.tvPackage, !tvPackage.isEmpty {
            return true
        }
        return false
    }
    
    func getTvStreamDevices() -> [TVStreamBox] {
        var nodesArray = [TVStreamBox]()
        let stbsFromAccount = getSTBs()
        if stbsFromAccount.isEmpty { return [] }
       // guard let devices = DeviceManager.shared.devices else {return stbsFromAccount}
        for stb in stbsFromAccount {
            
            if let device =  DeviceManager.shared.streamDevices.filter({(WifiConfigValues.checkMACFormat(mac: $0.mac ?? "").isMatching(WifiConfigValues.checkMACFormat(mac: stb.device_mac ?? "")))}).first {
                let deviceImageValue = device.deviceType ?? ""
                let stbNode = TVStreamBox(friendlyname: device.friendlyName ?? "", macAddress: WifiConfigValues.checkMACFormat(mac: stb.device_mac ?? ""), image: DeviceManager.IconType.white.getStreamImage(name: deviceImageValue.lowercased() == "unknown" ? "" : deviceImageValue), deviceType: device.deviceType ?? "", serial: stb.device_serial ?? "")
                nodesArray.append(stbNode)
            } else {
                let newMac = checkIfStbProvisioned(serial: stb.device_serial ?? "")
                let stbNode = TVStreamBox(friendlyname: "", macAddress: newMac.isEmpty ? stb.device_mac ?? "" : newMac, image: DeviceManager.IconType.white.getStreamImage(name: ""), deviceType: "Stream", serial: stb.device_serial ?? "")
                nodesArray.append(stbNode)
            }
        }
        return nodesArray
    }
    
    func checkIfStbProvisioned(serial: String) -> String {
        if serial.isEmpty || MyWifiManager.shared.newProvisionedSTBs.isEmpty {
            return ""
        }
        guard let device = MyWifiManager.shared.newProvisionedSTBs.filter({ $0.serialnumber?.lowercased() == serial.lowercased()}).first else {
            return ""
        }
        return WifiConfigValues.checkMACFormat(mac: device.macaddress ?? "") 
    }
    
    func getStreamDevicesFromAccounts() -> [LightspeedNode] {
        var nodesArray = [LightspeedNode]()
        if accountsStruct?.hasVideo == true {
            if let function = accountsNetworkPoints?.filter({ $0.function?.isMatching("stb") ?? false && $0.device_type?.isMatching("stream_stb") ?? false}) as [AccountsAPIResponse.Map]?, !function.isEmpty {
                for item in function {
                    let node = LightspeedNode(accno: "", mac: item.device_mac, gwid: "", friendlyName: WifiConfigValues.checkMACFormat(mac: item.device_mac ?? ""), hostname: "", location: "", createdDate: "", updatedDate: "", nodeType: "", category: "", deviceType: item.device_type, vendor: "")
                    nodesArray.append(node)
                }
            }
        }
        return nodesArray
    }
    
    func getAllConnectedDevices() -> [LightSpeedAPIResponse.Nodes] {
        var macAddresses = [String]()
        var connectedDevices = [LightSpeedAPIResponse.Nodes]()
        guard let links = self.lightSpeedData?[LT_links] as? NSArray else {
            return []
        }
        if let linksArray = (links.filter{($0 as! LightSpeedAPIResponse.Links).target_type != "node"}) as [Any]? {
            if !linksArray.isEmpty {
                if let targetArray = (linksArray.compactMap{($0 as! LightSpeedAPIResponse.Links).target}) as [String]? {
                    macAddresses = targetArray
                }
            }
        }
        if !macAddresses.isEmpty {
            ///All devices which contain macaddresses into one array
            if  let arrNodes = self.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes] {
                connectedDevices = arrNodes.filter{(macAddresses.contains($0.mac ?? ""))}
            }
        }
        return connectedDevices
    }
    
    func populateConnectedDevices(filterWeakStatus: Bool = false,
                                  havingMAC macAddress: String = "",
                                  withSections groupingOfSections: Bool = false) -> DeviceDetails? {
        var devicesResponse =  macAddress == "" ? MyWifiManager.shared.getAllConnectedDevices() : MyWifiManager.shared.getConnectedDevices(macAddress)
        if devicesResponse.isEmpty {
            return (nil, nil, nil)
        } else {
            if filterWeakStatus{
                //Only for getting weak devices
                devicesResponse = devicesResponse.filter({$0.color == "orange"})
            }
        }
        return self.segregateSectionForDevices(devicesResponse, groupingOfSections: groupingOfSections)
    }
    
    func segregateSectionForDevices(_ deviceResponse: [LightSpeedAPIResponse.Nodes], groupingOfSections: Bool) -> DeviceDetails? {
        var arrSections =  [String]()
        var sectionsForProfile:[Int] = []
        var sectionsForCategory:[String] = []
        var connectedDevices = deviceResponse.map { node -> ConnectedDevice in
            var title = ""
            var color = ""
            var profileName = ""
            var band = ""
            var deviceImageGray = UIImage(named: "unknown_gray_static")
            var deviceImageWhite = UIImage(named: "unknown_white_static")
            if let friendlyName = node.friendly_name, !friendlyName.isEmpty {
                title = friendlyName
            } else if let hostname = node.hostname, !hostname.isEmpty, hostname != node.mac {
                title = hostname
            } else if let displayName = node.cma_display_name, !displayName.isEmpty {
                title = displayName
            } else if let vendorName = node.vendor, !vendorName.isEmpty, !vendorName.contains("None") {
                title = vendorName
            } else {
                title = "Unnamed device"
            }
            if let colorValue = node.color, !colorValue.isEmpty {
                color = colorValue
            }
            if let profile = node.profile, !profile.isEmpty {
                profileName = profile
            }
            if let bandVal = node.band, !bandVal.isEmpty {
                band = bandVal
            }
            //let avatarID = profiles?.filter { $0.pid == Int(node.pid ?? "13") }.first?.avatar_id ?? "13"
            if let deviceImageValue = node.cma_dev_type, !deviceImageValue.isEmpty {
                deviceImageGray = DeviceManager.IconType.gray.getDeviceImage(name: deviceImageValue)
                deviceImageWhite = DeviceManager.IconType.white.getDeviceImage(name: deviceImageValue)
            } else {
                deviceImageGray = DeviceManager.IconType.gray.getDeviceImage(name: "unknown_device")
                deviceImageWhite = DeviceManager.IconType.white.getDeviceImage(name: "unknown_device")
            }
            var sectionTitle = ""
            if MyWifiManager.shared.isSmartWifi(), let profile = node.profile, !profile.isEmpty {
                if let pid = node.pid {
                    sectionsForProfile.append(pid)
                }
                sectionTitle = profile
            } else if let category = node.cma_category, !category.isEmpty {
                if category.lowercased() == "personal and computer" {
                    sectionsForCategory.append("Personal and Computer")
                } else {
                    sectionsForCategory.append(category.firstCapitalized)
                }
                sectionTitle = category.firstCapitalized
            } else {
                    sectionsForCategory.append("Other")
                    sectionTitle = "Other"
                }
            return ConnectedDevice(title: title,
                                   deviceImage_Gray: deviceImageGray!,
                                   deviceImage_White: deviceImageWhite!,
                                   colorName: color,
                                   device_type: node.cma_dev_type ?? node.device_type ?? "",
                                   conn_type: node.conn_type ?? "", vendor: node.vendor ?? "",
                                   macAddress: node.mac ?? "",
                                   ipAddress: node.ip ?? "",
                                   profileName: profileName,
                                   band: band,
                                   sectionTitle: sectionTitle,
                                   pid: node.pid ?? 0
            )
        }
        
        if connectedDevices.count > 0 {
            // Return all devices without sections
            if !groupingOfSections  {
                return (nil, nil, connectedDevices)
            }
            //CMAIOS-2100 Perform alphabetical sorting for connected devices
           connectedDevices = DeviceManager.shared.sortDevices(devices: connectedDevices)
            if !sectionsForProfile.isEmpty {
                var profiles = [ProfileModel]()
                var sortedProfile = [String]()
                for pid in sectionsForProfile {
                    if let profile = ProfileModelHelper.shared.profiles?.filter({$0.pid == pid}), !profile.isEmpty {
                        profiles.append(profile[0])
                    }
                }
                if profiles.count == 1 {
                    sortedProfile.append(profiles[0].profileName)
                    arrSections = sortedProfile + sectionsForCategory
                } else {
                    let sortedArray = profiles.sorted { $0.profile!.pid ?? 0 < $1.profile!.pid ?? 0 }
                    sortedProfile = sortedArray.compactMap{$0.profileName}
                    arrSections = sortedProfile + sectionsForCategory
                }
            } else {
                arrSections = sectionsForCategory
            }
            var arrDeviceSections = NSMutableOrderedSet(array: arrSections).array as! [String] //Remove duplicates
            var dictDevicesWithSections = [String : [ConnectedDevice]]()
            let sectionNames = ["Personal and Computer", "Gaming", "Entertainment", "Home", "Security", "Other"]
            
            let deviceSections = sectionNames.filter{arrDeviceSections.contains($0)}
            if let otherSections = arrDeviceSections.filter({!sectionNames.contains($0)}) as [String]?, !otherSections.isEmpty {
                arrDeviceSections = otherSections + deviceSections
            } else {
                arrDeviceSections = deviceSections
            }
            
            for key in arrDeviceSections {
                let deviceList = connectedDevices.filter({ $0.sectionTitle.lowercased() == key.lowercased()})
                dictDevicesWithSections[key] = deviceList
            }
            return (dictDevicesWithSections, arrDeviceSections, connectedDevices)
        } else {
            return (nil, nil, nil)
        }
    }
    
    func getDeviceDetailsForMAC(_ mac: String) -> LightSpeedAPIResponse.Nodes? {
        guard let nodes = self.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes], !nodes.isEmpty else {
            return nil
        }
        let devices = nodes.filter{($0.mac?.isMatching(mac) ?? false)}
        if !devices.isEmpty {
            return devices.first
        }
        return nil
    }
    
    func getConnectedDevices(_ mac: String) -> [LightSpeedAPIResponse.Nodes] {
        var macAddresses = [String]()
        var connectedDevices = [LightSpeedAPIResponse.Nodes]()
        guard let links = self.lightSpeedData?[LT_links] as? NSArray else {
            return []
        }
        if let linksArray = (links.filter{($0 as! LightSpeedAPIResponse.Links).source?.isMatching(mac) == true && ($0 as! LightSpeedAPIResponse.Links).target_type != "node"}) as [Any]? {
            if !linksArray.isEmpty {
                if let targetArray = (linksArray.compactMap{($0 as! LightSpeedAPIResponse.Links).target}) as [String]? {
                    macAddresses = targetArray
                }
            }
        }
        if !macAddresses.isEmpty {
            ///All devices which contain macaddresses into one array
            if  let arrNodes = self.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes] {
                connectedDevices = arrNodes.filter{(macAddresses.contains($0.mac ?? ""))}
            }
        }
        return connectedDevices
    }
    
    func getRecentlyDisconnected() -> [LightSpeedAPIResponse.rec_disconn] {
        guard let rec_disc = self.lightSpeedData?[LT_rec_disconn] as? [LightSpeedAPIResponse.rec_disconn] else {
            return []
        }
        return rec_disc
    }
    
    func getAllLightApiNodes() -> [LightSpeedAPIResponse.Nodes] {
        guard let rec_disc = self.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes] else {
            return []
        }
        return rec_disc
    }

    func getOfflineExtenders() -> [LightSpeedAPIResponse.extender_status.Nodes] {
        guard let extenderStatus = self.lightSpeedData?[LT_extender_status] as? LightSpeedAPIResponse.extender_status else {
            return []
        }
        
        guard let extenderNodes = extenderStatus.nodes else {
            return []
        }
        
        if extenderNodes.count > 0 {
            var offlineNodes = extenderNodes.filter{$0.status?.lowercased() == "offline"}
                offlineNodes = getSuppressedExtenders(nodesArray: offlineNodes)
            return offlineNodes
        }
        return []
    }
    
    func getSuppressedExtenders(nodesArray: [LightSpeedAPIResponse.extender_status.Nodes]) -> [LightSpeedAPIResponse.extender_status.Nodes] {
        
        if let savedExtenderSuppressedData = PreferenceHandler.getValuesForKey("extenderSuppressData") as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([ExtenderSuppressData].self, from: savedExtenderSuppressedData) {
                var modifiedNodesArray = Array(nodesArray)
                
                for extenderSupportObj in decodedData
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.locale = .init(identifier: "en_US_POSIX")
                    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
                    
                    let savedDate = dateFormatter.date(from: extenderSupportObj.extender_suppress_mac_LastCheck)
                    let futureDate = Calendar.current.date(byAdding: .day, value: Int(ConfigService.shared.extenderSuppressInterval) ?? 14, to: savedDate ?? Date())!
                    if dateFormatter.string(from: Date()) != dateFormatter.string(from: futureDate) {
                        modifiedNodesArray = modifiedNodesArray.filter{($0.status?.lowercased() == "offline" && $0.device_mac != extenderSupportObj.extender_suppress_mac)}
                    }
                }
                return modifiedNodesArray
            }
        }
        return nodesArray
    }
    
    func getOnlineExtenders() -> [LightSpeedAPIResponse.extender_status.Nodes] {
        guard let extenderStatus = self.lightSpeedData?[LT_extender_status] as? LightSpeedAPIResponse.extender_status else {
            return []
        }
        
        guard let extenderNodes = extenderStatus.nodes else {
            return []
        }
        
        if extenderNodes.count > 0 {
            let onlineNodes = extenderNodes.filter{$0.status?.lowercased() == "online" && $0.placement?.lowercased() == "optimal"}
            return onlineNodes
        }
        return []
    }
    
    func getAllOnlineExtenders() -> [LightSpeedAPIResponse.extender_status.Nodes] {
        guard let extenderStatus = self.lightSpeedData?[LT_extender_status] as? LightSpeedAPIResponse.extender_status else {
            return []
        }
        
        guard let extenderNodes = extenderStatus.nodes else {
            return []
        }
        
        if extenderNodes.count > 0 {
            let onlineNodes = extenderNodes.filter{$0.status?.lowercased() == "online"}
            return onlineNodes
        }
        return []
    }
    
    //CMAIOS-2100 get all extenders Weak + Online + Offline
    func getAllExtendersData()->[Extender] {
        let onlineExtenders = MyWifiManager.shared.getExtendersFromNodes()
        let offlineExtenders = MyWifiManager.shared.getOfflineExtenders()
        
        var arrExtenders = onlineExtenders.map {nodes -> Extender in
            var color = ""
            if let val = nodes.color, !val.isEmpty {
                color = val
            } else {
                color = ""
            }
            let extenderName = WifiConfigValues.getExtenderName(offlineExtNode: nil, onlineExtNode: nodes)
            return Extender.init(title: extenderName, colorName: color, status: nodes.status ?? "", device_type: nodes.cma_equipment_type_display ?? nodes.device_type ?? "", conn_type: nodes.conn_type ?? "", macAddress: nodes.mac ?? "", ipAddress: nodes.ip ?? "", band: nodes.band ?? "", image: DeviceManager.IconType.white.getExtenderImage(name: nodes.cma_display_name), hostname: nodes.hostname ?? "", category: nodes.cma_category ?? "")
        }
        let offlines = offlineExtenders.map{nodes -> Extender in
            //CMAIOS-2355 Added default red color for Offline extender
            let color = "red"
            let extenderName = WifiConfigValues.getExtenderName(offlineExtNode: nodes, onlineExtNode: nil)
            return Extender.init(title: extenderName, colorName: color, status: nodes.status ?? "", device_type: nodes.cma_equipment_type_display ?? "", conn_type: nodes.conn_type ?? "", macAddress: nodes.device_mac ?? "", ipAddress:"", band:"", image: DeviceManager.IconType.white.getExtenderImage(name: nodes.cma_display_name), hostname: nodes.hostname ?? "", category: nodes.cma_category ?? "")
        }
        arrExtenders.append(contentsOf: offlines)
        return arrExtenders
    }
    
    func getExtenderData(macAddress: String)-> Extender? {
        let arrExtenders = self.getAllExtendersData()
        let node =  arrExtenders.filter({$0.macAddress == macAddress}).first
        return node
    }
    
    func getWeakExtenders() -> [LightSpeedAPIResponse.extender_status.Nodes] {
        var nodesArray : [LightSpeedAPIResponse.extender_status.Nodes] = []
        guard let extenderStatus = self.lightSpeedData?[LT_extender_status] as? LightSpeedAPIResponse.extender_status else {
            return []
        }
        
        guard let extenderNodes = extenderStatus.nodes else {
            return []
        }
        
        if extenderNodes.count > 0 {
            let notOptimalNodes = extenderNodes.filter{$0.status?.lowercased() == "online" && $0.placement?.lowercased() != "optimal"}
            nodesArray.append(contentsOf: notOptimalNodes)
            
            let weakNodes = extenderNodes.filter{$0.status?.lowercased() == "weak"}
            nodesArray.append(contentsOf: weakNodes)
            return nodesArray
        }
        return []
    }
    
    func getMyWifiStatus() -> MyWifiStates {
        ///Step #1: Check for backend failures
        if self.getWifiType() == "Modem" {
            if isOperationalStatusOnline == false {
                return .wifiDown
            } else {
                return .runningSmoothly
            }
        }
        if lightSpeedAPIState == .failedLiveTopology || lightSpeedAPIState == .failedOperationalStatus {
            return .backendFailure
        } else if lightSpeedAPIState == .firstLiveTopologyCallInProgress {
            if pollingLTNotRequired == true {
                return .backendFailure
            }
            return .waitToRefresh
        }
        
        ///Step #2: Check status of master gateway
        if isOperationalStatusOnline == false {
            return .wifiDown
        }
        let masterDetails = MyWifiManager.shared.getMasterGatewayDetails()
        if masterDetails.statusText.isEmpty || masterDetails.statusText == "Offline" {
            return .wifiDown
        }
        
        ///Step #3:
        //Check offline extenders and count of offline extenders
        let offlineExtenders = getOfflineExtenders()
        if !offlineExtenders.isEmpty {
            return .offlineExtendersFound
        }
        
        ///Step #4:
        //check status of other extenders and count of weak extenders if any
        let weakExtenders = getWeakExtenders()
        if !weakExtenders.isEmpty {
            return .weakExtenderFound
        }
        
        ///Step #5:
        //If No offline or weak status is found, SHOW network is running smoothly message
        return .runningSmoothly
    }
    
    // Fallback mechanism to get extender name from Accounts API response
    func getEquipmentNameFromAccountsResponse(mac:String) -> String {
        let macAddressData = mac.replacingOccurrences(of: ":", with: "")
        if let networkPoints = self.accountsNetworkPoints, let networkData = networkPoints.filter({($0 ).device_mac?.isMatching(macAddressData) == true}) as? [AccountsAPIResponse.Map] {
            if !networkData.isEmpty {
                if let networkPointData = networkData[0] as AccountsAPIResponse.Map?, let name = networkPointData.cma_display_name, !name.isEmpty {
                    return name
                }
            }
        }
        return ""
    }
    //CMAIOS-992
    func getFallbackValuesForGateway() -> (name:String, type:String, image:String) {
        if let function = accountsNetworkPoints?.filter({ $0.function?.isMatching("gateway") ?? false}) as [AccountsAPIResponse.Map]?, !function.isEmpty {
            guard let gateway = function.first else {
                return("","","")
            }
            let values = (name:gateway.cma_display_name ?? "", type:gateway.cma_equipment_type_display ?? "", image:gateway.cma_equipment_type ?? "")
            return(values)
        }
        return("","","")
    }
    
    func checkOnlineActivityExistsForProfile(profile:ProfileModel?)-> Bool
    {
        var onlineActivityExistsForProfile: Bool = false
        if let profileExists = profile {
            for deviceNode in profileExists.devices {
                if deviceNode.connectedTime > 0 {
                    onlineActivityExistsForProfile = true
                    return onlineActivityExistsForProfile
                }
            }
        }
        return onlineActivityExistsForProfile
    }
    
    func getTotalConnectedHoursAndDevices(profile: ProfileModel?) -> (totalHours:Int, totalConnectedDevices:Int) {
        var totalConnectedTime = 0
        var totalConnectedDevices = 0
        if let profileExists = profile {
            for node in profileExists.devices {
                if node.connectedTime > 0 {
                    totalConnectedDevices = totalConnectedDevices + 1
                    totalConnectedTime = totalConnectedTime + node.connectedTime
                }
            }
        }
        if totalConnectedTime > 0{
            totalConnectedTime = getTotalOnlineActivityOfConnectedDevices(totalConnectedtime: totalConnectedTime)
        }
        return (totalConnectedTime, totalConnectedDevices)
    }
    
    func getTotalOnlineActivityOfConnectedDevices(totalConnectedtime: Int?) -> Int {
        guard let connectedTime = totalConnectedtime else {
            return 0
        }
        var hours = connectedTime / 3600
        let minutes = ((connectedTime % 3600) / 60)
        // Round of hours based on minutes only if activity is more than an hour
        if hours >= 1 && minutes >= 30 {
            hours = hours + 1
        }
        return hours
    }
    
    func isSmartWifi() -> Bool {
        if self.smartWifiType.isMatching("WiFi6") || self.smartWifiType.isMatching("WiFi5") {
            return true
        } else {
            return false
        }
    }
    
    func isLegacyManagedRouter() -> Bool {
        if isSmartWifi() {
            return false
        } else if MyWifiManager.shared.wifiDisplayType == .Gateway && MyWifiManager.shared.smartWifiType.lowercased() == ("None").lowercased() {
            return true
        } else {
            return false
        }
    }
    
    func isUnManagedModem() -> Bool {
        if isSmartWifi() || isLegacyManagedRouter() {
            return false
        } else {
            return true
        }
    }
    
    // This will not check Pause status
    func getNodeStatus(status:String, colorName:String) -> DeviceStatus? {
        if status.isEmpty {
            switch colorName.lowercased() {
            case "red":
                return .offline
                
            case "green":
                return .online
                
            case "orange":
                return .weak
                
            default:
                return nil
            }
        } else {
            switch status.lowercased() {
            case "offline":
                return .offline
            case "online": // Weak extender return online status
                if !colorName.isEmpty && colorName.isMatching("orange") {
                    return .weak
                } else if !colorName.isEmpty && colorName.isMatching("green") {
                    return .online
                }
                return .online
            case "weak":
                return .weak
            default:
                return nil
            }
        }
    }
    
    func triggerOperationalStatus() {
        guard let deviceMAC = MyWifiManager.shared.deviceMAC, let deviceType = MyWifiManager.shared.deviceType else {
            //Gateway is offline
            lightSpeedAPIState = .failedOperationalStatus
            return
        }
        let mapString = "\(deviceMAC)?devicetype=" + deviceType
        APIRequests.shared.isRebootOccured = false
        if !MyWifiManager.shared.accessTech.isEmpty, MyWifiManager.shared.accessTech == "gpon" {
            APIRequests.shared.initiateGatewayStatusAPIRequestForFiber(mapString) { success,response,error in
                
            }
        } else {
            APIRequests.shared.initiateGatewayStatusAPIRequest(mapString) { success, response, error in
            }
        }
    }
    
    // MARK: - Locally LT Model Changes
    func saveProfileChangeLocally(for mac: String, profileName: String?, pid: Int) {
        guard var nodes = self.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes], !nodes.isEmpty else {
            return
        }
        guard let index = nodes.firstIndex(where: {$0.mac?.isMatching(mac) == true}) else {
            return
        }
        guard var device = nodes.filter({($0.mac?.isMatching(mac) ?? false)}).first else {
            return
        }
        device.pid = pid
        device.profile = profileName ?? ""
        nodes[index] = device
        
        self.lightSpeedData?[LT_nodes] = nodes as AnyObject
    }
    
    func saveProfileChangeLocallyDisconnectedDevices(for mac: String, profileName: String?, pid: Int) {
        guard var nodes = self.lightSpeedData?[LT_rec_disconn] as? [LightSpeedAPIResponse.rec_disconn], !nodes.isEmpty else {
            return
        }
        guard let index = nodes.firstIndex(where: {$0.mac?.isMatching(mac) == true}) else {
            return
        }
        guard var device = nodes.filter({($0.mac?.isMatching(mac) ?? false)}).first else {
            return
        }
        device.pid = pid
        device.profile = profileName ?? ""
        nodes[index] = device
        self.lightSpeedData?[LT_rec_disconn] = nodes as AnyObject
    }
    
    func saveDeviceChangeLocally(for mac: String, deviceName: String?, deviceType: String, category:String) {
        guard var nodes = self.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes], !nodes.isEmpty else {
            return
        }
        guard let index = nodes.firstIndex(where: {$0.mac?.isMatching(mac) == true}) else {
            return
        }
        guard var device = nodes.filter({($0.mac?.isMatching(mac) ?? false)}).first else {
            return
        }
        device.cma_dev_type = deviceType
        device.friendly_name = deviceName
        device.cma_category = category
        nodes[index] = device
        
        self.lightSpeedData?[LT_nodes] = nodes as AnyObject
    }
    
    func saveDeviceChangeLocallyDisconnectedDevices(for  mac: String, deviceName: String?, deviceType: String, category:String) {
        guard var nodes = self.lightSpeedData?[LT_rec_disconn] as? [LightSpeedAPIResponse.rec_disconn], !nodes.isEmpty else {
            return
        }
        guard let index = nodes.firstIndex(where: {$0.mac?.isMatching(mac) == true}) else {
            return
        }
        guard var device = nodes.filter({($0.mac?.isMatching(mac) ?? false)}).first else {
            return
        }
        device.cma_dev_type = deviceType
        device.friendly_name = deviceName
        device.cma_category = category
        nodes[index] = device
        self.lightSpeedData?[LT_rec_disconn] = nodes as AnyObject
    }
    
    // MARK: -
    // MARK: - Accounts API Data Handling
    // MARK: -
    // MARK: -
    func isSplitSSID() -> Bool {
        if MyWifiManager.shared.wifiDisplayType == .Gateway {
            if self.smartWifiType.isMatching("WiFi6") || self.smartWifiType.isMatching("WiFi5") {
                return false
            } else {
                return true
            }
        } else if MyWifiManager.shared.wifiDisplayType == .ManagedLegacyRouter {
            return true
        }
        return false
    }
    
    func hasInternet() -> Bool {
        return accountsStruct?.hasInternet ?? false
    }
    
    func hasBillPay() -> Bool {
        let savedUser = LoginPreferenceManager.sharedInstance.getLoggedInUsername()
        if let user = accountsStruct?.users?.filter({ $0.username?.isMatching(savedUser) ?? false }) as? [AccountsAPIResponse.User], !user.isEmpty {
            return user[0].hasBillPay ?? false
        }
        return false
    }
    
    func isPrimaryUser() -> Bool
    {
        let savedUser = LoginPreferenceManager.sharedInstance.getLoggedInUsername()
        if let user = accountsStruct?.users?.filter({ $0.username?.isMatching(savedUser) ?? false }) as? [AccountsAPIResponse.User], !user.isEmpty {
            return user[0].isPrimary ?? false
        }
        return false
    }
    
    func isTVOnlyService() -> Bool {
        if let hasInternet = accountsStruct?.hasInternet, let hasVideo = accountsStruct?.hasVideo {
            if hasInternet == false && hasVideo == true {
                 return true
            } else {
                return false
            }
        }
        return false
    }
    
    func getServiceBundle() -> String {
        let components: [String] = [
            accountsStruct?.hasInternet.map {$0 ? "internet" : ""} ?? "",
            accountsStruct?.hasVideo.map {$0 ? "video" : ""} ?? "",
            accountsStruct?.hasVoice.map {$0 ? "phone" : ""} ?? ""
        ].compactMap {$0.isEmpty ? nil : $0}

        return components.isEmpty ? "" : components.joined(separator: ",")
    }
    
    func isTvStreamAvailable() -> Bool {
        if accountsStruct?.hasVideo == true {
            if let function = accountsNetworkPoints?.filter({ $0.function?.isMatching("stb") ?? false && $0.device_type?.isMatching("stream_stb") ?? false}) as [AccountsAPIResponse.Map]?, !function.isEmpty {
                return true
            }
        }
        return false
    }

    func getFirstName() -> String {
        if let name = accountsStruct?.firstName {
            return name
        }
        return ""
    }
    func getRegion() -> String {
        if let region = accountsStruct?.region{
            return region
        }
        return ""
    }
    // MARK: Internal Methods
    private var accountsStruct:AccountsAPIResponse?
    var accountsNetworkPoints: [AccountsAPIResponse.Map]?
    private func saveDeviceMACAndType(deviceMAC:String, deviceType:String, deviceIP: String?) {
        self.deviceMAC = deviceMAC
        self.deviceType = deviceType
        self.deviceIP = deviceIP
    }
    private func saveWifiDisplayType() {
        if let function = accountsNetworkPoints?.filter({ $0.function?.isMatching("gateway") ?? false && $0.isInternetMasterDevice == true}) as [AccountsAPIResponse.Map]?, !function.isEmpty {
            if function.count == 1 {
                setGatewayChanges(function[0])
            } else {
                self.wifiDisplayType = .None
            }
            
        } else if let function = accountsNetworkPoints?.filter({ $0.function?.isMatching("cablemodem") ?? false && $0.isInternetMasterDevice == true}) as [AccountsAPIResponse.Map]?, !function.isEmpty {
            self.supressPHCalls = true
            if function.count == 1 {
                setModemChanges(function[0])
                self.wifiDisplayType = .Other
            }
            else {
                self.wifiDisplayType = .None
            }
            
        } else {
            self.wifiDisplayType = .None
        }
    }
    
    func performDateComparison(_ function: [AccountsAPIResponse.Map]) -> AccountsAPIResponse.Map {
        let dateFormatter = DateFormatter()
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = en_US_POSIX
        let sortedArray = function.sorted{dateFormatter.date(from: $0.DTM_DATE_CREATED ?? "") ?? Date() > dateFormatter.date(from: $1.DTM_DATE_CREATED ?? "") ?? Date()}
        return sortedArray[0]
    }
    
    func setGatewayChanges(_ function: AccountsAPIResponse.Map) {
        if let smartWifi = function.smartwifi {
            self.smartWifiType = smartWifi
            self.wifiDisplayType = .Gateway
        } else {
            self.wifiDisplayType = .ManagedLegacyRouter
        }
        MyWifiManager.shared.accessTech = function.accesstech ?? ""
        if let device_mac = function.device_mac, let device_type = function.device_type, !device_mac.isEmpty, !device_type.isEmpty {
            MyWifiManager.shared.saveDeviceMACAndType(deviceMAC: device_mac, deviceType: device_type, deviceIP: function.ip)
            gwDisplayType6E = function.cma_equipment_type_display ?? ""
        }
        MyWifiManager.shared.isUploadSupported = function.uploadSpeedSupported ?? false
        MyWifiManager.shared.isDownloadSupported = function.downloadSpeedSupported ?? false
    }
    
    func setModemChanges(_ function: AccountsAPIResponse.Map) {
        if let smartWifi = function.smartwifi {
            self.smartWifiType = smartWifi
        }
        MyWifiManager.shared.accessTech = function.accesstech ?? ""
        if let device_mac = function.device_mac, let device_type = function.device_type, !device_mac.isEmpty, !device_type.isEmpty {
            MyWifiManager.shared.saveDeviceMACAndType(deviceMAC: device_mac, deviceType: device_type, deviceIP: function.ip)
        }
        MyWifiManager.shared.isUploadSupported = function.uploadSpeedSupported ?? false
        MyWifiManager.shared.isDownloadSupported = function.downloadSpeedSupported ?? false
    }
    
    func isGateWayWifi6() -> Bool {
        //CMAIOS-1137: Commented out pause functionality for WiFi6
//        if !self.smartWifiType.isEmpty, self.smartWifiType.isMatching("WiFi6") {
//            return true
//        } else {
//            return false
//        }
        return false
    }
    func isGateWayWifi5OrAbove() -> Int {
        if !self.smartWifiType.isEmpty {
            if self.smartWifiType.isMatching("WiFi6") {
                if gwDisplayType6E.lowercased().contains("6e") {
                    return 7
                }
                else {
                    return 6
                }
            } else if self.smartWifiType.isMatching("WiFi5") {
                return 5
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func getWifiType() -> String {
        if (MyWifiManager.shared.smartWifiType.isMatching("WiFi6") || MyWifiManager.shared.smartWifiType.isMatching("WiFi5")) {
            return "Gateway"
        }else if MyWifiManager.shared.wifiDisplayType == .Gateway && MyWifiManager.shared.smartWifiType.lowercased() == ("None").lowercased() {
            return "Equipment"
        }
        else if MyWifiManager.shared.smartWifiType.lowercased() == ("None").lowercased() {
            return "Modem"
        } else {
            return ""
        }
    }
    
    func checkForOutages() {
        if let outage =  QuickPayManager.shared.modelQuickPayeOutage, let outageInfo = outage.alerts, !outageInfo.isEmpty {
            if let outageData = outageInfo.first, let outageName = outageData.name {
                if outageName == "OUTAGE_ON_ACCOUNT" {
                    outageTitle = "OUTAGE_ON_ACCOUNT"
                } else if outageName == "RECENTLY_CLEARED" {
                    outageTitle = "RECENTLY_CLEARED"
                }
            }
        } else {
            outageTitle = ""
        }
    }
    
    
    /// Detects the outage
    /// - Returns: CardData value or nil, If cardData avaialble there is an outage or no outage
    func checkForOutagesWithSpotLight(_ service:String) -> SpotLightCardsGetResponse.CardData? {
        var spotlightCard: SpotLightCardsGetResponse.CardData?
        guard let spCards = SpotLightsManager.shared.spotLightCards,let cards = spCards.cards, !cards.isEmpty else {
            return spotlightCard
        }
        let outageInfo = cards.filter ({ $0.priorityKey?.contains("1.") == true && $0.moreInfo != nil && $0.moreInfo!.servicesImpacted != nil && $0.moreInfo!.servicesImpacted!.contains(where: {$0.caseInsensitiveCompare(service) == .orderedSame})})
        if !outageInfo.isEmpty {
            spotlightCard = outageInfo.first
        }
        return spotlightCard
    }
    
    func getExtenderImageForOfflineWeakStatus() -> Bool {
        if let equipmentType = MyWifiManager.shared.getMasterGatewayDetails().equipmentType as String?, !equipmentType.isEmpty {
            switch equipmentType {
            case "Ubee 1340", "FTTH Gateway Gen 9", "Multi Gig FTTH XGSPON Gen 9":
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
}

extension MyWifiManager {
    func removeWifiConfigValuesForSignOut() {
        lightSpeedData = nil
        clientUsage = nil
        pausedClientData = nil
        pausedProfileIds = []
        sessionID = ""
        smartWifiType = ""
        wifiDisplayType = .None
        lightSpeedAPIState = .none
        isOperationalStatusOnline = false
        deviceMAC = nil
        deviceType = nil
        deviceIP = nil
        isUploadSupported = false
        twoGHome = nil
        fiveGHome = nil
        stalenessType = nil
        accessTech = ""
        fiberOperationalStatus = nil
        cmtsipoltip = ""
        cmipOnu = ""
        networkName = ""
        bwUp = 0
        bwDown = 0
        refreshLTDataRequired = false
        isClientUsageAPISucceeded = true
        isMaster = false
        outageTitle = ""
        isFromHealthCheck = false
        isFromSpeedTest = false
        equipmentTypeDictionary = NSDictionary()
        supressPHCalls = false
        gwDisplayType6E = ""
    }
}

struct DeviceNodeStruct {
    let deviceName: String
    let deviceType: String
    let statusColor: String
    let statusString: String
    let conn_type: String
    let macAddress: String
    let ipAddress: String
    let band: String
    
    func getColorAndStatus() -> (color:UIColor,status:String) {
        switch self.statusColor {
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
        switch self.statusString.lowercased() {
        case "offline":
            return midnightBlueRGB
        case "online":
            if self.statusColor.lowercased() == "orange" {
                return midnightBlueRGB
            }
            return energyBlueRGB
        case "weak":
            return midnightBlueRGB
        default:
            return .clear
        }
    }
}

