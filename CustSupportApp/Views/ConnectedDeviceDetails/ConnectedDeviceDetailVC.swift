//
//  ConnectedDeviceDetailVC.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 22/08/22.
//

import UIKit
import Lottie

//protocol declaration to handle animation on presenting controller
@objc protocol HandlingPopUpAnimation {
    func animatedVCGettingDismissed(with image: UIImage)
    //CMAIOS-2311 Handle animation
    @objc optional func dismissAnimatedVC(with image: UIImage, isDeviceInfoUpdated : Bool)
    @objc optional func updateParentViewWithoutDeviceIconAnimation(isProfileAssignmentChanged:Bool)
    @objc optional func animateStreamboxToBack(with image: UIImage, frame : CGRect)
}
//To display TableView values
struct DeviceDetail {
    var title: String
    var value: String
}

class ConnectedDeviceDetailVC: UIViewController {
    //create instance of protocol
    var delegate : HandlingPopUpAnimation?
    //Add values to deviceDetails array
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var pauseDurationView: UIView!
    @IBOutlet weak var btnPauseBGView: UIView!
    
    @IBOutlet weak var saperatorView: UIView!
    
    @IBOutlet weak var pauseForHourBtn: UIButton!
    
    @IBOutlet weak var pauseForTomorroBtn: UIButton!
    
    @IBOutlet weak var palyPauseStatusLabel: UILabel!
    
    @IBOutlet weak var internetDurationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playPauseIconImg: UIImageView!
    
    @IBOutlet weak var playPauseImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var playPauseImgHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileErrorLabel: UILabel!
    @IBOutlet weak var btnLabelTraling: NSLayoutConstraint!
    @IBOutlet weak var playPauseImgCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var letsFixBtn: UIButton!
    @IBOutlet weak var heightConstraintForFixItBtn: NSLayoutConstraint!
    var arrDetails:[DeviceDetail] = []
    var isAssignedToProfile = false
    var isForRecentlyDisconnected = false
    var isRedirected = false
    lazy var deviceType : String? = nil
    lazy var deviceName = ""
    lazy var isProfileAssigmentChanged: Bool = false
    lazy var updatedProfileName:String = ""
    lazy var updatedProfilePid : Int = 0
    //CMAIOS-2311 To check whether the user has edited the deviceInfo or not
    lazy var isDeviceInfoUpdated: Bool = false
    var deviceDetails: ConnectedDevice? {
        didSet {
            if arrDetails.count > 0 {
                arrDetails.removeAll()
            }
            if MyWifiManager.shared.isLegacyManagedRouter() {
                if let devType = deviceDetails?.device_type , !devType.isEmpty {
                    arrDetails.append(DeviceDetail(title: "Device Type", value: devType))
                }
                else { //CMAIOS-1036 - bug fix
                    arrDetails.append(DeviceDetail(title: "Device Type", value: "Unknown"))
                }
                if let vendor = deviceDetails?.vendor, !vendor.isEmpty, !vendor.contains("None") {
                    arrDetails.append(DeviceDetail(title: "Manufacturer", value: vendor))
                }
                if let deviceStatus = deviceDetails?.colorName, !deviceStatus.isEmpty {
                    if isForRecentlyDisconnected { //Offline
                        if let mac = deviceDetails?.macAddress, !mac.isEmpty {
                            arrDetails.append(DeviceDetail(title: "MAC Address", value: WifiConfigValues.getFormattedMACAddress(mac)))
                        }
                    }
                    else {
                        if let connType = deviceDetails?.conn_type, !connType.isEmpty {
                            if connType.caseInsensitiveCompare("Wifi") == .orderedSame {
                                arrDetails.append(DeviceDetail(title: "Connection Type", value: "Wireless"))
                            } else {
                                arrDetails.append(DeviceDetail(title: "Connection Type", value: connType.firstCapitalized))
                            }
                        }
                        if let mac = deviceDetails?.macAddress, !mac.isEmpty {
                            arrDetails.append(DeviceDetail(title: "MAC Address", value: WifiConfigValues.getFormattedMACAddress(mac)))
                        }
                        if let iPAddress = deviceDetails?.ipAddress, !iPAddress.isEmpty {
                            arrDetails.append(DeviceDetail(title: "LAN IP Address", value: iPAddress))
                        }
                        if let band = deviceDetails?.band, !band.isEmpty {
                            guard let connType = deviceDetails?.conn_type, !connType.isEmpty else {
                                return
                            }
                            if connType.lowercased() != "wired" {
                                var replaced = band.replacingOccurrences(of: ",", with: " and ")
                                if band == "2" || band == "2 and 5" {
                                    replaced = replaced.replacingOccurrences(of: "2", with: "2.4")
                                }
                                let strFrequency = replaced.appending(" GHz")
                                arrDetails.append(DeviceDetail(title: "Frequency Band", value: strFrequency))
                            }
                        }
                    }
                }
            } else {
                if let deviceStatus = deviceDetails?.colorName, !deviceStatus.isEmpty {
                    if isForRecentlyDisconnected { //Offline or disconnected
                        if let devType = deviceDetails?.device_type, !devType.isEmpty {
                            if MyWifiManager.shared.isSmartWifi() {
                                arrDetails.append(DeviceDetail(title: "Device Type", value: devType.firstCapitalized))
                            } else {
                                arrDetails.append(DeviceDetail(title: "Equipment type", value: devType.firstCapitalized)) // CMA-87
                            }
                        }
                        if let vendor = deviceDetails?.vendor, !vendor.isEmpty, !vendor.contains("None") {
                            arrDetails.append(DeviceDetail(title: "Manufacturer", value: vendor))
                        }
                        if let mac = deviceDetails?.macAddress, !mac.isEmpty {
                            arrDetails.append(DeviceDetail(title: "MAC Address", value: WifiConfigValues.getFormattedMACAddress(mac)))
                        }
                    } else {
                        if let devType = deviceDetails?.device_type, !devType.isEmpty {
                            if MyWifiManager.shared.isSmartWifi() {
                                arrDetails.append(DeviceDetail(title: "Device Type", value: devType.firstCapitalized))
                            } else {
                                arrDetails.append(DeviceDetail(title: "Equipment type", value: devType.firstCapitalized)) // CMA-87
                            }
                        }
                        if let vendor = deviceDetails?.vendor, !vendor.isEmpty, !vendor.contains("None") {
                            arrDetails.append(DeviceDetail(title: "Manufacturer", value: vendor))
                        }
                        if let connType = deviceDetails?.conn_type, !connType.isEmpty {
                            if connType.caseInsensitiveCompare("Wifi") == .orderedSame {
                                arrDetails.append(DeviceDetail(title: "Connection Type", value: "Wireless"))
                            } else {
                                arrDetails.append(DeviceDetail(title: "Connection Type", value: connType.firstCapitalized))
                            }
                        }
                        if let mac = deviceDetails?.macAddress, !mac.isEmpty {
                            arrDetails.append(DeviceDetail(title: "MAC Address", value: WifiConfigValues.getFormattedMACAddress(mac)))
                        }
                        //            arrDetails = [DeviceDetail(title: "Device Type", value: deviceDetails?.device_type.firstCapitalized ?? "" ),
                        //                          DeviceDetail(title: "Connection Type", value: deviceDetails?.conn_type.firstCapitalized ?? "" ),
                        //                          DeviceDetail(title: "MAC Address", value: deviceDetails?.macAddress ?? "" )]
                        if let iPAddress = deviceDetails?.ipAddress, !iPAddress.isEmpty {
                            arrDetails.append(DeviceDetail(title: "LAN IP Address", value: iPAddress))
                        }
                        if let band = deviceDetails?.band, !band.isEmpty {
                            guard let connType = deviceDetails?.conn_type, !connType.isEmpty else {
                                return
                            }
                            if connType.lowercased() != "wired" {
                                var replaced = band.replacingOccurrences(of: ",", with: " and ")
                                if band == "2" || band == "2 and 5" {
                                    replaced = replaced.replacingOccurrences(of: "2", with: "2.4")
                                }
                                let strFrequency = replaced.appending(" GHz")
                                arrDetails.append(DeviceDetail(title: "Frequency Band", value: strFrequency))
                            }
                        }
                    }
                }
            }
        }
    }

