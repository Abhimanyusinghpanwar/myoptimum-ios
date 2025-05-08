//
//  NetworkDetailsVC.swift
//  CustSupportApp
//
//  Created by vishali Test on 22/04/24.
//

import UIKit
import Lottie

class NetworkDetailsVC: UIViewController{
    
    
    lazy var selectedNodeType: SelectedNodeType = .None
    lazy var recentlyDisconnectedCount = {
        MyWifiManager.shared.getRecentlyDisconnected().count
    }()
    lazy var arrNodeDetails:[DeviceDetail] = []
    lazy var editTapped:Bool = false
    
    var arrDevices:[String:[ConnectedDevice]] = [:]
    var arrDeviceSections:[String] = []
    var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
    var isPullToRefresh: Bool = false
    //Table View Outlet Connections
    @IBOutlet weak var networkDeviceDetailsTblVw: UITableView!
    //Button Outlet Connections
    @IBOutlet weak var vwClossBtn: UIButton!
    @IBOutlet weak var vwTopBackground: UIView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwCloseContainer: UIView!
    //Constraint Outlet Connections
    @IBOutlet weak var vwClossBtnBottom: NSLayoutConstraint!
    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    var qualtricsAction : DispatchWorkItem?
    var themeColor: UIColor?
    var refreshControl: UIRefreshControl!
    var emptyCellHeight = 0
    var numberOfDevices = 0
    var lastSectionIndex = 2
    
    //TableView Cell Identifiers
    let cellWiFiStatus                  = "MyWifiDetailsTableViewCell"
    let cellConnectedDevice             = "ConnectedDevicesTitleTableViewCell"
    let cellSectionHeader               = "SectionHeaderTableViewCell"
    let cellConnectedDeviceList         = "ConnectedDevicesListTableViewCell"
    let cellRecentlyButton              = "RecentlyButtonTableViewCell"
    let emptyCell                       = "EmptyCell"
    let equipmentDetailRow      = "EquipmentDetailRow"
    let extenderDetailCell      = "ExtenderDetailCell"
    
    //Constants
    let EMPTY_CELL_HEIGHT_CONSTANT = Int((400/xibDesignHeight)*currentScreenHeight)
    
