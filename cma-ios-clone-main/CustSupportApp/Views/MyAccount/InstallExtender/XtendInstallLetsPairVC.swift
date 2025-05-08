//
//  XtendInstallLetsPairVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/7/22.
//  GA-extender5_let'spair_extender/extender6_let'spair_extender

import UIKit
import Lottie

class XtendInstallLetsPairVC: BaseViewController {
    
    @IBOutlet weak var letsPairAnimationView: LottieAnimationView!
    @IBOutlet weak var letsPairHeaderLbl: UILabel!
    @IBOutlet weak var letsPairHeaderViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var letsPairImageView: UIImageView!
    @IBOutlet weak var letsPairHeaderViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var letsPairPrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var letsPairPrimaryBtn: RoundedButton!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    private let isTroubleshootFlow = ExtenderDataManager.shared.isExtenderTroubleshootFlow
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpPrimaryBtn(hide: false)
        ExtenderDataManager.shared.wpsAPIFail = false
        updateLetsPairUI()
        trackAnalyticsSIScreens()
        setupAnimationView()
    }
    
    func updateLetsPairUI() {
        letsPairHeaderViewLeadingConstraint.constant = 30.0
        letsPairHeaderViewTrailingConstraint.constant = 30.0
        let extender = ExtenderDataManager.shared.extenderType
        switch extender {
        case 5:
            letsPairAnimationView.isHidden = true
        case 7:
            letsPairAnimationView.isHidden = true
            letsPairImageView.image = isTroubleshootFlow ? UIImage(named: "Extender-6E-front-view-unpaired") : UIImage(named: "Extender-6E-front-view")
        default:
            letsPairImageView.isHidden = true
            letsPairAnimationView.animation = LottieAnimation.named("Xtend-6-Now-lets-pair-Xtend")
            letsPairAnimationView.backgroundColor = .clear
            letsPairAnimationView.loopMode = .playOnce
            letsPairAnimationView.animationSpeed = 1.0
            letsPairAnimationView.backgroundBehavior = .pauseAndRestore
            letsPairAnimationView.play()
        }
        if isTroubleshootFlow {
            letsPairHeaderLbl.text = "It looks like your Extender has become unpaired. Let's pair it again with your home WiFi network."
        }
        if (CurrentDevice.isLargeScreenDevice() && !isTroubleshootFlow) {
            letsPairHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            letsPairHeaderLbl.setLineHeight(1.21)
        } else {
            letsPairHeaderLbl.setLineHeight(1.15)
        }
    }
    
    @IBAction func letsPairPrimaryBtn(_ sender: Any) {
        setUpPrimaryBtn(hide: true)
        loadingAnimationView.play(fromProgress: 0.0, toProgress: 0.11, loopMode: .none) { _ in
            self.loadingAnimationView.play(fromProgress: 0.11, toProgress: 0.61, loopMode: .loop) { _ in }
        }
        delay(seconds: 0.75) {
            self.makeWPSAPICall()
        }
    }
    
    func makeWPSAPICall() {
        var identifier = ""
        APIRequests.shared.initiateWPSRequest { success, response, error in
            DispatchQueue.main.async {
                if response?.desc == "Success" {
                    identifier = "xtendInstallWPSVC"
                    ExtenderDataManager.shared.wpsAPIFail = false
                } else {
                    identifier = "goToGatewayVC"
                    ExtenderDataManager.shared.wpsAPIFail = true
                }
                self.loadingAnimationView.pause()
                self.loadingAnimationView.play(fromProgress: self.loadingAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.navigateNext(identifier: identifier)
                }
            }
        }
    }
    
    func navigateNext(identifier: String) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func trackAnalyticsSIScreens() {
        var screenTag: String = ""
        if isTroubleshootFlow {
            screenTag = ExtenderTroubleshooting.ExtenderTypeForTS.ts_extender5_pair_again.extenderTitleTS
        } else {
            screenTag = ExtenderInstallScreens.ExtenderType.extender5_lets_pair_extender.extenderTitle
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
}

extension XtendInstallLetsPairVC {
    func setupAnimationView() {
        loadingAnimationView.animation = LottieAnimation.named("OrangeFullWidthButton")
        loadingAnimationView.loopMode = .playOnce
    }
    
    func setUpPrimaryBtn(hide: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.letsPairPrimaryBtn.isHidden = hide
            self.loadingAnimationView.isHidden = !hide
        })
    }
    
    func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    }
}
