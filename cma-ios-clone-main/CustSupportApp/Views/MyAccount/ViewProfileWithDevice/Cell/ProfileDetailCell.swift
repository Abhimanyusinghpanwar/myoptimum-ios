//
//  ProfileDetailCell.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 03/10/22.
//

import UIKit

//protocol declaration to handle PullToRefresh
protocol HandlePullToRefresh {
    func performPullToRefresh()
}

protocol ProfileDetailDelegate {
    func callApiForTimerData(models: [Int :PauseScheduleModel])
    func presentPauseTimerVC(model: PauseScheduleModel)
    func animateCloseBtnViewToTop()
    func animateCloseBtnViewToBottom()
}

protocol PauseOrUnpauseInternet{
    func triggerPauseActionOnProfile(enable:Bool, profileID:Int)
}

class ProfileDetailCell: UICollectionViewCell {
    
    enum PauseTimerType {
        case none
        case Timer
        case WeekendTimer
        case TimerDateError
    }
    
    //TableView Cell Identifiers
    ///Cell for section Header
    let cellHeader                  = "SectionHeaderCellTableViewCell"
    ///Cell for profile detials
    let cellProfileDetails          = "ProfileDetailsTableViewCell"
    let cellPauseInternet           = "PauseInternetTableViewCell"
    ///Cell for device list
    let cellTopDevices              = "TopDevicesTableViewCell"
    let cellDevicesList             = "DevicesListTableViewCell"
    ///Cell for extenders
    let cellConnectedExtenders      = "ConnectedExtendersCell"
    ///Cell for automatically pause internet
   // let cellAutomaticallyPause      = "AutomaticallyPauseInternetsTableViewCell"
    ///Empty Cell for drawer animation
    let emptyCell                   = "EmptyCell"
    let cellWithoutDevice = "ProfileDetailWithoutDeviceCell"
    //Constants
    let PROFILE_CELL_HEIGHT_WITH_DEVICE = 174
    let PROFILE_CELL_HEIGHT_WITHOUT_DEVICE = 156
    let PAUSE_INTERNET_CELL_HEIGHT = 80
    let CLOSE_VIEW_HEIGHT = 120
    let TOP_CONSTRAINT_SPACE = 40
    let SECTION_HEADER_HEIGHT = 80
    let TOP_DEVICES_CELL_HEIGHT = 60 //Top Devices
    let ONLINE_ACTIVITY_CELL_HEIGHT = 45 //50
    let NO_ONLINE_ACTIVITY_CELL_HEIGHT = 60
    
    var arrOnlineActivityDeviceData: [OnlineActivityDevice] = []
    ///data for automatically pause internet list UI
   /* var arrAutomaticallyPauseData = [["title":"At bedtime","icon":"icon_bedtime"],
                                        ["title":"During the day","icon":"icon_timing"]]*/
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var vwHeader: UIView!
    var arrConnectedDevices:[ConnectedDevice] = []
    var emptyCellHeight = 0
    var arrHouseHoldProfiles : Profiles?
    var profile:ProfileModel?
    var deviceCount:Int = 0
    var refreshDelegate: HandlePullToRefresh?
    var delegate: ProfileDetailDelegate?
    var tableDataSource: [Int :PauseScheduleModel] = [:]
    var pauseTimerEnum: [Int : PauseTimerType] = [:]
    var pauseTimerModels: [Int : PauseTimerModel] = [:]
    var isPreviousTimeSave = false
    var isPreviousWeekendTimeSave = false
    var isCancelTapped = false
    var isPauseUnpauseTapped = false
    var isPullToRefreshIsInProgress = false
    var pauseUnpauseDelegate : PauseOrUnpauseInternet?
    var currentSelectedDeviceIndex : Int = 0
    var currentSelectedMacAddress : String = ""
    
    override func awakeFromNib() {
        registerCells()
        self.configureUIData()
        tblView.delegate = self
        tblView.dataSource = self
        self.tblView.rowHeight = UITableView.automaticDimension
        self.vwHeader.frame.size.height = UIDevice.current.topInset
    }
    
    override func prepareForReuse() {
        self.profile = nil
        self.deviceCount = 0
    }
    
    func setUpCellData(profile:ProfileModel?)
    {
        emptyCellHeight = self.getEmptyCellHeight()
        self.animateTableviewToTop()
    }
    
    func animateConnectedDeviceProgress() {
        self.animateTableViewProgress()
    }
    
    //Calculate dynamic empty cell height
    func getEmptyCellHeight() -> Int{
        var heightOfEmptyCell = 0
        if self.profile?.devices.count ?? 0 > 0, let isMaster = self.profile?.isMaster, !isMaster
        {
          //  heightOfEmptyCell = Int(currentScreenHeight) - (PROFILE_CELL_HEIGHT_WITH_DEVICE + CLOSE_VIEW_HEIGHT)
            heightOfEmptyCell = Int(currentScreenHeight) - (PROFILE_CELL_HEIGHT_WITH_DEVICE)
        } else {
            //heightOfEmptyCell = Int(currentScreenHeight) - (PROFILE_CELL_HEIGHT_WITHOUT_DEVICE + TOP_CONSTRAINT_SPACE + CLOSE_VIEW_HEIGHT)
            heightOfEmptyCell = Int(currentScreenHeight) - (PROFILE_CELL_HEIGHT_WITHOUT_DEVICE + TOP_CONSTRAINT_SPACE)
            if !UIDevice.current.hasNotch{
                heightOfEmptyCell += 20
            }
        }
    
        return heightOfEmptyCell
    }
    
