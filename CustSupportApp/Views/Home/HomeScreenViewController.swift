//
//  File.swift
//  CustSupportApp
//
//  Created by Namarta on 08/07/22.
//

import UIKit
import Shift
import Lottie
import Combine
import ASAPPSDK

protocol ProfileManagerDelegate: AnyObject {
    func updateStatusForPausedProfiles()
}

class HomeScreenViewController: UIViewController, DismissingChildViewcontroller, HandleAnimationInParentView {
    
    @IBOutlet weak var quickPayLoading: UIActivityIndicatorView!
    @IBOutlet weak var salutationLabel: UILabel!
    @IBOutlet weak var myWiFiImgView: UIImageView!
    @IBOutlet weak var quickPayImgView: UIImageView!
    @IBOutlet weak var myAccountImgView: UIImageView!
    @IBOutlet weak var tvImgView: UIImageView!
    @IBOutlet weak var salutationLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var animationHelperView: UIView!
    
    @IBOutlet weak var controlBgView: UIView!
    @IBOutlet weak var controlWiFi: UIControl!
    @IBOutlet weak var controlMyAccount: UIControl!
    @IBOutlet weak var controlQuickPaY: UIControl!
    @IBOutlet weak var controlTV: UIControl!
    
    @IBOutlet weak var btnMyAccount: UIButton!
    @IBOutlet weak var btnQuickPay: UIButton!
    @IBOutlet weak var btnMyWifi: UIButton!
    @IBOutlet weak var btnTV: UIButton!
    
    @IBOutlet weak var lblMyAccount: UILabel!
    @IBOutlet weak var lblQuickPay: UILabel!
    @IBOutlet weak var lblMyWiFi: UILabel!
    @IBOutlet weak var lblTV: UILabel!
    
    @IBOutlet weak var bottomControlsStack: UIStackView!
    @IBOutlet weak var myAccountWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackVBottomConstraint: NSLayoutConstraint!
        
   @IBOutlet weak var spotlightViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var spotlightViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spotlightViewTopCVConstraint: NSLayoutConstraint!
    @IBOutlet weak var spotlightCollectionView: UICollectionView!
    @IBOutlet weak var animationHelperBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var spotlightAnimated: Bool = false
    var firstLaunch: Bool = true
    var arrAnimatedSpotlights: [SpotLightCards] = []
    var arrTrackedSpotlights: [SpotLightCards] = []
//    var spotlightCardType: SpotLightCards = .none
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var loadingView: UIView!

    var autoLaunchBilling: Bool = false

    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet weak var profileErrorMessageView: UIView!
    @IBOutlet weak var lblTopConstraint: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    let billSharedManager = QuickPayManager.shared
    
    var isChatPresented: Bool = false
    var tapTargetForSpotlight = ""
    var spotLightCardId = ""
    var accountName = ""
    var isFromQuickPay = false
    var allProfiles: Profiles = [] {
        didSet {
            self.updateProfileErrorMessageView()
        }
    }
    var isProfileTap: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    var qualtricsAction : DispatchWorkItem?
    var isCloseBtnOnSpotlightTapped = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if !SpotLightsManager.shared.gAdCardEligible || ConfigService.shared.ad_enabled.lowercased() != "true" {
            SpotLightsManager.shared.configureSpotLightsForThankYou()
          //  spotlightCollectionView.reloadWithoutAnimation()
        }
        AppRatingManager.shared.trackAppEntryCount()
        CustomGAdLoader.shared.delegate = self
        self.fetchProfilesList()
        /// Bottom Section UI for large and small screens
        if CurrentDevice.forLargeSpotlights() {
            bottomControlsStack.spacing = (16.0/xibDesignWidth) * currentScreenWidth
            stackVBottomConstraint.constant = 34.0
            spotlightViewVerticalConstraint.constant = 0
            //spotlightViewTopCVConstraint.constant = 0
            //spotlightViewVerticalConstraint.constant = (60.0/926.0)*currentScreenHeight
            //CMAIOS-2199 to perform spotlight animation as per screen size
            spotlightViewVerticalConstraint.priority = UILayoutPriority(200)
            if currentScreenHeight > 874 {
                spotlightViewHeightConstraint.constant = 440.0
                spotlightViewTopCVConstraint.constant = 40
            } else {
                spotlightViewHeightConstraint.constant = 400.0
                spotlightViewTopCVConstraint.constant = 15
            }
        } else {
            spotlightViewVerticalConstraint.priority = UILayoutPriority(999)
            bottomControlsStack.spacing = 16.0
            stackVBottomConstraint.constant = currentScreenHeight < xibDesignHeight ? 16 : 25.0
            spotlightViewHeightConstraint.constant = 200.0
        }
        /// Bottom Section Controls UI For iPod Touch
        if currentScreenWidth < xibDesignWidth {
//            myAccountWidthConstraint.constant = (myAccountWidthConstraint.constant/xibDesignWidth)*currentScreenWidth
//            myAccountHeightConstraint.constant = (myAccountHeightConstraint.constant/xibDesignHeight)*currentScreenHeight
//            stackVBottomConstraint.constant = (stackVBottomConstraint.constant/xibDesignHeight)*currentScreenHeight
//            spotlightViewHeightConstraint.constant = (210/xibDesignHeight)*currentScreenHeight
//            //Fonts:
            lblMyWiFi.font = UIFont(name: "Regular-Medium", size: (16.0/xibDesignWidth)*currentScreenWidth)
            lblMyAccount.font = UIFont(name: "Regular-Medium", size: (16.0/xibDesignWidth)*currentScreenWidth)
            lblQuickPay.font = UIFont(name: "Regular-Medium", size: (16.0/xibDesignWidth)*currentScreenWidth)
            lblTV.font = UIFont(name: "Regular-Medium", size: (16.0/xibDesignWidth)*currentScreenWidth)
        }
        bottomControlsStack.layoutSubviews()
        if !CurrentDevice.forLargeSpotlights() {
            self.alignSpotlightCardsInCentreForSmallerScreens()
        }
        
        // handled in checkForBottomButtonFlags() method
        /*
         //add condition on payment bollean
         ///Comment/Un-comment to Hide Controls
         //CMAIOS-93
         if MyWifiManager.shared.isTVOnlyService() {
         hideMyWifi()
         }
         if MyWifiManager.shared.hasBillPay() == false {
         hideQuickPay()
         }
         */