    //UI Outlets
    @IBOutlet weak var statusIndicatorImgView: UIImageView!
    @IBOutlet weak var btnEditDeviceName: UIButton!
    @IBOutlet weak var btnEditProfileName: UIButton!
    @IBOutlet weak var btnPauseInternet: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var pauseBtnBGView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var pauseBtnBG: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var deviceIcon: UIImageView!
    @IBOutlet weak var deviceDetailTblVw: UITableView!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var viewAvatar: UIView!
    @IBOutlet weak var lblDeviceAssigned: UILabel!
    @IBOutlet weak var lblProfileName: UILabel!
    //Constraint Outlets
    @IBOutlet weak var detailViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDeviceAssignedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deviceIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deviceStatusBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDeviceAssignedLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewInternetHandlingLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewInternetHandlingHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewInternetHandlingTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var vwCloseHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pauseInternetlblLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarImageToInfoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageTolblDeviceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblProfileToInfoViewLeadingConstraint: NSLayoutConstraint!
    var editDeviceGesture:UITapGestureRecognizer!
    var assignDeviceGesture:UITapGestureRecognizer!
    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    var deviceIconGesture:UITapGestureRecognizer!
    var isDevicePaused = false
    @IBOutlet weak var profileIconLottieView: LottieAnimationView!
    @IBOutlet weak var bottomviewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeButtonYAlign: NSLayoutConstraint!
    var currentDevicePID = 0
    var qualtricsAction : DispatchWorkItem?
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =  energyBlueRGB
        currentDevicePID = self.deviceDetails?.pid ?? 0
        // register TableViewCells
        self.deviceDetailTblVw.register(UINib(nibName: "ConnectedDeviceDetailCell", bundle: nil), forCellReuseIdentifier: "ConnectedDeviceDetailCell")
        
        // calculate height of table view as per data
        self.tableViewHeight.constant = CGFloat(self.arrDetails.count) * deviceDetailTblVw.rowHeight
        
        //Check whether device is assigned or not so display UI accordingly
        self.deviceIcon.image = self.deviceDetails?.deviceImage_White
        if MyWifiManager.shared.isSmartWifi() {
            self.setProfileNameAndOtherAttributes()
        } else {
            self.informationView.isHidden = true
        }
        
        //Handle UI for small/large screen size
        self.updateConstraintsAsPerScreenSize()
    
        //Handle Pull To Refresh animation
        initialUIConstantsForPullToRefresh()
        initiatePullToRefresh()
        
        //handle tableView animation from bottom to top
        deviceStatusBottomConstraint.constant = self.view.frame.size.height
        
