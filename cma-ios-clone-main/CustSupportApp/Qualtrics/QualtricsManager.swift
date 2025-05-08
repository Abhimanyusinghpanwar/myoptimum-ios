//
//  QualtricsManager.swift
//  CustSupportApp
//
//  Created by Vishnu on 12/15/23.
//

import UIKit
import Qualtrics

struct QualtricsCustomData {
    let name: String
    let value: String
}

class QualtricsManager {
    var qualtricsPromptDisabled = false
    var eligibilityCheckDone = false
    var qualtricsInvokedInCurrentSession = false
    static let shared: QualtricsManager = {
        let qualtricsManager = QualtricsManager()
        qualtricsManager.initializeQualtricsTheme()
        return qualtricsManager
    }()
    
    private lazy var buttonOneTheme: ButtonTheme = {
        return ButtonTheme(
            textColor: UIColor(named: "softBlack") ?? UIColor.black,
            font: UIFont.customFont(.semiBold, size: 19),
            backgroundColor: UIColor.white,
            borderColor: UIColor(named: "mediumGray") ?? UIColor.gray
        )
    }()
    
    private lazy var buttonTwoTheme: ButtonTheme = {
        return ButtonTheme(
            textColor: UIColor.white,
            font: UIFont.customFont(.bold, size: 19),
            backgroundColor: UIColor(named: "CommonButtonColor") ?? UIColor.orange,
            borderColor: UIColor(named: "CommonButtonColor") ?? UIColor.orange
        )
    }()
    
    private lazy var mobileAppPromptTheme: MobileAppPromptTheme = {
        return MobileAppPromptTheme(
            backgroundColor: UIColor.white,
            headlineTextColor: UIColor(named: "softBlack") ?? UIColor.black,
            headlineFont: UIFont.customFont(.bold, size: 24),
            descriptionTextColor: UIColor(named: "softBlack") ?? UIColor.black,
            descriptionFont: UIFont.customFont(.regular, size: 18),
            buttonOneTheme: buttonOneTheme,
            buttonTwoTheme: buttonTwoTheme
        )
    }()
    
    private func initializeQualtricsTheme() {
        let theme = QualtricsTheme.init(mobileAppPromptTheme: mobileAppPromptTheme)
        Qualtrics.shared.setCreativeTheme(to: theme)
    }
    
    private func addQualatricsCustomData(screenName: String) {
        var qualPopCount = 1
        if let count = getQualtricsPopCount() {
            qualPopCount = count
        }
        let customProperties: [QualtricsCustomData] = [
            QualtricsCustomData(name: "tenure",
                                value: QuickPayManager.shared.getCustomerTenure()),
            QualtricsCustomData(name: "service_bundle",
                                value: MyWifiManager.shared.getServiceBundle()),
            QualtricsCustomData(name: "equipment",
                                value: MyWifiManager.shared.accessTech == "gpon" ? "Fiber" : "HFC"),
            QualtricsCustomData(name: "app_version",
                                value: App.versionNumber()),
            QualtricsCustomData(name: "device_id",
                                value: PreferenceHandler.getValuesForKey("deviceId") as? String ?? ""),
            QualtricsCustomData(name: "pop_count",
                                value: "\(qualPopCount)"),//#1883 add pop count
            QualtricsCustomData(name: "page_name",
                                value: screenName) //#1883 add page names
        ]
        for customProperty in customProperties {
            Qualtrics.shared.properties.setString(string: customProperty.value, for: customProperty.name)
        }
    }
    
    func evaluateAndDisplayQualtricsSurvey(screenName: String) {
        guard let topViewController = UIApplication.topViewController() else {
            print("Unable to get top ViewController.")
            return
        }
        self.addQualatricsCustomData(screenName: screenName)
        Qualtrics.shared.evaluateProject { (targetingResults) in
            for (_, result) in targetingResults {
                if result.passed() {
                    let displayed = Qualtrics.shared.display(viewController: topViewController)
                    self.saveQualtricsShownSuccess()
                    // Here displayed can be used to handle the result of dispay if we need it.
                    Logger.info("Qualtrics survey displayed: \(displayed)")
                }
            }
        }
    }
}
extension QualtricsManager {
    
    func processQualtricsEligibilityRules() {
        ///** RULES:
        /// 1. If App session is active longer than 10 seconds or include 2 or more page views
        /// 2. 30 days rule
        /// 3. If App rating is triggered, qualtrics is not eligible
        /// 4. If App rating is eligitble to display, qualtrics is not eligible
    
        self.startWithTenSecondsRule()
    }
    
