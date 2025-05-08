
//  APIRequests.swift
//  CustSupportApp
//
//  Created by Namarta on 18/05/22.


import Foundation
import Alamofire
import CoreMedia
import SmartWiFi
import CommonCrypto
class APIRequests {
    fileprivate var username: NSString!
    fileprivate var password: NSString!
    fileprivate var deviceDetails : [String : String]!
//    fileprivate var deviceMac : String!
    class var shared: APIRequests {
        struct Singleton {
            static let instance = APIRequests()
        }
        return Singleton.instance
    }
    var isRebootOccured = false
    var restrictLTErrorLogging = false
    var isAccountSignedOut = false
    var isReloadNotRequiredForMaui = false
    var isGetAccountBillApiFailed = true // Default set true, then it won't miss initial Get bill Account data
    var isListPaymentsApiFailed = true // Default set true, then it won't miss initial Listbill Payment data
    var hmacValue:String?
    var isFromChat = false
    var spotlightId = ""
    var isUpdateSpotlightCardRequests = false
    
    enum PausedBy {
        case client
        case profile
        case clientWithPid
    }
// MARK: - LOGIN REQUEST

    /// Triggers login webservice request.
    ///
    /// - parameter params:            params that needs to append in http post body
    /// - parameter completionHandler: completion handler to call back delegate method process with response comes from server.
    ///
    /// - returns: none
    func initiateLoginRequest(_ params : [String : AnyObject], completionHandler: @escaping (_ success:Bool, _ response: LoginResponse?, _ error: AFError?) -> Void) {
        self.username = params["username"] as? NSString
        self.password = params ["password"] as? NSString
        hmacValue = createHMACValueKey(username: self.username as String, password: self.password as String, serviceKey: ServiceKey.login)
        //The below encoding is for implementing the encoded query string
        /*   let paramURLEncoding = ParameterEncoding.custom {(request, params) ->
         (NSMutableURLRequest, NSError?) in

         let urlEncoding = Alamofire.ParameterEncoding.urlEncodedInURL
         let (urlRequest, error) = urlEncoding.encode(request, parameters: params)
         let mutableRequest = urlRequest.mutableCopy() as! NSMutableURLRequest
         mutableRequest.url = URL(string: (LOGIN_URL_PATH))
         mutableRequest.httpBody = urlRequest.url?.query?.data(using: String.Encoding.utf8)

         return (mutableRequest, error)

         }*/

        let queue = DispatchQueue(label: "Login-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue

        let requestObj = RequestBuilder(url: (LOGIN_URL_PATH), method: .post,
                                        serviceKey: ServiceKey.login, jsonParams: params,
                                        encoding: URLEncoding() as ParameterEncoding ).buildNetworkRequest()



        requestObj.validate().responseDecodable(of: LoginResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            self.hmacValue = ""
            switch response.result {
            case .success(let value):
                if value.access_token != nil {
                    LoginPreferenceManager.sharedInstance.setLoginAuthenticationDataToPreference(value.dictionary, user: self.username as String?)
                    Logger.info(response.value.debugDescription, sendLog: "Manual Login Success")
                    return completionHandler(true, value, nil)
                } else {
                    completionHandler(false, value, nil)
                }
            case .failure(let value):
                Logger.info("Login failure")
                if let data = response.data {
                    do {
                        let val = try JSONDecoder().decode(LoginResponse.self, from: data)
                        completionHandler(false, val, nil)
                    } catch {
                        Logger.info("Login Request error - \(error.localizedDescription)")
                        completionHandler(false, nil, value)
                    }
                } else {
                    completionHandler(false, nil, value)
                }
            }
        }
    }
    
    func createHMACValueKey(username: String, password: String, serviceKey: ServiceKey) -> String {
        guard serviceKey == .login || serviceKey == .mauiToken else {
            return ""
        }
        let endpoint = serviceKey == .login ? "/oauth/token:" : "/maui/token:"
        let authBaseString = "POST:\(endpoint)\(App.versionNumber()):\(username):\(password):\(Date().getDateCurrentDateHmac())"
        
        return authBaseString.hmac(key: "n0dplzbsfn37f2s78jf9")
    }

    func initiateSetWlanRequest(_ params : [String : AnyObject], completionHandler:@escaping (_ success:Bool, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "SetWlan-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let setWlanURL =  SETWLAN_PATH_URL + (MyWifiManager.shared.deviceMAC ?? "") + "?devicetype=\(MyWifiManager.shared.deviceType ?? "")" + "?sessionid=\(MyWifiManager.shared.sessionID)"
        
        let requestObj = RequestBuilder(url: (setWlanURL), method: .post,
                                        serviceKey: ServiceKey.setWlanInfo, jsonParams: params,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()



        requestObj.validate().responseDecodable(of: SetWLanResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {
            case .success(_):
                Logger.info("Edit Wifi Update success")
                self.performSSIDInfoRequest()
                completionHandler(true, nil)
            case .failure(_):
                Logger.info("Edit Wifi Update failure")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp:requestTimeStamp, screen: "EditWifi", body: CommonUtility.jsonToString(json: params as AnyObject?), requestURL: setWlanURL, uiMessage: "We can’t update your WiFi network settings. Please try again later.", response:response.response, responseData: response.data)
                completionHandler(false, nil)
            }
        }
    }
    
    func initiateLogoutRequest(completionHandler:@escaping (_ success:Bool, _ response:LogoutResponse?, _ error: AFError?) -> Void) {
        //The below encoding is for implementing the encoded query string
        /*   let paramURLEncoding = ParameterEncoding.custom {(request, params) ->
         (NSMutableURLRequest, NSError?) in

         let urlEncoding = Alamofire.ParameterEncoding.urlEncodedInURL
         let (urlRequest, error) = urlEncoding.encode(request, parameters: params)
         let mutableRequest = urlRequest.mutableCopy() as! NSMutableURLRequest
         mutableRequest.url = URL(string: (LOGIN_URL_PATH))
         mutableRequest.httpBody = urlRequest.url?.query?.data(using: String.Encoding.utf8)

         return (mutableRequest, error)

         }*/
        let queue = DispatchQueue(label: "Logout-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue

        let requestObj = RequestBuilder(url: (LOGOUT_URL_PATH), method: .post,
                                        serviceKey: ServiceKey.logout, jsonParams: nil,
                                        encoding: URLEncoding() as ParameterEncoding ).buildNetworkRequest()



        requestObj.validate().responseDecodable(of: LogoutResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            if response.response?.statusCode == 200 || response.response?.statusCode == 204 {
                completionHandler(true, nil, nil)
            } else {
                switch response.result {
                case .failure(let value):
                   Logger.info("Logout Request failure")
                   completionHandler(false, nil, value)
                case .success(_):
                    Logger.info("Logout Request success")
                    break
                    
                }
            }
        }
    }
    
    // MARK: - Access Profile API REQUESTS
   /* func initiateGetAccessProfileRequest(completionHandler:@escaping (_ success:Bool, _ response:AccessProfileGetResponse?, _ error:AFError?)->Void) {
        let queue = DispatchQueue(label: "AccessProfile-Get-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let accessProfileURL = PAUSE_API_URL_PATH + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: accessProfileURL, method: .get, serviceKey: .accessProfile, jsonParams: nil, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: AccessProfileGetResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result{
            case .success(let value):
                Logger.info(response.value.debugDescription)
                completionHandler(true,value, nil)
            case .failure(let error):
                Logger.info(error.localizedDescription)
                completionHandler(false, nil, error)
            }
        }
    }*/
    
    // MARK: - Access Profile API REQUESTS
    /*func initiateGetAccessProfileRequest(profileId: String, completionHandler:@escaping (_ success:Bool, _ response:AccessProfileDeleteResponse?, _ error:AFError?)->Void) {
        let queue = DispatchQueue(label: "AccessProfile-Delete-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let accessProfileURL = ACCESS_PROFILE_API_URL_PATH + "?sessionid=\(MyWifiManager.shared.sessionID)/" + "\(profileId)"
        let requestObj = RequestBuilder(url: accessProfileURL, method: .get, serviceKey: .accessProfile, jsonParams: nil, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: AccessProfileDeleteResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result{
            case .success(let value):
                Logger.info(response.value.debugDescription)
                completionHandler(true,value, nil)
            case .failure(let error):
                Logger.info(error.localizedDescription)
                completionHandler(false, nil, error)
            }
        }
    }*/

    func initiateGetAccessProfileRequest(pid:Int, completionHandler:@escaping (_ success:Bool, _ response:PauseProfileGetResponse?, _ error:AFError?)->Void) {
        let queue = DispatchQueue(label: "AccessProfile-GET-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let accessProfileURL = PAUSE_API_URL_PATH + "/pid/\(pid)" + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: accessProfileURL, method: .get, serviceKey: .accessProfile, jsonParams: nil, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: PauseProfileGetResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result{
            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Get Access Profile Request success")
                if let isProfilePaused = value.isProfilePaused {
                    if isProfilePaused && !MyWifiManager.shared.pausedProfileIds.contains(pid) {
                        MyWifiManager.shared.pausedProfileIds.append(pid)
                    } else if !isProfilePaused && MyWifiManager.shared.pausedProfileIds.contains(pid) {
                        MyWifiManager.shared.pausedProfileIds.removeAll(where: {$0 == pid})
                    }
                }
                completionHandler(true,value, nil)
            case .failure(let error):
                Logger.info(error.localizedDescription)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp:requestTimeStamp, screen: "ViewProfile", body: "", requestURL: accessProfileURL, uiMessage: "Sorry, facing issues to fetch the profile details right now.", response: response.response, responseData: response.data)
                completionHandler(false, nil, error)
            }
        }
    }
    
    func initiatePutAccessProfileRequest(pid:Int?, macID:String?, enablePause:Bool, pausedBy: PausedBy, completionHandler:@escaping (_ success:Bool, _ response:DevicePauseState?, _ error:AFError?)->Void){
        let queue = DispatchQueue(label: "AccessProfile-Put-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        var url = PAUSE_API_URL_PATH
        let pauseString = enablePause ? "pause" : "unpause"
        switch pausedBy {
        case .profile:
            url = url + "/pid/\(pid ?? 0)/" + pauseString
        case .client:
            url = url + "/client/\(macID ?? "")/" + pauseString
        case .clientWithPid:
            url = url + "/pid/\(pid ?? 0)/" + pauseString + "/\(macID ?? "")"
        }
        let accessProfileURL = url + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: accessProfileURL, method: .put, serviceKey: .accessProfile, jsonParams: nil, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: DevicePauseState.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]){ response in
            switch response.result{
            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Put Access Profile Request success")
                if enablePause == true {
                    if pausedBy == .profile && MyWifiManager.shared.pausedProfileIds.contains(pid ?? 0) == false {
                        MyWifiManager.shared.pausedProfileIds.append(pid ?? 0)
                    }
                } else {
                    if pausedBy == .profile && MyWifiManager.shared.pausedProfileIds.contains(pid ?? 0) == true {
                        MyWifiManager.shared.pausedProfileIds.removeAll(where: {$0 == pid})
                    }
                }
                completionHandler(true,value, nil)
            case .failure(let error):
                Logger.info(error.localizedDescription)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp:requestTimeStamp, screen: "ViewProfile", body: "", requestURL: accessProfileURL, uiMessage: "Sorry, we ran into a problem and can’t pause your device right now.", response: response.response, responseData: response.data)
                completionHandler(false, nil, error)
            }
        }
    }
    // MARK: - Access Profile By Client API
    func initiateGetAccessProfileByClientRequest(completionHandler:@escaping (_ success:Bool, _ response:PausedDevices?, _ error:AFError?)->Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "AccessProfile-Get-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let accessProfileURL = PAUSE_API_URL_PATH + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let requestObj = RequestBuilder(url: accessProfileURL, method: .get, serviceKey: .accessProfile, jsonParams: nil, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: PausedDevices.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result{
            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Get Access Profile By Client Request success")
                completionHandler(true,value, nil)
            case .failure(let error):
                Logger.info(error.localizedDescription)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp:requestTimeStamp, screen: "Pause", body: "", requestURL: accessProfileURL, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, error)
            }
        }
    }
    // MARK: - MAUI TOKEN REQUEST
    func initiateMAUITokenRequest(_ params: [String : AnyObject], completionHandler: @escaping (_ success:Bool, _ response: MAUITokenResponse?, _ error: AFError?) -> Void) {
        hmacValue = createHMACValueKey(username: params["username"] as? String ?? "", password: params["password"] as? String ?? "", serviceKey: ServiceKey.mauiToken)
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "MAUIToken-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let requestObj = RequestBuilder(url: (MAUI_TOKEN_URL_PATH), method: .post,
                                        serviceKey: ServiceKey.mauiToken, jsonParams: params,
                                        encoding: URLEncoding() as ParameterEncoding ).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: MAUITokenResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            self.hmacValue = ""
            switch response.result {

            case .success(let value):
                if value.access_token != nil {
                    LoginPreferenceManager.sharedInstance.setMauiTokenToPreference(token: value.access_token ?? "")
                    completionHandler(true, value, nil)
                    Logger.info(response.value.debugDescription, sendLog: "MAUI token success")
                } else {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: MAUI_TOKEN_URL_PATH, uiMessage: "We are experiencing technical difficulties, and cannot access your account at this time.  Please check back later.", response: response.response, responseData: response.data)
                    completionHandler(false, value, nil)
                }
                
            case .failure(let value):
                Logger.info("MAUI token failure")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: MAUI_TOKEN_URL_PATH, uiMessage: "We are experiencing technical difficulties, and cannot access your account at this time.  Please check back later.", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        }
    }
    // MARK: - MAUI Get Bank Image From Routing Number
    //CMAIOS-1996
    func mauiGetBankImgFromRoutingNum(routNum: String, completionHandler: @escaping (_ success: Bool, _ resValue: [bankImageRoutingNumberModel]?, _ error: AFError?) ->Void) {
        let numParam =  "?number=\(routNum)"
        let urlPath = MAUI_GETBANK_IMAGE_WITHROUTING_NUM_URL + numParam
        
        let request = RequestBuilder(url: urlPath, method: .get,
                                     serviceKey: ServiceKey.mauiGetBankImageRoutNum, jsonParams: nil,
                                     encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
       
        request.validate().responseDecodable(of: [bankImageRoutingNumberModel].self, completionHandler: {
            response in
            switch response.result {
            case let .success(imgValue):
                completionHandler(true, imgValue, nil )
            case  let .failure(failVal):
                completionHandler(false, nil, failVal)
            }
        })
    }
    
    // MARK: - DEVICE REGISTRATION REQUEST
    func performDeviceRegistration(completionHandler:@escaping (_ success:Bool, _ error: AFError?) -> Void) {
        self.deviceRegistrationRequest(REGISTER_DEVICE_URL_PATH) { success, response, error in
            switch success {
            case true:
                if let responseData = response, let deviceId = responseData.id as String?, !deviceId.isEmpty {
                    LoginPreferenceManager.sharedInstance.setRegisteredDeviceIDToPreference(response)
                }
                completionHandler(true, nil)
                
            case false:
                completionHandler(false, nil)
            }
        }
    }
    
    func performLiveTopologyRequest() {
        if MyWifiManager.shared.supressPHCalls { return }
        self.initiateLiveTopologyRequest(){ success, response, error in
            // TO-DO: Save accounts API data for use
        }
    }
    
    func performSSIDInfoRequest() {
        if MyWifiManager.shared.supressPHCalls { return }
        self.initiateSSIDInfoAPIRequest { success, error in
            // TO-DO: Save accounts API data for use
        }
    }
    
    func settingsAPIRequest(_ updateSetNumber: String, completionHandler:@escaping (_ success:Bool, _ response:SettingsAPIResponse?, _ error: AFError?) -> Void) {
        let queue = DispatchQueue(label: "SettingsAPI-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var  param = [String : String]()
        if !updateSetNumber.isEmpty {
            param["whatsnew_last_seen_set"] = updateSetNumber
        }
        let requestObj = RequestBuilder(url: SETTINGS_URL_PATH, method: (!updateSetNumber.isEmpty) ? .put : .get,
                                        serviceKey: ServiceKey.settings, jsonParams: (!updateSetNumber.isEmpty) ? param as [String : AnyObject] : nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        
        requestObj.validate().responseDecodable(of: SettingsAPIResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [200, 204, 205], emptyRequestMethods: [.head]) { (response) in
            if (response.response?.statusCode == 200 || response.response?.statusCode == 204 || response.response?.statusCode == 205) && response.data == nil {
                completionHandler(true, nil, nil)
            } else {
                switch response.result {
                case .failure(let value):
                   Logger.info("Settings API Request failure")
                   completionHandler(false, nil, value)
                case .success(let value):
                    Logger.info("Settings API Request success")
                    completionHandler(true, value, nil)
                }
            }
        }
    }
    
    func deviceRegistrationRequest(_ url: String, completionHandler:@escaping (_ success:Bool, _ response:DeviceRegistrationResponse?, _ error: AFError?) -> Void) {
        let deviceDetails = deviceRegisterParameter()
        let queue = DispatchQueue(label: "DeviceRegistration-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var deviceRegistrationURL = url
        var httpMethod: HTTPMethod = .post
        if let deviceId = DEVICE_TOKEN, !deviceId.isEmpty {
            deviceRegistrationURL += "/id/" + deviceId
            httpMethod = .put
        }
        LoginPreferenceManager.sharedInstance.authTokenFailed = false
        let requestObj = RequestBuilder(url: deviceRegistrationURL, method: httpMethod,
                                        serviceKey: ServiceKey.device, jsonParams: deviceDetails as [String : AnyObject]?,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        
        requestObj.validate().responseDecodable(of: DeviceRegistrationResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            if response.response?.statusCode == 401 {
                Logger.info("Authentication token failure")
                LoginPreferenceManager.sharedInstance.authTokenFailed = true
                completionHandler(false, nil, nil)
                return
            }
            switch response.result {

            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Device Registration success")
                Logger.info("success")
                completionHandler(true, value, nil)

            case .failure(let value):
                Logger.info("Device Registration failure")
                completionHandler(false, nil, value)
            }
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.isSplashShown {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "SplashSSO"), object: true, userInfo: nil)
                    appDelegate.dismissSplashOverlay()
                }
            }
        }
    }

    // MARK: - ACCOUNTS API REQUEST
    func initiateAccountsAPIRequest(completionHandler:@escaping (_ success:Bool, _ response:AccountsAPIResponse?, _ error: AFError?) -> Void) {
        let queue = DispatchQueue(label: "Accounts-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let requestObj = RequestBuilder(url: (ACCOUNTS_API_URL_PATH), method: .get,
                                        serviceKey: ServiceKey.account, jsonParams: nil,
                                        encoding: URLEncoding() as ParameterEncoding ).buildNetworkRequest()

        requestObj.validate().responseDecodable(of: AccountsAPIResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {

            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Accounts API")
                if let code = value.code, !code.isEmpty {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: ACCOUNTS_API_URL_PATH, uiMessage: "", response: response.response, responseData: response.data)
                    completionHandler(false, value, nil)
                } else {
                    Logger.info("Accounts API success")
                    MyWifiManager.shared.saveAccountsAPIResponse(value: value)
                    completionHandler(true, value, nil)
                }
//                if let map = value.map, !map.isEmpty {
//                    MyWifiManager.shared.saveAccountsAPIResponse(value: value)
//                    Logger.info("success")
//                    completionHandler(true, value, nil)
//                } else if let code = value.code, !code.isEmpty {
//                    completionHandler(false, value, nil)
//                } else {
//                    completionHandler(true, value, nil)
//                    return
//                }
            case .failure(let value):
                Logger.info("Accounts API failure")
                if let data = response.data {
                    do {
                        let val = try JSONDecoder().decode(AccountsAPIResponse.self, from: data)
                        completionHandler(false, val, nil)
                    } catch {
                        Logger.info("Accounts API Request error - \(error.localizedDescription)")
                        completionHandler(false, nil, value)
                    }
                } else {
                    completionHandler(false, nil, value)
                }
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: ACCOUNTS_API_URL_PATH, uiMessage: "We are experiencing technical difficulties, and cannot access your account at this time.  Please check back later.", response: response.response, responseData: response.data)
            }
        }
    }
    
    
    func getProActiveSignalAPIRequest(_ queryString: String, completionHandler:@escaping (_ success:Bool, _ response:SignalQuality?, _ error: Error?) -> Void) {
        
        SDKClient.sharedClient.getSignalQuality { signalModel, apiError in
            if apiError == nil
            {
                completionHandler(true, signalModel, nil)
            }
            else
            {
                completionHandler(false, signalModel, apiError)
            }
        }
    }
    
    func getIdentity(completionResult: @escaping (Bool?, Error?) ->Void ) {
        SDKClient.sharedClient.getIdentityCheck(completionResult: completionResult)
    }
    
    func logoutSession() {
        Logger.info("Local GW API Logout called....")
        SDKClient.sharedClient.logoutSession(completionResult: {
            success,error in
        })
    }

    func initiateSSIDInfoAPIRequest(completionHandler:@escaping (_ success:Bool, _ error: AFError?) -> Void) {

        let queue = DispatchQueue(label: "SSIDInfo-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var ssidURLPath = LIGHTSPEED_GWINFO_API_URL_PATH + (MyWifiManager.shared.deviceMAC ?? "")
        let deviceType = MyWifiManager.shared.deviceType ?? ""
        ssidURLPath += "?sessionid=\(MyWifiManager.shared.sessionID)"
        ssidURLPath += "&pwhide=0&devicetype=\(deviceType)&staleness=" + (MyWifiManager.shared.stalenessType ?? "-1")
        
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        
        let requestObj = RequestBuilder(url: (ssidURLPath), method: .get,
                                        serviceKey: ServiceKey.ssidInfo, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        requestObj.validate().responseJSON(queue: queue) { (response) in
            
            switch response.result {
                
            case .success(_):
                Logger.info("SSID INFO Request success")
                let data = response.data
                //var jsonDict:NSDictionary?
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        //jsonDict = jsonResult
                        //WifiConfigValues.shared.saveLightSpeedValues(response: jsonDict)
                        let wifiDetails = jsonResult
                        if !wifiDetails.allKeys.isEmpty {
                            if let twoGHome = wifiDetails.value(forKey: "2G Home") as? NSDictionary, twoGHome.allKeys.count > 0 {
                                MyWifiManager.shared.twoGHome = NSMutableDictionary(dictionary: twoGHome)
                                if let networkName = twoGHome.value(forKey: "SSID") as? NSString {
                                    MyWifiManager.shared.networkName = networkName as String
                                }
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateSSID"), object: true, userInfo: nil)
                            }
                            if let fiveGHome = wifiDetails.value(forKey: "5G Home") as? NSDictionary, fiveGHome.allKeys.count > 0 {
                                MyWifiManager.shared.fiveGHome = NSMutableDictionary(dictionary: fiveGHome)
                            }
                        }
                    }
                } catch let error as NSError {
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "MYWifi", body: "", requestURL: ssidURLPath, uiMessage: "", response: response.response, responseData: response.data)
                    Logger.info(error.localizedDescription)
                }
            case .failure(_):
                Logger.info("SSID INFO Request failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "MYWifi", body: "", requestURL: ssidURLPath, uiMessage: "", response: response.response, responseData: response.data)
                if MyWifiManager.shared.stalenessType == "0" {
                    MyWifiManager.shared.stalenessType = "-1"
                    self.performSSIDInfoRequest()
                }
            }
        }
    }
    
