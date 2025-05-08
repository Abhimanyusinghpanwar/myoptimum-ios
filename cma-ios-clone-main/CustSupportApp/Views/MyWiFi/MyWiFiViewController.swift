//
//  MyWiFiViewController.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 13/07/22.
//

import UIKit
import Lottie
import Shift
import Combine
import ASAPPSDK

enum MyWiFiStatusModel {
    case offline
    case online
    case extender_weak
    case extender_offline
    case be_failure
}

class MyWiFiViewController: UIViewController {
    
    //View Outlet Connections
    @IBOutlet weak var vwFullBackground: UIView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwBgFixBtn: UIView!
    @IBOutlet weak var vwClossBtn: UIView!
    @IBOutlet weak var vwWiFiDetails: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblWiFiName: UILabel!
    @IBOutlet weak var lblWiFiPassword: UILabel!
    //ImageView Outlet Connections
    @IBOutlet weak var imgViewWifi: UIImageView!
    @IBOutlet weak var imgViewPwd: UIImageView!
    //Animation Outlet Connections
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    //Button Outlet Connections
    @IBOutlet weak var btnFix: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnMoreOptions: UIButton!
    @IBOutlet weak var btnViewMyNetwork: UIButton!
    @IBOutlet weak var btnTroubleShootMyInternet: UIButton!
    //Constraint Outlet Connections
    @IBOutlet weak var vwClossBtnHeigth: NSLayoutConstraint!
    @IBOutlet weak var vwClossBottom: NSLayoutConstraint!
    @IBOutlet weak var viewAnimationTop: NSLayoutConstraint!
    @IBOutlet weak var lblContentHeight: NSLayoutConstraint!
    @IBOutlet weak var lblContentWidth: NSLayoutConstraint!
    @IBOutlet weak var viewAnimationHeight: NSLayoutConstraint!
    @IBOutlet weak var viewAnimationWidth: NSLayoutConstraint!
    //Implementing now
    @IBOutlet weak var btnMoreOptionsBottom: NSLayoutConstraint!
    @IBOutlet weak var vwWiFiDetailsTop: NSLayoutConstraint!
    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet weak var vwContainerTop: NSLayoutConstraint!
    @IBOutlet weak var lblContentTop: NSLayoutConstraint!
    @IBOutlet weak var lblContentHorizontal: NSLayoutConstraint!
    @IBOutlet weak var wifiImgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnFixBorderWidth: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    var forBillingFailure: Bool = false
    var outageTitle : OutageDescription?//CMAIOS-2399
    //Animation Properties
    let transition = MyWifiTransitionDelegate()
    var shiftID:String = ""
    var delegate:DismissingChildViewcontroller?
    var extenderStatusName = ""
    var networkName:String = ""
    var stillCheckingWifiStatus = false
    var homeScreenWillAppear = false
    @IBOutlet weak var animationCircleStaticImg: UIImageView!
    //this boolean will restrict two animations from running simultaneously during transition
    var isTransitionAnimationGoingOn:Bool = false
    var animationViewTop: CGFloat = {
        return CurrentDevice.forLargeSpotlights() ? 30.0 : 0.0
    }()
    @IBOutlet weak var closeBtnImgY: NSLayoutConstraint!
    var qualtricsAction : DispatchWorkItem?
    enum NetworkTheme {
        case backendIssuesTheme
        case onlineTheme
        case offlineTheme
        case extendersOfflineTheme
        case weakTheme
    }
    lazy var currentWifiStatus: MyWifiStates = {
        let state = MyWifiManager.shared.getMyWifiStatus()
        return state
    }()
    private var cancellables: Set<AnyCancellable> = []
    var isChatBtnClicked = false
    var dismissCallBack: ((Bool) -> Void)? //CMAIOS-2461
    var outageCardData: SpotLightCardsGetResponse.CardData? //CMAIOS-2399, 2596
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTransition()
    }
    
    func setupTransition() {
        transitioningDelegate = transition
        modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //CMAIOS-2399, 2596
        if forBillingFailure {
            self.btnFix.setTitle("", for: .normal)
            return
        }
        
        if self.outageTitle != nil {
            setAttributesForFailureTheme()
            return
        }
        // Do any additional setup after loading the view.
   //     observeLiveTopologyState()
        initialUIConstants()
        setupTransition()
        setUpUIAttributes()
        setUpUITexts()
        initiatePullToRefresh()
        let goToEditScreen = UITapGestureRecognizer(target: self, action: #selector(self.goToEditScreen(_:)))
       self.imgViewPwd.addGestureRecognizer(goToEditScreen)
        
        let goToEditScreenFirst = UITapGestureRecognizer(target: self, action: #selector(self.goToEditScreen(_:)))
        self.lblWiFiName.addGestureRecognizer(goToEditScreenFirst)
        let goToEditScreenSecond = UITapGestureRecognizer(target: self, action: #selector(self.goToEditScreen(_:)))
        self.lblWiFiPassword.addGestureRecognizer(goToEditScreenSecond)
        NotificationCenter.default.addObserver(self, selector: #selector(lightSpeedAPINotificationCenter(notification:)), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.fallBackForLTNotificationObserver(duration: 3.0)
    }
    
    //CMAIOS-2399,CMAIOS-2596
    func setAttributesForFailureTheme(){
        setupTransition()
        view.shift.id = shiftID
        shift.baselineDuration = 0.2
        self.btnFix.setTitle("", for: .normal)
    }
    
    func showFailureTheme(){
        if forBillingFailure {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : BillPayEvents.BILLING_NOT_AVAILABLE_SCREEN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue])
            self.setFailureTheme()
            return
        }
        //CMAIOS-2399, CMAIOS-2596
        if self.outageTitle != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.setFailureTheme()
            })
            return
        }
    }
    
    func fallBackForLTNotificationObserver(duration: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if self.lblContent.text == "Still checking your WiFi status" && MyWifiManager.shared.lightSpeedAPIState == .opCallInProgress {
                self.fallBackForLTNotificationObserver(duration: 3.0)
            } else if self.lblContent.text == "Still checking your WiFi status" && MyWifiManager.shared.lightSpeedAPIState != .opCallInProgress {
                if MyWifiManager.shared.isOperationalStatusOnline == false || MyWifiManager.shared.lightSpeedAPIState == .failedOperationalStatus {
                    self.showMyWifiStatus()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isChatBtnClicked { //CMAIOS-2461
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            self.dismissCallBack?(self.isChatBtnClicked)
            return
        }
        //CMAIOS-2399,2596
        if forBillingFailure || self.outageTitle != nil {
            showFailureTheme()
            return
        }
        MyWifiManager.shared.isFromHealthCheck = false
        MyWifiManager.shared.isFromSpeedTest = false
        MyWifiManager.shared.isCloseButtonClicked = false
        hideScreenControls(false)
        self.animationCircleStaticImg.isHidden = true
        self.animationCircleStaticImg.transform = .identity
        self.updateSSID()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSSID), name:NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
        self.showMyWifiStatus()
//        NotificationCenter.default.addObserver(self, selector: #selector(lightSpeedAPINotificationCenter(notification:)), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
//        if WifiConfigValues.shared.isWifiRunningSmoothly {
//            myWifiLightSpeedAPI(isBEFailure: false)
//        } else if !WifiConfigValues.shared.isLiveTopology, let status =  WifiConfigValues.shared.cmStatusString as Bool?, !status {
//            myWifiLightSpeedAPI(isBEFailure: true)
//        } else if !(WifiConfigValues.shared.isLiveTopology), let status =  WifiConfigValues.shared.cmStatusString as Bool?, status {
//            if let object = WifiConfigValues.shared.isLiveTopologySuccess as Bool? {
//                if object {
//                    myWifiLightSpeedAPI(isBEFailure: false)
//                } else {
//                    myWifiLightSpeedAPI(isBEFailure: true)
//                }
//            }
//        } else if !(WifiConfigValues.shared.isLiveTopology), let status =  WifiConfigValues.shared.cmStatusString as Bool?, !status {
//            setNetworkName()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if forBillingFailure {
            return
        }
        self.trackGAAction()//CMAIOS-2559
    }

    //CMAIOS-2559
    func trackGAAction(){
        var eventName = ""
        var fixed = ""
        if self.outageTitle != nil {
            switch self.outageTitle {
            case .OutageMyWifi:
                eventName = WiFiManagementScreenDetails.WIFI_HOMEPAGE_OUTAGE.rawValue
                fixed = Fixed.General.rawValue
            case .OutageTvHomePage:
                eventName = TVStreamTroubleshooting.TV_HOMEPAGE_OUTAGE.rawValue
                fixed = Fixed.General.rawValue
            case .none:
                break
            }
        } else {
            eventName = WiFiManagementScreenDetails.WIFI_MYWIFI.rawValue
            fixed = Fixed.Data.rawValue
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME : eventName,
                                                                   CUSTOM_PARAM_FIXED : fixed,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                   CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue,
                                                                    EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func showMyWifiStatus() {
        var status = MyWifiManager.shared.getMyWifiStatus()
        self.currentWifiStatus = status
        view.shift.id = shiftID
        shift.baselineDuration = 0.2
        self.setupAnimationUI(showScreen: true, isEditwifi: false)
        if MyWifiManager.shared.reCallFromMyWifiJumpLink == true {
            MyWifiManager.shared.reCallFromMyWifiJumpLink = false
            self.liveTopCallInProgressUI()
            return
        }
        if MyWifiManager.shared.accountsNetworkPoints == nil { // If Map is nil in Accounts API reponse, LightSpeed API shouldn't be triggered
            status = .backendFailure
        }
        switch status {
        case .backendFailure:
            self.lblContentTop.constant = -33
            self.lblContentHeight.constant = 160
            self.lblContent.text = MyWiFiConstants.check_back_later
            self.setThemeFor(themeType: .backendIssuesTheme)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_WIFI_TECHNICAL_DIFFICULTIES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
            
        case .waitToRefresh:
            self.liveTopCallInProgressUI()
            
        case .offlineExtendersFound:
            self.lblContentHeight.constant = 100
            self.lblContentTop.constant = 30
            let offlineExtenders = MyWifiManager.shared.getOfflineExtenders()
            if offlineExtenders.count > 1 {
                self.wifiImgTopConstraint.constant = 78
                self.lblContent.text = "\(offlineExtenders.count)" + MyWiFiConstants.multiple_ext_offline
            } else if offlineExtenders.count == 1 {
                if let extender = offlineExtenders.first {
                    let name = WifiConfigValues.getExtenderName(offlineExtNode: extender, onlineExtNode: nil)
                    self.lblContent.text = "Your " + name + MyWiFiConstants.one_ext_offline
                    let numberofLines = UILabel.countLines(font: self.lblContent.font, text: self.lblContent.text ?? "", width: self.lblContent.frame.size.width, height: self.lblContent.frame.size.height)
                    if numberofLines > 2 {
                        self.wifiImgTopConstraint.constant = 58
                    } else {
                        self.wifiImgTopConstraint.constant = 78
                    }
                }
            }
            self.setThemeFor(themeType: .extendersOfflineTheme)
            
        case .weakExtenderFound:
            self.lblContentHeight.constant = 100
            self.lblContentTop.constant = 30
            let weakExtends = MyWifiManager.shared.getWeakExtenders()
            if weakExtends.count > 1 {
                self.wifiImgTopConstraint.constant = 78
                self.lblContent.text = "\(weakExtends.count)" + MyWiFiConstants.multiple_ext_weak
            } else if weakExtends.count == 1 {
                if let extender = weakExtends.first {
                    let name = WifiConfigValues.getExtenderName(offlineExtNode: extender, onlineExtNode: nil)
                    self.lblContent.text = "Your " + name + MyWiFiConstants.one_ext_weak
                    let numberofLines = UILabel.countLines(font: self.lblContent.font, text: self.lblContent.text ?? "", width: self.lblContent.frame.size.width, height: self.lblContent.frame.size.height)
                    if numberofLines > 2 {
                        self.wifiImgTopConstraint.constant = 58
                    } else {
                        self.wifiImgTopConstraint.constant = 78
                    }
                }
            }
            self.setThemeFor(themeType: .weakTheme)
            
        case .runningSmoothly:
            self.lblContentHeight.constant = 100
            self.lblContentTop.constant = 30
            if MyWifiManager.shared.getWifiType() != "Modem" {
                self.lblContent.text = MyWiFiConstants.wifi_smoothly
            } else {
                self.lblContent.text = MyInternetConstants.internet_smoothly
            }
            self.setThemeFor(themeType: .onlineTheme)
        case .wifiDown:
            setNetworkName()
            self.lblContentHeight.constant = 100
            self.lblContentTop.constant = 30
            if MyWifiManager.shared.getWifiType() != "Modem" {
                self.wifiImgTopConstraint.constant = 78
                self.lblContent.text = self.networkName + MyWiFiConstants.wifi_down
            } else {
                self.wifiImgTopConstraint.constant = 60
                self.lblContent.text =  MyInternetConstants.internet_down
            }
            self.setThemeFor(themeType: .offlineTheme)
        }
        if status != .waitToRefresh && qualtricsAction == nil{
            self.qualtricsAction = self.checkQualtrics(screenName: WiFiManagementScreenDetails.WIFI_MYWIFI.rawValue, dispatchBlock: &qualtricsAction)
        }
        updateLblContentConstraint()
    }
    
    func updateLblContentConstraint() {
        if forBillingFailure {
            let status = MyWifiManager.shared.getMyWifiStatus()
            
            if status == .waitToRefresh || status == .backendFailure {
                self.lblContentTop.priority = UILayoutPriority(250)
                self.lblContentHorizontal.priority = UILayoutPriority(1000)
            } else {
                self.lblContentTop.priority = UILayoutPriority(1000)
                self.lblContentHorizontal.priority = UILayoutPriority(250)
            }
        } else {
            self.lblContentTop.priority = UILayoutPriority(1000)
            self.lblContentHorizontal.priority = UILayoutPriority(250)
        }
        self.view.layoutIfNeeded()
    }
    
    func setFailureTheme() {
        self.lblContent.isHidden = false
        self.lblContent.textColor = .white
        self.lblContent.font = UIFont(name: "Regular-Medium", size: 22)
        btnFix.titleLabel?.font = UIFont(name: "Regular-Bold", size: 16)
        self.btnFix.setTitleColor(.white, for: .normal)
        if forBillingFailure {
            self.lblContent.text = "Sorry, My Bill is not available right now. Check back later."
            self.lblContentTop.constant = -30
            btnFix.setTitle("Chat with us", for: .normal)
            self.btnFixBorderWidth.constant = 130.0
        } else {
            self.lblContentTop.constant = -40
            self.lblContentWidth.constant = 200
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 0.98
            paragraphStyle.alignment = .center
            self.lblContent.attributedText = NSMutableAttributedString(string: self.outageTitle?.rawValue ?? "", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            btnFix.setTitle("More info", for: .normal)
            self.btnFixBorderWidth.constant = 106.0
        }
        self.vwBgFixBtn.isHidden = false
        self.btnFix.isHidden = false
        self.vwFullBackground.backgroundColor = midnightBlueRGB
        self.vwClossBtn.backgroundColor = midnightBlueRGB
        self.animationCircleStaticImg.image = UIImage(named: "animation_circle_red")
        self.animationCircleStaticImg.isHidden = false
        setBorderView(view: self.vwBgFixBtn, borderWidth: 1.5, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1))
        self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
        self.viewAnimation.isUserInteractionEnabled = true
        self.viewAnimation.isHidden = false
        self.imgViewWifi.isHidden = true
        self.vwWiFiDetails.isHidden = true
        self.btnMoreOptions.isHidden = true
        self.btnViewMyNetwork.isHidden = true
        self.btnTroubleShootMyInternet.isHidden = true
        self.imgViewWifi.isHidden = true
        updateLblContentConstraint()
    }
    
    func setThemeFor(themeType:NetworkTheme) {
        var hideUsernamePassword = false
        var hideMenuButtons = false
        var hideAllItemsInsideCircle = false
        var animationName = ""
        switch themeType {
        case .offlineTheme:
            hideUsernamePassword = true
            hideMenuButtons = true
            hideAllItemsInsideCircle = false
            self.vwFullBackground.backgroundColor = midnightBlueRGB
            self.vwClossBtn.backgroundColor = midnightBlueRGB
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_red")
            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
            animationName = "WiFiCirclePulseOffline"
            self.imgViewWifi.image = UIImage(named: "icon_wifi_red")
            self.handleUIWithScreenSize(isBEFailure: false)
            //navigate to troubleshooting
            self.setTapActionForTroubleshooting()
        case .backendIssuesTheme:
            hideUsernamePassword = true
            hideMenuButtons = true
            hideAllItemsInsideCircle = true
            self.vwFullBackground.backgroundColor = midnightBlueRGB
            self.vwClossBtn.backgroundColor = midnightBlueRGB
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_red")
            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
            animationName = "WiFiCirclePulseOffline"
            self.handleUIWithScreenSize(isBEFailure: true)
        case .onlineTheme:
            hideUsernamePassword = false
            hideMenuButtons = false
            hideAllItemsInsideCircle = false
            self.vwFullBackground.backgroundColor = energyBlueRGB
            self.vwClossBtn.backgroundColor = energyBlueRGB
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_white")
            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseDefault")
            animationName = "WiFiCirclePulseDefault"
            self.imgViewWifi.image = UIImage(named: "icon_wifi_white")
            self.handleUIWithScreenSize(isBEFailure: false)
            //navigate to ViewMyNetwork
            self.setTapActionForAnimationView()
        case .extendersOfflineTheme:
            hideUsernamePassword = false
            hideMenuButtons = false
            hideAllItemsInsideCircle = false
            self.vwFullBackground.backgroundColor = midnightBlueRGB
            self.vwClossBtn.backgroundColor = midnightBlueRGB
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_red")
            self.imgViewWifi.image = UIImage(named: "icon_wifi_red")
            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
            animationName = "WiFiCirclePulseOffline"
            self.handleUIWithScreenSize(isBEFailure: false)
            //navigate to troubleshooting
            self.setTapActionForTroubleshooting()
        case .weakTheme:
            hideUsernamePassword = false
            hideMenuButtons = false
            hideAllItemsInsideCircle = false
            self.vwFullBackground.backgroundColor = midnightBlueRGB
            self.vwClossBtn.backgroundColor = midnightBlueRGB
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_red")
            self.imgViewWifi.image = UIImage(named: "icon_wifi_orange")
            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseWeak")
            animationName = "WiFiCirclePulseWeak"
            self.handleUIWithScreenSize(isBEFailure: false)
            //navigate to troubleshooting
            self.setTapActionForTroubleshooting()
        }
        if !hideUsernamePassword {
            if lblWiFiName.text?.isEmpty == true || lblWiFiPassword.text?.isEmpty == true {
                self.vwWiFiDetails.isHidden = true
            } else {
                self.vwWiFiDetails.isHidden = false
                self.lblWiFiName.isUserInteractionEnabled = true
                let goToEditScreenFromNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToEditScreen(_:)))
                self.lblWiFiName.addGestureRecognizer(goToEditScreenFromNameLabel)
                let goToEditScreenPwdLabel = UITapGestureRecognizer(target: self, action: #selector(self.goToEditScreen(_:)))
                self.lblWiFiPassword.addGestureRecognizer(goToEditScreenPwdLabel)
            }
        } else {
            self.vwWiFiDetails.isHidden = true
        }
        self.btnMoreOptions.isHidden = hideMenuButtons
        if MyWifiManager.shared.getWifiType() != "Modem" {
            self.btnViewMyNetwork.isHidden = hideMenuButtons
        } else {
            self.btnViewMyNetwork.isHidden = true
        }
        self.btnTroubleShootMyInternet.isHidden = hideMenuButtons
        self.imgViewWifi.isHidden = hideAllItemsInsideCircle
        self.vwBgFixBtn.isHidden = hideAllItemsInsideCircle
        if themeType == .onlineTheme {
            self.vwBgFixBtn.isHidden = true
        }
        self.btnFix.isHidden = hideAllItemsInsideCircle
        
        self.viewAnimation.backgroundColor = .clear
        self.viewAnimation.loopMode = .playOnce
        self.viewAnimation.play { _ in
            self.viewAnimation.animation = LottieAnimation.named(animationName)
            self.viewAnimation.loopMode = .loop
            self.viewAnimation.play()
        }
    }
    
    func chatButtonTapped() {
        self.isChatBtnClicked = true
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: .paymentSysytemDown)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return }
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    func liveTopCallInProgressUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(lightSpeedAPINotificationCenter(notification:)), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.stillCheckingWifiStatus = true
        let defaultTime = (MyWifiManager.shared.getWifiType() != "Modem") ? 40.0 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + defaultTime) {
            self.stillCheckingWifiStatus = false
            MyWifiManager.shared.pollingLTNotRequired = true
        }
        self.lblContentHeight.constant = 100
        self.lblContent.text = "Still checking your WiFi status"
        self.btnMoreOptions.isHidden = true
        self.btnViewMyNetwork.isHidden = true
        self.btnTroubleShootMyInternet.isHidden = true
        self.imgViewWifi.isHidden = true
        self.vwBgFixBtn.isHidden = true
        self.btnFix.isHidden = true
        self.vwFullBackground.backgroundColor = energyBlueRGB
        self.vwClossBtn.backgroundColor = energyBlueRGB
        if lblWiFiName.text?.isEmpty == true || lblWiFiPassword.text?.isEmpty == true {
            self.vwWiFiDetails.isHidden = true
        } else {
            self.vwWiFiDetails.isHidden = false
        }
        self.viewAnimation.animation = LottieAnimation.named("WiFiCircleDrawDefault")
        self.viewAnimation.backgroundColor = .clear
        self.viewAnimation.loopMode = .playOnce
        self.viewAnimation.play { _ in
            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseDefault")
            self.viewAnimation.loopMode = .loop
            self.viewAnimation.play()
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_WIFI_INTERIM_STATUS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
    }
    
    @objc func updateSSID() {
        DispatchQueue.main.async {
            // hide PullToRefresh is called in LiveTopology no need here
//            self.pullToRefresh(hideScreen: true)
            if let twoG = MyWifiManager.shared.twoGHome, twoG.allKeys.count > 0 {
                if let ssid = twoG.value(forKey: "SSID") as? String, !ssid.isEmpty,
                   let password = twoG.value(forKey: "password") as? String, !password.isEmpty {
                    self.lblWiFiName.text = ssid
                    if self.vwWiFiDetails.isHidden == true {
                        if self.currentWifiStatus != .backendFailure && self.currentWifiStatus != .wifiDown {
                            self.vwWiFiDetails.alpha = 0.0
                            self.vwWiFiDetails.isHidden = false
                            UIView.animate(withDuration: 0.5) {
                                self.vwWiFiDetails.alpha = 1.0
                            }
                        }
                    }
                    self.lblWiFiPassword.text = password
//                    if MyWiFiStatusModel.offline == .offline {
//                        if let status = WifiConfigValues.shared.cmStatusString as Bool?, !status {
//                            self.networkName = ssid
//                            self.lblContent.text = self.networkName + MyWiFiConstants.wifi_down
//                        }
//                    }
                }
            }
        }
    }
    
    func observeLiveTopologyState() {
        MyWifiManager.shared.$lightSpeedData
            .receive(on: RunLoop.main)
            .sink {[weak self] newLTData in
                if self?.isViewLoaded == true && self?.view.window != nil {
                    /// Refresh Screen
                    self?.hidePullToRefresh()
                }
            }.store(in: &cancellables)
    }
    
    @objc func lightSpeedAPINotificationCenter(notification: NSNotification) {
        if notification.object as! String == "failed" || notification.object as! String == "OP_Offline" {
            stillCheckingWifiStatus = false //Do not poll LT if the OP is returning offline status
            if notification.object as! String == "OP_Offline" {
                MyWifiManager.shared.isOperationalStatusOnline = false //CMAIOS-2866
            }
        }
        if stillCheckingWifiStatus == false {
            MyWifiManager.shared.pollingLTNotRequired = true
            if notification.object as! String != "success" && MyWifiManager.shared.isOperationalStatusOnline == true {
                MyWifiManager.shared.lightSpeedAPIState = .failedLiveTopology
            }
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
            /// Refresh Screen
            DispatchQueue.main.async {
                self.hidePullToRefresh()
            }
        } else { ///Still checking Wifi Status - Retry Live Topology Call
            if notification.object as! String == "success" || MyWifiManager.shared.pollingLTNotRequired == true {
                self.hidePullToRefresh()
            } else {
                APIRequests.shared.restrictLTErrorLogging = true
                APIRequests.shared.performLiveTopologyRequest()
            }
        }
    }
    /*
    @objc func myWifiLightSpeedAPI(isBEFailure:Bool) {
        DispatchQueue.main.async {
            let sampleArray = LiveTopologyStatus.shared.getGateway()
            self.pullToRefresh(hideScreen: true)
            if WifiConfigValues.shared.isWifiRunningSmoothly {
                self.setupAnimationUI(showScreen: true, isEditwifi: false)
                self.handleWiFiUIStatus(statusType: .online)
            } else if !isBEFailure {
                if !sampleArray.isEmpty {
                    let getExtenderStatus = LiveTopologyStatus.shared.getExtenderStatus()
                    if getExtenderStatus.0 == "Online" {
                        self.setupAnimationUI(showScreen: true, isEditwifi: false)
                        self.handleWiFiUIStatus(statusType: .online)
                    } else if getExtenderStatus.0 == "Offline" {
                        if let statusName = getExtenderStatus.1 as String?, !statusName.isEmpty {
                            if !statusName.allSatisfy({$0.isNumber}) {
                                self.extenderStatusName = "Your \(statusName) Extender is offline"
                            } else {
                                self.extenderStatusName = "\(statusName) of your Extenders are offline"
                            }
                        }
                        self.setupAnimationUI(showScreen: true, isEditwifi: false)
                        self.handleWiFiUIStatus(statusType: .extender_offline)
                    } else if getExtenderStatus.0 == "Weak" {
                        if let statusName = getExtenderStatus.1 as String?, !statusName.isEmpty {
                            if !statusName.allSatisfy({$0.isNumber}) {
                                self.extenderStatusName = "Your \(statusName) Extender has a weak signal"
                            } else {
                                self.extenderStatusName = "\(statusName) of your Extenders have a weak signal"
                            }
                        }
                        self.setupAnimationUI(showScreen: true, isEditwifi: false)
                        self.handleWiFiUIStatus(statusType: .extender_weak)
                    } else {
                        self.setupAnimationUI(showScreen: true, isEditwifi: false)
                        self.handleWiFiUIStatus(statusType: .be_failure)
                    }
                } else {
                    self.setNetworkName()
                }
            } else {
                self.setupAnimationUI(showScreen: true, isEditwifi: false)
                self.handleWiFiUIStatus(statusType: .be_failure)
            }
        }
    }*/
    
    ///Method for network name when it is down.
    func setNetworkName() {
        let twoGHome = NSMutableDictionary(dictionary: MyWifiManager.shared.twoGHome ?? ["":""])
        if let networkDict = twoGHome.value(forKey: "SSID") as? NSString {
            networkName = networkDict as String
        } else {
            networkName = "Your"
        }
//        self.setupAnimationUI(showScreen: true, isEditwifi: false)
//        self.handleWiFiUIStatus(statusType: .offline)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if homeScreenWillAppear || APIRequests.shared.isFromChat {
            if APIRequests.shared.isFromChat {
                APIRequests.shared.isFromChat = false
            }
            delegate?.childViewcontrollerGettingDismissed()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.cancellables.removeAll()
        APIRequests.shared.restrictLTErrorLogging = false
        qualtricsAction?.cancel()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isTransitionAnimationGoingOn = false
    }
    
    //MARK: UI Attributes, Text and Status Methods
    func setUpUIAttributes() {
        self.lblContent.textColor = .white
        self.btnFix.setTitleColor(.white, for: .normal)
        self.btnMoreOptions.setTitleColor(.white, for: .normal)
        self.btnViewMyNetwork.setTitleColor(.white, for: .normal)
        self.btnTroubleShootMyInternet.setTitleColor(.white, for: .normal)
        setBorderView(view: self.vwBgFixBtn, borderWidth: 1.5, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1))
    }
    
    func handleUIWithScreenSize(isBEFailure: Bool) {
        if currentScreenWidth < xibDesignWidth && !isBEFailure {
            viewAnimationHeight.constant = 325
            viewAnimationWidth.constant = 325
            viewAnimationHeight.constant = ((viewAnimationHeight.constant/xibDesignHeight)*currentScreenHeight) - 20
            viewAnimationWidth.constant = ((viewAnimationWidth.constant/xibDesignWidth)*currentScreenWidth) - 20
            lblContentWidth.constant = ((viewAnimationWidth.constant/xibDesignWidth)*currentScreenWidth) - 20
            //Fonts:
            lblContent.font = UIFont(name: "Regular-Medium", size: (22.0/xibDesignWidth)*currentScreenWidth)
            lblWiFiName.font = UIFont(name: "Regular-Bold", size: (18.0/xibDesignWidth)*currentScreenWidth)
            lblWiFiPassword.font = UIFont(name: "Regular-Medium", size: (16.0/xibDesignWidth)*currentScreenWidth)
            btnMoreOptions.titleLabel?.font =  UIFont(name: "Regular-Medium", size: (20.0/xibDesignWidth)*currentScreenWidth)
            btnViewMyNetwork.titleLabel?.font =  UIFont(name: "Regular-Medium", size: (20.0/xibDesignWidth)*currentScreenWidth)
            btnTroubleShootMyInternet.titleLabel?.font =  UIFont(name: "Regular-Medium", size: (20.0/xibDesignWidth)*currentScreenWidth)
            btnFix.titleLabel?.font =  UIFont(name: "Regular-Bold", size: (16.0/xibDesignWidth)*currentScreenWidth)
        } else {
            btnViewMyNetwork.titleLabel?.font =  UIFont(name: "Regular-Medium", size: 20)
            btnMoreOptions.titleLabel?.font =  UIFont(name: "Regular-Medium", size: 20)
            btnTroubleShootMyInternet.titleLabel?.font =  UIFont(name: "Regular-Medium", size: 20)
            btnFix.titleLabel?.font =  UIFont(name: "Regular-Bold", size: 16)
            lblContent.font = UIFont(name: "Regular-Medium", size: 22)
            lblWiFiName.font = UIFont(name: "Regular-Bold", size: 18)
            lblWiFiPassword.font = UIFont(name: "Regular-Medium", size: 16)
        }
    }
    
    func setUpUITexts() {
        self.btnFix.setTitle("Let's fix it", for: .normal)
        self.btnViewMyNetwork.setTitle(MyWiFiConstants.view_my_network, for: .normal)
        self.btnTroubleShootMyInternet.setTitle(MyWiFiConstants.trouble_my_internet, for: .normal)
        self.btnMoreOptions.setTitle(MyWiFiConstants.more_options, for: .normal)
        self.btnEdit.setTitle("", for: .normal)
        self.btnClose.setTitle("", for: .normal)
    }
    
   /* /// Method for WiFi Status
    func handleWiFiUIStatus(statusType:MyWiFiStatusModel) {
        viewShiftAnimationSetUp(animationType:statusType)
        switch statusType {
        case .offline:
            self.vwFullBackground.backgroundColor = offlineBgColor
            self.vwClossBtn.backgroundColor = offlineBgColor
            self.handleWifiUI(wifiOfflineStatus: true, beFailureStatus: false, extendStatus: false)
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_white")
            self.handleUIWithScreenSize(isBEFailure: false)
        case .online:
            self.setTapActionForAnimationView()
            self.vwFullBackground.backgroundColor = onlineBgColor
            self.vwClossBtn.backgroundColor = onlineBgColor
            self.handleWifiUI(wifiOfflineStatus: false, beFailureStatus: false, extendStatus: false)
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_white")
            self.handleUIWithScreenSize(isBEFailure: false)
        case .extender_weak:
            self.vwFullBackground.backgroundColor = offlineBgColor
            self.vwClossBtn.backgroundColor = offlineBgColor
            self.handleWifiUI(wifiOfflineStatus: false,beFailureStatus: false, extendStatus: true)
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_white")
            self.handleUIWithScreenSize(isBEFailure: false)
        case .extender_offline:
            self.vwFullBackground.backgroundColor = offlineBgColor
            self.vwClossBtn.backgroundColor = offlineBgColor
            self.handleWifiUI(wifiOfflineStatus: false, beFailureStatus: false, extendStatus: true)
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_white")
            self.handleUIWithScreenSize(isBEFailure: false)
        case .be_failure:
            self.vwFullBackground.backgroundColor = offlineBgColor
            self.vwClossBtn.backgroundColor = offlineBgColor
            self.lblContentHeight.constant = 160
            self.handleWifiUI(wifiOfflineStatus: true, beFailureStatus: true, extendStatus: false)
            self.animationCircleStaticImg.image = UIImage(named: "animation_circle_white")
            self.handleUIWithScreenSize(isBEFailure: true)
        }
    }
    
    func handleWifiUI(wifiOfflineStatus:Bool, beFailureStatus: Bool, extendStatus: Bool) {
        self.vwWiFiDetails.isHidden = wifiOfflineStatus
        self.btnMoreOptions.isHidden = wifiOfflineStatus
        self.btnViewMyNetwork.isHidden = wifiOfflineStatus
        self.btnTroubleShootMyInternet.isHidden = wifiOfflineStatus
        self.imgViewWifi.isHidden = false
        if extendStatus == true {
            self.vwBgFixBtn.isHidden = false
            self.btnFix.isHidden = false
        } else if !beFailureStatus {
            self.vwBgFixBtn.isHidden = wifiOfflineStatus == true ? false : true
            self.btnFix.isHidden = wifiOfflineStatus == true ? false : true
        } else {
            self.imgViewWifi.isHidden = wifiOfflineStatus
            self.vwBgFixBtn.isHidden = wifiOfflineStatus
            self.btnFix.isHidden = wifiOfflineStatus
        }
    }*/
    
    //MARK: Pull to refresh Methods
    ///Method for pull to refresh during swipe.
    func initiatePullToRefresh() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
        self.view?.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    ///Method for pull to refresh animation.
    @objc func pullToRefresh(hideScreen hide:Bool, isComplete: Bool = false) {
        vwPullToRefresh.isHidden = false
        vwPullToRefreshCircle.isHidden = false
        self.vwPullToRefreshAnimation.isHidden = false
        self.vwPullToRefreshAnimation.animation = LottieAnimation.named("AutoLogin")
        self.vwPullToRefreshAnimation.backgroundColor = .clear
        self.vwPullToRefreshAnimation.loopMode = !isComplete ? .loop : .playOnce
        self.vwPullToRefreshAnimation.animationSpeed = 1.0
        if !hide {
            if self.lblContent.text == "Still checking your WiFi status" {
                return // Do not trigger pull to refresh if OP/LT call is in progress
            }
            self.removeButtonAction(isAllowed: false)
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
                self.handleLargeScreenUI(isLargeScreen: currentScreenWidth > 390.0 ? true : false)
                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
                self.vwContainerTop.constant = 130
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                self.removeButtonAction(isAllowed: true)
                UIView.animate(withDuration: 0.5) {
                    self.isPullToRefresh = false
                    self.handleLargeScreenUI(isLargeScreen: currentScreenWidth > 390.0 ? true : false)
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshAnimation.isHidden = true
                    self.vwPullToRefreshTop.constant = 80
                    self.vwPullToRefreshHeight.constant = 0
                    self.vwContainerTop.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    ///Method for button action
    func removeButtonAction(isAllowed: Bool) {
        self.btnEdit.isUserInteractionEnabled = isAllowed
        self.btnFix.isUserInteractionEnabled = isAllowed
        self.btnViewMyNetwork.isUserInteractionEnabled = isAllowed
        self.btnTroubleShootMyInternet.isUserInteractionEnabled = isAllowed
        self.btnMoreOptions.isUserInteractionEnabled = isAllowed
        self.viewAnimation.isUserInteractionEnabled = isAllowed
    }
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        guard let _ = MyWifiManager.shared.deviceMAC, let _ = MyWifiManager.shared.deviceType else {
            //Gateway is offline
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hidePullToRefresh()
            }
            return
        }
        // After Refresh
        if MyWifiManager.shared.accountsNetworkPoints != nil {
            APIRequests.shared.restrictLTErrorLogging = false
            NotificationCenter.default.addObserver(self, selector: #selector(lightSpeedAPINotificationCenter(notification:)), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
            MyWifiManager.shared.triggerOperationalStatus()
        } else {
            // If Map is nil in Accounts API reponse, LightSpeed API shouldn't be triggered
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hidePullToRefresh()
            }
        }
    }
    
    func hidePullToRefresh(){
        self.showMyWifiStatus()
        self.pullToRefresh(hideScreen: true, isComplete: true)
    }
    
    //MARK: Animation Methods
    func initialUIConstants() {
        self.vwClossBottom.constant = 100
        self.vwContainer.alpha = 0.0
        self.handleLargeScreenUI(isLargeScreen: currentScreenWidth > 390.0 ? true : false)
        self.viewAnimationTop.constant = animationViewTop
        self.lblContentHeight.constant = 100
        self.vwFullBackground.backgroundColor = energyBlueRGB
        self.vwClossBtn.backgroundColor = energyBlueRGB
        view.shift.id = shiftID
        shift.baselineDuration = 0.2
        self.vwPullToRefresh.isHidden = true
        vwPullToRefreshCircle.isHidden = true
        self.vwPullToRefreshHeight.constant = 0
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
    }
    func setupAnimationUI(showScreen show:Bool, isEditwifi: Bool) {
        if show {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                UIView.animate(withDuration: 0.4) {
                    if !self.isTransitionAnimationGoingOn {
                        self.vwContainer.alpha = 1.0
                        self.vwClossBottom.constant = 0
                        self.closeBtnImgY.constant = UIDevice.current.hasNotch ? 23 : -10
                        self.viewAnimationTop.constant = self.animationViewTop
                        self.view.layoutIfNeeded()
                    }
                }
            }
        } else {
            self.qualtricsAction?.cancel()
            if shiftID.isEmpty { // When navigating from profile list
                self.dismiss(animated: false, completion: nil)
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.handleLargeScreenUI(isLargeScreen: currentScreenWidth > 390.0 ? true : false)
                self.viewAnimationTop.constant = self.animationViewTop
                self.vwClossBottom.constant = 100
                self.vwContainer.alpha = 0.0
                self.view.layoutIfNeeded()
                if !isEditwifi {
                    self.homeScreenWillAppear = true
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        let editWifiScreen = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditWifi") as! EditWifiViewController
                        editWifiScreen.modalPresentationStyle = .fullScreen
                        self.present(editWifiScreen, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    //MARK: Handling UI for large and small screen
    func handleLargeScreenUI(isLargeScreen:Bool) {
        // safe area adjustment for notch
        self.vwWiFiDetailsTop.constant = UIDevice.current.hasNotch ? 25 : 30
        if isLargeScreen {
            self.btnMoreOptionsBottom.constant = isPullToRefresh ? 0 : 120
        } else {
            self.btnMoreOptionsBottom.constant = isPullToRefresh ? 0 : 110
        }
    }
    func hideScreenControls(_ isHidden: Bool) {
        vwWiFiDetails.isHidden = isHidden
        viewAnimation.isHidden = isHidden
        vwClossBtn.isHidden = isHidden
        btnFix.isHidden = isHidden
        btnEdit.isHidden = isHidden
        btnClose.isHidden = isHidden
        btnMoreOptions.isHidden = isHidden
        if MyWifiManager.shared.getWifiType() != "Modem" {
            btnViewMyNetwork.isHidden = isHidden
        } else {
            btnViewMyNetwork.isHidden = true
        }
        imgViewPwd.isHidden = isHidden
        btnTroubleShootMyInternet.isHidden = isHidden
        lblWiFiName.isHidden = isHidden
        lblWiFiPassword.isHidden = isHidden
    }
    //MARK: Button Actions
    @IBAction func fixBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        if forBillingFailure {
            chatButtonTapped()
            return
        }
        //CMAIOS-2399, 2596
        if self.outageTitle != nil {
            self.navigateToOutageMoreInfo()
            return
        }
        DispatchQueue.main.async {
            self.navigateToFixItAction()
        }
    }

    func navigateToFixItAction() {
        UIView.animate(withDuration: 0.4) {
            self.handleLargeScreenUI(isLargeScreen: currentScreenWidth > 390.0 ? true : false)
            self.viewAnimationTop.constant = self.animationViewTop
            self.vwClossBottom.constant = 100
            self.vwContainer.alpha = 0.0
            self.view.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                switch(MyWifiManager.shared.getMyWifiStatus()) {
                case .wifiDown:
                    let healthCheck = UIStoryboard(name: "HealthCheck", bundle: Bundle.main).instantiateViewController(withIdentifier: "ManualRebootViewController") as! ManualRebootViewController
                    let aNavigationController = UINavigationController(rootViewController: healthCheck)
                    aNavigationController.modalPresentationStyle = .fullScreen
                    self.present(aNavigationController, animated: false, completion: nil)
                case .offlineExtendersFound:
                    //-TroubleshootingExtenders-
                    ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
                    ExtenderDataManager.shared.flowType = .offlineFlow
                    ExtenderDataManager.shared.iTroubleshoot = .troubleshoot
                    ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
                    let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
                    if let offlineExtenderFlowRootScreen = storyboard.instantiateViewController(withIdentifier: "extenderOfflineViewController") as? ExtenderOfflineViewController {
                        offlineExtenderFlowRootScreen.modalPresentationStyle = .fullScreen
                        let navVC = UINavigationController(rootViewController: offlineExtenderFlowRootScreen)
                        navVC.modalPresentationStyle = .fullScreen
                        navVC.setNavigationBarHidden(false, animated: false)
                        self.present(navVC, animated: true)
                    }
                case .weakExtenderFound:
                    ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
                    ExtenderDataManager.shared.flowType = .weakFlow
                    ExtenderDataManager.shared.iTroubleshoot = .troubleshoot
                    ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
                    let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
                    if let weakExtenderFlowRootScreen = storyboard.instantiateViewController(withIdentifier: "goToExtenderOfflineViewController") as? GoToExtenderOfflineViewController {
                        weakExtenderFlowRootScreen.modalPresentationStyle = .fullScreen
                        let navVC = UINavigationController(rootViewController: weakExtenderFlowRootScreen)
                        navVC.modalPresentationStyle = .fullScreen
                        navVC.setNavigationBarHidden(false, animated: false)
                        self.present(navVC, animated: true)
                    }
                default: break
                }
            }
        }
    }

    //CMAIOS-2399, 2596
    func navigateToOutageMoreInfo() {
        self.qualtricsAction?.cancel()
        guard let outageDetails = OutageDetailsVC.instantiateWithIdentifier(from: .Outage) else { return }
        let navigationController = UINavigationController(rootViewController: outageDetails)
        //CMAIOS-2399, CMAIOS-2596 getOutageMoreInfo Details as per JumpLink selection
        outageDetails.screenDetails = self.outageCardData?.moreInfo
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
//    @IBAction func wifiEditBtnTapAction(_ sender: Any) {
//        if self.isPullToRefresh == false {
//            self.isTransitionAnimationGoingOn = true
//            DispatchQueue.main.async {
//                self.setupAnimationUI(showScreen: false, isEditwifi: true)
//            }
//        }
//    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
        if self.isPullToRefresh == false {
            self.isTransitionAnimationGoingOn = true
            DispatchQueue.main.async {
                self.setupAnimationUI(showScreen: false, isEditwifi: true)
            }
        }
    }
    @objc func goToEditScreen(_ sender: UITapGestureRecognizer? = nil) {
        self.qualtricsAction?.cancel()
        if self.isPullToRefresh == false {
            self.isTransitionAnimationGoingOn = true
            DispatchQueue.main.async {
                self.setupAnimationUI(showScreen: false, isEditwifi: true)
            }
        }
    }
    @IBAction func viewMyNetworkBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        navigateToViewMyNetworkScreen()
    }
    
    @IBAction func troubleShootMyInternetBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        navigateToTroubleShootNetworkScreen()
    }
    @IBAction func moreOptionsBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.isTransitionAnimationGoingOn = true
        let storyboard = UIStoryboard(name: "WiFiScreen", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "advancedOptions") as? AdvancedSettingsUIViewController{
            vc.modalPresentationStyle = .fullScreen
            vc.performTransition = true
            UIView.animate(withDuration: 0.3) {
                self.viewAnimationTop.constant = self.animationViewTop
                self.vwClossBottom.constant = 100
                self.vwContainer.alpha = 0.0
                self.view.layoutIfNeeded()
                let aNavigationController = UINavigationController(rootViewController: vc)
                aNavigationController.modalPresentationStyle = .fullScreen
                self.present(aNavigationController, animated: false, completion: nil)
            }
        }
    }
    @IBAction func closeBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        pullToRefresh(hideScreen: true)
        isTransitionAnimationGoingOn = true
        setupAnimationUI(showScreen: false, isEditwifi: false)
    }
    ///Method for ViewMyNetwork Page Call
    func setTapActionForAnimationView() {
        imgViewWifi.gestureRecognizers?.forEach(imgViewWifi.removeGestureRecognizer)
        let viewMyNetworkTapFromImg = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imgViewWifi.addGestureRecognizer(viewMyNetworkTapFromImg)
        lblContent.gestureRecognizers?.forEach(lblContent.removeGestureRecognizer)
        let viewMyNetworkTapFromLabel = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        lblContent.addGestureRecognizer(viewMyNetworkTapFromLabel)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.qualtricsAction?.cancel()
        self.navigateToViewMyNetworkScreen()
    }
    func setTapActionForTroubleshooting() {
        imgViewWifi.gestureRecognizers?.forEach(imgViewWifi.removeGestureRecognizer)
        let troubleshootingfromImg = UITapGestureRecognizer(target: self, action: #selector(self.navigateToTroubleshooting(_:)))
        imgViewWifi.addGestureRecognizer(troubleshootingfromImg)
        lblContent.gestureRecognizers?.forEach(imgViewWifi.removeGestureRecognizer)
        let troubleshootingLabel = UITapGestureRecognizer(target: self, action: #selector(self.navigateToTroubleshooting(_:)))
       lblContent.addGestureRecognizer(troubleshootingLabel)
    }
    @objc func navigateToTroubleshooting(_ sender: UITapGestureRecognizer? = nil) {
        self.qualtricsAction?.cancel()
        self.navigateToFixItAction()
    }
    ///Method for ViewMyNetwork Page Call
    func navigateToViewMyNetworkScreen() {
        self.qualtricsAction?.cancel()
        if self.btnViewMyNetwork.isHidden == true {
            return
        }
        self.animationCircleStaticImg.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.hideScreenControls(true)
            self.animationCircleStaticImg.transform = CGAffineTransform(scaleX: 10, y: 10)
        } completion: { complete in
            let viewMyNetwork = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewMyNetwork") as! ViewMyNetworkViewController
            viewMyNetwork.modalPresentationStyle = .fullScreen
            self.present(viewMyNetwork, animated: false, completion: nil)
        }
    }
    
    ///Method for TroubleShoot Page Call
    func navigateToTroubleShootNetworkScreen() {
        self.animationCircleStaticImg.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.hideScreenControls(true)
            self.animationCircleStaticImg.transform = CGAffineTransform(scaleX: 10, y: 10)
        } completion: { complete in
            let healthCheck = UIStoryboard(name: "Troubleshooting", bundle: Bundle.main).instantiateViewController(withIdentifier: "CheckOutagesResultsViewController") as! CheckOutagesResultsViewController
            let aNavigationController = UINavigationController(rootViewController: healthCheck)
            aNavigationController.navigationBar.isHidden = false
            aNavigationController.modalPresentationStyle = .fullScreen
            self.present(aNavigationController, animated: false, completion: nil)
        }
    }

    //MARK: Lottie Animation