        //Update device name
        self.lblDeviceName.text = deviceDetails?.title ?? ""
        self.lblDeviceName.isUserInteractionEnabled = true
        self.deviceIcon?.isUserInteractionEnabled = true
        editDeviceGesture = UITapGestureRecognizer(target: self, action: #selector(self.editDeviceNameAction))
        deviceIconGesture = UITapGestureRecognizer(target: self, action: #selector(self.editDeviceNameAction))
        assignDeviceGesture = UITapGestureRecognizer(target: self, action: #selector(self.assignDeviceProfileAction))
        self.lblDeviceName.addGestureRecognizer(editDeviceGesture)
        self.deviceIcon?.addGestureRecognizer(deviceIconGesture)
        self.lblProfileName.addGestureRecognizer(assignDeviceGesture)
        self.lblProfileName.isUserInteractionEnabled = true
        //Update status and respective color
        self.showBackgroundColor()
        self.internetDurationHeightConstraint.constant = 0
        self.pauseDurationView.isHidden = true
        self.pauseDurationView.alpha = 0.0
        checkForProfileDetailsError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MyWifiManager.shared.refreshLTDataRequired {
            //CMAIOS-2311
            self.isDeviceInfoUpdated = true
            if MyWifiManager.shared.isGateWayWifi6(){
                self.refreshPausedDevices()
            }
            self.getRefreshedData()
         //   MyWifiManager.shared.refreshLTDataRequired = false
        }
        checkForProfileDetailsError()
        self.updateUIAsPerDeviceStatus()
        qualtricsAction = self.checkQualtrics(screenName: WiFiManagementScreenDetails.WIFI_DEVICE_DETAILS.rawValue, dispatchBlock: &qualtricsAction)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func showBackgroundColor()
    {
        if let statusValues = deviceDetails?.getColor() {
            self.statusIndicatorImgView.backgroundColor = statusValues.color
            if statusValues.status.lowercased() == "weak signal" || statusValues.status.contains("Weak") {
                self.view.backgroundColor = midnightBlueRGB
                self.letsFixBtn.isHidden = false
                self.letsFixBtn.layer.borderColor = UIColor.white.cgColor
                self.lblStatus.text = statusValues.status
            } else {
                if statusValues.status.lowercased() == "offline" {
                    self.view.backgroundColor = midnightBlueRGB
                } else {
                    self.view.backgroundColor = energyBlueRGB
                }
                self.lblStatus.text = statusValues.status
                self.letsFixBtn.isHidden = true
            }
        }
    }
    func checkForProfileDetailsError() {
        if ProfileManager.shared.profiles?.count == 0 {
            // Show errorText
            self.profileErrorLabel.isHidden = false
            self.lblProfileName.isHidden = true
            self.btnEditProfileName.isHidden = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_DEVICE_DETAILS_PROFILE_ASSIGNMENT_DATA_RETRIEVAL_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
        } else {
            self.profileErrorLabel.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        self.setUpInitialUI()
       //handle animation of DetailView
        UIView.animate(withDuration: 0.5) {
            self.setAlphaOfUIElements(alpha: 1.0)
            self.animateDetailViewAfterPlacingDeviceIcon()
        } completion: { _ in
            self.detailViewBottomConstraint.priority = UILayoutPriority.required
            self.view.layoutIfNeeded()
            self.lblDeviceName.isUserInteractionEnabled = true
            self.lblDeviceName.addGestureRecognizer(self.editDeviceGesture)
        }
        if MyWifiManager.shared.isGateWayWifi6()
        {
            self.btnPauseBGView.isHidden = false
        }
        else
        {
            self.btnPauseBGView.isHidden = true
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_DEVICE_DETAILS.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
     }
    override func viewWillDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self)
        self.qualtricsAction?.cancel()
    }
    //MARK: LiveTopologyAPI response methods
 
    @objc func lightSpeedAPICallBack() {
        self.pullToRefresh(hideScreen: true, isComplete: true)
        self.getRefreshedData()
        self.deviceDetailTblVw.reloadData()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
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
            self.handleUserInteractionOnPullToRefresh(isAllowed: false)
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.handleUIForSmallerAndLargerDevices(isPullToRefresh: self.isPullToRefresh)
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                self.handleUserInteractionOnPullToRefresh(isAllowed: true)
                UIView.animate(withDuration: 0.5) {
                    self.isPullToRefresh = false
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshAnimation.isHidden = true
                    self.vwPullToRefreshTop.constant = 80
                    self.vwPullToRefreshHeight.constant = 0
                    self.handleUIForSmallerAndLargerDevices(isPullToRefresh: self.isPullToRefresh)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    ///Method for enable/Disable user interaction
    func handleUserInteractionOnPullToRefresh(isAllowed: Bool) {
        self.deviceIcon.isUserInteractionEnabled = isAllowed
        self.lblDeviceName.isUserInteractionEnabled = isAllowed
        self.lblProfileName.isUserInteractionEnabled = isAllowed
        self.btnEditDeviceName.isUserInteractionEnabled = isAllowed
        self.btnEditProfileName.isUserInteractionEnabled = isAllowed
        self.btnPauseInternet.isUserInteractionEnabled = isAllowed
        if !self.letsFixBtn.isHidden {
            self.letsFixBtn.isUserInteractionEnabled = isAllowed
        }
    }
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        // After Refresh
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        MyWifiManager.shared.triggerOperationalStatus()
        if MyWifiManager.shared.isGateWayWifi6() {
            DispatchQueue.global(qos: .background).async {
                self.refreshPausedDevices()
            }
        }
    }
    
    func handleUIForSmallerAndLargerDevices(isPullToRefresh:Bool) {
        //For iPod, iPhone SE First Gen
        if currentScreenWidth < xibDesignWidth {
            self.detailViewBottomConstraint.constant = isPullToRefresh ? -20 : 50.0
            self.deviceIconTopConstraint.constant = isPullToRefresh ? self.deviceIconTopConstraint.constant + 60 : UIDevice.current.topInset + 12
            return
        }
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            self.deviceIconTopConstraint.constant = isPullToRefresh ? self.deviceIconTopConstraint.constant + 80 : UIDevice.current.topInset + 20
        } else {
            self.deviceIconTopConstraint.constant = isPullToRefresh ? self.deviceIconTopConstraint.constant + 60 : UIDevice.current.topInset + 26
        }
        self.detailViewBottomConstraint.constant = isPullToRefresh ? 0 : 80.0
    }
    
    //MARK: Initial UI SetUp methods
    func setUpInitialUI() {
        //add corner radius to Play/Pause button
        pauseBtnBGView.layer.cornerRadius = self.pauseBtnBGView.frame.size.height/2
        pauseBtnBGView.layer.borderWidth = 2.0
        if !isRedirected{
            pauseBtnBGView.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        }
        pauseBtnBG.layer.cornerRadius = self.pauseBtnBG.frame.size.height/2
    }
    
    //Handle alpha for deviceInfo
    func setAlphaOfUIElements(alpha : CGFloat) {
        self.lblStatus.alpha = alpha
        self.lblDeviceName.alpha = alpha
        self.statusIndicatorImgView.alpha = alpha
        self.btnEditDeviceName.alpha = alpha
        self.letsFixBtn.alpha = alpha
    }
    
    func setUIForPausedState() {
        //if ProfileManager.shared.isDeviceMacPaused(mac: self.deviceDetails?.macAddress ?? "") {
            self.isDevicePaused = true
            self.topView.isHidden = true
            self.pauseDurationView.isHidden = true
            self.lblStatus.text = "Paused"
            self.internetDurationHeightConstraint.constant = 0
            self.pauseDurationView.alpha = 0.0
            self.pauseBtnBGView.backgroundColor = UIColor.init(red: 246/255, green: 102/255, blue: 8/255, alpha: 1)
            self.pauseBtnBGView.layer.borderColor = UIColor.init(red: 246/255, green: 102/255, blue: 8/255, alpha: 1).cgColor
            self.palyPauseStatusLabel.font = UIFont(name: "Regular-Bold", size: 18)
            self.palyPauseStatusLabel.text = "Unpause Internet for this device"
            self.palyPauseStatusLabel.textColor = .white
            self.pauseBtnBG.backgroundColor = .white
            self.playPauseImgWidthConstraint.constant = 20
            self.playPauseImgHeightConstraint.constant = 20
            self.playPauseImgCenterConstraint.constant = self.playPauseImgWidthConstraint.constant/2 - 8
            self.playPauseIconImg.image = UIImage(named: "pause_icon.png")
            self.view.backgroundColor = pauseBgColor
            self.statusIndicatorImgView.backgroundColor = UIColor.StatusPause
//            if sender.tag == 1{
//                let formatter = DateFormatter()
//                formatter.dateFormat = "hh:mm a"
//                let hourString = formatter.string(from: Date() + 3600)
//                self.lblStatus.text = "Paused until " + hourString
//                //Pause API call
//                self.triggerPauseDevice(endTime: Date(timeIntervalSinceNow: 3600))
//            } else {
//                self.lblStatus.text = "Paused until 6 am tomorrow"
//                //Create end time for 6:00 AM tomorrow
//                let day = Calendar.current.component(.day, from: Date(timeIntervalSinceNow: 86400))
//                let month = Calendar.current.component(.month, from: Date(timeIntervalSinceNow: 86400))
//                let year = Calendar.current.component(.year, from: Date(timeIntervalSinceNow: 86400))
//                let calendar = Calendar.current
//                let components = DateComponents(year: year, month: month, day: day, hour: 6, minute: 0, second: 0)
//                let endDate = calendar.date(from: components)!
//                //Pause API call
//                self.triggerPauseDevice(endTime: endDate)
//            }
      //  }
    }
    
    func setProfileNameAndOtherAttributes(){
        var avatarName = ""
        var pid  = 0
        //If get all nodes API fails
        if let devices = DeviceManager.shared.devices, !devices.isEmpty {
            pid = DeviceManager.shared.getPIDForMac(mac: deviceDetails?.macAddress ?? "")
        } else {
            if let LT_deviceDetails = MyWifiManager.shared.getDeviceDetailsForMAC( deviceDetails?.macAddress ?? "") {
                pid = LT_deviceDetails.pid ?? self.deviceDetails?.pid ?? 0
            } else if let selectedId = self.deviceDetails?.pid{
                // get pid from deviceDetails if the device status is offline
                pid = selectedId
            } else {
                pid = 0
            }
        }
        
        if pid == 0 || deviceDetails?.profileName == "" {
            avatarImageTolblDeviceTopConstraint.priority = UILayoutPriority(rawValue: 250)
            avatarImageToInfoViewTopConstraint.priority = UILayoutPriority(rawValue: 1000)
            avatarLeadingConstraint.priority = UILayoutPriority(rawValue: 250)
            lblProfileToInfoViewLeadingConstraint.priority = UILayoutPriority(rawValue: 1000)
            avatarName = "Assign this device to a profile"
            lblDeviceAssigned.isHidden = true
            lblProfileName.textColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1)
            viewAvatar.isHidden = true
            lblProfileName.font = UIFont.init(name: "Regular-Bold", size: 18.0)
            self.isAssignedToProfile = false
        } else {
            avatarName = deviceDetails?.profileName ?? ""
            lblDeviceAssigned.isHidden = false
            viewAvatar.isHidden = false
            lblProfileName.font = UIFont.init(name: "Regular-Medium", size: 18.0)
            lblProfileName.textColor = UIColor.black
            self.isAssignedToProfile = true
            avatarImageToInfoViewTopConstraint.priority = UILayoutPriority(rawValue: 250)
            lblProfileToInfoViewLeadingConstraint.priority = UILayoutPriority(rawValue: 250)
        }
        lblProfileName.text = avatarName
        if let avatarID = ProfileManager.shared.getAvatarIDFromPID(pid: deviceDetails?.pid ?? 0) {
            self.profileIconLottieView.createStaticImageForProfileAvatar(avatarID: avatarID, profileName: avatarName, isOnlinePause: true)
        }
    }
    
    //MARK: Helper Functions
    func updateConstraintsAsPerScreenSize() {
        //For iPod, iPhone SE First Gen
        if currentScreenWidth < xibDesignWidth {
            lblDeviceAssignedTopConstraint.constant = (lblDeviceAssignedTopConstraint.constant/xibDesignWidth)*currentScreenWidth - 20
            lblDeviceAssignedLeadingConstraint.constant = (lblDeviceAssignedLeadingConstraint.constant/xibDesignWidth)*currentScreenWidth
            avatarLeadingConstraint.constant = (avatarLeadingConstraint.constant/xibDesignWidth)*currentScreenWidth
            lblProfileToInfoViewLeadingConstraint.constant = (lblProfileToInfoViewLeadingConstraint.constant/xibDesignWidth)*currentScreenWidth
            avatarImageTolblDeviceTopConstraint.constant = (avatarImageTolblDeviceTopConstraint.constant/xibDesignWidth)*currentScreenWidth - 10
            viewInternetHandlingLeadingConstraint.constant = (viewInternetHandlingLeadingConstraint.constant/xibDesignWidth)*currentScreenWidth
            viewInternetHandlingTrailingConstraint.constant = viewInternetHandlingLeadingConstraint.constant
//            vwCloseHeightConstraint.constant = 50.0
            self.detailViewBottomConstraint.constant = 50.0
            pauseInternetlblLeadingConstraint.constant = 15.0
            viewInternetHandlingHeightConstraint.constant = 50.0
            tableViewTopConstraint.constant = 0.0
            self.letsFixBtn.layer.cornerRadius = 15
            self.view.setNeedsUpdateConstraints()
            return
        }
        // Handle UI for large and small screens
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            // topInset -5 for large screen matches 30
            lblDeviceAssignedTopConstraint.constant = 40.0
            lblDeviceAssignedLeadingConstraint.constant = 33.0
            avatarLeadingConstraint.constant = 34.0
            lblProfileToInfoViewLeadingConstraint.constant = 34.0
            avatarImageTolblDeviceTopConstraint.constant = 3.0
            viewInternetHandlingLeadingConstraint.constant = 31.0
            viewInternetHandlingTrailingConstraint.constant = 32.0
            // 35 instead 40 to match space
            tableViewTopConstraint.constant = 35.0
            self.heightConstraintForFixItBtn.constant = 40
            self.letsFixBtn.layer.cornerRadius = 20
        } else {
            lblDeviceAssignedTopConstraint.constant = 36.0
            lblDeviceAssignedLeadingConstraint.constant = 23.0
            avatarLeadingConstraint.constant = 24.0
            lblProfileToInfoViewLeadingConstraint.constant = 24.0
            avatarImageTolblDeviceTopConstraint.constant = 14.0
            viewInternetHandlingLeadingConstraint.constant = 20.0
            viewInternetHandlingTrailingConstraint.constant = 19.0
            tableViewTopConstraint.constant = 18.0
            self.heightConstraintForFixItBtn.constant = 30
            self.letsFixBtn.layer.cornerRadius = 15
        }
        if UIDevice.current.hasNotch {
            self.closeButtonYAlign.constant = -11
            deviceIconTopConstraint.constant = UIDevice.current.topInset + 20
        } else {
            self.closeButtonYAlign.constant = -8
            deviceIconTopConstraint.constant = UIDevice.current.topInset + 26
        }
        self.view.setNeedsUpdateConstraints()
    }
        
    func getRecentlyDisconnectedData() {
        guard let connectedDevice = self.deviceDetails else {
            return
        }
        let deviceMAC = WifiConfigValues.getFormattedMACAddress(connectedDevice.macAddress)
        let recently_disc = MyWifiManager.shared.getRecentlyDisconnected()
        if recently_disc.isEmpty {
            return
        }
        var rec_disconnected_device: LightSpeedAPIResponse.rec_disconn?
        let devices = recently_disc.filter{($0.mac?.isMatching(deviceMAC) ?? false)}
        if !devices.isEmpty {
            rec_disconnected_device = devices.first
            var name = "Unknown"
            var image_white: UIImage! =  UIImage(named: "unknown_white_static")
            var image_gray: UIImage! =  UIImage(named: "unknown_gray_static")
            var section = "Others"
            let vendor = DeviceManager.shared.getVendorForMac(mac: rec_disconnected_device?.mac ?? "")

            //Display Name
            if let friendlyName = rec_disconnected_device?.friendly_name, !friendlyName.isEmpty {
                name = friendlyName
            } else if let hostname = rec_disconnected_device?.hostname, !hostname.isEmpty, hostname != rec_disconnected_device?.mac {
                name = hostname
            } else if let cmaDisName = rec_disconnected_device?.cma_display_name, !cmaDisName.isEmpty {
                name = cmaDisName
            } else if let vendorName = vendor, !vendorName.isEmpty, !vendorName.contains("None") {
                name = vendorName
            } else {
                name = "Unnamed device"
            }
            if let imageName = rec_disconnected_device?.cma_dev_type, !imageName.isEmpty {
                image_white = DeviceManager.IconType.white.getDeviceImage(name: imageName)
                image_gray = DeviceManager.IconType.gray.getDeviceImage(name: imageName)
            } else if let imageName = rec_disconnected_device?.cma_display_name, !imageName.isEmpty {
                image_white = DeviceManager.IconType.white.getDeviceImage(name: imageName)
                image_gray = DeviceManager.IconType.gray.getDeviceImage(name: imageName)
            } else {
                image_white = DeviceManager.IconType.white.getDeviceImage(name: "unknown_device")
                image_gray = DeviceManager.IconType.gray.getDeviceImage(name: "unknown_device")
            }
            
            // Profile / category
            if let profile = rec_disconnected_device?.profile, !profile.isEmpty {
                section = profile
            } else if let category = rec_disconnected_device?.cma_category, !category.isEmpty {
                section = category
            }
            let device = ConnectedDevice (title: name, deviceImage_Gray: image_gray, deviceImage_White: image_white, colorName: "red", device_type: rec_disconnected_device?.cma_dev_type ?? "", conn_type: "", vendor: vendor ?? "", macAddress: WifiConfigValues.getFormattedMACAddress(rec_disconnected_device?.mac ?? deviceMAC), ipAddress: rec_disconnected_device?.ip ?? "", profileName: rec_disconnected_device?.profile ?? "", band: "", sectionTitle: section, pid: rec_disconnected_device?.pid ?? 0)
            self.deviceDetails = device
            DispatchQueue.main.async {
                self.deviceIcon.image = self.deviceDetails?.deviceImage_White
                if MyWifiManager.shared.isSmartWifi() {
                    self.setProfileNameAndOtherAttributes()
                } else {
                    self.informationView.isHidden = true
                }
                self.updateUIAsPerDeviceStatus()
                self.lblDeviceName.text = self.deviceDetails?.title ?? ""
                self.deviceDetailTblVw.reloadData()
            }
        }
    }
    
    func getRefreshedData() {
        self.animateDetailViewAfterPlacingDeviceIcon()
        if isForRecentlyDisconnected {
            getRecentlyDisconnectedData()
            return
        }
        guard let connectedDevice = self.deviceDetails else {
            return
        }
        let deviceMAC = WifiConfigValues.getFormattedMACAddress(connectedDevice.macAddress)
        //get DeviceDetails from LT if the device status is online or weak
        if let details = MyWifiManager.shared.getDeviceDetailsForMAC(deviceMAC) {
            //Display Name
            let displayName = self.getDeviceDisplayName(friendlyName: details.friendly_name, hostName: details.hostname, cmaDisplayName: details.cma_display_name, vendorName: details.vendor, macAddress: details.mac)
            self.deviceDetails = getConnectedDeviceModel(deviceName: displayName, profilePId:  details.pid, deviceType: details.cma_dev_type ?? details.device_type, deviceMac: details.mac, statusColor: details.color, profileName: details.profile, deviceIP: details.ip, connectionType: details.conn_type, band: details.band, vendor: details.vendor)
        } else {
            //If getAllNodes API fails and the device is offline
            if DeviceManager.shared.devices == nil {
                //get updateDeviceDetails from EditConnectedDeviceDetailsVC and use existing deviceDetails
                self.deviceDetails = self.getConnectedDeviceModel(deviceName: self.isProfileAssigmentChanged ? self.deviceDetails?.title ?? "" : self.deviceName, profilePId: self.isProfileAssigmentChanged ? self.updatedProfilePid : self.deviceDetails?.pid, deviceType:  self.isProfileAssigmentChanged ? self.deviceDetails?.device_type : self.deviceType, deviceMac: self.deviceDetails?.macAddress, statusColor: self.deviceDetails?.colorName, profileName: self.isProfileAssigmentChanged ? self.updatedProfileName : self.lblProfileName.text, deviceIP: nil, connectionType: nil, band: nil, vendor: nil)
            } else {
                //get DeviceDetails from getAllNodes response if the device status is offline
                let details = DeviceManager.shared.getDeviceDetailsForMac(mac: deviceMAC)
                //Display Name
                let displayName = self.getDeviceDisplayName(friendlyName: details?.friendlyName, hostName: details?.hostname, cmaDisplayName: nil, vendorName: nil, macAddress: details?.mac)
                self.deviceDetails = self.getConnectedDeviceModel(deviceName: displayName, profilePId: details?.pid, deviceType: details?.deviceType, deviceMac: details?.mac, statusColor: self.deviceDetails?.colorName, profileName: details?.profile, deviceIP: nil, connectionType: nil, band: nil, vendor: details?.vendor)
            }
        }
        ProfileModelHelper.shared.updateNodeDataForProfile(deviceMac:deviceMAC, selectedProfilePid: self.currentDevicePID, updatedDeviceDetails: self.getLightSpeedNode())
        DispatchQueue.main.async {
            self.deviceIcon.image = self.deviceDetails?.deviceImage_White
            if MyWifiManager.shared.isSmartWifi() {
                self.setProfileNameAndOtherAttributes()
            } else {
                self.informationView.isHidden = true
            }
            self.lblDeviceName.text = self.deviceDetails?.title ?? ""
            self.deviceDetailTblVw.reloadData()
        }
    }
    
    func getConnectedDeviceModel(deviceName : String, profilePId:Int?, deviceType: String?, deviceMac:String?, statusColor:String?, profileName:String?, deviceIP:String?, connectionType:String?, band:String?, vendor: String?) -> ConnectedDevice{
        return ConnectedDevice(title: deviceName,
                               deviceImage_Gray:  (DeviceManager.IconType.gray.getDeviceImage(name:  deviceType ?? "unknown_gray_static")),
                               deviceImage_White: (DeviceManager.IconType.white.getDeviceImage(name: deviceType ?? "unknown_white_static")),
                               colorName: statusColor ?? "",
                               device_type: deviceType ?? "",
                               conn_type: connectionType ?? "",
                               vendor: vendor ?? "",
                               macAddress: deviceMac ?? "",
                               ipAddress: deviceIP ?? "",
                               profileName: profileName ?? "", band: band ?? "",
                               sectionTitle: "",
                               pid: profilePId ?? 0)
    }
    
    func getLightSpeedNode()->LightspeedNode? {
        return LightspeedNode(accno: "", mac: self.deviceDetails?.macAddress, gwid: "", pid: self.isProfileAssigmentChanged ? self.updatedProfilePid : self.deviceDetails?.pid, friendlyName: self.isProfileAssigmentChanged ? self.updatedProfileName :  self.deviceName, hostname: self.isProfileAssigmentChanged ? self.updatedProfileName :  self.lblProfileName.text, location: "", createdDate: "", updatedDate: "", nodeType: "", category: "", deviceType: self.isProfileAssigmentChanged ? self.deviceDetails?.device_type : self.deviceType, vendor: "" , profile: self.isProfileAssigmentChanged ? self.updatedProfileName : self.lblProfileName.text)
    }
    
    func getDeviceDisplayName(friendlyName:String?, hostName:String?, cmaDisplayName:String?, vendorName:String?, macAddress:String?)->String{
        //Display Name
        var displayName = "Unknown"
        if let friendlyName = friendlyName, !friendlyName.isEmpty {
            displayName = friendlyName
        } else if let hostname = hostName, !hostname.isEmpty, hostname != macAddress {
            displayName = hostname
        } else if let cmaDisName = cmaDisplayName, !cmaDisName.isEmpty {
            displayName = cmaDisName
        } else if let vendorName = vendorName, !vendorName.isEmpty, !vendorName.contains("None") {
            displayName = vendorName
        } else {
            displayName = "Unnamed device"
        }
        return displayName
    }
    
    @objc func editDeviceProfileAction() {
       //handle EditDeviceProfile
    }
    func setTransitionBackgroundColor() -> UIColor {
        if let statusValues = deviceDetails?.getColor() {
            if statusValues.status.contains("Weak") || statusValues.status.lowercased() == "weak signal" || statusValues.status.lowercased() == "offline"{
                return midnightBlueRGB
            } else {
                return energyBlueRGB
            }
        }
        return energyBlueRGB
    }
    
    @IBAction func assignDeviceProfileAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        let vc = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(identifier: "AssignDeviceToProfileVC") as AssignDeviceToProfileViewController
        vc.deviceDetails = self.deviceDetails
        vc.isForRecentlyDisconnected = self.isForRecentlyDisconnected
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        vc.checkAssignedToProfile = isAssignedToProfile
        //self.present(vc, animated: true)
        vc.delegateforDeviceAnimationForAssignProfile = self
        let transitionColor = self.setTransitionBackgroundColor()
        self.addDeviceIconAsSubviewAndAnimateForAssignProfile(frame: self.deviceIcon.frame, iconImage: self.deviceIcon.image!,backGroundColor: transitionColor) { isAnimationCompleted in
            self.present(vc, animated: false)
        }
    }
    
