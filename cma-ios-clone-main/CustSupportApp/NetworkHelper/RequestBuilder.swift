//
//  RequestBuilder.swift
//  CustSupportApp
//
//  Created by Namarta on 18/05/22.
//

import Foundation
import Alamofire

/** This class is built as a wrapper class over the Alamofire Library to
    use it as required by the developer.
 */
open class RequestBuilder
{
    fileprivate var url : String
    fileprivate var method : Alamofire.HTTPMethod
    fileprivate var headers : HTTPHeaders?
    fileprivate var encoding : Alamofire.ParameterEncoding?
    fileprivate var jsonParams: [String: AnyObject]?
    fileprivate var data: Data?
    fileprivate var serviceKey:ServiceKey?
    
    fileprivate let authHeaderAuthorization = "Authorization"
    fileprivate let deviceTokenHeader = "x-device-id"
    fileprivate let homeBasedAuthentication = "x-use-hba"
    fileprivate let authHeaderMAUI = "X-Maui-Token"
    fileprivate let deviceMac = "X-GW-MAC"
    fileprivate let authorizationHmac = "x-authorization-hmac"
    fileprivate let authorizationTime = "x-authorization-time"
    fileprivate let firebaseAppCheckToken = "x-firebase-appcheck"
    
    /// This is the init request without query params and encoding as the parameters
    init(url : String, method : Alamofire.HTTPMethod, serviceKey:ServiceKey)
    {
        self.url = url
        self.method = method
        self.headers = self.getRequestHeaders(serviceKey)
        self.encoding = URLEncoding() as ParameterEncoding
        self.serviceKey = serviceKey
        
    }
    
    /// This the initializer method for building up the requests' essentials
    ///
    /// - parameter url:         The URL
    /// - parameter method:      Type of method
    /// - parameter serviceType: ServiceKey
    /// - parameter jsonParams:  JSON parameters
    /// - parameter encoding:    Type of Encoding
    ///
    /// - returns: Retuns void
    init(url : String, method : Alamofire.HTTPMethod, serviceKey:ServiceKey, jsonParams : [String :AnyObject]?, encoding : Alamofire.ParameterEncoding)
    {
        self.url = url
        self.method = method
        self.jsonParams = jsonParams
        self.headers = self.getRequestHeaders(serviceKey)
        self.encoding = encoding
        self.serviceKey = serviceKey
    }
    
    /// This will build the request and add the prepare the query/json params as per the
    /// requirement
    /// - returns: Returns a well prepared request with http body.
    func buildNetworkRequest() -> Alamofire.DataRequest
    {
///**TODO- Add call encryption methods**
      /*  if let userName = PreferenceHandler.getValuesForKey("username") as? String, self.url.range(of: userName) != nil {
            let obfuscatedUserName = CCEncryptUtility.encryptedUserID.isEmpty ? CCEncryptUtility.aesEncrypt(userName, isUserID: true) : CCEncryptUtility.encryptedUserID
            let stringToLog = self.url.replacingOccurrences(of: userName, with: obfuscatedUserName)
            Logger.sharedInstance.dLog(stringToLog)
        } else {
            Logger.sharedInstance.dLog(self.url)
        }*/
        
        let request = NETWORK_MANAGER.default.request((self.url as URLConvertible), method: self.method, parameters: self.jsonParams, encoding: self.encoding!, headers: self.headers)
#if !DEBUG
        if !isProxyDisabledForProd(url) {
            request.cancel()
        }
#endif

        return request
    }
    
    func buildNetworkRequestWithInterceptor(interceptor: RequestInterceptor? = nil) -> Alamofire.DataRequest
    {
        ///**TODO- Add call encryption methods**
        /*  if let userName = PreferenceHandler.getValuesForKey("username") as? String, self.url.range(of: userName) != nil {
         let obfuscatedUserName = CCEncryptUtility.encryptedUserID.isEmpty ? CCEncryptUtility.aesEncrypt(userName, isUserID: true) : CCEncryptUtility.encryptedUserID
         let stringToLog = self.url.replacingOccurrences(of: userName, with: obfuscatedUserName)
         Logger.sharedInstance.dLog(stringToLog)
         } else {
         Logger.sharedInstance.dLog(self.url)
         }*/
        
        //        let request = NETWORK_MANAGER.default.request((self.url as URLConvertible), method: self.method, parameters: self.jsonParams, encoding: self.encoding!, headers: self.headers)
        //        return request
        //
        let request = NETWORK_MANAGER.default.request((self.url as URLConvertible), method: self.method, parameters: self.jsonParams, encoding: self.encoding!, headers: self.headers, interceptor: interceptor)
#if !DEBUG
        if !isProxyDisabledForProd(url) {
            request.cancel()
        }
#endif
        return request
    }
    
    func buildDownloadRequest(interceptor: RequestInterceptor? = nil, destination: @escaping DownloadRequest.Destination) -> Alamofire.DownloadRequest {
        let request = NETWORK_MANAGER.default.download((self.url as URLConvertible), method: self.method, parameters: self.jsonParams, encoding: self.encoding!, headers: self.headers, interceptor: interceptor, to: destination)
        
        return request
    }
    
