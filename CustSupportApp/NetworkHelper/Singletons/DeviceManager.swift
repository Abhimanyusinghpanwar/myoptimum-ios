//
//  DeviceManager.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/25/22.
//

import Alamofire
import Zip
import SVGKit
class DeviceManager {
    enum IconType: String {
        case white
        case gray
//MARK: - Icon Image Mapping Methods
        func getDeviceImage(name: String?) -> UIImage! {
            var defaultImage: UIImage! = UIImage(named: "unknown_gray_static")
            if self == .white {
                defaultImage = UIImage(named: "unknown_white_static")
            } else if self == .gray {
                defaultImage = UIImage(named: "unknown_gray_static")
            }
            guard var iconName = name, !iconName.isEmpty else {
                Logger.info("Icon name for Device not found in response")
                return defaultImage
            }
            if iconName.lowercased().contains("unknown") == true {
                iconName = "unknown_device"
            }
            guard let image = mapImageName(name: iconName) else {
                Logger.info("File name mapping issue with <Device image> named - \("\(rawValue)/\(iconName.lowercased()).svg")")
                return defaultImage
            }
            return image
        }
        
        func getGatewayImage(name:String?) -> UIImage? {
           // let defaultImage: UIImage! = UIImage(named: "icon_wifi_white")
        //    let defaultImageString = "unknown_equipment"
        //    let mappedImage = mapImageName(name: defaultImageString)
            guard var iconName = name, !iconName.isEmpty else {
                Logger.info("Icon name for Gateway not found in response")
                return nil
            }
            if iconName.lowercased().contains("unknown") == true {
                iconName = "unknown_equipment"
            }
            guard let image = mapImageName(name: iconName) else {
                Logger.info("File name mapping issue with <Gateway image> named - \("\(rawValue)/\(iconName.lowercased()).svg")")
                return nil
            }
            return image
        }
        
        func getExtenderImage(name:String?) -> UIImage! {
            let defaultImage: UIImage! = UIImage(named: "Extender_icon")
            guard let iconName = name, !iconName.isEmpty else {
                Logger.info("Icon name for Extender not found in response")
                return defaultImage
            }
            guard let image = mapImageName(name: iconName) else {
                Logger.info("File name mapping issue with <Extender image> named - \("\(rawValue)/\(iconName.lowercased()).svg")")
                return defaultImage
            }
            return image
        }
        
        func getStreamImage(name:String?) -> UIImage! {
            let defaultImage: UIImage! = UIImage(named: "tvDeviceListIcon")
            return defaultImage
            
            // Passing default Stream icon for now
            // Uncomment if needed.
            /**
            guard let iconName = name, !iconName.isEmpty else {
                Logger.info("Icon name for Stream not found in response")
                return defaultImage
            }
            if iconName.lowercased().localizedStandardContains("stream") {
                return defaultImage
            }
            guard let image = mapImageName(name: iconName) else {
                Logger.info("File name mapping issue with <Stream image> named - \("\(rawValue)/\(iconName.lowercased()).svg")")
                return defaultImage
            }
            return image
            */
        }
        
        //MARK: Map device icon with response value
        private func mapImageName(name:String) -> UIImage? {
            var imageURLs = [URL]()
            if self == .white {
                imageURLs = DeviceManager.shared.allImagesWhiteURL
            } else if self == .gray {
                imageURLs = DeviceManager.shared.allImagesGrayURL
            }
            if !imageURLs.isEmpty {
                let imageURL = imageURLs.filter{$0.lastPathComponent.replacingOccurrences(of: ".svg", with: "").isMatching(name) }
                if imageURL.isEmpty {
                    return nil
                } else {
                    let imageUrl = URL(fileURLWithPath: imageURL[0].path)
                    if let svgImage = SVGKImage(contentsOf: imageUrl) {
                        return svgImage.uiImage
                    } else {
                        return nil
                    }
                }
            }
            return nil
        }
    }
    
    // For now make it as a shared instance. In bigger picture all managers
    // should be include into session manager which is created per session
    class var shared: DeviceManager {
        struct Singleton {
            static let instance = DeviceManager()
        }
        return Singleton.instance
    }
    static let dateFormatter = ISO8601DateFormatter()
    var devices: [LightspeedNode]?
    var streamDevices = [LightspeedNode]()
    let folderManager = FoldersMerger()
    var allImagesWhiteURL = [URL]()
    var allImagesGrayURL = [URL]()
    