    lazy var selectedExtenderDetail : Extender? = nil{
        didSet {
            if let deviceType = selectedExtenderDetail?.device_type, !deviceType.isEmpty {
                arrNodeDetails.append(DeviceDetail(title: "Equipment Type", value: deviceType.firstCapitalized))
            }
            if let connType = selectedExtenderDetail?.conn_type, !connType.isEmpty {
                if connType.caseInsensitiveCompare("Wifi") == .orderedSame {
                    arrNodeDetails.append(DeviceDetail(title: "Connection Type", value: "Wireless"))
                } else {
                    arrNodeDetails.append(DeviceDetail(title: "Connection Type", value: connType.firstCapitalized))
                }
            }
            if let macAddress = selectedExtenderDetail?.macAddress, !macAddress.isEmpty {
                arrNodeDetails.append(DeviceDetail(title: "MAC Address", value: WifiConfigValues.getFormattedMACAddress(macAddress)))
            }
            if let iPAddress = selectedExtenderDetail?.ipAddress, !iPAddress.isEmpty {
                arrNodeDetails.append(DeviceDetail(title: "LAN IP Address", value: iPAddress))
            }
            var strFrequency = ""
            if let deviceType = selectedExtenderDetail?.device_type, !deviceType.isEmpty, deviceType.uppercased().contains("6E") { // CMAIOS-2022-added band based on device type.
                strFrequency = "2.4, 5 and 6 GHz"
            } else {
                strFrequency = "2.4 and 5 GHz"
            }
            arrNodeDetails.append(DeviceDetail(title: "Frequency Band", value: strFrequency))
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialise UI constants to perform animation
        self.initialUIConstants()
        //register all cells
        tblViewCellRegister()
        //populate table view as per node type(Extender/gateway)
        self.initialDataSetup()
        //set theme and cross button UI
        self.setUIAttributes()
        //handle pullToRefresh using SwipeGesture
        handlePullToRefreshUsingSwipe()
        // Do any additional setup after loading the view.
    }
    
    func handlePullToRefreshUsingSwipe(){
        //Add Swipe down gesture only if there are no connected devices
        if numberOfDevices == 0  {
            self.networkDeviceDetailsTblVw.addSwipeGesture(gesture: &swipeDownGestureRecognizer, controller: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //track GA events and show qulatrics PopUp
        trackGAEventAndAddQualtrics()
        self.editTapped = false
        //To get rename update for Gateway/Extender
        if MyWifiManager.shared.refreshLTDataRequired {
            self.refreshAfterLTCall()
        }
        //perform UI animation to get the main screen with data population
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAnimationOnLaunch()
        }
    
        //add LT observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
    }
    
    func trackGAEventAndAddQualtrics(){
        //add GA tag as per node type and Qualtrics popUp
        switch self.selectedNodeType {
        case .Gateway:
            self.trackEventForGatewayDetails()
        case .Extender:
            self.trackEventForExtenderDetails()
        case .None:
            break
        }
    }
    
    func tblViewCellRegister() {
        networkDeviceDetailsTblVw.register(UINib.init(nibName: cellWiFiStatus, bundle: nil), forCellReuseIdentifier: cellWiFiStatus)
        networkDeviceDetailsTblVw.register(UINib.init(nibName: cellConnectedDevice, bundle: nil), forCellReuseIdentifier: cellConnectedDevice)
        networkDeviceDetailsTblVw.register(UINib.init(nibName: cellSectionHeader, bundle: nil), forCellReuseIdentifier: cellSectionHeader)
        networkDeviceDetailsTblVw.register(UINib.init(nibName: cellConnectedDeviceList, bundle: nil), forCellReuseIdentifier: cellConnectedDeviceList)
        networkDeviceDetailsTblVw.register(UINib.init(nibName: cellRecentlyButton, bundle: nil), forCellReuseIdentifier: cellRecentlyButton)
        networkDeviceDetailsTblVw.register(UINib.init(nibName: equipmentDetailRow, bundle: nil), forCellReuseIdentifier: equipmentDetailRow)
        networkDeviceDetailsTblVw.register(EmptyCell.self, forCellReuseIdentifier: emptyCell)
        networkDeviceDetailsTblVw.register(UINib.init(nibName: extenderDetailCell, bundle: nil), forCellReuseIdentifier: extenderDetailCell)
        
        if #available(iOS 15.0, *) {
            networkDeviceDetailsTblVw.sectionHeaderTopPadding = 0
        }
    }
    
    func addQualtrics(screenName:String){
        qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    func trackEventForGatewayDetails() {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_NETWORKPOINT_DETAILS_GATEWAY.rawValue,
                                                                   CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                   CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue,
                                                                    EVENT_SCREEN_CLASS:self.classNameFromInstance])
        self.addQualtrics(screenName: WiFiManagementScreenDetails.WIFI_NETWORKPOINT_DETAILS_GATEWAY.rawValue)
    }
    
