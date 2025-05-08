//
//  AppRatingManager.swift
//  CustSupportApp
//
//  Created by Namarta on 12/10/23.
//

import Foundation
import StoreKit
class AppRatingManager {
    var inAppReviewPromptDisabled = false
    var isAppRatingTriggeredd = false // For current session
    
    class var shared: AppRatingManager {
        struct Singleton {
            static let instance = AppRatingManager()
        }
        return Singleton.instance
    }

    // MARK: - Initial Configuration
    func processInAppReviewDisplayRules() {
        ///**Initial Rules to configure App Review Rating Prompt**
        ///**Rule1:** Check if it is enabled from middleware. Return if NO
        if ConfigService.shared.app_rating_enabled != "true" {
            self.inAppReviewPromptDisabled = true
            return
        }
        
        ///**Rule 2:** Check If review prompt is already displayed and daysBetweenPrompt limit is not crossed. Return if both returns true.
        if let versionStr = self.getSavedVersion(), !versionStr.isEmpty {
            if versionStr == App.shortVersionNumber() {
                //check 120 days limit
                let lastSavedTimeStamp = self.getFirstQualifyingTimestamp()
                //Check if current data is greater than the last saved
                if Date().compare(lastSavedTimeStamp) == .orderedDescending {
                    if !self.daysBetweenPromptIsCrossed(lastSavedTimeStamp) {
                        self.inAppReviewPromptDisabled = true
                        return
                    } else {
                        self.reset() ///Reset when 120 days limit is over
                    }
                }
            } else {
                self.reset() ///Reset when app version is changed
            }
        }
    }
    
    // MARK: - Update values
    func checkQualifyingExperience() {
        if !inAppReviewPromptDisabled {
            let savedAppEntryCount = self.getSavedAppEntryCount()
            if savedAppEntryCount >= 6 {
                self.showInAppPrompt(triggeredFor: .appEntry)
            } else if self.getSavedQuickPayCount() >= 3 {
                self.showInAppPrompt(triggeredFor: .quickPay)
            }
            
        }
    }
    
    // MARK: - Display Rating prompt
    func showInAppPrompt(triggeredFor: QualifyingExpType) {
        Logger.info("showInAppPrompt")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                self.isAppRatingTriggeredd = true // for current app session
                self.saveFirstQualifyingTimestamp()
            }
        }
        self.saveInAppPromptShownSuccess()
    }
    
    // MARK: - Current version
    /// This is saved only when the app prompt is displayed
    fileprivate func saveCurrentVersion() {
        Logger.info("saveCurrentVersion")
        PreferenceHandler.saveValue(App.shortVersionNumber(), forKey: InAppReviewConstants.lastVersionPromptedForReviewKey_UserDef)
    }
    
    // If saved version is available, the app review prompt has already prompted this version
    fileprivate func getSavedVersion() -> String? {
        if let versionStr = PreferenceHandler.getValuesForKey(InAppReviewConstants.lastVersionPromptedForReviewKey_UserDef) as? String, !versionStr.isEmpty {
            return versionStr
        }
        return nil
    }
    
    fileprivate func clearSavedVersion() {
        Logger.info("clearSavedVersion")
        PreferenceHandler.removeDataForKey(InAppReviewConstants.lastVersionPromptedForReviewKey_UserDef)
    }
    
    // MARK: - First qualifying Timestamp
    fileprivate func saveFirstQualifyingTimestamp() {
        Logger.info("saveFirstQualifyingTimestamp")
        PreferenceHandler.saveValue(Date(), forKey: InAppReviewConstants.firstQualifyingTimestamp_UserDef)
    }
    
    fileprivate func clearFirstQualifyingTimestamp() {
        Logger.info("clearFirstQualifyingTimestamp")
        PreferenceHandler.removeDataForKey(InAppReviewConstants.firstQualifyingTimestamp_UserDef)
    }
    
    fileprivate func getFirstQualifyingTimestamp() -> Date {
        if let date = PreferenceHandler.getValuesForKey(InAppReviewConstants.firstQualifyingTimestamp_UserDef) as? Date {
                return date
        } else {
            return Date()
        }
    }
    
    fileprivate func daysBetweenPromptIsCrossed(_ savedDate:Date) -> Bool {
        let daysBetweenPrompts = ConfigService.shared.app_rating_window_days
        let days = Int(daysBetweenPrompts) ?? 120
        let differenceInSeconds = Date().timeIntervalSince(savedDate)
        if differenceInSeconds < Double(days) * 86400 {
            return false
        }
        return true
    }
    
    fileprivate func saveInAppPromptShownSuccess() {
        Logger.info("saveInAppPromptShownSuccess")
        self.saveCurrentVersion()
        self.inAppReviewPromptDisabled = true
    }
    
    // MARK: - Reset
    func reset() {
        Logger.info("reset values for app rating")
        self.clearSavedVersion()
        self.clearFirstQualifyingTimestamp()
        self.inAppReviewPromptDisabled = false
        self.resetQuickPayCount()
        self.resetAppEntryCount()
    }
}

// MARK: - TRACKING FOR APP RATING RULES

extension AppRatingManager {
    func trackAppEntryCount() {
        if self.inAppReviewPromptDisabled {
            return
        }
        Logger.info("trackAppEntryCount")
        var appEntryCount = getSavedAppEntryCount()
        appEntryCount = appEntryCount + 1
        PreferenceHandler.saveValue(appEntryCount, forKey: InAppReviewConstants.appEntryCount_UserDef)
        self.checkQualifyingExperience()
    }
    
    func getSavedAppEntryCount() -> Int {
        if let count = PreferenceHandler.getValuesForKey(InAppReviewConstants.appEntryCount_UserDef) as? Int {
                return count
        } else {
            return 0
        }
    }
    
    func getSavedQuickPayCount() -> Int {
        if let count = PreferenceHandler.getValuesForKey(InAppReviewConstants.quickPaySuccessCount_UserDef) as? Int {
                return count
        } else {
            return 0
        }
    }
    
    func trackConsecutiveQuickPaySuccess() {
        if self.inAppReviewPromptDisabled {
            return
        }
        Logger.info("trackConsecutiveQuickPaySuccess")
        var quickPaySuccessCount = getSavedQuickPayCount()
        quickPaySuccessCount = quickPaySuccessCount + 1
        PreferenceHandler.saveValue(quickPaySuccessCount, forKey: InAppReviewConstants.quickPaySuccessCount_UserDef)
        self.checkQualifyingExperience()
    }
    
    func resetQuickPayCount() {
        PreferenceHandler.saveValue(0, forKey: InAppReviewConstants.quickPaySuccessCount_UserDef)
    }
    func resetAppEntryCount() {
        PreferenceHandler.saveValue(0, forKey: InAppReviewConstants.appEntryCount_UserDef)
    }
    
    func trackEventTriggeredFor(qualifyingExpType: QualifyingExpType) {
        if self.inAppReviewPromptDisabled {
            return
        }
        Logger.info("trackEventTriggeredFor")
        if qualifyingExpType == .selfInstall {
            self.showInAppPrompt(triggeredFor: .selfInstall)
        } else if qualifyingExpType == .troubleshooting {
            self.showInAppPrompt(triggeredFor: .troubleshooting)
        } else if qualifyingExpType == .speedTest {
            self.showInAppPrompt(triggeredFor: .speedTest)
        }
    }
    
}