    //MARK: - Gateway icon mapping
    func getGatewayImage(equipmentType: String) -> UIImage {
        switch equipmentType {
        case "D-Link":
            let name = "Smart Router DLink"
            if let image = DeviceManager.IconType.white.getGatewayImage(name: name) {
                return image
            }
            return UIImage(named: name)!
        case "Sagemcom":
            let name = "Smart Router Sage"
            if let image = DeviceManager.IconType.white.getGatewayImage(name: name) {
                return image
            }
            return UIImage(named: name)!
        case "FTTH Gateway Gen 7", "Ubee 1319", "Ubee 1326", "Ubee 1338", "Ubee 1322":
            let name = "Fiber Gateway 5"
            if let image = DeviceManager.IconType.white.getGatewayImage(name: name) {
                return image
            }
            return UIImage(named: "Fiber Gateway")!
        case "Ubee 1340", "FTTH Gateway Gen 9", "Multi Gig FTTH XGSPON Gen 9":
            let name = "Gateway 6E"
            if let image = DeviceManager.IconType.white.getGatewayImage(name: name) {
                return image
            }
            return UIImage(named: "Fiber Gateway")!
        case "FTTH Gateway Gen 8", "Multi Gig FTTH XGSPON":
            let name = "Fiber Gateway 6 Max"
            if let image = DeviceManager.IconType.white.getGatewayImage(name: name) {
                return image
            }
            return UIImage(named: "Fiber Gateway")!
        case "Altice One Box Gateway":
            let name = "Gateway 4 A1"
            if let image = DeviceManager.IconType.white.getGatewayImage(name: name) {
                return image
            }
            return UIImage(named: name)!
        default:
            return UIImage(named: "icon_wifi_white")!
        }
    }
    
    //MARK: - Utility Methods
    func getGwidForMac(mac:String) -> String {
        if let deviceNode = self.devices?.filter({ $0.mac?.isMatching(mac) == true}).first {
            if let gwid = deviceNode.gwid, !gwid.isEmpty {
                return gwid
            }
        }
        return MyWifiManager.shared.deviceMAC ?? ""
    }
    
    func getCMA_CategoryForMac(mac:String) -> String {
        if let deviceNode = self.devices?.filter({ $0.mac?.isMatching(mac) == true }).first {
            return deviceNode.category ?? ""
        }
        return ""
    }
    
    func getCMA_DeviceTypeForMac(mac:String) -> String {
        if let deviceNode = self.devices?.filter({ $0.mac?.isMatching(mac) == true }).first {
            return deviceNode.deviceType ?? ""
        }
        return ""
    }
    
    func getHostnameForMac(mac:String) -> String {
        if let deviceNode = self.devices?.filter({ $0.mac?.isMatching(mac) == true }).first {
            return deviceNode.hostname ?? ""
        }
        return ""
    }
    
    func getVendorForMac(mac: String) -> String? {
        if let deviceNode = self.devices?.filter({ $0.mac?.isMatching(mac) == true }).first {
            return deviceNode.vendor ?? ""
        }
        return ""
    }
    
    func getPIDForMac(mac:String) -> Int {
        if let deviceNode = self.devices?.filter({ $0.mac?.isMatching(mac) == true }).first {
            return deviceNode.pid ?? 0
        }
        return 0
    }
    
    func getDeviceDetailsForMac(mac:String) -> LightspeedNode?{
        if let device = self.devices?.filter({ $0.mac?.isMatching(mac) == true }).first {
            return device
        }
        return nil
    }
    
    func checkAndUpdateStreamDevices() {
        if MyWifiManager.shared.isTvStreamAvailable() {
            if MyWifiManager.shared.isTvStreamAvailable() { // Added for CMAIOS-1877
                self.streamDevices.removeAll()
                let arrStbs = MyWifiManager.shared.getSTBs()
                for stb in arrStbs  {
                    if let device = self.devices?.filter({($0.mac?.replacingOccurrences(of: ":", with: "").isMatching(stb.device_mac) ?? false)}), !device.isEmpty {
                        self.streamDevices.append(device[0])
                    }
                }
            }
            if MyWifiManager.shared.isTVPackage() {
                let arrStbs = MyWifiManager.shared.getStreamDevicesFromAccounts()
                for stb in arrStbs  {
                    self.devices?.removeAll(where: { node in
                        return WifiConfigValues.checkMACFormat(mac: node.mac ?? "").isMatching(WifiConfigValues.checkMACFormat(mac: stb.mac ?? ""))
                    })
                }
            }
            
        }
    }
        
