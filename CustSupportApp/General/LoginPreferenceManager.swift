//
//  LoginPreferenceManager.swift
//  CustSupportApp
//
//  Created by Namarta on 26/05/22.
//

import Foundation
import FirebaseCrashlytics

open class LoginPreferenceManager {
  
    static let sharedInstance = LoginPreferenceManager()
    var manualSignInActive :Bool = false
    var metricsInfo: (startTime:Date, bgInterruption:Bool) = (Date.now, false)
    var autoLoginFlow: Bool = false
    var authTokenFailed: Bool = false
    
    func setRegisteredDeviceIDToPreference(_ deviceRegistration : DeviceRegistrationResponse?) {
        setCrashlyticsIDKeys()
        do {
            if let deviceID = deviceRegistration?.id, !deviceID.isEmpty {
                saveDeviceID(deviceID)
                DEVICE_TOKEN = deviceID
            } else {
                Logger.info("SetRegisteredDeviceId JSON ResponseData Failed")
            }
        }
    }
  
    func setLoginAuthenticationDataToPreference(_ response:[String : Any]!, user : String!) {
        
        //Store login authenticaton response to userdefault
        PreferenceHandler.saveValue(response!, forKey: "loginAuthenticationData")
        PreferenceHandler.saveValue(user.lowercased(), forKey: "username")
    }
    
    func getLoggedInUsername() -> String {
        if let user = PreferenceHandler.getValuesForKey("username") as? String, !user.isEmpty {
            return user
        }
        return ""
    }
    
    func removeLoginPreferences() {
        PreferenceHandler.removeDataForKey("loginAuthenticationData")
        PreferenceHandler.removeDataForKey("username")
        PreferenceHandler.removeDataForKey("MAUI_Token")
        PreferenceHandler.removeDataForKey("MAUI_EOID")
        LoginPreferenceManager.sharedInstance.manualSignInActive = false
        LoginPreferenceManager.sharedInstance.autoLoginFlow = false
        self.metricsInfo.bgInterruption = false
    }
    
    func setMauiTokenToPreference(token: String) {
        PreferenceHandler.saveValue(token, forKey: "MAUI_Token")
    }
    
    func setMauiEOIDToPreference(eoid: String) {
        PreferenceHandler.saveValue(eoid, forKey: "MAUI_EOID")
    }
    
    func getMauiToken() -> String? {
        guard let token = PreferenceHandler.getValuesForKey("MAUI_Token") as? String, !token.isEmpty else {
            return ""
        }
        return token
    }
    func getMauiEOID() -> String? {
        guard let eoid = PreferenceHandler.getValuesForKey("MAUI_EOID") as? String, !eoid.isEmpty else {
            return ""
        }
        return eoid
    }
    
    func getEncryptedUserID() -> String{
        let encryptUtility = CCEncryptUtility()
        return encryptUtility.aesEncryptOnly(getLoggedInUsername())
    }
    
    func setCrashlyticsIDKeys() {
        let encryptUserID = getEncryptedUserID()
        Crashlytics.crashlytics().setUserID(encryptUserID)
        Crashlytics.crashlytics().setCustomValue(encryptUserID, forKey: "User ID")
        CMAAnalyticsManager.sharedInstance.setUserIDForAnalytics(encryptUserID)
        Logger.info("The ID is set in crashlytics & GA...")
    }
    func saveDeviceID(_ deviceID: String) {
        storeDeviceTokenInKeychain(deviceID: deviceID)
        Crashlytics.crashlytics().setCustomValue(deviceID, forKey: "User Device ID")
        Logger.info("DeviceId added to Keychain and Crashlytics ")
    }
    func storeDeviceTokenInKeychain(deviceID: String) {
        do {
            if let currentDeviceToken = DEVICE_TOKEN {
                if currentDeviceToken != deviceID {
                    try KeychainWrapper.store(forKey: "deviceId", deviceID)
                }
            }
            else {
                try KeychainWrapper.store(forKey: "deviceId", deviceID)
                DEVICE_TOKEN = deviceID
            }
            PreferenceHandler.saveValue(deviceID, forKey: "deviceId")
        } catch {
            Logger.info("Keychain Write Error")
        }
    }
    
    //Capture login time
    func setInitialLoginTime() {
        PreferenceHandler.saveValue(Date(), forKey: "loginTime")
    }

    // MARK: - Log Metrics for Login APIs (CMAIOS-1948)
    func saveStartLoginTime() {
        self.metricsInfo = (Date.now, false)
    }
    
