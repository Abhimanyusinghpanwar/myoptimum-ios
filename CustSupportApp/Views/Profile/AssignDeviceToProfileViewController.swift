//
//  AssignDeviceToProfileViewController.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 16/11/22.
//

import UIKit
import Lottie

protocol UpdatedDeviceProfileAssignment {
    func getUpdatedProfileAssigmentDetails(profileName:String?, profilePid:Int?)
}

class AssignDeviceToProfileViewController: UIViewController, sendDeviceImage {
    func getDeviceIconFromAssignProfileScreen(image: UIImageView) {
        self.animateddeviceIcon.image = image.image
    }
    
    @IBOutlet weak var deviceIcon: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceTableview: UITableView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    var animateddeviceIcon = UIImageView()
    var delegate:UpdatedDeviceProfileAssignment?
    @IBOutlet weak var centreViewBottomConstraint: NSLayoutConstraint!
    // @IBOutlet weak var backgroundView: UIView!
    var deviceDetails: ConnectedDevice?
    fileprivate var listTitleForAssignDevice = "Who owns this device?"
    var availableProfiles: [ProfileModel] = ProfileModelHelper.shared.profiles ?? []
    var selectedIndex: IndexPath? = nil
    var emptyCellHeight = Int((400/xibDesignHeight)*currentScreenHeight)
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var saveInProgress = false
    var checkAssignedToProfile = false
    var isRemove = false
    var isForRecentlyDisconnected = false
    let emptyCell                   = "EmptyCell"
    var delegateforDeviceAnimationForAssignProfile : HandlingPopUpAnimation?
    var isAnimationDone = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        availableProfiles = ProfileModelHelper.shared.profiles ?? []
        deviceTableview.register(UINib.init(nibName: "AssignDeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "AssignDeviceTableViewCell")
        deviceTableview.register(UINib.init(nibName: "TopCellForAssignProfile", bundle: nil), forCellReuseIdentifier: "TopCell")
        deviceTableview.register(UINib.init(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        deviceTableview.register(EmptyCell.self, forCellReuseIdentifier: emptyCell)
        deviceTableview.tableFooterView = UIView()
        self.deviceTableview.rowHeight = UITableView.automaticDimension;
        self.deviceTableview.separatorStyle = .none
        self.deviceTableview.dataSource = self
        self.deviceTableview.delegate = self
        self.deviceTableview.sectionFooterHeight = 0.0
        //To cover the empty space above the tableView add headerView
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        deviceTableview.tableHeaderView = UIView.init(frame: frame)
        self.bottomView.transform = CGAffineTransform(translationX: 0, y: 125)
       // self.deviceTableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -22 , right: 0)
        self.selectProfile()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.selectProfile()
//        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func selectProfile() {
        guard let pID = deviceDetails?.pid else { return }
        guard let index = availableProfiles.firstIndex(where: { $0.pid == Int(pID) }) else { return }
        let indexPath = IndexPath(row: index, section: 2)
        selectedIndex = indexPath
        //deviceTableview.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        deviceTableview.delegate?.tableView!(deviceTableview, didSelectRowAt: indexPath)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //CMAIOS-2215
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ProfileEvent.Profiles_edit_deviceowner.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
        self.animateTableviewToTop()
    }
    
    @IBAction func onTapAction(_ sender: UIButton) {
        guard sender == primaryButton else {
            self.backAnimation()
              return
        }
        guard let index = selectedIndex else { return }
        let profile = availableProfiles[index.row]
        
        saveInProgress = true
        buttonStackView.isHidden = true
        animationLoadingView.isHidden = false
        viewAnimationSetUp()

        var nodes = [String: AnyObject]()
        let mac = WifiConfigValues.getFormattedMACAddress(self.deviceDetails?.macAddress ?? "")
        if mac.isEmpty {
            return
        }
        let deviceName = self.deviceDetails?.title.replaceApostropheFromText()
        nodes["friendlyname"] = deviceName as AnyObject?
        nodes["mac"] = self.deviceDetails?.macAddress as AnyObject
        if isRemove
        {
            nodes["pid"] = 0 as AnyObject
        }
        else
        {
            nodes["pid"] = profile.pid as AnyObject?
        }
     
        var deviceType = ""
        var deviceCategory = ""
        var hostName = ""
        var gwid = ""
        
        if let devices = DeviceManager.shared.devices, !devices.isEmpty {
            deviceType = DeviceManager.shared.getCMA_DeviceTypeForMac(mac: mac)
            if deviceType.isEmpty {
                deviceType = "unknown"
            }
            deviceCategory = DeviceManager.shared.getCMA_CategoryForMac(mac: mac)
            gwid = DeviceManager.shared.getGwidForMac(mac: mac)
            hostName = DeviceManager.shared.getHostnameForMac(mac: mac)
        } else {
            guard let LT_deviceDetails = MyWifiManager.shared.getDeviceDetailsForMAC(mac) else {
                Logger.info("Edit device details failed due to device details not found!")
                self.saveButtonAPIFailedAnimation(isSetNodeFailed: true)
                return
            }
            if let LT_deviceType = LT_deviceDetails.device_type, !LT_deviceType.isEmpty {
                deviceType  = LT_deviceType
            } else if let devType = self.deviceDetails?.device_type, !devType.isEmpty {
                deviceType = devType
            } else {
                deviceType = "unknown"
            }
            
            if let LT_deviceCategory = LT_deviceDetails.cma_category, !LT_deviceCategory.isEmpty {
                deviceCategory  = LT_deviceCategory
            }
            
            if let LT_hostName = LT_deviceDetails.hostname, !LT_hostName.isEmpty {
                hostName = LT_hostName
            }
            gwid = MyWifiManager.shared.deviceMAC ?? ""
        }
    
        nodes["cma_dev_type"] = deviceType as AnyObject
        nodes["cma_category"] = deviceCategory as AnyObject
        nodes["gwid"] = gwid as AnyObject
        nodes["hostname"] = hostName as AnyObject

        var params = [String: AnyObject]()
        params["devices"] = [nodes] as AnyObject
        APIRequests.shared.initiateSetNodeRequest(nodeData: params, completionHandler: {result, error in
            if result{
                Logger.info("Set Lightspeed Node success")
               //self.callLiveTopologyAfterSetNode()
                MyWifiManager.shared.refreshLTDataRequired = true
                self.callGetAllNodes(selectedProfile: profile)
                self.saveDeviceDetailsLocally(mac: mac, profile: profile)
            }
            else{
                self.saveButtonAPIFailedAnimation(isSetNodeFailed: true)
                Logger.info("Set Lightspeed Node failed: " + (error?.errorDescription ?? ""))
            }
        })
    }
    
    func backAnimation() {
        self.animateTableviewToBottom()
    }
    
    func saveDeviceDetailsLocally(mac: String, profile: ProfileModel) {
        if isForRecentlyDisconnected {
            MyWifiManager.shared.saveProfileChangeLocallyDisconnectedDevices(for: mac, profileName: (self.isRemove ? "" : profile.profileName), pid: (self.isRemove ? 0 : profile.pid ?? 0))
        } else {
            MyWifiManager.shared.saveProfileChangeLocally(for: mac, profileName: (self.isRemove ? "" : profile.profileName), pid: (self.isRemove ? 0 : profile.pid ?? 0))
        }
    }
    
    func presentErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .custom
        vc.isComingFromProfileCreationScreen = false
        vc.isComingFromAssignDeviceToProfileVC = true
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_change_device_owner_failure)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_UPDATE_DEVICE_DETAILS_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
        self.present(vc, animated: true)
    }
    
    func callLiveTopologyAfterSetNode() {
        APIRequests.shared.initiateLiveTopologyRequest { success, _, _ in
            if success {
                MyWifiManager.shared.refreshLTDataRequired = true
                self.saveInProgress = false
                self.stopAnimationAndDismiss()
            } else {
                Logger.info("Live topology after set Node failed")
                self.saveButtonAPIFailedAnimation(isSetNodeFailed: false)
            }
        }
    }
    
    func callGetAllNodes(selectedProfile: ProfileModel?) {
        APIRequests.shared.getAllNodes { result in
            guard case .success(_) = result else {
                Logger.info("Get All Nodes failed after set Node")
                self.delegate?.getUpdatedProfileAssigmentDetails(profileName: self.isRemove ? "" : selectedProfile?.profileName, profilePid: self.isRemove ? 0 : selectedProfile?.pid)
                self.saveButtonAPIFailedAnimation(isSetNodeFailed: false)
                return
            }
            self.saveInProgress = false
            self.stopAnimationAndDismiss()
        }
    }
    
    func stopAnimationAndDismiss() {
        self.saveInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                //self.dismiss(animated: true)
                self.backAnimation()
            }
        }
        
    }
    
    func saveButtonAPIFailedAnimation(isSetNodeFailed: Bool) {
        DispatchQueue.main.async {
            self.saveInProgress = false
            self.animationLoadingView.currentProgress = 3.0
            self.animationLoadingView.stop()
            self.animationLoadingView.isHidden = true
            self.buttonStackView.alpha = 0.0
            self.buttonStackView.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.buttonStackView.alpha = 1.0
            } completion: {_ in
                if isSetNodeFailed {
                    UIView.animate(withDuration:0.8, animations: {
                        self.delegateforDeviceAnimationForAssignProfile?.animatedVCGettingDismissed(with: self.animateddeviceIcon.image!)
                    },completion: { finished in
                        self.presentErrorMessageVC()
                    })
                    } else {
                    //self.dismiss(animated: true)
                    self.backAnimation()
                }
            }
        }
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
    
    func configureUI() {
        //deviceName.font = UIFont(name: "Regular-Medium", size: 24)
        secondaryButton.isHidden = false
        primaryButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1).cgColor
        primaryButton.setTitle("Save", for: .normal)
        secondaryButton.setTitle("Cancel", for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        secondaryButton.setTitleColor(.black, for: .normal)
        secondaryButton.layer.borderWidth = 2
        secondaryButton.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        self.bottomView.addTopShadow()
//        self.centreViewBottomConstraint.constant = UIDevice.current.hasNotch ? -70 : 0
//        self.deviceName.text = deviceDetails?.title ?? ""
//        self.deviceIcon.image = deviceDetails?.deviceImage_White
    }
        
    @objc func removeDevices(sender: UIButton!)
    {
        isRemove = true
    }
    
    func animateTableviewToTop() {
        UIView.animate(withDuration: 0.05) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.pullDeviceListUp()
               // self.bottomView.center.y -= self.bottomView.frame.height
            }
        }
    }
    
    
    func pullDeviceListUp() {
        self.deviceTableview.beginUpdates()
        emptyCellHeight = 10
        self.deviceTableview.endUpdates()
        UIView.animate(withDuration: 0.26) {
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: UIDevice.current.hasNotch ? 35 : 0)
        }
    }
    func pullProfileListDown(){
        self.deviceTableview.beginUpdates()
        self.emptyCellHeight = Int((400/xibDesignHeight)*currentScreenHeight) + 100
        self.deviceTableview.endUpdates()
        UIView.animate(withDuration: 0.4) {
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: 160)
        } completion: { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.delegateforDeviceAnimationForAssignProfile?.animatedVCGettingDismissed(with: self.animateddeviceIcon.image!)
                self.dismiss(animated: false)
            }
        }
    }
    func animateTableviewToBottom() {
        UIView.animate(withDuration: 0.1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pullProfileListDown()
            }
        }
    }
    
    
}