    //MARK: - API calls
    func performGetAllNodes() {
        APIRequests.shared.getAllNodes { _ in
        }
    }
    
    func setNode(_ nodes: [LightspeedNode], completion: @escaping ((Result<Void, Error>) -> Void)) {
        do {
           guard let nodesDict = try nodes.map({ try $0.asDictionary() }) as? AnyObject else { return }
            var params = [String: AnyObject]()
            params["devices"] = nodesDict
            let setNodeURL = SETNODE_PATH_URL + "?sessionid=\(MyWifiManager.shared.sessionID)"
            let requestObj = RequestBuilder(url: setNodeURL, method: .post, serviceKey: .postNode, jsonParams: params, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
            requestObj.validate().responseDecodable(of: SetNodeResponse.self, decoder: JSONDecoder(), completionHandler: { response in
                switch response.result {
                case let .success(value) where value.error == 0:
                    completion(.success(()))
                case let .success(value):
                    completion(.failure(NSError(domain: value.desc ?? "failed", code: value.error)))
                case let .failure(error):
                    completion(.failure(error))
                }
            })
        } catch {
            
        }
    }
    //MARK: - Download and Unzip Device Icons
    func downloadDeviceIcons(color: IconType) {
        let queue = DispatchQueue(label: "deviceicon-queue", attributes: DispatchQueue.Attributes.concurrent)
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(color.rawValue).zip")
            return (fileURL!, [.removePreviousFile, .createIntermediateDirectories])
        }
        let oldDestinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(color.rawValue)
        let isImagesExist = self.folderManager.isDir(atPath: oldDestinationURL?.path)
        let lastDownloaded = PreferenceHandler.getValuesForKey("\(color.rawValue)-since-modified")
        var params = [String: AnyObject]()
        params["format"] = "svg" as AnyObject
        params["size"] = "All" as AnyObject
        params["color"] = color.rawValue as AnyObject
        if isImagesExist {
            params["sinceModified"] = lastDownloaded as AnyObject
        }
        let requestObj: DownloadRequest = RequestBuilder(url: DEVICEICONS_PATH_URL, method: .get, serviceKey: .deviceIcons, jsonParams: params, encoding: URLEncoding.default).buildDownloadRequest(destination: destination)
        requestObj.validate().responseData(queue: queue) { [weak self] response in
            guard let self = self, response.error == nil else {
                let name = color.rawValue
                let destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(name)
                self!.getAllImagesURL(destURL: destinationURL, color: name)
                return }
            var name = color.rawValue
            if lastDownloaded != nil && isImagesExist {
                name += "1"
            }
            PreferenceHandler.saveValue(DeviceManager.dateFormatter.string(from: Date()), forKey: "\(color)-since-modified")
            let destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(name)
            self.unzip(source: response.fileURL, destination: destinationURL)
            if lastDownloaded != nil && isImagesExist {
                self.folderManager.merge(atPath: destinationURL?.path, toPath: oldDestinationURL?.path)
            }
            self.getAllImagesURL(destURL: destinationURL, color: name)
        }
    }
    func unzip(source: URL?, destination: URL?) {
        do {
            try Zip.unzipFile(source!, destination: destination!, overwrite: true, password: nil)
            try folderManager.fileManager.removeItem(atPath: source?.path ?? "")
        } catch {
            Logger.info("Extraction of ZIP archive failed with error:\(error)")
        }
    }
    
    func getAllImagesURL(destURL: URL?, color: String) {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: destURL!, includingPropertiesForKeys: nil, options: [])
            if color == "white" {
                allImagesWhiteURL = directoryContents.filter{ $0.pathExtension == "svg" }
            } else {
                allImagesGrayURL = directoryContents.filter{ $0.pathExtension == "svg" }
            }
        } catch {
            Logger.info("Get all images url \(error)")
        }
    }
    
    func sortDevices(devices: [ConnectedDevice]) -> [ConnectedDevice] {
        var sortedDevices = [ConnectedDevice] ()
        let alphabetSorting = (devices.filter{$0.title.first!.isLetter}).sorted {$0.title.localizedStandardCompare($1.title) == ComparisonResult.orderedAscending}
        
        let numberSorting = devices.filter{$0.title.first!.isNumber}.sorted {$0.title.localizedStandardCompare($1.title) == ComparisonResult.orderedAscending}
        
        let symbolSorting = devices.filter{!($0.title.first!.isLetter) && !($0.title.first!.isNumber)}.sorted {$0.title.localizedStandardCompare($1.title) == ComparisonResult.orderedAscending}
        
        sortedDevices = alphabetSorting + numberSorting + symbolSorting
        return sortedDevices
    }
}
//MARK: - Folder Manager
// Copy logic
class FoldersMerger {

