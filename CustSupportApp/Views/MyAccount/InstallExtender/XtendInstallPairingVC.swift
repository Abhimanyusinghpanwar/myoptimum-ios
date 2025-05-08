//
//  XtendInstallPairingVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/12/22.
//  GA-extender5_wait_for_pairing_to_complete/extender6_wait_for_pairing_to_complete

import UIKit
import Lottie


class XtendInstallPairingVC: BaseViewController {
    
    @IBOutlet weak var halfButtonLoadingView: LottieAnimationView!
    @IBOutlet weak var waitForPairingAnimation: LottieAnimationView!
    @IBOutlet weak var waitForPairingPrimaryLbl: UILabel!
    @IBOutlet weak var XtendInstallPairingStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var XtendInstallPairingTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var XtendInstallPairingBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var waitForPairingPrimaryBtn: RoundedButton!
    @IBOutlet weak var waitForPairingSecondarybtn: RoundedButton!
    @IBOutlet weak var waitForPairingBottomStackView: UIStackView!
    let pairingScreenExtender = ExtenderDataManager.shared.extenderType
    let xtendTroubleshoot = ExtenderDataManager.shared.isExtenderTroubleshootFlow
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateWaitForPairingUI()
        setUpBottomStackView(hide: false)
        trackAnalyticsSIScreens()
        setUpLoadingView()
    }
    
    func updateWaitForPairingUI() {
        
        if (CurrentDevice.isLargeScreenDevice() && !xtendTroubleshoot) {
            waitForPairingPrimaryLbl.font = UIFont(name: "Regular-Bold", size: 24)
            XtendInstallPairingStackViewLeadingConstraint.constant = 30.0
            XtendInstallPairingTrailingConstraint.constant = 30.0
            waitForPairingPrimaryLbl.setLineHeight(1.21)
        } else {
            waitForPairingPrimaryLbl.setLineHeight(1.15)
        }
        
        switch pairingScreenExtender {
        case 5:
            let headerText = xtendTroubleshoot ? "Wait a couple of minutes until the second light is solid green" : "Wait a couple of minutes until the top light blinks green and the second light is solid green"
            waitForPairingPrimaryLbl.text = headerText
            waitForPairingPrimaryBtn.setTitle("The second light is solid green", for: .normal)
            waitForPairingAnimation.animation = LottieAnimation.named("Xtend-5-Pairing-Waiting-for-light-sequence")
        case 7:
            waitForPairingPrimaryLbl.text = "Wait a few minutes until the WiFi lights are solid white"
            waitForPairingPrimaryBtn.setTitle("The WiFi lights are solid white", for: .normal)
            waitForPairingAnimation.animation = LottieAnimation.named("Extender6E-WiFi-Lights-solid-white")
        default:
            waitForPairingAnimation.animation = LottieAnimation.named("Xtend-6-Pairing-Waiting-for-light-sequence-Second-time")
        }
        self.waitForPairingAnimation.backgroundColor = .clear
        self.waitForPairingAnimation.loopMode = .playOnce
        self.waitForPairingAnimation.animationSpeed = 1.0
        self.waitForPairingAnimation.backgroundBehavior = .pauseAndRestore
        self.waitForPairingAnimation.play()
    }
    
    @IBAction func waitForPairingPrimatyBtn(_ sender: Any) {
        if xtendTroubleshoot {
            primaryBtnNavigationForTroubleshoot()
        } else {
            navigateTo(storyboard: "MyAccount", identifier: "xtendIsNowPairedVC")
        }
    }
    
    func primaryBtnNavigationForTroubleshoot() {
        setUpBottomStackView(hide: true)
        halfButtonLoadingView.play(fromProgress: 0.0, toProgress: 0.11, loopMode: .none) { _ in
            self.halfButtonLoadingView.play(fromProgress: 0.11, toProgress: 0.61, loopMode: .loop) { _ in }
        }
        makeLTCall()
    }
    
    @IBAction func waitForPairingSecBtn(_ sender: Any) {
        if ExtenderDataManager.shared.wpsAPIFail && ExtenderDataManager.shared.wpsFailCount < 1 {
            ExtenderDataManager.shared.wpsFailCount += 1
            ExtenderDataManager.shared.extenderPairingStatus = true
            wpsManualNavigationFlow()
        } else {
            checkForTipsOrContactScreen()
        }
    }
    
    func makeLTCall() {
        var identifier = ""
        APIRequests.shared.initiateLiveTopologyRequest { success, response, error in
            DispatchQueue.main.async {
                self.navigationController?.view.isUserInteractionEnabled = true
                if success {
                    let extenderStatus = MyWifiManager.shared.getOnlineExtenders().filter({
                        ExtenderDataManager.shared.extendersDeviceMac.contains($0.device_mac ?? "")
                    })
                    switch extenderStatus.count {
                    case 1...:
                        identifier = "extenderBackOnlineViewController"
                    default:
                        identifier = self.areExtendersOnline() ? "extenderStillWeakViewController":"extenderOfflineFailedViewController"
                    }
                } else {
                    identifier = "extenderTroubleshootLTFailViewController"
                }
                self.halfButtonLoadingView.pause()
                self.halfButtonLoadingView.play(fromProgress: self.halfButtonLoadingView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.navigateTo(storyboard: "TroubleshootingExtenders", identifier: identifier)
                }
            }
        }
    }
    
    func checkForTipsOrContactScreen() {
        if (waitForPairingSecondarybtn.isSelected || ExtenderDataManager.shared.extenderPairingStatus == true) {
            navigateTo(storyboard: "HomeScreen", identifier: "XtendSupportViewController")
        } else {
            waitForPairingSecondarybtn.isSelected = true
            ExtenderDataManager.shared.extenderPairingStatus = true
            navigateTo(storyboard: "MyAccount", identifier: "xtendInstallPairingFailFirstVC")
        }
    }
    
    func wpsManualNavigationFlow() {
        navigateTo(storyboard: "MyAccount", identifier: "goToGatewayVC")
    }
    
    func navigateTo(storyboard:String, identifier:String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.view.isUserInteractionEnabled = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func trackAnalyticsSIScreens() {
        var screenTag: String = ""
        if xtendTroubleshoot {
            screenTag = ExtenderTroubleshooting.ExtenderTypeForTS.ts_extender5_confirm_pairing_at_new_spot.extenderTitleTS
        } else {
            screenTag = ExtenderInstallScreens.ExtenderType.extender5_wait_for_pairing_to_complete.extenderTitle
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
}

extension XtendInstallPairingVC {
    
    func setUpLoadingView() {
        halfButtonLoadingView.backgroundColor = .clear
        halfButtonLoadingView.animation = LottieAnimation.named("OrangeFullWidthButton")
        halfButtonLoadingView.loopMode = .playOnce
    }
    
    func setUpBottomStackView(hide: Bool) {
        UIView.animate(withDuration: 0.35, animations: {
            self.waitForPairingBottomStackView.isHidden = hide
            self.halfButtonLoadingView.isHidden = !hide
        })
    }
    
    func areExtendersOnline() -> Bool {
        let extenderState = MyWifiManager.shared.getAllOnlineExtenders().filter({ExtenderDataManager.shared.extendersDeviceMac.contains($0.device_mac ?? "")})
        if extenderState.count > 0 {
            return true
        }
        return false
    }
}
