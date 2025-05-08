//
//  GoToExtenderVC.swift
//  CustSupportApp
//
//  Created by Vishnu Samikeri on 8/23/23.
//

import UIKit
import Lottie

class GoToExtenderVC: BaseViewController {
    
    
    @IBOutlet weak var gotoExtenderAnimationView: LottieAnimationView!
    @IBOutlet weak var gotoExtenderHeaderLbl: UILabel!
    @IBOutlet weak var gotoExtenderPrimaryBtn: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderManualPairing.extender_manual_pairing_press_extender_wps.rawValue,
                                                                  CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue,
                                                                   EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    private func updateUI() {
        gotoExtenderPrimaryBtn.setTitle("I pressed it for 2 seconds", for: .normal)
        gotoExtenderHeaderLbl.text = "Now go back to your Extender and press the WPS button on the Extender for 2 seconds"
        switch extenderType {
        case 5:
            gotoExtenderAnimationView.animation = LottieAnimation.named("Extender5-Press-WPS")
            gotoExtenderPrimaryBtn.setTitle("I pressed it for 3 seconds", for: .normal)
            gotoExtenderHeaderLbl.text = "Now go back to your Extender and press the WPS button on the Extender for 3 seconds"
        case 7:
            self.gotoExtenderAnimationView.animation = LottieAnimation.named("Extender6E-Press-WPS-button")
        default:
            gotoExtenderAnimationView.animation = LottieAnimation.named("Extender6-Press-WPS")
            
        }
        gotoExtenderAnimationView.backgroundColor = .clear
        gotoExtenderAnimationView.loopMode = .playOnce
        gotoExtenderAnimationView.animationSpeed = 1.0
        gotoExtenderAnimationView.backgroundBehavior = .pauseAndRestore
        gotoExtenderAnimationView.play()
    }
    @IBAction func gotoExtenderPrimaryBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallPairingVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
