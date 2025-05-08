//
//  ProfileSelectDeviceViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/21/22.
//

import Lottie
import UIKit

protocol UpdateDeviceInViewProfile{
    func updateParentViewWithDevices()
}

fileprivate struct SelectDeviceSection {
    let title: String
    var devices: [LightspeedNode] = []
    var pid:Int = 0
    
    static let personalAndComputer = SelectDeviceSection(title: "Personal and Computer")
    static let gaming = SelectDeviceSection(title: "Gaming")
    static let entertainment = SelectDeviceSection(title: "Entertainment")
    static let home = SelectDeviceSection(title: "Home")
    static let security = SelectDeviceSection(title: "Security")
    static let other = SelectDeviceSection(title: "Other")
}

/*
 This method is used to disable ProfileAvatarIcon animation when the user lands on this screen from any ChildVC
 */

class ProfileSelectDeviceViewController: UIViewController {
    enum State {
        case add(Profile)
        case edit(Profile)
        
        var profile: Profile {
            switch self {
            case let .add(profile):
                return profile
            case let .edit(profile):
                return profile
            }
        }
        
        var isEdit: Bool {
            guard case .edit = self else { return false }
            return true
        }
        var isAdd: Bool {
            guard case .add = self else { return false }
            return true
        }
    }
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var name: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    var state: State!
    var sectionHeader = ""
    private var sections: [SelectDeviceSection] = []
    private var selectedNodes: [LightspeedNode] = []
    var delegate:UpdateDeviceInViewProfile?
    @IBOutlet weak var lblAlertTitle: UILabel!
    @IBOutlet weak var collectionViewTopToAlertViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noDeviceAlertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noDeviceAlertView: UIView!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonStackView: UIStackView!
    var saveInProgress = false
    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet weak var nameBottomConstraint: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    @IBOutlet weak var vwTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    var profileStatus: ProfileStatus?
    var shouldSetHidden = false
    var pidSelected: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = energyBlueRGB
        if shouldSetHidden {
            self.statusView.isHidden = true
            self.statusLabel.isHidden = true
           
        }
       navigationController?.isNavigationBarHidden = true
       /* if state.isEdit {
            navigationController?.isNavigationBarHidden = true
        } else {
            navigationController?.isNavigationBarHidden = state.profile.master_bit == true
        }*/
        collectionView.allowsMultipleSelection = true
        self.navigationItem.hidesBackButton = true
        fetchDevices(forPullToRefresh: false)
        configureUI()
        //Handle Pull To Refresh animation
        initialUIConstantsForPullToRefresh()
        initiatePullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackAnalytics()
    }
    
    func trackAnalytics() {
        var event = ""
        if self.state.profile.master_bit == true {
            event = ProfileEvent.Profiles_assigndevices_masterprofile.rawValue
        } else if self.state.isEdit {
            event = ProfileEvent.Profiles_assigndevices_householdprofile.rawValue
        } else {
            event = ProfileEvent.Profiles_addperson_assigndevices.rawValue
        }
        if event.isEmpty { return }
        //CMAIOS-2215
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: PullToRefresh methods
    ///Method for pull to refresh during swipe.
    func initiatePullToRefresh() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
        self.view?.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    ///Method for initial constants in pull to refresh animation
    func initialUIConstantsForPullToRefresh(){
        self.vwPullToRefresh.isHidden = true
        vwPullToRefreshCircle.isHidden = true
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
        if !hide {
            self.view.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
                if UIDevice.current.hasNotch {
                    self.vwPullToRefreshTop.constant = 0
                } else {
                    self.vwPullToRefreshTop.constant =  currentScreenWidth > 375 ? -20 : -40
                }
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.handleScreenUI()
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                UIView.animate(withDuration: 0.5) {
                    self.isPullToRefresh = false
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshAnimation.isHidden = true
                    self.vwPullToRefreshTop.constant = -80
                    self.vwPullToRefreshHeight.constant = 0
                    self.handleScreenUI()
                    self.view.isUserInteractionEnabled = true
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        APIRequests.shared.getAllNodes { result in
            guard case .success(_) = result else {
                self.pullToRefresh(hideScreen: true, isComplete: true)
                return
            }
            self.fetchDevices(forPullToRefresh: true)
        }
    }
    
    //MARK: Handling UI For PullToRefresh
    func handleScreenUI() {
        if isPullToRefresh {
            if UIDevice.current.hasNotch {
                self.vwTopConstraint.constant = 130
            } else {
                self.vwTopConstraint.constant = currentScreenWidth > 375 ? 110 : 90
            }
        } else {
            self.vwTopConstraint.constant = 0.0
        }
    }
    
    func configureUI() {
        self.bottomView.addTopShadow(topLight: true)
        name.text = state.profile.profile
        showNoDeviceAlert(isHidden: true)
        animationView.createStaticImageForProfileAvatar(avatarID: state.profile.avatar_id, profileName: state.profile.profile)
        if !self.state.isEdit {
            guard state.profile.master_bit != true else {
                return
            }
        }
        secondaryAction.isHidden = false
        primaryAction.setTitle(state.isEdit ? "Save" : "I'm done", for: .normal)
        secondaryAction.setTitle(state.isEdit ? "Cancel" : "Skip this step", for: .normal)
        secondaryAction.layer.borderWidth = 2
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        noDeviceAlertView.layer.borderWidth = 1
        noDeviceAlertView.layer.borderColor = UIColor(red: 1, green: 0.808, blue: 0, alpha: 1).cgColor
        noDeviceAlertView.layer.cornerRadius = 15.0
        let paragraph = NSMutableParagraphStyle()
        lblAlertTitle.attributedText = NSMutableAttributedString(string: "You have to select at least one device",
                                                                 attributes: [NSAttributedString.Key.kern: -0.54,
                                                                  .paragraphStyle: paragraph])
        collectionView.showsVerticalScrollIndicator = false
        if let status = self.profileStatus {
            switch status {
            case .offline:
                self.statusLabel.text = status.rawValue
                self.statusView.backgroundColor = .StatusOffline
            case .online:
                self.statusLabel.text = status.rawValue
                self.statusView.backgroundColor = .StatusOnline
            case .paused:
                self.statusLabel.text = status.rawValue
                self.statusView.backgroundColor = .StatusPause                
            }
        } else {
            self.statusView.backgroundColor = UIColor.clear
            self.statusLabel.text = ""
            nameBottomConstraint.constant = 30
        }
        bottomViewBottomConstraint.constant = UIDevice().hasNotch ? -20 : 0
    }
    
   //MARK: Save Button Animation methods
    func viewAnimationSetUp() {
        self.animationLoadingView.backgroundColor = .clear
        self.animationLoadingView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.animationLoadingView.loopMode = .playOnce
        self.animationLoadingView.animationSpeed = 1.0
        self.animationLoadingView.play(toProgress: 0.6, completion:{_ in
            if self.saveInProgress {
                self.animationLoadingView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func saveButtonAnimation(){
        saveInProgress = true
        buttonStackView.isHidden = true
        animationLoadingView.isHidden = false
        viewAnimationSetUp()
    }

    func stopAnimationAndDismiss() {
        self.saveInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) {[weak self] _ in
                self?.view.isUserInteractionEnabled = true
                if ProfileManager.shared.isFirstUserExperience {
                    self?.loadHouseHoldFlow()
                } else {
                    if let isEdit = self?.state.isEdit , isEdit == true{
                        if self?.delegate != nil {
                            self?.delegate?.updateParentViewWithDevices()
                            self?.dismiss(animated: true)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
                        vc.state = .add(self?.state.profile ?? Profile())
                        /// pause schedule set hidden
//                        if MyWifiManager.shared.isGateWayWifi6() {
//                            //load Pause Schedule
//                            vc.isShowPauseSchedule = true
//                        } else {
//                            vc.isShowPauseSchedule = false
//                        }
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    func saveButtonAPIFailedAnimation() {
        DispatchQueue.main.async {
            self.saveInProgress = false
            self.animationLoadingView.currentProgress = 3.0
            self.animationLoadingView.stop()
            self.animationLoadingView.isHidden = true
            self.buttonStackView.alpha = 0.0
            self.buttonStackView.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.buttonStackView.alpha = 1.0
            }  completion: { _ in
                self.view.isUserInteractionEnabled = true
                // show errorVC when API fails
                guard let isMaster = self.state.profile.master_bit else{
                    return
                }
                if self.state.isEdit {
                    self.presentErrorMessageVCForEditDeviceFailure()
                } else if !isMaster && self.state.isAdd{
                    self.showErrorMessageVCForAddDeviceFailure()
                }
            }
        }
    }
    
    //MARK: getAllNodes API
    func fetchDevices(forPullToRefresh: Bool) {
        guard let devices = DeviceManager.shared.devices, !devices.isEmpty else {
            if !self.isPullToRefresh {
                // Show error CMAIOS-914 & CMAIOS-928
                if ProfileManager.shared.isFirstUserExperience {
                    self.presentErrorMessageVCForEditDeviceFailure()
                } else {
                    //Show Profile Completion screen
                    DispatchQueue.main.async {
                        guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
                        vc.state = .add(self.state.profile)
                        vc.isShowPauseSchedule = false
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else {
                self.pullToRefresh(hideScreen: true, isComplete: true)
            }
            return
        }
        populateData(devices: devices, forPullToRefresh: forPullToRefresh)
    }
        
    func populateData(devices: [LightspeedNode], forPullToRefresh: Bool) {
        self.sections = [.personalAndComputer, .gaming, .entertainment, .home, .security, .other]
        devices.forEach { device in
            if !forPullToRefresh && device.pid == self.state.profile.pid {
                self.selectedNodes.append(device)
            }
            //Group devices under categories and ProfileName as per CMA-254
            if let profileName = device.profile , !profileName.isEmpty, device.pid ?? 0 > 0, device.pid != self.state.profile.pid {
                if !self.sections.contains(where: { deviceSection in
                    deviceSection.title == device.profile
                }) {
                    var deviceSection = SelectDeviceSection(title: profileName)
                    deviceSection.pid = device.pid ?? 0
                    self.sections.append(deviceSection)
                }
                let index = self.sections.firstIndex(where: { $0.title.isMatching(profileName) == true}) ?? 5
                self.sections[index].devices.append(device)
                self.sections[index].devices = getSortedDevices(devices: self.sections[index].devices)
            } else {
                let index: Int = self.sections.firstIndex(where: { $0.title.isMatching(device.category ?? "") == true}) ?? 5
                self.sections[index].devices.append(device)
                self.sections[index].devices = getSortedDevices(devices: self.sections[index].devices)
            }
        }
        self.sections = self.sections.filter({ !$0.devices.isEmpty })
        let profileSections = self.sections.filter({ $0.pid > 0 })
        let defaultSections = self.sections.filter({ $0.pid <= 0 })
        self.sections = []
        self.sections = defaultSections + profileSections.sorted { $0.pid < $1.pid }
        self.collectionView.reloadData()
        if isPullToRefresh {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.pullToRefresh(hideScreen: true, isComplete: true)
            }
        }
    }
    
    func getSortedDevices(devices: [LightspeedNode]) -> [LightspeedNode] {
        var sortedDevices = [LightspeedNode] ()
        let alphabetSorting = devices.filter{ $0.friendlyName?.first?.isLetter ?? false }.sorted { $0.friendlyName?.localizedStandardCompare($1.friendlyName ?? "") == ComparisonResult.orderedAscending }
        let numberSorting = devices.filter{ $0.friendlyName?.first?.isNumber ?? false }.sorted { $0.friendlyName?.localizedStandardCompare($1.friendlyName ?? "") == ComparisonResult.orderedAscending }
        let symbolSorting = devices.filter{ !($0.friendlyName?.first?.isLetter ?? false) && !($0.friendlyName?.first?.isNumber ?? false) }.sorted { $0.friendlyName?.localizedStandardCompare($1.friendlyName ?? "") == ComparisonResult.orderedAscending }
        sortedDevices = alphabetSorting + numberSorting + symbolSorting
        return sortedDevices
    }
        
    func presentErrorMessageVCForProfiles() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_profile_failure, subTitleMessage: "Please close the app and try again later.")
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_FIRST_USE_CREATE_MASTER_PROFILE_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            vc.isComingFromProfileCreationScreen = true
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
        
    //MARK: Pre-Selected Devices
    func isDeviceSelected(node: LightspeedNode) -> Bool {
        let filtered = self.selectedNodes.filter({$0.mac?.isMatching(node.mac ?? "") == true}) //{
            if filtered.count == 1 {
                if filtered.first?.pid == state.profile.pid {
                    return true
                }
                return false
            }
        return false
    }
    //MARK: Button Actions
    @IBAction func onTapAction(_ sender: UIButton) {
        guard sender == primaryAction else {
            if state.isEdit {
               self.navigationController?.dismiss(animated: true)
            } else {
               guard let vc = ProfileAlertViewController.instantiateWithIdentifier(from: .profile) else { return }
               vc.state = .add(state.profile)
               navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        if(isPullToRefresh){
            return
        }
        let nodes: [LightspeedNode] = self.selectedNodes//getSelectedNodes()
        guard !nodes.isEmpty else {
            if ProfileManager.shared.isFirstUserExperience {
                self.loadHouseHoldFlow()
            } else {
                if state.isEdit  {
                    showNoDeviceAlert(isHidden: false)
                    return
                }
                guard let vc = ProfileAlertViewController.instantiateWithIdentifier(from: .profile) else { return }
                vc.state = .add(state.profile)
                navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        self.saveButtonAnimation()
        self.view.isUserInteractionEnabled = false
        DeviceManager.shared.setNode(nodes) { result in
            guard case .success = result else {
                self.saveButtonAPIFailedAnimation()
                return
            }
           // MyWifiManager.shared.refreshLTDataRequired = true
            var presentedController : UIViewController?
            if self.state.isEdit {
                presentedController = self.presentingViewController?.presentingViewController?.presentingViewController
            } else {
                presentedController = self.presentingViewController?.presentingViewController
            }
            if presentedController != nil, presentedController!.isKind(of: MyWiFiViewController.self), ProfileManager.shared.isFirstUserCompleted {
                for device in self.selectedNodes{
                    var profileName = ""
                    if device.pid != 0 {
                        profileName = self.state.profile.profile ?? ""
                    }
                    MyWifiManager.shared.saveProfileChangeLocally(for: device.mac ?? "", profileName: profileName, pid: device.pid ?? 0)
                }
            }
            self.callProfileRefreshAPIsAndDismiss()
        }
    }
    
    func callProfileRefreshAPIsAndDismiss() {
        APIRequests.shared.getAllNodes { response in
            guard case .success(_) = response else {
                self.view.isUserInteractionEnabled = true
                return
            }
            if MyWifiManager.shared.isGateWayWifi6() {
                self.refreshPauseAPIs()
            } else {
                ProfileModelHelper.shared.getAllAvailableProfiles { [weak self] _ in
                    guard let self = self else { return }
                    self.stopAnimationAndDismiss()
                }
            }
        }
    }
    
    func refreshPauseAPIs() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        APIRequests.shared.initiateGetAccessProfileRequest(pid: self.pidSelected ?? 0, completionHandler: { _, _, _ in
            dispatchGroup.leave()
        })
        dispatchGroup.enter()
        APIRequests.shared.initiateGetAccessProfileByClientRequest { success, response, error in
            if success {
                MyWifiManager.shared.pausedClientData = response
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            ProfileModelHelper.shared.getAllAvailableProfiles { [weak self] _ in
                guard let self = self else { return }
                self.stopAnimationAndDismiss()
            }
        }
    }
    
    func presentErrorMessageVCForEditDeviceFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .fullScreen
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_node_household_and_master_edit_device_failure)
        self.present(vc, animated: true)
    }
    
    func showErrorMessageVCForAddDeviceFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        if state.isEdit {
            vc.state = .edit(state.profile)
        } else {
            vc.state = .add(state.profile)
        }
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_node_household_add_device_failure)
        vc.navToProfileCompletionVC = true
        vc.isComingFromProfileCreationScreen = false
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_ADD_DEVICES_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadHouseHoldFlow() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "AppearedAfterFirstUserExperience"),object: nil, userInfo: ["reload": "Profiles"]))
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(identifier: "NoDevicesInHouseholdVC") as NoDevicesInHouseholdVC
             vc.isFirstUserExperience = ProfileManager.shared.isFirstUserExperience
            self.navigationController?.pushViewController(vc, animated: true)
             ProfileManager.shared.isFirstUserExperience = false
        }
    }
    
    func showNoDeviceAlert(isHidden: Bool) {
        if isHidden {
            self.noDeviceAlertView.isHidden = true
            self.noDeviceAlertViewHeightConstraint.constant = 0.0
            self.collectionViewTopConstraint.priority = UILayoutPriority(1000)
            self.collectionViewTopToAlertViewConstraint.priority = UILayoutPriority(750)
        } else {
            self.noDeviceAlertView.isHidden = false
            self.noDeviceAlertViewHeightConstraint.constant = 63.0
            self.collectionViewTopConstraint.priority = UILayoutPriority(750)
            self.collectionViewTopToAlertViewConstraint.priority = UILayoutPriority(1000)
        }
        self.view.layoutIfNeeded()
    }
    
    func getSelectedNodes() -> [LightspeedNode] {
        guard let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty else { return [] }
        guard let pid = state.profile.pid else {
            assertionFailure("Should not happen")
            return []
        }
        let nodes: [LightspeedNode] = indexPaths.map { indexPath in
            var node = sections[indexPath.section].devices[indexPath.row]
            node.pid = pid
            node.profile = state.profile.profile
            return node
        }
        return nodes
    }
}

extension ProfileSelectDeviceViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectDeviceCell.identifier, for: indexPath) as? SelectDeviceCell else { return UICollectionViewCell() }
        cell.leftImage.image = DeviceManager.IconType.gray.getDeviceImage(name: sections[indexPath.section].devices[indexPath.row].deviceType ?? "unknown")
        
        let device = sections[indexPath.section].devices[indexPath.row]
        var deviceName: String
        if let friendlyName = device.friendlyName, !friendlyName.isEmpty {
            deviceName = friendlyName
        } else if let hostName = device.hostname, !hostName.isEmpty, hostName != device.mac {
            deviceName = hostName
        } else if let vendorName = device.vendor, !vendorName.isEmpty, !vendorName.contains("None") {
            deviceName = vendorName
        } else {
            deviceName = "Unnamed device"
        }
        
        cell.title.text = deviceName
        cell.rightImage.isHidden = true
        DispatchQueue.main.async {
            if self.isDeviceSelected(node: self.sections[indexPath.section].devices[indexPath.row]) == true {
                cell.showSelectedUI()
            } else {
                cell.showDeSelectedUI()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: SelectDeviceHeader.self), for: indexPath) as? SelectDeviceHeader else { return UICollectionReusableView() }
        header.listTitle.isHidden = indexPath.section != 0
        if !header.listTitle.isHidden {
            if sectionHeader.isEmpty {
                if self.state.isEdit {
                    if state.profile.master_bit ?? false {
                        sectionHeader = "Select all devices that you use regularly:"
                    } else {
                        sectionHeader = "Select all devices that belong to " + (state.profile.profile ?? " ") + ":"
                    }
                } else {
                    sectionHeader = "Select all devices that you want to track"
                }
            }
            header.listTitle.text = sectionHeader
        }
        header.sectionTitle.text = sections[indexPath.section].title
        return header
    }
}

extension ProfileSelectDeviceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? SelectDeviceCell else {
            return
        }
        if !noDeviceAlertView.isHidden {
            self.showNoDeviceAlert(isHidden: true)
        }
        if(isPullToRefresh){
            return
        }
        let selectedNode = self.sections[indexPath.section].devices[indexPath.row]
        if isDeviceSelected(node: selectedNode) {
            let nodes = self.selectedNodes.filter({$0.mac?.isMatching(selectedNode.mac ?? "") == true })
            if !nodes.isEmpty {
                guard var nod = nodes.first else {
                    return
                }
                nod.updatePid(newPid: 0)
                if let index = self.selectedNodes.firstIndex(where: {$0.mac?.isMatching(selectedNode.mac ?? "") == true }) {
                    self.selectedNodes.remove(at: index)
                    if self.profileStatus != nil{
                        self.selectedNodes.append(nod)
                    }
                    cell.showDeSelectedUI()
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadData()
                    }
                }
            }
        } else {
            let nodes = self.selectedNodes.filter({$0.mac?.isMatching(selectedNode.mac ?? "") == true })
            if !nodes.isEmpty {
                guard var nod = nodes.first else {
                    return
                }
                nod.updatePid(newPid: self.state.profile.pid ?? 0)
                if let index = self.selectedNodes.firstIndex(where: {$0.mac?.isMatching(selectedNode.mac ?? "") == true}) {
                    self.selectedNodes.remove(at: index)
                    self.selectedNodes.append(nod)
                    cell.showSelectedUI()
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadData()
                    }
                } else {
                    self.selectedNodes.append(selectedNode)
                }
                cell.showSelectedUI()
                
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            } else {
                var nod = selectedNode
                nod.updatePid(newPid: self.state.profile.pid ?? 0)
                self.selectedNodes.append(nod)
                cell.showSelectedUI()
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension ProfileSelectDeviceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeMake(collectionView.frame.width,  90)
        } else {
            return CGSizeMake(collectionView.frame.width, 41.5)
        }
    }
}
