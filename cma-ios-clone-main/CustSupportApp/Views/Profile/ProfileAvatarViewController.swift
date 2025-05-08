//
//  ProfileAvatarViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/8/22.
//

import UIKit
import Lottie

class ProfileAvatarViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    enum State {
        case add(Profile)
        case edit(Profile)
        
        var isEdit: Bool {
            guard case .edit = self else { return false }
            return true
        }

        var isAdd: Bool {
            guard case .add = self else { return false }
            return true
        }

        var profile: Profile {
            switch self {
            case let .add(profile):
                return profile
            case let .edit(profile):
                return profile
            }
        }
        
        var header: String {
            switch self {
            case let .add(profile) where profile.master_bit == true:
                return "Thanks, \(profile.profile ?? "")"
            case .add:
                return "Add a person"
            case let .edit(profile) where profile.master_bit == true:
                return "Edit my profile"
            case .edit:
                return "Edit profile"
            }
        }
        
        var subHeader: String {
            switch self {
            case let .add(profile) where profile.master_bit == true:
                return "Now, swipe to choose an avatar for yourself"
            case let .add(profile):
                return "Swipe to choose an avatar for \(profile.profile ?? "")"
            case let .edit(profile) where profile.master_bit == true:
                return "Swipe to choose an avatar for yourself"
            case let .edit(profile):
                return "Swipe to choose an avatar for \(profile.profile ?? "")"
            }
            
        }
        
