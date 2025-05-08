//
//  ViewProfileWithDeviceViewController.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

import UIKit
import Lottie

//protocol declaration to handle animation on presenting controller
protocol HandleAnimationInParentView {
    func childViewcontrollerGettingDismissed(profileDetail:Profile, index: Int?, fromView: ProfileDetailsTableViewCell?)
    func updateAvatarIconAfterProfileEdit(profileDetail:Profile?,
                                          completionHanlder: @escaping (_ isAnimationCompleted:Bool) -> Void)
}

enum PauseAPIState: String{
    case progress = "progress"
    case none = "none"
}

class ViewProfileWithDeviceViewController: UIViewController {
    
    //View Outlet Connections
    @IBOutlet weak var vwFullBackground: UIView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwCloseContainer: UIView!
    //Button Outlet Connections
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var profile:ProfileModel?
    var arrProfiles: Profiles?
    var delegate : HandleAnimationInParentView?
    var hasDevice:(Bool, [LightspeedNode]?) = (false,nil)
    var currentSelectedIndex:Int?
    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet weak var vwContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var vwContainerBottomConstraint: NSLayoutConstraint!
    var currentSelectedProfileIndex: Int?
    @IBOutlet weak var viewBgPauseInternet: UIView!
    var isAvatarIdChanged: Bool = false
    
    @IBOutlet weak var vwSeparator: UIView!
    @IBOutlet weak var vwPauseInternetHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnPauseForAnHour: UIButton!
    @IBOutlet weak var btnPauseForUntilTomorrow: UIButton!
    @IBOutlet weak var vwPauseInternet: UIView!
    @IBOutlet weak var saveCancelBottomView: UIView!
    @IBOutlet weak var saveCancelAnimationView: LottieAnimationView!
    @IBOutlet weak var animationBottomView: LottieAnimationView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    private var progressReloadIndex: Int? = nil
    var isSave = false
    var isCancel = false
    var isErrorViewPresent = false
    var avalilablePauseTimers: [PauseSchedule] = []
    var profilePauseAPIState: PauseAPIState = .none
    @IBOutlet weak var vwCloseTopConstraint: NSLayoutConstraint!
    var currentContentOffSet : CGPoint = CGPointZero
    var currentSelectedDeviceIndex : Int = 0
    var currentSelectedMacAddress : String = ""
    var qualtricsAction : DispatchWorkItem?
    