    func calculateLoginDuration() -> Double {
        let seconds = Date.now.timeIntervalSince(self.metricsInfo.startTime)
        return seconds.rounded() * 1000 //Converted to milliseconds
    }

    func callLogMetrics(duration: Double, label: String) {
        let metricParams = ["label" : label as AnyObject, "milliseconds" : duration as AnyObject]
        APIRequests.shared.logMetrics(params: metricParams) { _, _ in
            Logger.info("Metrics Log request completed")
            //Reset Metrics after the API is completed
            self.metricsInfo.bgInterruption = false
        }
    }
    
  /*func saveLoggedInDeviceInfo(_ deviceDetails : [String : Any]) {
      
      let deviceId :String!  = DEVICE_TOKEN
      //PreferenceHandler.getValuesForKey("deviceId")
      // Commented since we get device id from keychain
      
      if deviceId != nil {
          
          PreferenceHandler.saveValue(deviceDetails, forKey: deviceId!  )

          if let userName = PreferenceHandler.getValuesForKey("username") as? String, deviceDetails.description.range(of: userName) != nil {
              let obfuscatedUserName = CCEncryptUtility.encryptedUserID.isEmpty ? CCEncryptUtility.aesEncrypt(userName, isUserID: true) : CCEncryptUtility.encryptedUserID
              let stringToLog = deviceDetails.description.replacingOccurrences(of: userName, with: obfuscatedUserName)
              Logger.sharedInstance.dLog("Logged In Device details: \(stringToLog))")
          } else {
              Logger.sharedInstance.dLog("Logged In Device details: \(deviceDetails))")
          }
          
      } else {
          
          return
      }
  }
  
  
  
  func isDeviceTokenRequired() -> Bool {
      Logger.sharedInstance.dLog("")
      if DEVICE_TOKEN == nil
      {
          /*LBM-1683 : Persisting device token not required*/
          //DEVICE_TOKEN = app.getDeviceTokenFromKeyChain()

          DEVICE_TOKEN = PreferenceHandler.getValuesForKey("deviceId") as? String
          
      }
      
      let deviceID:String! = DEVICE_TOKEN
      
      if  deviceID != nil
      {
          
          if let loggedInDeviceInfo = PreferenceHandler.getValuesForKey(deviceID!) as? [String:AnyObject] {
              
              for (key, value) in loggedInDeviceInfo {
                  
                  switch key {
                      
                  case "osVersion":
                      
                      if value as? String != MYDEVICE.systemVersion {
                          
                          return true
                      }
                  case "deviceName":
                      
                      if value as? String != MYDEVICE.name {
                          
                          return true
                      }
                  case "appVersion":
                      
                      if value as? String != App.versionNumber() {
                          
                          return true
                      }
                  case "username":
                      
                      if let currentUser = PreferenceHandler.getValuesForKey("username") as? String {
                          
                          if (value as? String)!.lowercased() != currentUser.lowercased(){
                              
                              return true
                          }
                      }
                  default:
                      break
                  }
              }
              
              Logger.sharedInstance.dLog("Device Id : \(deviceID!)")
              Logger.sharedInstance.dLog("Logged In Device details: \(deviceID ?? "")")
              
              return false
          }
      } else {
          
          self.isInitialDeviceRegistration = true
      }
      return true
  }
  
  func setDeviceTokenToKeychain(_ responseData : Data?)
  {
      
      do {
          let jsonDict = try JSON(data: responseData!).dictionaryObject
          if jsonDict != nil {
              if  let deviceID = jsonDict!["id"]
              {
                  let existingDeviceToken :String! = DEVICE_TOKEN
                  
                  if existingDeviceToken != nil
                  {
                      if existingDeviceToken != deviceID as? String
                      {
                          if KeychainWrapper.defaultKeychainWrapper().setString((deviceID as? String)!, forKey: "deviceId" )
                          {
                              Logger.sharedInstance.dLog("Saved successfuly")
                          } else {
                              Logger.sharedInstance.dLog("Failed to save")
                          }
                      }
                  } else
                  {
                      _ = KeychainWrapper.defaultKeychainWrapper().setString((deviceID as? String)!, forKey: "deviceId" )
                      DEVICE_TOKEN = deviceID as? String
                  }
                  PreferenceHandler.saveValue(deviceID, forKey: "deviceId")
              }
          }
      } catch let error {
          Crashlytics.crashlytics().record(error:error)
          Logger.sharedInstance.dLog("SetDeviceToken JSON ResponseData Failed")
          return
      }
  }*/
  
}