        if MyWifiManager.shared.isPrimaryUser(){
            checkForBottomButtonFlags()
        } else {
            checkForBottomButtonFlags()
        }
        initiatePullToRefresh()
        initialUIConstants()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSSID), name:NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateOnlineActivity(notification:)), name: NSNotification.Name(rawValue: "UpdateOnlineActivity"), object: nil)
        
        //CMAIOS-77 TO-DO to replace with saved values and call this API from methods for profile association/Friendly Name update/ Device Category update
        ///Uncomment to test set lightspeed node
       /* var nodeData = LightspeedNode()
        nodeData.cma_category = "MAC"
        nodeData.cma_dev_type = "laptop"
        nodeData.friendlyname = "string"
        nodeData.gwid = "58FC200744DF"
        nodeData.hostname = "Test"
        nodeData.location = "Test"
        nodeData.mac = "d3:d5:75:83:19:4a"
        nodeData.profile = ""
        nodeData.pid = "50"
        LightSpeedAPIRequests.shared.initiateSetNodeRequest(nodeData: nodeData, completionHandler: {result, error in
            if result{
                print("Set Lightspeed Node success")
            }
            else{
                print("Set Lightspeed Node failed: " + (error?.errorDescription ?? ""))
            }
        })*/
            
        setUIImgViewAnime()
        if MyWifiManager.shared.wifiDisplayType == .Other {
            self.lblMyWiFi.text = "Internet"
        } else {
            self.lblMyWiFi.text = "WiFi"
        }
        
        // Greeting Salutation
        let currentTime = App.checkCurrentTimeForSalutation()
        salutationLabel.text = currentTime.getGreetingText()
         
        //Profile Collection UI
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout
        self.collectionView.register(UINib(nibName: "DeviceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DeviceCollectionViewCell")
        
        //Spotlight Collection UII
        let spotlightLayout = UICollectionViewFlowLayout()
        spotlightLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        spotlightLayout.scrollDirection = .horizontal
        spotlightLayout.minimumInteritemSpacing = 0
        spotlightLayout.minimumLineSpacing = self.getSpotlightCellSpace()

        self.spotlightCollectionView.collectionViewLayout = spotlightLayout
        self.spotlightCollectionView.backgroundColor = .clear
        self.spotlightCollectionView.showsHorizontalScrollIndicator = false
        if CurrentDevice.forLargeSpotlights() {
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightOneLarge", bundle: nil), forCellWithReuseIdentifier: "SpotLightOneLarge")
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightTwoLarge", bundle: nil), forCellWithReuseIdentifier: "SpotLightTwoLarge")
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightThreeLarge", bundle: nil), forCellWithReuseIdentifier: "SpotLightThreeLarge")
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightFourLarge", bundle: nil), forCellWithReuseIdentifier: "SpotLightFourLarge")
            self.spotlightCollectionView.register(UINib(nibName: "OutageDetectedCollectionViewCellLarge", bundle: nil), forCellWithReuseIdentifier: "OutageDetectedCollectionViewCellLarge")
            self.spotlightCollectionView.register(UINib(nibName: "OutageFoundCollectionViewCellLarge", bundle: nil), forCellWithReuseIdentifier: "OutageFoundCollectionViewCellLarge")
        } else {
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightOneSmall", bundle: nil), forCellWithReuseIdentifier: "SpotLightOneSmall")
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightTwoSmall", bundle: nil), forCellWithReuseIdentifier: "SpotLightTwoSmall")
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightThreeSmall", bundle: nil), forCellWithReuseIdentifier: "SpotLightThreeSmall")
            self.spotlightCollectionView.register(UINib(nibName: "SpotLightFourSmall", bundle: nil), forCellWithReuseIdentifier: "SpotLightFourSmall")
            self.spotlightCollectionView.register(UINib(nibName: "OutageFoundCollectionViewCellSmall", bundle: nil), forCellWithReuseIdentifier: "OutageFoundCollectionViewCellSmall") 
            self.spotlightCollectionView.register(UINib(nibName: "OutageDetectedCollectionViewCellSmall", bundle: nil), forCellWithReuseIdentifier: "OutageDetectedCollectionViewCellSmall")
            
        }
        observeSpotlights()
        callMetricsForLoginTime()
        observeLiveTopologyState()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(notification:)), name: NSNotification.Name(rawValue: "UpdateProfile"), object: nil)
    }
    
    func callMetricsForLoginTime() {
        let manager = LoginPreferenceManager.sharedInstance
        var label = ""
        let duration = manager.calculateLoginDuration()
        if manager.metricsInfo.bgInterruption {
            label = manager.autoLoginFlow ? "home_load_after_autologin_bg" : "home_load_after_login_bg"
        } else {
            label = manager.autoLoginFlow ? "home_load_after_autologin" : "home_load_after_login"
        }
        LoginPreferenceManager.sharedInstance.callLogMetrics(duration: duration, label: label)
    }
        
    func checkForBottomButtonFlags() {
        var hideCount = 0
        if MyWifiManager.shared.hasBillPay() == false {
            hideQuickPay()
            hideCount += 1
        }
        
        //add condition on payment bollean
        ///Comment/Un-comment to Hide Controls
        //CMAIOS-93
        
       if MyWifiManager.shared.isTVOnlyService() {
            hideCount += 1
            hideMyWifi()
        }
        
        if MyWifiManager.shared.isTvStreamAvailable() == false {
            hideCount += 1
            hideTVControl()
        }
        updateBottomStackConstraints(hideCount: hideCount)
    }
    
    func alignSpotlightCardsInCentreForSmallerScreens()
    {
        let topSpace = self.collectionView.frame.origin.y + self.collectionView.frame.height
        let bottomSpace = self.bottomControlsStack.frame.size.height + self.stackVBottomConstraint.constant
        var spaceAvailable = 0.0
        spaceAvailable = currentScreenHeight - (bottomSpace + topSpace + spotlightViewHeightConstraint.constant + UIDevice.current.topInset)
        //For iPod, iPhoneSE First gen
        if currentScreenHeight < xibDesignHeight {
            spaceAvailable += UIDevice.current.topInset
        }
        spotlightViewVerticalConstraint.constant = spaceAvailable/2
        spotlightViewTopCVConstraint.constant = spaceAvailable/2
    }
    
    /* CMAIOS-1202 */
    private func getSpotlightCellSpace() -> CGFloat {
        var spacePadding = 20.0
        if CurrentDevice.forLargeSpotlights() {
            let padding = currentScreenWidth - 350
            if padding > 0 {
                if padding <= 50 && padding >= 40 { // Buffer 10 pts
                    spacePadding = 15.0
                }
            }
        }
        return spacePadding
    }
    
    @objc func updateOnlineActivity(notification: NSNotification) {
        if let profiles = ProfileModelHelper.shared.profiles {
           self.allProfiles = profiles
        }
    }
    
    func addLoader() {
        self.removeLoaderView()
        self.loadingView.isHidden = false
        self.loadingAnimationView.isHidden = false
    }
    
    func removeLoaderView() {
        if !self.loadingView.isHidden {
            self.loadingView.isHidden = true
            self.loadingAnimationView.stop()
            self.loadingAnimationView.isHidden = true
        }
    }

    func showODotAnimation() {
        self.loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        self.loadingAnimationView.backgroundColor = .clear
        self.loadingAnimationView.loopMode = .loop
        self.loadingAnimationView.animationSpeed = 1.0
        self.loadingAnimationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //CMA-3123 Handle deeplink
        let appDel = UIApplication.shared.delegate as? AppDelegate
        if appDel?.deepLinkToChatEnabled == true && ASAPP.config != nil {
            var chatViewController : UIViewController?
            chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil)
            guard let chatVC = chatViewController else {
                return
            }
            chatVC.modalPresentationStyle = .fullScreen
            self.trackAndNavigateToChat(chatTransitionType: .Push, chatVC: chatVC)
            appDel?.deepLinkToChatEnabled = false
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterGAdSuppress(notification:)), name: NSNotification.Name(rawValue: "GACardRemoved"), object: nil)
        autoLaunchBilling ? addLoader() : removeLoaderView()
        if autoLaunchBilling {
            btnQuickPay.sendActions(for: .touchUpInside)
        }
        QuickPayManager.shared.localSavedPaymethods = nil
        ProfileManager.shared.profileManagerDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(fromFirstUserExperience(notification:)), name: NSNotification.Name(rawValue: "AppearedAfterFirstUserExperience"), object: nil)
        DispatchQueue.main.async {
//            self.mauiOutageAlertApiRequest(reloadOutageCard: false)
            if !self.isChatPresented { // Block the api call when chat view in MyAccount screen is presented
                self.initialSetupForBillPayCards()
            }
            QuickPayManager.shared.delegate = self
            self.reloadSpotlights()
            self.handleBackwardTransitionFromChatVC()
        }
        self.addQualtricsAction()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : HomePageCards.Home.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        IntentsManager.sharedInstance.screenFlow = .none
        //CMAIOS-2336: Added API calling when user moves to Bill Pay directly from spotlight cards
        if isFromQuickPay {
            isFromQuickPay = false
            if MyWifiManager.shared.hasBillPay() {
                self.performSpotlightRequests()
            }
        }
        //
    }
    
    func movingOutOfHomeScreen() {
        qualtricsAction?.cancel()
       //SpotLightsManager.shared.GACardRemoved = false
        //need to start ScreenNavs rules if ten second rule is not completed and user is moving out of home screen
        QualtricsManager.shared.startWithScreenNavsRule()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        qualtricsAction?.cancel()
        super.viewWillDisappear(animated)
        if !self.isChatPresented {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        ProfileManager.shared.isFirstUserCompleted = true
        spotlightAnimated = false
        self.arrAnimatedSpotlights = SpotLightsManager.shared.arrSpotLights
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AppearedAfterFirstUserExperience"), object: nil)
    }
    
    func handleBackwardTransitionFromChatVC(){
           if self.isChatPresented {
               if APIRequests.shared.isReloadNotRequiredForMaui {
                   APIRequests.shared.isReloadNotRequiredForMaui = false
               }
               self.isChatPresented = false
               self.navigationController?.isNavigationBarHidden = true
               self.view.backgroundColor =  UIColor(red: 232.0/255.0, green: 233.0/255.0, blue: 231.0/255.0, alpha: 1.0)
               let viewController = self.getMyAccountsController(screenTypeID: "MyAccountScreen")
               self.present(viewController, animated: false)
               return
           }
       }
    
    func observeSpotlights() {
        if !APIRequests.shared.isAccountSignedOut {
            SpotLightsManager.shared.$arrSpotLights
                .receive(on: RunLoop.main)
                .sink {[weak self] newArrSpotLight in
                    DispatchQueue.main.async {
                        //CMAIOS-2199 to stop reloading animation after close button click on spotlight card
                        if self?.isCloseBtnOnSpotlightTapped == false {
                            if newArrSpotLight.count > 1 {
                                /// Refresh Screen
                                if self?.spotlightAnimated == false && self?.arrAnimatedSpotlights.containsSameElements(as: newArrSpotLight) == false {
                                    self?.reloadSpotlights()
                                    self?.spotlightAnimated = true
                                } else {
                                    self?.spotlightCollectionView.reloadWithoutAnimation()
                                }
                            }
                        }
                    }
                }.store(in: &cancellables)
        }
    }
    
    func observeLiveTopologyState() {
        if !APIRequests.shared.isAccountSignedOut {
            MyWifiManager.shared.$lightSpeedData
                .receive(on: RunLoop.main)
                .sink {[weak self] data in
                    if self?.isViewLoaded == true && self?.view.window != nil {
                        /// Refresh Profiles
                        if data?.isEmpty == false && DeviceManager.shared.devices != nil {
                            self?.fetchAndLoadProfileStatus(isFromLiveTopology: true)
                        }
//                        else {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                                self?.fetchAndLoadProfileStatus()
//                            }
//                        }
                    }
                }.store(in: &cancellables)
        }
    }
    
    //MARK: UpdateProfile After Editing ProfileDetails
    @objc func updateProfile(notification: NSNotification) {
        let dict = notification.userInfo
        let updatedProfileObj = dict?["profile"] as? Profile
        if let selectedRowIndex = self.allProfiles.firstIndex(where: {$0.pid == updatedProfileObj?.pid}){
            var oldProfileDetail = self.allProfiles[selectedRowIndex]
            oldProfileDetail.profile = updatedProfileObj
            oldProfileDetail.profileName = updatedProfileObj?.profile ?? ""
            oldProfileDetail.avatarImage = Avatar().getAvatarImage(for: updatedProfileObj?.avatar_id ?? 13, name:updatedProfileObj?.profile ?? "" )
            self.allProfiles[selectedRowIndex]  = oldProfileDetail
            self.collectionView.reloadItems(at: [IndexPath(row:selectedRowIndex , section: 0)])
        }
    }
    
    func fetchAndLoadProfileStatus(isFromLiveTopology: Bool = false) {
        ProfileModelHelper.shared.getProfileDeviceStatusBasedOnLTResponse { profiles in
            self.updateHomeScreenProfileList(profiles: profiles, isFromLiveTopology: isFromLiveTopology)
        }
    }
    
    func updateHomeScreenProfileList(profiles: Profiles?, isFromLiveTopology: Bool = false){
        self.allProfiles = profiles ?? []
        if !isFromLiveTopology {
            self.reloadCollectionView()
        }
    }
    
    @objc func reloadAfterGAdSuppress(notification: NSNotification) {
        //CMAIOS-2664
        if SpotLightsManager.shared.arrSpotLights.count > 0 && !APIRequests.shared.isRebootOccured {
            self.reloadSpotlightCollectionView()
        }
        //
    }
    
    @objc func fromFirstUserExperience(notification: NSNotification) {
        if let reloadInfo = notification.userInfo?["reload"] as? String, reloadInfo == "Profiles" {
            self.fetchProfilesList()
        } else {
            DispatchQueue.main.async {
                self.reloadSpotlights()
            }
        }
    }
    
    @objc func fromTSSupport(notification: NSNotification) {
        self.btnMyWifi.backgroundColor = .clear
        self.childViewcontrollerGettingDismissed()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "TSSupport"), object: nil)
    }
    
    @objc func fromTVTSSupport(notification: NSNotification) {
        self.btnTV.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.applyAnimationAfterDismiss()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "TSSupport"), object: nil)
    }

    func trackAvailableSpotlightCards() {
        if APIRequests.shared.isRebootOccured { return }
        if self.arrTrackedSpotlights.isEmpty {
            self.arrTrackedSpotlights = self.arrAnimatedSpotlights
            self.trackSpotlightCardsArray(cards: self.arrTrackedSpotlights)
        } else {
            var newCards: [SpotLightCards] = []
            for card in self.arrAnimatedSpotlights {
                if self.arrTrackedSpotlights.contains(card) == false {
                    newCards.append(card)
                }
            }
            self.trackSpotlightCardsArray(cards: newCards)
            self.arrTrackedSpotlights = self.arrAnimatedSpotlights
        }
    }
    
    func trackSpotlightCardsArray(cards: [SpotLightCards]) {
        for card in cards {
            trackSpotlightCard(card: card)
        }
    }
    
    func trackSpotlightCard(card: SpotLightCards) {
        var event = ""
        var fixed = "General"
        var intent = "wifi"
        switch card {
        case .dead_zones:
            intent = "wifi"
            event = HomePageCards.Homepagecard_Deadzones.rawValue
        case .network_down:
            intent = "wifi"
            event = HomePageCards.Homepagecard_Network_down.rawValue
        case .network_weak:
            intent = "extender"
            event = HomePageCards.Homepagecard_Extender_Weaksignal.rawValue
        case .offline_extender:
            intent = "extender"
            event = HomePageCards.Homepagecard_Extender_Offline.rawValue
        case .weak_extender:
            intent = "extender"
            event = HomePageCards.Homepagecard_Extender_Weaksignal.rawValue
        case .thankYou:
//            fixed = "general"
//            intent = "general"
            event = HomePageCards.Homepagecard_Thankyou.rawValue
        case .none, .readyToInstall_Extender5, .readyToInstall_Extender6:
            // Not defined yet
            break
        case .adType:
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : HomePageCards.Google_Ad_Spotlight.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
        case .billPayTemplateTypeOne, .billPayTemplateTypeTwo, .billPaySecondTemplateTypeOne, .billPaySecondTemplateTypeTwo, .billPayTemplateTypeThree, .billPaySecondTemplateTypeThree:
                //CMAIOS-2297: Track action mapped with API data
            fixed = "Billing"
            event = SpotLightsManager.shared.getEventName(card: card)
        case .stream_install:
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_SETUP_CARD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
            break
        case .outageAreaTemplateTypeOne, .outageAreaTemplateTypeTwo, . outageAreaSecondTemplateTypeOne, .outageAreaSecondTemplateTypeTwo:
            //CMAIOS-2559: Track action mapped with API data
            event = SpotLightsManager.shared.getEventName(card: card)
            break
        }
        if event.isEmpty { return }
        if fixed == "General" {
            if intent == "wifi" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
            }else if intent == "extender" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
            }
        } else if fixed == "Billing" { //billing
            
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        }
    }
    
    
    func reloadSpotlights() {
        guard SpotLightsManager.shared.arrSpotLights.count > 0 else {
            return
        }
        if MyWifiManager.shared.recallSpotlights {
            self.arrAnimatedSpotlights = SpotLightsManager.shared.arrSpotLights
            MyWifiManager.shared.recallSpotlights = false
            self.reloadSpotlightCollectionView()
            return
        }
        if self.arrAnimatedSpotlights.containsSameElements(as: SpotLightsManager.shared.arrSpotLights) == true {
            return
        }
        self.arrAnimatedSpotlights = SpotLightsManager.shared.arrSpotLights
        trackAvailableSpotlightCards()
        if SpotLightsManager.shared.arrSpotLights.count > 0 {
            self.reloadSpotlightCollectionView()
        }
    }
    
    func reloadSpotlightCollectionView() {
        if !APIRequests.shared.isAccountSignedOut {
            DispatchQueue.main.async {
                self.spotlightCollectionView.reloadData()
                //            spotlightCollectionView.performBatchUpdates(nil, completion: {
                //                _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    if !SpotLightsManager.shared.arrSpotLights.isEmpty, let spCollectionView = self.spotlightCollectionView, let viewCount = spCollectionView.numberOfItems(inSection: 0) as Int?, viewCount == SpotLightsManager.shared.arrSpotLights.count {
                        self.spotlightCollectionView.scrollToItem(at: IndexPath(row: SpotLightsManager.shared.arrSpotLights.count-1, section: 0), at: .left, animated: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            UIView.animate(withDuration: 1.0) {
                                self.spotlightCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .right, animated: true)
                            }
                        }
                    }
                }
            }
        }
        // })
    }

    func setUIImgViewAnime() {
        controlWiFi.layer.masksToBounds = true
        controlWiFi.shift.id = "MyWiFiScreen"
        myWiFiImgView.backgroundColor = .clear
        controlTV.layer.masksToBounds = true
        controlTV.shift.id = "TVHomePage"
        tvImgView.backgroundColor = .clear
        controlQuickPaY.layer.masksToBounds = true
        controlQuickPaY.shift.id = "QuickPayScreen"
        controlQuickPaY.backgroundColor = .clear
        controlMyAccount.layer.masksToBounds = true
        controlMyAccount.shift.id = "MyAccountScreen"
        controlMyAccount.backgroundColor = .clear
        self.lblMyWiFi.textColor = UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        self.lblMyAccount.textColor = UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        self.lblQuickPay.textColor = UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        self.lblTV.textColor = UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    }
    
    func setupInitialUI() {
        self.salutationLabelWidth.constant = 220
    }
    
    @objc func updateSSID() {
        //self.pullToRefresh(hideScreen: true)
        DispatchQueue.main.async {
           // self.collectionView.reloadData()
            self.spotlightCollectionView.reloadWithoutAnimation()
        }
    }
   
    @objc func lightSpeedAPICallBack() {
        self.fetchAndLoadProfileStatus(isFromLiveTopology: true)
        self.pullToRefresh(hideScreen: true, isComplete: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
    }
    
    func reloadCollectionViewForLightSpeedSSID(isFromLiveTopology: Bool = false) {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                if isFromLiveTopology {
                    self.reloadCollectionView()
                }
                self.spotlightCollectionView.reloadWithoutAnimation()
            }
        }
    }
   
    ///Method for button action
    func disableUserIntractions(isAllowed: Bool) {
        self.btnMyWifi.isUserInteractionEnabled = isAllowed
        self.btnQuickPay.isUserInteractionEnabled = isAllowed
        self.btnMyAccount.isUserInteractionEnabled = isAllowed
        self.collectionView.isUserInteractionEnabled = isAllowed
        self.spotlightCollectionView.isUserInteractionEnabled = isAllowed
    }
    
    //MARK: Animation Methods
    func initialUIConstants() {
        self.vwPullToRefresh.isHidden = true
        vwPullToRefreshCircle.isHidden = true
        self.vwPullToRefreshHeight.constant = 0
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
    }
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        // After Refresh
        guard let _ = MyWifiManager.shared.deviceMAC, let _ = MyWifiManager.shared.deviceType else {
            //Gateway is offline
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.pullToRefresh(hideScreen: true)
            }
            return
        }
     //   SpotLightsManager.shared.GACardRemoved = false
        if MyWifiManager.shared.accountsNetworkPoints != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
            MyWifiManager.shared.triggerOperationalStatus()
            self.checkMauiApiStateForRefresh(pullToRefresh: true)
            if MyWifiManager.shared.isGateWayWifi6() {
                ProfileManager.shared.pausedProfileStatusCalled = false
//                DispatchQueue.global(qos: .background).async {
//                    ProfileManager.shared.getPausedProfiles()
//                }
            }
            self.spotlightAnimated = false
        } else {
            // If Map is nil in Accounts API reponse, LightSpeed API shouldn't be triggered
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.pullToRefresh(hideScreen: true)
            }
        }
    }
    
    //MARK: Pull to refresh Methods
    ///Method for pull to refresh during swipe.
    func initiatePullToRefresh() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
        self.view?.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    //MARK: Handling UI for large and small screen
    func handleSmallAndLargeScreenUI() {
         self.animationHelperBottomConstraint.constant = isPullToRefresh ? -130 : 0
         self.lblTopConstraint.constant = isPullToRefresh ? 130 : 10
    }
    
    ///Method for pull to refresh animation.
    @objc func pullToRefresh(hideScreen hide:Bool, isComplete: Bool = false) {
        vwPullToRefresh.isHidden = false
        vwPullToRefreshCircle.isHidden = false
        self.vwPullToRefreshAnimation.isHidden = false
        self.vwPullToRefreshAnimation.animation = LottieAnimation.named("AutoLogin")
        self.vwPullToRefreshAnimation.loopMode = !isComplete ? .loop : .playOnce
        self.vwPullToRefreshAnimation.animationSpeed = 1.0
        if !hide {
            self.disableUserIntractions(isAllowed: false)
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
                self.handleSmallAndLargeScreenUI()
                self.vwPullToRefreshTop.constant = currentScreenHeight >= 844.0 || currentScreenHeight == 736.0 ? 40 : 60
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
         //   self.vwPullToRefreshAnimation.play() { _ in
                self.disableUserIntractions(isAllowed: true)
                UIView.animate(withDuration: 0.5, animations: {
                        self.isPullToRefresh = false
                        self.handleSmallAndLargeScreenUI()
                        self.vwPullToRefreshAnimation.stop()
                        self.vwPullToRefreshAnimation.isHidden = true
                        self.vwPullToRefreshTop.constant = 80
                        self.vwPullToRefreshHeight.constant = 0
                        self.view.layoutIfNeeded()
                   
                }) { _ in
                    self.reloadCollectionViewForLightSpeedSSID(isFromLiveTopology: true)
                }
           // }
        }
    }
    // MARK: - Hide/Unhide Bottom Section Controls
    func hideQuickPay() {
        self.controlQuickPaY.isHidden = true
    }
    
    func hideMyWifi() {
        self.controlWiFi.isHidden = true
    }
    
    func hideTVControl() {
        self.controlTV.isHidden = true
    }
    
    func updateBottomStackConstraints(hideCount: Int) {
        myAccountWidthConstraint.constant = (hideCount == 0) ? 76.25 : 90.0
        bottomControlsStack.spacing = 10.0
        self.bottomControlsStack.layoutIfNeeded()
    }
    
    // MARK: - User Interaction Methods
  
    @IBAction func showMyWifiHomePage(_ sender: Any) {
        self.movingOutOfHomeScreen()
        /*if MyWifiManager.shared.outageTitle == "OUTAGE_ON_ACCOUNT" {
            self.presentErrorMessageVCForRFOutage()
        } else {} */ // CMAIOS-1701
            //Call OP+LT request
            if MyWifiManager.shared.lightSpeedAPIState != .firstLiveTopologyCallInProgress {
                if MyWifiManager.shared.isOperationalStatusOnline == false || MyWifiManager.shared.lightSpeedAPIState == .failedLiveTopology || MyWifiManager.shared.lightSpeedAPIState == .failedOperationalStatus {
                    MyWifiManager.shared.reCallFromMyWifiJumpLink = true
                    MyWifiManager.shared.recallSpotlights = true
                    DispatchQueue.main.async {
                        MyWifiManager.shared.triggerOperationalStatus()
                    }
                } else {
                    DispatchQueue.main.async {
                        if MyWifiManager.shared.getWifiType() != "Modem" {
                            APIRequests.shared.performLiveTopologyRequest()
                        }
                    }
                }
            }
        //CMAIOS-2399, CMAIOS-2596
        if SpotLightsManager.shared.checkIfOutageCardExists().0 && MyWifiManager.shared.isOperationalStatusOnline == false {
            self.animateSalutation(hideContent: true, screenTypeID: "MyWiFiScreen", isOutageDetected: true)
        } else {
            self.animateSalutation(hideContent: true, screenTypeID: "MyWiFiScreen")
        }
    }

    @IBAction func showTvHomePage(_ sender: Any) {
        //CMAIOS-2399, CMAIOS-2596
        if SpotLightsManager.shared.checkIfOutageCardExists(isFromWiFiJumpLink: false).0 && MyWifiManager.shared.isOperationalStatusOnline != true {
            self.animateSalutation(hideContent: true, screenTypeID: "TVHomePage", isOutageDetected: true)
            return
        }
        var showInstallFlow = true //CMA-2137 //CMA-2549
        let arrayStb = MyWifiManager.shared.getTvStreamDevices()
        for stbData in arrayStb {
            if !stbData.macAddress.isEmpty {
                showInstallFlow = false
                break
            }
        }
        if showInstallFlow {
            optimumStreamInstallNow()
        } else {
            self.movingOutOfHomeScreen()
            self.animateSalutation(hideContent: true, screenTypeID: "TVHomePage")
        }
    }
    
    @IBAction func showQuickPayHomePage(_ sender: Any) {
        self.movingOutOfHomeScreen()
        if QuickPayManager.shared.isReAuthenticationRequired() {
            movingOutOfHomeScreen()
            QuickPayManager.shared.reAuthOnTimeExpiry(category: .jumpLink)
        } else {
            self.showQuickPayViewController()
        }
    }
    
    @IBAction func showMyAccountPage(_ sender: Any) {
        self.movingOutOfHomeScreen()
        self.animateSalutation(hideContent: true, screenTypeID: "MyAccountScreen")
    }
    
    // MARK: - Animation Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.presentedViewController?.isKind(of: MyWiFiViewController.self) == true {
            return .lightContent
        }
        return .default
    }
    
    //CMAIOS-2399, CMAIOS-2596
    func animateSalutation(hideContent hide: Bool, screenTypeID: String, isOutageDetected:Bool = false) {
        //add animation for salutation label
        self.arrAnimatedSpotlights = SpotLightsManager.shared.arrSpotLights
        ProfileManager.shared.isFirstUserCompleted = true
        spotlightAnimated = false
        UIView.animate(withDuration: 0.2) {
            self.salutationLabelWidth.constant = hide ? 0 : 220
            //self.animationHelperView.alpha = hide ? 0.0 : 1.0
            self.collectionView.alpha = hide ? 0.0 : 1.0
            self.spotlightCollectionView.alpha = hide ? 0.0 : 1.0
            self.view.layoutIfNeeded()
        } completion: { complete in
            if screenTypeID == "MyAccountScreen" {
                //show MyAccount screen with transition
//                let viewController = UIStoryboard(name: "MyAccount", bundle: nil).instantiateViewController(identifier: "myAccountViewController") as MyAccountViewController
//                let appDel = UIApplication.shared.delegate as? AppDelegate
//                appDel?.acccountVC = viewController
//                viewController.shiftID = screenTypeID
//                viewController.delegate = self
                let myAccountsVC = self.getMyAccountsController(screenTypeID: screenTypeID)

                UIView.animate(withDuration: 0.2) {
                    //Show fadeOut animation on HomeVC while transtion from HomeVC to MyAccountVC
                   // self.animationHelperView.alpha = 0.0
                    self.spotlightCollectionView.alpha = 0.0
                    self.controlQuickPaY.alpha = 0.0
                    self.controlWiFi.alpha = 0.0
                    self.controlTV.alpha = 0.0
                    self.myAccountImgView.alpha = 0.0
                    self.lblMyAccount.alpha = 0.0
                    self.collectionView.alpha = 0.0
                } completion: { complete in
//                    self.present(viewController, animated: true, completion: nil)
                    self.present(myAccountsVC, animated: true, completion: nil)
                }
            } else if screenTypeID == "MyWiFiScreen" {
                let viewController = UIStoryboard(name: "WiFiScreen", bundle: nil).instantiateViewController(identifier: "MyWiFiScreen") as MyWiFiViewController
                //CMAIOS-2399, 2596
                viewController.outageTitle = isOutageDetected ? OutageDescription.OutageMyWifi : nil
                viewController.outageCardData = isOutageDetected ? SpotLightsManager.shared.checkIfOutageCardExists().1 : nil
                viewController.shiftID = screenTypeID
                viewController.delegate = self
                UIView.animate(withDuration: 0.2) {
                    //self.animationHelperView.alpha = 0.0
                    self.collectionView.alpha = 0.0
                    self.spotlightCollectionView.alpha = 0.0
                    self.myWiFiImgView.alpha = 0.0
                    self.lblMyWiFi.alpha = 0.0
                    self.controlQuickPaY.alpha = 0.0
                    self.controlMyAccount.alpha = 0.0
                    self.controlTV.alpha = 0.0
                    self.btnMyWifi.backgroundColor = energyBlueRGB
                } completion: { complete in
                    NotificationCenter.default.addObserver(self, selector: #selector(self.fromTSSupport(notification:)), name: NSNotification.Name(rawValue: "TSSupport"), object: nil)
                    self.present(viewController, animated: true, completion: nil)
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            } else if screenTypeID == "QuickPayScreen" {
                let viewController = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "AnimationViewController") as AnimationViewController
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalPresentationCapturesStatusBarAppearance = true
                viewController.shiftID = screenTypeID
                viewController.delegate = self
                viewController.shift.enable()
                self.navigateToMyBill(ViewController: viewController)
            } else if screenTypeID == "TVHomePage" {
                // TODO: -- update correct VCscreen here...
                //CMAIOS-2399, CMAIOS-2596
                let tvHomePage = isOutageDetected ? self.getWIFIPageController(screenTypeID: screenTypeID) : self.getTVPageController(screenTypeID: screenTypeID)
                UIView.animate(withDuration: 0.2) {
                    //self.animationHelperView.alpha = 0.0
                    self.collectionView.alpha = 0.0
                    self.spotlightCollectionView.alpha = 0.0
                    self.tvImgView.alpha = 0.0
                    self.lblTV.alpha = 0.0
                    self.controlQuickPaY.alpha = 0.0
                    self.controlMyAccount.alpha = 0.0
                    self.controlWiFi.alpha = 0.0
                    self.btnTV.backgroundColor = energyBlueRGB
                } completion: { complete in
                    NotificationCenter.default.addObserver(self, selector: #selector(self.fromTVTSSupport(notification:)), name: NSNotification.Name(rawValue: "TSSupport"), object: nil)
                    tvHomePage.shift.enable()
                    self.present(tvHomePage, animated: true, completion: nil)
                }
            }
        }
    }
    
    func disableAlphaForBilling() {
        self.collectionView.alpha =  0.0
        self.spotlightCollectionView.alpha = 0.0
        self.quickPayImgView.alpha = 0.0
        self.lblQuickPay.alpha = 0.0
        self.controlWiFi.alpha = 0.0
        self.controlMyAccount.alpha = 0.0
        self.controlTV.alpha = 0.0
        self.btnQuickPay.backgroundColor = .white
    }
    
    func navigateToMyBill(ViewController: AnimationViewController) {
        if self.autoLaunchBilling {
            self.disableAlphaForBilling()
            self.showODotAnimation()
            self.loadingAnimationView.play(fromProgress: 0, toProgress: 0.9, loopMode: .playOnce) { _ in
                self.present(ViewController, animated: false) {
                    self.removeLoaderView()
                    self.autoLaunchBilling = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.disableAlphaForBilling()
            } completion: { complete in
                self.present(ViewController, animated: true, completion: nil)
            }
        }
    }
    
    func getTVPageController(screenTypeID: String) -> TVHomePageViewController{
           //show TVHomePage screen with transition
           let viewController = UIStoryboard(name: "TVHomeScreen", bundle: nil).instantiateViewController(identifier: "TVHomePageViewController") as TVHomePageViewController
           viewController.shiftID = screenTypeID
           viewController.delegate = self
           return viewController
       }
    
    //CMAIOS-2399, CMAIOS-2596
    func getWIFIPageController(screenTypeID: String) -> MyWiFiViewController{
           //show TVHomePage screen with transition
           let viewController = UIStoryboard(name: "WiFiScreen", bundle: nil).instantiateViewController(identifier: "MyWiFiScreen") as MyWiFiViewController
           viewController.shiftID = screenTypeID
           viewController.delegate = self
           viewController.outageTitle = OutageDescription.OutageTvHomePage
           viewController.outageCardData = SpotLightsManager.shared.checkIfOutageCardExists(isFromWiFiJumpLink: false).1
           return viewController
       }
    func getMyAccountsController(screenTypeID: String) -> MyAccountViewController{
           //show MyAccount screen with transition
           let viewController = UIStoryboard(name: "MyAccount", bundle: nil).instantiateViewController(identifier: "myAccountViewController") as MyAccountViewController
           let appDel = UIApplication.shared.delegate as? AppDelegate
           appDel?.acccountVC = viewController
           viewController.shiftID = screenTypeID
           viewController.delegate = self
           return viewController
       }
    
    func mockNavigation() {
        guard let vc = PaymentHistoryViewController.instantiateWithIdentifier(from: .billing) else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func applyAnimationAfterDismiss() {
        UIView.animate(withDuration: 0.4) {
            //self.animationHelperView.alpha = 1.0
            self.collectionView.alpha =  1.0
            self.spotlightCollectionView.alpha = 1.0
            self.quickPayImgView.alpha = 1.0
            self.myWiFiImgView.alpha = 1.0
            self.tvImgView.alpha = 1.0
            self.myAccountImgView.alpha = 1.0
            self.lblMyWiFi.alpha = 1.0
            self.lblTV.alpha = 1.0
            self.lblQuickPay.alpha = 1.0
            self.lblMyAccount.alpha = 1.0
            self.controlWiFi.alpha = 1.0
            self.controlQuickPaY.alpha = 1.0
            self.controlMyAccount.alpha = 1.0
            self.controlTV.alpha = 1.0
            self.btnMyWifi.backgroundColor = .clear
            self.btnQuickPay.backgroundColor = .clear
            self.btnTV.backgroundColor = .clear
        } completion: { complete in
            // modifications
            self.setupInitialUI()
        }
    }
    
    // MARK: - Quick Pay jump link
    func showQuickPayViewController() {
        self.animateSalutation(hideContent: true, screenTypeID: "QuickPayScreen")
    }
    
    // MARK: - DismissingChildViewcontroller Delegate Methods
    func childViewcontrollerGettingDismissed(profileDetail : Profile) {
        self.fetchProfilesList()
        QuickPayManager.shared.removePdfFile()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // CMAIOS-2543
            self.initialSetupForBillPayCards()
        }
//        SpotLightsManager.shared.configureSpotLightsForOutage(MyWifiManager.shared.outageTitle)
        //remove added bgView for profileIcon animation
        let animationIconView = self.view.viewWithTag(101)
        let bgAnimationView = self.view.viewWithTag(1000)
        let alphabetView = self.view.viewWithTag(102)
        let bgColor = UIColor(red: 232.0/255.0, green: 233.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        self.animateProfileAvatarIconFromTopToBottom(toView: UIView(), profileDetail: profileDetail , color: bgColor, animateFromVC: AnimateFrom.Home) { isAnimationCompleted, _  in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                bgAnimationView?.alpha = 0.0
                bgAnimationView?.removeFromSuperview()
                animationIconView?.removeFromSuperview()
                alphabetView?.removeFromSuperview()
//                animationProfileIconView?.removeFromSuperview()
                self.setAlphaForUIElements(alpha: 1.0)
            }
        }
    }
        
    // MARK: - DismissingChildViewcontroller Delegate Methods
    func childViewcontrollerGettingDismissed(profileDetail : Profile, index: Int?, fromView: ProfileDetailsTableViewCell?) {
        // From profiles
        self.fetchProfilesList()
        QuickPayManager.shared.removePdfFile()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.initialSetupForBillPayCards()
        }
//        SpotLightsManager.shared.configureSpotLightsForOutage(MyWifiManager.shared.outageTitle)
        if collectionView.visibleCurrentCellIndexPath.contains(index!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animateForDismissedProfile(profileDetail: profileDetail, index: index, fromView: fromView)
            }
        } else {
            self.collectionView.dataSource = nil
            self.collectionView.dataSource = self
            //                self.collectionView.delegate = self
            self.collectionView.reloadData()
            //                self.collectionView.layoutIfNeeded()
            if let cellIndex = index {
                self.collectionView.scrollToItem(at: IndexPath(item: cellIndex, section: 0), at: .centeredHorizontally, animated: false)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animateForDismissedProfile(profileDetail: profileDetail, index: index, fromView: fromView)
            }
        }
                
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            //remove added bgView for profileIcon animation
//            let animationIconView = self.view.viewWithTag(101)
//            let bgAnimationView = self.view.viewWithTag(1000)
//            let alphabetView = self.view.viewWithTag(102)
//            let bgColor = UIColor(red: 232.0/255.0, green: 233.0/255.0, blue: 231.0/255.0, alpha: 1.0)
//            var currentCell:DeviceCollectionViewCell!
//            if let profileIndex = index, let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: profileIndex, section: 0)) as? DeviceCollectionViewCell {
//                currentCell = collectionCell
//            } else {
//                let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? DeviceCollectionViewCell
//                currentCell = collectionCell
//            }
//            self.animateProfileAvatarIconFromTopToBottomHome(toView: currentCell, fromView: fromView, profileDetail: profileDetail , color: bgColor, animateFromVC: AnimateFrom.Home) { isAnimationCompleted in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    bgAnimationView?.alpha = 0.0
//                    bgAnimationView?.removeFromSuperview()
//                    animationIconView?.removeFromSuperview()
//                    alphabetView?.removeFromSuperview()
//                    self.setAlphaForUIElements(alpha: 1.0)
//                }
//            }
//        }
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.reloadSpotlights()
        }
    }
    
    func animateForDismissedProfile(profileDetail : Profile, index: Int?, fromView: ProfileDetailsTableViewCell?) {
        let animationIconView = self.view.viewWithTag(101)
        let bgAnimationView = self.view.viewWithTag(1000)
        let alphabetView = self.view.viewWithTag(102)
        let bgColor = UIColor(red: 232.0/255.0, green: 233.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        var currentCell:DeviceCollectionViewCell!
        if let profileIndex = index, let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: profileIndex, section: 0)) as? DeviceCollectionViewCell {
            currentCell = collectionCell
        } else {
            let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? DeviceCollectionViewCell
            currentCell = collectionCell
        }
        self.animateProfileAvatarIconFromTopToBottomHome(toView: currentCell, fromView: fromView, profileDetail: profileDetail , color: energyBlueRGB) { isAnimationCompleted, imageType in
            
               if imageType == .avatarIcon {
                  alphabetView?.removeFromSuperview()
               } else if imageType == .alphabet {
                  animationIconView?.removeFromSuperview()
               } else {
                   alphabetView?.removeFromSuperview()
                   animationIconView?.removeFromSuperview()
               }
                UIView.animate(withDuration: 0.4) {
                    bgAnimationView?.alpha = 0.0
                    self.setAlphaForUIElements(alpha: 1.0)
                } completion: { _ in
                    bgAnimationView?.removeFromSuperview()
                    animationIconView?.removeFromSuperview()
                    alphabetView?.removeFromSuperview()
                }
        }
    }
    
    func updateAvatarIconAfterProfileEdit(profileDetail: Profile?, completionHanlder: @escaping (Bool) -> Void) {
        self.updateAvatarAfterEditForBackwardAnimation(updatedProfileDetail: profileDetail, animatingVC: .Home){
            isAnimationCompleted in
            completionHanlder(true)
        }
    }
    
    func childViewcontrollerGettingDismissed() {
        self.fetchProfilesList()
        if MyWifiManager.shared.hasBillPay() {
//            self.performSpotlightRequests()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // CMAIOS-2543
                self.initialSetupForBillPayCards()
            }
        }
        QuickPayManager.shared.removePdfFile()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