    func getSTBNodeForNav() -> Extender {
        let arrayOfSTB = MyWifiManager.shared.getTvStreamDevices()
        let stbnode = arrayOfSTB.filter { WifiConfigValues.checkMACFormat(mac: $0.macAddress).isMatching(WifiConfigValues.checkMACFormat(mac: self.deviceDetails?.macAddress ?? "")) == true }.first
        let deviceImageValue = stbnode?.deviceType ?? ""
        let extenderName = stbnode?.friendlyname ?? ""
        return Extender.init(title: extenderName , colorName: "", status: "", device_type: stbnode?.deviceType ?? "", conn_type: "", macAddress: stbnode?.macAddress ?? "", ipAddress: "", band: "", image: DeviceManager.IconType.white.getStreamImage(name: deviceImageValue.lowercased() == "unknown" ? "unknown" : deviceImageValue), hostname: "", category: "")
        }

    @IBAction func editDeviceNameAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        //handle edit device name
        
        if (MyWifiManager.shared.getStreamDevicesFromAccounts().contains(where: { node in WifiConfigValues.checkMACFormat(mac: node.mac ?? "").isMatching(WifiConfigValues.checkMACFormat(mac: deviceDetails?.macAddress ?? ""))})) {
            let networkPointRename = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "NetworkPointRename") as! NetworkPointRenameViewController
            networkPointRename.modalPresentationStyle = .fullScreen
            networkPointRename.isFromTVFlow = true
            networkPointRename.extender = getSTBNodeForNav()
            self.present(networkPointRename, animated: true, completion: nil)
        } else {
            let vc = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(identifier: "EditConnectedDevice") as EditConnectedDeviceDetailsViewController
            vc.passingImag = self.deviceIcon.image
            vc.connectedDevice = self.deviceDetails
            vc.isForRecentlyDisconnected = self.isForRecentlyDisconnected
            vc.deviceName = lblDeviceName.text ?? ""
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            vc.delegateforDeviceAnimation = self
            let transitionColor = self.setTransitionBackgroundColor()
            self.addDeviceIconAsSubviewAndAnimate(frame: self.deviceIcon.frame, iconImage: self.deviceIcon.image!, isEditDeviceScreen: true, backGroundColor: transitionColor) { isAnimationCompleted in
                self.present(vc, animated: false)
            }
        }
    }
    
    @IBAction func letsFixBtnTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
