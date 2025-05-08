//
//  ExtenderOfflineCheckLightsViewController.swift
//  CustSupportApp
//  CMAIOS-377
//  Created by vsamikeri on 2/9/23.
//

import UIKit
import Lottie

class ExtenderOfflineCheckLightsViewController: BaseViewController {
    
    @IBOutlet weak var extenderOfflineCheckLightsAnimationView: LottieAnimationView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var regularLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CurrentDevice.isLargeScreenDevice() {
            headerLbl.setLineHeight(1.21)
            regularLbl.setLineHeight(1.15)
        } else {
            headerLbl.setLineHeight(1.2)
            regularLbl.setLineHeight(1.2)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        updateExtenderOfflineCheckLightsUI()
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_check_extender_power.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    func updateExtenderOfflineCheckLightsUI() {
        var animationName = ""
        switch extenderType {
        case 5:
            animationName = "29_Extender_5_lights_highlight_power_front"
        case 7:
            animationName = "Extender6E-Power-Lights"
        default:
            animationName = "30_Extender_6_lights_highlight_power_top"
        }
        extenderOfflineCheckLightsAnimationView.animation = LottieAnimation.named(animationName)
        extenderOfflineCheckLightsAnimationView.backgroundColor = .clear
        extenderOfflineCheckLightsAnimationView.loopMode = .playOnce
        extenderOfflineCheckLightsAnimationView.animationSpeed = 1.0
        extenderOfflineCheckLightsAnimationView.backgroundBehavior = .pauseAndRestore
        extenderOfflineCheckLightsAnimationView.play()
    }
    @IBAction func extenderOfflineCheckLightsPrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "restartTimerExtenderViewController")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func extenderOfflineCheckLightsSecondaryBtn(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "extenderOfflineCheckLightsTipsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