//        SpotLightsManager.shared.configureSpotLightsForOutage(MyWifiManager.shared.outageTitle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //show FadeIn effect while transtion from MyAccountVC to HomeVC
            self.applyAnimationAfterDismiss()
            self.reloadSpotlights()
        }
        addQualtricsAction()
    }
    
    func performSpotlightRequests() {
        APIRequests.shared.mauiGetSpotLightCards(completionHandler: { success, value, error in
            self.checkBillPayDataForSpotlight()
            //self.refreshBillPayCards()
        })
    }
    
    func hideDismissedSpotlightcards(spotLightId: String, cardName: String, isReloadRequired: Bool = false) {
        if !spotLightId.isEmpty, let spCards = SpotLightsManager.shared.spotLightCards, let cards = spCards.cards, !cards.isEmpty {
            if let index = SpotLightsManager.shared.spotLightCards.cards!.firstIndex(where: {$0.id == spotLightId  && $0.name == cardName && $0.wasDismissed == false}) {
                SpotLightsManager.shared.spotLightCards.cards![index].wasDismissed = true
                self.updateSpotlightCardsRequest(cards: SpotLightsManager.shared.addParams(cards:[SpotLightsManager.shared.spotLightCards.cards![index]], isViewed: false))
            } else if let index = SpotLightsManager.shared.spotLightCards.cards!.firstIndex(where: {$0.id == spotLightId && $0.wasDismissed == false}) {
                SpotLightsManager.shared.spotLightCards.cards![index].wasDismissed = true
                self.updateSpotlightCardsRequest(cards: SpotLightsManager.shared.addParams(cards:[SpotLightsManager.shared.spotLightCards.cards![index]], isViewed: false))
                if isReloadRequired {
                    checkBillPayDataForSpotlight()
                }
                /*
                if spotLightId == "billingDiscount1" { //CMAIOS-2680
                    SpotLightsManager.shared.spotLightCards.cards![index].dismissalWindow = 60
                    self.updateSpotlightCardsRequest(cards: SpotLightsManager.shared.addParams(cards:[SpotLightsManager.shared.spotLightCards.cards![index]], isViewed: true))
                } else {
                    self.updateSpotlightCardsRequest(cards: SpotLightsManager.shared.addParams(cards:[SpotLightsManager.shared.spotLightCards.cards![index]], isViewed: false))
                }
                 */
            }
        }
    }
    
    /*
    func updateSpotlightCardsRequest(cards: NSMutableArray) {
        var params = [String:AnyObject]()
        params["cards"] = cards as AnyObject
        APIRequests.shared.mauiUpdateSpotLightCards(params: params) { success, value, error in
            self.performSpotlightRequests()
        }
    }
     */
    
    func addQualtricsAction(){
        self.qualtricsAction = self.checkQualtricsOnLaunchOfHomeScreen(screenName: "HomeScreen", dispatchBlock: &qualtricsAction)
    }
         
    func refreshBillPayCards() {
        if !APIRequests.shared.isAccountSignedOut {
            DispatchQueue.main.async {
                QuickPayManager.shared.delegate = self
//                self.mauiOutageAlertApiRequest(reloadOutageCard: false)
//                self.mauiBillAccountActivityApiRequest()
            }
        }
    }
    
