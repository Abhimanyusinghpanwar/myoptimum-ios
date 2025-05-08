//
//  AppDelegate.swift
//  CustSupportApp
//
//  Created by Jagadeesh Sriram on 4/22/22.
//

import UIKit
import Firebase
import FirebaseAppCheck
import IQKeyboardManagerSwift
import GoogleMobileAds
import ASAPPSDK //v13.5.2
import Qualtrics

@main
class AppDelegate: UIResponder, UIApplicationDelegate, ASAPPDelegate {
    var window: UIWindow?
    //var reachabilitymanager: ReachabilityManager?
    var splashView: SplashViewController!
    var isSplashShown = false
    var isReloadRequiredForMauiFailure = false
    var backgroundTime: Date? = nil
    let currentTime = 0
    var acccountVC : MyAccountViewController?
    var xtendSettingVC: XtendInstallDeviceSettingsVC?
    var isShowDeAuthScreen = false
    var deepLinkToChatEnabled = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let dateString = PreferenceHandler.getValuesForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP") as? String, CommonUtility.checkRemainingTime() > 0 {
            isShowDeAuthScreen = true
            let loadingScreen = UIStoryboard(name: "BillPay", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeAuthDueViewController")
            window?.rootViewController = loadingScreen
            window!.makeKeyAndVisible()
        } else {
            if let dateString = PreferenceHandler.getValuesForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP") as? String, !dateString.isEmpty {
                PreferenceHandler.removeDataForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP")
            }
            // show loading screen till the config response is received
            let loadingScreen = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoadingScreenViewController")
            window?.rootViewController = loadingScreen
            window!.makeKeyAndVisible()
        }
        setupNaviagtionApperance()
        configureFirebase()
        // Initialize Google Mobile Ads SDK
        DispatchQueue.main.async {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        // Delete any existing png icons before downloading
        PreferenceHandler.checkAndDeleteAnyPNGIcons()
        IQKeyboardManager.shared.enable = true
        getDeviceToken()
        self.initializeQualtrics()
        if !isShowDeAuthScreen {
            self.performConfigRequest()
        }
        return true
    }
    
    func performConfigRequest() {
        APIRequests.shared.initiateConfigRequest(isBrandRequest: false, [:]) { success, response, error in
            ConfigService.shared.saveConfigValues(configResponse: response)
            Logger.info("",shouldLogContext: success)
            if (success && error != nil) {
                // version info screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.navigateToAppUpgradeScreen()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.navigateToLoginScreen()
                }
            }
        }
    }
    
    func initializeASAPP() {
        let config = ASAPPConfig(appId: ConfigService.shared.asapp_app_id,
                                 apiHostName: ConfigService.shared.asapp_host,
                                 clientSecret: "")
        ASAPP.initialize(with: config)
        ASAPP.delegate = self
        //UI Styling for Navigation bar and nav bar items
        ASAPP.styles.colors.navBarBackground = midnightBlueRGB
        ASAPP.styles.colors.navBarButton = .white
        ASAPP.styles.colors.navBarTitle = .white
        ASAPP.styles.navBarStyles.buttonImages.back?.size = CGSize(width: 24, height: 24)
        ASAPP.styles.navBarStyles.buttonImages.more?.size = CGSize(width: 24, height: 24)
        ASAPP.styles.navBarStyles.buttonImages.close?.size = CGSize(width: 24, height: 24)
        ASAPP.styles.navBarStyles.buttonImages.back?.insets = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        ASAPP.styles.navBarStyles.buttonImages.more?.insets = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        ASAPP.styles.navBarStyles.buttonImages.close?.insets = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        ASAPP.styles.navBarStyles.buttonImages.back?.image = UIImage(named: "CaratWhite") ?? UIImage()
        
        //Navigation bar Title
        ASAPP.views = ASAPPViews.init()
        let label:VerticalAlignLabel = VerticalAlignLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.font = UIFont(name: "Regular-Bold", size: 20)
        label.text = "Chat with us"
        label.textColor = UIColor.white
        ASAPP.views.chatTitle = label
        
        //Set MainView bg color
        ASAPP.styles.colors.background = .white
        ASAPP.styles.colors.messagesListBackground = .white
        
        //Styling for User input messages
        ASAPP.styles.colors.messageBackground = energyBlueRGB
        ASAPP.styles.colors.messageText = .white
        
        //Styling for QuickReply buttons
        ASAPP.styles.colors.quickReplyButton.border = energyBlueRGB
        ASAPP.styles.colors.quickReplyButton.textNormal = energyBlueRGB
        ASAPP.strings.quickRepliesRestartButton = ""
        
        //Styling for Agent Bubbles
        ASAPP.styles.colors.replyMessageBackground = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        
        //Styling for ChatInput Area
        ASAPP.styles.colors.chatInput.background = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        ASAPP.styles.colors.chatInput.border = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        ASAPP.styles.colors.separatorPrimary = .clear
        
        //Set Custom Fonts for Messages
        let customFont = ASAPPFontFamily(
            light: UIFont(name: "Regular-Regular", size: 16)!,
            regular:  UIFont(name: "Regular-Medium", size: 16)!,
            medium:  UIFont(name: "Regular-SemiBold", size: 16)!,
            bold:  UIFont(name: "Regular-Bold", size: 20)!)
        ASAPP.styles.textStyles.updateStyles(for: customFont)
        ASAPP.user = ASAPPUser(
            userIdentifier: LoginPreferenceManager.sharedInstance.getMauiEOID(),
            requestContextProvider: { needsRefresh in
                return [
                    "Auth": [
                        "Token": LoginPreferenceManager.sharedInstance.getMauiToken()
                    ]]
            })
        /**
         ASAPPFontFamily
         You can define a font family to be used by the SDK's default styles.
         */
        /* let avenirNext = ASAPPFontFamily(
         light: UIFont(name: "AvenirNext-Regular", size: 16)!,
         regular: UIFont(name: "AvenirNext-Medium", size: 16)!,
         medium: UIFont(name: "AvenirNext-DemiBold", size: 16)!,
         bold: UIFont(name: "AvenirNext-Bold", size: 16)!)
         /**
          ASAPPStyles
          The SDK can be stylized to fit your brand.
          */
         ASAPP.styles.textStyles.updateStyles(for: avenirNext)
         
         ASAPP.styles.textStyles.navButton = ASAPPTextStyle(font: avenirNext.bold, size: 12, letterSpacing: 0, color: .black)*/
        
        /**
         ASAPPStrings
         The strings displayed in the SDK can be customized by accessing ASAPP.strings...
         */
        //ASAPP.strings.chatTitle = "Demo Chat"
    }
    
    func navigateToAppUpgradeScreen() {
        if let appUpgradeVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "appUpgradeViewController") as? AppUpgradeViewController {
            // let navigationController = UINavigationController.init(rootViewController: appUpgradeVC)
            // self.window?.rootViewController = appUpgradeVC
            appUpgradeVC.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(appUpgradeVC, animated: true)
        }
    }
    func navigateToLoginScreen() {
        let loginViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        loginViewController?.isMauiReAuth = false
        let navigationController = UINavigationController.init(rootViewController: loginViewController!)
        self.window?.rootViewController = navigationController
    }
    func setupNaviagtionApperance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.tintColor = .black
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        if (UIApplication.topViewController()?.isKind(of: XtendInstallDeviceSettingsVC.self)) == true {
            resumeXtendInstall()
        }
        if (UIApplication.topViewController()?.isKind(of: ProactivePlacementViewController.self)) == true {
            if let topVC = UIApplication.topViewController() as? ProactivePlacementViewController {
                topVC.rssis = ["",""]
            }
        }
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkForLogin()
        checkForMauiFailure()
        if self.isSplashShown || self.isReloadRequiredForMauiFailure {
            showSplash()
            self.isSplashShown = false
            self.isReloadRequiredForMauiFailure = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigateToLoginScreen()
            }
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        let currentTime = Date.now
        backgroundTime = currentTime //For deauth scenario
        LoginPreferenceManager.sharedInstance.metricsInfo.bgInterruption = true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
        if QuickPayManager.shared.interceptor.ignoreReAuth == true {
            LoginPreferenceManager.sharedInstance.removeLoginPreferences()
        }
        if !SpotLightsManager.shared.dismissibleCardsArray.isEmpty {
            let dismissibleArray =  SpotLightsManager.shared.addParams(cards: SpotLightsManager.shared.dismissibleCardsArray, isViewed: true)
            PreferenceHandler.saveValue(dismissibleArray, forKey: "dismissibleSpotlights")
        }
    }
    
    func showSplash() {
        isSplashShown = true
        DispatchQueue.main.async(execute: {
            self.splashView = SplashViewController()
            let bounds = UIScreen.main.bounds
            // self.activity = UIWindow.init(frame: bounds)
            self.splashView?.view.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
            // self.splashView.view.backgroundColor = midnightBlueRGB
            self.window?.addSubview((self.splashView?.view)!)
            self.window?.bringSubviewToFront((self.splashView?.view)!)
            Logger.info("The Splash screen is shown for Foreground state...")
        })
    }
    
    func dismissSplashOverlay() {
        isSplashShown = false
        DispatchQueue.main.async(execute: {
            if self.splashView?.view != nil {
                UIView.animate(withDuration: 0.2,
                               animations: {self.splashView.view.alpha = 0.0},
                               completion: {(value: Bool) in
                    self.splashView.view.removeFromSuperview()})
            }
        })
    }
    func resumeXtendInstall() {
        if let topVC = UIApplication.topViewController() as? XtendInstallDeviceSettingsVC {
            topVC.checkNetworkState()
        }
    }
    func calculateTimeDifference(started: Date, ended: Date) -> Int? {
        let diffsec = Int(ended.timeIntervalSince(started))
        return diffsec
    }
    func checkForLogin() {
        guard let asmThreshold = Int(ConfigService.shared.asmThresholdDuration) else { return }
        let currentTime = Date.now
        let pastTime = backgroundTime
        if let pastTime = pastTime, let diff = calculateTimeDifference(started: pastTime, ended: currentTime) {
            Logger.info("The time difference when swithching to Foreground: \(diff)")
            if (diff >= asmThreshold) {
                isSplashShown = true
                Logger.info("The Splash shown for ASM and time diff is \(diff)")
            }
        }
    }
    
    func checkForMauiFailure() {
        switch (
                QuickPayManager.shared.isMauiAccountListCompleted,
                QuickPayManager.shared.isGetAccountActivityCompleted) {
        case (false, _), (_, false):
            isReloadRequiredForMauiFailure = true
        default:
            isReloadRequiredForMauiFailure = false
        }
        if isReloadRequiredForMauiFailure, APIRequests.shared.isReloadNotRequiredForMaui {
            isReloadRequiredForMauiFailure = false
        }
    }
    
    func getDeviceToken() {
        if DEVICE_TOKEN == nil {
            DEVICE_TOKEN = App.getDeviceIdFromKeychain()
        }
    }
    func handleASAPPDeepLink(named deepLink: String, with data: [String : Any]?) {
        let alert = UIAlertController(title: "Deep Link", message: deepLink, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //present(alert, animated: true, completion: nil)
    }
    @objc func chatViewControllerDidDisappear() {}
    
    @objc func chatViewControllerDidTapDeepLink(name: String, data: [String: Any]?) {
        handleASAPPDeepLink(named: name, with: data)
    }
    
    @objc func chatViewControllerShouldHandleWebLink(url: URL) -> Bool {
        // Return false if ASAPP should not handle the web link and your app will handle it instead.
        return true
    }
    
    @objc func chatViewControllerDidTapUserLoginButton() {
        /**
         Application should present UI to let user login. Once login is finished, ASAPP.user should be set.
         Note: if the user is always logged in, the body of this method may be left blank.
         */
    }
    
    @objc func chatViewControllerDidReceiveChatEvent(name: String, data: [String: Any]?) {
        // Application can respond to certain agreed-upon events that can occur during a chat.
    }
    
    func initializeQualtrics() {
        Qualtrics.shared.initializeProject(
            brandId: "testaltice",
            projectId: "ZN_3WeSXtlaqsXgcVE",
            extRefId: "SI_eMbeGuPKQ3wXy8m",
            completion: { (myInitializationResult) in
                print(myInitializationResult)
            })
    }
    
    func configureFirebase() {
        let providerFactory = MOACustomAppCheckProvider()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
    }
    
    // Helper function to get the topmost view controller
    func getTopViewController(from rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            // If there's a modal presented, navigate through it
            return getTopViewController(from: presentedViewController)
        } else if let navigationController = rootViewController as? UINavigationController {
            // If it's a navigation controller, get the top view controller
            return navigationController.topViewController
        } else {
            // Otherwise, return the root view controller itself
            return rootViewController
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        // Handle the URL
        handleUniversalLink(url)
        return true
    }

    private func handleUniversalLink(_ url: URL) {
        if url.pathComponents.contains("chat") {
            navigateToChat()
        }
    }
    
    func navigateToChat() {
        if ASAPP.config == nil {
            deepLinkToChatEnabled = true
            return
        }
        deepLinkToChatEnabled = false
        var chatViewController : UIViewController?
        chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil)
        guard let chatVC = chatViewController else {
            return
        }
        chatVC.modalPresentationStyle = .fullScreen
        // Access the current window's root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No root view controller available.")
            return
        }
        let topViewController = getTopViewController(from: rootViewController)
        if topViewController is HomeScreenViewController {
            topViewController?.trackAndNavigateToChat(chatTransitionType: .Push, chatVC: chatVC)
        }
    }
}

