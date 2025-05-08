//
//  LightSpeedAPIRequests.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 12/08/22.
//

import Foundation
import Alamofire
import SmartWiFi
import CoreMedia

extension APIRequests {
    
//    class var shared: LightSpeedAPIRequests {
//        struct Singleton {
//            static let instance = LightSpeedAPIRequests()
//        }
//        return Singleton.instance
//    }
    
    // MARK: - GATEWAY STATUS API REQUEST FOR DOCSIS / Legacy
    func initiateGatewayStatusAPIRequest(_ queryString: String, completionHandler:@escaping (_ success:Bool, _ response:OperationalStatusAPIResponse?, _ error: AFError?) -> Void) {
        MyWifiManager.shared.lightSpeedAPIState = .opCallInProgress
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "Gateway-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let url = OPERATIONALSTATUS_PATH_URL + queryString + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: (url), method: .get,
                                        serviceKey: ServiceKey.lightSpeedRouter, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()

        requestObj.responseDecodable(of: OperationalStatusAPIResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {

            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Gateway Status API success")
                if let cm = value.cm {
                    if let cmip = cm.cmip, !cmip.isEmpty {
                        MyWifiManager.shared.cmipOnu = cmip
                    }
                    if let cmtsInfo = cm.cmtsInfo {
                        if let cmtsip = cmtsInfo.cmtsIp, !cmtsip.isEmpty {
                            MyWifiManager.shared.cmtsipoltip = cmtsip
                        }
                        if let cmStatus = cmtsInfo.cmStatus, let status = cmStatus.lowercased() as String?, !status.isEmpty {
                            if status.contains("online") || status.contains("operational") {
                                if !self.isRebootOccured {
                                    MyWifiManager.shared.isOperationalStatusOnline = true
                                    MyWifiManager.shared.stalenessType = "0"
                                    if !MyWifiManager.shared.supressPHCalls {
                                        self.performLiveTopologyRequest()
                                    } else { //Issue fix for CMA-915
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "success"))
                                        }
                                    }
                                    self.performSSIDInfoRequest()
                                }
                                completionHandler(true, value, nil)
                            } else { ///Router Offline
                                MyWifiManager.shared.isOperationalStatusOnline = false
                                MyWifiManager.shared.stalenessType = "-1"
                                if !self.isRebootOccured {
                                    self.performSSIDInfoRequest()
                                }
                                self.removeLTData()
                                //CMAIOS-2664
                                if !self.isRebootOccured {
                                    SpotLightsManager.shared.configureSpotLightsForMyWifi()
                                }
                                //
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "OP_Offline"))
                                }
                                completionHandler(false, value, nil)
                            }
                            MyWifiManager.shared.lightSpeedAPIState = .none
                        } else { ///Router failure
                            MyWifiManager.shared.stalenessType = "-1"
                            if !self.isRebootOccured {
                                self.performSSIDInfoRequest()
                            }
                            self.removeLTData()
                            MyWifiManager.shared.lightSpeedAPIState = .failedOperationalStatus
                            //CMAIOS-2664
                            if !self.isRebootOccured {
                                SpotLightsManager.shared.configureSpotLightsForMyWifi()
                            }
                            //
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                            }
                            if !self.isRebootOccured {
                                let errorLogger = APIErrorLogger()
                                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: url, uiMessage: "", response: response.response, responseData: response.data)
                            }
                            completionHandler(false, nil, nil)
                        }
                    } else { ///Router failure
                        self.removeLTData()
                        MyWifiManager.shared.lightSpeedAPIState = .failedOperationalStatus
                        //CMAIOS-2664
                        if !self.isRebootOccured {
                            SpotLightsManager.shared.configureSpotLightsForMyWifi()
                        }
                        //
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                        }
                        if !self.isRebootOccured {
                            let errorLogger = APIErrorLogger()
                            errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: url, uiMessage: "", response: response.response, responseData: response.data)
                        }
                        completionHandler(false, nil, nil)
                    }
                } else { ///Router failure
                    self.removeLTData()
                    MyWifiManager.shared.lightSpeedAPIState = .failedOperationalStatus
                    //CMAIOS-2664
                    if !self.isRebootOccured {
                        SpotLightsManager.shared.configureSpotLightsForMyWifi()
                    }
                    //
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                    }
                    if !self.isRebootOccured {
                        let errorLogger = APIErrorLogger()
                        errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: url, uiMessage: "", response: response.response, responseData: response.data)
                    }
                    completionHandler(false, nil, nil)
                }
               // self.performSSIDInfoRequest()

            case .failure(let value):
                Logger.info("Gateway status API failure")
                MyWifiManager.shared.lightSpeedAPIState = .failedOperationalStatus
                if !self.isRebootOccured {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: url, uiMessage: "", response: response.response, responseData: response.data)
                }
                //CMAIOS-2664
                if !self.isRebootOccured {
                    SpotLightsManager.shared.configureSpotLightsForMyWifi()
                }
                //
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                }
                completionHandler(false, nil, value)
            }
        }
    }
    
    // MARK: - GATEWAY STATUS API REQUEST FOR FIBER
    func initiateGatewayStatusAPIRequestForFiber(_ queryString: String, completionHandler:@escaping (_ success:Bool, _ response:OperationalStatusAPIResponseFiber?, _ error: AFError?) -> Void) {
        MyWifiManager.shared.lightSpeedAPIState = .opCallInProgress
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "Gateway-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let url = OPERATIONALSTATUS_PATH_URL + queryString + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: (url), method: .get,
                                        serviceKey: ServiceKey.lightSpeed, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()

        requestObj.responseDecodable(of: OperationalStatusAPIResponseFiber.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {

            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Gateway status API for Fiber success")
                if let cm = value.operationalStatus, let cmStatus = cm.lowercased() as String?, !cmStatus.isEmpty {
                    if cmStatus.contains("operational") || cmStatus.contains("online") {
                        if !self.isRebootOccured {
                            MyWifiManager.shared.isOperationalStatusOnline = true
                            MyWifiManager.shared.stalenessType = "0"
                            self.performLiveTopologyRequest()
                            self.performSSIDInfoRequest()
                        }
                        completionHandler(true, value, nil)
                    } else { ///Gateway Offline
                            MyWifiManager.shared.isOperationalStatusOnline = false
                            MyWifiManager.shared.stalenessType = "-1"
                            if !self.isRebootOccured {
                                self.performSSIDInfoRequest()
                            }
                            self.removeLTData()
                        //CMAIOS-2664
                        if !self.isRebootOccured {
                            SpotLightsManager.shared.configureSpotLightsForMyWifi()
                        }
                        //
                        DispatchQueue.main.async {
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "OP_Offline"))
                            }
                            completionHandler(false, value, nil)
                    }
                    MyWifiManager.shared.fiberOperationalStatus = NSMutableDictionary(dictionary: NSDictionary(object: value, forKey: "OperationalStatusAPIResponseFiber" as NSCopying))
                    MyWifiManager.shared.lightSpeedAPIState = .none
                } else { ///Gateway Failure
                    MyWifiManager.shared.stalenessType = "-1"
                    if !self.isRebootOccured {
                        self.performSSIDInfoRequest()
                    }
                    self.removeLTData()
                    MyWifiManager.shared.lightSpeedAPIState = .failedOperationalStatus
                    //CMAIOS-2664
                    if !self.isRebootOccured {
                        SpotLightsManager.shared.configureSpotLightsForMyWifi()
                    }
                    //
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                    }
                    if !self.isRebootOccured {
                        let errorLogger = APIErrorLogger()
                        errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: url, uiMessage: "", response: response.response, responseData: response.data)
                    }
                    completionHandler(false, nil, nil)
                }
               // self.performSSIDInfoRequest()

            case .failure(let value):
                Logger.info("Gateway status API for Fiber failure")
                MyWifiManager.shared.lightSpeedAPIState = .failedOperationalStatus
                if !self.isRebootOccured {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: url, uiMessage: "", response: response.response, responseData: response.data)
                }
                self.removeLTData()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                }
                completionHandler(false, nil, value)
            }
        }
    }
    
    func removeLTData() {
        MyWifiManager.shared.lightSpeedData?["extender_status"] = nil
        MyWifiManager.shared.lightSpeedData?["links"] = nil
        MyWifiManager.shared.lightSpeedData?["nodes"] = nil
        MyWifiManager.shared.lightSpeedData?["rec_disconn"] = nil
    }
    
    // MARK: - LIVE TOPOLOGY API REQUEST
    func initiateLiveTopologyRequest(withReboot reboot: Bool = false, completionHandler:@escaping (_ success:Bool, _ response:LightSpeedAPIResponse?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "LightSpeed-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var deviceMac = MyWifiManager.shared.deviceMAC ?? ""
        deviceMac += "?devicetype=\(MyWifiManager.shared.deviceType ?? "")"
        deviceMac += "&sessionid=\(MyWifiManager.shared.sessionID)"
        deviceMac += "&ext_bit=1&rd_bit=1"
        var lightSpeedURL = LIGHTSPEED_API_URL_PATH + deviceMac
        if reboot {lightSpeedURL += "&gwReboot=true"}
        let requestObj = RequestBuilder(url: (lightSpeedURL), method: .get,
                                        serviceKey: ServiceKey.lightSpeed, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        if let lightSpeedDict = MyWifiManager.shared.lightSpeedData {
            if lightSpeedDict.keys.isEmpty {
                MyWifiManager.shared.lightSpeedAPIState = .firstLiveTopologyCallInProgress
            } else {
                MyWifiManager.shared.lightSpeedAPIState = .none
            }
        } else {
            MyWifiManager.shared.lightSpeedAPIState = .firstLiveTopologyCallInProgress
        }
        requestObj.validate().responseDecodable(of: LightSpeedAPIResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {

            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "LIVE TOPOLOGY success")
                MyWifiManager.shared.lightSpeedAPIState = .completed
                guard (value.nodes != nil) else {
                    MyWifiManager.shared.lightSpeedAPIState = .failedLiveTopology
                    self.removeLTData()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                    }
                    if APIRequests.shared.restrictLTErrorLogging == false {
                        let errorLogger = APIErrorLogger()
                        errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: lightSpeedURL, uiMessage: "", response: response.response, responseData: response.data)
                    }
                    completionHandler(false, nil, nil)
                    return
                }
                DispatchQueue.main.async {
                    if MyWifiManager.shared.saveLightspeedAPIResponse(value: value) == false { // This will be false only if there is no master node in LT response
                        if APIRequests.shared.restrictLTErrorLogging == false {
                            let errorLogger = APIErrorLogger()
                            errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: LIGHTSPEED_API_URL_PATH, uiMessage: "", response: response.response, responseData: response.data)
                            MyWifiManager.shared.lightSpeedAPIState = .failedLiveTopology
                        }
                        self.removeLTData()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                        }
                        completionHandler(false, nil, nil)
                    } else {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "success"))
                        }
                        completionHandler(true, value, nil)
                    }
                    SpotLightsManager.shared.configureSpotLightsForMyWifi()
                    return
                }
                
                /*if let extenderStatus = value.extender_status as LightSpeedAPIResponse.extender_status? {
                    if let online = extenderStatus.online {
                        LiveTopologyStatus.shared.online = online
                    }
                    if let onAccount = extenderStatus.on_account {
                        LiveTopologyStatus.shared.on_account = onAccount
                    }
                    if let nodes = extenderStatus.nodes as [Any]?, !nodes.isEmpty {
                        LiveTopologyStatus.shared.extender_nodes = nodes as NSArray
                    }
                }
                if let links = value.links as [LightSpeedAPIResponse.Links]?, !links.isEmpty {
                    LiveTopologyStatus.shared.links = links as NSArray
                }
                if let nodes = value.nodes as [LightSpeedAPIResponse.Nodes]?, !nodes.isEmpty {
                    LiveTopologyStatus.shared.nodesData = nodes as NSArray
                }
//                LiveTopologyStatus.shared.getConnectedDevices("d8:d7:75:81:18:4a")
               Logger.info("success")
//                self.performSSIDInfoRequest()
                 */

            case .failure(let value):
                /// UN-COMMENT below code to use mock Live Topology response in case the API is failing. USERNAME - laboxtest01
                /*
                 do {
                     let mockJsonStr = try String(contentsOf: Bundle.main.url(forResource: "MockLiveTopology", withExtension: nil)!)
                     let data = mockJsonStr.data(using: .utf8)
                     let value = try JSONDecoder().decode(LightSpeedAPIResponse.self, from: data!)
                     if let extenderStatus = value.extender_status as LightSpeedAPIResponse.extender_status? {
                         if let online = extenderStatus.online {
                             LiveTopologyStatus.shared.online = online
                         }
                         if let onAccount = extenderStatus.on_account {
                             LiveTopologyStatus.shared.on_account = onAccount
                         }
                         if let nodes = extenderStatus.nodes as [Any]?, !nodes.isEmpty {
                             LiveTopologyStatus.shared.extender_nodes = nodes as NSArray
                         }
                     }
                     if let links = value.links as [LightSpeedAPIResponse.Links]?, !links.isEmpty {
                         LiveTopologyStatus.shared.links = links as NSArray
                     }
                     if let nodes = value.nodes as [LightSpeedAPIResponse.Nodes]?, !nodes.isEmpty {
                         LiveTopologyStatus.shared.nodesData = nodes as NSArray
                     }
                     WifiConfigValues.shared.isLiveTopology = false
                     WifiConfigValues.shared.isLiveTopologySuccess = true
                     DispatchQueue.main.async {
                         NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: true))
                     }
                     completionHandler(true, value, nil)
                 }
                 catch {
                     completionHandler(false, nil, value)
                 }
                 return
                */
               Logger.info("******Live Topology failure******")
