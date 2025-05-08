//
//  GatewayPairingModeVC.swift
//  CustSupportApp
//
//  Created by Vishnu Samikeri on 8/23/23.
//

import UIKit
import Lottie

class GatewayPairingModeVC: BaseViewController {
    
    @IBOutlet weak var gwPairingAnimationView: LottieAnimationView!
    @IBOutlet weak var gwPairingHeaderLbl: UILabel!
    @IBOutlet weak var gwPairingPrimaryBtn: RoundedButton!
    private let animationFiles = ["1319-1326-Press-WPS",
                                  "1322-Press-WPS","OptimumOne-Press-WPS",
                                  "Gateway6E-Press-WPS",
                                  "Fiber_Press_WPS",
                                  "Docsis-Gateway6E-Press-WPS-button"]
    private let gwType = ExtenderDataManager.shared.gwEquipType
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderManualPairing.extender_manual_pairing_press_gateway_wps.rawValue,
                                                                  CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue,
                                                                   EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func updateUI() {
        gwPairingHeaderLbl.text = "Press the WPS button on your Gateway"
        gwPairingPrimaryBtn.setTitle("I pressed the WPS button", for: .normal)
        
        //Lottie
        gwPairingAnimationView.animation = LottieAnimation.named(animationForWPS())
        gwPairingAnimationView.backgroundColor = .clear
        gwPairingAnimationView.loopMode = .playOnce
        gwPairingAnimationView.animationSpeed = 1.0
        gwPairingAnimationView.backgroundBehavior = .pauseAndRestore
        gwPairingAnimationView.play()
    }
    
    func animationForWPS() -> String {
        var animationName = ""
        switch gwType {
        case "Ubee 1340":
            animationName = animationFiles[5]
        case "FTTH Gateway Gen 7":
            animationName = animationFiles[4]
        case "FTTH Gateway Gen 9", "Multi Gig FTTH XGSPON Gen 9":
            animationName = animationFiles[3]
        case "Altice One Box Gateway":
            animationName = animationFiles[2]
        case "Ubee 1322":
            animationName = animationFiles[1]
        default:
            animationName = animationFiles[0]
        }
        return animationName
    }
    
    @IBAction func gwPairingPrimaryBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "goToExtenderVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