//    func initiateDirectSSIDInfoAPIRequest(completionHandler:@escaping (_ success:Bool, _ error: AFError?) -> Void) {
//
//        let queue = DispatchQueue(label: "SSIDInfo-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
//        let ssidURLPath = "http://lightspeed-staging.alticeusa.net:8089/lightspeed/gwaction/gwinfo/D8D77581184A?staleness=" +  (WifiConfigValues.shared.stalenessType ?? "-1") + "&devicetype=onebox&pwhide=0" //LIGHTSPEED_GWINFO_API_URL_PATH + deviceMac
//        let requestObj = RequestBuilder(url: (ssidURLPath), method: .get,
//                                        serviceKey: ServiceKey.ssidInfo, jsonParams: nil,
//                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
//        requestObj.validate().responseJSON(queue: queue) { (response) in
//
//            switch response.result {
//
//            case .success(_):
//                let data = response.data
//                var jsonDict:NSDictionary?
//                do {
//                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
//                        jsonDict = jsonResult
//                        print(jsonDict as Any)
//                        WifiConfigValues.shared.saveLightSpeedValues(response: jsonDict)
//                    }
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            case .failure(_):
//                print("Direct SSID INFO Request failed")
//            }
//        }
//    }
    
    // MARK: - CONFIG API REQUEST
    // This calls initial config API and brand Config API
    func initiateConfigRequest(isBrandRequest:Bool,_ params : [String : AnyObject], completionHandler:@escaping (_ success:Bool, _ response:ConfigResponse?, _ error: AFError?) -> Void) {
        var urlString = CONFIG_API_URL
        var queueName = "Config-API-queue"
        var serviceKey:ServiceKey = .configAPI
        var requestTimeStamp = ""
        if isBrandRequest {
            requestTimeStamp = Date().getDateForErrorLog()
            let brandSpecific = (App.getBrandInfo().uppercased() == OPTIMUM_BRAND) ? CONFIG_UPDATED_TIMESTAMP_OPT : CONFIG_UPDATED_TIMESTAMP_SDL
            if let dateString = PreferenceHandler.getValuesForKey(brandSpecific) as? String {
                urlString += "?aa="
                urlString += dateString
            }
            queueName = "BrandConfig-API-queue"
            serviceKey = .configAPIBrandSpecific
        }
        let queue = DispatchQueue(label: queueName, attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue

        let requestObj = RequestBuilder(url: (urlString), method: .get,
                                        serviceKey: serviceKey, jsonParams: params,
                                        encoding: URLEncoding() as ParameterEncoding ).buildNetworkRequest()
        
        requestObj.validate().responseDecodable(of: ConfigResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {
                
            case .success(let value):
                Logger.info(response.value.debugDescription, sendLog: "Config API response success")
                completionHandler(true, value, nil)
                
            case .failure(let value):
                Logger.info("Config API response failure")
                switch response.response?.statusCode {
                case 403:
                    if let data = response.data {
                        if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String], json["code"] == "0-8" {
                            completionHandler(true, nil, value)
                            return
                        }
                    }
                default:
                    Logger.info("Some other Error")
                    if isBrandRequest {
                        let errorLogger = APIErrorLogger()
                        errorLogger.apiErrorLogginCall(requestTimeStamp:requestTimeStamp, screen: "Login", body: CommonUtility.jsonToString(json: params as AnyObject?), requestURL: urlString, uiMessage: "", response: response.response, responseData: response.data)
                    }
                }
                completionHandler(false, nil, value)
            }
        }
    }
    
    // MARK: - INSTALL Stream Device SET API REQUESTS
    func installStreamDeviceRequest(completionHandler:@escaping (_ success:Bool, _ response:[MapCPEInforResponse]?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "Map-CPEInfo-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var queryString = "?fields=macaddress"
        let serialNumbers = MyWifiManager.shared.unProvisionedSTBs.compactMap(\.device_serial).filter({$0.isEmpty == false})
        let strOfSerialNumbers = serialNumbers.joined(separator: ",")
        queryString += "&sn=\(strOfSerialNumbers)"
        let lightSpeedURL = MAP_CPEINFO_URL_PATH + queryString
        let requestObj = RequestBuilder(url: (lightSpeedURL), method: .get,
                                        serviceKey: ServiceKey.lightSpeed, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        requestObj.responseDecodable(of: [MapCPEInforResponse].self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            switch response.result {

            case .success(let value):
                if let mac = value.first?.macaddress, !mac.isEmpty {
                    MyWifiManager.shared.newProvisionedSTBs = value
                    completionHandler(true,value,nil)
                } else {
                    Logger.info("MAC address not found after stb install")
                    completionHandler(false, nil, nil)
                }
                break
            case .failure(let value):
               Logger.info("******Map-CPEInfo failure******")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Stream Install", body: "", requestURL: lightSpeedURL, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        }
    }

    // MARK: - PROFILE GET/SET/DELETE API REQUESTS
    func performGetProfileRequest(completionHandler:@escaping (_ success:Bool, _ value:[Profile]?, _ error:AFError?)->Void) {
        let queue = DispatchQueue(label: "GetProfiles", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let getProfileURL = GETPROFILE_PATH_URL + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let request = RequestBuilder(url: getProfileURL, method: .get, serviceKey: .getLightspeedProfiles).buildNetworkRequest()
        request.validate().responseDecodable(of: [Profile].self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result{
            case .success(let value):
                Logger.info("Lightspeed Profile Request Succeded:\n" + value.debugDescription, sendLog: "Lightspeed Profile Request Success")
                ProfileManager.shared.profiles = value
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Lightspeed Profile Request Failed:\n" + (value.errorDescription ?? ""))
                ProfileManager.shared.profiles = nil
                ProfileModelHelper.shared.profiles = nil
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: getProfileURL, uiMessage: "Sorry, profiles aren’t available right now.", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        }
    }
    func getAllNodes(completion: @escaping ((Result<[LightspeedNode], Error>) -> Void)) {
        if MyWifiManager.shared.supressPHCalls && !MyWifiManager.shared.isTvStreamAvailable() { return }
        let getAllNodesURL = GETALLNODES_PATH_URL + "?sessionid=\(MyWifiManager.shared.sessionID)"
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let requestObj = RequestBuilder(url: getAllNodesURL, method: .get,
                                        serviceKey: ServiceKey.account, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        // Need to check with team if we can pass in date fromatters in decoder which automatically converts string to date
        requestObj.validate().responseDecodable(of: [LightspeedNode].self, completionHandler: { response in
            switch response.result {
            case let .success(value):
                // Need to check if we need to save value in WifiConfigValues
                DeviceManager.shared.devices = value
                DeviceManager.shared.checkAndUpdateStreamDevices()
                completion(.success(DeviceManager.shared.devices ?? []))
            case let .failure(error):
                DeviceManager.shared.devices = nil
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: getAllNodesURL, uiMessage: "Sorry, we ran into a problem and can’t add devices right now.", response: response.response, responseData: response.data)
                completion(.failure(error))
            }
        })
    }
    //MARK: DeleteHouseHoldProfile API
    func performDeleteProfileRequest(params : [String : AnyObject], completionHandler:@escaping (_ success:Bool, _ value:DeleteProfileResponseModel?, _ error:AFError?)->Void) {
        let queue = DispatchQueue(label: "DeleteProfiles", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let profileURL = SETPROFILE_PATH_URL + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let request = RequestBuilder(url: profileURL, method: .delete, serviceKey: .setProfiles, jsonParams: params, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: DeleteProfileResponseModel.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result{
            case .success(let value):
                Logger.info("Delete Profile Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Delete Profile Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Manage_my_household", body: CommonUtility.jsonToString(json: params as AnyObject?), requestURL: profileURL, uiMessage: "Sorry, we ran into a problem and can't delete this profile right now.", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        }
    }
    
    func setProfile(jsonParams: [String: AnyObject], completionHandler:@escaping (_ success:Bool, _ value:SetProfileResponseModel?, _ error:AFError?)->Void) {
        let queue = DispatchQueue(label: "SetProfile", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let profileURL = SETPROFILE_PATH_URL + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let request = RequestBuilder(url: profileURL, method: .post, serviceKey: .setProfiles, jsonParams: jsonParams, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: SetProfileResponseModel.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { response in
            switch response.result {
            case let .success(value):
                completionHandler(true, value, nil)
            case let .failure(error):
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Manage_my_household", body: CommonUtility.jsonToString(json: jsonParams as AnyObject?), requestURL: profileURL, uiMessage: "Sorry, we ran into a problem.", response: response.response, responseData: response.data)
                completionHandler(false, nil, error)
            }
        }
    }
    
    //MARK: - WPS API REQUEST
        func initiateWPSRequest(completionHandler:@escaping (_ success:Bool, _ response: XtendInstallWPSResponseModel?, _ error: AFError?) -> Void) {

            let queue = DispatchQueue(label: "WPS-API-queue", attributes: DispatchQueue.Attributes.concurrent)
            var requestTimeStamp = ""
            requestTimeStamp = Date().getDateForErrorLog()
            var deviceMac = MyWifiManager.shared.deviceMAC ?? ""
            deviceMac += "?sessionid=\(MyWifiManager.shared.sessionID)"
            deviceMac += "&devicetype=\(MyWifiManager.shared.deviceType ?? "")"
            let lightSpeedWPSURL = LIGHTSPEED_WPS_PATH_URL + deviceMac
            let requestObj = RequestBuilder(url: (lightSpeedWPSURL), method: .get,
                                            serviceKey: ServiceKey.lightSpeed, jsonParams: nil,
                                            encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()

            requestObj.validate().responseDecodable(of: XtendInstallWPSResponseModel.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
                switch response.result
                {
                case .success(let responseModel):
                    Logger.info("WPS request success")
                    completionHandler(true,responseModel, nil)
                case .failure(let error):
                   Logger.info(error.localizedDescription)
                    let errorLogger = APIErrorLogger()
                    errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Extender", body: "", requestURL: lightSpeedWPSURL, uiMessage: "", response: response.response, responseData: response.data)
                    completionHandler(false, nil, error)
                }
            }

        }
    //MARK: - Check Home IP Request
    func checkHomeIP(completionHandler:@escaping (_ success:Bool, _ response: HomeIPCheck?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let queue = DispatchQueue(label: "HomeIP-API-queue", attributes: DispatchQueue.Attributes.concurrent)
        
        let accountIPURL = CHECK_HOMEIP_PATH_URL
        let requestObj = RequestBuilder(url: (accountIPURL), method: .get,
                                        serviceKey: ServiceKey.lightSpeed, jsonParams: nil,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        
        requestObj.validate().responseDecodable(of: HomeIPCheck.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            switch response.result
            {
            case .success(let responseModel):
                completionHandler(true,responseModel, nil)
            case .failure(let error):
                Logger.warning("In Home IP Check Failure with \(error)")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Extender", body: "", requestURL: accountIPURL, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, error)
            }
        }
        
    }
    
    //MARK: - Metrics API
    
    func logMetrics(params : [String : AnyObject], completionHandler:@escaping (_ success:Bool, _ error: AFError?) -> Void) {
        
        let queue = DispatchQueue(label: "Metric-API-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        let urlPath = METRICS_URL_PATH
        //        var requestTimeStamp = ""
        //        requestTimeStamp = Date().getDateForErrorLog()
        let requestObj = RequestBuilder(url: (urlPath), method: .post,
                                        serviceKey: ServiceKey.metricAPI, jsonParams: params,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        requestObj.validate().responseJSON(queue: queue) { (response) in
            Logger.info("Status code \(String(describing: response.response?.statusCode)) for - APIRequests.logMetrics(params:\(params) ")
        }
    }
}

// MARK: - Helper Methods
extension APIRequests {
    fileprivate func deviceRegisterParameter() -> [String : String] {
        
        var  param = [String : String]()

//        if let userName = PreferenceHandler.getValuesForKey("username") as? String, !userName.isEmpty {
//            param["username"] = userName
//        }
        param["app_version"] = App.versionNumber()
        param["os_version"] = MYDEVICE.systemVersion
        //        param["platform"] = MYDEVICE.systemName
        param["platform"] = DEVICE_PLATFORM
        param["device_name"] = MYDEVICE.name
        param["device_type"] = MYDEVICE.model
        param["device_type_info"] = App.getDeviceTypeInfo()
        
        //Adding device id key/value if second level device id info update purpose. For inital device registration avoiding device id parameter.
        
//        if DEVICE_TOKEN == nil || DEVICE_TOKEN == "" {
//
//            /*LBM-1683 : Persisting device token not required*/
//            DEVICE_TOKEN = PreferenceHandler.getValuesForKey("deviceId") as? String
//        }
        
//        let deviceId :String! = DEVICE_TOKEN
//
//        if deviceId != nil {
//
//            param["deviceId"] = deviceId
//        }
        
        return param
    }
}
//String extension to create HEX encoded string using HMAC SHA-256 encryption
extension String {
    func hmac(key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = UInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = CC_SHA256_DIGEST_LENGTH
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(digestLength))
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = UInt(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyStr!, Int(keyLen), str!, Int(strLen), result)
        
        let hash = NSMutableString()
        for iLength in 0..<digestLength {
            hash.appendFormat("%02x", result[Int(iLength)])
        }
        
        result.deinitialize(count:1)
        
        return String(hash)
    }
}
