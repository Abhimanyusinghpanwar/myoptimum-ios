//
//  XtendPlacementHelpWiFiWorksBestVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/19/22.
// GA-extender5_manual_placement_tipsheet1/extender6_manual_ placement_tipsheet1

import UIKit
import Lottie

class XtendPlacementHelpWiFiWorksBestVC: BaseViewController {
    
    @IBOutlet weak var helpWiFiAnimationView: LottieAnimationView!
    var refreshDelegateHelperScreen: RefreshSignalProtocol?
    @IBOutlet weak var xtendHelpOneStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendHelpOneStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendHelpOnePrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendHelpOneHeaderLbl: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendHelpOneUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //Lottie
        helpWiFiAnimationView.animation = (ExtenderDataManager.shared.extenderType == 7) ? LottieAnimation.named("Extender6E-Generic-Gateway-Let’s-pick-a-spot-wall") : LottieAnimation.named("Xtend 6-Generic-Gateway-Lets-pick-a-spot-Wall")
        helpWiFiAnimationView.backgroundColor = .clear
        helpWiFiAnimationView.loopMode = .playOnce
        helpWiFiAnimationView.animationSpeed = 1.0
        helpWiFiAnimationView.backgroundBehavior = .pauseAndRestore
        helpWiFiAnimationView.play()
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_manual_placement_tipsheet1.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    
    func updateXtendHelpOneUI() {
        
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendHelpOneStackViewLeadingConstraint.constant = 30.0
            xtendHelpOneStackViewTrailingConstraint.constant = 30.0
            xtendHelpOneHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendHelpOneHeaderLbl.setLineHeight(1.21)
        } else {
            xtendHelpOneHeaderLbl.setLineHeight(1.15)
        }
    }
    
    @IBAction func helpWiFiOkayBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpScreenTwo")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
