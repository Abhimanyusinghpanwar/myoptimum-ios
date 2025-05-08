//
//  XtendConnectToHomeNetworkVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/16/22.
//  GA-extender6_proactive_placement_connect_to_home_network

import UIKit
import Network

class XtendConnectToHomeNetworkVC: BaseViewController {
    
    @IBOutlet weak var xtendConnectToHomeHeaderLbl: UILabel!
    @IBOutlet weak var networkNameValueLbl: UILabel!
    @IBOutlet weak var networkPasswordValueLbl: UILabel!
    @IBOutlet weak var bodyContentView: UIView!
    @IBOutlet weak var bodyContentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyContentViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectToHomeBottomStackViewBottomConstraint: NSLayoutConstraint!
    weak var delegate: LocalNetworkConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendConnectToHomeUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_connect_to_home_network.extenderTitleWifi6, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }

    func updateXtendConnectToHomeUI() {
        
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendConnectToHomeHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            bodyContentViewLeadingConstraint.constant = 30.0
            bodyContentViewTrailingConstraint.constant = 30.0
            xtendConnectToHomeHeaderLbl.setLineHeight(1.21)
        } else {
            xtendConnectToHomeHeaderLbl.setLineHeight(1.15)
        }
        bodyContentView.layer.borderColor = UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1).cgColor
        bodyContentView.layer.cornerRadius = 12
        bodyContentView.layer.borderWidth = 1
        
        if let wifi = MyWifiManager.shared.fiveGHome, wifi.allKeys.count > 0 {
            if let ssid = wifi.value(forKey: "SSID") as? String, !ssid.isEmpty,
               let password = wifi.value(forKey: "password") as? String, !password.isEmpty {
                self.networkNameValueLbl.text = ssid
                self.networkPasswordValueLbl.text = password
            }
        } else {
            self.bodyContentView.isHidden = true
        }
    }
    
    @IBAction func connectedToHomeNetworkBtn(_ sender: Any) {
        
        let isPermissionGiven = PreferenceHandler.getValuesForKey("localNetwork")
        if isPermissionGiven == nil {
            checkCellularNetwork()
        } else {
            checkLANFromHomeNetworkVC()
        }
        ExtenderDataManager.shared.extenderHomeNetwork = true
    }
    
    @IBAction func installWithoutHomeNetworkBtn(_ sender: Any) {
        Logger.info("Not connected to Home Network button clicked...")
        ExtenderDataManager.shared.extenderHomeNetwork = false
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpWiFiWorksBestVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkLANFromHomeNetworkVC() {
        let connection = NWConnection(host: "192.168.1.1", port: 0, using: .tcp)
        if sharedConnection != nil  {
            sharedConnection?.cancel()
        }
        sharedConnection = LocalNetworkConnection(delegate: self, localConnection: connection, connectionStarted: true)
    }
    
    func navigateToNextScreen(identifier: String) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkCellularNetwork() {
        let wifiNetwork = NWPathMonitor(requiredInterfaceType: .wifi)
        wifiNetwork.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.navigateToNextScreen(identifier: "xtendInstallDevicePermissionsVC")
            } else {
                self.navigateToNextScreen(identifier: "xtendPlacementHelpWiFiWorksBestVC")
                ExtenderDataManager.shared.extenderHomeNetwork = false
            }
            wifiNetwork.cancel()
        }
        wifiNetwork.start(queue: .main)
    }
}

extension XtendConnectToHomeNetworkVC: LocalNetworkConnectionDelegate {
    func localConnection(isAvailable: Bool, error: NWError?) {
        sharedConnection?.cancel()
        var identifier = ""
        if isAvailable == true {
            identifier = "proactivePlacementViewController"
        } else {
            if (error == NWError.posix(.ENETDOWN)) {
                identifier = "xtendPlacementHelpWiFiWorksBestVC"
                ExtenderDataManager.shared.extenderHomeNetwork = false
            } else {
                identifier = "xtendInstallDeviceSettingsVC"
            }
        }
        navigateToNextScreen(identifier: identifier)
    }
}
