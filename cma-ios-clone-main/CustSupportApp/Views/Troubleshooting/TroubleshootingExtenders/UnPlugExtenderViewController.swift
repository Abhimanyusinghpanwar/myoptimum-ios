//
//  UnPlugExtenderViewController.swift
//  CustSupportApp
//  CMAIOS-381
//
//  Created by vsamikeri on 1/25/23.

import UIKit
import Lottie

class UnPlugExtenderViewController: BaseViewController {
    
    @IBOutlet weak var unPlugExtenderAnimationView: LottieAnimationView!
    @IBOutlet weak var unPlugExtenderViewHeaderLbl: UILabel!
    private let currentNavigationFlow = ExtenderDataManager.shared.flowType

    override func viewDidLoad() {
        super.viewDidLoad()
        if CurrentDevice.isLargeScreenDevice() {
            unPlugExtenderViewHeaderLbl.setLineHeight(1.21)
        } else {
            unPlugExtenderViewHeaderLbl.setLineHeight(1.15)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        unplugViewUpdateUI()
        trackAnalyticsTS()
    }
    
    @IBAction func unPlugExtenderPrimaryBtn(_ sender: Any) {
        switch ExtenderDataManager.shared.flowType {
            
        case .offlineFlow:
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "plugInExtenderViewController")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        case .weakFlow:
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "extenderWeakFindGoodSpotViewController")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func unplugViewUpdateUI() {
        if currentNavigationFlow == .weakFlow {
            unPlugExtenderViewHeaderLbl.text = "Now unplug the Extender’s POWER cord from the outlet"
        }
        unPlugExtenderAnimationView.animation = LottieAnimation.named("08_Plug_Out")
        unPlugExtenderAnimationView.backgroundColor = .clear
        unPlugExtenderAnimationView.loopMode = .playOnce
        unPlugExtenderAnimationView.animationSpeed = 1.0
        unPlugExtenderAnimationView.backgroundBehavior = .pauseAndRestore
        unPlugExtenderAnimationView.play()
    }
    func trackAnalyticsTS() {
        var screenTag: String = ""
        switch ExtenderDataManager.shared.flowType {
            
        case .offlineFlow:
            screenTag = ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_unplug_extender.rawValue
        case .weakFlow:
            screenTag = ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_unplug_extender.rawValue
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
}

/*
 *if larger device constraints.
 */
