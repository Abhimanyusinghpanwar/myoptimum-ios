//
//  EditConnectedDeviceDetailsViewController.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 08/11/22.
//

import UIKit
import Lottie

protocol UpdatedDeviceDetailsData {
    func getUpdatedDeviceDetails(deviceName:String, deviceType:String)
}

class EditConnectedDeviceDetailsViewController: UIViewController, UITextFieldDelegate ,UpdateDeviceDetails{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deviceNameTextField: FloatLabelTextField!
    @IBOutlet weak var deviceTableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    @IBOutlet var seperator: UIView!
    @IBOutlet weak var viewDeviceName: UIView!
    var isForRecentlyDisconnected: Bool = false
    @IBOutlet weak var customHeaderView: UIView!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var buttonStackView: UIStackView!
    var saveInProgress = false

    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    var delegate: UpdatedDeviceDetailsData?
    @IBOutlet weak var deviceIconBottom: NSLayoutConstraint!
    @IBOutlet weak var tableviewTop: NSLayoutConstraint!
    
    @IBOutlet weak var tableTopAlign: NSLayoutConstraint!
    var delegateforDeviceAnimation : HandlingPopUpAnimation?
    var passingImag: UIImage?
    var deviceType: String = ""
    var deviceName: String = ""
    var categoryName = ""
    var connectedDevice: ConnectedDevice!
    var checkIndex = 0
    var collectionItemIndex : IndexPath? = nil
    @IBOutlet weak var bottomView: UIView!
    