    enum ActionType { case move, copy }
    enum ConflictResolution { case keepSource, keepDestination }

    let fileManager = FileManager.default
    private var actionType: ActionType!
    private var conflictResolution: ConflictResolution!
    private var deleteEmptyFolders: Bool!

    init(actionType: ActionType = .move, conflictResolution: ConflictResolution = .keepSource, deleteEmptyFolders: Bool = true) {
        self.actionType = actionType
        self.conflictResolution = conflictResolution
        self.deleteEmptyFolders = deleteEmptyFolders
    }

    func merge(atPath: String?, toPath: String?) {
        guard let atPath = atPath, let toPath = toPath else { return }
        let pathEnumerator = fileManager.enumerator(atPath: atPath)

        var folders: [String] = [atPath]

        while let relativePath = pathEnumerator?.nextObject() as? String {

            let subItemAtPath = URL(fileURLWithPath: atPath).appendingPathComponent(relativePath).path
            let subItemToPath = URL(fileURLWithPath: toPath).appendingPathComponent(relativePath).path

            if isDir(atPath: subItemAtPath) {

                if deleteEmptyFolders! {
                   folders.append(subItemAtPath)
                }

                if !isDir(atPath: subItemToPath) {
                    do {
                        try fileManager.createDirectory(atPath: subItemToPath, withIntermediateDirectories: true, attributes: nil)
                        Logger.info("FoldersMerger: directory created: \(subItemToPath)", sendLog: "FoldersMerger: Directory created")
                    }
                    catch let error {
                        Logger.info("ERROR FoldersMerger: \(error.localizedDescription)")
                    }
                }
                else {
                    Logger.info("FoldersMerger: directory \(subItemToPath) already exists", sendLog: "FoldersMerger: directory exists")
                }
            }
            else {

                if isFile(atPath:subItemToPath) && conflictResolution == .keepSource {
                    do {
                        try fileManager.removeItem(atPath: subItemToPath)
                        Logger.info("FoldersMerger: file deleted: \(subItemToPath)", sendLog: "FoldersMerger: file deleted")
                    }
                    catch let error {
                        Logger.info("ERROR FoldersMerger: \( error.localizedDescription)")
                    }
                }

                do {
                    try fileManager.moveItem(atPath: subItemAtPath, toPath: subItemToPath)
                    Logger.info("FoldersMerger: file moved from \(subItemAtPath) to \(subItemToPath)", sendLog: "FoldersMerger: file moved")
                }
                catch let error {
                    Logger.info("ERROR FoldersMerger: \( error.localizedDescription)")
                }
            }
        }

        if deleteEmptyFolders! {
            folders.sort(by: { (path1, path2) -> Bool in
                return path1.split(separator: "/").count < path2.split(separator: "/").count
            })
            while let folderPath = folders.popLast() {
                if isDirEmpty(atPath: folderPath) {
                    do {
                        try fileManager.removeItem(atPath: folderPath)
                        Logger.info("FoldersMerger: empty dir deleted: \(folderPath)", sendLog: "FoldersMerger: empty dir deleted")
                    }
                    catch {
                        Logger.info("ERROR FoldersMerger: \( error.localizedDescription)")
                    }
                }
            }
        }
    }

    func isDir(atPath: String?) -> Bool {
        guard let atPath = atPath else { return false }
        var isDir: ObjCBool = false
        let exist = fileManager.fileExists(atPath: atPath, isDirectory: &isDir)
        return exist && isDir.boolValue
    }

    private func isFile(atPath: String) -> Bool {
        var isDir: ObjCBool = false
        let exist = fileManager.fileExists(atPath: atPath, isDirectory: &isDir)
        return exist && !isDir.boolValue
    }

    private func isDirEmpty(atPath: String) -> Bool {
        do {
            return try fileManager.contentsOfDirectory(atPath: atPath).count == 0
        }
        catch _ {
            return false
        }
    }
}