//    func mauiOutageAlertApiRequest(reloadOutageCard: Bool) {
//        // For CMAIOS-2269 To not Call the outage alert API before OP call response
//        if MyWifiManager.shared.lightSpeedAPIState == .opCallInProgress {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.mauiOutageAlertApiRequest(reloadOutageCard: true)
//            }
//            return
//        }
//        APIRequests.shared.mauiOutageAlertRequest(interceptor: nil) { success, value, error in
//            DispatchQueue.main.async {
//                if success {
//                    QuickPayManager.shared.modelQuickPayeOutage = value
//                    MyWifiManager.shared.checkForOutages()
//                    self.checkOutageDataForSpotlight()
//                    if reloadOutageCard {
//                        self.reloadSpotlights()
//                    }
//                    Logger.info("Outage Alert Response is \(String(describing: value))",sendLog: "Outage Alert success" )
//                } else {
//                    Logger.info("Outage Alert failure: \(String(describing: error))")
//                    // Error scenario
//                }
//            }
//        }
//    }
    
    private func initalLaunchBillApiSetup() {
        /*
         if self.firstLaunch {
         self.firstLaunch = false
         self.mauiGetListPaymentApiRequest()
         } else {
         self.mauiBillAccountActivityApiRequest()
         }
         */
        self.checkMauiApiStateForRefresh()
        if self.firstLaunch {
            self.firstLaunch = false
        }
    }
    
    /// Proceed Maui Bill pay apis if entitlement is enable, hasBillPay == true
    private func initialSetupForBillPayCards() {
        if MyWifiManager.shared.hasBillPay() {
            self.initialLaunchSpotlightRefresh()
            self.initalLaunchBillApiSetup()
        }
    }
    
    /// First lauch should refresh bill pay cards once we get all the dependant API datas
    /// So, skip updateSpotlightTypeForBillPayCards for first launch
    private func initialLaunchSpotlightRefresh() {
        if !self.firstLaunch {
            self.updateSpotlightTypeForBillPayCards()
        }
    }
    
    /*
    private func mauiBillAccountActivityApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        QuickPayManager.shared.ismauiMainApiInProgress.isprogress = true
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity: \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiGetListPaymentApiRequest()
                } else {
                    self.validateAndResetFlagsOnLogout()
                    Logger.info("Get Account Bill Activity failure: \(String(describing: error))")
                    // Error scenario
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = billSharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: billSharedManager.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                    self.checkGetBillAccountApiStateForRetry()
                } else {
                    self.validateAndResetFlagsOnLogout()
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                }
            }
        })
    }
    
    private func mauiGetBillAccountApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = billSharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: billSharedManager.interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.checkBillPayDataForSpotlight()
                    QuickPayManager.shared.ismauiMainApiInProgress = (false, false)
                } else {
                    self.validateAndResetFlagsOnLogout()
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                }
            }
        })
    }
     */
    
    func validateAndResetFlagsOnLogout() {
        self.removeLoaderView()
//        QuickPayManager.shared.ismauiMainApiInProgress.isprogress = false
//        QuickPayManager.shared.ismauiMainApiInProgress.iserror = true
//        if APIRequests.shared.isAccountSignedOut {
//            QuickPayManager.shared.ismauiMainApiInProgress.iserror = false
//            QuickPayManager.shared.ismauiMainApiInProgress.isprogress = true
//        }
    }
    
    /// If Get Bill Account Failed, Retry the api again
    /*
    private func checkGetBillAccountApiStateForRetry() {
        self.mauiGetBillAccountApiRequest()
        self.checkListBillsApiStateForRetry()
    }
     */
    
    /// If List Bills Failed, Retry the api again
    private func checkListBillsApiStateForRetry() {
        if !QuickPayManager.shared.isListBillsCompeletd {
            QuickPayManager.shared.mauiListBillsRequest()
        }
    }
     
    ///  Spotlight should be updated w.r.t below status of  below models
    func checkBillPayDataForSpotlight() {
        // use
        // QuickPayManager.shared.modelQuickPayeOutage
        // QuickPayManager.shared.modelQuickPayGetBillActivity
        // QuickPayManager.shared.modelQuickPayGetAccountBill
        self.updateSpotlightTypeForBillPayCards()
        self.reloadSpotlights()
    }
    
    private func updateSpotlightTypeForBillPayCards() {
        QuickPayManager.shared.setNotificationType()
        SpotLightsManager.shared.configureSpotLightsForBillPay()
    }
    
    /// Handle Maui api error code 500...
    func handleErrorBillPayApis() {
        /*
         if !billSharedManager.mandatoryDataAvailable() {
         QuickPayManager.shared.ismauiMainApiInProgress = (false, true)
         }
         APIRequests.shared.isGetAccountBillApiFailed = true
         */
        
        // CMAIOS-2543
        DispatchQueue.main.async {
            self.updateFlagForFailedMauiApiCall()
            self.removeLoaderView()
            if (QuickPayManager.shared.isMauiAccountListCompleted == false ||
                QuickPayManager.shared.isGetAccountActivityCompleted == false ||
                QuickPayManager.shared.isListBillsCompeletd == false ||
                QuickPayManager.shared.isGetAccountBillCompleted == false) {
            }
            self.performFailedSpotlightCardsRequest()
        }
    }
        
    ///  Spotlight should be updated w.r.t below status on the outage model
    private func checkOutageDataForSpotlight() {
//        SpotLightsManager.shared.configureSpotLightsForOutage(MyWifiManager.shared.outageTitle)
    }
    
    func presentErrorMessageVCForRFOutage() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .wifi_home_rfOutage_failure)
            vc.isComingFromProfileCreationScreen = true
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    func pushChatVC(withIntentData:[String:Any]?) {
        self.isChatPresented = true
        self.view.backgroundColor = .white
        APIRequests.shared.isReloadNotRequiredForMaui = true
        var chatViewController : UIViewController?
        if withIntentData != nil {
            chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: withIntentData ?? [:])
        } else {
            chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil)
        }
        guard let chatVC = chatViewController else {
            return }
        chatVC.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatTransitionType: .Push, chatVC: chatVC)
    }
    
    func clickToAdChat() {
        DispatchQueue.main.async {
            var chatViewController : UIViewController?
            chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil)
            guard let chatVC = chatViewController else {
                return }
            chatVC.modalPresentationStyle = .fullScreen
            self.trackAndNavigateToChat(chatTransitionType: .Push, chatVC: chatVC)
        }
    }
}

