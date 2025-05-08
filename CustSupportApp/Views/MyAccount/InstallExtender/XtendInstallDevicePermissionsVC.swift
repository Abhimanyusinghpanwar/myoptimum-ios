//
//  XtendInstallDevicePermissionsVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/21/22.
//  GA-

import UIKit
import Network

class XtendInstallDevicePermissionsVC: BaseViewController {
    
    @IBOutlet weak var devicePermissionImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var devicePermissionImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var devicePermissionPrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var devicePermissionHeaderLbl: UILabel!
//    @IBOutlet weak var devicePermissionBodyLbl: UILabel!
    var count = 0
    var networkStatus = "nil"
    var timer: Timer?
    var isLANPermissionGiven: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        udpateDevicePermissionUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_local_network_privacy_permission.extenderTitleWifi6, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func udpateDevicePermissionUI() {
//        devicePermissionBodyLbl.attributedText = getBodyLabelAtrributedText()
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            devicePermissionHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            devicePermissionImageViewLeadingConstraint.constant = 30.0
            devicePermissionImageViewTrailingConstraint.constant = 30.0
            devicePermissionHeaderLbl.setLineHeight(1.21)
        } else {
            devicePermissionHeaderLbl.setLineHeight(1.15)
        }
    }
    
    func getBodyLabelAtrributedText() -> NSAttributedString {
        
        let attributedStr = NSMutableAttributedString.init(string:"")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.21
        let boldFont = UIFont(name: "Regular-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        let font = UIFont(name: "Regular-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let atrText = "When you see the prompt, tap Allow"
        let lineText = "\nso that we can tell you right away if your Extender is in a good or bad spot."
        attributedStr.append(NSMutableAttributedString.init(string:atrText ,attributes: [NSAttributedString.Key.font : boldFont, .paragraphStyle: paragraphStyle]))
        attributedStr.append(NSMutableAttributedString.init(string:lineText ,attributes: [NSAttributedString.Key.font : font, .paragraphStyle: paragraphStyle]))
        
        return attributedStr
    }
    
    @IBAction func devicePermissionPrimaryBtn(_ sender: Any) {
        checkLocalNetworkConnection()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {(timer)  in
            if (UIApplication.shared.applicationState == .active) && (self.networkStatus == "Local Network denied") {
                self.checkLocalNetworkConnection()
            }
        })
    }
    
//    @IBAction func devicePermissionBackBtn(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func devicePermissionCancelBtn(_ sender: Any) {
//        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
//            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
//            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
//                cancelVC.modalPresentationStyle = .fullScreen
//                self.navigationController?.pushViewController(cancelVC, animated: true)
//            }
//        } else{
//            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
//            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
//                cancelVC.modalPresentationStyle = .fullScreen
//                self.present(cancelVC, animated: true)
//            }
//        }
//    }
    
    func checkLocalNetworkConnection() {
        Logger.warning("The Local network check started....")
        let connection = NWConnection(host: "192.168.1.1", port: 0, using: .tcp)
        
        connection.pathUpdateHandler = { latestPath in
            
            if #available(iOS 14.2, *) {
                Logger.warning("The Local network unstatisfied reason due to \(latestPath.unsatisfiedReason)!")
                switch latestPath.unsatisfiedReason {
                case .localNetworkDenied:
                    self.networkStatus = "Local Network denied"
                    if self.count == 0 {
                        self.isLANPermissionGiven = false
                        PreferenceHandler.saveValue(self.isLANPermissionGiven, forKey: "localNetwork")
                        self.count += 1
                    }
                    else {
                        self.timer?.invalidate()
                        self.timer = nil
                        self.navigateToNextScreen(identifier: "xtendPlacementHelpWiFiWorksBestVC", connectionState: connection)
                    }
                case .notAvailable:
                    self.timer?.invalidate()
                    self.timer = nil
                    self.networkStatus = "Local network available"
                    self.isLANPermissionGiven = true
                    PreferenceHandler.saveValue(self.isLANPermissionGiven, forKey: "localNetwork")
                    if ((connection.currentPath?.debugDescription.range(of: ("unsatisfied (No network route)"))) != nil){
                        Logger.info("No LAN network")
                        self.navigateToNextScreen(identifier: "xtendPlacementHelpWiFiWorksBestVC", connectionState: connection)
                    } else {
                        self.navigateToNextScreen(identifier: "proactivePlacementViewController", connectionState: connection)
                    }
                case .cellularDenied:
                    self.networkStatus = "Cellular denied"
                case .wifiDenied:
                    self.networkStatus = "WiFi Denied"
                @unknown default:
                    self.networkStatus = "Other"
                }
            } else {
                // Fallback on earlier versions
            }
            Logger.info(connection.debugDescription, sendLog: "Local Network check")
        }
        connection.start(queue: .main)
    }
    
    func navigateToNextScreen(identifier: String, connectionState: NWConnection) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        connectionState.cancel()
        Logger.warning("Connection canceled with \(connectionState.debugDescription)")
    }
}