    // MARK: - RequestHeader method
    
    /// Get request header from User Defaults
    ///
    /// - parameter serviceKey:             seevice key that needs to pass with the method to get appropriate request header.
    ///
    /// - returns: request headers as a String dictionary
    final func getRequestHeaders(_ serviceKey:ServiceKey) -> HTTPHeaders {
        
        var requestHeaders = HTTPHeaders()
        
        switch serviceKey {
        case .metricAPI:
            print("")
//            requestHeaders = getDeviceParameters(true, isBrandNameNeeded: false)
//            requestHeaders[authHeaderAuthorization] = AUTHHEADER_AUTHORIZATION
            requestHeaders = self.getDeviceToken(requestHeaders)
            requestHeaders = self.getAccessToken(requestHeaders)
           // requestHeaders["Accept"] = "application/json"
            
        case .configAPI:
            requestHeaders = getDeviceParameters(true, isBrandNameNeeded: false)
            requestHeaders[authHeaderAuthorization] = AUTHHEADER_AUTHORIZATION
            
        case .login, .mauiToken:
            requestHeaders = getDeviceParameters(true, isBrandNameNeeded: false)
            requestHeaders[authorizationHmac] = APIRequests.shared.hmacValue
            requestHeaders[authorizationTime] = Date().getDateCurrentDateHmac()
            requestHeaders[authHeaderAuthorization] = AUTHHEADER_AUTHORIZATION
            requestHeaders[self.firebaseAppCheckToken] = AppCheckTokenManager.shared.token

        case .logout, .device, .lightSpeed, .ssidInfo, .operationalStatus, .reboot, .account, .setWlanInfo, .getLightspeedProfiles, .setProfiles, .speedTest, .postNode, .clientUsage, .accessProfile, .deadZone, .errorLogging, .settings:
            requestHeaders = self.getDeviceToken(requestHeaders)
            requestHeaders = self.getAccessToken(requestHeaders)
//            requestHeaders = self.getMAUIToken(requestHeaders)
            requestHeaders["Accept"] = "application/json"
            
        case .lightSpeedRouter:
            requestHeaders = self.getDeviceToken(requestHeaders)
            requestHeaders = self.getAccessToken(requestHeaders)
//            requestHeaders = self.getMAUIToken(requestHeaders)
            if MyWifiManager.shared.getWifiType() == "Modem" {
                requestHeaders = self.getMacAddress(requestHeaders)
            }
            requestHeaders["Accept"] = "application/json"
            
//        case .account:
//               requestHeaders = self.getAccessToken(requestHeaders)
//               requestHeaders = self.getDeviceToken(requestHeaders)
//               requestHeaders["Accept"] = "application/json"
            
//        case .setWlanInfo, .getLightspeedProfiles, .setProfiles, .speedTest:
//            requestHeaders = self.getAccessToken(requestHeaders)
//            requestHeaders = self.getDeviceToken(requestHeaders)
            
        case .configAPIBrandSpecific:
            requestHeaders = getDeviceParameters(true, isBrandNameNeeded: true)
            requestHeaders[authHeaderAuthorization] = AUTHHEADER_AUTHORIZATION
//        case .postNode:
//            requestHeaders = self.getAccessToken(requestHeaders)
//            requestHeaders = self.getDeviceToken(requestHeaders)
        case .deviceIcons:
            requestHeaders = self.getAccessToken(requestHeaders)
            requestHeaders = self.getDeviceToken(requestHeaders)
            requestHeaders["Accept"] = "application/zip, application/octet-stream"
            
        case .mauiAccounts, .mauiPayMethods, .mauiListBills, .mauiGetBill, .mauiGetAccountBill, .mauiBillAccountActivity, .mauiNextPaymentDue, .mauiBillPreferences, .mauiUpdateBillPreferences, .mauiCreatePayment, .mauiSetDefaultPayMethod, .mauiGetAutoPay, .mauiAccountRestriction, .mauiImmediatePayment, .mauiOutageAlert, .mauiCreateAutoPay, .mauiCreateOneTimePayment, .mauiListPayment, .mauiConsolidatedDetails, .mauiCustomer, .mauiGetBankImageRoutNum, .mauiSpotLightCards, .mauiUpdateSpotlightCards, .mauiDeleteMOP:
            requestHeaders = self.getDeviceToken(requestHeaders)
            requestHeaders = self.getAccessToken(requestHeaders)
            requestHeaders = self.getMAUIToken(requestHeaders)
            if serviceKey == .mauiUpdateSpotlightCards {
                requestHeaders["Accept"] = "application/json"
            }
            
        case .mauiPdfDownload:
            requestHeaders = self.getDeviceToken(requestHeaders)
            requestHeaders = self.getAccessToken(requestHeaders)
            requestHeaders = self.getMAUIToken(requestHeaders)
//            requestHeaders["Content-Type"] = "application/pdf"
            requestHeaders["Accept"] = "application/pdf, application/octet-stream, application/json"
        }
        
        return requestHeaders
    }
    