        var actionTitle: String {
            switch self {
            case .add:
                return "Continue"
            case .edit:
                return "Save"
            }
        }
    }
    
    @IBOutlet var header: UILabel!
    @IBOutlet var subHeader: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var actionButton: UIButton!
    var animateNextCell: Bool = false
    var state: State!
    var previousScrollOffset: CGFloat?
    private var avatars: [AvatarImage] = []
    var saveInProgress = false
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    
    lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(240), heightDimension: .absolute(240))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, environment) in
            if self?.previousScrollOffset == nil {
                self?.previousScrollOffset = offset.x
            }
            let scrollDif = (self?.previousScrollOffset ?? 0) - offset.x
            self?.previousScrollOffset = offset.x
            let direction = ScrollDirection(offset: scrollDif)
            let centerPoint = CGPoint(x: (offset.x + direction.padding + environment.container.contentSize.width / 2.0), y: environment.container.contentSize.height / 2.0)
            UIView.animate(withDuration: 0.1) {
                items.forEach { item in
                    if item.frame.contains(centerPoint) {
                        self?.pageControl.currentPage = item.indexPath.item
                    }
                    guard let cell = self?.collectionView.cellForItem(at: item.indexPath) as? AvatarCell else {
                        if case .none = direction {
                            self?.previousScrollOffset = nil
                        }
                        return
                    }
                    let position = AvatarCell.Position(currentIndex: item.indexPath.item, centerIndex: self?.pageControl.currentPage ?? 0)
                    if scrollDif < 0 {
                        cell.adjustSubviews(to: position, scrollDirection: direction)
                    } else if scrollDif > 0 {
                        cell.adjustSubviews(to: position, scrollDirection: direction)
                    } else {
                        cell.adjustSubviews(to: position, scrollDirection: direction)
                    }
                }
                self?.collectionView.layoutIfNeeded()
            }
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        collectionView?.collectionViewLayout = compositionalLayout
        prepareAvatarDataSource()
        pageControl.numberOfPages = avatars.count
        configureUI()
        if !self.state.isEdit {
            guard state.profile.master_bit != true else { return }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        trackAnalytics()
        //Hide Cancel button for FUE
        if ProfileManager.shared.isFirstUserExperience {
            self.hideRightBarItem()
        }
    }

    func trackAnalytics() {
        var event = ""
        if ProfileManager.shared.isFirstUserExperience {
            event = ProfileEvent.Profiles_firstuse_masterprofile_avatar.rawValue
        } else {
            if self.state.isAdd {
                event = ProfileEvent.Profiles_addperson_avatar.rawValue
            } else if self.state.isEdit && (self.state.profile.master_bit == true) {
                event = ProfileEvent.Profiles_edit_masterprofile_avatar.rawValue
            } else if self.state.isEdit {
                event = ProfileEvent.Profiles_edit_householdprofile_avatar.rawValue
            }
        }
        if event.isEmpty { return }
        //CMAIOS-2215
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }
    
    func onTapCancel() {
        if self.state.isEdit {
            if MyWifiManager.shared.isSmartWifi(){
                self.navigationController?.popToViewController(ofClass: ViewProfileWithDeviceViewController.self)
            } else {
                self.navigationController?.popToViewController(ofClass: HomeScreenViewController.self)
            }
        } else {
            guard let vc = ConfirmationViewController.instantiateWithIdentifier(from: .profile) else { return }
            vc.configure(headerTitle: "Are you sure you want to cancel adding a person?", subHeaderTitle: nil, primaryButtonAction: {
                if let isExists = self.navigationController?.checkIfViewControllerExists(ofClass: ManageMyHouseholdDevicesVC.self), isExists {
                    self.navigationController?.popToViewController(ofClass: ManageMyHouseholdDevicesVC.self)
                } else {
                    if ProfileManager.shared.isFirstUserCompleted, let profiles = ProfileManager.shared.profiles, profiles.count > 1, let isExists = self.navigationController?.checkIfViewControllerExists(ofClass: NoDevicesInHouseholdVC.self), isExists {
                        let vc = UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(identifier: "ManageMyHouseholdDevicesVC") as ManageMyHouseholdDevicesVC
                            vc.modalPresentationStyle = .fullScreen
                        self.pushViewControllerWithLeftToRightAnimation(vc, from: self)
                    }
                    else {
                        self.navigationController?.dismiss(animated: true)
                    }
                }
            }, secondaryButtonAction: {
                self.navigationController?.popViewController(animated: false)
            })
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func prepareAvatarDataSource() {
        let usedIds = getAllUsedAvatarIds()
        // Show only avatars that are not used by other profiles
        var avatarNames = AvatarConstants.names
        if let letter = state.profile.profile?.prefix(1).capitalized {
            avatarNames.append(letter)
        }
        for (i, name) in avatarNames.enumerated() where (!usedIds.contains((i + 1)) || (i + 1) == avatarNames.count) {
            if i == avatarNames.count - 1 {
                let decrementValue = Int("A".unicodeScalars.map{$0.value}[0]) - avatarNames.count
                let nameId = Int((name.uppercased().unicodeScalars.map{$0.value})[0]) - decrementValue
                let avatar = AvatarImage(id: nameId, name: name)
                avatars.append(avatar)
            } else {
                let avatar = AvatarImage(id: (i + 1), name: name)
                avatars.append(avatar)
            }
        }
    }
    
    private func getAllUsedAvatarIds() -> Set<Int> {
        // TODO: Remove this which is added for testing purpose
        if enableFirstUserExperience {
            return []
        }
        // Get all profile avatar Ids
        let usedIds: [Int]? = ProfileManager.shared.profiles?.compactMap { profile in
            guard profile.avatar_id != state.profile.avatar_id else { return 0 }
            return profile.avatar_id
        }
        return Set(usedIds ?? [])
    }
    
    private func configureUI() {
        header.text = state.header
        subHeader.text = state.subHeader
        actionButton.setTitle(state.actionTitle, for: .normal)
    }
    
    func presentErrorMessageVCForProfiles() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_profile_failure, subTitleMessage: "Please close the app and try again later.")
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_CREATE_MASTER_PROFILE_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            vc.isComingFromProfileCreationScreen = true
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func onTapActionButton(_ sender: UIButton) {
        let avatar = avatars[pageControl.currentPage]
        var isAnimationCompleted = false
        if ProfileManager.shared.isFirstUserExperience == true {
            var profile = Profile()
            profile.avatar_id = avatar.id
            profile.profile = avatar.name
            let model = ProfileModel(profile: profile, profileName: self.state.profile.profile ?? "", avatarImage: avatar)
            // profileModel
            self.navigationController?.navigationBar.isHidden = true
            addImageViewAsSubview(selectedView:UIView(frame: CGRect()),profileModel: model, animateFromVC: AnimateFrom.ProfileFirstUX) { isStaticScreen  in
                isAnimationCompleted = true
            }
        } else {
            self.saveButtonAnimation()
        }
        let profileName = self.state.profile.profile?.replaceApostropheFromText()
        ProfileManager.shared.setProfile(Profile(avatar_id: avatar.id, pid: self.state.profile.pid, profile: profileName)) { [weak self] result in
            switch result {
            case let .success(profiles):
                if  !ProfileManager.shared.isFirstUserCompleted {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "AppearedAfterFirstUserExperience"),object: nil, userInfo: ["reload": "Profiles"]))
                    if ProfileManager.shared.isFirstUserExperience {
                        if isAnimationCompleted {
                            self?.removeAnimationViewFromScreen()
                            self?.performActionAfterAnimation(profiles:profiles)
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now()+2.4) {
                                self?.removeAnimationViewFromScreen()
                                self?.performActionAfterAnimation(profiles:profiles)
                            }
                        }
                    } else {
                        self?.performActionAfterAnimation(profiles:profiles)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                        self?.saveInProgress = false
                        self?.stopAnimationAndPerformAction(profiles: profiles)
                    }
                }
            case let .failure(error):
                Logger.info("Set profiles failed with \(error)")
                if ProfileManager.shared.isFirstUserExperience == true {
                    self?.removeAnimationViewFromScreen()
                    self?.presentErrorMessageVCForProfiles()
                } else {
                    self?.saveButtonAPIFailedAnimation()
                }
            }
        }
    }
    
    func saveButtonAnimation(){
        saveInProgress = true
        actionButton.isHidden = true
        animationLoadingView.isHidden = false
        viewAnimationSetUp()
    }
    
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
    
    func stopAnimationAndPerformAction(profiles:[Profile]) {
        self.saveInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                self.performActionAfterAnimation(profiles:profiles)
            }
        }
    }
    
    func loadHouseHoldFlow() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(identifier: "NoDevicesInHouseholdVC") as NoDevicesInHouseholdVC
             vc.isFirstUserExperience = ProfileManager.shared.isFirstUserExperience
            self.navigationController?.pushViewController(vc, animated: true)
             ProfileManager.shared.isFirstUserExperience = false
        }
    }
    
    func showProfileCompletionAndSkipPauseSchedule() {
        //Show Profile Completion screen
        DispatchQueue.main.async {
            guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
            vc.state = .add(self.state.profile)
            vc.isShowPauseSchedule = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func performActionAfterAnimation(profiles:[Profile]){
        var firstUser = ProfileManager.shared.isFirstUserExperience
        var sectionHeader = ""
        var profile = Profile()
        if firstUser {
            if !MyWifiManager.shared.isSmartWifi() {
                DispatchQueue.main.async {
                ProfileManager.shared.isFirstUserExperience = false
                self.navigationController?.dismiss(animated: true)
                return
                }
            }
            ProfileManager.shared.isFirstUserExperience = true
            firstUser = false
            if let profileData = profiles.filter({ $0.master_bit! == true}) as [Profile]?, profileData.count > 0
            {
                profile = profileData[0]
            }
        } else {
            ProfileManager.shared.isFirstUserExperience = false
            profile = profiles.first ?? Profile()
        }
        if ProfileManager.shared.isFirstUserExperience {
            sectionHeader = "Select all devices that you use regularly:"
        } else {
            sectionHeader = "Select all devices that belong to " + (self.state.profile.profile ?? " ") + ":"
        }
        switch self.state {
        case .add:
            DispatchQueue.main.async {
                if MyWifiManager.shared.isSmartWifi(){
                        if ProfileManager.shared.isFirstUserExperience {
                            // Show error CMAIOS-914
                            self.loadHouseHoldFlow()
                        } else {
                            guard let devices = DeviceManager.shared.devices, !devices.isEmpty else {
                                //CMAIOS-928, 1399
                                self.showProfileCompletionAndSkipPauseSchedule()
                                return
                            }
                            guard let vc = ProfileSelectDeviceViewController.instantiateWithIdentifier(from: .profile) else { return }
                            vc.state = .add(profile)
                            vc.sectionHeader = sectionHeader
                            vc.shouldSetHidden = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                } else {
                    ProfileManager.shared.isFirstUserExperience = false
                    self.dismiss(animated: true, completion: nil)
                    return
                }
            }
        case .edit:
            DispatchQueue.main.async {
                var dataDict = Dictionary<String, Profile>()
                dataDict["profile"] = profile
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateProfile"),object: nil, userInfo: dataDict))
                if MyWifiManager.shared.isSmartWifi() {
                    self.navigationController?.popToViewController(ofClass: ViewProfileWithDeviceViewController.self)
                } else {
                    self.navigationController?.popToViewController(ofClass: HomeScreenViewController.self)
                }
            }
        default: break
        }
    }
    
    func presentErrorMessageVCForGetAllNodesFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .fullScreen
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_node_household_add_device_failure)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_ADD_DEVICES_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
        self.present(vc, animated: true)
    }
    
    func removeAnimationViewFromScreen() {
        DispatchQueue.main.async() {
            self.navigationController?.navigationBar.isHidden = false
            let animationIconView = self.view.viewWithTag(100)
            let alphabetView = self.view.viewWithTag(101)
            let alphabetViewLabel = self.view.viewWithTag(102)
            let profileTextLabel = self.view.viewWithTag(1004)
            let bgAnimationView = self.view.viewWithTag(1000)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                bgAnimationView?.alpha = 0.0
                bgAnimationView?.removeFromSuperview()
                animationIconView?.removeFromSuperview()
                alphabetView?.removeFromSuperview()
                alphabetViewLabel?.removeFromSuperview()
                profileTextLabel?.removeFromSuperview()
                self.setAlphaForUIElements(alpha: 1.0)
            }
        }
    }
    
    func saveButtonAPIFailedAnimation() {
        DispatchQueue.main.async {
            self.presentErrorMessageVCForProfiles()
            self.saveInProgress = false
            self.animationLoadingView.currentProgress = 3.0
            self.animationLoadingView.stop()
            self.animationLoadingView.isHidden = true
            self.actionButton.alpha = 0.0
            self.actionButton.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.actionButton.alpha = 1.0
            }
        }
    }
}


extension ProfileAvatarViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        avatars.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell else { return UICollectionViewCell() }
        let name: String = avatars[indexPath.item].offline
        cell.animationView.animation = LottieAnimation.named(name)
        cell.contentMode = .scaleAspectFit
        if pageControl.currentPage == indexPath.item, !cell.isCentered {
            animateNextCell = true
            cell.adjustSubviews(to: .center, scrollDirection: .none)
        }
        if animateNextCell, pageControl.currentPage == indexPath.item - 1 {
            animateNextCell = false
            cell.adjustSubviews(to: .right, scrollDirection: .none)
        }
        return cell
    }
    
    @IBAction func onValueChanged(_ sender: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}
