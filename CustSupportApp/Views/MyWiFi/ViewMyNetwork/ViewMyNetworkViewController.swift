//
//  ViewMyNetworkViewController.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 24/08/22.
//

import UIKit
import Lottie
import Combine
class ViewMyNetworkViewController: UIViewController {
    
    //View Outlet Connections
    @IBOutlet weak var vwTopBackground: UIView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwCloseContainer: UIView!
    //Table View Outlet Connections
    @IBOutlet weak var vwMyNetworkTableView: UITableView!
    //Button Outlet Connections
    @IBOutlet weak var vwClossBtn: UIButton!
    //Constraint Outlet Connections
    @IBOutlet weak var vwClossBtnBottom: NSLayoutConstraint!
    //Pull to referesh outlet connections and properties
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet weak var vwTblViewTopConstraint: NSLayoutConstraint!
    var refreshControl: UIRefreshControl!
    var isPullToRefresh: Bool = false
    var isReloadForExtenderSelection = false
    //TableView Cell Identifiers
    let cellWiFiStatus                  = "MyWifiDetailsTableViewCell"
    let cellConnectedDevice             = "ConnectedDevicesTitleTableViewCell"
    let cellSectionHeader               = "SectionHeaderTableViewCell"
    let cellConnectedDeviceList         = "ConnectedDevicesListTableViewCell"
    let cellRecentlyButton              = "RecentlyButtonTableViewCell"
    let emptyCell                       = "EmptyCell"
    
    //Constants
    let EMPTY_CELL_HEIGHT_CONSTANT = Int((400/xibDesignHeight)*currentScreenHeight)
    
    var arrAll_Devices:[String:[ConnectedDevice]] = [:]
    var arrExtenders:[Extender] = []
    var arrAll_DeviceSections:[String] = []
    var numberOfDevices = 0
    lazy var recentlyDisconnectedCount = {
        MyWifiManager.shared.getRecentlyDisconnected().count
    }()
    var lastSectionIndex = 2
    //Animation Instances
    var emptyCellHeight = 0
    var detailContainerHeight = 0
    private var cancellables: Set<AnyCancellable> = []
    var qualtricsAction : DispatchWorkItem?
    var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Populate data for screen
        initialDataSetup()
        //set constraint + constant values for drawer and close button animation
        initialUIConstants()
        //register all TableViewCells
        tblViewCellRegister()
        //Set initial UI theme
        setUIAttributes()
        observeLiveTopologyState()
        //Added observer to handle background animation from deviceDetail screen
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBlueBGViewWithoutAnimation), name: NSNotification.Name(rawValue: "RemoveBGAnimationView"), object: nil)
        //Added observer to get updated SSID info
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSSID), name:NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
        //handle pullToRefresh using SwipeGesture
        handlePullToRefreshUsingSwipe()
        // Do any additional setup after loading the view.
    }

