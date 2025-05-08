//
//  XtendPlacementHelpScreenTwo.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/21/22.
//  GA-extender5_manual_placement_tipsheet2/extender6_manual_placement_tipsheet2

import UIKit
import Lottie

class XtendPlacementHelpScreenTwo: BaseViewController {
    
    @IBOutlet weak var xtendPlacementHelpTwoStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendPlacementHelpTwoStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendPlacementHelpTwoPrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendPlacementHelpTwoHeaderLbl: UILabel!
    @IBOutlet weak var helpScreenTwoAnimationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendPlacementHelpTwoUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //Lottie
        helpScreenTwoAnimationView.animation = (ExtenderDataManager.shared.extenderType == 7) ? LottieAnimation.named("Extender6E-Generic-Gateway-Let’s-pick-a-spot-Floor") : LottieAnimation.named("Xtend-6-Generic-Gateway-Lets-pick-a-spot-Floor")
        helpScreenTwoAnimationView.backgroundColor = .clear
        helpScreenTwoAnimationView.loopMode = .playOnce
        helpScreenTwoAnimationView.animationSpeed = 1.0
        helpScreenTwoAnimationView.backgroundBehavior = .pauseAndRestore
        helpScreenTwoAnimationView.play()
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_manual_placement_tipsheet2.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    
    func updateXtendPlacementHelpTwoUI() {
        
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendPlacementHelpTwoStackViewLeadingConstraint.constant = 30.0
            xtendPlacementHelpTwoStackViewTrailingConstraint.constant = 30.0
            xtendPlacementHelpTwoHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendPlacementHelpTwoHeaderLbl.setLineHeight(1.21)
        } else {
            xtendPlacementHelpTwoHeaderLbl.setLineHeight(1.15)
        }
    }
    
    @IBAction func helpScreenTwoOkayBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpScreenThree")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
