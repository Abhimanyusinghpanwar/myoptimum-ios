//
//  RestartTimerExtenderViewController.swift
//  CustSupportApp
//  CMAIOS-376
//
//  Created by vsamikeri on 2/1/23.
//

import UIKit
import Lottie

class RestartTimerExtenderViewController: UIViewController {
    @IBOutlet weak var extenderTimerBGView: LottieAnimationView!
    @IBOutlet weak var extenderTimerLabel: UILabel!
    private var timer: Timer?
    private var totalTime = 300
    private var checkPoint = 180
    private var onlineExtenders: [LightSpeedAPIResponse.extender_status.Nodes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extenderTimerLabel.text = self.timeFormatted(self.totalTime) // will show timer
        extenderTimerBGView.layer.cornerRadius = self.extenderTimerBGView.frame.width/2
        self.extenderTimerBGView.backgroundColor = .clear
        self.extenderTimerBGView.animation = LottieAnimation.named("Timer-ring5Min_no_ease")
        self.extenderTimerBGView.loopMode = .playOnce
        self.extenderTimerBGView.animationSpeed = 1.0
        self.extenderTimerBGView.play()
        self.extenderTimerBGView.bringSubviewToFront(self.extenderTimerLabel)
        countDownTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.isIdleTimerDisabled = true
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_extender_restarting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        invalidateTimer()
    }
    private func countDownTimer() {
        // self.totalTime = 10
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        self.extenderTimerLabel.text = self.timeFormatted(self.totalTime - 1) // will show timer
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            invalidateTimer()
        }
        if (totalTime == checkPoint || totalTime < 1) {
            APIRequests.shared.initiateLiveTopologyRequest { success, response, error in
                DispatchQueue.main.async {
                    if success {
                        self.checkExtenderStatusToNavigate()
                    } else {
                        self.navigateToExtenderStatusFail()
                    }
                }
            }
        }
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%2d:%02d", minutes, seconds)
    }
    
    func invalidateTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
            // self.navigationController?.popViewController(animated: true)
        }
    }
    
    func checkExtenderStatusToNavigate() {
        findExtender()
        if onlineExtenders.count > 0 {
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "extenderBackOnlineViewController")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "extenderOfflineFailedViewController")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            Logger.warning("Failed to Load extender Status")
        }
    }
    func navigateToExtenderStatusFail() {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "extenderTroubleshootLTFailViewController")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func findExtender() {
        let offlineDeviceMacs = ExtenderDataManager.shared.extendersDeviceMac
        onlineExtenders = MyWifiManager.shared.getAllOnlineExtenders()
        switch offlineDeviceMacs.count {
        case 1:
            onlineExtenders = MyWifiManager.shared.getAllOnlineExtenders().filter({$0.device_mac == ExtenderDataManager.shared.extendersDeviceMac.first})
        default:
            onlineExtenders = MyWifiManager.shared.getAllOnlineExtenders().filter({ExtenderDataManager.shared.extendersDeviceMac.contains($0.device_mac ?? "")
            })
            ExtenderDataManager.shared.extenderFriendlyName = WifiConfigValues.getExtenderName(offlineExtNode: onlineExtenders.first, onlineExtNode:nil)
        }
    }
}
