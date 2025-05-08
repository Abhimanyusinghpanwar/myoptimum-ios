//
//  LoginViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 18/05/22.
//

import UIKit
import SafariServices
import Lottie
import Combine
import Alamofire

class LoginViewController: UIViewController, TTTAttributedLabelDelegate {
    
    let errorColor = UIColor(red: 234/255, green: 0/255, blue: 42/255, alpha: 1.0)
    
    @IBOutlet weak var lcLetsStartedWidth: NSLayoutConstraint!
    @IBOutlet weak var lcMainContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var usernameTextField: FloatLabelTextField!
    @IBOutlet weak var passwordTextField: FloatLabelTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var termsAndConditionsLabel: TTTAttributedLabel!
    @IBOutlet weak var createIDLabel: TTTAttributedLabel!
    @IBOutlet weak var lcErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var vwMainContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var optimumLogo: UIImageView!
    @IBOutlet weak var signInAnimView: LottieAnimationView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var showHidePassButton: UIButton!
    @IBOutlet weak var showHidePassImgView: UIImageView!
    @IBOutlet weak var labelScreenTitle: UILabel!
    @IBOutlet weak var lcTopSpaceSubTitle: NSLayoutConstraint!
    @IBOutlet weak var lcSaveButtonBottomMaui: NSLayoutConstraint!
    @IBOutlet weak var lcCreateIdLabel: NSLayoutConstraint!
    @IBOutlet weak var errorIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameSuperView: UIView!
    @IBOutlet weak var passwordSuperView: UIView!
    @IBOutlet weak var postLoginUserNameLabel: UILabel!
    @IBOutlet weak var postLoginUserNameTextField: UITextField!
    @IBOutlet weak var postLoginPasswordLabel: UILabel!
    @IBOutlet weak var postLoginPasswordTextField: UITextField!
    @IBOutlet weak var postLoginPasswordLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    var params = [String: AnyObject]()
    var signInIsProgress: Bool = false
    var greetingSalutationView: GreetingSalutaionView?
    var isPasswordExpired: Bool = false
    var canNavigateToNextScreen:Bool = false
    var mauiAPISuccess = false
    let paymentSharedManager = QuickPayManager.shared
    var isMauiReAuth: Bool = false
    var isAutoLoginFlow: Bool = false
    var dispatchGroupQueue = DispatchGroup()
    var savedUserNameTextField: FloatLabelTextField?
    var savedPasswordTextField: FloatLabelTextField?
    var showWhatsNewScreenEnabled = false
//    var firstlaunch = false

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let subview = view.subviews.first as? UIScrollView {
            subview.contentInsetAdjustmentBehavior = .never
        }
        self.view.backgroundColor = midnightBlueRGB
        self.configureUI()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadLogin), name:NSNotification.Name(rawValue: "SplashSSO"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)),
                                                   name: UIResponder.keyboardWillHideNotification,
                                                   object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.greetingSalutationView != nil && !self.greetingSalutationView!.isHidden {
            return .lightContent
        } else {
            return .default
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addTextFields()
        self.loadingView.isHidden = true
        self.showWhatsNewScreenEnabled = false
        self.postLoginPasswordLabel.isHidden = true
        self.postLoginUserNameLabel.isHidden = true
        self.postLoginPasswordTextField.isHidden = true
        self.postLoginUserNameTextField.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if !canAutoLogin() {
            self.signInButton.isHidden = false
            self.signInAnimView.isHidden = true
            self.passwordTextField.isSecureTextEntry = true
            self.showHidePassButton.isSelected = false
            self.showHidePassImgView.image = UIImage.init(named: "show_Password")
            lcErrorHeight.constant = 0
          //  usernameTextField.text = ""
            passwordTextField.text = ""
            self.view.backgroundColor = .systemBackground
            
            self.optimumLogo.image = UIImage(named:"logo_black")
            if self.greetingSalutationView != nil {
                self.greetingSalutationView?.isHidden = true
                self.greetingSalutationView?.removeFromSuperview()
                self.greetingSalutationView = nil
                self.setNeedsStatusBarAppearanceUpdate()
                setupInitialScreen()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startLoginStartupAnimation()
                }
            }
        }
        
        if usernameTextField != nil {
            usernameTextField.setBorderColor(mode: BorderColor.deselcted_color)
            passwordTextField.setBorderColor(mode: BorderColor.deselcted_color)
            changePlaceholderColor(textField: usernameTextField, color: .placeholderText)
            changePlaceholderColor(textField: passwordTextField, color: .placeholderText)
        }
       // addingLogo()
      //  loginViewInitialAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Attributes for terms&condition and forgot id label content.
        addingLinks()
        errorLabel.superview?.layer.cornerRadius = 20
        errorLabel.superview?.layer.borderColor = errorColor.cgColor
        errorLabel.superview?.layer.borderWidth = 1
        //For Firebase Analytics
 
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_SIGN_IN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
    }
    
    @objc func didEnterBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadLogin(_:)), name:NSNotification.Name(rawValue: "SplashSSO"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SplashSSO"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func reloadLogin(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SplashSSO"), object: nil)
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        let userNameFieldReference = usernameTextField ?? savedUserNameTextField
        let passwordFieldReference = passwordTextField ?? savedPasswordTextField
        if userNameFieldReference != nil, userNameFieldReference?.getBorderColor() == .selected_color {
            userNameFieldReference?.setBorderColor(mode: .deselcted_color)
            changePlaceholderColor(textField: userNameFieldReference!, color: .placeholderText)
        }

        if passwordFieldReference != nil, passwordFieldReference?.getBorderColor() == .selected_color {
            passwordFieldReference?.setBorderColor(mode: .deselcted_color)
            changePlaceholderColor(textField: passwordFieldReference!, color: .placeholderText)
        }
    }
    // MARK: - Auto Login
    func canAutoLogin() -> Bool {
        if  let loginData = PreferenceHandler.getValuesForKey("loginAuthenticationData") as? [String : AnyObject], let accessToken = loginData["access_token"] as? String, !accessToken.isEmpty {
            return true
        } else {
            return false
        }
    }
    func initiateAutoLogin() {
        if PreferenceHandler.getValuesForKey("loginTime") == nil { // CMAIOS-1632
            LoginPreferenceManager.sharedInstance.setInitialLoginTime()
        }
        LoginPreferenceManager.sharedInstance.autoLoginFlow = true
        LoginPreferenceManager.sharedInstance.saveStartLoginTime()
        initiateAfterLoginAPICalls(isAutoLogin: true)
    }
    // MARK: - SignIn Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.signInAnimView.isHidden = true
        self.signInButton.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.signInAnimView.isHidden = false
        }
        self.signInAnimView.backgroundColor = .clear
        self.signInAnimView.animation = LottieAnimation.named("OrangeFullWidthButton")
        self.signInAnimView.loopMode = .playOnce
        self.signInAnimView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.signInAnimView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress && self.signInAnimView.isAnimationPlaying {
                self.signInAnimView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .loop)
            }
        })
    }
    func signInFailedAnimation() {
        self.resetPostLoginScreen(true, username: "", password: "")
        self.signInIsProgress = false
        self.signInAnimView.currentProgress = 3.0
        self.signInAnimView.stop()
        self.signInAnimView.isHidden = true
        self.signInButton.alpha = 0.0
        self.signInButton.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.signInButton.alpha = 1.0
        }
    }
    // MARK: - UI and Animations
    func addingLinks() {
        
        let screenWidth = UIScreen.main.bounds.width
        let xibDesignWidth = 375.0
        
        let tAndCFont = UIFont(name: "Regular-Medium", size: (15.0/xibDesignWidth)*screenWidth)//font.withSize((font.pointSize/xibDesignWidth)*screenWidth)
        let createIDFont = UIFont(name: "Regular-Medium", size: (16.0/xibDesignWidth)*screenWidth)
        let createIDLinkFont = UIFont(name: "Regular-Bold", size: (16.0/xibDesignWidth)*screenWidth)
        termsAndConditionsLabel.font = tAndCFont
        createIDLabel.font = createIDFont
        
        let linkAttributes: NSMutableDictionary = NSMutableDictionary()
        linkAttributes.setObject(UIColor(red: 0.216, green: 0.372, blue: 0.910, alpha: 1.0), forKey: NSAttributedString.Key.foregroundColor as NSCopying)
        
        let createIDlinkAttributes: NSMutableDictionary = NSMutableDictionary()
        createIDlinkAttributes.setObject(UIColor(red: 0.216, green: 0.372, blue: 0.910, alpha: 1.0), forKey: NSAttributedString.Key.foregroundColor as NSCopying)
        createIDlinkAttributes.setObject(createIDLinkFont as Any, forKey: NSAttributedString.Key.font as NSCopying)
        if let attributes = (NSDictionary(dictionary: linkAttributes) as? [AnyHashable: Any]) {
            self.termsAndConditionsLabel.linkAttributes = attributes
           // self.createIDLabel.linkAttributes = attributes
        }
        if let attributes = (NSDictionary(dictionary: createIDlinkAttributes) as? [AnyHashable: Any]) {
          //  self.termsAndConditionsLabel.linkAttributes = attributes
            self.createIDLabel.linkAttributes = attributes
        }
        let activeLinkAttributes: NSMutableDictionary = NSMutableDictionary()
        activeLinkAttributes.setObject(UIColor.white, forKey: NSAttributedString.Key.foregroundColor as NSCopying)

        if let attributes = (NSDictionary(dictionary: activeLinkAttributes) as? [AnyHashable: Any]) {
            termsAndConditionsLabel.activeLinkAttributes = attributes
            createIDLabel.activeLinkAttributes = attributes
        }
        let termsAndConditionsString: NSString = ConfigService.shared.tosPpText as NSString

        self.termsAndConditionsLabel.text = termsAndConditionsString as String
        
        let createIDString: NSString = "Don’t have an Optimum ID?  Create ID"

        self.createIDLabel.text = createIDString as String

        //Terms and condition label text with underlined link.
        let termsAndConditionsRange: NSRange = termsAndConditionsString.range(of: "Terms of Use")
        termsAndConditionsLabel.addLink(to: URL(string: "TOS"), with: termsAndConditionsRange)

        let privacyNoticeRange: NSRange = termsAndConditionsString.range(of: "Mobile Privacy Notice")
        termsAndConditionsLabel.addLink(to: URL(string: "MobilePrivacyNotice"), with: privacyNoticeRange)
        
        let createIDRange: NSRange = createIDString.range(of: "Create ID")
        createIDLabel.addLink(to: URL(string: "CreateID"), with: createIDRange)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        var linkURL = ""
        switch url.absoluteString {
        case "TOS":
            linkURL = ConfigService.shared.tosURL
        case "MobilePrivacyNotice":
            linkURL = ConfigService.shared.privacyPolicyURL
        case "CreateID":
            linkURL = ConfigService.shared.createUserIDURL
        default:
            linkURL = ""
        }
        self.navigateToInAppBrowser(linkURL, title: "")
    }
    
    func resetUIOnSignIn() {
        usernameTextField.setBorderColor(mode: .deselcted_color)
        passwordTextField.setBorderColor(mode: .deselcted_color)
        resetKeyboard()
        changePlaceholderColor(textField: usernameTextField, color: .placeholderText)
        changePlaceholderColor(textField: passwordTextField, color: .placeholderText)
        lcErrorHeight.constant = 0
    }
    
    func resetKeyboard() {
        usernameTextField.returnKeyType = .next
        usernameTextField.reloadInputViews()
        
        passwordTextField.returnKeyType = .next
        passwordTextField.reloadInputViews()
    }
    
    func startLoginStartupAnimation() {
        animateLetsGetStarted(showScreen: true)
    }
    
    func animateLetsGetStarted(showScreen show: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.lcLetsStartedWidth.constant = show ? 1000 : 0
            self.view.layoutIfNeeded()
        } completion: { complete in
            self.animateBottomSectionWithAnimation(showScreen: show)
            self.animateMainContainer(showScreen: show)
            self.animateOptimumLogo(showScreen: show)
        }
    }
    
    func animateMainContainer(showScreen show:Bool) {
        UIView.animate(withDuration: 1.5) {
            self.vwMainContainer.alpha = show ? 1.0 : 0.0
            self.lcTopSpaceSubTitle.constant =  CurrentDevice.forLargeSpotlights() ? 56.0 : 38.0
        }
        
        self.lcMainContainerHeight.constant = show ? 1000 : 0
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func animateBottomSectionWithAnimation(showScreen show:Bool) {
        UIView.animate(withDuration: 1.0) {
            self.termsAndConditionsLabel.superview?.alpha = show ? 1.0 : 0.0
        }
    }
    
    func animateOptimumLogo(showScreen show:Bool) {
        UIView.animate(withDuration: 1.0) {
            self.optimumLogo.alpha = show ? 1.0 : 0.0
        }
    }
    
    func setupInitialScreen() {
        lcTopSpaceSubTitle.constant = 210
        lcErrorHeight.constant = 0
        lcLetsStartedWidth.constant = 0
        lcMainContainerHeight.constant = 0
        termsAndConditionsLabel.superview?.alpha = 0
        vwMainContainer.alpha = 0
        self.view.layoutIfNeeded()
    }
    
    //For iPod, iPhone SE 3rd, first, 2nd gen devices
       func     updateConstraintForSmallerScreens(constraintConstant: CGFloat) {
           if currentScreenHeight <= xibDesignHeight {
               self.lcTopSpaceSubTitle.constant = constraintConstant
           }
       }
    
    func addTextFields(){
        if passwordTextField == nil && savedPasswordTextField != nil {
            passwordTextField = savedPasswordTextField
            passwordSuperView.addSubview(passwordTextField)
            self.setConstraintsForPassword()
            savedPasswordTextField = nil
            self.passwordSuperView.bringSubviewToFront(self.showHidePassButton)
        }
        if usernameTextField == nil && savedUserNameTextField != nil {
            usernameTextField = savedUserNameTextField
            userNameSuperView.addSubview(usernameTextField)
            self.setConstraintsForUsername()
            savedUserNameTextField = nil
        }
    }

    func showLoginScreen(needErrorMessage: Bool)
    {
        self.showWhatsNewScreenEnabled = false
        LoginPreferenceManager.sharedInstance.removeLoginPreferences()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
            self.addTextFields()
            if self.greetingSalutationView != nil {
                self.greetingSalutationView?.salutationAnimation.isHidden = true
                self.greetingSalutationView?.isHidden = true
                self.greetingSalutationView?.removeFromSuperview()
                self.greetingSalutationView = nil
                self.setNeedsStatusBarAppearanceUpdate()
            }
            self.view.backgroundColor = .systemBackground
            self.signInIsProgress = false
            self.signInButton.alpha = 0.0
            self.signInButton.isHidden = false
            self.signInButton.alpha = 1.0
            self.lcLetsStartedWidth.constant = 1000
            self.termsAndConditionsLabel.superview?.alpha = 1.0
            self.vwMainContainer.alpha = 1.0
            self.optimumLogo.alpha = 1.0
            self.optimumLogo.image = UIImage(named:"logo_black")
            self.lcMainContainerHeight.constant = 1000
            if self.passwordTextField != nil {
                self.passwordTextField.text = ""
            }
            self.lcErrorHeight.constant = 0
            if needErrorMessage {
                self.lcErrorHeight.constant = 500
                self.displayError(message: MyWiFiConstants.check_accounts_later, for: [])
                if self.passwordTextField != nil {
                    self.usernameTextField.setBorderColor(mode: .deselcted_color)
                    self.passwordTextField.setBorderColor(mode: .deselcted_color)
                }
                trackTechnicalDifficultyGAEvent() //CMAIOS-2449
            }
            if !self.loadingView.isHidden {
                self.removeLoaderView()
            }
        }
    }
    func callMetricsForError() {
        let duration = LoginPreferenceManager.sharedInstance.calculateLoginDuration()
        let label = "login_technical_difficulties"
        LoginPreferenceManager.sharedInstance.callLogMetrics(duration: duration, label: label)
    }