//    func viewShiftAnimationSetUp(animationType:MyWiFiStatusModel) {
//        view.shift.id = shiftID
//        shift.baselineDuration = 1.00
//        switch animationType {
//        case .offline:
//            self.imgViewWifi.image = UIImage(named: "icon_wifi_red")
//            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
//            self.lblContent.text = networkName + MyWiFiConstants.wifi_down                    //set api value: wifi name
//        case .online:
//            self.lblContentY.constant = 20
//            self.imgViewWifi.image = UIImage(named: "icon_wifi_white")
//            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseDefault")
//            self.lblContent.text = MyWiFiConstants.wifi_smoothly                //set api value: wifi name
//        case .extender_weak:
//            self.imgViewWifi.image = UIImage(named: "icon_wifi_orange")
//            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseWeak")
//            self.lblContent.text = self.extenderStatusName     //set api value: wifi name or number of wifi
//        case .extender_offline:
//            self.imgViewWifi.image = UIImage(named: "icon_wifi_red")
//            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
//            self.lblContent.text = self.extenderStatusName            //set api value: wifi name or number of wifi
//        case .be_failure:
//            self.lblContentY.constant = 20
//            self.viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseOffline")
//            self.lblContent.text = MyWiFiConstants.check_back_later
//        }
//        self.viewAnimation.backgroundColor = .clear
//        self.viewAnimation.loopMode = .loop
//        self.viewAnimation.animationSpeed = 1.0
//        self.viewAnimation.play()
//    }
    
    //MARK: Set Border View
    func setBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor) {
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.layer.masksToBounds = true
    }
}

//MARK: Animation Extension
class MyWifiTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return MyWifiPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Updating corner especifically for MyWiFiViewController
        if dismissed is MyWiFiViewController {
            dismissed.view.layer.cornerRadius = 80
        }
        return ModalTransitionDismissing()
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionPresenting()
    }
}

class MyWifiPresentationController: UIPresentationController {
    let width = CGFloat(275)
    let height = CGFloat(263)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            x: 0,
            y: 0,
            width: containerView.frame.width,//width,
            height: containerView.frame.height
        )
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: width, height: height)
    }
}