extension AssignDeviceToProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerView = UIView()
//            headerView.backgroundColor = .white
//            let headerLabel = UILabel()
//            headerLabel.frame = CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-20, height: 35)
//            headerLabel.text = listTitleForAssignDevice
//            headerLabel.textAlignment = .left
//            headerLabel.font = UIFont(name: "Regular-Medium", size: 24)
//            headerView.addSubview(headerLabel)
//            return headerView
//        }
        if section == 0 || section == 1 {
            let headerViewForSecondSection = UIView()
            headerViewForSecondSection.backgroundColor = energyBlueRGB
            return headerViewForSecondSection
        } else {
            let headerViewForSecondSection = UIView()
            headerViewForSecondSection.backgroundColor = .white
            return headerViewForSecondSection
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if checkAssignedToProfile {
            if section == 3 {
                let view = UIView()
                view.backgroundColor = .white
                return view
            }
        } else {
            if section == 2 {
                let view = UIView()
                view.backgroundColor = .white
                return view
            }
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if checkAssignedToProfile {
            if section == 3 {
                return 100
            }
        } else {
            if section == 2 {
                return 100
            }
        }
        return 0.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if checkAssignedToProfile {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if checkAssignedToProfile
        {
            if section == 0 {
                return 2
            } else if section == 2 {
                return availableProfiles.count
            }
            return 1
        } else {
            if section == 0 {
                return 2
            } else if section == 2 {
                return availableProfiles.count
            }
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if checkAssignedToProfile
//        {
//            if section == 0
//            {
//                return 44
//            }
//            return 0.0
//        }
//        return 0.0
//        if section == 0 {
//            return 44.0
//        }
        return 1.0
        //return 44.0 // CMA-266
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 180
            }
            return CGFloat(emptyCellHeight)
        } else if indexPath.section == 1 {
            return 69
        }
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let topcell = tableView.dequeueReusableCell(withIdentifier: "TopCell") as! TopCellForAssignProfile
                topcell.delegateforDeviceIcon = self
                if !isAnimationDone {
                    topcell.deviceNameLabel.alpha = 0.3
                }
                topcell.deviceiconImageView.image = deviceDetails?.deviceImage_White
                topcell.passDeviceIcon()
                if !isAnimationDone {
                    isAnimationDone = true
                    UIView.animate(withDuration: 0.3) {
                        topcell.deviceNameLabel.alpha = 1.0
                        topcell.deviceNameLabel.text = self.deviceDetails?.title ?? ""
                    }
                }
                return topcell
            } else {
                let cell = self.deviceTableview.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                cell.contentView.backgroundColor = energyBlueRGB
                return cell
            }
        } else if indexPath.section == 1 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TitleTableViewCell
            titleCell.titleLabel.text = listTitleForAssignDevice
            return titleCell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssignDeviceTableViewCell") as! AssignDeviceTableViewCell
            cell.selectionStyle = .default
            cell.checkImage.isHidden = (indexPath != selectedIndex)
            cell.setUpCellData(profileDetail: availableProfiles[indexPath.row])
            cell.checkImage.isHidden = (indexPath != selectedIndex)
            let bgColorForSelection = (indexPath != selectedIndex) ? UIColor.white: UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1)
            cell.ContainerView.backgroundColor = bgColorForSelection
            return cell
        }
        deviceTableview.register(UINib.init(nibName: "RemoveProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "removeProfiles")
        let removeProfilecell = tableView.dequeueReusableCell(withIdentifier: "removeProfiles", for: indexPath) as! RemoveProfileTableViewCell
        removeProfilecell.selectionStyle = .default
        removeProfilecell.check.isHidden = (indexPath != selectedIndex)
        let bgColorForSelection = (indexPath != selectedIndex) ? UIColor.white: UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1)
        removeProfilecell.containerView.backgroundColor = bgColorForSelection
        return removeProfilecell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2
        {
            isRemove = false
            self.selectedIndex = indexPath
            guard (selectedIndex != nil) else { return }
            self.deviceTableview.reloadData()
        } else if indexPath.section == 3
        {
            isRemove = true
            self.selectedIndex = indexPath
            guard (selectedIndex != nil) else { return }
            self.deviceTableview.reloadData()
        }
    }
    
}
