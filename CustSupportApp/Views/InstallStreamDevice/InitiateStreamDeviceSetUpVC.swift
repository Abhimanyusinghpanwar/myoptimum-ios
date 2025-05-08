//
//  InitiateStreamDeviceSetUpVC.swift
//  CustSupportApp
//
//  Created by vishali Test on 19/06/24.
//

import UIKit
import Lottie

class InitiateStreamDeviceSetUpVC: BaseViewController {
    @IBOutlet weak var animationView: LottieAnimationView!
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var primaryButton: RoundedButton!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpUIData()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_INSTALL_SETUP.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    func setUpUIData() {
        headerTitle.text = "Open your Optimum Stream box"
        descriptionLabel.isHidden = false
        headerTitle.setLineHeight(0.99)
        descriptionLabel.text = "Follow the instructions inside to set up your Stream."
        descriptionLabel.setLineHeight(0.99)
        primaryButton.setTitle("I've set up my Stream", for: .normal)
        primaryButton.isHidden = false
        playAnimation(animationName: "Stream-Box-opening")
        self.setupLeftBarItem()
        buttonBottomConstraint.constant = UIDevice().hasNotch ? 10 : 30
    }
    
    func playAnimation(animationName: String, loop:LottieLoopMode = .playOnce) {
        self.animationView.backgroundColor = .clear
        self.animationView.animation = LottieAnimation.named(animationName)
        self.animationView.animationSpeed = 1.0
        self.animationView.loopMode = loop
        self.animationView.backgroundBehavior = .forceFinish
        self.animationView.play()
    }

    @IBAction func installStreamDeviceBtnTapped(_ sender: Any) {
        guard let vc = InstallStreamDeviceVC.instantiateWithIdentifier(from: .TVHomeScreen) else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InitiateStreamDeviceSetUpVC : BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .cancel {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            navigationController?.dismiss(animated: true)
        } else {
            if let welcomScreen = self.navigationController?.viewControllers.filter({$0.isKind(of: StreamDeviceLandingScreen.classForCoder())}).first {
                navigationController?.popViewController(animated: true)
            } else {
                DispatchQueue.main.async {
                    if APIRequests.shared.isReloadNotRequiredForMaui {
                        APIRequests.shared.isReloadNotRequiredForMaui = false
                    }
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
