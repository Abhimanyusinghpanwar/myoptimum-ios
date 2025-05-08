//
//  NetworkPointRenameViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 08/11/22.
//

import UIKit
import Lottie

protocol RenameCustomDelegate {
    func updateCellSelection()
}

class NetworkPointRenameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var renameNetworkPointTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveAndCancelView: UIView!
    @IBOutlet weak var helperView: UIView!
    var selectedText = ""
    var lastSelectedRow = -1
    var selectedNodeType : SelectedNodeType = .None
    var xtendDelegate : XtendInstallRenameVCDelegate?
    var extender: Extender?
    var gateway = MyWifiManager.shared.getMasterGatewayDetails()
    let buttonBorderColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    var networkNameList = ["Basement", "Bedroom", "Kitchen", "Office", "Laundry room", "Living room", "Custom"]
    var lastRowIndex = 6
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var buttonStackView: UIStackView!
    let emptyCell = "EmptyCell"
    var emptyCellHeight = 0
    var saveInProgress = false
    var isFromTVFlow = false
    var isXtendRaname = false
    var isCustomeRowSelected = false
    var EMPTY_CELL_HEIGHT : CGFloat {
        get {
            if selectedNodeType == .Gateway || isFromTVFlow {
                return currentScreenHeight - getHeightForCell() //(cellHeight + topSpace)
            } else {
                return 0.0
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
    
    @IBOutlet weak var saveCancelViewBottomConstraint: NSLayoutConstraint!

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        var defaultTime = 0.0
        if lastSelectedRow == lastRowIndex {
            if self.renameNetworkPointTableView.visibleCells.count < 7 {
                self.renameNetworkPointTableView.scrollToRow(at: NSIndexPath(row: lastRowIndex, section: 1) as IndexPath, at: .bottom, animated: true)
                defaultTime = 0.25
            } else {
                defaultTime = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + defaultTime) {
                let cell = self.renameNetworkPointTableView.cellForRow(at: NSIndexPath(row: self.lastRowIndex, section: 1) as IndexPath)  as! RenameCustomTableViewCell
                    cell.showSecondView()
            if let networkName = cell.networkNameTextField.text {
                if networkName.isEmpty || networkName.trimmingCharacters(in: .whitespaces).isEmpty {
                    cell.networkNameTextField.text = ""
                    cell.errorView.isHidden = false
                    cell.errorLabel.text = self.isFromTVFlow ? "Please enter a location for your Optimum Stream" : "Please enter a name for your network point"
                    cell.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
                    cell.networkNameTextField.setBorderColor(mode: .error_color)
                    cell.networkNameTextField.resignFirstResponder()
                } else if networkName.lowercased().contains("altice") || networkName.lowercased().contains("optimum") || networkName.lowercased().contains("suddenlink") || networkName.lowercased().contains("cablewifi") {
                    cell.networkNameTextField.resignFirstResponder()
                } else if networkName.hasPrefix(" ") || networkName.hasSuffix(" ") {
                    cell.networkNameTextField.resignFirstResponder()
                } else {
                    self.selectedText = networkName.replaceApostropheFromText()
                    self.saveButtonAnimation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.sendSetNodeRequest(self.selectedText)
                    }
                }
            }
        }
        } else {
            if lastSelectedRow >= 0 {
                selectedText = networkNameList[lastSelectedRow]
                self.saveButtonAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.sendSetNodeRequest(self.selectedText)
                }
            }
        }
    }
    
    func saveButtonAnimation(){
        saveInProgress = true
        buttonStackView.isHidden = true
        animationLoadingView.isHidden = false
        self.renameNetworkPointTableView.isUserInteractionEnabled = false
        viewAnimationSetUp()
    }
    
    func saveButtonAPIFailedAnimation(isSetNodeFailed:Bool) {
        DispatchQueue.main.async {
            self.saveInProgress = false
            self.renameNetworkPointTableView.isUserInteractionEnabled = true
            self.animationLoadingView.currentProgress = 3.0
            self.animationLoadingView.stop()
            self.animationLoadingView.isHidden = true
            self.buttonStackView.alpha = 0.0
            self.buttonStackView.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.buttonStackView.alpha = 1.0
            } completion: { _ in
                if isSetNodeFailed {
                    self.presentErrorMessageVC()
                } else {
                    if self.isXtendRaname {
                        self.xtendDelegate?.didClickDone()
                    }
                    else {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func sendSetNodeRequest(_ friendlyName: String) {
        var nodes = [String: AnyObject]()
        var mac = ""
        if !isFromTVFlow {
            ExtenderDataManager.shared.extenderFriendlyName = friendlyName
        }
        if selectedNodeType == .Gateway {
            if let gatewayDetails = gateway.gatewayDetails as [DeviceDetail]?, !gatewayDetails.isEmpty {
                if let deviceDetail = gatewayDetails.filter({($0).title == "MAC Address"}) as [DeviceDetail]?, !deviceDetail.isEmpty, let deviceValue = deviceDetail.first{
                    mac = deviceValue.value
                }
                
            }
        } else {
            if isFromTVFlow {
                mac = extender?.macAddress ?? ""
                if !mac.isEmpty, !mac.contains(":"), mac.count == 12 {
                    mac = WifiConfigValues.getFormattedMACAddress(mac)
                }
            } else {
                mac = extender?.macAddress ?? ""
            }
        }
        if mac.isEmpty {
            if self.isXtendRaname {
                self.xtendDelegate?.didClickDone()
            } else {
                saveButtonAPIFailedAnimation(isSetNodeFailed:false)
            }
            return
        }
        
        var strHostname = ""
        var strCategory = ""
        var strDevType = ""
        var profileId = 0
        if isFromTVFlow && MyWifiManager.shared.isTVPackage() {
            strHostname = extender?.hostname ?? ""
            strCategory = extender?.category ?? ""
            if let cmaDevType = extender?.device_type, !cmaDevType.isEmpty {
                strDevType = cmaDevType
            } else {
                strDevType = "unknown"
            }
            //strDevType = extender?.device_type ?? ""
        } else if extender?.status.lowercased() == "offline" || extender?.colorName.lowercased() == "red" {
            if let devType = extender?.device_type, !devType.isEmpty {
                strDevType = devType
            } else {
                strDevType = "unknown"
            }
            if let hostnameVal = extender?.hostname, !hostnameVal.isEmpty {
                strHostname = hostnameVal
            }
            if let categoryVal = extender?.device_type, !categoryVal.isEmpty {
                strCategory = categoryVal
            }
        } else if let nodeDetails = MyWifiManager.shared.getDeviceDetailsForMAC(mac) {
            strHostname = nodeDetails.hostname ?? ""
            strCategory = nodeDetails.cma_category ?? ""
            if let cmaNodeDevType = nodeDetails.cma_dev_type , !cmaNodeDevType.isEmpty {
                strDevType = cmaNodeDevType
            } else {
                strDevType = "unknown"
            }
            //strDevType = nodeDetails.cma_dev_type ?? ""
            profileId = nodeDetails.pid ?? 0
        }
        
        nodes["gwid"] = DeviceManager.shared.getGwidForMac(mac: mac) as AnyObject
        nodes["hostname"] = strHostname as AnyObject
        nodes["friendlyname"] = friendlyName as AnyObject
        nodes["mac"] = mac as AnyObject
        nodes["pid"] = profileId as AnyObject //No profile id for network points
        nodes["cma_category"] = strCategory as AnyObject
        nodes["cma_dev_type"] = strDevType as AnyObject
        
        var params = [String: AnyObject]()
        params["devices"] = [nodes] as AnyObject
        APIRequests.shared.initiateSetNodeRequest(nodeData: params, completionHandler: {result, error in
            if result {
                Logger.info("Set Lightspeed Node success")
                if self.isFromTVFlow && MyWifiManager.shared.isTVPackage() {
                    self.callGetAllNodes()
                } else {
                    self.callLiveTopologyAfterSetNode()
                }
            }
            else {
                Logger.info("Set Lightspeed Node failed: " + (error?.errorDescription ?? ""))
                self.saveButtonAPIFailedAnimation(isSetNodeFailed: true)
            }
        })
    }
    
    func presentErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .fullScreen
        var networkName = ""
        if selectedNodeType == .Gateway {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_NETWORK_POINT_SETTINGS_UPDATE_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])

            networkName = gateway.name
        } else {
            networkName = extender?.title ?? ""
        }
        vc.isComingFromProfileCreationScreen = false
        vc.isComingFromSpeedTestVC = true
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_networkpoint_edit_failure, subTitleMessage: networkName)
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
    
    func callGetAllNodes() {
        APIRequests.shared.getAllNodes { result in
            guard case .success(_) = result else {
                Logger.info("Get All Nodes failed after set Node")
                self.saveButtonAPIFailedAnimation(isSetNodeFailed: false)
                return
            }
            MyWifiManager.shared.refreshLTDataRequired = true
            self.saveInProgress = false
            self.stopAnimationAndDismiss()
        }
    }
    
    func stopAnimationAndDismiss() {
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                if self.isXtendRaname {
                    self.xtendDelegate?.didClickDone()
                }
                else {
                    self.animateTableviewToDown()
                }
//                self.dismiss(animated: true)
            }
        }
    }
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.animateTableviewToDown()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyCellHeight = Int(EMPTY_CELL_HEIGHT)
        //renameNetworkPointTableView.backgroundColor = onlineBgColor
        setThemeBackgroundColor()
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = buttonBorderColor.cgColor
        
        renameNetworkPointTableView.register(UINib.init(nibName: "RenameNetworkPointTableViewCell", bundle: nil), forCellReuseIdentifier: "RenameNetworkPointCell")
        renameNetworkPointTableView.register(UINib.init(nibName: "RenameNetworkListTableViewCell", bundle: nil), forCellReuseIdentifier: "RenameNetworkList")
        renameNetworkPointTableView.register(UINib.init(nibName: "RenameCustomTableViewCell", bundle: nil), forCellReuseIdentifier: "RenameCustom")
        renameNetworkPointTableView.register(UINib.init(nibName: "RenameXtendTableViewCell", bundle: nil), forCellReuseIdentifier: "RenameXtendTableViewCell")
        renameNetworkPointTableView.register(EmptyCell.self, forCellReuseIdentifier: emptyCell)
        self.renameNetworkPointTableView.dataSource = self
        self.renameNetworkPointTableView.delegate = self
                
        // Do any additional setup after loading the view.
        renameNetworkPointTableView.separatorStyle = .none
        //to fix the empty space between tableView and its cell
        self.renameNetworkPointTableView.sectionHeaderTopPadding = .zero
        self.saveAndCancelView.addTopShadow(topLight: true)
        self.saveCancelViewBottomConstraint.constant = self.selectedNodeType == .Gateway ? -self.saveAndCancelView.frame.size.height : self.saveCancelViewBottomConstraint.constant
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(NetworkPointRenameViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NetworkPointRenameViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if isFromTVFlow {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_EDIT_DEVICE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
        }
    }
    
    
    func animateTableviewToTop() {
        UIView.animate(withDuration: 0.4) {
            // this dispatch queue is added to get the correct section header animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pullDeviceListUp()
            }
        }
    }
    
    func animateTableviewToDown() {
        if selectedNodeType == .Gateway || isFromTVFlow {
            UIView.animate(withDuration: 0.8) {
                self.pushProfileListDown()
                self.animateCloseBtnViewToDown()
            } completion: { _ in
                self.dismiss(animated: false)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
    
    func pullDeviceListUp() {
        self.renameNetworkPointTableView.beginUpdates()
        self.emptyCellHeight = 0
        self.renameNetworkPointTableView.endUpdates()
    }
    
    func pushProfileListDown(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.renameNetworkPointTableView.beginUpdates()
            self.emptyCellHeight = Int(self.EMPTY_CELL_HEIGHT)
            self.renameNetworkPointTableView.endUpdates()
        }
    }

    func animateCloseBtnViewToTop(){
        UIView.animate(withDuration: 0.3) {
            self.saveCancelViewBottomConstraint.constant = UIDevice().hasNotch ? -20 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateCloseBtnViewToDown(){
        self.saveCancelViewBottomConstraint.constant = -self.saveAndCancelView.frame.size.height
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_EDIT_NETWORKPOINT_NAME.rawValue,  CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
        if selectedNodeType == .Gateway || isFromTVFlow {
            animateTableviewToTop()
            self.animateCloseBtnViewToTop()
        }
    }
    
    func setThemeBackgroundColor() {
        if isFromTVFlow {
            renameNetworkPointTableView.backgroundColor = .clear
            self.view.backgroundColor = .white
            helperView.isHidden = false
        } else if selectedNodeType == .Extender {
            renameNetworkPointTableView.backgroundColor = extender?.getThemeColor()
            self.view.backgroundColor = extender?.getThemeColor()
            
        } else {
            renameNetworkPointTableView.backgroundColor = gateway.bgColor
            self.view.backgroundColor = gateway.bgColor
        }
    }
    
    func reloadTableViewForRenameXtend() {
        isXtendRaname = true
        self.renameNetworkPointTableView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 75
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            guard let contentView =  Bundle.main.loadNibNamed("RenameSectionHeaderTableViewCell", owner: nil, options: nil) else {
                // xib not loaded, or its top view is of the wrong type
                return nil
            }
            let headerView = contentView.first as! RenameSectionHeaderTableViewCell
            if isXtendRaname {
                headerView.lblTitle.text = " Choose a name for your Extender"
            } else {
                if selectedNodeType == .Extender {
                    headerView.lblTitle.text = "Where's your Extender?"
                }
               else if MyWifiManager.shared.getWifiType() == "Gateway" {
                    headerView.lblTitle.text = "Where's your Gateway?"
                }else {
                    headerView.lblTitle.text = "Where's your Router?"
                }
                if isFromTVFlow {
                    headerView.lblTitle.text = "Where's your Optimum Stream?"
                }
              //  headerView.lblTitle.text = "Where's your \(selectedNodeType)?"
    
            }
//            headerView.lblTitle.text = "Where's your \(selectedNodeType)?"
            //To fix the disappearing of header while animating tableView list from top to bottom
            headerView.contentView.layer.cornerRadius = 10.0
            headerView.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerView.contentView.clipsToBounds = true
            return headerView.contentView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return networkNameList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return getHeightForCell()
            }
            return CGFloat(emptyCellHeight)
        } else {
            if indexPath.row < networkNameList.count - 1 {
                return 60
            } else {
                if isCustomeRowSelected {
                    return 175
                }
                return 60
            }
        }
    }
    
    func getHeightForCell() -> CGFloat {
        if isFromTVFlow {
            //CMAIOS-2143 Updated cell height
            return 155
        } else {
            if UIDevice.current.hasNotch {
                return 245
            } else {
                return 247
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return getHeightForCell()
            }
            return CGFloat(emptyCellHeight)
        } else {
            if indexPath.row < networkNameList.count - 1 {
                return 60
            } else {
                if isCustomeRowSelected {
                    return 175
                }
                return 60
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isXtendRaname == true {
                let cell = self.renameNetworkPointTableView.dequeueReusableCell(withIdentifier: "RenameXtendTableViewCell") as! RenameXtendTableViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                if indexPath.row == 0 {
                let cell = self.renameNetworkPointTableView.dequeueReusableCell(withIdentifier: "RenameNetworkPointCell") as! RenameNetworkPointTableViewCell
                cell.isUserInteractionEnabled = false
                cell.viewAnimation.isHidden = isFromTVFlow ? true : false
                cell.tvNetworkPointName.isHidden = isFromTVFlow ? false : true
                cell.tvNetworkPointIcon.isHidden = isFromTVFlow ? false : true
                    if selectedNodeType == .Gateway {
                    cell.networkStatus.text = gateway.statusText
                    cell.networkPointName.text = gateway.name
                    cell.networkStatusImage.backgroundColor = gateway.statusColor
                    cell.networkPointIcon.image = gateway.equipmentImage
                    } else {
                        if extender?.status == "Offline" {
                          cell.networkStatus.text = "Offline"
                            cell.networkStatusImage.backgroundColor = .StatusOffline
                        } else {
                            cell.networkStatus.text = extender?.getColor().status
                            cell.networkStatusImage.backgroundColor = extender?.getColor().color
                        }
                        cell.networkPointName.text = extender?.title
                        cell.tvNetworkPointName.text = extender?.title
                        cell.backgroundColor = extender?.getThemeColor()
                        cell.networkPointIcon.image = extender?.image
                        cell.tvNetworkPointIcon.image = extender?.image
                    }
                    cell.showCircleAnimation()
                    cell.selectionStyle = .none
                    return cell
                }
                else {
                    let cell = self.renameNetworkPointTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                    cell.contentView.backgroundColor = isFromTVFlow ? energyBlueRGB : .clear
                    return cell
                }
            }
        } else {
            if indexPath.row < networkNameList.count - 1 {
                let cell = self.renameNetworkPointTableView.dequeueReusableCell(withIdentifier: "RenameNetworkList") as! RenameNetworkListTableViewCell
                cell.networkName.text = networkNameList[indexPath.row]
                cell.selectionStyle = .none
                if indexPath.row == lastSelectedRow {
                    cell.networkSelectionConfirmImage.alpha = 1.0
                    cell.contentView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                } else {
                    cell.networkSelectionConfirmImage.alpha = 0.0
                    cell.contentView.backgroundColor = .white
                }
//                if indexPath.row == 5 {
//                    cell.separationView.isHidden = true
//                } else {
//                    cell.separationView.isHidden = false
//                }
                return cell
            } else {
                let cell = self.renameNetworkPointTableView.dequeueReusableCell(withIdentifier: "RenameCustom") as! RenameCustomTableViewCell
                cell.errorView.isHidden = true
                //cell.secondView.isHidden = true
                cell.customDelegate = self
                cell.updateUIFontForTV(isTv: self.isFromTVFlow)
                cell.networkNameTextField.font = UIFont(name: "Regular-Medium ", size: 18)
                if indexPath.row == lastSelectedRow {
                    cell.networkSelectionConfirmImage.alpha = 1.0
                } else {
                    cell.networkSelectionConfirmImage.alpha = 0.0
                }
                if isCustomeRowSelected {
                    cell.networkSelectionConfirmImage.alpha = 1.0
                } else {
                    cell.networkSelectionConfirmImage.alpha = 0.0
                    cell.networkNameTextField.text = ""
                    cell.networkNameTextField.setBorderColor(mode: .deselcted_color)
                    cell.errorView.isHidden = true
                    cell.hideSecondView()
                    cell.firstView.backgroundColor = .white//UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                    cell.secondView.backgroundColor = .white//UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                    cell.errorView.backgroundColor = .white//UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if lastSelectedRow != indexPath.row && lastSelectedRow == lastRowIndex {
                if let cell = tableView.cellForRow(at: NSIndexPath(row: lastRowIndex, section: 1) as IndexPath)  as? RenameCustomTableViewCell {
                    self.isCustomeRowSelected = false
                    if cell.networkSelectionConfirmImage.alpha == 1.0 {
                        cell.networkSelectionConfirmImage.alpha = 0.0
                    }
                    cell.networkNameTextField.text = ""
                    cell.networkNameTextField.setBorderColor(mode: .deselcted_color)
                    cell.errorView.isHidden = true
                    cell.hideSecondView()
                    cell.networkNameTextField.resignFirstResponder()
                    cell.firstView.backgroundColor = .white//UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                    cell.secondView.backgroundColor = .white//UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                    cell.errorView.backgroundColor = .white//UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                    self.renameNetworkPointTableView.performBatchUpdates(nil)
                }
            } else if lastSelectedRow == lastRowIndex && lastSelectedRow == indexPath.row {
                let cell = tableView.cellForRow(at: NSIndexPath(row: lastRowIndex, section: 1) as IndexPath)  as! RenameCustomTableViewCell
                self.isCustomeRowSelected = true
                if let networkName = cell.networkNameTextField.text, (networkName.isEmpty || networkName.trimmingCharacters(in: .whitespaces).isEmpty) {
                    cell.errorView.isHidden = false
                    cell.errorLabel.text = "Please enter a name for your network point"
                    cell.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
                    cell.networkNameTextField.setBorderColor(mode: .error_color)
                }
            }
            if indexPath.row < networkNameList.count - 1 {
                let cell = tableView.cellForRow(at: indexPath)  as! RenameNetworkListTableViewCell
                cell.networkSelectionConfirmImage.alpha = 1.0
                self.renameNetworkPointTableView.reloadData()
               } else {
                let cell = tableView.cellForRow(at: indexPath)  as! RenameCustomTableViewCell
                self.isCustomeRowSelected = true
                cell.networkSelectionConfirmImage.alpha = 1.0
                cell.showSecondView()
                cell.networkNameTextField.becomeFirstResponder()
                   cell.firstView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                   cell.secondView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                   cell.errorView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
                   cell.secondView.isHidden = false
                self.renameNetworkPointTableView.performBatchUpdates(nil)
            }
            lastSelectedRow = indexPath.row
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row < networkNameList.count - 1 {
                let cell = tableView.cellForRow(at: indexPath)  as! RenameNetworkListTableViewCell
                cell.networkSelectionConfirmImage.alpha = 0.0
               } else {
                   if let cell = tableView.cellForRow(at: indexPath)  as? RenameCustomTableViewCell {
                       cell.networkSelectionConfirmImage.alpha = 0.0
                   }
                self.isCustomeRowSelected = false
                  // cell.contentView.backgroundColor = .white
                   
               }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            renameNetworkPointTableView.setBottomInset(to: keyboardHeight - 100)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        renameNetworkPointTableView.setBottomInset(to: 0.0)
    }
    
}

extension NetworkPointRenameViewController: RenameCustomDelegate {
    func updateCellSelection() {
        if lastSelectedRow != lastRowIndex && lastSelectedRow != -1 {
            let indexPath = NSIndexPath(row: lastSelectedRow, section: 1)
            let cell = renameNetworkPointTableView.cellForRow(at: indexPath as IndexPath) as! RenameNetworkListTableViewCell
            if cell.networkSelectionConfirmImage.alpha == 1.0 {
                cell.networkSelectionConfirmImage.alpha = 0.0
                cell.contentView.backgroundColor = .white
            }
        }
        let indexPath = NSIndexPath(row: lastRowIndex, section: 1)
        lastSelectedRow = lastRowIndex
        let cell = renameNetworkPointTableView.cellForRow(at: indexPath as IndexPath) as! RenameCustomTableViewCell
        if cell.networkSelectionConfirmImage.alpha == 0.0 {
            cell.networkSelectionConfirmImage.alpha = 1.0
            cell.firstView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
            cell.secondView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
            cell.errorView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.941, alpha: 1)
        }
    }
}

extension UITableView {
    
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