// MARK: - After Login API Calls
    /**This methods is used to call DeviceRegistration API in case of manual login and AutoLogin
     After success of Device Reg API, other initial launch API are calls while "Signing you screen is shown to user"
     @param: isAutoLogin - determine if the API calls are for AutoLogin or manual login
     **/
    func initiateAfterLoginAPICalls(isAutoLogin: Bool) {
        self.displayLoadingAfterLogin(isAutoLogin: isAutoLogin)
        APIRequests.shared.performDeviceRegistration {success, error in
            if success {
                self.parallelApiCalls(isAutoLogin: isAutoLogin)
            } else if LoginPreferenceManager.sharedInstance.authTokenFailed {
                self.callMetricsForError()
                DispatchQueue.main.async {
                    self.showLoginScreen(needErrorMessage: false)
                }
            } else {
                self.callMetricsForError()
                self.showLoginScreen(needErrorMessage: true)
            }
        }
    }
    
    /*
    func showReauthErrorMessage() {
        guard let topVisibleView = UIApplication.topViewController() else {
            return
        }
        LoginPreferenceManager.sharedInstance.manualSignInActive = false // CMAIOS-1480
        // Only works in autologin flow, If loginview as top ViewController
        // Modify the Login UI for maui login flow
        if topVisibleView.isKind(of: LoginViewController.self) {
            DispatchQueue.main.async {
                if let loginView = topVisibleView as? LoginViewController {
                    loginView.isMauiReAuth = true
                    loginView.isAutoLoginFlow = true
                    loginView.configureUI()
                    loginView.removeGreetingSalutationView()
                }
            }
        } else {
            self.showLoginScreen(needErrorMessage: true)
        }
    }
     */
    
    func decodeEOIDFromJWT() -> String? {
        guard let jwtJson = CommonUtility.decodeJWT(token: LoginPreferenceManager.sharedInstance.getMauiToken()) else {
            return nil
        }
        
        return jwtJson["eoid"] as? String
    }
    
    func initializeASAPPChat() {
        DispatchQueue.main.async {
            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                appDel.initializeASAPP()
            }
        }
    }
    
    /**This methods calls 3 APIS:
     API #1: Accounts API Call
     API #2: Operational Status API Call after getting the value from Accounts API
     API #3: Config API call
     **/
    func parallelApiCalls(isAutoLogin: Bool) {
        let dispatchGroup = DispatchGroup()
        var accountsAPISuccess = false
        var configAPISuccess = false

        AppRatingManager.shared.processInAppReviewDisplayRules()
        QualtricsManager.shared.processQualtricsEligibilityRules()
        
        /// Download device icons
        DeviceManager.shared.downloadDeviceIcons(color: .white)
        DeviceManager.shared.downloadDeviceIcons(color: .gray)
        /// API #1: MAUI Token API Call only in case of manual login
        Logger.info("Requesting maui tokens...")
        if !isAutoLogin {
            APIRequests.shared.initiateMAUITokenRequest(self.params) { success, _, _ in
                if success {
                    Logger.info("MAUI token saved success")
                    if let eoid = self.decodeEOIDFromJWT(), !eoid.isEmpty {
                        LoginPreferenceManager.sharedInstance.setMauiEOIDToPreference(eoid: eoid)
                        self.initializeASAPPChat()
                    }
        /// API #2: MAUI Accounts API call, followed by
        /// API #3: MAUI Account Activity API call
                    QuickPayManager.shared.interceptor.ignoreReAuth = false // CMA:-2926
                    self.mauiAccoutsListRequest(dispatchGroup)
                } else {
                    Logger.info("MAUI Login failed")
                    self.callMetricsForError()
                    self.showLoginScreen(needErrorMessage: true)
                }
            }
        } else {
            self.mauiAccoutsListRequest(dispatchGroup)
            /**Uncomment code below to enable EOID from maui token JWT**/
            if let eoid = LoginPreferenceManager.sharedInstance.getMauiEOID(), !eoid.isEmpty {
                self.initializeASAPPChat()
            } else {
                if let eoid = self.decodeEOIDFromJWT(), !eoid.isEmpty {
                    LoginPreferenceManager.sharedInstance.setMauiEOIDToPreference(eoid: eoid)
                    self.initializeASAPPChat()
                }
            }
        }
        
        if !ConfigService.shared.whats_new.isEmpty && !enableFirstUserExperience{
            /// API #5: Settings API Call
            dispatchGroup.enter()
            APIRequests.shared.settingsAPIRequest("") { success, response, error  in
                if success {
                    if let lastSeenFrmSettings = response?.whatsnew_last_seen_set {
                        if let setNumFrmConfig = WhatsNewManager.shared.getSetNumber() as String?, !setNumFrmConfig.isEmpty {
                            if Int(lastSeenFrmSettings)! < Int(setNumFrmConfig)! {
                                self.showWhatsNewScreenEnabled = true
                            }
                        }
                    } else {
                        self.showWhatsNewScreenEnabled = true
                    }
                }
                dispatchGroup.leave()
            }
        }
        /// API #4: Accounts API Call
        dispatchGroup.enter()
        APIRequests.shared.initiateAccountsAPIRequest { success, response, error in
            if success {
                Logger.info("",shouldLogContext: success)
                accountsAPISuccess = true
                dispatchGroup.leave()
                self.initiateGatewayCall()
            } else {
                if response == nil {
                    self.callMetricsForError()
                    self.showLoginScreen(needErrorMessage: true)
                } else {
                    if let code = response?.code, code == "business" {
                        DispatchQueue.main.async {
                            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AuthenticationErrorViewController") as AuthenticationErrorViewController
                            self.navigationController?.pushViewController(loginVC, animated: true)
                        }
                    }
                }
            }
        }
        /// API #3: Config API call
        dispatchGroup.enter()
        APIRequests.shared.initiateConfigRequest(isBrandRequest: true, [:]) { success, response, error in
            Logger.info("",shouldLogContext: success)
            if success {
                ConfigService.shared.saveConfigValues(configResponse: response) // CMAIOS-1632
            }
            if (success && error != nil) {
                DispatchQueue.main.async {
                    if let appUpgradeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "appUpgradeViewController") as? AppUpgradeViewController {
                        appUpgradeVC.modalPresentationStyle = .fullScreen
                        self.present(appUpgradeVC, animated: true)
                    }
                }
            } else {
                configAPISuccess = true
            }
            // To unblock the app in staging ans production, added the below condition
            // dispatchGroup.leave(), Should be removed once Quickpay moved to staging/Production
            if !enableQuickPayFeature {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            switch (configAPISuccess, accountsAPISuccess) {
            // To unblock the app in staging and production, added the below condition
            // The below condition Should be replaced with *****case (true, true, true)***** once Quickpay moved to staging/Production
            case (true, true):
                self.canNavigateToNextScreen = true /// Make 'canNavigateToNextScreen' boolean true here only when all the parallel api calls are completed
                DispatchQueue.main.async { /// As per CMA-1450, User should not be navigated to home screen before 3.5 seconds of animation progress
                    if self.greetingSalutationView != nil && !(self.greetingSalutationView?.salutationAnimation.realtimeAnimationProgress.isLess(than: 0.07))!{
                        if self.canNavigateToNextScreen == true {
                            self.validateNextScreen()
                        }
                    } else { /// Edge case - If the blocker APIs are completed before 3.5 seconds, then below code will avoid the wait to navigate till the end of salut animation. The user will be navigated after another 2.0 seconds playtime
                        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                            if self.canNavigateToNextScreen == true {
                                self.validateNextScreen()
                            }
                        }
                    }
                }
            default: break
            }
        }
    }
    
    /// Checks the scrren flow type like normal, maui expiry flow (with and without autologin)
    func validateNextScreen() {
            switch (isMauiReAuth, isAutoLoginFlow) {
            case (true, false):
                if ((self.navigationController?.isBeingPresented) != nil) {
                    LoginPreferenceManager.sharedInstance.setInitialLoginTime() // Whenever reauth happens update the login time // CMAIOS-1480
                     if paymentSharedManager.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" {
                     presentAccountBlockedScreen()
                     } else {
                     self.dismiss(animated: true) {
                     QuickPayManager.shared.showAppropriteScreenAfterReAuth()
                     }
                     }
                    self.dismiss(animated: true) {
                        QuickPayManager.shared.showAppropriteScreenAfterReAuth()
                    }
                }
            case (true, true):
                LoginPreferenceManager.sharedInstance.setInitialLoginTime() // Whenever reauth happens update the login time // CMAIOS-1480
                 if enableQuickPayFeature {
                 self.checkUserBlockedForNonPayment()
                 } else {
                 self.prepareNextScreen()
                 }
                self.prepareNextScreen()
            default:
                // To unblock the app in staging and production, added the below condition
                // Should be replaced with self?.checkUserBlockedForNonPayment() once Quickpay moved to staging/Production
                 if enableQuickPayFeature {
                 self.checkUserBlockedForNonPayment()
                 } else {
                 self.prepareNextScreen()
                 }
                self.prepareNextScreen()
            }
    }
    
    /*
    func mauiAccoutsListRequest(_ dispatchGroup: DispatchGroup) {
        // To unblock the app in staging and production, added the below condition
        // The below condition  **** If enableQuickPayFeature **** Should be removed once Quickpay moved to staging/Production
        if enableQuickPayFeature {
            /// API #4: Maui Account List API call
            self.dispatchGroupQueue = dispatchGroup
            APIRequests.shared.mauiAccoutsListRequest(interceptor: QuickPayManager.shared.interceptor, completionHandler: { success, value, error, code in
                DispatchQueue.main.async {
                    if success {
                        QuickPayManager.shared.modelAccountsList = value
                        self.mauiGetAccountActivityRequest(dispatchGroup)
                        self.checkForUpdateSpotlights(dispatchGroup)
                        Logger.info("MAUI Account List Response is \(String(describing: value))", sendLog: "MAUI Account List success")
                    } else {
                        Logger.info("MAUI Account List Response is \(String(describing: error))")
                        self.validateFailureCodeToUpdateErrrMsg(code: code)
                    }
                }
            })
        }
    }
     */
    
    func checkForUpdateSpotlights(_ dispatchGroup: DispatchGroup) {
        if enableQuickPayFeature {
            self.dispatchGroupQueue = dispatchGroup
            if let dismissArray = PreferenceHandler.getValuesForKey("dismissibleSpotlights") as? NSMutableArray, dismissArray.count > 0 {
                self.updateSpotlightCardsRequest(cards: dismissArray, dispatchGroup: dispatchGroup)
                PreferenceHandler.removeDataForKey("dismissibleSpotlights")
            } else {
                mauiSpotlightCardRequest(dispatchGroup)
            }
        }
    }
    
    func updateSpotlightCardsRequest(cards: NSMutableArray, dispatchGroup: DispatchGroup ) {
        self.dispatchGroupQueue = dispatchGroup
        var params = [String:AnyObject]()
        params["cards"] = cards as AnyObject
            APIRequests.shared.mauiUpdateSpotLightCards(params: params) { success, value, error in
                if success {
                    self.mauiSpotlightCardRequest(dispatchGroup)
                }
            }
    }
    
    func mauiSpotlightCardRequest(_ dispatchGroup: DispatchGroup) {
        if enableQuickPayFeature {
            self.dispatchGroupQueue = dispatchGroup
            APIRequests.shared.mauiGetSpotLightCards(completionHandler: { success, value, error in
                //            Enable it to check update spotlight API
                //            if success {
                //                if let spotlightCards = SpotLightsManager.shared.spotLightCards, let cards = spotlightCards.cards, !cards.isEmpty {
                //                    SpotLightsManager.shared.spotLightCards.cards![0].wasDismissed = true
                //                    SpotLightsManager.shared.spotLightCards.cards![0].wasViewed = true
                //                }
                //            }
            })
        }
    }
    
    /*
    func mauiGetAccountActivityRequest(_ dispatchGroup: DispatchGroup) {
        var params = [String: AnyObject]()
        params["name"] = paymentSharedManager.getAccountNam() as AnyObject?
        self.dispatchGroupQueue = dispatchGroup
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity Response is \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiAPISuccess = true
                    self.mauiRequestGetAccountBill()
                    self.mauiGetCustomerInfo()
                    dispatchGroup.leave()
                } else {
                    Logger.info("Get Account Bill Activity Response is \(String(describing: error))")
                    self.validateFailureCodeToUpdateErrrMsg(code: code)
                }
            }
        })
    }
     */
    
    /*
    /// To get the initial GetAccountBill data for home screen, but its not blocker API
    func mauiRequestGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = paymentSharedManager.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.mauiRequestListBills()
                } else {
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                }
            }
        })
    }
     */
    
    /*
    /// To get listBills
      func mauiRequestListBills() {
        var params = [String: AnyObject]()
        params["name"] = paymentSharedManager.getAccountNam() as AnyObject?
        APIRequests.shared.mauiBillListRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayListBill = value
                }
            }
        })
    }
     */
    
    func mauiGetCustomerInfo() {
        APIRequests.shared.mauiGetCustomerTenure { success, response, error in
            if success {
                QuickPayManager.shared.modelCustomerTenure = response
            }
        }
    }

    func initiateClientUsageCall() {
        if MyWifiManager.shared.isSmartWifi() {
            APIRequests.shared.initiateClientUsageRequest(){ success, response, error in
                Logger.info("",shouldLogContext: success)
                MyWifiManager.shared.isClientUsageAPISucceeded = success
                if success {
                    if let usageData = response?.clients as [ClientUsageResponse.Client]?, !usageData.isEmpty {
                        MyWifiManager.shared.saveClientUsageData(value: usageData)
                        //Update device connectedTime
                        ProfileModelHelper.shared.updateProfileDeviceConnectedTime(onlineActivityData: usageData) { profiles in
                            ProfileModelHelper.shared.profiles = profiles
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateOnlineActivity"),object: nil))
                            }
                        }
                    }
                } else {
                    MyWifiManager.shared.clientUsage = nil
                }
            }
        }
    }
    
    func initiateGatewayCall() {
        /// API #2: Operational Status API Call after Accounts API
        guard let deviceMAC = MyWifiManager.shared.deviceMAC, let deviceType = MyWifiManager.shared.deviceType else {
            //Gateway is offline
            ///TO-DO: Create structure for gateway values
            return
        }
        let mapString = "\(deviceMAC)?devicetype=" + deviceType
        APIRequests.shared.isRebootOccured = false
        if !MyWifiManager.shared.accessTech.isEmpty, MyWifiManager.shared.accessTech == "gpon" {
            APIRequests.shared.initiateGatewayStatusAPIRequestForFiber(mapString) { success, response, error in
                if success && MyWifiManager.shared.isOperationalStatusOnline == true {
                    self.initiateClientUsageCall()
                }
            }
        } else {
            APIRequests.shared.initiateGatewayStatusAPIRequest(mapString) { success, response, error in
                if success && MyWifiManager.shared.isOperationalStatusOnline == true {
                    self.initiateClientUsageCall()
                }
            }
        }
        
        if MyWifiManager.shared.getWifiType() == "Gateway" && isShowDeadZoneSpotlight() {
            APIRequests.shared.initiateDeadZoneRequest { success,value,error  in
                if success {
                    if let deadZone = value, let homeQoe = deadZone.home_qoe, !homeQoe.isEmpty, let homeQoeData = homeQoe.first, let qoeScore = homeQoeData.qoe_score, let threshold = Double(ConfigService.shared.qoeThreshold), qoeScore < threshold {
                        SpotLightsManager.shared.configureSpotlightsForDeadZone()
                    } else {
                        SpotLightsManager.shared.removeSpotlightForDeadZone()
                    }
                } else {
                    SpotLightsManager.shared.removeSpotlightForDeadZone()
                }
            }
        }
    }
    
    func isShowDeadZoneSpotlight() -> Bool {
        if let deadZoneDate = PreferenceHandler.getValuesForKey("DeadZoneDate") as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = .init(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
            let savedDate = dateFormatter.date(from: deadZoneDate)
            let futureDate = Calendar.current.date(byAdding: .day, value: Int(ConfigService.shared.deadSpotInterval) ?? 60, to: savedDate ?? Date())!
            if dateFormatter.string(from: Date()) == dateFormatter.string(from: futureDate) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    
    
    
    // MARK: - Maui Re-auth
    func getInterceptor() -> RequestInterceptor? {
        return QuickPayManager.shared.interceptor
    }
    
    func refreshMaui() {
        self.displayLoadingAfterLogin(isAutoLogin: true)
        self.mauiAccoutsListRequest(self.dispatchGroupQueue)
    }
    
    func validateFailureCodeToUpdateErrrMsg(code: Int) {
        switch code {
        case 401:
            showLoginScreen(needErrorMessage: false)
        default :
            callMetricsForError()
            showLoginScreen(needErrorMessage: true)
        }
    }
    
    func loadSalutationView() {
        if self.greetingSalutationView == nil {
            let loadingView = GreetingSalutaionView.instanceFromNib()
            self.greetingSalutationView = loadingView
            self.greetingSalutationView?.loginDelegate = self
        }
        guard let loadingScreen = self.greetingSalutationView else {
            return
        }
        self.setNeedsStatusBarAppearanceUpdate()
        loadingScreen.salutationLabel.isHidden = true
        loadingScreen.salutationAnimation.isHidden = true
        loadingScreen.salutationLabel.alpha = 0
        self.view.addSubview(self.greetingSalutationView ?? UIView())
        loadingScreen.translatesAutoresizingMaskIntoConstraints = false
        loadingScreen.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        loadingScreen.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        loadingScreen.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        loadingScreen.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    func displayLoadingAfterLogin(isAutoLogin: Bool) {
        DispatchQueue.main.async {
            if self.usernameTextField != nil {
                self.savedUserNameTextField = self.usernameTextField
                self.usernameTextField.removeFromSuperview()
                self.usernameTextField = nil
            }
            if self.passwordTextField != nil {
                self.savedPasswordTextField = self.passwordTextField
                self.passwordTextField.removeFromSuperview()
                self.passwordTextField = nil
            }
            if self.greetingSalutationView == nil {
                self.loadSalutationView()
            }
            if !isAutoLogin {
                if self.greetingSalutationView != nil {
                    self.greetingSalutationView?.isHidden = false
                    self.greetingSalutationView?.showSalutationAnimation()
                    self.resetPostLoginScreen(true, username: "", password: "")
                }
            } else {
                if self.greetingSalutationView != nil {
                    self.greetingSalutationView?.showSalutationAnimation()
                }
            }
        }
    }
    
    func resetPostLoginScreen(_ hide: Bool, username: String, password: String) {
        if !hide {
            self.postLoginPasswordLabelTopConstraint.constant = 30.0
        }
        self.vwMainContainer.isHidden = !hide
        self.createIDLabel.isHidden = !hide
        self.termsAndConditionsLabel.isHidden = !hide
        self.postLoginPasswordLabel.isHidden = hide
        self.postLoginUserNameLabel.isHidden = hide
        self.postLoginPasswordTextField.isHidden = hide
        self.postLoginUserNameTextField.isHidden = hide
        self.postLoginUserNameTextField.text = username
        self.postLoginPasswordTextField.text = password
    }

    // MARK: - IBActions
    
    @IBAction func onSignInAction(_ sender: AnyObject) {
        self.lcErrorHeight.constant = 0
        if signInIsProgress || LoginPreferenceManager.sharedInstance.manualSignInActive == true {
            return
        }
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        if !validateEmptyFields() {
            return
        } else {
            //For Firebase Analytics
           CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_SIGN_IN_FILLED_IN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            self.resetUIOnSignIn()
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        //activityIndicator.startAnimating()
        self.signInIsProgress = true
        LoginPreferenceManager.sharedInstance.saveStartLoginTime()
        params["grant_type"] = "password" as AnyObject?
        params["username"] = self.usernameTextField.text as AnyObject?
        params["username"] = params["username"]?.trimmingCharacters(in: .whitespaces) as AnyObject?
        params ["password"] = self.passwordTextField.text as AnyObject?
        
        if !isMauiReAuth { // CMAIOS-1632
            LoginPreferenceManager.sharedInstance.setInitialLoginTime() // CMAIOS-1480
        }
        self.resetPostLoginScreen(false, username: self.usernameTextField.text!, password: self.passwordTextField.text!)
        AppCheckTokenManager.shared.userName = params["username"] as? String
        self.initiateAppCheck()
    }
    
    private func initiateAppCheck(_ refresh:Bool = false) {
        AppCheckTokenManager.shared.fetchFirebaseTokenAppCheck(forceRefresh: refresh) { token, error in
            if let error = error {
                Logger.info("Initiate App check failed: \(error)", sendLog:"App Check")
#if DEBUG 
                self.initiateLogin(params: self.params)
#endif
            } else if token != nil {
                Logger.info("Initiate App check success with token")
                self.initiateLogin(params: self.params)
            } else {
                Logger.info("Initiate App check failed with empty token", sendLog:"App Check")
                self.initiateLogin(params: self.params)
            }
            
        }
    }
    
    private func initiateLogin(params: [String: AnyObject]) {
        APIRequests.shared.initiateLoginRequest(params) { success, objLoginResponse, error in
            DispatchQueue.main.async {
                //  self.activityIndicator.stopAnimating()
                if success {
                    self.signInIsProgress = false
                    self.signInAnimView.pause()
                    self.signInAnimView.play(fromProgress: self.signInAnimView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        //CMAIOS-2449
                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_READ_ONLY.rawValue
                                                                                   , EVENT_SCREEN_CLASS: self.classNameFromInstance])
                        self.initiateAfterLoginAPICalls(isAutoLogin: false)
                    }
                    self.lcErrorHeight.constant = 0
                    APIRequests.shared.isAccountSignedOut = false
                    LoginPreferenceManager.sharedInstance.manualSignInActive = true
                } else {
                    self.signInFailedAnimation()
                    guard let errorType = objLoginResponse?.error, let errorKey = objLoginResponse?.error_description else {
                        self.errorLabel.text = MyWiFiConstants.check_accounts_later
                        self.lcErrorHeight.constant = 500
                        self.updateConstraintForSmallerScreens(constraintConstant: 20)
                        self.trackTechnicalDifficultyGAEvent() //CMAIOS-2449
                        return
                    }
                    if errorType == "invalid_grant" {
                        self.handleInvalidGrantErrors(error_key: errorKey)
                    }
                }
            }
            //            DispatchQueue.main.async {
            //               // self.actIndSignIn.stopAnimating()
            //                print(objLoginResponse as Any)
            //            }
            
            /// TO-DO: SAVE LOGIN RESPONSE TO USER DEFAULTS
        }
    }
    
    func trackTechnicalDifficultyGAEvent(){
        //CMAIOS-2449
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.LOGIN_ERROR_TECHNICAL_DIFFICULTIES.rawValue
                                                                   , EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    /*
    func initiateMauiLoginForReAuth(params: [String: AnyObject]) {
        APIRequests.shared.initiateMAUITokenRequest(params) { success, response, error in
            DispatchQueue.main.async {
                if success {
                    self.signInIsProgress = false
                    self.signInAnimView.pause()
                    self.signInAnimView.play(fromProgress: self.signInAnimView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self.dismiss(animated: true) {
                            QuickPayManager.shared.showAppropriteScreenAfterReAuth()
                        }
                    }
                    self.lcErrorHeight.constant = 0
                } else {
                    self.signInFailedAnimation()
                    guard let errorType = response?.error, let errorKey = response?.error_description else {
                        self.errorLabel.text = MyWiFiConstants.check_accounts_later
                        self.lcErrorHeight.constant = 500
                        return
                    }
                    if errorType == "invalid_grant" {
                        self.handleInvalidGrantErrors(error_key: errorKey)
                    }
                }
            }
        }
    }
    */
    
    @IBAction func showHideButtonAction(sender:UIButton) {
       //sender.isSelected = !sender.isSelected
        if passwordTextField == nil {
            return
        }
        if sender.isSelected {
            self.showHidePassImgView.image = UIImage.init(named: "show_Password")
            passwordTextField.isSecureTextEntry = true
        } else {
            self.showHidePassImgView.image = UIImage.init(named: "hide_password")
            passwordTextField.isSecureTextEntry = false
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func forgotUserID(_ sender: AnyObject) {
        self.navigateToInAppBrowser(ConfigService.shared.forgotUserIdURL, title: "")
    }
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
        self.navigateToInAppBrowser(ConfigService.shared.forgotPasswordURL, title: "")
    }
    
    // MARK: - Validations and Login Error Handling
    func handleInvalidGrantErrors(error_key: String) {
        if error_key == InvalidGrant.active_temp_password.rawValue || error_key == InvalidGrant.expired_temp_password.rawValue {
            self.isPasswordExpired = (error_key == InvalidGrant.expired_temp_password.rawValue) ? true : false
            self.navigateToTemporaryPassword()
        } else {
            // clear text fields
            handleClearFields(errorType: InvalidGrant(rawValue: error_key) ?? .default)
            
            // show error message
            let message = LoginErrorMessages.getMessage(forKey: InvalidGrant(rawValue: error_key) ?? .default)
            if usernameTextField == nil || passwordTextField == nil {
                return
            }
            displayError(message: message, for: [usernameTextField,passwordTextField])
            //For Firebase Analytics
            switch error_key {
            case InvalidGrant.invalid_credentials.rawValue :
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_ERROR_INCORRECT_ID_OR_PASSWORD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
                
            case InvalidGrant.invalid_credentials_2_left.rawValue :
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_ERROR_ACCOUNT_LOCKED_AFTER_2_MORE_ATTEMPTS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            case InvalidGrant.toomanyloginfailures.rawValue :
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AFTER_6_ATTEMPTS.rawValue
                                                                           , EVENT_SCREEN_CLASS: self.classNameFromInstance])
            default :
                break
            }
        }
    }
    
    func handleClearFields(errorType: InvalidGrant) {
        if passwordTextField == nil {
            return
        }
        switch errorType {
            // Clear password but retain username
        case .invalid_credentials, .invalid_credentials_1_left, .invalid_credentials_2_left, .toomanyloginfailures:
           // usernameTextField.text = ""
            passwordTextField.text = ""
            // Clear password, retain username
        case .active_temp_password, .expired_temp_password:
            passwordTextField.text = ""
        default:
           // usernameTextField.text = ""
            passwordTextField.text = ""
        }
    }
    
    func validateEmptyFields() -> Bool {
        if usernameTextField.text?.isEmpty ?? true && passwordTextField.text?.isEmpty ?? true {
            displayError(message: "Please enter your Optimum ID and Password", for: [usernameTextField,passwordTextField])
            errorIconTopConstraint.constant = 14
            //For Firebase Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_ERROR_ENTER_ID_AND_password.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            return false
        } else if usernameTextField.text?.isEmpty ?? true {
           errorIconTopConstraint.constant = 14
            displayError(message: "Please enter your Optimum ID", for: [usernameTextField])
            //For Firebase Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_ERROR_NO_ID.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            return false
        } else if passwordTextField.text?.isEmpty ?? true {
            errorIconTopConstraint.constant = 14
            displayError(message: "Please enter your password", for: [passwordTextField])
            //For Firebase Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_ERROR_NO_PASSWORD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            return false
        }
        errorIconTopConstraint.constant = 20
        return true
    }
    
    func displayError(message: String, for textFields: [FloatLabelTextField]) {
        if textFields.count == 1 {
            if textFields[0] == usernameTextField {
                usernameTextField.setBorderColor(mode: .error_color)
                passwordTextField.setBorderColor(mode: .deselcted_color)
                changePlaceholderColor(textField: usernameTextField, color: errorColor)
                changePlaceholderColor(textField: passwordTextField, color: .placeholderText)
            } else if textFields[0] == passwordTextField {
                passwordTextField.setBorderColor(mode: .error_color)
                usernameTextField.setBorderColor(mode: .deselcted_color)
                changePlaceholderColor(textField: passwordTextField, color: errorColor)
                changePlaceholderColor(textField: usernameTextField, color: .placeholderText)
            }
        } else {
            for textField in textFields {
                textField.setBorderColor(mode: BorderColor.error_color)
                changePlaceholderColor(textField: textField, color: errorColor)
            }
        }
        errorLabel.text = message
        lcErrorHeight.constant = 500
        self.updateConstraintForSmallerScreens(constraintConstant: 20)
    }
    
    func changePlaceholderColor(textField: FloatLabelTextField, color: UIColor) {
        let placeholderText = (textField == usernameTextField) ? "Optimum ID" : "Password"
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
    func navigateToWhatsNewScreen() {
        WhatsNewManager.shared.downloadJsonwhatsNew() { success, error in
            if success {
                DispatchQueue.main.async {
                    let whatsnewScreen = UIStoryboard(name: "WhatsNew", bundle: nil).instantiateViewController(identifier: "whatsNewViewController") as WhatsNewViewController
                    self.navigationController?.pushViewController(whatsnewScreen, animated: true)
                }
            } else{
                DispatchQueue.main.async {
                    if self.navigationController?.visibleViewController?.classNameFromInstance == HomeScreenViewController.classNameFromType {
                        return // Return if home screen is already navigated once.
                    }
                    let homeVC = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(identifier: "HomeScreen") as HomeScreenViewController
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
            }
        }
    }
    func prepareNextScreen() {
        canNavigateToNextScreen = false
        if MyWifiManager.shared.accountsNetworkPoints == nil { // If Map is nil in Accounts API reponse, LightSpeed API shouldn't be triggered
            self.navigateToHomeScreen()
            return
        }
        ProfileManager.shared.getProfiles() { [weak self] result in
            switch result {
            case let .success(profiles):
                DispatchQueue.main.async {
                    guard profiles.isEmpty == true || enableFirstUserExperience else {
                        // pass in profiles to the user
                        self?.navigateToHomeScreen()
                        return
                    }
                    self?.navigateToFirstUserFlow()
                }
                
            case let .failure(error):
                DispatchQueue.main.async {
                    //CMA-559
                    if MyWifiManager.shared.getIsMasterProfileCreated() {
                        self?.navigateToHomeScreen()
                    } else {
                        self?.navigateToFirstUserFlow()
                    }
                }
                Logger.info("Lightspeed Profile Request Failed:\n \(error)")
            }
        }
    }
    
    /// If user de-auth  ==  DE_AUTH_STATE_DEAUTH (account blocked  screen should be shown)
    /// If user de-auth is not  DE_AUTH_STATE_DEAUTH  fallback to the  next screen
    func checkUserBlockedForNonPayment() {
        if paymentSharedManager.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" {
            presentAccountBlockedScreen()
        } else {
            self.prepareNextScreen()
        }
    } 
    
    func setConstraintsForPassword() {
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: passwordSuperView.safeAreaLayoutGuide.topAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordSuperView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordSuperView.safeAreaLayoutGuide.trailingAnchor, constant: 2),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordSuperView.centerYAnchor)
        ])
    }
    func setConstraintsForUsername() {
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: userNameSuperView.safeAreaLayoutGuide.topAnchor),
            usernameTextField.leadingAnchor.constraint(equalTo: userNameSuperView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: userNameSuperView.safeAreaLayoutGuide.trailingAnchor, constant: 2),
            usernameTextField.centerYAnchor.constraint(equalTo: userNameSuperView.centerYAnchor)
        ])
    }
    
    func configureUI() {
        self.addTextFields()
        self.usernameTextField.titleYPadding = 14
        self.passwordTextField.titleYPadding = 14
        
        self.usernameTextField.hintYPadding = 0
        self.passwordTextField.hintYPadding = 0
        
       // self.passwordTextField.isSecureTextEntry = false
        let passwordRuleDescription = "minlength: 1;"
        let passwordRules = UITextInputPasswordRules(descriptor: passwordRuleDescription)
        passwordTextField.passwordRules = passwordRules
        switch isMauiReAuth {
        case true:
            self.view.backgroundColor = .systemBackground
            self.labelScreenTitle.text = "To protect your most sensitive information, please sign in again"
            self.createIDLabel.isHidden = true
            self.lcSaveButtonBottomMaui.priority = UILayoutPriority(999)
            self.lcCreateIdLabel.priority = UILayoutPriority(250)
            setupInitialScreen()
            usernameTextField.setBorderColor(mode: .deselcted_color)
            passwordTextField.setBorderColor(mode: .deselcted_color)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.startLoginStartupAnimation()
            }
            // Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_REAUTH_SCREEN.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        case false:
            self.labelScreenTitle.text = "Let’s get you signed in"
            self.createIDLabel.isHidden = false
            self.lcSaveButtonBottomMaui.priority = UILayoutPriority(250)
            self.lcCreateIdLabel.priority = UILayoutPriority(999)
            if canAutoLogin() {
                self.loadSalutationView()
                initiateAutoLogin()
            } else {
                if let greetingScreen = self.greetingSalutationView {
                    greetingScreen.isHidden = true
                    greetingScreen.removeFromSuperview()
                    self.greetingSalutationView = nil
                    self.setNeedsStatusBarAppearanceUpdate()
                }
                ///Manual Login
                setupInitialScreen()
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.startLoginStartupAnimation()
                }
            }
        }
    }
    
    /// Remove the greeting animation on re-arraning UI for maui token expiry login flow
    func removeGreetingSalutationView() {
        if self.greetingSalutationView != nil {
            self.greetingSalutationView?.isHidden = true
            self.greetingSalutationView?.removeFromSuperview()
            self.greetingSalutationView = nil
            self.setNeedsStatusBarAppearanceUpdate()
        }
        self.passwordTextField.text = ""
        if !signInIsProgress {
            signInFailedAnimation()
        }
    }
    
    func navigateToFirstUserFlow(){
        // Go to onboarding flow
        ProfileManager.shared.isFirstUserExperience = true
        ProfileManager.shared.isFirstUserCompleted = false
        guard let vc = ProfileNameViewController.instantiate() else { return }
        let name = MyWifiManager.shared.getFirstName()
        vc.state = .add(isMaster: true, name: name)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(nav, animated: true, completion: {
            self.navigateToHomeScreen()
        })
    }
    
    // MARK: - Navigation
    func navigateToTemporaryPassword() {
        DispatchQueue.main.async {
            var optId = self.usernameTextField.text ?? ""
            let tempVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "temporaryPassword") as TemporaryPasswordViewController
            tempVC.optimumId = (optId.isEmpty) ? "" : optId.trimmingCharacters(in: .whitespaces)
            tempVC.isTempPasswordExpired = self.isPasswordExpired
            self.navigationController?.pushViewController(tempVC, animated: true)
        }
    }
    
    func navigateToHomeScreen() {
        if let path = Bundle.main.path(forResource: "EquipmentTypes", ofType: "plist"), let equipmentDict = NSDictionary(contentsOfFile: path) {
            MyWifiManager.shared.equipmentTypeDictionary = equipmentDict
        }
        if showWhatsNewScreenEnabled {
            self.showWhatsNewScreenEnabled = false
            self.navigateToWhatsNewScreen()
            return
        }
        DispatchQueue.main.async {
//            QuickPayManager.shared.loginTime = Date.now // CMAIOS-1480
            if self.navigationController?.visibleViewController?.classNameFromInstance == HomeScreenViewController.classNameFromType {
                return // Return if home screen is already navigated once.
            }
            let homeVC = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(identifier: "HomeScreen") as HomeScreenViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
            if !self.loadingView.isHidden {
                self.removeLoaderView()
            }
        }
    }
    
    func presentAccountBlockedScreen() {
        DispatchQueue.main.async {
            let deAuthVewController = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(identifier: "QuickPayDeAuthViewController") as QuickPayDeAuthViewController
            deAuthVewController.modalPresentationStyle = .fullScreen
            deAuthVewController.dismissCallBack = {
                self.dismiss(animated: false) {
                    self.showLoadingView()
                }
            }
            self.present(deAuthVewController, animated: true)
        }
    }
    
    private func showLoadingView() {
//        enableDeAuth = false
//        simulatePastDue = false
        self.loadingView.isHidden = false
        self.view.bringSubviewToFront(self.loadingView)
        self.loadingAnimationView.isHidden = false
        self.showODotAnimation()
        self.initiateAutoLogin()
    }
    
    // MARK: - O dot Animation View
    private func showODotAnimation() {
        loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        loadingAnimationView.backgroundColor = .clear
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.play()
    }
    
    private func removeLoaderView() {
        if !loadingView.isHidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.loadingView.isHidden = true
                self.loadingAnimationView.stop()
                self.loadingAnimationView.isHidden = true
            }
        }
    }
}

