//
//  ExtenderWeakConfirmPairingVC.swift
//  CustSupportApp
//
//  Created by Vishnu Samikeri on 9/25/23.
//

import UIKit
import Lottie

class ExtenderWeakConfirmPairingVC: BaseViewController {
    
    @IBOutlet weak var xtendWeakConfirmPairingAnimationView: LottieAnimationView!
    @IBOutlet weak var xtendWeakConfirmPairingheaderLabel: UILabel!
    @IBOutlet weak var xtendWeakConfirmPairingPrimaryButton: RoundedButton!
    @IBOutlet weak var xtendWeakConfirmPairingViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendWeakConfirmPairingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendWeakConfirmPairingStackView: UIStackView!
    @IBOutlet weak var xtendWeakConfirmPairingLoadingAnimationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateXtendWeakConfirmPairingUI()
    }
    
    func updateXtendWeakConfirmPairingUI() {
        setUpPrimaryBtn(hide: false)
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendWeakConfirmPairingheaderLabel.font = UIFont(name: "Regular-Bold", size: 24)
            xtendWeakConfirmPairingViewLeadingConstraint.constant = 30.0
            xtendWeakConfirmPairingViewTrailingConstraint.constant = 30.0
            xtendWeakConfirmPairingheaderLabel.setLineHeight(1.21)
        } else {
            xtendWeakConfirmPairingheaderLabel.setLineHeight(1.15)
        }
        switch extenderType {
        case 5:
            let headerText = ExtenderDataManager.shared.isExtenderTroubleshootFlow ? "Wait a couple of minutes until the second light is solid green" : "Wait a couple of minutes until the top light blinks green and the second light is solid green"
            xtendWeakConfirmPairingheaderLabel.text = headerText
            xtendWeakConfirmPairingPrimaryButton.setTitle("The second light is solid green", for: .normal)
            xtendWeakConfirmPairingAnimationView.animation = LottieAnimation.named("Xtend-5-Pairing-Waiting-for-light-sequence")
        case 7:
            xtendWeakConfirmPairingheaderLabel.text = "Wait a few minutes until the WiFi lights are solid white"
            xtendWeakConfirmPairingPrimaryButton.setTitle("The WiFi lights are solid white", for: .normal)
            xtendWeakConfirmPairingAnimationView.animation = LottieAnimation.named("Extender6E-WiFi-Lights-solid-white")
        default:
            xtendWeakConfirmPairingAnimationView.animation = LottieAnimation.named("Xtend-6-Pairing-Waiting-for-light-sequence-Second-time")
        }
        xtendWeakConfirmPairingAnimationView.loopMode = .playOnce
        xtendWeakConfirmPairingAnimationView.animationSpeed = 1.0
        xtendWeakConfirmPairingAnimationView.backgroundBehavior = .pauseAndRestore
        xtendWeakConfirmPairingAnimationView.play()
        setAnimationViewForLoading()
    }
    @IBAction func PrimaryButtonAction(_ sender: Any) {
        setUpPrimaryBtn(hide: true)
        xtendWeakConfirmPairingLoadingAnimationView.play(fromProgress: 0.0, toProgress: 0.11, loopMode: .none) { _ in
            self.xtendWeakConfirmPairingLoadingAnimationView.play(fromProgress: 0.11, toProgress: 0.61, loopMode: .loop) { _ in }
        }
        self.makeLTAPICall()
    }
    
    @IBAction func secondaryButtonAction(_ sender: Any) {
        navigateNext(storyboard: "MyAccount", identifier: "xtendCheckLightsVC")
    }
    
    func navigateNext(storyboard:String, identifier:String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.view.isUserInteractionEnabled = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func areExtendersOnline() -> Bool {
        let extenderState = MyWifiManager.shared.getAllOnlineExtenders().filter({ExtenderDataManager.shared.extendersDeviceMac.contains($0.device_mac ?? "")})
        if extenderState.count > 0 {
            return true
        }
        return false
    }
    
    func makeLTAPICall() {
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
                self.xtendWeakConfirmPairingLoadingAnimationView.pause()
                self.xtendWeakConfirmPairingLoadingAnimationView.play(fromProgress: self.xtendWeakConfirmPairingLoadingAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.navigateNext(storyboard: "TroubleshootingExtenders", identifier: identifier)
                }
            }
        }
    }
}

extension ExtenderWeakConfirmPairingVC {
    func setAnimationViewForLoading() {
        xtendWeakConfirmPairingLoadingAnimationView.backgroundColor = .clear
        xtendWeakConfirmPairingLoadingAnimationView.animation = LottieAnimation.named("OrangeFullWidthButton")
        xtendWeakConfirmPairingLoadingAnimationView.animationSpeed = 1.0
        xtendWeakConfirmPairingLoadingAnimationView.loopMode = .playOnce
    }
    func setUpPrimaryBtn(hide: Bool) {
        UIView.animate(withDuration: 0.35, animations: {
            self.xtendWeakConfirmPairingStackView.isHidden = hide
            self.xtendWeakConfirmPairingLoadingAnimationView.isHidden = !hide
        })
    }
    
    func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    }
}
