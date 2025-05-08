//
//  PluginXtendVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 9/29/22.
//  GA-extender5_plug_in_extender/extender6_plug_in_extender

import UIKit
import Lottie

class PluginXtendVC: BaseViewController {
    
    @IBOutlet weak var plugInAnimation: LottieAnimationView!
    @IBOutlet weak var plugInHeaderLbl: UILabel!
    @IBOutlet weak var plugInBtnTiltle: UIButton!
    @IBOutlet weak var PluginXtendStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var PluginXtendStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var PluginXtendBottomBtnBottomConstraint: NSLayoutConstraint!
    private let navigationFlow = ExtenderDataManager.shared.flowType
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        updatePlugInScreenUI()
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_plug_in_extender.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updatePlugInScreenUI() {
        let extender = ExtenderDataManager.shared.extenderType
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            plugInHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            PluginXtendStackViewLeadingConstraint.constant = 30.0
            PluginXtendStackViewTrailingConstraint.constant = 30.0
            plugInHeaderLbl.setLineHeight(1.21)
        } else {
            plugInHeaderLbl.setLineHeight(1.15)
        }
        switch extender {
            
        case 7:
            self.plugInAnimation.animation = LottieAnimation.named("Extender6E-Press-the-POWER-button")
            plugInBtnTiltle.setTitle("I pressed the power button", for: .normal)
            self.plugInHeaderLbl.text = "Now plug in your Extender and press the POWER button on the back"
        case 5:
            self.plugInAnimation.animation = LottieAnimation.named("Plug-in-Xtend-5")
            plugInBtnTiltle.setTitle("I pressed the power button", for: .normal)
            self.plugInHeaderLbl.text = "Great. Now plug in your Extender. If you don't see the lights on the front, press the POWER button on the back."
        default:
            self.plugInAnimation.animation = LottieAnimation.named("Plug-in-Xtend-6")
            plugInBtnTiltle.setTitle("I plugged it in", for: .normal)
            self.plugInHeaderLbl.text = "Now plug in your Extender"
        }
        self.plugInAnimation.backgroundColor = .clear
        self.plugInAnimation.loopMode = .playOnce
        self.plugInAnimation.animationSpeed = 1.0
        self.plugInAnimation.backgroundBehavior = .pauseAndRestore
        self.plugInAnimation.play()
    }
    @IBAction func plugInActionBtn(_ sender: Any) {
        
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "extenderWeakConfirmPairingVC")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "xtendCheckLightsVC")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
