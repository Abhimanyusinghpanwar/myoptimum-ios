//
//  XtendPlacementHelpScreenThree.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/21/22.
//  GA-extender5_manual_placement_tipsheet3/extender6_manual_placement_tipsheet3

import UIKit
import Lottie

class XtendPlacementHelpScreenThree: BaseViewController {
    
    @IBOutlet weak var helpScreenThreeAnimationView: LottieAnimationView!
    @IBOutlet weak var xtendPlacementHelpThreeStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendPlacementHelpThreeStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendPlacementHelpThreePrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendPlacementHelpThreeHeaderLbl: UILabel!
    var refreshDelegateHelpScreen: RefreshSignalProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendPlacementHelpThreeUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //Lottie
        helpScreenThreeAnimationView.animation = (ExtenderDataManager.shared.extenderType == 7) ? LottieAnimation.named("Extender6E-Let’s-pick-a-spot") : LottieAnimation.named("Xtend-6-Lets-pick-a-spot")
        helpScreenThreeAnimationView.backgroundColor = .clear
        helpScreenThreeAnimationView.loopMode = .playOnce
        helpScreenThreeAnimationView.animationSpeed = 1.0
        helpScreenThreeAnimationView.backgroundBehavior = .pauseAndRestore
        helpScreenThreeAnimationView.play()
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_manual_placement_tipsheet3.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    
    func updateXtendPlacementHelpThreeUI() {
        
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendPlacementHelpThreeStackViewLeadingConstraint.constant = 30.0
            xtendPlacementHelpThreeStackViewTrailingConstraint.constant = 30.0
            xtendPlacementHelpThreeHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendPlacementHelpThreeHeaderLbl.setLineHeight(1.21)
        } else {
            xtendPlacementHelpThreeHeaderLbl.setLineHeight(1.15)
        }
    }
    @IBAction func helpScreenThreeGotItBtn(_ sender: Any) {
        //Navigation back to proactive placement screen
        var proactiveVC: ProactivePlacementViewController?
        let tempFlag = ExtenderDataManager.shared.extenderAPIFailure
        let tempNetworkFlag = ExtenderDataManager.shared.extenderHomeNetwork
        for currentVC in self.navigationController?.viewControllers ?? [] {
            if currentVC.isKind(of: ProactivePlacementViewController.self) && tempFlag == false {
                if tempNetworkFlag == true {
                    proactiveVC = currentVC as? ProactivePlacementViewController
                }
                break
            }
        }
        if let vc = proactiveVC {
//            proactiveVC?.refreshData()
            self.navigationController?.popToViewController(vc, animated: true)
        } else {
            Logger.info("Stack doesn't contain Proactive VC")
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallManualPickSpotVC")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
