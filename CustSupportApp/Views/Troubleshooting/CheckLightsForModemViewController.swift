//
//  CheckLightsForModemViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 05/02/23.
//

import UIKit
import Lottie

class CheckLightsForModemViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    @IBOutlet weak var lightsOnButton: RoundedButton!
    @IBOutlet weak var lightsOffButton: RoundedButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var connectedImage: UIImageView!
    @IBOutlet weak var connectedImageView: LottieAnimationView!
    @IBOutlet weak var headerLabelTopToAnimationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLabelTopToSafeAreaConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        self.titleLabel.isHidden = false
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            self.headerLabel.text = "Let's make sure your Gateway has power"
            self.titleLabel.text = "Do you see any lights on your Gateway?"
            self.lightsOnButton.setTitle("Yes, I see lights on my Gateway", for: .normal)
            self.lightsOffButton.setTitle("No, I don't see any lights", for: .normal)
            self.headerLabelTopToAnimationViewConstraint.priority = UILayoutPriority(999)
            self.headerLabelTopToSafeAreaConstraint.priority = UILayoutPriority(250)
            let gateway = MyWifiManager.shared.getMasterGatewayDetails()
            if !gateway.equipmentDisplay.isEmpty, let equipmentDict = MyWifiManager.shared.equipmentTypeDictionary as NSDictionary?, let wifiDict = equipmentDict.value(forKey: gateway.equipmentDisplay) as? NSDictionary, !wifiDict.allKeys.isEmpty, let jsonData = wifiDict.value(forKey: "Lights") as? String, !jsonData.isEmpty {
                self.connectedImage.isHidden = true
                self.viewAnimationSetUpForCable(animationName: jsonData)
            } else {
                self.connectedImage.image = UIImage(named: "plug")
                self.connectedImage.isHidden = false
            }
        } else if MyWifiManager.shared.getWifiType() == "Equipment" {
            self.headerLabel.text = "Let's make sure your equipment has power"
            self.titleLabel.text = "Do you see any lights on your modem and router?"
            self.lightsOnButton.setTitle("Yes. I see lights on my equipment", for: .normal)
            self.lightsOffButton.setTitle("No, I don't see any lights", for: .normal)
            self.connectedImage.isHidden = true
            self.headerLabelTopToAnimationViewConstraint.priority = UILayoutPriority(250)
            self.headerLabelTopToSafeAreaConstraint.priority = UILayoutPriority(999)
        } else if MyWifiManager.shared.getWifiType() == "Modem" {
            self.headerLabel.text = "Let's make sure your modem has power"
            self.titleLabel.text = "Do you see any lights on your modem?"
            self.lightsOnButton.setTitle("Yes. I see lights on my modem", for: .normal)
            self.lightsOffButton.setTitle("No, I don't see any lights", for: .normal)
            self.connectedImage.isHidden = true
            self.headerLabelTopToAnimationViewConstraint.priority = UILayoutPriority(250)
            self.headerLabelTopToSafeAreaConstraint.priority = UILayoutPriority(999)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectedImageView.play()
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GATEWAY_POWER_ON.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        } else if MyWifiManager.shared.getWifiType() == "Equipment" {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_CHECK_LIGHTS_ON_MODEM_ROUTER.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        } else if MyWifiManager.shared.getWifiType() == "Modem" {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_CHECK_LIGHTS_ON_MODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        }
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
    
    @IBAction func lightsOnAction(_ sender: Any) {
        guard let vc = RestartCountDownTimerViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
        vc.isFromManualRestart = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func lightsOffAction(_ sender: Any) {
        guard let vc = CheckLightsViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController")
        //vc.modalPresentationStyle = .fullScreen
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
