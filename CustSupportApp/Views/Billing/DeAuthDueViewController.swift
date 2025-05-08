//
//  DeAuthDueViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 14/03/24.
//

import UIKit
import Lottie

class DeAuthDueViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var LableTitle: UILabel!
    @IBOutlet weak var LableSubTitle: UILabel!
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var isScreenEnteredBG = false
    override func viewDidLoad() {
        super.viewDidLoad()
        handleUI()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func willEnterForeground() {
        isScreenEnteredBG = false
        if CommonUtility.checkRemainingTime() > 0 {
            self.animationView.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(CommonUtility.checkRemainingTime())) {
                self.playFinalAnimation()
            }
        } else {
            self.playFinalAnimation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appDidEnterBackground() {
        isScreenEnteredBG = true
        self.animationView.pause()
    }
    
    func handleUI() {
        loadJsonAnimation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : DeAuthServices.Billing_Deauth_Services_Being_Restored.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Profile.rawValue ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func loadJsonAnimation() {
        setAnimation(animationView: self.animationView, name: "De-Authrestoreloop", loopMode: .loop, speed: 1.0)
        
        // Calculate the progress to reach after one minute
        self.animationView.play()
        if CommonUtility.checkRemainingTime() > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(CommonUtility.checkRemainingTime())) {
                self.playFinalAnimation()
            }
        } else {
            self.playFinalAnimation()
        }
    }
    
    func playFinalAnimation() {
        if !isScreenEnteredBG {
            self.animationView.stop()
            self.setAnimation(animationView: self.animationView, name: "De-Authrestorefull", loopMode: .playOnce, speed: 1.0)
            self.animationView.play { _ in
                //            App.endSimulationForDeAuth()
                if self.appDel.isShowDeAuthScreen {
                    self.appDel.isShowDeAuthScreen = false
                    PreferenceHandler.removeDataForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP")
                    self.appDel.performConfigRequest()
                } else {
                    self.dismissQuickPayAndLoadLogin()
                }
            }
        }
    }
    
    func dismissQuickPayAndLoadLogin() {
        // CMAIOS:-2569
        if let quickPayDeauth = self.navigationController?.presentingViewController?.isKind(of: QuickPayDeAuthViewController.classForCoder()), quickPayDeauth {
            PreferenceHandler.removeDataForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP")
            let quickPay = self.navigationController?.presentingViewController! as! QuickPayDeAuthViewController
            self.navigationController?.dismiss(animated: false)
            quickPay.dismissCallBack?()
            return
        }
        
        // CMAIOS:-2570
        if let navigationControl = self.presentingViewController as? UINavigationController {
            if let quickPayDeauth = navigationControl.viewControllers.filter({$0 is QuickPayDeAuthViewController}).first as? QuickPayDeAuthViewController {
                PreferenceHandler.removeDataForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP")
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: false, completion: {
                        quickPayDeauth.dismissCallBack?()
                    })
                }
            }
        }
    }
    
    func setAnimation(animationView: LottieAnimationView, name: String, loopMode: LottieLoopMode, speed: CGFloat) {
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
    }
    
}
