//
//  RetartCountDownTimerViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 18/01/23.
//

import UIKit
import Lottie

class RestartCountDownTimerViewController: UIViewController {
    @IBOutlet weak var timerBgView: LottieAnimationView!
    @IBOutlet weak var gatewayNameLabel: UILabel!
    @IBOutlet weak var threeDotsAnimation: LottieAnimationView!
    @IBOutlet weak var timerAdditionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    //Gateway restarting
    var timer: Timer?
    var totalTime = 300
    var additionalTime = 180
    var isRestartSucccess = false
    var deviceName = ""
    var isFromManualRestart = false
    var statusArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        UIApplication.shared.isIdleTimerDisabled = true
        self.timerLabel.text = self.timeFormatted(self.totalTime)// show time
        deviceName = MyWifiManager.shared.getWifiType()
        gatewayNameLabel.text = "\(deviceName) restarting"
        self.timerLabel.textAlignment = .center
        self.timerBgView.backgroundColor = .clear
        self.timerBgView.animation = LottieAnimation.named("Timer-ring5Min_no_ease")
        self.timerBgView.loopMode = .playOnce
        self.timerBgView.animationSpeed = 1.0
        self.timerBgView.play()
        self.timerAdditionLabel.isHidden = true
        self.threeDotsAnimation.isHidden = true
        countDownTimer()
        if !isFromManualRestart {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.RESTART_GATEWAY_RESTARTING.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            APIRequests.shared.initiateRebootRequest() { success, error in
                if success {
                    self.statusArray.add("Online")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        if self.totalTime != 0 {
                            self.initiateGatewayCall()
                        }
                    }
                } else {
                    self.isRestartSucccess = false
                    APIRequests.shared.isRebootOccured = false
                    self.navigateToNextScreen()
                }
            }
        } else {
            if MyWifiManager.shared.getWifiType() == "Equipment" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_EQUIPMENT_RESTARTING.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            } else if MyWifiManager.shared.getWifiType() == "Modem" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_MODEM_RESTARTING.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            }
            let spareTimeToPerformOS: Double = Double((totalTime - 45))
            DispatchQueue.main.asyncAfter(deadline: .now() + spareTimeToPerformOS) {
                if self.totalTime != 0 {
                    self.initiateGatewayCall()
                }
            }
        }
        self.timerBgView.layer.cornerRadius = self.timerBgView.frame.width/2
        self.timerBgView.backgroundColor = energyBlueRGB
        self.timerLabel.textColor = .white
        self.timerBgView.bringSubviewToFront(self.timerLabel)
    }
    
    func threeDotsAnimationSetup() {
        self.threeDotsAnimation.backgroundColor = .clear
        self.threeDotsAnimation.animation = LottieAnimation.named("three_dots")
        self.threeDotsAnimation.loopMode = .loop
        self.threeDotsAnimation.animationSpeed = 1.0
        self.threeDotsAnimation.play()
    }
    
    private func countDownTimer() {
              // self.totalTime = 10
               self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
           }
   
    @objc func updateTimer() {
        self.timerLabel.text = self.timeFormatted(self.totalTime - 1) // will show timer
               if totalTime != 0 {
                   totalTime -= 1  // decrease counter timer
               } else {
                   if let timer = self.timer {
                       timer.invalidate()
                       self.timer = nil
                       self.timerBgView.stop()
                       self.timerBgView.animation = nil
                       self.timerBgView.backgroundColor = energyBlueRGB
                       self.timerLabel.isHidden = true
                       self.timerAdditionLabel.isHidden = false
                       self.threeDotsAnimation.isHidden = false
                       self.threeDotsAnimationSetup()
                       self.additionalTimerCountDown()
                   }
               }
           }
    
    private func additionalTimerCountDown() {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_GATEWAY_RESTARTING_ADDITIONAL_WAIT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAdditionalTimer), userInfo: nil, repeats: true)
    }
   
    @objc func updateAdditionalTimer() {
               if additionalTime != 0 {
                   additionalTime -= 1  // decrease counter timer
               } else {
                   if let timer = self.timer {
                       timer.invalidate()
                       self.timer = nil
                       isRestartSucccess = false
                       APIRequests.shared.isRebootOccured = false
                       self.navigateToNextScreen()
                       // self.navigationController?.popViewController(animated: true)
                   }
               }
           }
    
    func navigateToNextScreen() {
        //CMAIOS-2664
        SpotLightsManager.shared.configureSpotLightsForMyWifi()
        //
        UIApplication.shared.isIdleTimerDisabled = false
        self.timerBgView.stop()
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
        guard let vc = RestartFailViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
        vc.isRestartSuccess = isRestartSucccess
        vc.deviceName = deviceName
        vc.isFromManualRestart = isFromManualRestart
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
            let seconds: Int = totalSeconds % 60
            let minutes: Int = (totalSeconds / 60) % 60
            return String(format: "%2d:%02d", minutes, seconds)
        }
    
    func restartSuccess() {
        DispatchQueue.main.async {
            self.isRestartSucccess = true
            APIRequests.shared.isRebootOccured = false
            MyWifiManager.shared.isOperationalStatusOnline = true
            MyWifiManager.shared.stalenessType = "0"
            if MyWifiManager.shared.getMyWifiStatus() == .runningSmoothly {
                MyWifiManager.shared.recallSpotlights = true
            }
            if MyWifiManager.shared.getWifiType() != "Modem" {
                self.performLiveTopology()
            } else {
                self.navigateToNextScreen()
            }
        }
    }
    
    func performRestartOperationForManual(cmStatus: String) {
        if cmStatus.contains("operational") || cmStatus.contains("online") {
            self.restartSuccess()
            return
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.initiateGatewayCall()
            }
        }
    }
    
    func performRestartOperation(cmStatus: String) {
        if cmStatus.contains("operational") || cmStatus.contains("online") {
            self.statusArray.add("Online")
        } else {
            if !self.statusArray.contains("Offline") {
                self.statusArray.add("Offline")
            }
        }
        if self.statusArray.count >= 3 {
            if self.statusArray.firstObject as! String == "Online", self.statusArray.lastObject as! String == "Online", self.statusArray.contains("Offline") {
                self.restartSuccess()
                return
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.initiateGatewayCall()
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.initiateGatewayCall()
            }
        }
    }
    
    func initiateGatewayCall() {
        if self.additionalTime != 0 {
            /// API #2: Operational Status API Call after Accounts API
            guard let deviceMAC = MyWifiManager.shared.deviceMAC, let deviceType = MyWifiManager.shared.deviceType else {
                //Gateway is offline
                ///TO-DO: Create structure for gateway values
                return
            }
            let mapString = "\(deviceMAC)?devicetype=" + deviceType
            APIRequests.shared.isRebootOccured = true
            if !MyWifiManager.shared.accessTech.isEmpty, MyWifiManager.shared.accessTech == "gpon" {
                APIRequests.shared.initiateGatewayStatusAPIRequestForFiber(mapString) { success, response, error in
                    if success, let operationalStatusResponse = response, let operationalStatus = operationalStatusResponse.operationalStatus, !operationalStatus.isEmpty, let cmStatus = operationalStatus.lowercased() as String? {
                        if self.isFromManualRestart {
                            self.performRestartOperationForManual(cmStatus: cmStatus)
                        } else {
                            self.performRestartOperation(cmStatus: cmStatus)
                        }
                    } else {
                        if self.isFromManualRestart {
                            self.performRestartOperationForManual(cmStatus: "failure")
                        } else {
                            self.performRestartOperation(cmStatus: "failure")
                        }
                    }
                }
            } else {
                APIRequests.shared.initiateGatewayStatusAPIRequest(mapString) { success, response, error in
                    if success, let operationalStatusResponse = response, let operationalStatus = operationalStatusResponse.cm, let cmtsInfo = operationalStatus.cmtsInfo,  let cmStatus = cmtsInfo.cmStatus, let cmStatusValue = cmStatus.lowercased() as String? {
                        if self.isFromManualRestart {
                            self.performRestartOperationForManual(cmStatus: cmStatusValue)
                        } else {
                            self.performRestartOperation(cmStatus: cmStatus)
                        }
                    } else {
                        if self.isFromManualRestart {
                            self.performRestartOperationForManual(cmStatus: "failure")
                        } else {
                            self.performRestartOperation(cmStatus: "failure")
                        }
                    }
                }
            }
        }
    }
    
    func performLiveTopology() {
        if self.additionalTime != 0 {
            APIRequests.shared.initiateLiveTopologyRequest(withReboot: true) { success, response, error in
                if !success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.performLiveTopology()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigateToNextScreen()
                    }
                }
            }
        }
    }
}