func handlePullToRefreshUsingSwipe(){
    //Add Swipe down gesture only if there are no connected devices
    if numberOfDevices == 0  {
        self.vwMyNetworkTableView.addSwipeGesture(gesture: &swipeDownGestureRecognizer, controller: self)
    }
}
    override func viewWillAppear(_ animated: Bool) {
        let (isNodeSelected, cell, _) = checkIFAnyNodeIsSelected()
        if  isNodeSelected {
            self.resetUIAfterNodeDismissal(cell: cell)
        } else {
            self.setAlphaOfUIElements(alpha: 0.0)
            self.performUIAnimations(delayDuration: 0.4)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        self.view.layoutIfNeeded()
    }
    
    //used to check whether any network node is selected
    func checkIFAnyNodeIsSelected() -> (Bool, cell:MyWifiDetailsTableViewCell?, SelectedNodeType){
        if let cell = self.vwMyNetworkTableView.cellForRow(at: IndexPath(row: 0, section: 0))  as? MyWifiDetailsTableViewCell, cell.selectedNodeType != .None {
            return (true, cell, cell.selectedNodeType)
        }
        return (true, nil, .None)
    }
    
    //used to reset UI on Main screen when the user dismisses the network detail VC
    func resetUIAfterNodeDismissal(cell: MyWifiDetailsTableViewCell?){
        //reset theme to energyBlueRGB
        self.setThemeForMainView(themeColor: energyBlueRGB)
        cell?.updateBackgroundTheme(themeColor: energyBlueRGB)
        
        //update extender/gateway name after renaming in the animating view during backward animation
        switch cell?.selectedNodeType {
        case .Gateway:
            cell?.updateGatewayName()
        case .Extender:
            let updatedExtenderData = MyWifiManager.shared.getExtenderData(macAddress: cell?.extenderDetails?.macAddress ?? "")
            cell?.selectedExtenderView?.lblExtenderName.text = updatedExtenderData?.title
        case .None, nil:
               break
        }
        //Handle display of UI elements
        self.setAlphaOfUIElements(alpha: 1.0)
        //Perform backward animation of Gateway/Extender to reset to the base position
        self.performUIAnimations(delayDuration:0.1, cell: cell)
    }
    
    //handle UI animations
    func performUIAnimations(delayDuration:CGFloat, cell: MyWifiDetailsTableViewCell? = nil){
        DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
            self.setupAnimationUI(cell: cell)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        //To avoid the flickering effect
        self.isPullToRefresh = true
        self.qualtricsAction?.cancel()
    }
    
    func addQualtrics(screenName:String){
        qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.callWiFimynetworkWithGA()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func callWiFimynetworkWithGA() {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_MYNETWORK.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
        self.addQualtrics(screenName: WiFiManagementScreenDetails.WIFI_MYNETWORK.rawValue)
    }
    
    @objc func updateSSID() {
        //self.pullToRefresh(hideScreen: true)
        DispatchQueue.main.async {
            self.vwMyNetworkTableView.beginUpdates()
            if let cell = self.vwMyNetworkTableView.cellForRow(at: IndexPath(row: 0, section: 0))  as? MyWifiDetailsTableViewCell {
                cell.updateSSID(animation: true)
            }
            self.vwMyNetworkTableView.endUpdates()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
        }
      //  vwMyNetworkTableView.reloadData()
    }
    @objc func lightSpeedAPICallBack() {
//        self.pullToRefresh(hideScreen: true, isComplete: true)
        // refreshAfterLTCall handles closing of animation
        self.refreshAfterLTCall()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
//        initialDataSetup()
//        vwMyNetworkTableView.reloadData()
    }
    @objc func removeBlueBGViewWithoutAnimation() {
        //remove added bgView for deviceIcon animation
        let bgAnimationView = self.view.viewWithTag(1000)
        bgAnimationView?.removeFromSuperview()
    }
    
    //CMAIOS-2100 update main view bg color as per status of extender upon its selection/deselection
    func setThemeForMainView(themeColor:UIColor){
        self.vwTopBackground.backgroundColor = themeColor
        self.view.backgroundColor = themeColor
    }
    
    func populateAllExtenders() {
        arrExtenders.removeAll()
        arrExtenders = MyWifiManager.shared.getAllExtendersData() //Offline + Online
    }
    
    func populateAllNetworkDetails(){
        let allNetworkDevicesDetails = MyWifiManager.shared.populateConnectedDevices(withSections: true)
        //CMAIOS-2100 
        //dict of all connected devices with Sections
        arrAll_Devices = allNetworkDevicesDetails?.0 ?? [:]
        //arr of different section names/device categories
        arrAll_DeviceSections = allNetworkDevicesDetails?.1 ?? []
        // Backup for initial data for reset UI
        lastSectionIndex = arrAll_DeviceSections.count + 1
        
        let arrConnectedDevices = allNetworkDevicesDetails?.2 ?? []
        numberOfDevices = arrConnectedDevices.isEmpty ? 0 : arrConnectedDevices.count
    }
    
    func initialDataSetup() {
        // Combine online and offline Extenders
        populateAllExtenders()
        populateAllNetworkDetails()
    }
    
    func tblViewCellRegister() {
        vwMyNetworkTableView.register(UINib.init(nibName: cellWiFiStatus, bundle: nil), forCellReuseIdentifier: cellWiFiStatus)
        vwMyNetworkTableView.register(UINib.init(nibName: cellConnectedDevice, bundle: nil), forCellReuseIdentifier: cellConnectedDevice)
        vwMyNetworkTableView.register(UINib.init(nibName: cellSectionHeader, bundle: nil), forCellReuseIdentifier: cellSectionHeader)
        vwMyNetworkTableView.register(UINib.init(nibName: cellConnectedDeviceList, bundle: nil), forCellReuseIdentifier: cellConnectedDeviceList)
        vwMyNetworkTableView.register(UINib.init(nibName: cellRecentlyButton, bundle: nil), forCellReuseIdentifier: cellRecentlyButton)
        vwMyNetworkTableView.register(EmptyCell.self, forCellReuseIdentifier: emptyCell)

        if #available(iOS 15.0, *) {
            vwMyNetworkTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func setAlphaOfUIElements(alpha : CGFloat){
        self.vwMyNetworkTableView.alpha = alpha
        self.vwCloseContainer.alpha = alpha
    }
    
    //MARK: Button Actions
    @IBAction func closeTapAction(_ sender: Any) {
        self.closeBtnAction()
    }
    
    func closeBtnAction (){
        self.qualtricsAction?.cancel()
        hideVWPullToRefreshUI()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editWifiBtnAction() {
        if  !isPullToRefresh {
            self.qualtricsAction?.cancel()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
            UIView.animate(withDuration: 0.5) {
                self.pushDeviceListDown()
                self.animateCloseBtnViewDown()
                self.vwMyNetworkTableView.alpha = 0.5
            } completion: { _ in
                self.vwMyNetworkTableView.alpha = 0.0
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateSSID), name:NSNotification.Name(rawValue: "UpdateSSID"), object: nil)
                    let editWifiScreen = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditWifi") as! EditWifiViewController
                    editWifiScreen.modalPresentationStyle = .fullScreen
                    self.present(editWifiScreen, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func recentlyDisconnectedBtnTapped()
    {
        self.qualtricsAction?.cancel()
        let vc = UIStoryboard(name: "WiFiScreen", bundle: nil).instantiateViewController(identifier: "DisconnectedDevices") as DisconnectedDevicesViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @objc func letUsHelpBtnTapped()
    {
        self.qualtricsAction?.cancel()
        pullToRefresh(hideScreen: true, isComplete: true)
        let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "OneDeviceSlowViewController") as OneDeviceSlowViewController
        vc.isComingFromLetUsHelp = true
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
    }
    
    @objc func letsFixItButton(btn: UIButton) {
        self.qualtricsAction?.cancel()
        ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
        if let indexPath = self.vwMyNetworkTableView.indexPathForView(view: btn)
        {
            if let cell = self.vwMyNetworkTableView.cellForRow(at: indexPath) as? MyWifiDetailsTableViewCell {
                if let extender = cell.extenderDetails {
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
    }

    func setUIAttributes() {
        var themeColor = energyBlueRGB
        if let bgColor = MyWifiManager.shared.getMasterGatewayDetails().bgColor {
            themeColor = bgColor
        }
        self.setThemeForMainView(themeColor: themeColor)
        self.vwCloseContainer.layer.shadowColor = UIColor.gray.cgColor
        self.vwCloseContainer.layer.shadowOpacity = 0.5
        self.vwCloseContainer.layer.shadowRadius = 5
    }
    
    //MARK: Pull to refresh Methods
    func observeLiveTopologyState() {
        MyWifiManager.shared.$lightSpeedData
            .receive(on: RunLoop.main)
            .sink {[weak self] newLTData in
                if self?.isViewLoaded == true && self?.view.window != nil {
                    /// Refresh Screen
                    if self?.isPullToRefresh == false {
                        self?.refreshAfterLTCall()
                    }
                }
            }.store(in: &cancellables)
    }
    
    func refreshAfterLTCall() {
        if MyWifiManager.shared.getMyWifiStatus() == .wifiDown {
            self.closeBtnAction()
            return
        }
        Logger.info("Wifi Status is \(MyWifiManager.shared.getMyWifiStatus())")
        recentlyDisconnectedCount =  MyWifiManager.shared.getRecentlyDisconnected().count
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isReloadForExtenderSelection = true
            self.initialDataSetup()
            if self.isPullToRefresh{//CMAIOS-2149
                self.pullToRefresh(hideScreen: true, isComplete: true)
            } else {
                UIView.performWithoutAnimation {
                    self.vwMyNetworkTableView.reloadData()
                }
            }
        }
    }
    
    func enableDisableScrolling() {
        if self.recentlyDisconnectedCount > 0 || self.numberOfDevices > 0 {
            self.vwMyNetworkTableView.isScrollEnabled = true
        } else {
            self.vwMyNetworkTableView.isScrollEnabled = false
        }
    }
    
    ///Method for pull to refresh during swipe.
    func initiatePullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        vwMyNetworkTableView.backgroundView = refreshControl
    }
    
    func hideVWPullToRefreshUI() {
        self.vwPullToRefreshAnimation.stop()
        self.vwPullToRefreshTop.constant = 80
        self.vwPullToRefreshHeight.constant = 0
        self.refreshControl.resetManualPullFrameChanges()
        self.refreshControl.endRefreshing()
        self.isPullToRefresh = false
        vwPullToRefresh.isHidden = true
        vwPullToRefreshCircle.isHidden = true
        self.vwPullToRefreshAnimation.backgroundColor = .clear
        self.vwPullToRefreshAnimation.isHidden = true
        self.view.layoutIfNeeded()
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
                self.isReloadForExtenderSelection = true
                self.vwMyNetworkTableView.allowsSelection = false
                self.vwPullToRefreshCircle.backgroundColor = .white
                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
//                self.vwPullToRefreshTop.constant = UIDevice().hasNotch ? 70 : 50
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.isHidden = false
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.vwMyNetworkTableView.isUserInteractionEnabled = false
                self.vwClossBtn.isUserInteractionEnabled = true
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                UIView.animate(withDuration: 0.5) {
                    self.vwMyNetworkTableView.allowsSelection = hide
                    self.vwPullToRefresh.isHidden = hide
                    self.vwPullToRefreshCircle.isHidden = hide
                    self.vwPullToRefreshAnimation.isHidden = hide
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshTop.constant = 80
                    self.vwPullToRefreshHeight.constant = 0
                    self.vwMyNetworkTableView.isUserInteractionEnabled = true
                    self.vwClossBtn.isUserInteractionEnabled = true
                    self.refreshControl.endRefreshing()
                    if self.numberOfDevices == 0 {
                        self.refreshControl.resetManualPullFrameChanges()
                    }
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.isPullToRefresh = false
                    UIView.performWithoutAnimation {//CMAIOS-2149
                        self.vwMyNetworkTableView.reloadData()
                    }
                }
            }
        }
    }
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        // After Refresh
       NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        MyWifiManager.shared.triggerOperationalStatus()
       /* let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        APIRequests.shared.initiateLiveTopologyRequest { _, _, _ in
            dispatchGroup.leave()
        }
        if MyWifiManager.shared.isGateWayWifi6() {
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
        }
        dispatchGroup.notify(queue: .main){
            self.pullToRefresh(hideScreen: true)
            self.refreshAfterLTCall()
        }*/
    }
    
    //MARK: Animation Methods
    func initialUIConstants() {
        emptyCellHeight = EMPTY_CELL_HEIGHT_CONSTANT
        initiatePullToRefresh()
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
        self.vwClossBtnBottom.constant = -100
        detailContainerHeight = self.getDynamicHeight(extenders: arrExtenders)
    }

    func resetElementsToPositions(cell: MyWifiDetailsTableViewCell?){
        if let selectedCell = cell {
            if selectedCell.editControl != nil {
                if  selectedCell.lblWiFiName.text?.isEmpty == false {
                    selectedCell.editControl.alpha = 1.0
                    selectedCell.editControl.isHidden = false
                }
            }
            if selectedCell.selectedExtenderView != nil {
                selectedCell.selectedExtenderView?.transform = .identity
            }
            selectedCell.viewAnimation.transform = .identity
            selectedCell.fadeEffectOnViewWithoutDuration(view:  selectedCell.vwContainer)
            selectedCell.vwContainer.subviews.first?.subviews.forEach({ $0.alpha = 1.0 })
        }
    }
    
    func setupAnimationUI(cell: MyWifiDetailsTableViewCell? = nil) {
        UIView.animate(withDuration: 0.4) {
            //reset main screen elements after tapping close button from Gateway/Extender Detail
            self.resetElementsToPositions(cell: cell)
            //close button animation from bottom to top
            self.animateCloseBtnViewTop()
            self.view.layoutIfNeeded()
            //handle UI Elements Alpha
            self.setAlphaOfUIElements(alpha: 1.0)
            self.vwContainer.alpha = 1.0
            //Helps in whether drawer animation from bottom to Top is required
            var pullDevices = false
            if self.recentlyDisconnectedCount > 0 || self.numberOfDevices > 0 {
                pullDevices = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if pullDevices {
                    self.pullDeviceListUp()
                } else {
                    self.vwMyNetworkTableView.isScrollEnabled = false
                }
            }
        } completion: { _ in
            //To enable the user interaction
            self.isPullToRefresh = false
            //CMAIOS-2100 Update UI after renaming Gateway/Extender consuming updated LT response data
            if MyWifiManager.shared.refreshLTDataRequired {
                MyWifiManager.shared.refreshLTDataRequired = false
                self.refreshAfterLTCall()
            }
        }
    }

    //MARK: Navigation Methods
    func navigateToConnectedDeviceDetailScreen(deviceDetail:ConnectedDevice?) {
        let viewController = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(identifier: "ConnectedDeviceDetailVC") as ConnectedDeviceDetailVC
            viewController.deviceDetails = deviceDetail
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
    }
    func navigationForExtenderTroubleshoot(identifier: String) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        let navVC = UINavigationController.init(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.setNavigationBarHidden(false, animated: true)
        self.present(navVC, animated: true)
    }
    
    //get extender view total height dymanically as per extender count
    func getDynamicHeight(extenders:[Extender])-> Int {
        switch extenders.count {
        case 0:
            if UIDevice.current.hasNotch {
               return 38
            }
            return 28
        default:
            //CMAIOS-2100 Restrict count to 6 as we are accomodating only 6 extenders.
            var totalExtenders = extenders.count
            if totalExtenders > 6 {
                totalExtenders = 6
            }
            var (numberOfRows, remainder) = totalExtenders.quotientAndRemainder(dividingBy:3)
            var space = 65
            if !UIDevice.current.hasNotch {
                space = 45
            }
            switch (extenders.count > 0, numberOfRows, remainder) {
            case (true, 0, _):
                //handle the case when  extender count < 3
                numberOfRows = numberOfRows + 1
            case (true, _ , 0):
                //handle the case when  extender count is divisible by 3
                numberOfRows = numberOfRows + remainder
            default:
                //handle the case when  extender count > 3
                numberOfRows =  numberOfRows + 1
            }
            let height = numberOfRows * 114 + (5 * (numberOfRows - 1))
            return  height + space //(heightOfExtender + space b\w each extender row + bottom space between device list and last extender row)
        }
    }
    
    @objc func handleSwipeGesture(){
        self.vwMyNetworkTableView.isScrollEnabled = true
        self.refreshControl.refreshManually()
    }
}

// MARK: - Extender Selection
extension ViewMyNetworkViewController:ExtendersDelegate {

    func navigateToNetworkDetailsScreen(_ cell: MyWifiDetailsTableViewCell, selectedNodeType: SelectedNodeType) {
        let storyboard = UIStoryboard(name: "WiFiScreen", bundle: nil)
        guard let networkDetailsVC = storyboard.instantiateViewController(withIdentifier: "NetworkDetailsVC") as? NetworkDetailsVC else { return }
        networkDetailsVC.selectedNodeType = selectedNodeType
        if networkDetailsVC.selectedNodeType == .Extender {
            networkDetailsVC.selectedExtenderDetail = cell.extenderDetails
        }
        networkDetailsVC.modalPresentationStyle = .fullScreen
        self.present(networkDetailsVC, animated: false, completion: nil)
    }
    
    func pushDeviceListDown() {
        self.vwMyNetworkTableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        self.vwMyNetworkTableView.isScrollEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.vwMyNetworkTableView.beginUpdates()
            self.emptyCellHeight = self.EMPTY_CELL_HEIGHT_CONSTANT
            self.vwMyNetworkTableView.endUpdates()
        }
    }
    
//    func getExtenders() -> [Extender] {
//        return arrExtenders
//    }
    func pullDeviceListUp() {
        if self.numberOfDevices > 0 || self.recentlyDisconnectedCount > 0 {
            self.vwMyNetworkTableView.beginUpdates()
            self.emptyCellHeight = 0
            self.vwMyNetworkTableView.endUpdates()
            self.vwMyNetworkTableView.isScrollEnabled = true
            self.vwMyNetworkTableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        }
    }
    
    func setSelectedExtenderTheme(theme:UIColor) {
        self.setThemeForMainView(themeColor: theme)
    }

    func animateCloseBtnViewDown(){
        UIView.animate(withDuration: 0.1) {
            self.vwClossBtnBottom.constant = -100
            self.view.layoutIfNeeded()
        }
    }
    
    func animateCloseBtnViewTop(){
        DispatchQueue.main.asyncAfter(deadline:.now()+0.3, execute: {
            UIView.animate(withDuration: 0.3) {
                self.vwClossBtnBottom.constant = 0
                self.view.layoutIfNeeded()
            }
        })
    }
}

// MARK: - TableView delegate and datasource
extension ViewMyNetworkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + arrAll_DeviceSections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 && section != lastSectionIndex {
            if section < arrAll_DeviceSections.count + 1 {
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
                if section < arrAll_DeviceSections.count + 1 {
                    if section == 1 {
                        view.titleTop.constant = 28
                    } else {
                        view.titleTop.constant = 12
                    }
                    let string = arrAll_DeviceSections[section-1]
                    if string == "personal and computer" {
                        view.lblTitle.text = "Personal and Computer" //For casing issues
                    } else {
                        view.lblTitle.text = string
                    }
                } else {
                    view.lblTitle.text = ""
                }
              //  view.isHidden = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    view.isHidden = false
//                }
            }
            return contentView.first as? UIView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == lastSectionIndex {
            if numberOfDevices == 0 && recentlyDisconnectedCount == 0
            {
                return 0
            }
            return 1
        } else {
            let key = arrAll_DeviceSections[section-1]
            let list = arrAll_Devices[key]
            return list?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                var cellHeight = 280
                if UIDevice.current.hasNotch {
                    cellHeight = 280
                } else {
                    cellHeight = 282
                }
                return CGFloat(cellHeight + detailContainerHeight)
            } else if indexPath.row == 1 {
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
            if indexPath.section < arrAll_DeviceSections.count + 1 {
                let key = arrAll_DeviceSections[indexPath.section-1]
                let list = arrAll_Devices[key]
                
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
            /// Cell to show Wifi name/password and Gateway status and extenders
            if indexPath.row == 0 {
                let cell = self.vwMyNetworkTableView.dequeueReusableCell(withIdentifier: cellWiFiStatus) as! MyWifiDetailsTableViewCell
                cell.updateGatewayName()
                cell.editControl.addTarget(self, action: #selector(editWifiBtnAction), for: .touchUpInside)
                cell.updateSSID(animation: !isReloadForExtenderSelection)
                cell.viewAnimation.play()
                cell.setTapActionForAnimationView()
                    if arrExtenders.isEmpty {
                        cell.vwContainer.isHidden = true
                    } else {
                        if isReloadForExtenderSelection && !isPullToRefresh {
                            cell.addExtender(arrExtenders: arrExtenders,showFadeEffect: false, handlePullToRefresh: isPullToRefresh)
                        } else {
                            if !isPullToRefresh {
                                cell.addExtender(arrExtenders: arrExtenders,showFadeEffect: true, handlePullToRefresh: isPullToRefresh)
                            }
                        }
                    }
                cell.extenderDelegate = self
                return cell
            } else if indexPath.row == 1 {
                let cell = self.vwMyNetworkTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                return cell
            } else {
                let cell = self.vwMyNetworkTableView.dequeueReusableCell(withIdentifier: cellConnectedDevice) as! ConnectedDevicesTitleTableViewCell
                cell.contentView.isHidden = false
                cell.lblTitle.text = numberOfDevices == 0 ? "No connected devices" : ((numberOfDevices == 1) ? "\(numberOfDevices) connected device" : "\(numberOfDevices) connected devices")
                return cell
            }
        }
        /// Cell to show the bottom button
        else if indexPath.section == lastSectionIndex {
            
            let cell = self.vwMyNetworkTableView.dequeueReusableCell(withIdentifier: cellRecentlyButton) as! RecentlyButtonTableViewCell
            cell.vwTopLineToLabel.alpha = 0.0
            cell.recentlyButton.addTarget(self, action: #selector(recentlyDisconnectedBtnTapped), for: .touchUpInside)
            cell.letusHelpBtn.addTarget(self, action: #selector(letUsHelpBtnTapped), for: .touchUpInside)
            if self.recentlyDisconnectedCount == 0 || checkIFAnyNodeIsSelected().2 == .Extender {
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
            if indexPath.section < arrAll_DeviceSections.count + 1 {
                let cell = self.vwMyNetworkTableView.dequeueReusableCell(withIdentifier: cellConnectedDeviceList) as! ConnectedDevicesListTableViewCell
                let key = arrAll_DeviceSections[indexPath.section-1]
                let list = arrAll_Devices[key]
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
                guard let cell = self.vwMyNetworkTableView.dequeueReusableCell(withIdentifier: "test") else {
                    return UITableViewCell()
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 && indexPath.section != lastSectionIndex {
            self.qualtricsAction?.cancel()
            //add deviceIcon and animate
            let key = arrAll_DeviceSections[indexPath.section-1]
            let list = arrAll_Devices[key]
            guard let device = list?[indexPath.row] else {
                return
            }
            if  indexPath.section < arrAll_DeviceSections.count + 1 {
                let selectedCell = self.vwMyNetworkTableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! ConnectedDevicesListTableViewCell
                let deviceIconFrame = self.getFrameOfSelectedAvatarIcon(selectedView: selectedCell, animateFromVC: .None)
                self.addDeviceIconAsSubviewAndAnimate(frame: deviceIconFrame, iconImage: device.deviceImage_White) { isAnimationCompleted in
                    self.navigateToConnectedDeviceDetailScreen(deviceDetail:device)
                }
            }
        }
    }
//    func deviceForRow(index:Int) -> ConnectedDevice {
//        if arrAll_Devices.isEmpty {
//            return ConnectedDevice(title: "Test", colorName: "Test")
//        }
//        let node = arrAll_Devices[index]
//        var title = ""
//        var color = ""
//        if let friendlyName = node.friendly_name, !friendlyName.isEmpty {
//            title = friendlyName
//        } else if let hostname = node.hostname, !hostname.isEmpty {
//            title = hostname
//        }
//        if let colorValue = node.color, !colorValue.isEmpty {
//            color = colorValue
//        }
//        return ConnectedDevice(title: title, colorName: color)
//}
}

//MARK: HandlingPopUpAnimation protocol methods
extension ViewMyNetworkViewController : HandlingPopUpAnimation {
    
    func animatedVCGettingDismissed(with image: UIImage){
        //remove added bgView for deviceIcon animation
        let bgAnimationView = self.view.viewWithTag(1000)
        self.animateDeviceIconFromTopToBottom(image: image) { isAnimationCompleted in
            UIView.animate(withDuration: 0.5) {
                bgAnimationView?.alpha = 0.0
                self.setAlphaForUIElements(alpha: 1.0)
            } completion: { _ in
                bgAnimationView?.removeFromSuperview()
                UIView.performWithoutAnimation {
                    self.vwMyNetworkTableView.reloadData()
                }
            }
        }
    }
}

extension UITableView {
    func indexPathForView(view: UIView) -> IndexPath? {
        let tableView = self.convert(CGPoint.zero, from: (view))
        return self.indexPathForRow(at: tableView)
    }
    
    func addSwipeGesture( gesture: inout UISwipeGestureRecognizer, controller: UIViewController){
        gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        if let vc = controller as? ViewMyNetworkViewController {
            gesture.addTarget(controller, action: #selector(vc.handleSwipeGesture))
        } else if let vc = controller as? NetworkDetailsVC {
            gesture.addTarget(controller, action: #selector(vc.handleSwipeGesture))
        }
        self.addGestureRecognizer(gesture)
    }
}

extension UIRefreshControl {
    func refreshManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height - 40), animated: false)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
    
    func resetManualPullFrameChanges() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
}