// MARK: - TextField Delegates
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            let userNameLength = self.usernameTextField.text?.utf8.count
            let passwordLength = self.passwordTextField.text?.utf8.count
            if (userNameLength! > 0 && passwordLength! == 0) || (userNameLength == 0 && passwordLength! > 0) || (userNameLength! == 0 && passwordLength! == 0) {
                self.usernameTextField.becomeFirstResponder()
                textField.returnKeyType = .next
            } else {
                if textField.returnKeyType == .go {
                    self.onSignInAction(UIButton())
                }
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let userNameLength = self.usernameTextField.text?.utf8.count ?? 0
        let passwordLength = self.passwordTextField.text?.utf8.count ?? 0
        
        if (textField == usernameTextField && passwordLength > 0) || (textField == passwordTextField && userNameLength > 0) {
            // below 2 statements fixes - CMAIOS-1822 and 1803 resp.
//            lcErrorHeight.constant = 0
            self.updateConstraintForSmallerScreens(constraintConstant: 38)
        }
        
        if textField == usernameTextField {
            usernameTextField.setBorderColor(mode: .selected_color)
            changePlaceholderColor(textField: usernameTextField, color: .placeholderText)
            if passwordTextField.getBorderColor() == .selected_color {
                passwordTextField.setBorderColor(mode: .deselcted_color)
                changePlaceholderColor(textField: passwordTextField, color: .placeholderText)
            }
        } else if textField == passwordTextField {
            passwordTextField.setBorderColor(mode: .selected_color)
            changePlaceholderColor(textField: passwordTextField, color: .placeholderText)
            if usernameTextField.getBorderColor() == .selected_color {
                usernameTextField.setBorderColor(mode: .deselcted_color)
                changePlaceholderColor(textField: usernameTextField, color: .placeholderText)
            } else if userNameLength > 0 && usernameTextField.getBorderColor() == .error_color {
                usernameTextField.setBorderColor(mode: .deselcted_color)
                changePlaceholderColor(textField: usernameTextField, color: .placeholderText)
            }
        }
       
        if userNameLength > 0 && passwordLength > 0 {
            textField.returnKeyType = .go
            textField.reloadInputViews()
        } else {
            textField.returnKeyType = .next
            textField.reloadInputViews()
        }
    }
    
    // Enable/show the signin Button only on insertion of atleast 1 character in both fields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var userNameLength = self.usernameTextField.text?.utf8.count ?? 0
        var passwordLength = self.passwordTextField.text?.utf8.count ?? 0
        if textField == self.usernameTextField {
            userNameLength = (self.usernameTextField.text?.utf8.count)! - range.length + string.utf16.count
        } else if textField == self.passwordTextField {
            passwordLength = (self.passwordTextField.text?.utf8.count)! - range.length + string.utf16.count
        }
        
        // Change Go & Next button on Keyboard
        if (userNameLength > 0 && passwordLength > 0) && textField.returnKeyType != .go {
            textField.returnKeyType = .go
            textField.reloadInputViews()
        } else if (!(userNameLength > 0) || !(passwordLength > 0)) && textField.returnKeyType == .go {
            resetKeyboard()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetKeyboard()
        return true
    }

}

// MARK: - SFSafariViewController Delegates
extension LoginViewController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser(_ URLString : String, title : String) {

            let safariVC = SFSafariViewController(url: URL(string: URLString)!)
            safariVC.delegate = self
            
            //make status bar have default style for safariVC
            
            self.present(safariVC, animated: true, completion:nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //make status bar have light style since going back to UIApplication
    }
}
// MARK: - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    func salutationAnimationDidCompleted() {
        if canNavigateToNextScreen {
            validateNextScreen()
        }
    }
}
