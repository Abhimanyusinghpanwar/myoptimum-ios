//
//  PlugInExtenderViewController.swift
//  CustSupportApp
//  CMAIOS-378.
//
//  Created by vsamikeri on 1/26/23.
//

import UIKit
import Lottie

class PlugInExtenderViewController: BaseViewController {
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var plugInExtenderAnimationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        //Lottie
        plugInExtenderAnimationView.animation = LottieAnimation.named("08_Plug_in")
        plugInExtenderAnimationView.backgroundColor = .clear
        plugInExtenderAnimationView.loopMode = .playOnce
        plugInExtenderAnimationView.animationSpeed = 1.0
        plugInExtenderAnimationView.backgroundBehavior = .pauseAndRestore
        plugInExtenderAnimationView.play()
        if CurrentDevice.isLargeScreenDevice() {
            headerLbl.setLineHeight(1.21)
        } else {
            headerLbl.setLineHeight(1.15)
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_plug_extender.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    @IBAction func plugInExtenderPrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "extenderOfflineCheckLightsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
