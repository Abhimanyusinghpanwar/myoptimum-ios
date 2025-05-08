//
//  DisconnectedDevicesViewController.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 10/12/22.
//

import UIKit
import Lottie
class DisconnectedDevicesViewController: UIViewController {
    let cellDisconnectedDeviceList         = "DisconnectedDevices"
    let cellSectionHeader               = "SectionHeaderTableViewCell"
    @IBOutlet weak var disconnectedDevicesListTableview: UITableView!
    // Pull To Refresh properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet weak var vwTopConstraint: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    //
    var tableArray = [String]()
    var arrDevices:[String:[RecentlyDisconnected]] = [:]
    var arrWithoutTime:[RecentlyDisconnected] = []
    var arrWithTime:[RecentlyDisconnected] = []
    var arrDeviceSections:[String] = []
    let cellRecentlyButton              = "RecentlyButtonTableViewCell"
    @IBOutlet weak var closeIconYConstraint: NSLayoutConstraint!
    var qualtricsAction :DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.disconnectedDevicesListTableview.dataSource = self
        self.disconnectedDevicesListTableview.delegate = self
//        tableArray = ["LQM5678UHGytN","Maria’s iPhone","Amazon Fire TV"]
        disconnectedDevicesListTableview.register(UINib.init(nibName: "DisconnectedDevicesListTableViewCell", bundle: nil), forCellReuseIdentifier: cellDisconnectedDeviceList)
        disconnectedDevicesListTableview.register(UINib.init(nibName: "SectionHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: cellSectionHeader)
        disconnectedDevicesListTableview.register(UINib.init(nibName: cellRecentlyButton, bundle: nil), forCellReuseIdentifier: cellRecentlyButton)
        //Handle Pull To Refresh animation
        initialUIConstantsForPullToRefresh()
        initiatePullToRefresh()
        if UIDevice.current.hasNotch {
            self.vwTopConstraint.constant = 20
            self.closeIconYConstraint.constant = 9
        } else {
            self.vwTopConstraint.constant = 24
            self.closeIconYConstraint.constant = -11
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.populateDisconnectedDevices(forMAC: "")
        self.disconnectedDevicesListTableview.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.qualtricsAction = self.checkQualtrics(screenName: WiFiManagementScreenDetails.WIFI_RECENTLY_DISCONNECTED_DEVICES.rawValue, dispatchBlock: &qualtricsAction)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_RECENTLY_DISCONNECTED_DEVICES.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
    }
    
    @objc func lightSpeedAPICallBack() {
        self.pullToRefresh(hideScreen: true, isComplete: true)
        MyWifiManager.shared.refreshLTDataRequired = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.populateDisconnectedDevices(forMAC: "")
        self.disconnectedDevicesListTableview.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.qualtricsAction?.cancel()
    }

    @IBAction func crossBtnTapped(_ sender: Any) {
        qualtricsAction?.cancel()
        self.dismiss(animated: true)
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
        self.view.isUserInteractionEnabled = hide
        if !hide {
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
                    self.vwPullToRefresh.isHidden = true
                    self.vwPullToRefreshCircle.isHidden = true
                    self.vwPullToRefreshTop.constant = -80
                    self.vwPullToRefreshHeight.constant = 0
                    self.handleScreenUI()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
         MyWifiManager.shared.triggerOperationalStatus()
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
        //
    func populateDisconnectedDevices(forMAC macid:String) {
        //Reset collections
        arrDevices.removeAll()
        arrDeviceSections.removeAll()
        var sections:[String] = []
        var sectionsForProfile:[Int] = []
        var sectionsForCategory:[String] = []
        var devicesResponse:[LightSpeedAPIResponse.rec_disconn] = []
        devicesResponse = MyWifiManager.shared.getRecentlyDisconnected()
        if devicesResponse.isEmpty {
            arrDeviceSections = []
            arrDevices = [:]
            return
        }
        
        var lightNodes:[LightSpeedAPIResponse.Nodes] = []
        lightNodes = MyWifiManager.shared.getAllLightApiNodes()
        
        var devices = devicesResponse.map{device -> RecentlyDisconnected in
            var name = "Unknown"
            var image_white =  UIImage(named: "unknown_white_static")
            var image_gray =  UIImage(named: "unknown_gray_static")
            var section = "Others"
            let vendor = DeviceManager.shared.getVendorForMac(mac: device.mac ?? "")
            //Display Name
            if let friendlyName = device.friendly_name, !friendlyName.isEmpty {
                name = friendlyName
            } else if let hostname = device.hostname, !hostname.isEmpty, hostname != device.mac {
                name = hostname
            } else if let cmaDisName = device.cma_display_name, !cmaDisName.isEmpty {
                name = cmaDisName
            } else {
                name = "Unnamed device"
            }
            if var imageName = device.cma_dev_type, !imageName.isEmpty {
                if imageName.caseInsensitiveCompare("unknown") == .orderedSame {
                    imageName = "unknown_device"
                }
                image_white = DeviceManager.IconType.white.getDeviceImage(name: imageName)
                image_gray = DeviceManager.IconType.gray.getDeviceImage(name: imageName)
            }
            else if var imageName = device.cma_display_name, !imageName.isEmpty {
                if imageName.caseInsensitiveCompare("unknown") == .orderedSame {
                    imageName = "unknown_device"
                }
                image_white = DeviceManager.IconType.white.getDeviceImage(name: imageName)
                image_gray = DeviceManager.IconType.gray.getDeviceImage(name: imageName)
            } else {
                image_white = DeviceManager.IconType.white.getDeviceImage(name: "unknown_device")
                image_gray = DeviceManager.IconType.gray.getDeviceImage(name: "unknown_device")
            }
            
            // Disconnected Time
            let dateString = WifiConfigValues.getDisconnectedTimeString(timestamp: Double(device.rtime ?? 0))
            var disConnectDate: Date? =  nil
            disConnectDate = WifiConfigValues.getDisconnectedDateFromString(disconnectDate: device.rec_disconn_time ?? "")
            if (device.rec_disconn_time ?? "").isEmpty && device.rtime != nil {
                disConnectDate = WifiConfigValues.getDisconnectedTime(timestamp: Double(device.rtime ?? 0))
            }
            
            // Profile / category
            if MyWifiManager.shared.isSmartWifi(), let profile = device.profile, !profile.isEmpty {
                if let pid = device.pid {
                    sectionsForProfile.append(pid)
                }
                section = profile
            } else if let category = device.cma_category, !category.isEmpty {
                section = category.firstCapitalized
                sectionsForCategory.append(category.lowercased())
            }
            var deviceType = device.cma_dev_type ?? ""
            if deviceType.isEmpty {
                let newnode = lightNodes.filter { $0.mac?.isMatching(device.mac ?? "") == true }.first
                deviceType = newnode?.cma_dev_type ?? ""
            }
            
            sections.append(section)
            return RecentlyDisconnected(deviceName: name, dateString: dateString, deviceIcon_white: image_white!, deviceIcon_gray:image_gray!, deviceCategory: section, connectionType: "", deviceType: deviceType, profile: device.profile ?? "", mac: device.mac ?? "", vendor: vendor ?? "", lanIP: device.ip ?? "", band: "", pid: device.pid ?? 0, disConnectDate: disConnectDate)
        }

        if !sectionsForProfile.isEmpty {
            var profiles = [ProfileModel]()
            var sortedProfile = [String]()
            for pid in sectionsForProfile {
                if let profile = ProfileModelHelper.shared.profiles?.filter({$0.pid == pid}), !profile.isEmpty {
                    profiles.append(profile[0])
                }
            }
            if profiles.count == 1 {
                sortedProfile.append(profiles[0].profileName)
                sections = sortedProfile + sectionsForCategory
            } else {
                let sortedArray = profiles.sorted { $0.profile!.pid ?? 0 < $1.profile!.pid ?? 0 }
                sortedProfile = sortedArray.compactMap{$0.profileName}
                sections = sortedProfile + sectionsForCategory
            }
        } else {
            sections = sectionsForCategory
        }
        
        // Sort the devices by disconnect device time and alphabet,number and symbol
        arrWithTime = devices.filter { $0.disConnectDate != nil }
        arrWithTime = arrWithTime.sorted(by: { $0.disConnectDate?.compare($1.disConnectDate!) == .orderedDescending })
        arrWithoutTime = devices.filter{ $0.disConnectDate == nil }
        arrWithoutTime = !arrWithoutTime.isEmpty ? sortDevicesToAlphabet(devices: arrWithoutTime) : arrWithoutTime
        devices = arrWithTime + arrWithoutTime
        self.arrDeviceSections = NSMutableOrderedSet(array: sections).array as! [String]
        let defaultCategories = ["personal and computer", "gaming", "entertainment", "home", "security", "other"]
        let categorySections = defaultCategories.filter{arrDeviceSections.contains($0)} //sections with categories
        if let profileSections = arrDeviceSections.filter({!defaultCategories.contains($0)}) as [String]?, !profileSections.isEmpty {
            arrDeviceSections = profileSections + categorySections
        } else {
            arrDeviceSections = categorySections
        }
        for key in arrDeviceSections {
            let deviceList = devices.filter({ $0.deviceCategory.lowercased() == key.lowercased()})
            arrDevices[key] = deviceList
        }
    }
    
    func sortDevicesToAlphabet(devices: [RecentlyDisconnected]) -> [RecentlyDisconnected] {
        var sortedDevices = [RecentlyDisconnected] ()
        
        let alphabetSorting = (devices.filter{$0.deviceName.first!.isLetter}).sorted {$0.deviceName.localizedStandardCompare($1.deviceName) == ComparisonResult.orderedAscending}
        
        let numberSorting = devices.filter{$0.deviceName.first!.isNumber}.sorted {$0.deviceName.localizedStandardCompare($1.deviceName) == ComparisonResult.orderedAscending}
        
        let symbolSorting = devices.filter{!($0.deviceName.first!.isLetter) && !($0.deviceName.first!.isNumber)}.sorted {$0.deviceName.localizedStandardCompare($1.deviceName) == ComparisonResult.orderedAscending}
        
        sortedDevices = alphabetSorting + numberSorting + symbolSorting
        return sortedDevices
    }
    //MARK: - Navigation Methods
    func navigateToDeviceDetails(deviceDetails:RecentlyDisconnected) {
        let device = ConnectedDevice (title: deviceDetails.deviceName, deviceImage_Gray: UIImage(named: "unknown_white_static")!, deviceImage_White: deviceDetails.deviceIcon_white, colorName: "red", device_type: deviceDetails.deviceType , conn_type: deviceDetails.connectionType, vendor: deviceDetails.vendor, macAddress: WifiConfigValues.getFormattedMACAddress(deviceDetails.mac), ipAddress: deviceDetails.lanIP, profileName: deviceDetails.profile, band: deviceDetails.band, sectionTitle: "", pid: deviceDetails.pid)
        if let viewController = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(withIdentifier: "ConnectedDeviceDetailVC") as? ConnectedDeviceDetailVC {
            viewController.modalPresentationStyle = .fullScreen
            viewController.isForRecentlyDisconnected = true
            viewController.deviceDetails = device
            self.present(viewController, animated: false)
        }
    }
    
    @objc func letUsHelpBtnTapped() {
        qualtricsAction?.cancel()
        let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "OneDeviceSlowViewController") as OneDeviceSlowViewController
        vc.isComingFromLetUsHelp = true
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
    }
}
// Mark: - Tableview Datasource and Delegate
 
extension DisconnectedDevicesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == arrDeviceSections.count {
            return 1
        }
        let key = arrDeviceSections[section]
        let list = arrDevices[key]
        return list?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        arrDeviceSections.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == arrDeviceSections.count {
            let cell = self.disconnectedDevicesListTableview.dequeueReusableCell(withIdentifier: cellRecentlyButton) as! RecentlyButtonTableViewCell
            cell.letusHelpBtn.addTarget(self, action: #selector(letUsHelpBtnTapped), for: .touchUpInside)
            cell.recentlyButton.isHidden = true
            cell.topConstraint.constant = 10
            if arrDeviceSections.isEmpty {
                cell.vwTopLineToLabel.isHidden = true
                cell.labelToLineConstraint.constant = 0
            } else {
                cell.labelToLineConstraint.constant = 25
                cell.vwTopLineToLabel.isHidden = false
            }
            return cell
        }
        let cell = self.disconnectedDevicesListTableview.dequeueReusableCell(withIdentifier: cellDisconnectedDeviceList) as! DisconnectedDevicesListTableViewCell
        
        let key = arrDeviceSections[indexPath.section]
        let list = arrDevices[key]
        let device = list?[indexPath.row]
        cell.deviceNameLabel.text = device?.deviceName
        cell.iconView.image = device?.deviceIcon_gray
       if let date = device?.dateString, date.isEmpty || (MyWifiManager.shared.isLegacyManagedRouter() ) {
                cell.dateLabel.isHidden = true
                cell.dateLabel.text = ""
            } else {
                cell.dateLabel.isHidden = false
                cell.dateLabel.text = device?.dateString
            }
        cell.selectionStyle = .none

//        if indexPath.row == list!.count - 1
//        {
//            cell.drawDottedLine(start: CGPoint(x: cell.bottomview.bounds.minX - 60, y: cell.bottomview.bounds.minY), end: CGPoint(x: cell.bottomview.bounds.maxX + 30, y: cell.bottomview.bounds.maxY), view: cell.bottomview)
//        }
//        else
//        {
//            cell.drawDottedLine(start: CGPoint(x: cell.bottomview.bounds.minX, y: cell.bottomview.bounds.minY), end: CGPoint(x: cell.bottomview.bounds.maxX, y: cell.bottomview.bounds.maxY), view: cell.bottomview)
//        }
          if indexPath.row == list!.count - 1 {
              cell.bottomview.isHidden = true
              cell.bottomViewTopConstraint.constant = 0
          } else {
              cell.bottomview.isHidden = false
              cell.bottomViewTopConstraint.constant = 20
          }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == arrDeviceSections.count {
            return 100
        } else {
            let key = arrDeviceSections[indexPath.section]
            let list = arrDevices[key]
            if indexPath.row == list!.count - 1 {
                return currentScreenWidth >= 393 || (MyWifiManager.shared.isLegacyManagedRouter()) ? 64 : 76
            } else {
                return currentScreenWidth >= 393 || (MyWifiManager.shared.isLegacyManagedRouter()) ? 80 : 95
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == arrDeviceSections.count {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            return view
        }
        guard let contentView =  Bundle.main.loadNibNamed("SectionHeaderTableViewCell", owner: nil, options: nil) else {
                    return nil
                }
        if let view = contentView.first as? SectionHeaderTableViewCell {
            let string = arrDeviceSections[section]
            if !string.isEmpty {
                if string == "personal and computer" {
                    view.lblTitle.text = "Personal and Computer" //For casing issues
                } else {
                    view.lblTitle.text = string.firstCapitalized
                }
            } else {
                view.lblTitle.text = ""
            }
        }
        return contentView.first as? UIView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < arrDeviceSections.count - 1 {
            guard let contentView =  Bundle.main.loadNibNamed("LineSeparationTableViewCell", owner: nil, options: nil) else {
                return nil
            }
            return contentView.first as? UIView
        }
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == arrDeviceSections.count {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == arrDeviceSections.count - 1 || section == arrDeviceSections.count {
            return 0
        } else {
            return 26
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != arrDeviceSections.count {
            qualtricsAction?.cancel()
            let key = arrDeviceSections[indexPath.section]
            let list = arrDevices[key]
            if let device = list?[indexPath.row] {
                navigateToDeviceDetails(deviceDetails: device)
            }
        }
    }
}
