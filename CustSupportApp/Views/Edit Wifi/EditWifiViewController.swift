//
//  EditWifiViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 13/07/22.
//

import UIKit
import Lottie

class EditWifiViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var vwBg: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var editWifiHeaderView: UIView!
    @IBOutlet weak var editWifiTableView: UITableView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var tableViewToEditWifiHeader: NSLayoutConstraint!
    @IBOutlet weak var tableViewToTop: NSLayoutConstraint!
    @IBOutlet weak var errorTitleView: UIView!
    @IBOutlet weak var errorDescriptionView: UIView!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorDescriptionLabel: UILabel!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var editWifiLabel: UILabel!
    
    
    @IBOutlet weak var vwBgViewHeight: UIView!
    @IBOutlet weak var editHeaderViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!

    @IBOutlet weak var editHeaderViewTop: NSLayoutConstraint!
    
    var isWifiChanges = false
    var isWifiUpdated = false
    var isNetworkNameNotValid = false
    var isNetworkPasswordNotValid = false
    var isNetworkNameNotValid1 = false
    var isNetworkPasswordNotValid1 = false
    var isNetworkNameNotValidError = ""
    var isNetworkNameNotValid1Error = ""
    var count = 0
    var isResetWifiData = false
    var isWifiUpdateFailed = false
    var ssidArray = NSMutableArray()
    var lastSelectedRow = -1
    var lastSelectedField = ""
    var ssid2G = ""
    var password2G = ""
    var ssid5G = ""
    var password5G = ""
    var isOldWifiValueFor2G = false
    var isOldWifiValueFor5G = false
    var saveInProgress = false
    var isShowElipsForSSID = false
    var isShowElipsForSecondSSID = false
    var statusBarStyle = UIStatusBarStyle.lightContent
    fileprivate var overlayTapGesture: UITapGestureRecognizer!
    var qualtricsAction : DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        editWifiLabel.text = "Edit WiFi network"
        self.overlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOverlay))
        self.view?.addGestureRecognizer(self.overlayTapGesture)
        cancelButton.layer.borderColor = UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
        saveButton.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1)
        gotItButton.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1)
        editWifiHeaderView.backgroundColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1)
        vwBg.backgroundColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1)
        self.editWifiTableView.register(UINib(nibName: "EditWifiTableViewCell", bundle: nil), forCellReuseIdentifier: "WifiTableCell")
        self.editWifiTableView.register(UINib(nibName: "EditWifiConfirmTableViewCell", bundle: nil), forCellReuseIdentifier: "WifiConfirmTableCell")
        self.editWifiTableView.register(UINib(nibName: "EditWifiUpdatedTableViewCell", bundle: nil), forCellReuseIdentifier: "EditWifiUpdatedCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let firstSSID = NSMutableDictionary()
        let secondSSID = NSMutableDictionary()
        let twoGHome = NSMutableDictionary(dictionary: MyWifiManager.shared.twoGHome ?? ["":""])
        let fiveGHome = NSMutableDictionary(dictionary: MyWifiManager.shared.fiveGHome ?? ["":""])
        firstSSID.setValue(twoGHome, forKey: "2.4 GHz")
        secondSSID.setValue(fiveGHome, forKey: "5 GHz")
        ssidArray.add(firstSSID)
        if MyWifiManager.shared.isSplitSSID() {
            ssidArray.add(secondSSID)
            isShowElipsForSSID = true
            isShowElipsForSecondSSID = true
        } else {
            isShowElipsForSSID = true
            isShowElipsForSecondSSID = false
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2.0) {
                self.editWifiLabel.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        }
        self.errorDescriptionView.isHidden = true
        self.errorTitleView.isHidden = true
        if UIDevice.current.hasNotch {
            self.editHeaderViewTop.constant = UIDevice.current.topInset - 11.0
            self.bottomViewBottom.constant = -20.0
        } else {
            self.editHeaderViewTop.constant = UIDevice.current.topInset - 5.0
            self.bottomViewBottom.constant = 0.0
        }
        // Do any additional setup after loading the view.
    }
    
    func updateSpacingForSuccess() {
        // topInset - 5 
        if UIDevice.current.hasNotch {
            self.tableViewToTop.constant = UIDevice.current.topInset + 19.0
        } else {
            self.tableViewToTop.constant = UIDevice.current.topInset + 23.0
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
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
    
    @objc func tapOverlay(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.checkSSIDs()
        self.verifyPassword()
        self.editWifiTableView.reloadData()
    }
    
    @IBAction func savwWifiChanges(_ sender: UIButton) {
        checkForOldWifiDetails()
        if MyWifiManager.shared.isSplitSSID() {
            if isOldWifiValueFor5G {
                if isOldWifiValueFor2G {
                    self.qualtricsAction?.cancel()
                    self.dismiss(animated: true, completion: nil)
                    return
                }
            }
        } else {
            if isOldWifiValueFor2G {
                self.qualtricsAction?.cancel()
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        
        self.checkSSIDs()
        self.verifyPassword()
        if !isNetworkNameNotValid && !isNetworkPasswordNotValid && !isNetworkNameNotValid1 && !isNetworkPasswordNotValid1 {
            buttonStackView.isHidden = true
            animationLoadingView.isHidden = false
            self.viewAnimationSetUp()
            isWifiChanges = true
            isWifiUpdated = false
            self.editWifiTableView.reloadData()
            self.editWifiTableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: false)
            self.overlayTapGesture.isEnabled = false
            self.setParamForSetLanAPI()
        } else {
            self.editWifiTableView.reloadData()
            if isNetworkNameNotValid || isNetworkPasswordNotValid {
                self.editWifiTableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: false)
            } else {
                self.editWifiTableView.scrollToRow(at: NSIndexPath(row: 1, section: 0) as IndexPath, at: .top, animated: false)
            }
            isResetWifiData = true
        }
    }
    
    func resetWifiData() {
        if isResetWifiData {
            isResetWifiData = false
            isNetworkNameNotValid = false
            isNetworkPasswordNotValid = false
            isNetworkNameNotValid1 = false
            isNetworkPasswordNotValid1 = false
//            if ssidArray.count > 1 {
//                self.editWifiTableView.reloadData()
//            }
        }
    }
    
    func checkForOldWifiDetails() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        let firstCell = self.editWifiTableView.cellForRow(at: indexPath as IndexPath) as! EditWifiTableViewCell
        ssid2G = firstCell.networkNameTextField.text!
        password2G = firstCell.passwordTextField.text!
        if let wifiDetails = MyWifiManager.shared.twoGHome {
            if let ssid = wifiDetails.value(forKey: "SSID") as? String, !ssid.isEmpty, ssid == ssid2G, let password = wifiDetails.value(forKey: "password") as? String, !password.isEmpty, password == password2G {
                isOldWifiValueFor2G = true
            } else {
                isOldWifiValueFor2G = false
            }
        }
        if MyWifiManager.shared.isSplitSSID() {
            let indexPath1 = NSIndexPath(row: 1, section: 0)
            let secondCell = self.editWifiTableView.cellForRow(at: indexPath1 as IndexPath) as! EditWifiTableViewCell
            ssid5G = secondCell.networkNameTextField.text!
            password5G = secondCell.passwordTextField.text!
            if let wifiDetails = MyWifiManager.shared.fiveGHome {
                if let ssid = wifiDetails.value(forKey: "SSID") as? String, !ssid.isEmpty, ssid == ssid5G, let password = wifiDetails.value(forKey: "password") as? String, !password.isEmpty, password == password5G {
                    isOldWifiValueFor5G = true
                } else {
                    isOldWifiValueFor5G = false
                }
            }
        }
    }
    
    func setParamForSetLanAPI() {
        var params = [String:AnyObject]()
        self.gotItButton.isHidden = true
        saveInProgress = true
        if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary {
            params["ssid_2G"] = ssid2G as AnyObject
            params["password_2G"] = password2G as AnyObject
            params["autoChannel2g"] = networkDict.value(forKey: "autoChannel") as? AnyObject
            params["securitytype_2G"] = networkDict.value(forKey: "securityMode") as? AnyObject
        }
        if MyWifiManager.shared.isSplitSSID() {
            if let ssidArray = ssidArray.lastObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "5 GHz") as? NSMutableDictionary {
                params["ssid_5G"] = ssid5G as AnyObject
                params["password_5G"] = password5G as AnyObject
                params["autoChannel5g"] = networkDict.value(forKey: "autoChannel") as? AnyObject
                params["securitytype_5G"] = networkDict.value(forKey: "securityMode") as? AnyObject
            }
        } else {
            params["ssid_5G"] = params["ssid_2G"]
            params["password_5G"] = params["password_2G"]
            params["autoChannel5g"] = params["autoChannel2g"]
            params["securitytype_5G"] = params["securitytype_2G"]
        }
        
        APIRequests.shared.initiateSetWlanRequest(params) { success, error in
            DispatchQueue.main.async {
                self.statusBarStyle = .default
                self.setNeedsStatusBarAppearanceUpdate()
                if success {
                    self.saveInProgress = false
                    self.animationLoadingView.pause()
                    self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                            self.isWifiChanges = false
                            self.isWifiUpdated = true
                            self.editWifiTableView.reloadData()
                            self.editWifiTableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: false)
                            self.editWifiTableView.scrollsToTop = true
                            self.buttonStackView.isHidden = true
                            self.animationLoadingView.isHidden = true
                            self.gotItButton.setTitle("Got it!", for: .normal)
                            self.gotItButton.isHidden = false
                            self.editWifiHeaderView.isHidden = true
                            self.vwBg.isHidden = true
                            self.updateSpacingForSuccess()
                            self.tableViewToTop.priority = UILayoutPriority(rawValue: 999)
                            self.tableViewToEditWifiHeader.priority = UILayoutPriority(rawValue: 250)
                    }
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_EDIT_NETWORK_SUCCESS.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
                    self.addQualtrics(screenName: WiFiManagementScreenDetails.WIFI_EDIT_NETWORK_SUCCESS.rawValue)
                } else {
                        self.saveInProgress = false
                        self.animationLoadingView.currentProgress = 0.0
                        self.animationLoadingView.stop()
                        self.animationLoadingView.isHidden = true
                        self.errorDescriptionView.isHidden = false
                        self.errorTitleView.isHidden = false
                        self.isWifiChanges = false
                        self.isWifiUpdated = false
                        self.editWifiTableView.isHidden = true
                        self.buttonStackView.isHidden = true
                        self.animationLoadingView.isHidden = true
                        self.editWifiHeaderView.isHidden = true
                        self.vwBg.isHidden = true
                        self.gotItButton.setTitle("Okay", for: .normal)
                        self.gotItButton.isHidden = false
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_EDIT_NETWORK_FAIL.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
                    self.addQualtrics(screenName: WiFiManagementScreenDetails.WIFI_EDIT_NETWORK_FAIL.rawValue)
                }
            }
        }
    }
    
    func addQualtrics(screenName:String){
        self.qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    func checkSSIDs() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        let firstCell = self.editWifiTableView.cellForRow(at: indexPath as IndexPath) as! EditWifiTableViewCell
        (isNetworkNameNotValidError, isNetworkNameNotValid) = self.checkForNetworkName(wifiCell: firstCell)
        if MyWifiManager.shared.isSplitSSID() {
            let indexPath1 = NSIndexPath(row: 1, section: 0)
            let secondCell = self.editWifiTableView.cellForRow(at: indexPath1 as IndexPath) as! EditWifiTableViewCell
            (isNetworkNameNotValid1Error, isNetworkNameNotValid1) = self.checkForNetworkName(wifiCell: secondCell)
        }
    }
    
    func verifyPassword() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        let firstCell = self.editWifiTableView.cellForRow(at: indexPath as IndexPath) as! EditWifiTableViewCell
        isNetworkPasswordNotValid = checkForPassword(wifiCell: firstCell)
        if MyWifiManager.shared.isSplitSSID() {
            let indexPath1 = NSIndexPath(row: 1, section: 0)
            let secondCell = self.editWifiTableView.cellForRow(at: indexPath1 as IndexPath) as! EditWifiTableViewCell
            isNetworkPasswordNotValid1 = checkForPassword(wifiCell: secondCell)
        }
    }
    
    func checkForPassword(wifiCell: EditWifiTableViewCell) -> Bool {
        let textFieldData = wifiCell.passwordTextField.text! as NSString
        if textFieldData.hasPrefix(" ") || textFieldData.hasSuffix(" ") {
            return true
        } else if textFieldData.length > 7 {
            return false
        } else {
            return true
        }
    }
    
    func checkForNetworkName(wifiCell: EditWifiTableViewCell) -> (String,Bool) {
        let textFieldData = wifiCell.networkNameTextField.text! as NSString
        if textFieldData.length == 0 {
            return ("Please enter a name for your home WiFi Network",true)
        } else if textFieldData.hasPrefix(" ") || textFieldData.hasSuffix(" ") {
            return (SSID_SPACE_ERROR,true)
        } else if let textFieldString = textFieldData.lowercased as String?, textFieldString.contains("altice") || textFieldString.contains("optimum") || textFieldString.contains("suddenlink") || textFieldString.contains("cablewifi") {
            return (SSID_KEYWORD_ERROR, true)
        } else {
            return ("",false)
        }
    }
    
    @IBAction func cancelEditWifi(_ sender: UIButton) {
//        let transition: CATransition = CATransition()
//        transition.duration = 1.0
//        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        transition.type = .push
//        transition.subtype = .fromBottom
//        navigationController?.view.layer.add(transition, forKey: kCATransition)
//        navigationController?.popViewController(animated: true)
        self.qualtricsAction?.cancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func wifiUpdated(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            editWifiTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {

        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            editWifiTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonStackView.isHidden = false
        animationLoadingView.isHidden = true
        tableViewToTop.priority = UILayoutPriority(rawValue: 250)
        tableViewToEditWifiHeader.priority = UILayoutPriority(rawValue: 999)
//        editWifiTableView.reloadData()
//        LightSpeedAPIRequests.shared.initiateGetAllNodesRequest { success, error in
//            print(success)
//        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_EDIT_NETWORK.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS:self.classNameFromInstance])
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension EditWifiViewController: EditWifiTableViewCellDelegate {
    //Update tableView cell height by updating constraint priority
    func showErrorForSSIDPwd(selectedRow : Int, errorText : String) {
        self.editWifiTableView.beginUpdates()
        let indexPath = IndexPath(row: selectedRow, section: 0)
        let cell = self.editWifiTableView.cellForRow(at: indexPath as IndexPath) as! EditWifiTableViewCell
            if !errorText.isEmpty {
                self.showErrorLabelForUserName(cell, errorData: errorText)
            } else {
                self.hideErrorLabelForUserName(cell)
            }
        self.editWifiTableView.endUpdates()
    }
    
    func reloadRow(_ selectedRow: Int, ssidArray: NSMutableArray) {
        self.ssidArray = ssidArray
//        let indexPath = IndexPath(row: selectedRow, section: 0)
//        self.editWifiTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func resetWifiDataForEdit() {
        self.resetWifiData()
    }

    func selectedRow(_ selectedRow: Int, ssidArray: NSMutableArray, selectedField: String) {
        self.ssidArray = ssidArray
        if selectedRow == 0 && isShowElipsForSSID {
            isShowElipsForSSID = false
        } else if selectedRow == 1 && isShowElipsForSecondSSID {
            isShowElipsForSecondSSID = false
        }
//        if ssidArray.count > 1 {
//            var currentRow = 0
//            if selectedRow == 1 {
//                currentRow = selectedRow - 1
//            } else {
//                currentRow = selectedRow + 1
//            }
//            let indexPath = IndexPath(row: currentRow, section: 0)
            if lastSelectedRow == selectedRow && lastSelectedField == selectedField {
                
            } else {
                self.checkSSIDs()
                self.verifyPassword()
                self.editWifiTableView.reloadData()
                lastSelectedRow = selectedRow
                lastSelectedField = selectedField
                let indexPath = IndexPath(row: selectedRow, section: 0)
                let secondCell = self.editWifiTableView.cellForRow(at: indexPath as IndexPath) as! EditWifiTableViewCell
                if selectedField == "NetworkName" {
                    secondCell.networkNameTextField.becomeFirstResponder()
                } else {
                    secondCell.passwordTextField.becomeFirstResponder()
                }
            }
//        }
    }
    
    func showErrorLabelForUserName(_ cell: EditWifiTableViewCell, errorData: String) {
        cell.errorDescriptionView.isHidden = false
        cell.errorDescriptionLabel.text = errorData
        cell.networkNameTextField.setBorderColor(mode: .error_color)
        cell.errorDescriptionLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
        cell.errorDescriptionViewToPasswordView.priority = UILayoutPriority(rawValue: 999)
        cell.errorDescriptionViewToUsernameView.priority = UILayoutPriority(rawValue: 999)
        cell.passwordViewToNetworkNameView.priority = UILayoutPriority(rawValue: 250)
    }
    
    func showErrorLabelForPassword(_ cell: EditWifiTableViewCell) {
        let currentTextFieldData = cell.passwordTextField.text! as NSString
        if currentTextFieldData.hasPrefix(" ") || currentTextFieldData.hasSuffix(" ") {
            cell.passwordValidImageView.isHidden = true
            cell.errorLabel.text = "Your password can't start or end with a space."
            cell.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
            cell.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
            cell.errorLabelToTop.priority = UILayoutPriority(rawValue: 999)
            cell.errorLabelToLeading.priority = UILayoutPriority(rawValue: 999)
            cell.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 250)
            cell.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 250)
            return
        }
        if currentTextFieldData.length > 7 {
            cell.passwordValidImageView.isHidden = false
            cell.errorLabel.text = "Minimum 8 characters"
            cell.errorLabel.textColor = .black
            cell.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
            cell.errorLabelToTop.priority = UILayoutPriority(rawValue: 250)
            cell.errorLabelToLeading.priority = UILayoutPriority(rawValue: 250)
            cell.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 999)
            cell.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 999)
            return
        } else {
            cell.passwordValidImageView.isHidden = true
            cell.errorLabel.text = "Minimum 8 characters"
            cell.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
            cell.errorLabel.font = UIFont(name: "Regular-Regular", size: 15)
            cell.errorLabelToTop.priority = UILayoutPriority(rawValue: 999)
            cell.errorLabelToLeading.priority = UILayoutPriority(rawValue: 999)
            cell.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 250)
            cell.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 250)
            return
        }
    }
    
    func hideErrorLabelForUserName(_ cell: EditWifiTableViewCell) {
        cell.errorDescriptionView.isHidden = true
        cell.errorDescriptionLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
        cell.errorDescriptionViewToPasswordView.priority = UILayoutPriority(rawValue: 250)
        cell.errorDescriptionViewToUsernameView.priority = UILayoutPriority(rawValue: 250)
        cell.passwordViewToNetworkNameView.priority = UILayoutPriority(rawValue: 999)
    }
}