    func cancelCurrentQualtricsWorkItem(){
        guard let vc = parentViewController as? ViewProfileWithDeviceViewController else{
            return
        }
        vc.qualtricsAction?.cancel()
    }
    
    //Register All UITableViewCells
    func registerCells() {
        tblView.register(UINib.init(nibName: cellHeader, bundle: nil), forCellReuseIdentifier: cellHeader)
        tblView.register(UINib.init(nibName: cellProfileDetails, bundle: nil), forCellReuseIdentifier: cellProfileDetails)
        tblView.register(UINib.init(nibName: cellPauseInternet, bundle: nil), forCellReuseIdentifier: cellPauseInternet)
        tblView.register(UINib.init(nibName: cellTopDevices, bundle: nil), forCellReuseIdentifier: cellTopDevices)
        tblView.register(UINib.init(nibName: cellDevicesList, bundle: nil), forCellReuseIdentifier: cellDevicesList)
        tblView.register(UINib.init(nibName: cellConnectedExtenders, bundle: nil), forCellReuseIdentifier: cellConnectedExtenders)
      //  tblView.register(UINib.init(nibName: cellAutomaticallyPause, bundle: nil), forCellReuseIdentifier: cellAutomaticallyPause)
        tblView.register(EmptyCell.self, forCellReuseIdentifier: emptyCell)
        tblView.register(UINib.init(nibName: cellWithoutDevice, bundle: nil), forCellReuseIdentifier: cellWithoutDevice)
    }

    func pushDeviceListDown() {
        self.tblView.beginUpdates()
        emptyCellHeight = self.getEmptyCellHeight()
        self.tblView.endUpdates()
    }
    
    func pullDeviceListUp() {
        self.tblView.beginUpdates()
        self.emptyCellHeight = 0
        self.tblView.endUpdates()
        self.delegate?.animateCloseBtnViewToTop()
    }
    