    var presentProfile : ProfileModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = energyBlueRGB
        self.profile = self.arrProfiles?[currentSelectedIndex ?? 0]
        // Do any additional setup after loading the view.
        setUIAttributes()
        setCollectionViewDelegateDataSources()
        //set initial values for PullToRefresh
        initialUIConstantsForPullToRefresh()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(notification:)), name: NSNotification.Name(rawValue: "UpdateProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateOnlineActivity(notification:)), name: NSNotification.Name(rawValue: "UpdateOnlineActivity"), object: nil)
        vwPauseInternet.layer.cornerRadius = 10.0
        vwSeparator.layer.shadowColor = UIColor.gray.cgColor
        vwSeparator.layer.shadowOpacity = 0.5
        vwSeparator.layer.shadowRadius = 5
        self.saveCancelBottomView.addTopShadow()
        self.saveCancelBottomView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(hideShowBottomView(notification:)), name: NSNotification.Name(rawValue: "HideShowSaveCancelBottomView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showErroView(notification:)), name: NSNotification.Name(rawValue: "ShowErrorView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBlueBGViewWithoutAnimation), name: NSNotification.Name(rawValue: "RemoveBGAnimationView"), object: nil)
        self.setNeedsStatusBarAppearanceUpdate()
        profile = self.arrProfiles?[pageControl.currentPage]
    }
    
    func addQualtrics(screenName:String){
        qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    @objc func showErroView(notification:NSNotification)
    {
        self.isErrorViewPresent = true
        self.saveCancelBottomView.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func hideShowBottomView(notification:NSNotification) {
        if isSave{
            if self.saveCancelBottomView.isHidden{
                self.saveCancelBottomView.isHidden = false } else {
               self.saveCancelBottomView.isHidden = true
            } } else {
            self.saveCancelBottomView.isHidden = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
       // self.getCurrentPauseTimerData()
        trackAnalytics()
        self.avalilablePauseTimers = ProfileManager.shared.getPauseScheduleFor(pid: profile?.pid ?? 0) ?? []
        if MyWifiManager.shared.refreshLTDataRequired == true {
            MyWifiManager.shared.refreshLTDataRequired = false
            if MyWifiManager.shared.isGateWayWifi6(){
                self.refreshPausedDevices()
            }
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qualtricsAction?.cancel()
    }
    
    @IBAction func onClickBtnPauseForAnHour(_ sender: Any) {
        self.triggerPauseDevice(endTime: Date(timeIntervalSinceNow: 3600), isProfilePause: true)
        performPauseUnpauseAction()
    }

    @IBAction func onClickBtnPauseForTomorrow(_ sender: Any) {
        performPauseUnpauseAction()
    }
    
    func getCurrentPauseTimerData() {
        APIRequests.shared.initiateGetAccessProfileRequest(pid: self.profile?.pid ?? 0) { success, response, error in
            if success {
                Logger.info("Get Access Profile success")
            }
        }
    }
    
    func performPauseUnpauseAction() {
        self.vwPauseInternetHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        self.vwPauseInternet.isHidden = true
        self.viewBgPauseInternet.isHidden = true
        self.btnPauseForAnHour.isHidden = true
        self.btnPauseForUntilTomorrow.isHidden = true
        self.vwSeparator.isHidden = true
        self.handleUIForPauseUnpauseInternet(isPausedUntilTomorrow: true)
    }
    
    func triggerPauseDevice(endTime: Date, isProfilePause: Bool) {
//        guard let rules = ProfileManager.shared.createRestrictionRuleForProfile(enabled: true, endTime: endTime.getDateStringForAPIParam(), startTime: Date().getDateStringForAPIParam(), days: []) else {
//            return
//        }
//        guard let params = ProfileManager.shared.schedulePauseForProfile(pid: self.profile?.pid ?? 0, rules: rules) else {
//            return
//        }
        APIRequests.shared.initiatePutAccessProfileRequest(pid:self.profile?.pid, macID: nil, enablePause:isProfilePause, pausedBy: APIRequests.PausedBy.profile) { success, response, error in
            if success {
                Logger.info("Put Access Profile success")
            } else if response == nil && error != nil {
                self.presentErrorMessageVCForPauseProfile(isPauseProfile: isProfilePause)
            }
        }
    }
    
    func callInstantPause(enable:Bool, pausedPID:Int) {
        APIRequests.shared.initiatePutAccessProfileRequest(pid: pausedPID, macID: nil, enablePause: enable, pausedBy: APIRequests.PausedBy.profile) { success, response, error in
            self.profilePauseAPIState = .none
            if success {
                Logger.info("Put Access Profile success")
                self.refreshPausedDevices()
            } else if response == nil && error != nil {
                self.presentErrorMessageVCForPauseProfile(isPauseProfile: enable)
            }
        }
    }

    func refreshPausedDevices() {
        APIRequests.shared.initiateGetAccessProfileByClientRequest { success, response, error in
            if success {
                MyWifiManager.shared.pausedClientData = response
                ProfileModelHelper.shared.updateProfileDeviceStatusUsingLTData { arrProfileWithDeviceStatus in
                    self.arrProfiles = arrProfileWithDeviceStatus
                    DispatchQueue.main.async {
                        let index = self.pageControl.isHidden ? 0 : self.pageControl.currentPage
                           if let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ProfileDetailCell {
                               collectionCell.profile = self.arrProfiles?[index]
                               collectionCell.tblView.reloadRows(at:[IndexPath(row: 0, section:2) ], with: .none)
                        }
                    }
                }
            } else {
                Logger.info("Get Access Profile API failure")
            }
            self.enablePauseProfileBtnInteraction()
        }
    }
    
    func presentErrorMessageVCForPauseProfile(isPauseProfile : Bool) {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
            vc.isComingFromProfileCreationScreen = false
            vc.modalPresentationStyle = .fullScreen
            if isPauseProfile {
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_pauseinternet_for_profile_apifailure)
            } else {
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_unpause_internet_failureforProfile)
                }
            self.present(vc, animated: true)
        }
    }
    
    func handleUIForPauseUnpauseInternet(isPausedUntilTomorrow:Bool){
        var currentSelectedIndex : Int = 0
        if !pageControl.isHidden {
            currentSelectedIndex = pageControl.currentPage
        }
        if var profileObj = self.arrProfiles?[currentSelectedIndex], let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: currentSelectedIndex, section: 0)) as? ProfileDetailCell, let detailCell = collectionCell.tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileDetailsTableViewCell{
            profileObj.profileStatus = .paused//isPausedUntilTomorrow ? .pausedUntilTomorrow : .paused
            detailCell.profileIconLottieView.animation = LottieAnimation.named(" ")
            collectionCell.profile = profileObj
            self.arrProfiles?[self.pageControl.currentPage] = profileObj
            collectionCell.isPauseUnpauseTapped = true
            //get BG color on basis of Pause
            let bgColor = self.getColorForPauseUnpauseInternetState(profileModel: collectionCell.profile)
            collectionCell.backgroundColor = bgColor
            collectionCell.vwHeader.backgroundColor = bgColor
            collectionCell.tblView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }
    
    func enablePauseProfileBtnInteraction(){
        var currentSelectedIndex : Int = 0
        DispatchQueue.main.async {
            if !self.pageControl.isHidden {
                currentSelectedIndex = self.pageControl.currentPage
            }
            if let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: currentSelectedIndex, section: 0)) as? ProfileDetailCell, let pauseProfileCell = collectionCell.tblView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PauseInternetTableViewCell {
                pauseProfileCell.btnPauseInternet.isUserInteractionEnabled = true
            }
        }
    }
    
    //MARK: UpdateProfile After Editing ProfileDetails
    @objc func updateProfile(notification: NSNotification) {
        let dict = notification.userInfo
        let updatedProfileObj = dict?["profile"] as? Profile
        self.profile?.profile = updatedProfileObj
        if let row = self.arrProfiles?.firstIndex(where: {$0.pid == updatedProfileObj?.pid}){
            var oldProfileDetail = self.arrProfiles?[row]
            if oldProfileDetail?.profile?.avatar_id != updatedProfileObj?.avatar_id {
                isAvatarIdChanged = true
            }
            if oldProfileDetail?.profile?.profile != updatedProfileObj?.profile, let devices = oldProfileDetail?.devices, !devices.isEmpty {
                if let presentingController = self.parent?.presentingViewController?.presentingViewController, presentingController.isKind(of: MyWiFiViewController.self) {
                    for node in devices {
                        MyWifiManager.shared.saveProfileChangeLocally(for: node.device?.mac ?? "", profileName: updatedProfileObj?.profile, pid: updatedProfileObj?.pid ?? 0)
                    }
                }
            }
            oldProfileDetail?.profile = updatedProfileObj
            oldProfileDetail?.profileName = updatedProfileObj?.profile ?? ""
            oldProfileDetail?.avatarImage = Avatar().getAvatarImage(for: updatedProfileObj?.avatar_id ?? 13, name:updatedProfileObj?.profile ?? "" )
            self.arrProfiles?[row]  = oldProfileDetail!
            let index = self.pageControl.isHidden ? 0 : self.pageControl.currentPage
            self.collectionView.reloadItems(at: [IndexPath(row:index , section: 0)])
        }
    }

    ///Method for updating UI after LiveTopologyAPI success/failure
    @objc func pullToRefreshIsCompleted() {
        self.pullToRefresh(hideScreen: true, isComplete: true)
    }
    
    @objc func updateOnlineActivity(notification: NSNotification) {
        self.collectionView.reloadData()
    }
    
    //MARK: PullToRefresh methods

    ///Method for initial constants in pull to refresh animation
    func initialUIConstantsForPullToRefresh(){
        self.vwPullToRefresh.isHidden = true
        self.vwPullToRefreshCircle.isHidden = true
        self.vwPullToRefreshHeight.constant = 0
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
    }
    
    ///Method for pull to refresh animation
    @objc func pullToRefresh(hideScreen hide:Bool, isComplete: Bool = false) {
        vwPullToRefresh.isHidden = false
        vwPullToRefreshCircle.isHidden = false
        self.vwPullToRefreshAnimation.isHidden = false
        self.vwPullToRefreshAnimation.animation = LottieAnimation.named("AutoLogin")
        self.vwPullToRefreshAnimation.backgroundColor = .clear
        self.vwPullToRefreshAnimation.loopMode = !isComplete ? .loop : .playOnce
        self.vwPullToRefreshAnimation.animationSpeed = 1.0
        var index : Int = 0
        if !self.pageControl.isHidden {
            index = self.pageControl.currentPage
        }
        let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ProfileDetailCell
        //Handle background color of mainView during pullToRefresh
          self.view.backgroundColor = collectionCell?.backgroundColor
        if !hide {
        //Handle overlapping of vwHeader with ProfileAvatar during pulltoRefresh
            collectionCell?.vwHeader.isHidden = true
            UIView.animate(withDuration: 0.5) {
                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                if UIDevice.current.hasNotch && currentScreenWidth  > 390.0 {
                    self.vwContainerTopConstraint.constant = 150
                    self.vwContainerBottomConstraint.constant = -120
                    //self.vwCloseTopConstraint.constant = -230
                    self.vwCloseTopConstraint.constant = -223
                } else {
                    self.vwContainerTopConstraint.constant = 120
                    self.vwContainerBottomConstraint.constant = -78
                    self.vwCloseTopConstraint.constant = -180
                }
                self.collectionView.isUserInteractionEnabled = false
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                UIView.animate(withDuration: 0.5) {
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshAnimation.isHidden = true
                    self.vwPullToRefreshTop.constant = 80
                    self.vwPullToRefreshHeight.constant = 0
                    self.vwContainerTopConstraint.constant = 40
                    self.vwContainerBottomConstraint.constant = 0
                    self.vwCloseTopConstraint.constant = UIDevice.current.hasNotch ? -103 : -101
                    self.view.layoutIfNeeded()
                    self.collectionView.isUserInteractionEnabled = true
                } completion: { _ in
                    // index needed
                    //Handle overlapping of vwHeader with ProfileAvatar during pulltoRefresh
                    collectionCell?.vwHeader.isHidden = false
                    guard let index = self.progressReloadIndex else {
                        return
                    }
                    self.collectionView.reloadItems(at: [IndexPath(row: index, section:0)])
                }
            }
        }
    }
    
    func performGetAllNodesRequestForRefresh() {
        var currentProfiles = self.arrProfiles ?? []
        APIRequests.shared.getAllNodes { result in
            guard case let .success(nodes) = result else {
                self.arrProfiles = currentProfiles
                ProfileModelHelper.shared.profiles = self.arrProfiles
                return
            }
            for (index, device) in currentProfiles.enumerated() {
                let node = nodes.filter { $0.pid == device.pid ?? 0 }.compactMap {
                    DeviceNode(status: nil, device: $0)
                }
                currentProfiles[index].devices = node
            }
            self.arrProfiles = currentProfiles
            ProfileModelHelper.shared.profiles = self.arrProfiles
        }
    }
    
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        // After Refresh
        performGetAllNodesRequestForRefresh()
        if MyWifiManager.shared.isOperationalStatusOnline {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            APIRequests.shared.initiateLiveTopologyRequest { _, _, _ in
                dispatchGroup.leave()
            }
            dispatchGroup.enter()
            APIRequests.shared.initiateClientUsageRequest(){ success, response, error in
                Logger.info("",shouldLogContext: success)
                MyWifiManager.shared.isClientUsageAPISucceeded = success
                if success {
                    if let usageData = response?.clients as [ClientUsageResponse.Client]? {
                        MyWifiManager.shared.saveClientUsageData(value: usageData)
                        //Update device connectedTime
                        ProfileModelHelper.shared.updateProfileDeviceConnectedTime(onlineActivityData: usageData)
                        { profiles in
                            ProfileModelHelper.shared.profiles = profiles
                        }
                    }
                } else {
                    MyWifiManager.shared.clientUsage = nil
                }
                dispatchGroup.leave()
            }
            /*if MyWifiManager.shared.isGateWayWifi6() {
             dispatchGroup.enter()
             APIRequests.shared.initiateGetAccessProfileRequest(pid: self.profile?.pid ?? 0, completionHandler: { _, _, _ in
             dispatchGroup.leave()
             })
             dispatchGroup.enter()
             APIRequests.shared.initiateGetAccessProfileByClientRequest { success, response, error in
             if success {
             Logger.info("Get Access Profile API success")
             MyWifiManager.shared.pausedClientData = response
             } else {
             Logger.info("Get Access Profile API failure")
             }
             dispatchGroup.leave()
             }
             }*/
            dispatchGroup.notify(queue: .main){
                ProfileModelHelper.shared.getProfileDeviceStatusBasedOnLTResponse { arrProfileWithDeviceStatus in
                    self.updateProfileDetailData(profilesData: arrProfileWithDeviceStatus)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let index = self.pageControl.isHidden ? 0 : self.pageControl.currentPage
                if let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ProfileDetailCell {
                    collectionCell.isPullToRefreshIsInProgress = false
                }
                self.pullToRefreshIsCompleted()
            }
        }
    }
    
    func updateProfileDetailData(profilesData: Profiles?){
        self.arrProfiles = profilesData
        progressReloadIndex = self.pageControl.isHidden ? 0 : self.pageControl.currentPage
        self.pullToRefreshIsCompleted()
    }
    
    func setCollectionViewDelegateDataSources() {
        self.setBasicPaginationAttributes()
        //set delegate and dataSource and render data in collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        //scroll collection to selected index
        if let selectedIndex = self.currentSelectedIndex, selectedIndex > 0{
                self.collectionView.isPagingEnabled = false
                self.collectionView.scrollToItem(at: IndexPath(row: selectedIndex , section: 0), at: .centeredHorizontally, animated: false)
                self.collectionView.isPagingEnabled = true
        }
    }
    //Method for showing shadow at bottom
    func showShadowForCarousel() {
        vwCloseContainer.layer.shadowColor = UIColor.gray.cgColor
        vwCloseContainer.layer.shadowOpacity = 0.5
        vwCloseContainer.layer.shadowRadius = 5
    }
    
    //Method for setting Pagination Attributes
    func setBasicPaginationAttributes() {
        if let count = arrProfiles?.count, count > 1 {
           pageControl.numberOfPages = count
           pageControl.isHidden = false
           pageControl.currentPage = currentSelectedIndex ?? 0
           collectionView.isPagingEnabled = true
        } else {
            pageControl.isHidden = true
            collectionView.isPagingEnabled = false
        }
        showShadowForCarousel()
    }
    
    ///Method for setting UI attributes
    func setUIAttributes() {
        pageControl.pageIndicatorTintColor = UIColor(red: 0.71, green: 0.75, blue: 0.82, alpha: 1.00) // notfilled
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.00, green: 0.16, blue: 0.39, alpha: 1.00) // filled
    }
    
    // MARK: - UIButton Action
    @IBAction func btnCloseTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        //set index to zero if arrProfiles.count == 1
        let index = pageControl.isHidden ? 0 : pageControl.currentPage
        let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ProfileDetailCell
        let tblCell = cell?.tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileDetailsTableViewCell
            UIView.animate(withDuration: 0.5) {
                cell?.pushDeviceListDown()
                self.animateCloseBtnViewToBottom()
            } completion: { _ in
                self.vwCloseTopConstraint.constant = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.navigationController?.popViewController(animated: false)
                    if let profileObj = cell?.profile?.profile {
                        if self.isAvatarIdChanged {
                            self.delegate?.updateAvatarIconAfterProfileEdit(profileDetail: profileObj){ isAnimationFinished in
                                self.delegate?.childViewcontrollerGettingDismissed(profileDetail: profileObj, index: index, fromView: tblCell)
                            }
                        } else {
                            self.delegate?.childViewcontrollerGettingDismissed(profileDetail: profileObj, index: index, fromView: tblCell)
                        }
                    }
                }
            }
    }
    
    @objc func editBtnAction() {
        
    }
    
    @IBAction func onValueChanged(_ sender: UIPageControl) {
        self.qualtricsAction?.cancel()
        if let profileModelObj = self.arrProfiles?[sender.currentPage], let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: sender.currentPage, section: 0)) as? ProfileDetailCell{
            let bgColor = self.getColorForPauseUnpauseInternetState(profileModel: profileModelObj)
            collectionCell.backgroundColor = bgColor
            collectionCell.vwHeader.backgroundColor = bgColor
        }
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
        if let profileModelObj = self.arrProfiles?[sender.currentPage] {
            self.delegate?.updateAvatarIconAfterProfileEdit(profileDetail: profileModelObj.profile){ _ in }
        }
        trackAnalytics()
    }
    
    func trackAnalytics() {
        let currentProfile = self.arrProfiles?[pageControl.currentPage]
        var event = ""
        if currentProfile?.isMaster == true {
            if currentProfile?.devices.count ?? 0 == 0 {
                event = ProfileEvent.Profiles_view_profile_masterprofile_nodevices.rawValue
                self.addQualtrics(screenName: ProfileEvent.Profiles_view_profile_masterprofile_nodevices.rawValue)
            }
            else {
                event = ProfileEvent.Profiles_viewprofile_with_devices.rawValue
                self.addQualtrics(screenName: ProfileEvent.Profiles_viewprofile_with_devices.rawValue)
            }
        } else {
            if currentProfile?.devices.count ?? 0 == 0 {
                event = ProfileEvent.Profiles_viewproile_householdprofile_nodevices.rawValue
                self.addQualtrics(screenName: ProfileEvent.Profiles_viewproile_householdprofile_nodevices.rawValue)
            } else {
                event = ProfileEvent.Profiles_viewprofile_with_devices.rawValue
                self.addQualtrics(screenName: ProfileEvent.Profiles_viewprofile_with_devices.rawValue)
            }
        }
        if event.isEmpty { return }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        //self.isSave = true
        if sender == saveBtn{
            self.isSave = true
            self.arrProfiles?.enumerated().forEach { (index, name) in
                guard let firstCell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ProfileDetailCell else { return }
                firstCell.isPreviousTimeSave = false
                firstCell.isPreviousWeekendTimeSave = false
                firstCell.updateTimerDataOnSave()
                DispatchQueue.main.async {
                    self.saveCancelBottomView.isHidden = true
                } }
        } else {
              self.arrProfiles?.enumerated().forEach { (index, name) in
                guard let firstCell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ProfileDetailCell else { return }
                if isSave {
                    //firstCell.updateTimerDataOnCancel()
                    firstCell.isPreviousTimeSave = true
                    firstCell.isPreviousWeekendTimeSave = true
                    if isErrorViewPresent{
                        firstCell.isCancelTapped = false
                        isErrorViewPresent = false
                    }else
                    {
                        firstCell.isCancelTapped = true
                    }
                    firstCell.updateTimerDataOnSave()
                } else {
                    firstCell.isPreviousTimeSave = false
                    firstCell.isPreviousWeekendTimeSave = false
                    firstCell.isCancelTapped = false
                    firstCell.updateTimerDataOnCancel()
                }
                DispatchQueue.main.async {
                    self.saveCancelBottomView.isHidden = true
                }
            }
        }
    }
    func showBottomView() {
        self.saveCancelBottomView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view == viewBgPauseInternet {
            self.vwPauseInternet.isHidden = true
            self.viewBgPauseInternet.isHidden = true
            self.vwPauseInternetHeightConstraint.constant = 0
        }
    }
    
    func getColorForPauseUnpauseInternetState(profileModel : ProfileModel?) -> UIColor{
        guard let profileObj = profileModel else {
            return energyBlueRGB }
        var color = UIColor()
        if profileObj.profileStatus == .paused {
            color =  pauseBgColor
        } else {
            color = energyBlueRGB
        }
        return color
    }
    
    //MARK: Navigation Methods
    func navigateToConnectedDeviceDetailScreen(deviceDetail:ConnectedDevice?) {
        let viewController = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(identifier: "ConnectedDeviceDetailVC") as ConnectedDeviceDetailVC
        viewController.deviceDetails = deviceDetail
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: false)
    }
    
    func updateCurrentSelectedDeviceIndex(selectedIndex:Int, deviceMac:String){
        //get currentSelected device and its mac address
        self.currentSelectedDeviceIndex = selectedIndex
        self.currentSelectedMacAddress = deviceMac
    }
    
    func reloadCurrentSelectedProfile(isProfileAssignmentChanged:Bool = false, with deviceImage: UIImage = UIImage(),isDeviceInfoUpdated:Bool = false ){
            //update current selected profile with updated data
            self.arrProfiles = ProfileModelHelper.shared.profiles
            let currentSelectedIndex = self.getCurrentSelectedProfileIndex()
            let selectedCell = self.getCurrentSelectedProfileCell()
            self.currentContentOffSet = selectedCell?.tblView.contentOffset ?? CGPointZero
            UIView.animate(withDuration: 0) {
                //CMAIOS-2311
                if isDeviceInfoUpdated || isProfileAssignmentChanged{
                    self.collectionView.reloadItems(at: [IndexPath(row: currentSelectedIndex, section: 0)])
                }
            } completion: { isCompleted in
                //Perform backward device icon animation only if the profileAssigment for selected device is not changed
                if !isProfileAssignmentChanged {
                    let updatedFrame = self.getUpdatedFrameForSelectedDevice()
                    self.performIconAnimationFromTopToBottom(updatedFrame: updatedFrame , image: deviceImage)
                }
            }
    }
    
    func getUpdatedIndexOfSelectedDeviceAfterEdit()->Int{
        //get updated device index after device name edit
        let currentSelectedCell = self.getCurrentSelectedProfileCell()
        let updatedDeviceIndex = currentSelectedCell?.arrConnectedDevices.firstIndex { device in
            device.macAddress.isMatching(self.currentSelectedMacAddress)
       }
        if let updatedIndex = updatedDeviceIndex {
            return updatedIndex
        }
        return self.currentSelectedDeviceIndex
    }
    
    func getCurrentSelectedProfileCell()-> ProfileDetailCell?{
           // get current selected profile
           let currentSelectedIndex = self.getCurrentSelectedProfileIndex()
           let selectedCell = self.collectionView.cellForItem(at: IndexPath(row: currentSelectedIndex, section: 0)) as? ProfileDetailCell
           return selectedCell
    }
    
    func getCurrentSelectedProfileIndex()-> Int{
        // get current selected profile Index
        var currentSelectedIndex = 0
        if !self.pageControl.isHidden {
            currentSelectedIndex = self.pageControl.currentPage
        }
        return currentSelectedIndex
    }
    
    func getUpdatedFrameForSelectedDevice()->CGRect{
        let selectedCell = self.getCurrentSelectedProfileCell()
        //CMAIOS-2311 set tableViewContent offset to retain the scroll position
        selectedCell?.tblView.setContentOffset(self.currentContentOffSet, animated: false)
        let updatedDeviceIndex = self.getUpdatedIndexOfSelectedDeviceAfterEdit()
        // get updated frame only if the index of selected device changes after edit else no change in the frame
        if updatedDeviceIndex != self.currentSelectedDeviceIndex {
            let connectedDeviceCell = selectedCell?.tblView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ConnectedDeviceCell
            var updatedFrame = connectedDeviceCell?.getFrameOfSelectedDevice(selectedIndex: updatedDeviceIndex + 1, fromVC: self) ?? CGRectZero
            let expectedY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height - 120
            //if selected device got hidden beneath close button after edit then assign the default bottom left corner position
            if updatedFrame.origin.y > expectedY {
                updatedFrame.origin.y = expectedY + 70
                updatedFrame.origin.x = 60
            }
            return updatedFrame
        }
        return CGRectZero
    }
}

