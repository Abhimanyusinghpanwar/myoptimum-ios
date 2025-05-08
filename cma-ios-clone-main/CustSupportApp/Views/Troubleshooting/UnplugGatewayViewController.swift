//
//  UnplugGatewayViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 31/01/23.
//

import UIKit
import Lottie

class UnplugGatewayViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    @IBOutlet weak var unplugButton: RoundedButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var connectedImageView: LottieAnimationView!
    @IBOutlet weak var connectedImage: UIImageView!
    var wifiLegacyType = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        switch MyWifiManager.shared.getWifiType() {
        case "Gateway":
            self.headerLabel.text = "Unplug the Gateway's POWER cord from the outlet, and wait 10 seconds."
            self.unplugButton.setTitle("I’ve unplugged the POWER cord", for: .normal)
        case "Equipment":
            if wifiLegacyType == "router" {
                self.headerLabel.text = "Unplug the Router's POWER cord from the outlet"
                self.unplugButton.setTitle("I’ve unplugged the router", for: .normal)
            } else if wifiLegacyType == "modem" {
                self.headerLabel.text = "Unplug the Modem's POWER cord from the outlet, and wait 10 seconds."
                self.unplugButton.setTitle("I’ve unplugged the modem", for: .normal)
            }
        case "Modem":
            self.headerLabel.text = "Unplug the Modem's POWER cord from the wall, and wait 10 seconds."
            self.unplugButton.setTitle("I’ve unplugged the modem", for: .normal)
        default:
            self.headerLabel.text = "Unplug the Gateway's POWER cord from the outlet, and wait 10 seconds."
            self.unplugButton.setTitle("I’ve unplugged the POWER cord", for: .normal)
        }
        viewAnimationSetUp()
        self.connectedImage.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectedImageView.play()
        switch MyWifiManager.shared.getWifiType() {
        case "Gateway":
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_UNPLUG_GATEWAY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        case "Equipment":
            if wifiLegacyType == "router" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_UNPLUG_ROUTER.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_UNPLUG_MODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            }
        case "Modem":
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_UNPLUGMODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        default:
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_UNPLUG_GATEWAY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        }
    }
    
    func viewAnimationSetUp() {
        self.connectedImageView.backgroundColor = .clear
        self.connectedImageView.animation = LottieAnimation.named("08_Plug_Out")
        self.connectedImageView.animationSpeed = 1.0
        self.connectedImageView.play(toProgress: 0.3, completion:{_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.connectedImageView.play(fromProgress: self.connectedImageView.currentProgress, toProgress: 1.0, loopMode: .playOnce)
            }
        })
    }
    
    @IBAction func unplugButtonAction(_ sender: Any) {
        if wifiLegacyType.isEmpty {
            guard let vc = ConnectPoewrCablesViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            vc.wifiLegacyType = ""
            if ((MyWifiManager.shared.accessTech == "gpon") || (MyWifiManager.shared.getWifiType() == "Modem") ) {
                vc.isShowConnectedScreen = false
            } else {
                vc.isShowConnectedScreen = true
            }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if wifiLegacyType == "modem" {
                guard let vc = ConnectPoewrCablesViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                vc.wifiLegacyType = wifiLegacyType
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = RestartFlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                vc.isTypeModem = true
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController")
        self.navigationController?.pushViewController(vc, animated: true)
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