    func animateTableviewToTop() {
        UIView.animate(withDuration: 0.5) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.pullDeviceListUp()
                self.animateProgressOnChangeInProfile(profileModel: self.profile)
            }
        }
    }

    func animateTableViewProgress() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.animateProgressOnChangeInProfile(profileModel: self.profile)
        }
    }
    
    
    func animateProgressOnChangeInProfile(profileModel:ProfileModel?) {
        setConnectedDevicesAndOnlineActivityData(profileModel: profileModel)
        let connectedDevices =  MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: profileModel).1
        if connectedDevices > 0 {
            for index in 0...3 {
                let updatedIndexRow = (connectedDevices > 4) ? index + 1 : index
                guard let selectedCell = self.tblView.cellForRow(at: IndexPath(row: updatedIndexRow, section: 1)) as? DevicesListTableViewCell else { return }
                selectedCell.progressViewStatus.setProgress(0, animated: false)
                let onlineDeviceData = (connectedDevices > 4) ? index + 1 : index
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
                    if self.arrOnlineActivityDeviceData.indices.contains(onlineDeviceData) {
                        selectedCell.progressViewStatus.setProgress(self.arrOnlineActivityDeviceData[onlineDeviceData].totalProgress, animated: true)
                    }
                }
            }
        }
    }
        
    func setConnectedDevicesAndOnlineActivityData(profileModel:ProfileModel?) {
        if !arrConnectedDevices.isEmpty {
            arrConnectedDevices.removeAll()
        }
        if !self.arrOnlineActivityDeviceData.isEmpty {
           self.arrOnlineActivityDeviceData.removeAll()
        }
        if let deviceList = self.profile?.devices, deviceList.count > 0 {
            for deviceNode in deviceList {
                var deviceName: String
                if let friendlyName = deviceNode.device?.friendlyName, !friendlyName.isEmpty {
                    deviceName = friendlyName
                } else if let hostName = deviceNode.device?.hostname, !hostName.isEmpty, hostName != deviceNode.device?.mac {
                    deviceName = hostName
                } else if let vendorName = deviceNode.device?.vendor, !vendorName.isEmpty, !vendorName.contains("None") {
                    deviceName = vendorName
                }
                else {
                    deviceName = "Unnamed device"
                }
                let LT_Node = MyWifiManager.shared.getDeviceDetailsForMAC(deviceNode.device?.mac ?? "")
                let deviceIconType = deviceNode.device?.deviceType ?? "unknown_gray_static"
                var defaultColor = "red"
                if self.profile?.profileStatus == nil{
                    defaultColor = ""
                }
                var deviceType = ""
                if LT_Node == nil {
                    deviceType = deviceNode.device?.deviceType ?? ""
                } else {
                    deviceType = LT_Node?.cma_dev_type ?? LT_Node?.device_type ?? ""
                }
                let color = LT_Node?.color ?? defaultColor
                arrConnectedDevices.append(ConnectedDevice(title: deviceName, deviceImage_Gray: DeviceManager.IconType.gray.getDeviceImage(name: deviceIconType), deviceImage_White: DeviceManager.IconType.white.getDeviceImage(name: deviceIconType), colorName: color, device_type: deviceType, conn_type: LT_Node?.conn_type ?? "", vendor: deviceNode.device?.vendor ?? "", macAddress: deviceNode.device?.mac ?? "", ipAddress: LT_Node?.ip ?? "", profileName: deviceNode.device?.profile ?? "", band:LT_Node?.band ?? "", sectionTitle: "", pid: deviceNode.device?.pid ?? 0))
                if deviceNode.connectedTime > 0 {
                    arrOnlineActivityDeviceData.append(OnlineActivityDevice(deviceName: deviceName, deviceIcon: deviceIconType, totalProgress: 0.0, connectedTime: deviceNode.connectedTime))
                }
            }
            arrConnectedDevices = DeviceManager.shared.sortDevices(devices: arrConnectedDevices)
            if !arrOnlineActivityDeviceData.isEmpty {
                arrOnlineActivityDeviceData = arrOnlineActivityDeviceData.sorted { $0.connectedTime > $1.connectedTime }
                guard let maxConnectedTime = (arrOnlineActivityDeviceData.first)?.connectedTime else { return }
                for var onlineActivityObj in arrOnlineActivityDeviceData {
                    let progressTime = calculateRelativeUsageProgress(connectedTimeValue: Float(onlineActivityObj.connectedTime), maximumConnectedTime: Float(maxConnectedTime))
                    onlineActivityObj.totalProgress = progressTime
                    if let index = arrOnlineActivityDeviceData.firstIndex(where: {$0.deviceName == onlineActivityObj.deviceName}){
                        arrOnlineActivityDeviceData[index] = onlineActivityObj
                    }
                }
            }
        }        
    }

    func calculateRelativeUsageProgress(connectedTimeValue: Float, maximumConnectedTime: Float)-> Float {
        return (connectedTimeValue / maximumConnectedTime)
    }
    
    func presentErrorMessageVCForGetAllNodesFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .fullScreen
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_node_household_add_device_failure)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_ADD_DEVICES_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
        parentViewController!.present(vc, animated: true)
    }
    
    @objc func btnLetsDoItAction(sender:UIButton){
        cancelCurrentQualtricsWorkItem()
        // select device
        guard let devices = DeviceManager.shared.devices, !devices.isEmpty else {
            self.presentErrorMessageVCForGetAllNodesFailure()
            return
        }
        guard let deviceVC = ProfileSelectDeviceViewController.instantiate(from: .profile, identifier: ProfileSelectDeviceViewController.identifier) else { return }
        deviceVC.pidSelected = self.profile?.pid
        if let profileObj = self.profile?.profile {
            deviceVC.state = .edit(profileObj)
            deviceVC.profileStatus = nil
        }
        guard let vc = parentViewController as? ViewProfileWithDeviceViewController else{
            let navVC = UINavigationController(rootViewController: deviceVC)
            navVC.modalPresentationStyle = .fullScreen
            parentViewController?.present(navVC, animated: true)
            return
        }
        deviceVC.delegate = vc
        let navVC = UINavigationController(rootViewController: deviceVC)
        navVC.modalPresentationStyle = .fullScreen
        vc.present(navVC, animated: true)
    }
    
    @objc func btnPauseInternetAction(sender:UIButton){
        let index = self.arrOnlineActivityDeviceData.count > 4 ? 1 : 0
        guard let pauseInternetCell = self.tblView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PauseInternetTableViewCell, let vc = parentViewController as? ViewProfileWithDeviceViewController else{return}
           pauseInternetCell.btnPauseInternet.isUserInteractionEnabled = false
            self.isPauseUnpauseTapped = true
            if pauseInternetCell.lblTitle.text == "Unpause Internet" {
                pauseUnpauseDelegate?.triggerPauseActionOnProfile(enable:false, profileID: self.profile?.pid ?? 0)
                    self.profile?.profileStatus = .online
                    self.tblView.reloadSections(IndexSet(integer: 0), with: .none)
                    self.vwHeader.backgroundColor = energyBlueRGB
                    self.backgroundColor = energyBlueRGB
            } else if pauseInternetCell.lblTitle.text == "Pause Internet"  {
                pauseUnpauseDelegate?.triggerPauseActionOnProfile(enable:true, profileID: self.profile?.pid ?? 0)
                vc.handleUIForPauseUnpauseInternet(isPausedUntilTomorrow: true)
            }
        //Update progressBar color while Pause/Unpause
        for var i in  0..<arrOnlineActivityDeviceData.count {
            if index > 0 {
                i = i + 1
            }
            let onlineActivityCell = self.tblView.cellForRow(at: IndexPath(row: i, section: 1)) as? DevicesListTableViewCell
            onlineActivityCell?.progressViewStatus.progressTintColor = self.profile?.profileStatus == .paused ? pauseBgColor : energyBlueRGB
            }
        
    }
    
    func configureUIData() {
        let model = PauseScheduleModel()
        let model1 = PauseScheduleModel()
        model.cellIndex = 0
        tableDataSource[0] = model
        model1.cellIndex = 1
        tableDataSource[1] = model1
    }
    
    //MARK: Pull To Refresh Methods
    func addSwipeGestureForPullToRefresh(detailCell: ProfileDetailsTableViewCell) {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
        swipeDownGestureRecognizer.delegate = self
        detailCell.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    @objc func pullToRefresh() {
        if !isPullToRefreshIsInProgress {
            isPullToRefreshIsInProgress = true
            self.refreshDelegate?.performPullToRefresh()
        }
    }
    
    ///Method for EditProfile
    @objc func btnEditProfile() {
        cancelCurrentQualtricsWorkItem()
        parentViewController?.navigationController?.removeViewControllerIfExists(ofClass: ProfileNameViewController.self)
        guard let profileVC = ProfileNameViewController.instantiate() else { return }
        if let profileObj = self.profile?.profile {
            profileVC.state = .edit(profileObj)
            profileVC.profile = profileObj
        }
        parentViewController?.navigationController?.pushViewController(profileVC, animated: true)
    }
    @objc func editDeviceBtnTapped(sender: UIButton){
        cancelCurrentQualtricsWorkItem()
        guard let devices = DeviceManager.shared.devices, !devices.isEmpty else {
            self.presentErrorMessageVCForGetAllNodesFailure()
            return
        }
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let deviceVC = storyboard.instantiateViewController(withIdentifier: "ProfileSelectDeviceViewController") as! ProfileSelectDeviceViewController
        deviceVC.pidSelected = self.profile?.pid
        if let profileObj = self.profile?.profile {
            deviceVC.state = .edit(profileObj)
            deviceVC.profileStatus = self.profile?.profileStatus
        }
        guard let vc = parentViewController as? ViewProfileWithDeviceViewController else{
            let navVC = UINavigationController(rootViewController: deviceVC)
            navVC.modalPresentationStyle = .fullScreen
            parentViewController?.present(navVC, animated: true)
            return
        }
        deviceVC.delegate = vc
        let navVC = UINavigationController(rootViewController: deviceVC)
        navVC.modalPresentationStyle = .fullScreen
        vc.present(navVC, animated: true)
    }
    func updateTimerDataOnSave() {
        var anyErrors: [Bool] = []
        for index in 0...1 {
            self.checkForTimerErrors(index: index)
            if let isTimer = tableDataSource[index]?.isTimer, isTimer == true {
                guard let firstCell = self.tblView.cellForRow(at: IndexPath(row: index, section: 3)) as? AutomaticallyPauseInternetsTableViewCell else { return }
//                updatePauseScheduleModels(for: firstCell, isSaved: true)
                self.updatePauseScheduleDataModels(for: firstCell)
            }
            let model = tableDataSource[index]
            if model!.pauseTimeDates.displayErrorView || model!.pauseTimeDates.displayWErrorView {
                anyErrors.append(true)
            }
        }
        // commented for now
        if anyErrors.count == 0 {
            self.delegate?.callApiForTimerData(models: tableDataSource)
            //           // updateUIButtons(title: "I’m done", hideSecond: true)
        }
        UIView.animate(withDuration: 0.5) {
            self.tblView.performBatchUpdates(nil)
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        }
    }
    
    func updateTableDataSource(model: PauseScheduleModel) {
        self.tableDataSource[model.cellIndex] = model
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5) {
                self.tblView.reloadData()
            }
        }
    }
    
    func updateTimerDataOnCancel() {
        self.tblView.reloadData()
        for inde in 0...1 {
            let model = tableDataSource[inde]
            if model?.isTimer == true {
            tableDataSource[inde] = PauseScheduleModel()
          }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.tblView.reloadData()
            }
        }
    }
    func checkForTimerErrors(index: Int) {
        if let fromDate = tableDataSource[index]?.timerModel.fromDate, let toDate = tableDataSource[index]?.timerModel.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            tableDataSource[index]?.pauseTimeDates.displayErrorView = true
            tableDataSource[index]?.timerModel.displayErrorView = true
        } else {
            tableDataSource[index]?.pauseTimeDates.displayErrorView = false
            tableDataSource[index]?.timerModel.displayErrorView = false
        }
        
        if let fromDate = tableDataSource[index]?.weekEndModel.fromDate, let toDate = tableDataSource[index]?.weekEndModel.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            tableDataSource[index]?.pauseTimeDates.displayWErrorView = true
            tableDataSource[index]?.weekEndModel.displayErrorView = true
        } else {
            tableDataSource[index]?.pauseTimeDates.displayWErrorView = false
            tableDataSource[index]?.weekEndModel.displayErrorView = false
        }
    }
    func updatePauseScheduleDataModels(for cell: AutomaticallyPauseInternetsTableViewCell, index: Int = 0) {
        tableDataSource[cell.tag]?.isInitial = false
        tableDataSource[cell.tag]?.isTimer = false

        tableDataSource[cell.tag]?.timerModel.cellIndex = cell.tag
        tableDataSource[cell.tag]?.weekEndModel.cellIndex = cell.tag
        if let isError = tableDataSource[cell.tag]?.timerModel.displayErrorView, isError == true || tableDataSource[cell.tag]!.weekEndModel.displayErrorView == true {
            // add code here
            if isCancelTapped{
                tableDataSource[cell.tag]?.timerModel.isTimerSaved = true
                tableDataSource[cell.tag]?.isTimer = false
                
            }
            else
            {
                tableDataSource[cell.tag]?.timerModel.isTimerSaved = false
                tableDataSource[cell.tag]?.isTimer = true
            }
        } else {
            tableDataSource[cell.tag]?.timerModel.isTimerSaved = true
            tableDataSource[cell.tag]?.isEdit = false
        }
        if tableDataSource[cell.tag]!.timerModel.displayErrorView == false && cell.pauseOnWeekEndsEnabled == true {
            if let isError = tableDataSource[cell.tag]?.weekEndModel.displayErrorView, isError == true {
                if isCancelTapped{
                    tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = true
                    tableDataSource[cell.tag]?.isTimer = false
                }else{
                    tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = false
                    tableDataSource[cell.tag]?.isTimer = true
                }

            } else {
                tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = true
                tableDataSource[cell.tag]?.weekEndModel.isWeekendsEnabled = true
                tableDataSource[cell.tag]?.isEdit = false
            }
        } else {
            tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = false
            tableDataSource[cell.tag]?.weekEndModel.isWeekendsEnabled = false
            tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = false
        }
    }
    func getTimeAndtimeTypefromDateForValidation(date: Date) -> (time: String, String) {
        var changedTimeString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        changedTimeString = formatter.string(from: date)
        return (time: changedTimeString , changedTimeString.components(separatedBy: " ").last ?? "")
    }
}

