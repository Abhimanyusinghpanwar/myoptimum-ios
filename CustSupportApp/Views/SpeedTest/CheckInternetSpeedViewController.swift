//
//  CheckInternetSpeedViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/16/22.
//

import Lottie
import UIKit

class CheckInternetSpeedViewController: UIViewController {
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var header: UILabel!
    var isRestartHappend: Bool = false
    var isSuccessResponseReceived = false
    var speedTestResponse: SpeepTestResponse!
    @IBOutlet var animationViewCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeBottomViewConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = MyWifiManager.shared.isUploadSupported ? "Speed_Upload" : "Speed_Download"
        animationView.animation = LottieAnimation.named(name)
        if MyWifiManager.shared.isFromHealthCheck {
            self.header.alpha = 0
            header.text = MyWifiManager.shared.isUploadSupported ? "Checking the speed to and from your home..." : "Checking the download speed to your home..."
            UIView.animate(withDuration: 0.5) {
                self.header.alpha = 1.0
            }
            if MyWifiManager.shared.isUploadSupported {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_CHECKING_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_CHECKING_DOWNLOAD_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            }
        } else {
            header.text = MyWifiManager.shared.isUploadSupported ? "Let’s check the speed to and from your home" : "Let’s check the download speed to your home"
            
            animationViewCenterConstraint.constant = currentScreenWidth
            animationView.frame.origin.x = currentScreenWidth
        }
        //closeBottomViewConstraint.constant = CurrentDevice.forLargeSpotlights() ? 45 : 30
        header.setLineHeight(1.2)
        header.textAlignment = .center
    }
    
    override func viewDidAppear(_ animated: Bool){
        //For Firebase Analytics
        if !MyWifiManager.shared.isFromHealthCheck {
            if !MyWifiManager.shared.isUploadSupported {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_CHECKING_DOWNLOAD_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.CHECKING_DUAL_SPEEDS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
            }
        }
    }
    
    func performSpeedTest() {
        SpeedTestManager.shared.startSpeedTest { result in
            switch result {
            case let .success(response):
                if MyWifiManager.shared.isCloseButtonClicked {
                    self.speedTestResponse = response
                    self.isSuccessResponseReceived = true
                } else {
                    guard let vc = SpeedTestResultViewController.instantiateWithIdentifier(from: .speedTest) else { return }
                    vc.speedResult = response
                    vc.isRestartHappend = self.isRestartHappend
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            case let .failure(error):
                self.presentErrorMessageVC()
                Logger.info(error.localizedDescription)
              
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !MyWifiManager.shared.isCloseButtonClicked {
            self.performSpeedTest()
        }
        if !MyWifiManager.shared.isFromHealthCheck {
            navigationController?.isNavigationBarHidden = true
        } else {
            self.navigationItem.hidesBackButton = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.7) {
                self.animationView.frame.origin.x = currentScreenWidth/2 - self.animationView.frame.size.width/2
                self.animationViewCenterConstraint.constant = 0
            } completion:{_ in
                self.playAnimationAndCallSpeedTestAPI()
                if MyWifiManager.shared.isCloseButtonClicked {
                    if self.isSuccessResponseReceived {
                        guard let vc = SpeedTestResultViewController.instantiateWithIdentifier(from: .speedTest) else { return }
                        vc.speedResult = self.speedTestResponse
                        vc.isRestartHappend = self.isRestartHappend
                        self.navigationController?.pushViewController(vc, animated: false)
                        self.isSuccessResponseReceived = false
                    }
                    MyWifiManager.shared.isCloseButtonClicked = false
                }
            }
        }
        
    }
    
    func playAnimationAndCallSpeedTestAPI() {
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 1.0
        self.animationView.play()
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        if MyWifiManager.shared.isFromHealthCheck {
            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
                MyWifiManager.shared.isCloseButtonClicked = true
                 cancelVC.modalPresentationStyle = .fullScreen
                 self.navigationController?.pushViewController(cancelVC, animated: true)
             }
        } else {
//            navigationController?.dismiss(animated: true)
            
            if let navigationControl = self.presentingViewController as? UINavigationController {
                if let moreOptions = navigationControl.viewControllers.filter({$0 is AdvancedSettingsUIViewController}).first as? AdvancedSettingsUIViewController {
                    DispatchQueue.main.async {
                        navigationControl.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(moreOptions, animated: true)
                        })
                    }
                }
            } else {
                navigationController?.dismiss(animated: true)
            }
        }
    }
    
    func presentErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.modalPresentationStyle = .fullScreen
        if MyWifiManager.shared.isFromHealthCheck {
            vc.isComingFromMyWifiPage = true
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .troubleshoot_dead_zone_and_speed_test_failure)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_TS_HEALTH_CHECK_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        } else {
            vc.isComingFromSpeedTestVC = true
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .more_options_speed_test_failure)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_SPEEDTEST_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
        }
      
        self.present(vc, animated: true)
    }
}
