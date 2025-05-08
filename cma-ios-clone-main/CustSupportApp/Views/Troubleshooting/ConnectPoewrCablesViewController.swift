//
//  ConnectPoewrCablesViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 18/01/23.
//

import UIKit
import Lottie

class ConnectPoewrCablesViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    @IBOutlet weak var connectedImage: UIImageView!
    @IBOutlet weak var connectedButton: RoundedButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var connectedImageView: LottieAnimationView!
    var isShowConnectedScreen : Bool = false
    var wifiLegacyType = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        switch MyWifiManager.shared.getWifiType() {
        case "Gateway":
            if !isShowConnectedScreen {
                self.headerLabel.text = "Now plug the Gateway's POWER cord back into the outlet"
                self.connectedButton.setTitle("I’ve connected the power cable", for: .normal)
                self.connectedImage.isHidden = true
                self.viewAnimationSetUp()
            } else {
                self.headerLabel.text = "Make sure the coaxial cable is firmly connected to the coax wall outlet and your Gateway."
                self.connectedImage.isHidden = false
                self.connectedButton.setTitle("I checked the connections", for: .normal)
                let gateway = MyWifiManager.shared.getMasterGatewayDetails()
                if !gateway.equipmentDisplay.isEmpty, let equipmentDict = MyWifiManager.shared.equipmentTypeDictionary as NSDictionary?, let wifiDict = equipmentDict.value(forKey: gateway.equipmentDisplay) as? NSDictionary, !wifiDict.allKeys.isEmpty, let jsonData = wifiDict.value(forKey: "Cable") as? String, !jsonData.isEmpty {
                    self.viewAnimationSetUpForCable(animationName: jsonData)
                } else {
                    self.connectedImage.image = UIImage(named: "plug")
                }
            }
            
        case "Equipment":
            if wifiLegacyType == "router" {
                self.headerLabel.text = "Now plug the Router's POWER cord back into the outlet"
                self.connectedButton.setTitle("I’ve plugged the router back in", for: .normal)
                self.connectedImage.isHidden = true
                self.viewAnimationSetUp()
            } else if wifiLegacyType == "modem" {
                self.headerLabel.text = "Plug the Modem's POWER cord back into the outlet"
                self.connectedButton.setTitle("I’ve plugged the modem back in", for: .normal)
                self.connectedImage.isHidden = true
                self.viewAnimationSetUp()
            }
            
        case "Modem":
            self.headerLabel.text = "Now plug the Modem's POWER cord back into an outlet"
            self.connectedImage.isHidden = true
            self.connectedButton.setTitle("I’ve plugged the modem back in", for: .normal)
            self.viewAnimationSetUp()
            
        default:
            self.headerLabel.text = "Make sure the coaxial cable is firmly connected to the coax wall outlet and your Gateway."
            self.connectedImage.isHidden = false
            self.connectedButton.setTitle("I checked the connections", for: .normal)
            let gateway = MyWifiManager.shared.getMasterGatewayDetails()
            if !gateway.equipmentDisplay.isEmpty, let equipmentDict = MyWifiManager.shared.equipmentTypeDictionary as NSDictionary?, let wifiDict = equipmentDict.value(forKey: gateway.equipmentDisplay) as? NSDictionary, !wifiDict.allKeys.isEmpty, let jsonData = wifiDict.value(forKey: "Cable") as? String, !jsonData.isEmpty {
                self.viewAnimationSetUpForCable(animationName: jsonData)
            } else {
                self.connectedImage.image = UIImage(named: "plug")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectedImageView.play()
        switch MyWifiManager.shared.getWifiType() {
        case "Gateway":
            if !isShowConnectedScreen {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_PLUG_GATEWAY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_CABLE_CONNECTION.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
            }
        case "Equipment":
            if wifiLegacyType == "router" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_PLUG_ROUTER.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_PLUG_MODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            }
        case "Modem":
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_PLUGMODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        default:
            break
        }
    }
    
    func viewAnimationSetUp() {
            self.connectedImageView.backgroundColor = .clear
            self.connectedImageView.animation = LottieAnimation.named("08_Plug_in")
            self.connectedImageView.animationSpeed = 1.0
            self.connectedImageView.backgroundBehavior = .forceFinish
            self.connectedImageView.play(toProgress: 0.3, completion:{_ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.connectedImageView.play(fromProgress: self.connectedImageView.currentProgress, toProgress: 1.0, loopMode: .playOnce)
                }
            })
    }
    
    func viewAnimationSetUpForCable(animationName: String) {
            self.connectedImageView.backgroundColor = .clear
            self.connectedImageView.animation = LottieAnimation.named(animationName)
            self.connectedImageView.animationSpeed = 1.0
        self.connectedImageView.backgroundBehavior = .forceFinish
            self.connectedImageView.play(toProgress: 0.05, completion:{_ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.connectedImageView.play(fromProgress: self.connectedImageView.currentProgress, toProgress: 1.0, loopMode: .playOnce)
                }
            })
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController")
        //vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
        }
  
    @IBAction func connectedButtonAction(_ sender: Any) {
        if wifiLegacyType.isEmpty {
            if isShowConnectedScreen {
                guard let vc = ConnectPoewrCablesViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                vc.isShowConnectedScreen = false
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = CheckLightsForModemViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if wifiLegacyType == "modem" {
            guard let vc = ConnectPoewrCablesViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            vc.isShowConnectedScreen = false
            vc.wifiLegacyType = "router"
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = CheckLightsForModemViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

}
