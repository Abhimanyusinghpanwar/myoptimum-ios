//
//  MaybeLaterViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/21/22.
//

import Lottie
import UIKit

class MaybeLaterViewController: UIViewController {
    @IBOutlet var secondaryAction: UIButton!
    @IBOutlet var animationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        secondaryAction.layer.borderWidth = 1
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        animationView.play()
    }
    
    override func viewDidAppear(_ animated: Bool){
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_INFLUENCING_YOUR_INTERNET_SPEED_CONFIRM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
    }
    
    @IBAction func onTapSecondaryAction(_ sender: UIButton) {
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func onTapPrimaryAction(_ sender: UIButton) {
        guard let vc = TipsContainerViewController.instantiateWithIdentifier(from: .speedTest) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}
