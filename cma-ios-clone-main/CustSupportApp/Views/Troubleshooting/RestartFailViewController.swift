//
//  RestartFailViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 20/01/23.
//

import UIKit
import Lottie
class RestartFailViewController: UIViewController {
    
    @IBOutlet weak var mainView: LottieAnimationView!
    @IBOutlet weak var letsTryLabel: UILabel!
    @IBOutlet weak var gatewayLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var routerImage: UIImageView!
    @IBOutlet weak var letsDoitButton: RoundedButton!
    @IBOutlet weak var mayBeLaterButton: RoundedButton!
    @IBOutlet weak var buttonsBgView: UIView!
    @IBOutlet weak var gatewayImage: UIImageView!
    @IBOutlet weak var gatewayNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    var isRestartSuccess = false
    var isFromManualRestart = false
    var deviceName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.gatewayLabel.font = UIFont(name: "Regular-Bold", size: 24)
        self.letsTryLabel.isHidden = false
        self.buttonsBgView.isHidden = false
        self.deviceName = (MyWifiManager.shared.getWifiType() == "Gateway") ? self.deviceName : (isRestartSuccess ? self.deviceName : self.deviceName.lowercased())
        if !isRestartSuccess {
            if MyWifiManager.shared.getWifiType() == "Gateway" {
                self.hideUnhideRouterDetails(isHidden: true)
                self.hideUnhideGateWayDetails(isHidden: false)
                self.showOfflineForGateway()
            } else {
                self.hideUnhideRouterDetails(isHidden: false)
                self.hideUnhideGateWayDetails(isHidden: true)
            }
            self.showFailureUI()
        } else {
            RequestBuilder.cancelAllRequests()
            if MyWifiManager.shared.getWifiType() == "Gateway" {
                self.hideUnhideRouterDetails(isHidden: true)
                self.hideUnhideGateWayDetails(isHidden: false)
                self.seggregateGatewayData()
            } else {
                self.hideUnhideRouterDetails(isHidden: false)
                self.hideUnhideGateWayDetails(isHidden: true)
            }
            self.showSuccessUI()
        }
    }
    
    func showOfflineForGateway() {
        let masterDetails = MyWifiManager.shared.getMasterGatewayDetails()
        if !masterDetails.name.isEmpty {
            gatewayNameLabel.text = masterDetails.name
            self.statusLabel.text = "Offline"
            self.statusImage.backgroundColor = UIColor.StatusOffline
            if let imageName = masterDetails.equipmentImage as UIImage? {
                self.gatewayImage.image = imageName
            } else {
                self.gatewayImage.image = UIImage(named: "icon_wifi_white")
            }
        }
    }
    
    func showSuccessUI() {
        self.mainView.backgroundColor = energyBlueRGB
        self.showRestartUI(isHidden: false)
        self.gatewayLabel.text = "\(deviceName) is back online"
        if MyWifiManager.shared.isFromSpeedTest {
            self.letsTryLabel.text = "Let's see if that improved your speed."
            self.letsDoitButton.setTitle("Let's do it", for: .normal)
            self.mayBeLaterButton.setTitle("Maybe later", for: .normal)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.RESTART_IMPROVESPEED_GATEWAY_BACK_ONLINE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        } else {
            self.letsTryLabel.text = "Did that fix your problem?"
            self.letsDoitButton.setTitle("Yes, my Internet works now", for: .normal)
            self.mayBeLaterButton.setTitle("No, I'm still experiencing an issue", for: .normal)
            if !isFromManualRestart {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.RESTART_GATEWAY_BACK_ONLINE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            } else {
                if MyWifiManager.shared.getWifiType() == "Equipment" {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_EQUIPMENT_BACKONLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                } else {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_MODEM_BACKONLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                }
            }
        }
    }
    
    //CMAIOS-2288, CMAIOS-2289, CMAIOS-2291
    func trackGATagOnClickEvent(eventLinkText:String, eventScreenName: String){
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : eventLinkText,
                        EVENT_SCREEN_NAME:eventScreenName ,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue]
        )
    }
    
    func showRestartUI(isHidden: Bool) {
        self.gatewayLabel.isHidden = isHidden
        self.letsTryLabel.isHidden = isHidden
        self.letsDoitButton.isHidden = isHidden
        self.mayBeLaterButton.isHidden = isHidden
    }
    
    func showFailureUI() {
        self.mainView.backgroundColor = midnightBlueRGB
        self.showRestartUI(isHidden: false)
        if !isFromManualRestart {
            self.gatewayLabel.text = "We’re not able to restart your \(deviceName) automatically"
            self.letsTryLabel.text = "Let’s try a manual restart."
            self.letsDoitButton.setTitle("Let’s do it", for: .normal)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.SYSTEMIC_RESTART_GATEWAY_OFFLINE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        } else {
            if MyWifiManager.shared.getWifiType() == "Gateway" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GATEWAY_OFFLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
            } else if MyWifiManager.shared.getWifiType() == "Equipment" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_EQUIPMENT_NOT_BACKONLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_MODEM_NOT_BACKONLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            }
            self.gatewayLabel.text = "We can’t connect to your \(deviceName)"
            self.letsTryLabel.text = "Please contact us to get some help."
            self.letsDoitButton.setTitle("Contact us", for: .normal)
        }
        self.mayBeLaterButton.setTitle("Maybe later", for: .normal)
    }
    
    func hideUnhideGateWayDetails(isHidden: Bool) {
        self.gatewayNameLabel.isHidden = isHidden
        self.statusView.isHidden = isHidden
        self.gatewayImage.isHidden = isHidden
    }
    
    func hideUnhideRouterDetails(isHidden: Bool) {
        self.routerImage.isHidden = isHidden
        if !isHidden {
            if isRestartSuccess {
                self.routerImage.image = UIImage(named: "WiFi_Connected")
            } else {
                self.routerImage.image = UIImage(named: "Wifi_Disconnected")
            }
        }
    }
    
    func seggregateGatewayData() {
        let masterDetails = MyWifiManager.shared.getMasterGatewayDetails()
        if !masterDetails.name.isEmpty {
            gatewayNameLabel.text = masterDetails.name
            self.statusLabel.text = masterDetails.statusText
            self.statusImage.backgroundColor = masterDetails.statusColor!
            if let imageName = masterDetails.equipmentImage as UIImage? {
                self.gatewayImage.image = imageName
            } else {
                self.gatewayImage.image = UIImage(named: "icon_wifi_white")
            }
        }
    }
    
    @IBAction func letsDoitAction(_ sender: Any) {
        if isRestartSuccess {
            if MyWifiManager.shared.isFromSpeedTest {
                MyWifiManager.shared.isFromSpeedTest = false
                guard let vc = CheckInternetSpeedViewController.instantiateWithIdentifier(from: .speedTest) else { return }
                vc.isRestartHappend = true
                APIRequests.shared.isReloadNotRequiredForMaui = false
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: false)
            } else {
                //CMAIOS-2288, CMAIOS-2289, CMAIOS-2291
                 trackOnClickEvent(isLetsDoItButtonTapped: true)
                AppRatingManager.shared.trackEventTriggeredFor(qualifyingExpType: .troubleshooting)
                APIRequests.shared.isReloadNotRequiredForMaui = false
                self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
                    IntentsManager.sharedInstance.screenFlow = .none
                })
            }
        } else {
            if !isFromManualRestart {
                guard let vc = RestartFlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //CMAIOS-2288, CMAIOS-2289, CMAIOS-2291
    func trackOnClickEvent(isLetsDoItButtonTapped: Bool){
        //CMAIOS-2288, CMAIOS-2289, CMAIOS-2291
        switch (isRestartSuccess,isFromManualRestart, MyWifiManager.shared.getWifiType(), isLetsDoItButtonTapped) {
            //First three cases handles Lets do it  button action when Modem/Equipment/Gateway comes online
        case (true, true, "Equipment", true) :
            self.trackGATagOnClickEvent(eventLinkText: Troubleshooting.TS_EQUIPMENT_INTERNET_WORKS_NOW.rawValue, eventScreenName: Troubleshooting.TS_MANUAL_RESTART_EQUIPMENT_BACKONLINE.rawValue)
            break
        case (true, true, "Modem", true) :
            self.trackGATagOnClickEvent(eventLinkText: Troubleshooting.TS_MODEM_INTERNET_WORKS_NOW.rawValue, eventScreenName: Troubleshooting.TS_MANUAL_RESTART_MODEM_BACKONLINE.rawValue)
        case (true, false, "Gateway", true) :
            self.trackGATagOnClickEvent(eventLinkText: Troubleshooting.TS_GATEWAY_INTERNET_WORKS.rawValue, eventScreenName: Troubleshooting.RESTART_GATEWAY_BACK_ONLINE.rawValue)
        //Last three cases handles MayBeLater button action when Modem/Equipment/Gateway comes online
        case (true, true, "Equipment", false):
            self.trackGATagOnClickEvent(eventLinkText: Troubleshooting.TS_EQUIPMENT_ISSUE_NOT_RESOLVED.rawValue, eventScreenName: Troubleshooting.TS_MANUAL_RESTART_EQUIPMENT_BACKONLINE.rawValue)
            break
        case (true, true, "Modem", false) :
            self.trackGATagOnClickEvent(eventLinkText: Troubleshooting.TS_MODEM_ISSUE_NOT_RESOLVED.rawValue, eventScreenName: Troubleshooting.TS_MANUAL_RESTART_MODEM_BACKONLINE.rawValue)
        case (true, false, "Gateway", false) :
            self.trackGATagOnClickEvent(eventLinkText: Troubleshooting.TS_GATEWAY_ISSUE_NOT_RESOLVED.rawValue, eventScreenName: Troubleshooting.RESTART_GATEWAY_BACK_ONLINE.rawValue)
            break
        default :
            break
        }
    }
    
    @IBAction func mayBeLaterAction(_ sender: UIButton) {
        /*CMAIOS-1181:
         if isRestartSuccess {
         guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
         self.navigationController?.navigationBar.isHidden = false
         self.navigationController?.pushViewController(vc, animated: true)
         } else {
         self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
         }
         */
        //CMAIOS-1181: The button reusing causing to break the navigation flow. Added temp fix, needed to imporve in next builds.
        if (mayBeLaterButton.currentTitle?.lowercased() == "maybe later") {
            APIRequests.shared.isReloadNotRequiredForMaui = false
            self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
                IntentsManager.sharedInstance.screenFlow = .none
            })
        } else {
            //CMAIOS-2288, CMAIOS-2289, CMAIOS-2291
            self.trackOnClickEvent(isLetsDoItButtonTapped: false)
            guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