//        let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "InternetSlowViewController") as InternetSlowViewController
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true)
        
        guard let vc = OneDeviceSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return } 
        let nav = UINavigationController.init(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        vc.isComingFromLetUsHelp = true
        self.present(nav, animated: true)
    }
    
        
    //MARK: DeviceIcon and DetailView animation Methods
    // Adjust dynamic displacement for device with notch
    func getNotchDisplacement() -> CGFloat {
        return CGFloat(64.0)
    }
    
    //get Top And Bottom Separator Margin from avatarIcon
    func getTopAndBottomSeparatorMargin() ->(topMargin: CGFloat , bottomMargin: CGFloat ){
        var topMargin = 0.0, bottomMargin = 0.0
        //For iPod
        if currentScreenWidth < xibDesignWidth{
            topMargin = 40.0
            bottomMargin = 4.0
        } else {
            topMargin = 50.0
            bottomMargin = 21.0
        }
        return (topMargin, bottomMargin)
    }
        
    //Handling animation of deviceIcon
    func animateDeviceIcon(deviceIconImgVw : UIImageView) {
        let vwCenterX = self.view.frame.width/2 - deviceIcon.frame.size.width/2
        deviceIconImgVw.frame = CGRect.init(origin: CGPoint.init(x: vwCenterX , y: deviceIcon.frame.origin.y), size: CGSize.init(width:  deviceIcon.frame.size.width, height: deviceIcon.frame.size.height))
        //handle topSpace as per screenSize
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch{
            deviceIconImgVw.frame.origin.y = UIDevice.current.topInset + 41
        } else {
            deviceIconImgVw.frame.origin.y = UIDevice.current.topInset + 12
        }
        self.view.layoutIfNeeded()
    }
    
    //Handling animation of detailView from Bottom to Top
    func animateDetailViewAfterPlacingDeviceIcon(){
        //handle topSpace as per screenSize
        self.bottomviewHeightConstraint.constant = 80
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch{
            if let statusValues = deviceDetails?.getColor() {
                if statusValues.status.contains("Weak")
                {
                    deviceStatusBottomConstraint.constant = 80.0
                }else{
                    deviceStatusBottomConstraint.constant = 60.0
                }
            }
           
        } else {
            if let statusValues = deviceDetails?.getColor() {
                if statusValues.status.contains("Weak")
                {
                    deviceStatusBottomConstraint.constant = 60
                }else{
                    deviceStatusBottomConstraint.constant = 29.0
                }
            }
            }
        self.view.layoutIfNeeded()
    }
    
    //MARK: Close Button Action
    @IBAction func closeBtnAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        //set deviceStatus bottom constraint equal to current XIB height in order to animate DetailView
        self.deviceStatusBottomConstraint.constant = self.view.frame.size.height
        UIView.animate(withDuration: 0.8) { [self] in
            //Fade out top device info
            self.setAlphaOfUIElements(alpha: 0.0)
            //animate detail View from top to bottom
            self.detailViewBottomConstraint.priority = UILayoutPriority.defaultLow
            self.bottomviewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            // check if the current presenting controller is ViewProfileWithDeviceViewController and profile assignment is changed or not
            if self.delegate is ViewProfileWithDeviceViewController && self.currentDevicePID != self.deviceDetails?.pid {
                    //remove BG View used for deviceIcon Animation before dismissing
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RemoveBGAnimationView"),object: nil))
                self.delegate?.updateParentViewWithoutDeviceIconAnimation?(isProfileAssignmentChanged: true)
                   self.dismiss(animated: true)
                   return
            }
            /*** default behaviour whether the current presenting controller is ViewProfileWithDeviceViewController or ViewMyNetwork
             ***/
            //handle parent controller animation
            //CMAIOS-2311
            if self.delegate is ViewProfileWithDeviceViewController {
                self.delegate?.dismissAnimatedVC?(with: self.deviceDetails!.deviceImage_White, isDeviceInfoUpdated: self.isDeviceInfoUpdated)
            } else {
                self.delegate?.animatedVCGettingDismissed(with: self.deviceDetails!.deviceImage_White)
            }
            
            //dismiss without animation
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func btnPauseInternetTapped(_ sender: Any) {
        if !isDevicePaused {
//            self.topView.isHidden = false
//            self.topView.alpha = 0.4
//            self.pauseDurationView.isHidden = false
//            self.topView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
//            UIView.animate(withDuration: 0.5)  {
//                self.pauseDurationView.alpha = 1.0
//                self.internetDurationHeightConstraint.constant = 120
//                self.view.layoutIfNeeded()
//                self.pauseDurationView.layer.cornerRadius = 10
//                self.pauseDurationView.layer.shadowColor = UIColor.gray.cgColor
//                self.pauseDurationView.layer.shadowOpacity = 0.5
//                self.pauseDurationView.layer.shadowRadius = 5
//                self.saperatorView.layer.shadowColor = UIColor.gray.cgColor
//                self.saperatorView.layer.shadowOpacity = 0.5
//                self.saperatorView.layer.shadowRadius = 5
//            }
            self.setUIForPausedState()
            self.triggerPauseDevice(pauseEnabled: true)
        }
        else {
            self.setUIForUnpausedState()
            self.triggerPauseDevice(pauseEnabled: false)
        }
    }
    func updateUIAsPerDeviceStatus(){
            if ProfileManager.shared.isDeviceMacPaused(mac: self.deviceDetails?.macAddress ?? ""){
                setUIForPausedState()
            } else {
                setUIForUnpausedState()
            }
        }
        
        func setUIForUnpausedState(){
            self.showBackgroundColor()
            pauseBtnBGView.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
            self.btnPauseBGView.backgroundColor = .white
            self.pauseBtnBGView.backgroundColor = .white
            self.palyPauseStatusLabel.font = UIFont(name: "Regular-SemiBold", size: 18)
            self.palyPauseStatusLabel.text = "Pause Internet for this device"
            self.palyPauseStatusLabel.textColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
            self.pauseBtnBG.backgroundColor = UIColor.init(red: 246/255, green: 102/255, blue: 8/255, alpha: 1)
            self.playPauseImgWidthConstraint.constant = 40
            self.playPauseImgHeightConstraint.constant = 40
            self.playPauseImgCenterConstraint.constant = self.playPauseImgWidthConstraint.constant/2 - 20
            self.playPauseIconImg.image = UIImage(named: "play_icon.png")
            self.isDevicePaused = false
        }
    //  dropdown set hidden
//    @IBAction func pauseInternetForHourBtnTapped(_ sender: UIButton) {
//        self.isPauseUnpause = false
//        self.topView.isHidden = true
//        self.pauseDurationView.isHidden = true
//        self.internetDurationHeightConstraint.constant = 0
//        self.pauseDurationView.alpha = 0.0
//        self.pauseBtnBGView.backgroundColor = UIColor.init(red: 246/255, green: 102/255, blue: 8/255, alpha: 1)
//        self.pauseBtnBGView.layer.borderColor = UIColor.init(red: 246/255, green: 102/255, blue: 8/255, alpha: 1).cgColor
//        self.palyPauseStatusLabel.font = UIFont(name: "Regular-Bold", size: 18)
//        self.palyPauseStatusLabel.text = "Unpause Internet for this device"
//        self.palyPauseStatusLabel.textColor = .white
//        self.pauseBtnBG.backgroundColor = .white
//        self.playPauseImgWidthConstraint.constant = 20
//        self.playPauseImgHeightConstraint.constant = 20
//        self.playPauseImgCenterConstraint.constant = self.playPauseImgWidthConstraint.constant/2 - 8
//        self.playPauseIconImg.image = UIImage(named: "pause_icon.png")
//        self.view.backgroundColor = pauseBgColor
//        self.statusIndicatorImgView.image = UIImage(named: "offlinestatus1x.png")
//        if sender.tag == 1{
//            let formatter = DateFormatter()
//            formatter.dateFormat = "hh:mm a"
//            let hourString = formatter.string(from: Date() + 3600)
//            self.lblStatus.text = "Paused until " + hourString
//            //Pause API call
//            self.triggerPauseDevice(pauseEnabled: true)
//        } else {
//            self.lblStatus.text = "Paused until 6 am tomorrow"
//            //Create end time for 6:00 AM tomorrow
//            let day = Calendar.current.component(.day, from: Date(timeIntervalSinceNow: 86400))
//            let month = Calendar.current.component(.month, from: Date(timeIntervalSinceNow: 86400))
//            let year = Calendar.current.component(.year, from: Date(timeIntervalSinceNow: 86400))
//            let calendar = Calendar.current
//            let components = DateComponents(year: year, month: month, day: day, hour: 6, minute: 0, second: 0)
//            let endDate = calendar.date(from: components)!
//            //Pause API call
//            self.triggerPauseDevice(pauseEnabled: true)
//        }
//    }
    
    func triggerPauseDevice(pauseEnabled: Bool) {
//        guard let rules = ProfileManager.shared.createRestrictionRulesForDevice(enabled: true, startTime: Date(), endTime: endTime) else {
//            return
//        }
//        guard let params = ProfileManager.shared.schedulePauseForDevice(macAddresses: [self.deviceDetails?.macAddress ?? ""], rules: rules) else {
//            return
//        }
        var type = APIRequests.PausedBy.client
        
        let profileId = DeviceManager.shared.getPIDForMac(mac: self.deviceDetails?.macAddress ?? "")
        if profileId > 0 {
            type = APIRequests.PausedBy.clientWithPid
        }
        APIRequests.shared.initiatePutAccessProfileRequest(pid: profileId, macID: self.deviceDetails?.macAddress, enablePause: pauseEnabled, pausedBy: type) { success, response, error in
            if success {
                Logger.info("Put Access Profile success")
                ProfileManager.shared.getPausedDevices()
               } else if response == nil && error != nil {
                self.presentErrorMessageVC(isPauseEnabled: pauseEnabled)
            }
        }
    }
    
    func presentErrorMessageVC(isPauseEnabled: Bool) {
        self.isRedirected = true
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
            vc.isComingFromProfileCreationScreen = false
            vc.modalPresentationStyle = .fullScreen
            if isPauseEnabled{
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_pause_internet_failure)
            } else {
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_unpause_internet_failure)
            }
            self.present(vc, animated: true)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view == self.topView
        {
            self.topView.isHidden = true
            self.pauseDurationView.isHidden = true
            self.isDevicePaused = true
            self.internetDurationHeightConstraint.constant = 0
        }
    }
    
    func refreshPausedDevices() {
        APIRequests.shared.initiateGetAccessProfileByClientRequest { success, response, error in
            if success {
                MyWifiManager.shared.pausedClientData = response
                DispatchQueue.main.async {
                    self.updateUIAsPerDeviceStatus()
                }
            } else {
                Logger.info("Get Access Profile API failure")
            }
        }
    }
    
    }
    
