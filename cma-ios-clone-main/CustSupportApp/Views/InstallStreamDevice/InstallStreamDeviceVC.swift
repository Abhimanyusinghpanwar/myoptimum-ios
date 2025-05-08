//
//  InstallStreamDeviceVC.swift
//  CustSupportApp
//
//  Created by riyaz on 16/05/24.
//

import UIKit
import Lottie

class InstallStreamDeviceVC: BaseViewController, BarButtonItemDelegate {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var primaryButton: RoundedButton!
    
    var failCount = 0
    
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        //CMA-2651
        updateUIForLookingStreamDevice()
        self.callInstallStreamDeviceRequest()
        // Do any additional setup after loading the view.
    }

    func handleForFailure() {
        self.failCount += 1
        if failCount == 1 {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_FIRST_FAIL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
            updateUIForFailure()
        } else if failCount > 1 {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_SECONDFAIL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
            self.navToContactChatWithUs()
            updateUIForFailure()
        }
    }

    func updateUIForFailure() {
        primaryButton.isHidden = false
        //CMAIOS-2330
        descriptionLabel.isHidden = false
        //CMAIOS-2363: Added line height multiple and alignment for label
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
        headerTitle.attributedText = NSMutableAttributedString(string: "Hmm, we can't see your Optimum Stream", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        descriptionLabel.attributedText = NSMutableAttributedString(string: "Let's try this again. \n\nFollow the instructions on the inside cover of your Optimum Stream box.", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        //
        //CMAIOS-2330
        primaryButton.setTitle("I've set up my Stream", for: .normal)
        playAnimation(animationName: "Looking-for-Stream-Failed")
        //CMAIOS-2363: Button constraints updated
        buttonBottomConstraint.constant = UIDevice().hasNotch ? 10 : 30
        //
    }
    
    func updateUIForSuccess() {
        primaryButton.isHidden = true
        headerTitle.text = "Looking for your Optimum Stream"
        descriptionLabel.isHidden = true
        self.animationView.backgroundColor = .clear
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_FOUNDSTREAM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
        self.animationView.animation = LottieAnimation.named("Looking-for-Stream-Success")
        self.animationView.animationSpeed = 1.0
        self.animationView.loopMode = .playOnce
        self.animationView.backgroundBehavior = .forceFinish
        self.animationView.play(toProgress: 0.95, completion:{_ in
            DispatchQueue.main.async {
                self.navToTVHomeScreen()
            }
        })
    }

    func updateUIForLookingStreamDevice() {
        primaryButton.isHidden = true
        headerTitle.text = "Looking for your Optimum Stream"
        descriptionLabel.isHidden = true
        playAnimation(animationName: "Looking-for-Stream-loop", loop: .loop)
    }

    func playAnimation(animationName: String, loop:LottieLoopMode = .playOnce) {
        self.animationView.backgroundColor = .clear
        self.animationView.animation = LottieAnimation.named(animationName)
        self.animationView.animationSpeed = 1.0
        self.animationView.loopMode = loop
        self.animationView.backgroundBehavior = .forceFinish
        self.animationView.play()
    }
    
    func navToTVHomeScreen() {
        guard let navigationController = self.navigationController else { return }
        if let landingScreen = navigationController.viewControllers.first(where: { $0.isKind(of: StreamDeviceLandingScreen.self) }) {
            if let presentingVC = landingScreen.presentingViewController, presentingVC.isKind(of: TVHomePageViewController.self) {
                DispatchQueue.main.async {
                    landingScreen.dismiss(animated: false)
                }
            } else {
                if APIRequests.shared.isReloadNotRequiredForMaui {
                    APIRequests.shared.isReloadNotRequiredForMaui = false
                }
                if  let navVC = landingScreen.presentingViewController as? UINavigationController, let tvScreen = navVC.viewControllers.first(where: { $0.isKind(of: TVHomePageViewController.self)}) {
                    self.navigationController?.dismiss(animated: true)
                    return
                }
                guard let vc = TVHomePageViewController.instantiateWithIdentifier(from: .TVHomeScreen) else { return }
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.navigationController?.pushViewController(vc, animated: true)
            }
          }
    }

    func navToContactChatWithUs() {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallContactSupportVC") as? XtendInstallContactSupportVC {
            vc.streamInstallFlow = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .cancel {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            navigationController?.dismiss(animated: true)
        } else {
            //CMA-2651
            navigationController?.popViewController(animated: true)
        }
    }

    //CMA-2651
    func callInstallStreamDeviceRequest (){
        DispatchQueue.main.async {
            self.updateUIForLookingStreamDevice()
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_LOOKING_FOR_STREAM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
            APIRequests.shared.installStreamDeviceRequest{ success, response, error in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.updateUIForSuccess()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.handleForFailure()
                    }
                }
            }
        }
    }
    
    @IBAction func installStreamDeviceTapped(_ sender: Any) {
           //CMA-2651
           self.updateUIForLookingStreamDevice()
           self.callInstallStreamDeviceRequest ()
    }
}