    func trackEventForExtenderDetails(){
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_NETWORKPOINT_DETAILS_EXTENDER.rawValue,
                                                                   CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                   CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue,
                                                                    EVENT_SCREEN_CLASS:self.classNameFromInstance])
        self.addQualtrics(screenName: WiFiManagementScreenDetails.WIFI_NETWORKPOINT_DETAILS_EXTENDER.rawValue)
    }
    
    func initialDataSetup() {
        var macAddress = ""
        //check node type and populate data using node MAC address
        switch self.selectedNodeType {
        case .Gateway:
            let allGatewayDetails = MyWifiManager.shared.getMasterGatewayDetails()
            macAddress = allGatewayDetails.gatewayFormattedMac
            self.arrNodeDetails = allGatewayDetails.gatewayDetails
            if let bgColor = MyWifiManager.shared.getMasterGatewayDetails().bgColor {
                themeColor = bgColor
            } else {
                themeColor = energyBlueRGB
            }
        case .Extender:
            macAddress = self.selectedExtenderDetail?.macAddress ?? ""
            guard let color = selectedExtenderDetail?.getThemeColor() else { return }
            //CMAIOS-2100 set current bg color as per offline/Online/Weak status
            themeColor = color
        default:
            Logger.info("")
        }
        self.populateNetworkDeviceDetails(forMAC: macAddress)
    }
    
    func setUIAttributes() {
        self.view.backgroundColor = themeColor
        self.vwTopBackground.backgroundColor = themeColor
        //do not add shadow to close container for offline extender
        //CMAIOS-2355 Show shadow for weak/ Online extnder if there are any connected devices
        if themeColor == energyBlueRGB || (themeColor == midnightBlueRGB && numberOfDevices > 0){
            self.vwCloseContainer.layer.shadowColor = UIColor.gray.cgColor
            self.vwCloseContainer.layer.shadowOpacity = 0.5
            self.vwCloseContainer.layer.shadowRadius = 5
        }
        //CMAIOS-2355 Show close button UI as per extender status and number of connected devices
        self.setCloseButtonColor()
    }
    
    func showAnimationOnLaunch(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animateCloseBtnViewTop()
        }
        if self.recentlyDisconnectedCount > 0 || self.numberOfDevices > 0 {
            self.pullDeviceListUp()
        }
    }
    
    func performAnimationOnClickOfCloseBtn(){
        UIView.animate(withDuration: 0.4) {
            if self.recentlyDisconnectedCount > 0 || self.numberOfDevices > 0 {
                self.pushDeviceListDown()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.animateCloseBtnViewDown()
                }
            } else {
                self.animateCloseBtnViewDown()
            }
        }
    }
    
    func animateCloseBtnViewTop(){
        UIView.animate(withDuration: 0.5) {
            self.vwClossBtnBottom.constant = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            //To enable the user interaction
            self.isPullToRefresh = false
        }
    }
    
    func animateCloseBtnViewDown(){
        UIView.animate(withDuration: 0.3) {
            self.vwClossBtnBottom.constant = -100
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !self.editTapped {
                self.dismiss(animated: false, completion: nil)
            } else {
                self.loadNetworkPointNameScreen()
            }
        }
    }
    
    func setCloseButtonColor(){
        //CMAIOS-2355 Added check for weak extender
        if themeColor == midnightBlueRGB && numberOfDevices == 0  {
            self.vwClossBtn.backgroundColor = midnightBlueRGB
            self.vwCloseContainer.layer.shadowColor = UIColor.clear.cgColor
            self.vwClossBtn.setImage(UIImage(named: "icon_close_white"), for: .normal)
        } else {
            self.vwClossBtn.backgroundColor = .clear
            self.vwCloseContainer.layer.shadowColor = UIColor.gray.cgColor
            self.vwClossBtn.setImage(UIImage(named: "closeImage"), for: .normal)
        }
    }
    
    func pullDeviceListUp() {
        if self.numberOfDevices > 0 || self.recentlyDisconnectedCount > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.networkDeviceDetailsTblVw.beginUpdates()
                self.emptyCellHeight = 0
                self.networkDeviceDetailsTblVw.endUpdates()
            }
            self.networkDeviceDetailsTblVw.isScrollEnabled = true
           // self.networkDeviceDetailsTblVw.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        }
    }
    
    func pushDeviceListDown() {
        self.networkDeviceDetailsTblVw.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        self.networkDeviceDetailsTblVw.isScrollEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.networkDeviceDetailsTblVw.beginUpdates()
            self.emptyCellHeight = self.EMPTY_CELL_HEIGHT_CONSTANT
            self.networkDeviceDetailsTblVw.endUpdates()
        }
    }
    
    
    //MARK: Animation Methods
    func initialUIConstants() {
        //set the emptyCellHeight value to perform drawer animation
        emptyCellHeight = EMPTY_CELL_HEIGHT_CONSTANT
        //add refresh control to tableView for PullToRefresh feature
        initiatePullToRefreshControl()
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
        //set the bottom constraint value to perform cross button animation
        self.vwClossBtnBottom.constant = -100
    }
    
    ///Method for pull to refresh using Refresh Control
    func initiatePullToRefreshControl() {
        //add refresh control to tableView for pullToRefresh
        refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        networkDeviceDetailsTblVw.backgroundView = refreshControl
    }
        
    func getNetworkDeviceRowHeight() -> CGFloat{
        var rowHeight = 0.0
        switch self.selectedNodeType {
        case .Gateway:
            switch UIDevice.current.hasNotch{
            case true:
                rowHeight = 245
            case false:
                rowHeight = 225
            }
        case .Extender:
            if themeColor != midnightBlueRGB {
                rowHeight = 166
            } else {
                rowHeight = 214
            }
        case .None:
            rowHeight = 0.0
        }
        return rowHeight
    }
    
    @objc func handleSwipeGesture(gesture : UISwipeGestureRecognizer){
        self.networkDeviceDetailsTblVw.isScrollEnabled = true
        self.refreshControl.refreshManually()
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
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
                self.networkDeviceDetailsTblVw.allowsSelection = false
                self.vwPullToRefreshCircle.backgroundColor = .white
                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.isHidden = false
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.networkDeviceDetailsTblVw.isUserInteractionEnabled = false
                self.vwClossBtn.isUserInteractionEnabled = true
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                UIView.animate(withDuration: 0.5) {
                    self.networkDeviceDetailsTblVw.allowsSelection = hide
                    self.vwPullToRefresh.isHidden = hide
                    self.vwPullToRefreshCircle.isHidden = hide
                    self.vwPullToRefreshAnimation.isHidden = hide
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshTop.constant = 80
                    self.vwPullToRefreshHeight.constant = 0
                    self.networkDeviceDetailsTblVw.isUserInteractionEnabled = true
                    self.vwClossBtn.isUserInteractionEnabled = true
                    self.refreshControl.endRefreshing()
                    if self.numberOfDevices == 0 {
                        self.refreshControl.resetManualPullFrameChanges()
                    }
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.isPullToRefresh = false
                }
            }
        }
    }
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        // After Refresh
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        MyWifiManager.shared.triggerOperationalStatus()
    }
    
    @objc func lightSpeedAPICallBack() {
        self.refreshAfterLTCall()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
    }
    
    func refreshAfterLTCall() {
        if MyWifiManager.shared.getMyWifiStatus() == .wifiDown {
            self.closeTapAction(UIButton())
            return
        }
        recentlyDisconnectedCount =  MyWifiManager.shared.getRecentlyDisconnected().count
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pullToRefresh(hideScreen: true, isComplete: true)
                self.arrNodeDetails.removeAll()
                self.updateNodeDetails()
                self.initialDataSetup()
                UIView.performWithoutAnimation {
                    self.networkDeviceDetailsTblVw.reloadData()
                }
        }
    }
    
    func updateNodeDetails(){
        switch self.selectedNodeType {
        case .Gateway:
            if let cell = self.networkDeviceDetailsTblVw.cellForRow(at: IndexPath(row: 0, section: 0))  as? MyWifiDetailsTableViewCell {
                cell.updateGatewayName()
            }
        case .Extender:
            self.selectedExtenderDetail = MyWifiManager.shared.getExtenderData(macAddress: self.selectedExtenderDetail?.macAddress ?? "")
        case .None:
            break
        }
    }
    
    func populateNetworkDeviceDetails(forMAC macid:String) {
        let networkDeviceDetails = MyWifiManager.shared.populateConnectedDevices(havingMAC: macid, withSections: true)
        //CMAIOS-2100
        //dict of all connected devices with Sections
        arrDevices = networkDeviceDetails?.0 ?? [:]
        //arr of different section names/device categories
        arrDeviceSections = networkDeviceDetails?.1 ?? []
        let arrConnectedDevices = networkDeviceDetails?.2 ?? []
        numberOfDevices = arrConnectedDevices.isEmpty ? 0 : arrConnectedDevices.count
        // Backup for initial data for reset UI
        lastSectionIndex = arrDeviceSections.count + 1
        self.networkDeviceDetailsTblVw.isScrollEnabled = numberOfDevices > 0
    }
    
    //MARK: Button Actions
    @IBAction func closeTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        performAnimationOnClickOfCloseBtn()
    }
    
    //MARK: Navigation Methods
    func navigateToConnectedDeviceDetailScreen(deviceDetail:ConnectedDevice?) {
        if !self.isPullToRefresh {
            let viewController = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(identifier: "ConnectedDeviceDetailVC") as ConnectedDeviceDetailVC
            viewController.deviceDetails = deviceDetail
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
        }
    }
    
    func loadNetworkPointNameScreen() {
        //NetworkPoint
        let networkPointRename = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "NetworkPointRename") as! NetworkPointRenameViewController
        networkPointRename.modalPresentationStyle = .fullScreen
        networkPointRename.selectedNodeType = self.selectedNodeType
        switch selectedNodeType {
        case .Gateway:
            self.present(networkPointRename, animated: false, completion: nil)
        case .Extender:
            networkPointRename.extender = self.selectedExtenderDetail
            self.present(networkPointRename, animated: true, completion: nil)
        case .None:
            return
        }
    }
    
    @objc func editNodeNameBtnTapped()
    {
        if  !isPullToRefresh {
            self.qualtricsAction?.cancel()
            editTapped = true
            performAnimationOnClickOfCloseBtn()
        }
    }

    @objc func letUsHelpBtnTapped()
    {
        if  !isPullToRefresh {
            self.qualtricsAction?.cancel()
            let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "OneDeviceSlowViewController") as OneDeviceSlowViewController
            vc.isComingFromLetUsHelp = true
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    @objc func letsFixItButton(btn: UIButton) {
        if  !isPullToRefresh {
            self.qualtricsAction?.cancel()
            ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
            if let extender = self.selectedExtenderDetail {
                ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
                switch extender.status {
                case "Offline":
                    ExtenderDataManager.shared.flowType = .offlineFlow
                    ExtenderDataManager.shared.iTroubleshoot = .troubleshoot
                    navigationForExtenderTroubleshoot(identifier: "extenderOfflineViewController")
                case "Online":
                    if extender.colorName.isMatching("orange") {
                        ExtenderDataManager.shared.flowType = .weakFlow
                        ExtenderDataManager.shared.iTroubleshoot = .troubleshoot
                        navigationForExtenderTroubleshoot(identifier: "goToExtenderOfflineViewController")
                    }
                default:
                    Logger.info("No Extenders to Troubleshoot")
                }
            }
        }
    }
    
    func navigationForExtenderTroubleshoot(identifier: String) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        let navVC = UINavigationController.init(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.setNavigationBarHidden(false, animated: true)
        self.present(navVC, animated: true)
    }
    
    @objc func recentlyDisconnectedBtnTapped()
    {
        if  !isPullToRefresh {
            self.qualtricsAction?.cancel()
            let vc = UIStoryboard(name: "WiFiScreen", bundle: nil).instantiateViewController(identifier: "DisconnectedDevices") as DisconnectedDevicesViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.qualtricsAction?.cancel()
        //To avoid flickering effect
        self.isPullToRefresh = true
    }
}

extension NetworkDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrDeviceSections.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 && section != lastSectionIndex {
            if section < arrDeviceSections.count + 1 {
                if section == 1 {
                    return 68
                } else {
                    return 49
                }
            } else {
                return 0 //This is done for update cases
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == lastSectionIndex {
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 && section != lastSectionIndex {
            
            guard let contentView =  Bundle.main.loadNibNamed("SectionHeaderTableViewCell", owner: nil, options: nil) else {
                // xib not loaded, or its top view is of the wrong type
                return nil
            }
            if let view = contentView.first as? SectionHeaderTableViewCell {
                if section < arrDeviceSections.count + 1 {
                    if section == 1 {
                        view.titleTop.constant = 28
                    } else {
                        view.titleTop.constant = 12
                    }
                    let string = arrDeviceSections[section-1]
                    if string == "personal and computer" {
                        view.lblTitle.text = "Personal and Computer" //For casing issues
                    } else {
                        view.lblTitle.text = string
                    }
                } else {
                    view.lblTitle.text = ""
                }
            }
            return contentView.first as? UIView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4 + self.arrNodeDetails.count
        } else if section == lastSectionIndex {
            if numberOfDevices == 0 && recentlyDisconnectedCount == 0
            {
                return 0
            }
            return 1
        }  else {
            let key = arrDeviceSections[section-1]
            let list = arrDevices[key]
            return list?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return getNetworkDeviceRowHeight()
            } else if indexPath.row - 1 <  self.arrNodeDetails.count {
                return UITableView.automaticDimension
            } else if  indexPath.row ==  self.arrNodeDetails.count + 1 {
                switch UIDevice.current.hasNotch {
                case true:
                     return 28
                case false:
                    return 18
                }
            } else if  indexPath.row ==  self.arrNodeDetails.count + 2 {
                return CGFloat(emptyCellHeight)
            } else {
                return 61
            }
        } else if indexPath.section == lastSectionIndex {  //For Recently Disconnected
            if recentlyDisconnectedCount == 0 {
//             // To add extra white view padding (150 + requiredCellHeight(90))
                return 240
            } else {
                // To add extra white view padding (150 + requiredCellHeight(220))
                return 370
            }
        } else {
            if indexPath.section < arrDeviceSections.count + 1 {
                let key = arrDeviceSections[indexPath.section-1]
                let list = arrDevices[key]
                
                if indexPath.row == list!.count - 1 {
                    return 114
                }
                return 81
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            /// Cell to show Gateway/Extender details
            if indexPath.row == 0 {
                switch self.selectedNodeType{
                    //Create Gateway Image Cell
                case .Gateway:
                    let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: cellWiFiStatus) as! MyWifiDetailsTableViewCell
                    cell.updateGatewayName()
                    cell.editControl.isHidden = true
                    cell.editWifiViewHeightConstraint.constant = 0
                    cell.wifiViewBottomConstraint.priority = .defaultLow
                    cell.wifiViewBottomConstraintFromSuperView.priority = .required
                    cell.viewAnimation.play()
                    cell.updateGatewayName()
                    cell.btnEditGateway.isHidden = false
                    cell.btnEditGateway.addTarget(self, action: #selector(editNodeNameBtnTapped), for: .touchUpInside)
                    cell.btnEditGateway.fadeInEffectOnView(view:cell.btnEditGateway, pullToRefresh: self.isPullToRefresh)
                    return cell
                    //Create Extender Image Cell
                case .Extender:
                    let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: extenderDetailCell) as! ExtenderDetailCell
                    cell.btnEdit.addTarget(self, action: #selector(editNodeNameBtnTapped), for: .touchUpInside)
                    cell.btnEdit.fadeInEffectOnView(view:cell.btnEdit, pullToRefresh: self.isPullToRefresh)
                    cell.btnLetsFixIt.addTarget(self, action: #selector(letsFixItButton), for: .touchUpInside)
                    cell.updateExtenderName(extenderDetails: self.selectedExtenderDetail)
                    if !cell.btnLetsFixIt.isHidden {
                        cell.btnLetsFixIt.fadeInEffectOnView(view: cell.btnLetsFixIt, pullToRefresh: self.isPullToRefresh)
                    }
                    return cell
                case .None:
                    return UITableViewCell()
                }
            }
            //Create Extender/Gateway Details cell
            else if indexPath.row - 1 <  self.arrNodeDetails.count {
                let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: equipmentDetailRow) as! EquipmentDetailRow
                let deviceDetail = self.arrNodeDetails[indexPath.row - 1]
                cell.lblLeftColumn.text = deviceDetail.title
                cell.lblRightColumn.text = deviceDetail.value
                cell.fadeInEffectOnView(view: cell.detailContentView, pullToRefresh: self.isPullToRefresh)
                return cell
            }
            //Create Empty cell
            else if indexPath.row == self.arrNodeDetails.count + 1 {
                let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                cell.backgroundColor = themeColor
                return cell
            }
            //Create Empty cell
            else if indexPath.row == self.arrNodeDetails.count + 2 {
                let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                return cell
            }
            //Create NumberOfDevices Connected to Extender/Gateway cell
            else {
                let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: cellConnectedDevice) as! ConnectedDevicesTitleTableViewCell
                cell.contentView.isHidden = (self.selectedNodeType == .Extender && numberOfDevices == 0)
                cell.lblTitle.text = numberOfDevices == 0 ? "No connected devices" : ((numberOfDevices == 1) ? "\(numberOfDevices) connected device" : "\(numberOfDevices) connected devices")
                return cell
            }
        }
        //Create bottom LetUsHelp/Recently disconnected button cell for Extender/Gatewa
        else if indexPath.section == lastSectionIndex {
            
            let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: cellRecentlyButton) as! RecentlyButtonTableViewCell
            cell.vwTopLineToLabel.alpha = 0.0
            cell.recentlyButton.addTarget(self, action: #selector(recentlyDisconnectedBtnTapped), for: .touchUpInside)
            cell.letusHelpBtn.addTarget(self, action: #selector(letUsHelpBtnTapped), for: .touchUpInside)
            if self.selectedNodeType == .Extender || self.recentlyDisconnectedCount == 0 {
                cell.recentlyButton.isHidden = true
                cell.topConstraint.constant = -3
            } else {
                cell.recentlyButton.isHidden = false
                cell.topConstraint.constant = 128
            }
            //}
            return cell
        }
        /// Cell to show the connected devices
        else {
            if indexPath.section < arrDeviceSections.count + 1 {
                let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: cellConnectedDeviceList) as! ConnectedDevicesListTableViewCell
                let key = arrDeviceSections[indexPath.section-1]
                let list = arrDevices[key]
                let device = list?[indexPath.row]
                
                if indexPath.row == list!.count - 1 {
                    cell.hideSeparator = false
                    cell.isLastCell = true
                    cell.vwBottomLine.isHidden = true
                } else {
                    cell.hideSeparator = false
                    cell.isLastCell = false
                    cell.vwBottomLine.isHidden = false
                    cell.vwSolidLine.isHidden = true
                }
                cell.lblTitle.text = device?.title
                cell.imgViewType.image = device?.deviceImage_Gray
                /// Check If the device is paused
                if ProfileManager.shared.isDeviceMacPaused(mac: device?.macAddress ?? "") {
                    cell.lblStatus.isHidden = false
                    cell.imgViewStatus.isHidden = false
                    cell.lblStatus.text = "Paused"
                    cell.imgViewStatus.backgroundColor = pauseIndicatorColor
                    return cell
                }
                /// Configure offline/online/weak status
                let statusValues = device?.getColor()
                guard let statusStr = statusValues?.status else {
                    cell.lblStatus.isHidden = true
                    cell.imgViewStatus.isHidden = true
                    return cell
                }
                cell.lblStatus.isHidden = false
                cell.imgViewStatus.isHidden = false
                cell.lblStatus.text = statusStr
                cell.imgViewStatus.backgroundColor = statusValues?.color
                return cell
            } else {
                guard let cell = self.networkDeviceDetailsTblVw.dequeueReusableCell(withIdentifier: "test") else {
                    return UITableViewCell()
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isPullToRefresh {
            if indexPath.section != 0 && indexPath.section != lastSectionIndex{
                self.qualtricsAction?.cancel()
                //add deviceIcon and animate
                let key = arrDeviceSections[indexPath.section-1]
                let list = arrDevices[key]
                guard let device = list?[indexPath.row] else {
                    return
                }
                if  indexPath.section < arrDeviceSections.count + 1 {
                    let selectedCell = self.networkDeviceDetailsTblVw.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! ConnectedDevicesListTableViewCell
                    let deviceIconFrame = self.getFrameOfSelectedAvatarIcon(selectedView: selectedCell, animateFromVC: .None)
                    self.addDeviceIconAsSubviewAndAnimate(frame: deviceIconFrame, iconImage: device.deviceImage_White) { isAnimationCompleted in
                        self.navigateToConnectedDeviceDetailScreen(deviceDetail:device)
                    }
                }
            }
        }
    }
}

extension NetworkDetailsVC: HandlingPopUpAnimation{
    
    func animatedVCGettingDismissed(with image: UIImage) {
        //remove added bgView for deviceIcon animation
        let bgAnimationView = self.view.viewWithTag(1000)
        self.animateDeviceIconFromTopToBottom(image: image) { isAnimationCompleted in
            UIView.animate(withDuration: 0.5) {
                bgAnimationView?.alpha = 0.0
                self.setAlphaForUIElements(alpha: 1.0)
            } completion: { _ in
                bgAnimationView?.removeFromSuperview()
                self.isPullToRefresh = true
                //to not show the alpha effect when coming back from connected device detail screen
                UIView.animate(withDuration: 0.0) {
                    self.networkDeviceDetailsTblVw.reloadData()
                } completion: { _ in
                    self.isPullToRefresh = false
                }
            }
        }
    }
}