//MARK: HandlingPopUpAnimation protocol methods
extension ViewProfileWithDeviceViewController : HandlingPopUpAnimation {
    
    //CMAIOS-2311
    func animatedVCGettingDismissed(with image: UIImage) {
    }
    
    //CMAIOS-2311
    func dismissAnimatedVC(with image: UIImage, isDeviceInfoUpdated : Bool){
        //reload current selected profile cell with backward device icon animation
        self.reloadCurrentSelectedProfile(with: image, isDeviceInfoUpdated: isDeviceInfoUpdated)
    }
    
    func updateParentViewWithoutDeviceIconAnimation(isProfileAssignmentChanged : Bool){
        //reload current selected profile cell without backward device icon animation
        self.reloadCurrentSelectedProfile(isProfileAssignmentChanged: isProfileAssignmentChanged)
    }
}

extension ViewProfileWithDeviceViewController {
    
    func performIconAnimationFromTopToBottom(updatedFrame : CGRect = CGRectZero, image:UIImage){
        //remove added bgView for deviceIcon animation
        let bgAnimationView = self.view.viewWithTag(1000)
        //CMAIOS-2311 updated image size to correct device icon backward animation
        self.animateDeviceIconFromTopToBottom(image: image, with: 40.0, frame: updatedFrame) { isAnimationCompleted in
            UIView.animate(withDuration: 0.5) {
                bgAnimationView?.alpha = 0.0
                self.setAlphaForUIElements(alpha: 1.0)
            } completion: { _ in
                bgAnimationView?.removeFromSuperview()
                self.currentContentOffSet = .zero
            }
        }
    }
    