//extension HomeScreenViewController: MauiApisStatusDelegate {
//    func apiRequestSuccess(type: ApiType) { }
//    
//    func apiRequestFailure(type: ApiType) { }
//    
//    func sequenceApiStatus(isCompleted: Bool) { }
//}

extension HomeScreenViewController: ProfileManagerDelegate {
    func updateStatusForPausedProfiles() {
        guard MyWifiManager.shared.pausedProfileIds.isEmpty == false else { return }
        DispatchQueue.main.async {
            self.fetchAndLoadProfileStatus()
//            ProfileModelHelper.shared.getAllAvailableProfiles { profiles in
//                self.allProfiles = profiles ?? []
//                self.collectionView.reloadData()
//            }
        }
    }
}

// MARK: ReAuth Refresh
extension HomeScreenViewController {
    func refreshAfterReAuthOnTimeExpiry(category: ReAuthCategory) {
        switch category {
        case .spotlightCard:
            self.navigateToBillPay()
        case .jumpLink:
            self.showQuickPayViewController()
        case .billingMenu: break
        }
    }
}

extension UICollectionView {
    func reloadWithoutAnimation(){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.reloadData()
        CATransaction.commit()
    }
}
extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
extension HomeScreenViewController: GoogleAdLoadHandler {
    func didFailToLoadAd() {
        SpotLightsManager.shared.configureSpotLightsForThankYou()
        DispatchQueue.main.async {
            self.reloadSpotlights()
        }
    }
    
    func didReceiveAdObjects() {
        SpotLightsManager.shared.configureSpotLightsForGoogleAd()
        DispatchQueue.main.async {
            self.reloadSpotlights()
        }
    }    
}