extension ProfileDetailCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
}

extension ProfileDetailCell: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       /* //Hide Automatically Pause Internet for master profile
        var numberOfSections = 0
        guard let isMaster = self.profile?.isMaster else {return 2}
        if  deviceCount > 0 && isMaster  {
            numberOfSections = 3
        } else if deviceCount > 0 && !isMaster  && MyWifiManager.shared.isGateWayWifi6(){
            numberOfSections = 4
        } else if deviceCount > 0 && !isMaster && !MyWifiManager.shared.isGateWayWifi6()
        {
            numberOfSections = 3
        }
        else {
            numberOfSections = 2
        }
        return numberOfSections*/
        //Hide Automatically Pause Internet
        var numberOfSections = 0
        if deviceCount > 0 {
            numberOfSections = 3
        }
        else {
            numberOfSections = 2
        }
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 80
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            ///Cell for section Header
            let cell = self.tblView.dequeueReusableCell(withIdentifier: cellHeader) as! SectionHeaderCellTableViewCell
            cell.profile = profile
            cell.setUpUI(section: section)
            if section == 2
            {
                cell.btnEditDevices.addTarget(self, action: #selector(editDeviceBtnTapped(sender:)), for: .touchUpInside)
            }
            return cell.contentView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return deviceCount > 0 && MyWifiManager.shared.isGateWayWifi6() && self.profile?.isMaster == false ? 3 : 2
        } else if section == 1 {
            if deviceCount > 0 {
                if MyWifiManager.shared.checkOnlineActivityExistsForProfile(profile: self.profile) {
                    let connectedDevicesCount = MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: self.profile).1
                    switch connectedDevicesCount {
                    case 1...4:
                        return arrOnlineActivityDeviceData.count
                    case 5...:
                        return 5
                    default:
                        return 1
                    }
                } else {
                    //show no activity text
                    return 1
                }
            } else {
                return 1
            }
        } else {
            return 2
        } /*else if section == 2 {
            return 1
        } else {
            return arrAutomaticallyPauseData.count
        }*/
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return CGFloat(deviceCount > 0 ? PROFILE_CELL_HEIGHT_WITH_DEVICE : PROFILE_CELL_HEIGHT_WITHOUT_DEVICE)
            } else if indexPath.row == 1 {
                return CGFloat(deviceCount > 0 && MyWifiManager.shared.isGateWayWifi6() && self.profile?.isMaster == false ? CGFloat(PAUSE_INTERNET_CELL_HEIGHT) : CGFloat(emptyCellHeight))
            } else {
                return CGFloat(emptyCellHeight)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if deviceCount > 0 {
                    if MyWifiManager.shared.checkOnlineActivityExistsForProfile(profile: self.profile){
                        let connectedDevices = MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: self.profile).1
                      switch (connectedDevices) {
                        case 5...:
                            // show Top devices text
                          return CGFloat(TOP_DEVICES_CELL_HEIGHT)
                        case 1...4:
                            // do not show Top devices text but show devices list
                          return CGFloat(ONLINE_ACTIVITY_CELL_HEIGHT)
                        default:
                            return 0
                        }
                    } else {
                        // show no activity text instead of Top Devices
                        return CGFloat(NO_ONLINE_ACTIVITY_CELL_HEIGHT)
                    }
                }else  {
                    // create empty cell
                    let dynamicCellHeight = Int(currentScreenHeight) -  PROFILE_CELL_HEIGHT_WITHOUT_DEVICE - SECTION_HEADER_HEIGHT - TOP_CONSTRAINT_SPACE
                    return CGFloat(dynamicCellHeight)
                 }
            } else {
                return 50
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let onlineActivityDevices = MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: self.profile).1
                var availableDynamicSpace = 0
                switch (onlineActivityDevices) {
                case 5...:
                    // With Top devices text
                    availableDynamicSpace = Int(currentScreenHeight) -  PROFILE_CELL_HEIGHT_WITH_DEVICE - SECTION_HEADER_HEIGHT * 2 - TOP_CONSTRAINT_SPACE - CLOSE_VIEW_HEIGHT - ONLINE_ACTIVITY_CELL_HEIGHT * onlineActivityDevices - TOP_DEVICES_CELL_HEIGHT
                case 1...4:
                    // Without Top devices text but with devices list
                    availableDynamicSpace = Int(currentScreenHeight) -  PROFILE_CELL_HEIGHT_WITH_DEVICE - SECTION_HEADER_HEIGHT * 2 - TOP_CONSTRAINT_SPACE - CLOSE_VIEW_HEIGHT - ONLINE_ACTIVITY_CELL_HEIGHT * onlineActivityDevices
                default:
                    // No Online activity but with No activity text
                    availableDynamicSpace = Int(currentScreenHeight) -  PROFILE_CELL_HEIGHT_WITH_DEVICE - SECTION_HEADER_HEIGHT * 2 - TOP_CONSTRAINT_SPACE - CLOSE_VIEW_HEIGHT - NO_ONLINE_ACTIVITY_CELL_HEIGHT
                }
                let cellheight = getDynamicHeight(devices: arrConnectedDevices)
                var requiredCellHeight = 0
                if availableDynamicSpace < cellheight {
                    requiredCellHeight = cellheight
                } else {
                    requiredCellHeight = availableDynamicSpace
                }
                return CGFloat(requiredCellHeight)
            } else {
                return CGFloat(CLOSE_VIEW_HEIGHT)
            }
            //else {
            //            // return 184
            //            return  CommonUtility.getHeightForCellModel(model: tableDataSource[indexPath.row]!)
            //        }
        }
        return 120
    }
    
    func getDynamicHeight(devices:[ConnectedDevice])-> Int {
        var (quotient, remainder) = devices.count.quotientAndRemainder(dividingBy:3)
        if remainder == 1 || remainder == 2 {
            quotient = quotient + 1
        }
        let padding = (quotient != 1) ? (quotient-1)*10 : 0
        return (quotient * 140) + padding
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            ///Cell for profile details
            if indexPath.row == 0 {
                let cell = self.tblView.dequeueReusableCell(withIdentifier: cellProfileDetails) as! ProfileDetailsTableViewCell
                cell.setProfileStatus(profileStatus: self.profile?.profileStatus ?? nil)
                self.addSwipeGestureForPullToRefresh(detailCell: cell)
                cell.btnEditProfileName.addTarget(self, action: #selector(btnEditProfile), for: .touchUpInside)
                cell.btnEditProfile.addTarget(self, action: #selector(btnEditProfile), for: .touchUpInside)
                cell.setUpUIAttributes(profile: self.profile, isPauseUnpauseTapped: self.isPauseUnpauseTapped)
                cell.selectionStyle = .none
                return cell
            } else {
                if deviceCount > 0 {
                    if indexPath.row == 1 && MyWifiManager.shared.isGateWayWifi6() && self.profile?.isMaster == false{
                        ///Cell for pause internet
                        let cell = self.tblView.dequeueReusableCell(withIdentifier: cellPauseInternet) as! PauseInternetTableViewCell
                        var pauseBtnTitle = ""
                        var pauseImageName = ""
                        if self.profile?.profileStatus == .online || self.profile?.profileStatus == .offline {
                            pauseBtnTitle = "Pause Internet"
                            pauseImageName = "icon_pause"
                        } else if self.profile?.profileStatus == .paused {
                            pauseBtnTitle = "Unpause Internet"
                            pauseImageName = "icon_play"
                        } else if  self.profile?.profileStatus == nil {
                            pauseBtnTitle = "Pause Internet"
                            pauseImageName = "icon_pause"
                        }
                        if let vc = parentViewController as? ViewProfileWithDeviceViewController {
                            cell.btnPauseInternet.isUserInteractionEnabled = vc.profilePauseAPIState == .progress ? false : true
                        }
                        cell.setUpUIAttributes(pauseBtnText: pauseBtnTitle, pauseImageName: pauseImageName)
                        cell.btnPauseInternet.addTarget(self, action: #selector(btnPauseInternetAction(sender:)), for: .touchUpInside)
                        cell.selectionStyle = .none
                        return cell
                    } else {
                        ///empty cell
                        let cell = self.tblView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                        cell.backgroundColor = UIColor.clear
                        return cell
                    }
                } else {
                    // empty cell
                    let cell = self.tblView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
            }
        } else if indexPath.section == 1 {
            if deviceCount > 0 {
                let connectedDevices =  MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: self.profile).1
                if indexPath.row == 0 {
                    if MyWifiManager.shared.checkOnlineActivityExistsForProfile(profile: self.profile) {
                        switch connectedDevices {
                        case 5...:
                            let cell = self.createTopDeviceCell(profileObj: self.profile)
                            return cell
                        case 1...4:
                            ///Cell for devices list
                            let cell = self.createDeviceListCell(currentIndexPath: indexPath)
                            return cell
                        default:
                            return UITableViewCell()
                        }
                    } else {
                        ///Cell for top devices
                        let cell = self.createTopDeviceCell(profileObj: self.profile)
                        return cell
                    }
                } else {
                    // If connected devices count is more than threshold (4)
                    let topLabelIsShown = connectedDevices > 4 ? true : false
                    ///Cell for devices list
                    let cell = self.createDeviceListCell(currentIndexPath: indexPath, topDevicesLabelVisible: topLabelIsShown)
                    return cell
                }
            } else {
                let cell = self.tblView.dequeueReusableCell(withIdentifier: cellWithoutDevice) as! ProfileDetailWithoutDeviceCell
                guard let profileDetail = self.profile else {
                    return UITableViewCell()
                }
                if profileDetail.isMaster == true {
                    cell.headerLabel.text =  "Add devices to your profile to know how much time you spend online."
                    cell.firstLabel.isHidden = true
                    cell.btnTopSpacingFromHeaderLabel.priority = .defaultHigh
                    cell.btnTopSpacingFromFirstLabel.priority = .defaultLow
                } else {
                    cell.headerLabel.text = "Add devices to " + "\(profileDetail.profileName)'s " + "profile to:"
                    let smartWifiValue = MyWifiManager.shared.isGateWayWifi5OrAbove()
                    cell.firstLabel.isHidden = false
                     switch smartWifiValue {
                     case 5, 6, 7:
                         cell.btnTopSpacingFromHeaderLabel.priority = .defaultLow
                         cell.btnTopSpacingFromFirstLabel.priority = .defaultHigh
                         let arrayOfLines = ["Encourage healthy screen time habits!","See how much time \(profileDetail.profileName) spends online"]
                         cell.firstLabel.add(stringList: arrayOfLines, font: UIFont(name: "Regular-Regular", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0))
                     default:
                        //handle text below WIFI5
                         break
                     }
                }
                cell.btnLetsDoIt.addTarget(self, action: #selector(btnLetsDoItAction(sender:)), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
        } //else if indexPath.section == 2
        else {
            if indexPath.row == 0 {
                ///Cell for extenders
                let cell = self.tblView.dequeueReusableCell(withIdentifier: cellConnectedExtenders) as! ConnectedDeviceCell
                /* if let isMaster = self.profile?.isMaster {
                 cell.isMasterProfile = isMaster
                 }*/
                cell.addDevicesBasedOnArray(arrConnectedDevices: arrConnectedDevices)
                cell.selectionStyle = .none
                return cell
            } else {
                ///empty cell
                let cell = self.tblView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                cell.backgroundColor = UIColor.white
                return cell
            }
        } /*else {
            ///Cell for automatically pause internet
            let cell = self.tblView.dequeueReusableCell(withIdentifier: cellAutomaticallyPause) as! AutomaticallyPauseInternetsTableViewCell
            cell.tag = indexPath.row
            cell.delegate = self
            cell.tapGestureForTimerView.isEnabled = false
            cell.shouldSavePreviousTime = self.isPreviousTimeSave
            cell.shouldSavePreviousWeekendTime = self.isPreviousWeekendTimeSave
            cell.setUpDataInUI(data: arrAutomaticallyPauseData, indexpath: indexPath)
            cell.selectionStyle = .none
            guard let scheduleModel = tableDataSource[indexPath.row] else { return cell }
            
    //        if scheduleModel.isSavedItem == true {
            if scheduleModel.timerModel.isTimerSaved == true || scheduleModel.weekEndModel.isTimerSaved == true {
                if !isCancelTapped {
                    if scheduleModel.isEdit {
                        cell.pauseOnWeekEndsEnabled = scheduleModel.isWeekendsEnabled
                        cell.configCellForEditSaved(model: scheduleModel)
                        
                        cell.layoutIfNeeded()
                        return cell
                    }
                }
                cell.configCellForSaved(model: scheduleModel)
                cell.layoutIfNeeded()
                return cell
            }

            if scheduleModel.isTimer {
                cell.addTimeControl.isHidden = true
                cell.timerView.isHidden = false
                cell.pauseOnWeekEndsEnabled = scheduleModel.isWeekendsEnabled
                cell.configCellForTimer(title: self.profile?.profileName ?? "", timerModel: scheduleModel.pauseTimeDates)
            } else if !scheduleModel.isTimer && scheduleModel.isInitial {
                cell.addTimeControl.isHidden = false
                cell.timerView.isHidden = true
                cell.tapGestureForTimerView.isEnabled = true
            }
           cell.layoutIfNeeded()
            return cell
        }*/
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*if indexPath.section == 3
        {
            let pauseCell = cell as! AutomaticallyPauseInternetsTableViewCell
            cell.tag = indexPath.row
            pauseCell.delegate = self
            pauseCell.shouldSavePreviousTime = self.isPreviousTimeSave
            pauseCell.shouldSavePreviousWeekendTime = self.isPreviousWeekendTimeSave
            pauseCell.tag = indexPath.row
            pauseCell.tapGestureForTimerView.isEnabled = false
            pauseCell.profileName = self.profile?.profileName ?? ""
            pauseCell.setUpDataInUI(data: arrAutomaticallyPauseData, indexpath: indexPath)
            
            guard let scheduleModel = tableDataSource[indexPath.row] else { return }
            
            if scheduleModel.timerModel.isTimerSaved == true || scheduleModel.weekEndModel.isTimerSaved == true {
                if !self.isCancelTapped{
                    if scheduleModel.isEdit {
                        pauseCell.pauseOnWeekEndsEnabled = scheduleModel.isWeekendsEnabled
                        pauseCell.configCellForEditSaved(model: scheduleModel)
                        //self.isCancelTapped = false
                        pauseCell.layoutIfNeeded()
                        return
                    }}
                pauseCell.configCellForSaved(model: scheduleModel)
                pauseCell.layoutIfNeeded()
                return
            }
            
            if scheduleModel.isTimer {
                pauseCell.addTimeControl.isHidden = true
                pauseCell.timerView.isHidden = false
                pauseCell.pauseOnWeekEndsEnabled = scheduleModel.isWeekendsEnabled
                pauseCell.configCellForTimer(title: self.profile?.profileName ?? "", timerModel: scheduleModel.pauseTimeDates)
            } else if !scheduleModel.isTimer && scheduleModel.isInitial {
                pauseCell.addTimeControl.isHidden = false
                pauseCell.timerView.isHidden = true
                pauseCell.tapGestureForTimerView.isEnabled = true
            }
            pauseCell.layoutIfNeeded()
        }*/
    }
    
    func createTopDeviceCell(profileObj:ProfileModel?) -> TopDevicesTableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: cellTopDevices) as! TopDevicesTableViewCell
        cell.setUpUIAttributes(profile: profileObj)
        cell.selectionStyle = .none
        return cell
    }

    func createDeviceListCell(currentIndexPath:IndexPath, topDevicesLabelVisible : Bool = false) -> DevicesListTableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: cellDevicesList) as! DevicesListTableViewCell
        cell.setUpDataInUI(onlineDeviceActivityData: arrOnlineActivityDeviceData, indexpath: currentIndexPath, profileStatus: self.profile?.profileStatus, topDevicesLabelShown: topDevicesLabelVisible)
        cell.selectionStyle = .none
        return cell
    }

}
extension ProfileDetailCell : PauseInternetCellDelegate
{
    func deleteScheduleTimer() {}
    