    @objc func removeBlueBGViewWithoutAnimation() {
        //remove added bgView for deviceIcon animation
        let bgAnimationView = self.view.viewWithTag(1000)
        bgAnimationView?.removeFromSuperview()
        self.setAlphaForUIElements(alpha: 1.0)
    }
}

extension ViewProfileWithDeviceViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileDetailCell", for: indexPath) as! ProfileDetailCell
        cell.delegate = self
        cell.pauseUnpauseDelegate = self
        let indexProfile = arrProfiles?[indexPath.row]
        cell.profile = indexProfile
        let bgColor = self.getColorForPauseUnpauseInternetState(profileModel: indexProfile)
        cell.backgroundColor = bgColor
        cell.vwHeader.backgroundColor = bgColor
        cell.isPullToRefreshIsInProgress = false
        if currentSelectedIndex == indexPath.row {
            //animation of tableView
            cell.setUpCellData(profile: indexProfile)
        }
        cell.deviceCount = indexProfile?.devices.count ?? 0
        cell.setConnectedDevicesAndOnlineActivityData(profileModel: indexProfile)
        cell.refreshDelegate = self
        //To cover the empty space above the tableView add headerView
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        cell.tblView.tableHeaderView = UIView.init(frame: frame)
        //CMAIOS-2311 Added fix for issue#2
        cell.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        cell.tblView.setContentOffset(CGPointZero, animated: false)
        cell.tblView.reloadData()
        if currentSelectedIndex != indexPath.row {
            cell.animateConnectedDeviceProgress()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = self.arrProfiles?.count else { return 1 }
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension ViewProfileWithDeviceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*let vwContainerHeight = currentScreenHeight -  160 //(TopConstraintValue + CloseBtnHeight = 40 + 120)
        return CGSize(width:view.frame.width , height:vwContainerHeight)*/
        let vwContainerHeight = currentScreenHeight -  40 //(TopConstraintValue)
        return CGSize(width:view.frame.width , height:vwContainerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension ViewProfileWithDeviceViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.qualtricsAction?.cancel()
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        self.pageControl.currentPage = currentPage
        let index = self.pageControl.isHidden ? 0 : self.pageControl.currentPage
        animateAfterProfileMoved(index: index)
        trackAnalytics()
        if self.arrProfiles?.isEmpty == false {
            if currentPage <= self.arrProfiles!.count - 1 {
                if let profileModelObj = self.arrProfiles?[currentPage] {
                    self.delegate?.updateAvatarIconAfterProfileEdit(profileDetail: profileModelObj.profile){ _ in }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //CMAIOS-2311 handle horizontal scroll position
        let index = self.pageControl.isHidden ? 0 : self.pageControl.currentPage
        let selectedCell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ProfileDetailCell
        selectedCell?.tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        selectedCell?.tblView.setContentOffset(CGPointZero, animated: false)
        self.qualtricsAction?.cancel()
    }
    
    func animateAfterProfileMoved(index: Int) {
        guard let profileCell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ProfileDetailCell else { return }
        profileCell.animateProgressOnChangeInProfile(profileModel: arrProfiles?[index])
    }
    
}

extension ViewProfileWithDeviceViewController : HandlePullToRefresh, ProfileDetailDelegate, PauseTimerVCDelegate {
    func didUpdatePauseModel(model: PauseScheduleModel, isCancel: Bool) {
        self.arrProfiles?.enumerated().forEach { (index, name) in
            guard let firstCell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ProfileDetailCell else { return }
            firstCell.updateTableDataSource(model: model)
            if isCancel {
                firstCell.isPreviousTimeSave = false
                firstCell.isPreviousWeekendTimeSave = false
                firstCell.isCancelTapped = false
                firstCell.updateTimerDataOnCancel()
            }
        }
        DispatchQueue.main.async {
            self.saveCancelBottomView.isHidden = true
        }
    }
    
    func presentPauseTimerVC(model: PauseScheduleModel) {
        let scheduleModel = model
        scheduleModel.isWeekendsEnabled = model.weekEndModel.isWeekendsEnabled
        let vc = UIStoryboard(name: "PauseSchedule", bundle: nil).instantiateViewController(identifier: "PauseTimerVC") as PauseTimerViewController
        vc.profileModel = self.profile
        vc.tableDataSource = [model.cellIndex : scheduleModel]
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true)
    }
    
    func callApiForTimerData(models: [Int : PauseScheduleModel]) {
        callPauseSetApi(tableDataSource: models)
    }
    
    func performPullToRefresh() {
        self.pullToRefresh(hideScreen: false)
    }
    
    func callPauseSetApi(tableDataSource: [Int : PauseScheduleModel]) {
        for index in 0...1 {
            if tableDataSource[index]?.timerModel.isTimerSaved == true {
                let model = tableDataSource[index]
                triggerPauseDevice(startTime: model?.timerModel.fromDate ?? Date(), endTime: model?.timerModel.fromDate ?? Date()) { success in
                    if success {
                        if model?.weekEndModel.isTimerSaved == true {
                            self.triggerPauseDevice(startTime: model?.weekEndModel.fromDate ?? Date(), endTime: model?.weekEndModel.toDate ?? Date()) { success in
                                if !success {
                                    // Handle api error / failure
                                }
                            }
                        }
                    } else {
                        // Handle api error / failure
                    }
                }
            }
        }
    }
    
    func triggerPauseDevice(startTime: Date, endTime: Date, isWeekEnds: Bool = false, completionHandler:@escaping (_ success:Bool) -> Void) {
       /* let days = isWeekEnds == true ? ["sat", "sun"] : ["mon", "tue", "wed", "thu", "fri"]
        guard let rules = ProfileManager.shared.createRestrictionRuleForProfile(enabled: true, endTime: endTime.getDateStringForAPIParam(), startTime: startTime.getDateStringForAPIParam(), days: days) else {
            return
        }
        guard let params = ProfileManager.shared.schedulePauseForProfile(pid: self.profile?.pid ?? 0, rules: rules) else {
            return
        }
        APIRequests.shared.initiatePutAccessProfileRequest(pid:self.profile?.pid, macID: nil,enablePause:true, jsonParams: params) { success, response, error in
            if success {
                Logger.info("success")
                completionHandler(true)
            } else if response == nil && error != nil {
                completionHandler(false)
               // self.presentErrorMessageVC()
            }
        }*/
    }

    func animateCloseBtnViewToTop(){
        UIView.animate(withDuration: 0.5) {
             self.vwCloseContainer.frame.origin.y = self.vwContainer.frame.size.height - self.vwCloseContainer.frame.size.height
        } completion: { _ in
            self.vwCloseTopConstraint.constant = -103.0
            self.currentSelectedIndex = nil
        }
    }
    
//    func animateCloseBtnViewToBottom(){
//        UIView.animate(withDuration: 0.5) {
//             self.vwCloseContainer.frame.origin.y = currentScreenHeight
//        } completion: { _ in
//            self.vwCloseTopConstraint.constant = 120.0
//        }
//    }
    
    func animateCloseBtnViewToBottom(){
        self.vwCloseContainer.frame.origin.y = currentScreenHeight
    }
}

extension ViewProfileWithDeviceViewController : UpdateDeviceInViewProfile {
    
    func updateParentViewWithDevices() {
        if  self.arrProfiles?.count ?? 0 > 0 {
            self.arrProfiles?.removeAll()
        }
        self.arrProfiles = ProfileModelHelper.shared.profiles
        self.collectionView.reloadData()
    }
}

extension ViewProfileWithDeviceViewController : PauseOrUnpauseInternet
{
    func triggerPauseActionOnProfile(enable:Bool, profileID:Int) {
       // self.triggerPauseDevice(endTime: Date(timeIntervalSinceNow: 3600), isProfilePause: false)
        self.profilePauseAPIState = .progress
        self.callInstantPause(enable: enable, pausedPID:profileID)
    }
}
