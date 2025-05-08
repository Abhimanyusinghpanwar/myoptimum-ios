//
//  XtendInstallWPSVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/6/22.
//  GA-extender5_press_wps_button/extender6_press_wps_button

import UIKit
import Lottie

class XtendInstallWPSVC: BaseViewController {
    
    @IBOutlet weak var pressWPSPrimaryLbl: UILabel!
    @IBOutlet weak var pressWPSAnimationView: LottieAnimationView!
    @IBOutlet weak var xtendInstallWPSStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallWPSTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallWPSPrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallPrimaryButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        updatePressWPSUI()
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_press_wps_button.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updatePressWPSUI() {
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            self.pressWPSPrimaryLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendInstallWPSStackViewLeadingConstraint.constant = 30.0
            xtendInstallWPSTrailingConstraint.constant = 30.0
            pressWPSPrimaryLbl.setLineHeight(1.21)
        } else {
            pressWPSPrimaryLbl.setLineHeight(1.15)
        }
        switch extenderType {
        case 5:
            pressWPSPrimaryLbl.text = "Press the WPS button on the Extender for 3 seconds"
            xtendInstallPrimaryButton.setTitle("I pressed it for 3 seconds", for: .normal)
            self.pressWPSAnimationView.animation = LottieAnimation.named("Xtend-5-Press-the-pairing-button-on")
        case 7:
            self.pressWPSAnimationView.animation = LottieAnimation.named("Extender6E-Press-WPS-button")
        default:
            self.pressWPSAnimationView.animation = LottieAnimation.named("Xtend-6-Press-the-pairing-button-on-Xtend")
        }
        self.pressWPSAnimationView.backgroundColor = .clear
        self.pressWPSAnimationView.loopMode = .playOnce
        self.pressWPSAnimationView.animationSpeed = 1.0
        self.pressWPSAnimationView.backgroundBehavior = .pauseAndRestore
        self.pressWPSAnimationView.play()
    }
    
    @IBAction func pressWPSNextBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallPairingVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
