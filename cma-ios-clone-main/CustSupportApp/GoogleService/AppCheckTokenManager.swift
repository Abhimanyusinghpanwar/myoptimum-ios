//
//  AppCheckTokenManager.swift
//  CustSupportApp
//
//  Created by Vishnu on 11/22/24.
//
import UIKit
import Firebase

class AppCheckTokenManager {
    static let shared = AppCheckTokenManager()
    
    private init() {}
    
    private var maxRetries = 1
    private var retryCount = 0
    var token: String?
    var userName: String?
    
    /// To fetch app check token.
    func fetchFirebaseTokenAppCheck(forceRefresh: Bool = false, completion: @escaping (String?, Error?) -> Void) {
        AppCheck.appCheck().token(forcingRefresh: forceRefresh) {
            token, error in
            if let error = error {
                self.logAppCheckErrors(error, message: "Error! fetching App Check token")
                if self.retryCount < self.maxRetries {
                    self.retryCount += 1
                    Logger.info("Retry app check with force refresh")
                    self.fetchFirebaseTokenAppCheck(forceRefresh: true, completion: completion)
                    return
                }
                self.retryCount = 0
                completion(nil, error)
                return
            } else if let appCheckToken = token {
//                self.logAppCheckErrors(message: "App check token received successfully: \(appCheckToken.token)")
                self.token = appCheckToken.token
                completion(appCheckToken.token, nil)
            } else {
                let error = NSError(domain: "AppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey:"Failed to fetch the App Check token"])
                self.logAppCheckErrors(error, message: "No App Check token received!")
                self.retryCount = 0
                completion(nil,error)
            }
        }
    }
    
    /// To log erros and info messages to crashlytics.
    private func logAppCheckErrors(_ error: Error? = nil, message: String) {
        let encryptedUsername = self.getEncryptedUserID(str: self.userName ?? "")
        if let error = error {
            Crashlytics.crashlytics().record(error: error, userInfo: [encryptedUsername:"User"])
            Crashlytics.crashlytics().log(message)
            Logger.warning("\(message): \(error.localizedDescription)")
        } else {
            Crashlytics.crashlytics().log("Info: \(message)")
            Logger.info("Info: \(message)")
        }
    }
    
    private func getEncryptedUserID(str: String) -> String{
        let encryptUtility = CCEncryptUtility()
        return encryptUtility.aesEncryptOnly(str)
    }

    func clearTokens() {
        token = nil
        userName = nil
        print("token has been cleared")
    }
}