extension EditWifiViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count = ssidArray.count
        if isWifiUpdated {
            count += 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if isWifiChanges || isWifiUpdated {
            return UITableView.automaticDimension
//        }
//        return 240
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if isWifiChanges || isWifiUpdated {
            return 195
        }
        return 345
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isWifiChanges && !isWifiUpdated {
            let cell = self.editWifiTableView.dequeueReusableCell(withIdentifier: "WifiTableCell") as! EditWifiTableViewCell
            cell.selectionStyle = .none
            cell.networkNameTextField.tag = indexPath.row
            cell.passwordTextField.tag = indexPath.row
            cell.editWifiViewDelegate = self
            cell.ssidArray = ssidArray
            cell.networkNameTextField.setBorderColor(mode: .deselcted_color)
            cell.passwordTextField.setBorderColor(mode: .deselcted_color)
            hideErrorLabelForUserName(cell)
            
            if indexPath.row == 0 && ssidArray.count == 1 {
                cell.ghzLabelView.isHidden = true
                cell.separatorImageView.isHidden = true
                if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                    cell.networkNameTextField.text = networkDict.value(forKey: "SSID") as? String
                    if isShowElipsForSSID {
                    let text = cell.networkNameTextField.attributedText?.size()
                    let isOverflowing: Bool = text!.width > cell.networkNameTextField.frame.size.width
                    if isOverflowing {
                        let SSID = NSMutableString(string: networkDict.value(forKey: "SSID") as! String)
//                        SSID.insert("...", at: 10)
                        cell.networkNameTextField.text = SSID as String?
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineBreakMode = .byTruncatingMiddle
                        let attributedString = NSMutableAttributedString(string: SSID as String)
                        attributedString.addAttribute(.paragraphStyle,
                                                      value: paragraphStyle,
                                                      range:NSMakeRange(0, attributedString.length))

                        // Set the text field's attributed text as the attributed string
                        cell.networkNameTextField.attributedText = attributedString
                    } else {
                        isShowElipsForSSID = false
                    }
                }
                    cell.passwordTextField.text = networkDict.value(forKey: "password") as? String
                }
                cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 999)
                cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 250)
                showErrorLabelForPassword(cell)
            } else {
                if indexPath.row == 0 {
                    if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                        cell.ghzLabelView.isHidden = false
                        cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                        cell.networkNameTextField.text = networkDict.value(forKey: "SSID") as? String
                        if isShowElipsForSSID {
                        let text = cell.networkNameTextField.attributedText?.size()
                        let isOverflowing: Bool = text!.width > cell.networkNameTextField.frame.size.width
                        if isOverflowing {
                            let SSID = NSMutableString(string: networkDict.value(forKey: "SSID") as! String)
    //                        SSID.insert("...", at: 10)
                            cell.networkNameTextField.text = SSID as String?
                            let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.lineBreakMode = .byTruncatingMiddle
                            let attributedString = NSMutableAttributedString(string: SSID as String)
                            attributedString.addAttribute(.paragraphStyle,
                                                          value: paragraphStyle,
                                                          range:NSMakeRange(0, attributedString.length))

                            // Set the text field's attributed text as the attributed string
                            cell.networkNameTextField.attributedText = attributedString
                        } else {
                            isShowElipsForSSID = false
                        }
                    }
                        cell.passwordTextField.text = networkDict.value(forKey: "password") as? String
                        showErrorLabelForPassword(cell)
                    }
                } else {
                    if let ssidArray = ssidArray.lastObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "5 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                        cell.ghzLabelView.isHidden = false
                        cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                        cell.networkNameTextField.text = networkDict.value(forKey: "SSID") as? String
                        if isShowElipsForSecondSSID {
                        let text = cell.networkNameTextField.attributedText?.size()
                        let isOverflowing: Bool = text!.width > cell.networkNameTextField.frame.size.width
                        if isOverflowing {
                            let SSID = NSMutableString(string: networkDict.value(forKey: "SSID") as! String)
    //                        SSID.insert("...", at: 10)
                            cell.networkNameTextField.text = SSID as String?
                            let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.lineBreakMode = .byTruncatingMiddle
                            let attributedString = NSMutableAttributedString(string: SSID as String)
                            attributedString.addAttribute(.paragraphStyle,
                                                          value: paragraphStyle,
                                                          range:NSMakeRange(0, attributedString.length))

                            // Set the text field's attributed text as the attributed string
                            cell.networkNameTextField.attributedText = attributedString
                        } else {
                            isShowElipsForSecondSSID = false
                        }
                    }
                        cell.passwordTextField.text = networkDict.value(forKey: "password") as? String
                        showErrorLabelForPassword(cell)
                    }
                }
                cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 250)
                cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 999)
                if indexPath.row == count - 1 {
                    cell.separatorImageView.isHidden = true
                } else {
                    cell.separatorImageView.isHidden = false
                }
            }
            if indexPath.row == 0 {
                if isNetworkNameNotValid {
                    showErrorLabelForUserName(cell, errorData: isNetworkNameNotValidError)
                } else {
                    hideErrorLabelForUserName(cell)
                }
                if isNetworkPasswordNotValid {
                    cell.passwordTextField.setBorderColor(mode: .error_color)
                }
            }
            
            if ssidArray.count == 2 && indexPath.row == 1 {
                if isNetworkNameNotValid1 {
                    showErrorLabelForUserName(cell, errorData: isNetworkNameNotValid1Error)
                } else {
                    hideErrorLabelForUserName(cell)
                }
                if isNetworkPasswordNotValid1 {
                    cell.passwordTextField.setBorderColor(mode: .error_color)
                }
            }
            return cell
        } else {
//            let cell = self.editWifiTableView.dequeueReusableCell(withIdentifier: "WifiConfirmTableCell") as! EditWifiConfirmTableViewCell
            if isWifiUpdated {
                if indexPath.row == 0 {
                    let cell = self.editWifiTableView.dequeueReusableCell(withIdentifier: "EditWifiUpdatedCell") as! EditWifiUpdatedTableViewCell
                    cell.selectionStyle = .none
                    return cell
                } else {
                    let cell = self.editWifiTableView.dequeueReusableCell(withIdentifier: "WifiConfirmTableCell") as! EditWifiConfirmTableViewCell
                    if indexPath.row == 1 && ssidArray.count == 1 {
                        cell.ghzLabel.isHidden = true
                        cell.lineSeparationView.isHidden = true
                        cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 999)
                        cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 250)
                        if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                            cell.networkNameTextLabel.text = networkDict.value(forKey: "SSID") as? String
                            cell.passwordTextLabel.text = networkDict.value(forKey: "password") as? String
                        }
                    } else {
                        if indexPath.row == 1 {
                            cell.ghzLabel.isHidden = false
                            cell.lineSeparationView.isHidden = false
                            cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 250)
                            cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 999)
                            if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                                cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                                cell.networkNameTextLabel.text = networkDict.value(forKey: "SSID") as? String
                                cell.passwordTextLabel.text = networkDict.value(forKey: "password") as? String
                            }
                        } else {
                            cell.ghzLabel.isHidden = false
                            cell.lineSeparationView.isHidden = true
                            cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 250)
                            cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 999)
                            if let ssidArray = ssidArray.lastObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "5 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                                cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                                cell.networkNameTextLabel.text = networkDict.value(forKey: "SSID") as? String
                                cell.passwordTextLabel.text = networkDict.value(forKey: "password") as? String
                            }
                        }
                    }
                    cell.selectionStyle = .none
                    return cell
                }
            } else {
                let cell = self.editWifiTableView.dequeueReusableCell(withIdentifier: "WifiConfirmTableCell") as! EditWifiConfirmTableViewCell
                if indexPath.row == 0 && ssidArray.count == 1 {
                    cell.ghzLabel.isHidden = true
                    cell.lineSeparationView.isHidden = true
                    cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 999)
                    cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 250)
                    if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                        cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                        cell.networkNameTextLabel.text = networkDict.value(forKey: "SSID") as? String
                        cell.passwordTextLabel.text = networkDict.value(forKey: "password") as? String
                    }
                } else {
                    if indexPath.row == 0 {
                        cell.ghzLabel.isHidden = false
                        cell.lineSeparationView.isHidden = false
                        cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 250)
                        cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 999)
                        if let ssidArray = ssidArray.firstObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "2.4 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                            cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                            cell.networkNameTextLabel.text = networkDict.value(forKey: "SSID") as? String
                            cell.passwordTextLabel.text = networkDict.value(forKey: "password") as? String
                        }
                    } else {
                        cell.ghzLabel.isHidden = false
                        cell.lineSeparationView.isHidden = true
                        cell.networkNameTopSpace.priority = UILayoutPriority(rawValue: 250)
                        cell.networkNameTopSpaceToLabel.priority = UILayoutPriority(rawValue: 999)
                        if let ssidArray = ssidArray.lastObject, let ssidDict = ssidArray as? NSMutableDictionary, !ssidDict.allKeys.isEmpty, let networkDict = ssidDict.value(forKey: "5 GHz") as? NSMutableDictionary, !networkDict.allKeys.isEmpty {
                            cell.ghzLabel.text = ssidDict.allKeys[0] as? String
                            cell.networkNameTextLabel.text = networkDict.value(forKey: "SSID") as? String
                            cell.passwordTextLabel.text = networkDict.value(forKey: "password") as? String
                        }
                    }
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
}