    func didTappedTimer(cell: AutomaticallyPauseInternetsTableViewCell, isWeekEnd: Bool) {
        self.tableDataSource[cell.tag]?.cellIndex = cell.tag
        self.pauseTimerEnum[cell.tag] = !isWeekEnd ? PauseTimerType.Timer : PauseTimerType.WeekendTimer
        self.tableDataSource[cell.tag]?.isInitial = false
        self.tableDataSource[cell.tag]?.isTimer = true
        self.tableDataSource[cell.tag]?.isWeekendsEnabled = isWeekEnd
        self.tableDataSource[cell.tag]?.weekEndModel.isWeekendsEnabled = isWeekEnd
        self.tableDataSource[cell.tag]?.timerModel.cellIndex = cell.tag
        guard let model = self.tableDataSource[cell.tag]  else {
            return
        }
        self.delegate?.presentPauseTimerVC(model: model)
//        UIView.animate(withDuration: 0.5) {
//            self.tblView.performBatchUpdates(nil)
//            self.tblView.reloadData()
//        }
    }
    
    func didTappedEdit(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseScheduleModel) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "HideShowSaveCancelBottomView"),object: nil))
        self.tableDataSource[cell.tag]?.cellIndex = cell.tag
        self.pauseTimerEnum[cell.tag] = !model.isWeekendsEnabled ? PauseTimerType.Timer : PauseTimerType.WeekendTimer
        self.tableDataSource[cell.tag]?.isEdit = true
        self.tableDataSource[cell.tag]?.isTimer = true
        self.tableDataSource[cell.tag]?.isWeekendsEnabled = cell.pauseOnWeekEndsEnabled
        guard let model = self.tableDataSource[cell.tag]  else {
            return
        }
        self.delegate?.presentPauseTimerVC(model: model)
//        UIView.animate(withDuration: 0.5) {
//            self.tblView.performBatchUpdates(nil)
//            self.tblView.reloadData()
//           }
    }
    
    func updateTimerData(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseTimerModel) {
        
        self.pauseTimerModels[cell.tag] = model
        self.tableDataSource[cell.tag]?.pauseTimeDates = model
        
        self.tableDataSource[cell.tag]?.timerModel.fromDate = model.fromDate
        self.tableDataSource[cell.tag]?.timerModel.toDate = model.toDate
        
        self.tableDataSource[cell.tag]?.weekEndModel.fromDate = model.fromWDate
        self.tableDataSource[cell.tag]?.weekEndModel.toDate = model.toWDate
    }
    
    func removeTimerError(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseTimerModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.tblView.performBatchUpdates(nil)
                DispatchQueue.main.async {
                    self.tblView.reloadData()
                }
            }
        }
    }
}