    func startWithTenSecondsRule() {
        if ProfileManager.shared.isFirstUserExperience == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if self.eligibilityCheckDone == false {
                    QualtricsManager.shared.qualtricsPromptDisabled = false
                    self.processInitialRules()
                }
            }
        }
    }
    
    func startWithScreenNavsRule() {
        if self.eligibilityCheckDone == false {
            QualtricsManager.shared.qualtricsPromptDisabled = false
            self.processInitialRules()
        }
    }
    
    func processInitialRules() {

        self.eligibilityCheckDone = true
        
        ///**Rule 1:** Check If qualtrics prompt is already displayed and daysBetweenPrompt limit (30 days) is not crossed. Return if 30 days limit not passed.
        guard let lastSavedTimeStamp = self.getFirstQualifyingTimestamp() else {
            return
        }
        //Check if current date is greater than the last saved
        if Date().compare(lastSavedTimeStamp) == .orderedDescending {
            if !self.daysBetweenPromptIsCrossed(lastSavedTimeStamp) {
                self.qualtricsPromptDisabled = true
                return
            } else {
                self.reset() ///Reset when 30 days limit is over
            }
        }
        ///**Rule 2:**  If App rating is triggered in current app session, qualtrics is not eligible. Return if true
        if AppRatingManager.shared.isAppRatingTriggeredd {
            self.qualtricsPromptDisabled = true
            return
        }
        
        ///**Rule 3:**  If App rating is eligitble to display, qualtrics is not eligible. Return if true
        if checkQualifyingExpForAppRating() {
            self.qualtricsPromptDisabled = true
        }
    }
    
    /// To check if App rating is about to display in current session
    func checkQualifyingExpForAppRating() -> Bool {
        if AppRatingManager.shared.inAppReviewPromptDisabled == false {
            let savedAppEntryCount = AppRatingManager.shared.getSavedAppEntryCount()
            if savedAppEntryCount >= 6 {
                return true
            } else if AppRatingManager.shared.getSavedQuickPayCount() >= 3 {
                return true
            }
        }
        return false
    }
    
    func invokeQualtrics(screen: String) {
        ///**Check for App store rating prompt
        ///**Rule 2 & Rule 3 as mentioned in processInitialRules
        if checkQualifyingExpForAppRating() == true || self.qualtricsInvokedInCurrentSession == true || AppRatingManager.shared.isAppRatingTriggeredd == true {
            self.qualtricsPromptDisabled = true
            return
        }
        
        if !qualtricsPromptDisabled {
            //SET DATA TO BE PASSED
            self.evaluateAndDisplayQualtricsSurvey(screenName: screen)
        }
    }
    
    // MARK: - First qualifying Timestamp
    fileprivate func saveFirstQualifyingTimestamp() {
        Logger.info("saveFirstQualifyingTimestamp")
        PreferenceHandler.saveValue(Date(), forKey: QualtricsConstants.firstQualifyingTimestamp_UserDef)
    }
    
    fileprivate func clearFirstQualifyingTimestamp() {
        Logger.info("clearFirstQualifyingTimestamp")
        PreferenceHandler.removeDataForKey(QualtricsConstants.firstQualifyingTimestamp_UserDef)
    }
    
    fileprivate func getFirstQualifyingTimestamp() -> Date? {
        if let date = PreferenceHandler.getValuesForKey(QualtricsConstants.firstQualifyingTimestamp_UserDef) as? Date {
                return date
        } else {
            return nil
        }
    }
    
    fileprivate func daysBetweenPromptIsCrossed(_ savedDate:Date) -> Bool {
        let daysBetweenPrompts = 30//ConfigService.shared.app_rating_window_days
        //let days = Int(daysBetweenPrompts) ?? 30
        let differenceInSeconds = Date().timeIntervalSince(savedDate)
        if differenceInSeconds < Double(daysBetweenPrompts) * 86400 {
            return false
        }
        return true
    }
    
    fileprivate func saveQualtricsShownSuccess() {
        Logger.info("saveInAppPromptShownSuccess")
        self.saveFirstQualifyingTimestamp()
        self.saveQualtricsPopCount()
        self.qualtricsInvokedInCurrentSession = true
        self.qualtricsPromptDisabled = true
    }
    
    // MARK: - Qualtrics count
    //Increment count and save with every qualtrics Pop up appear
    fileprivate func saveQualtricsPopCount() {
        Logger.info("save Qualtrics Pop up count")
        var qualPopCount = 0
        if let count = getQualtricsPopCount() {
            qualPopCount = count
        }
        PreferenceHandler.saveValue(qualPopCount + 1, forKey: QualtricsConstants.qualtricsPopCount_UserDef)
    }
    
    func clearQualtricsPopCount() {
        Logger.info("clear Qualtrics Pop up count")
        PreferenceHandler.removeDataForKey(QualtricsConstants.qualtricsPopCount_UserDef)
    }
    
    fileprivate func getQualtricsPopCount() -> Int? {
        if let count = PreferenceHandler.getValuesForKey(QualtricsConstants.qualtricsPopCount_UserDef) as? Int {
                return count
        } else {
            return nil
        }
    }
    
    // MARK: - Reset
    func reset() {
        Logger.info("reset values for app rating")
        self.clearFirstQualifyingTimestamp()
        self.qualtricsPromptDisabled = false
//        self.resetQuickPayCount()
//        self.resetAppEntryCount()
    }
    
}
class QualtricsConstants {
    class var firstQualifyingTimestamp_UserDef: String {
        return "firstQualifyingTimestampQualtrics"
    }
    class var qualtricsPopCount_UserDef: String {
        return "qualtricsPopCount"
    }
    
}

enum QualifyingQualtrics {
    case selfInstall
    case troubleshooting
    case speedTest
    case quickPay
    case appEntry
}