//                WifiConfigValues.shared.isLiveTopology = false
//                WifiConfigValues.shared.isLiveTopologySuccess = false
                if APIRequests.shared.restrictLTErrorLogging == false {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: lightSpeedURL, uiMessage: "", response: response.response, responseData: response.data)
                }
                MyWifiManager.shared.lightSpeedAPIState = .failedLiveTopology
                self.removeLTData()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LightSpeedAPI"),object: "failed"))
                }
                completionHandler(false, nil, value)
            }
        }
    }
    
    func initiateClientUsageRequest(completionHandler:@escaping (_ success:Bool, _ response:ClientUsageResponse?, _ error: AFError?) -> Void) {
//https://stage.cma.alticeusa.com/api/lightspeed/livetopology/clientsusage/58FC20FBF35F?devicetype=XSR150DX
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "LightSpeed-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var deviceMac = MyWifiManager.shared.deviceMAC ?? ""
        deviceMac += "?devicetype=\(MyWifiManager.shared.deviceType ?? "")"
        deviceMac += "&sessionid=\(MyWifiManager.shared.sessionID)"
        let lightSpeedURL = LIGHTSPEED_API_URL_PATH + "clientsusage/" + deviceMac
        let requestObj = RequestBuilder(url: (lightSpeedURL), method: .get,
                                        serviceKey: ServiceKey.clientUsage, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        requestObj.responseDecodable(of: ClientUsageResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            switch response.result {

            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Client Usage success")
                if value.error == 0 || value.error == nil {
                    completionHandler(true, value, nil)
                } else {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Profile", body: "", requestURL: lightSpeedURL, uiMessage: "", response: response.response, responseData: response.data)
                    completionHandler(false, value, response.error)
                }
            case .failure(let value):
               Logger.info("******Client Usage failure******")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: lightSpeedURL, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        }
    }
    
    private struct SetNodeResponse:Decodable{
        var desc:String
        var error:Int?
    }
    
    // MARK: - Set Node API REQUEST
    func initiateSetNodeRequest(nodeData:[String : AnyObject]?, completionHandler:@escaping (_ success:Bool, _ error:AFError?)->Void){
        guard let nodesDict = nodeData as? AnyObject else { return }
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let setNodeURL = SETNODE_PATH_URL + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: setNodeURL, method: .post, serviceKey: .postNode, jsonParams:nodesDict as? [String : AnyObject], encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
            requestObj.responseDecodable(of: SetNodeResponse.self, decoder: JSONDecoder(), completionHandler: {response in
                switch response.result{
                case .success(let value):
                    Logger.info(response.debugDescription, sendLog: "Set Node success")
                    if value.error == 0 {
                        completionHandler(true, nil)
                    }
                    else {
                        let errorLogger = APIErrorLogger()
                        errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Profile", body: CommonUtility.jsonToString(json: nodeData as AnyObject?), requestURL: setNodeURL, uiMessage: "Sorry, we ran into a problem.", response: response.response, responseData: response.data)
                        completionHandler(false, response.error)
                    }
                case .failure(let error):
                    Logger.info(error.localizedDescription)
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Profile", body: CommonUtility.jsonToString(json: nodeData as AnyObject?), requestURL: setNodeURL, uiMessage: "Sorry, we ran into a problem.", response: response.response, responseData: response.data)
                    completionHandler(false, error)
                }
            })
        //}
    }
    
    // MARK: - Reboot API REQUEST
    
    func queryStringForReboot() -> String {
        var queryString = ""
        if MyWifiManager.shared.accessTech == "docsis" || MyWifiManager.shared.accessTech == "legacy" {
            //https://dev.cma.alticeusa.com/api/lightspeed/gwaction/cmreboot/802BF9F4D519?cmtsip=65.19.106.12&cmip=10.20.184.100
            queryString = "cmreboot/\(MyWifiManager.shared.deviceMAC ?? "")"
            queryString += "?sessionid=\(MyWifiManager.shared.sessionID)"
            queryString += "&cmtsip=\(MyWifiManager.shared.cmtsipoltip)"
            queryString += "&cmip=\(MyWifiManager.shared.cmipOnu)"
        } else if MyWifiManager.shared.accessTech == "gpon" {
            //https://dev.cma.alticeusa.com/api/lightspeed/gwaction/onureboot/CC19A8E8E33F?oltip=10.172.72.93&onu=4/1501/6
            //onu = response.oltcardid/response.oltponportid/response.oltonuid
            //oltip = response.oltip
            queryString = "onureboot/\(MyWifiManager.shared.deviceMAC ?? "")"
            queryString += "?sessionid=\(MyWifiManager.shared.sessionID)"
            if let fiberOperationalStatus = MyWifiManager.shared.fiberOperationalStatus, !fiberOperationalStatus.allKeys.isEmpty, let operationalStatus = fiberOperationalStatus.value(forKey: "OperationalStatusAPIResponseFiber") as? OperationalStatusAPIResponseFiber {
                if let oltip = operationalStatus.oltip, !oltip.isEmpty {
                    queryString += "&oltip=\(oltip)"
                }
                if let oltcardid = operationalStatus.oltcardid, !oltcardid.isEmpty, let oltponportid = operationalStatus.oltponportid, !oltponportid.isEmpty, let oltonuid = operationalStatus.oltonuid, !oltonuid.isEmpty {
                    queryString += "&onu=\(oltcardid)/" + "\(oltponportid)/" + "\(oltonuid)"
                }
            }
        } else {
            //https://dev.cma.alticeusa.com/api/lightspeed/gwaction/gwreboot/9072825087ba?devicetype=fast5260
            queryString = "gwreboot/\(MyWifiManager.shared.deviceMAC ?? "")"
            queryString += "?sessionid=\(MyWifiManager.shared.sessionID)"
            queryString += "&devicetype=\(MyWifiManager.shared.deviceType ?? "")"
        }
        return queryString
    }
    
    func initiateRebootRequest(completionHandler:@escaping (_ success:Bool, _ error:AFError?)->Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queryString = queryStringForReboot()
        let rebootURL = REBOOT_PATH_URL + queryString
        let requestObj = RequestBuilder(url: rebootURL, method: .get, serviceKey: .reboot, jsonParams:nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.responseDecodable(of: RebootAPIResponse.self, decoder: JSONDecoder(), completionHandler: {response in
            switch response.result{
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Reboot success")
                if value.error == 0 {
                    completionHandler(true, nil)
                } else {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Restart", body: "", requestURL: rebootURL, uiMessage: "", response: response.response, responseData: response.data)
                    completionHandler(false, response.error)
                }
            case .failure(let error):
                Logger.info(error.localizedDescription)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Restart", body: "", requestURL: rebootURL, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, error)
            }
        })
    }
    
    func queryStringForDeadZone() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        let pastDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let pastDateString = dateFormatter.string(from: pastDate)
        let queryString = "\(MyWifiManager.shared.deviceMAC ?? "")/\(pastDateString)/\(currentDateString)?devicetype=\(MyWifiManager.shared.deviceType ?? "")&sessionid=\(MyWifiManager.shared.sessionID)"
        return queryString
    }

    func initiateDeadZoneRequest(completionHandler:@escaping (_ success:Bool, _ response:DeadZoneAPIResponse?, _ error:AFError?)->Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let deadZoneURL = DEAD_ZONE_API_URL_PATH + queryStringForDeadZone()
        let requestObj = RequestBuilder(url: deadZoneURL, method: .get, serviceKey: .deadZone, jsonParams:nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.responseDecodable(of: DeadZoneAPIResponse.self, decoder: JSONDecoder(), completionHandler: {response in
            switch response.result{
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "DeadZone success")
                    completionHandler(true,value,nil)
            case .failure(let value):
                Logger.info("DeadZone failure", sendLog: value.localizedDescription)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: deadZoneURL, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false,nil,value)
            }
        })
    }
    
}