    var sectionNames = ["Personal and Computer", "Gaming", "Entertainment", "Home", "Security", "Other"]
    var personalandhome = ["tablet", "phone", "desktop", "laptop", "watch"]
    var gaming = ["game"]
    var Entertainment = ["streaming","TV"]
    var Home = ["lightbulb", "thermostat", "printer", "bike", "speaker", "vacuum"]
    var security = ["camera","doorbell", "doorlock","alarm", "smartplug"]
    var other = ["unknown"]

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        configureUI()
        self.errorLabel.isHidden = true
        deviceTableView.register(UINib.init(nibName: "EditConnectedDeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "EditConnectedDeviceTableViewCell")
        deviceTableView.tableFooterView = UIView()
        self.deviceTableView.separatorStyle = .none
        self.deviceTableView.dataSource = self
        self.deviceTableView.delegate = self
        bottomViewBottomConstraint.constant = UIDevice().hasNotch ? 12 : 0
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        deviceNameTextField.delegate = self
        resetSearchField()
        self.view.backgroundColor = energyBlueRGB
        deviceNameTextField.layoutIfNeeded()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME : WiFiManagementScreenDetails.WIFI_EDIT_DEVICE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.hasNotch {
            tableTopAlign.constant = 0
        }
    }
    
    func configureUI() {
        imageView.image = passingImag?.aspectFitImage(inRect: imageView.frame)
        imageView.contentMode = .scaleAspectFit
        deviceNameTextField.text = deviceName
        secondaryAction.isHidden = false
        primaryAction.layer.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1).cgColor
        primaryAction.setTitle("Save", for: .normal)
        secondaryAction.setTitle("Cancel", for: .normal)
        primaryAction.setTitleColor(.white, for: .normal)
        secondaryAction.setTitleColor(.black, for: .normal)
        secondaryAction.layer.borderWidth = 2
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        self.bottomView.addTopShadow(topLight: true)
        seperator.backgroundColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 0.5)
        deviceIconBottom.constant = 30
    }
        
    @objc func handleKeyboardWillHide(notification: Notification) {
        if deviceNameTextField.getBorderColor() == .selected_color {
            deviceNameTextField.setBorderColor(mode: .deselcted_color)
            changePlaceholderColor(textField: deviceNameTextField, color: .placeholderText)
        }
        guard let text = deviceNameTextField.text else { return }
        validateSearchText(search: text)
    }
    
    func validateSearchText(search: String) {
        if search.count == 0 {
            showErrorWithString(errString: "Please enter a name for your Device")
            changePlaceholderColor(textField: deviceNameTextField, color: UIColor.init(red: 234/255, green: 0/255, blue: 42/255, alpha: 1.0))
        } else if search.hasPrefix(" ") || search.hasSuffix(" ") {
            showErrorWithString(errString: "Your Device name can’t start or end with a space.")
            changePlaceholderColor(textField: deviceNameTextField, color: UIColor.init(red: 234/255, green: 0/255, blue: 42/255, alpha: 1.0))
        } else if search.count > 0 {
            deviceNameTextField.setBorderColor(mode: .selected_color)
            changePlaceholderColor(textField: deviceNameTextField, color: .placeholderText)
            hideError()
        }else {
            resetSearchField()
        }
    }
    
    func resetSearchField() {
        deviceNameTextField.setBorderColor(mode: .deselcted_color)
        changePlaceholderColor(textField: deviceNameTextField, color: .placeholderText)
    }
    
    func hideError() {
        self.errorLabel.text = nil
        self.errorLabel.isHidden = true
    }
    
    func showErrorWithString(errString: String) {
        self.errorLabel.isHidden = false
        self.errorLabel.text = errString
        self.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
        self.deviceNameTextField.setBorderColor(mode: .error_color)
        self.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
        changePlaceholderColor(textField: deviceNameTextField, color: UIColor.init(red: 234/255, green: 0/255, blue: 42/255, alpha: 1.0))
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
    func sendDataFromCollectionview(deviceName deviceType: String, categoryName: String, sendIndex: Int, differentIndex: IndexPath) {
        self.deviceType = deviceType
        self.categoryName = categoryName
        self.checkIndex = sendIndex
        self.collectionItemIndex = differentIndex
        self.deviceTableView.reloadData()
       }
    @IBAction func onTapAction(_ sender: UIButton) {
        guard sender == primaryAction else {
            //self.dismiss(animated: true)
            UIView.animate(withDuration: 0.8) { [self] in
                self.delegateforDeviceAnimation?.animatedVCGettingDismissed(with: self.imageView.image!)
                //dismiss without animation
                self.dismiss(animated: false)
            }
            return
        }
        if !isValidName(search: deviceNameTextField.text ?? "").1 {
            return
        }
        saveInProgress = true
        buttonStackView.isHidden = true
        animationLoadingView.isHidden = false
        viewAnimationSetUp()
        if self.isValidName(search: deviceNameTextField.text ?? "").1 {
            var nodes = [String: AnyObject]()
            let mac = WifiConfigValues.getFormattedMACAddress(self.connectedDevice.macAddress)
            if mac.isEmpty {
                return
            }
            let editedName = self.deviceNameTextField.text?.replaceApostropheFromText()
            nodes["friendlyname"] = editedName as AnyObject? //self.deviceNameTextField.text as AnyObject
            nodes["mac"] = self.connectedDevice.macAddress as AnyObject
            nodes["pid"] = self.connectedDevice.pid as AnyObject
    
            var hostName = ""
            var gwid = ""
            if let devices = DeviceManager.shared.devices, !devices.isEmpty {
                if self.categoryName.isEmpty {
                    self.categoryName = DeviceManager.shared.getCMA_CategoryForMac(mac: mac)
                }
                hostName = DeviceManager.shared.getHostnameForMac(mac: mac)
                let deviceType = DeviceManager.shared.getCMA_DeviceTypeForMac(mac: mac)
                if self.deviceType.isEmpty {
                    if  !deviceType.isEmpty {
                        self.deviceType = deviceType
                    } else {
                        self.deviceType = "unknown"
                    }
                }
                gwid = DeviceManager.shared.getGwidForMac(mac: mac)
            } else {
                guard let LT_deviceDetails = MyWifiManager.shared.getDeviceDetailsForMAC(mac) else {
                    self.saveButtonAPIFailedAnimation(isSetNodeFailed: true)
                    Logger.info("Edit device details failed due to device details not found!")
                    return
                }
                if self.categoryName.isEmpty {
                    if let LT_deviceCategory = LT_deviceDetails.cma_category, !LT_deviceCategory.isEmpty {
                        self.categoryName  = LT_deviceCategory
                    }
                }
                if let LT_hostName = LT_deviceDetails.hostname, !LT_hostName.isEmpty {
                    hostName = LT_hostName
                }
                if self.deviceType.isEmpty {
                   if let LT_deviceType = LT_deviceDetails.device_type, !LT_deviceType.isEmpty {
                       self.deviceType  = LT_deviceType
                   } else {
                       self.deviceType  = "unknown"
                   }
                }
                gwid = MyWifiManager.shared.deviceMAC ?? ""
            }
            nodes["hostname"] = hostName as AnyObject
            nodes["cma_category"] = self.categoryName.lowercased() as AnyObject
            nodes["cma_dev_type"] = self.deviceType.lowercased() as AnyObject
            nodes["hostname"] = hostName as AnyObject
            nodes["gwid"] = gwid as AnyObject
            var params = [String: AnyObject]()
            params["devices"] = [nodes] as AnyObject
            APIRequests.shared.initiateSetNodeRequest(nodeData: params, completionHandler: {success, error in
                if success {
                    Logger.info("Set Lightspeed Node success")
                    MyWifiManager.shared.refreshLTDataRequired = true
                    self.callGetAllNodes()
                    self.saveDeviceDetailsLocally()
                    //self.callLiveTopologyAfterSetNode()
                }
                else{
                    self.saveButtonAPIFailedAnimation(isSetNodeFailed: true)
                    Logger.info("Set Lightspeed Node failed: " + (error?.errorDescription ?? ""))
                }
            })
        }
    }
    
    
    func saveDeviceDetailsLocally() {
        if isForRecentlyDisconnected {
            MyWifiManager.shared.saveDeviceChangeLocallyDisconnectedDevices(for: self.connectedDevice.macAddress, deviceName: self.deviceNameTextField.text, deviceType: self.deviceType.lowercased(),category: self.categoryName)
        } else {
            MyWifiManager.shared.saveDeviceChangeLocally(for: self.connectedDevice.macAddress, deviceName: self.deviceNameTextField.text, deviceType: self.deviceType.lowercased(),category: self.categoryName)
        }
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
                self.delegate?.getUpdatedDeviceDetails(deviceName: self.deviceNameTextField.text ?? "", deviceType: self.deviceType)
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
                self.delegateforDeviceAnimation?.animatedVCGettingDismissed(with: self.imageView.image!)
                //dismiss without animation
                self.dismiss(animated: false)
            }
        }
    }
    
    func saveButtonAPIFailedAnimation(isSetNodeFailed:Bool) {
        DispatchQueue.main.async {
            self.saveInProgress = false
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
                    //self.dismiss(animated: true)
                    self.delegateforDeviceAnimation?.animatedVCGettingDismissed(with: self.imageView.image!)
                    //dismiss without animation
                    self.dismiss(animated: false)
                }
            }
        }
    }
    
    func presentErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .custom
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_node_edit_device_name_failure)
        vc.isComingFromEditDeviceNameVC = true
        vc.isComingFromProfileCreationScreen = false
        self.present(vc, animated: true)
    }
    
    func isValidName(search: String) -> (String, Bool) {
        if search.count == 0 {
            return ("Please enter a name for your Device", false)
        } else if search.hasPrefix(" ") || search.hasSuffix(" ") {
            return ("Your Device name can’t start or end with a space.", false)
        } else if search.count > 0 {
            return ("", true)
        }else {
            resetSearchField()
            return ("", false)
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
        if textField == deviceNameTextField {
            deviceNameTextField.setBorderColor(mode: .selected_color)
            changePlaceholderColor(textField: deviceNameTextField, color: .placeholderText)
            }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharacters = 32
        let currentTextFieldData = textField.text! as NSString
        let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 0 && newString.length <= 32 {
            validateSearchText(search: newString as String)
        }
        if newString.length > 32 {
            if let lastChar = UnicodeScalar(newString.character(at: 31)), lastChar == " " {
                return false
            }else if let firstChar = UnicodeScalar(newString.character(at: 0)), firstChar == " ", let lastChar = UnicodeScalar(newString.character(at: 1)), lastChar == " " {
                return false
            }
        }
        return newString.length <= maxCharacters
    }
    
    func changePlaceholderColor(textField: FloatLabelTextField, color: UIColor) {
        let placeholderText = "Device Name"
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getDevicesOnTheBasisOfCurrentRow(rowNumber: Int) ->[String]{
        switch(rowNumber)
        {
        case 0:
            return personalandhome
        case 1:
            return gaming
        case 2:
            return Entertainment
        case 3:
            return Home
        case 4:
            return security
        default:
            return other
        }
    }
}

extension EditConnectedDeviceDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionNames.count != 0
        {
            return sectionNames.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let arrayOfDevices = getDevicesOnTheBasisOfCurrentRow(rowNumber: indexPath.row)
        var height = 0.0
        if UIScreen.main.bounds.height >= 852.0 {
            height = arrayOfDevices.count > 3 ? 359 : 214
        } else {
            height = arrayOfDevices.count > 3 ? 339 : 203
        }
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditConnectedDeviceTableViewCell") as! EditConnectedDeviceTableViewCell
        cell.selectionStyle = .none
        if indexPath.row == self.sectionNames.count - 1 {
            cell.cellSaperatorView.isHidden = true
        } else {
            cell.cellSaperatorView.isHidden = false
            cell.cellSaperatorView.backgroundColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
        }
        cell.sectionName.text = sectionNames[indexPath.row]
        cell.categoryName = sectionNames[indexPath.row]
        cell.delegate = self
        cell.devicesFrom = getDevicesOnTheBasisOfCurrentRow(rowNumber : indexPath.row)
        cell.collectionview.tag = indexPath.row
        if indexPath.row != self.checkIndex
        {
            cell.selectedIndex = nil
        }
        else
        {
            cell.selectedIndex = self.collectionItemIndex
        }
        cell.collectionview.reloadData()
        cell.layoutIfNeeded()
        return cell
    }
}