//MARK: UITableView Delegate/DataSource
extension ConnectedDeviceDetailVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.deviceDetailTblVw.dequeueReusableCell(withIdentifier: "ConnectedDeviceDetailCell") as? ConnectedDeviceDetailCell{
            cell.lblDeviceDetail.text = arrDetails[indexPath.row].title
            cell.lblDeviceInfo.text = arrDetails[indexPath.row].value
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDetails.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34.0
    }
}

extension ConnectedDeviceDetailVC : UpdatedDeviceDetailsData {
    
    func getUpdatedDeviceDetails(deviceName:String, deviceType:String){
        self.deviceName = deviceName
        self.deviceType = deviceType
    }
}

extension ConnectedDeviceDetailVC : UpdatedDeviceProfileAssignment {
    
    func getUpdatedProfileAssigmentDetails(profileName:String?, profilePid:Int?){
        isProfileAssigmentChanged = true
        self.updatedProfilePid = profilePid ?? 0
        self.updatedProfileName = profileName ?? ""
    }
}

extension ConnectedDeviceDetailVC : HandlingPopUpAnimation{
    func animatedVCGettingDismissed(with image: UIImage) {
        let bgAnimationView = self.view.viewWithTag(1000)
        self.animateDeviceIconFromBottomTopToForEditDevice(image: image) { isAnimationCompleted in
            UIView.animate(withDuration: 0.5) {
                bgAnimationView?.alpha = 0.0
                self.setAlphaForUIElements(alpha: 1.0)
            } completion: { _ in
                bgAnimationView?.removeFromSuperview()
            }
        }
    }
}