    /// - returns: dictionary of device info parameters.
    func getDeviceParameters(_ isDeviceNameNeeded: Bool, isBrandNameNeeded : Bool) -> HTTPHeaders {
        
        var  httpHeader = HTTPHeaders()
        
        //    param["platform"] = MYDEVICE.systemName
        httpHeader.add(name: "x-device-os-version", value: MYDEVICE.systemVersion)
        httpHeader.add(name: "x-device-app-version", value: App.versionNumber())
        httpHeader.add(name: "x-device-type", value: MYDEVICE.model)
        httpHeader.add(name: "x-device-platform", value: DEVICE_PLATFORM)
        if isDeviceNameNeeded {
            httpHeader.add(name: "x-device-name", value: MYDEVICE.name)
        }
        return httpHeader
    }
    
    /// Fetch access token from User Defaults
    ///
    /// - parameter headers:             request headers that needs to pass with the method.
    ///
    /// - returns: request headers with access token appedned with the exciting request header as a String dictionary
    
    func getAccessToken(_ headers : HTTPHeaders) -> HTTPHeaders {
        ///**TODO - fetch accesstoken from Login**
                var requestHeaders = headers
        //
        if  let loginData = PreferenceHandler.getValuesForKey("loginAuthenticationData") as? [String : AnyObject], let accessToken = loginData["access_token"] {
            requestHeaders.add(name: authHeaderAuthorization, value: "Bearer \(accessToken)")
        }
        //        else {
        //            if let accessToken = PreferenceHandler.getValuesForKey("AccessToken") {
        //                requestHeaders.add(name: authHeaderAuthorization, value: "Bearer \(accessToken)")
        //            }
        //        }
        return requestHeaders
    }
    
    /// Fetch device token from User Defaults
    ///
    /// - parameter headers:             request headers that needs to pass with the method.
    ///
    /// - returns: request headers with access token appedned with the exciting request header as a String dictionary
    func getDeviceToken(_ headers : HTTPHeaders) -> HTTPHeaders {

        var requestHeaders = headers

        // Device token to the request header
        let deviceId : String! = DEVICE_TOKEN//PreferenceHandler.getValuesForKey("deviceId")
        //let deviceId  = PreferenceHandler.getValuesForKey("deviceId")
        // Commented since we get device id from keychain

        if deviceId != nil {

            requestHeaders.add(name: deviceTokenHeader, value: deviceId)
        }

        return requestHeaders
    }
    
    /// Fetch Mac Address
    func getMacAddress(_ headers : HTTPHeaders) -> HTTPHeaders {
        var requestHeaders = headers
        if let macAddress = MyWifiManager.shared.deviceMAC, !macAddress.isEmpty {
            requestHeaders.add(name: deviceMac, value: macAddress)
        }
        return requestHeaders
    }
    
    /// Fetch MAUI token from User Defaults
    ///
    /// - parameter headers:             request headers that needs to pass with the method.
    ///
    /// - returns: request headers with access token appedned with the exciting request header as a String dictionary
    func getMAUIToken(_ headers : HTTPHeaders) -> HTTPHeaders {
        var requestHeaders = headers
        if  let MAUIToken = LoginPreferenceManager.sharedInstance.getMauiToken(), !MAUIToken.isEmpty {
            requestHeaders.add(name: authHeaderMAUI, value: MAUIToken)
        }
        return requestHeaders
    }
    
    /// Cancelling requests 
    class func cancelAllRequests() {
        NETWORK_MANAGER.default.session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                $0.cancel()
            }
            uploadTasks.forEach {
                $0.cancel()
            }
            downloadTasks.forEach {
                $0.cancel()
            }
        })
    }
    
    func getNetworkProxySettings() -> CFDictionary? {
        guard let proxiesSettings = CFNetworkCopySystemProxySettings() else {
            return nil
        }
        return proxiesSettings.takeRetainedValue()
    }
    
    func getProxiesForURL(_ url: URL, _ proxiesSettings: CFDictionary) -> [[String:AnyObject]] {
        let proxiesRoot = CFNetworkCopyProxiesForURL(url as CFURL, proxiesSettings)
        let proxies = proxiesRoot.takeRetainedValue()
        return proxies as? [[String:AnyObject]] ?? []
    }
    
    func isProxyDisabledForProd(_ url: String) -> Bool {
        if let currentUrl = URL(string: url), let bundleID = Bundle.main.bundleIdentifier?.lowercased(), bundleID.contains("prod") || bundleID.compare("com.optimum.cma") == .orderedSame {
            if let proxySettings = getNetworkProxySettings() {
                let proxies = getProxiesForURL(currentUrl, proxySettings)
                print(proxies)
                if let value = proxies.first?["kCFProxyTypeKey"], value as? String != "kCFProxyTypeNone" {
                    return false
                }
            }
        }
        return true
    }
}
