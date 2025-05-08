//
//  ProactiveViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 8/5/22.
//
/*
import UIKit
import Lottie

protocol RefreshProtocol {
    func refreshData()
}

class ProactiveViewController: BaseViewController, RefreshProtocol {
    
    
    @IBOutlet weak var placementAnimation: LottieAnimationView!
    @IBOutlet weak var additionalText: UILabel!
    @IBOutlet weak var signalQualLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var placedXtendBtn: UIButton!
    @IBOutlet weak var noGoodSpot: UIButton!
    var isServiceProgress: Bool = false
    weak var timer: Timer?
    var count = 0
    var identiyServiceFailCount = 0
    var signalQualityAPIFail = 0
    
    func refreshData() {
        getIdentity()
        Logger.info("Get Identity local method called [-]")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signalQualLbl.text = ""
        additionalText.text = ""
        placedXtendBtn.isHidden = true
        headerLbl.isHidden = false
        identiyServiceFailCount = 0
        placementAnimation.animation = LottieAnimation.named("Proactive-placement-Blue-stroke-Ripple")
        placementAnimation.backgroundColor = .clear
        placementAnimation.loopMode = .loop
        placementAnimation.animationSpeed = 1.0
        self.placementAnimation.play()
        Logger.info("Proactive Screen is loading......")
    }

    override func viewDidAppear(_ animated: Bool) {
        getIdentity()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
        placementAnimation.animation = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        APIRequests.shared.logoutSession()
        Logger.info("viewDidDisappear")
    }
    
    func scheduleServiceCall() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.timer = timer
            if self.navigationController?.topViewController != nil &&  ((self.navigationController?.topViewController?.isKind(of: ProactiveViewController.self)) != nil){
                if self.isServiceProgress == false && self == self.navigationController?.topViewController {
                    self.fetchProactiveSingal()
                }
            }
        }
    }
    
    func getIdentity() {
        
        APIRequests.shared.getIdentity { isSuccess, error in
            Logger.warning("<Count>\(self.identiyServiceFailCount)")
            if isSuccess == true {
                Logger.info("getIdentity API is successful with a token!")
                if self == self.navigationController?.topViewController {
                    self.fetchProactiveSingal()
                }
            } else {
                if error != nil {
                    if self.identiyServiceFailCount < 2 {
                        self.identiyServiceFailCount += 1
                        self.getIdentity()
                    } else {
                        if self.identiyServiceFailCount == 2 {
                            Logger.info("ERROR NAVIGATION")
                            self.identiyServiceFailCount += 1
                            self.handleXtendAPIErrorNav(identifier: "xtendPlacementHelpWiFiWorksBestVC")
                        }
                    }
                }
                Logger.error("Failed to get Identity check with token!")
            }
        }
    }
    
    func fetchProactiveSingal()
    {
        isServiceProgress = true
        APIRequests.shared.getProActiveSignalAPIRequest("") { success, signalModel, error in
            self.isServiceProgress = false
            if success {
                if self.count == 0 {
                    self.count += 1
                    if self == self.navigationController?.topViewController {
                        self.scheduleServiceCall()
                    }
                }
                DispatchQueue.main.async {
                    Logger.info("The RSSI is \(signalModel?.rssi_cat ?? [])")
                    if let rssi = signalModel?.rssi_cat {
                        
                        switch (rssi[0],rssi[1]) {
                            
                        case ("good","weak"), ("good", "no signal"), ("good", "--"):
                            self.signalQualLbl.text = "This is a good spot!"
                            self.additionalText.text = "You can place the Extender here"
                            self.placementAnimation.animation = LottieAnimation.named("Proactive-placement-Green-Check")
                            self.placedXtendBtn.isHidden = false
                            self.noGoodSpot.isHidden = true
                            self.headerLbl.isHidden = true
                            
                        case ("too strong", _):
                            self.signalQualLbl.text = "A bit too close"
                            self.additionalText.text = "Please move further from your Gateway"
                            self.placementAnimation.animation = LottieAnimation.named("Proactive-placement-Red-cross")
                            self.placedXtendBtn.isHidden = true
                            self.noGoodSpot.isHidden = false
                            self.headerLbl.isHidden = false
                            if self.noGoodSpot.isSelected {
                                self.noGoodSpot.setTitle("I still can't find a good spot", for: .normal)
                            }
                            
                        case ("weak", _):
                            self.signalQualLbl.text = "A bit too far"
                            self.additionalText.text = "Please move closer to your network point"
                            self.placementAnimation.animation = LottieAnimation.named("Proactive-placement-Red-cross")
                            self.placedXtendBtn.isHidden = true
                            self.noGoodSpot.isHidden = false
                            self.headerLbl.isHidden = false
                            
                        case ("no signal", _):
                            Logger.info("The RSSI is \(rssi)")
                            self.placedXtendBtn.isHidden = true
                            self.noGoodSpot.isHidden = false
                            self.headerLbl.isHidden = false
                            
                        case ("good", _):
                            Logger.info("The RSSI is \(rssi)")
                            
                        default:
                            self.signalQualLbl.text = "This is a Not a good location."
                            self.placedXtendBtn.isHidden = true
                            self.noGoodSpot.isHidden = false
                            self.headerLbl.isHidden = false
                        }
                        self.placementAnimation.backgroundColor = .clear
                        self.placementAnimation.loopMode = rssi[0] == "good" ? .playOnce :
                            .loop
                        self.placementAnimation.animationSpeed = 1.0
                        self.placementAnimation.play()
                    }
                }
            } else {
                if error != nil {
                    if self.signalQualityAPIFail == 0 {
                        self.signalQualityAPIFail += 1
                        self.handleXtendAPIErrorNav(identifier: "xtendInstallAPIFailVC")
                    }
                }
            }
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.count = 0
    }
    
    func handleXtendAPIErrorNav (identifier: String) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        ExtenderDataManager.shared.extenderAPIFailure = true
        self.stopTimer()
    }
    
    @IBAction func noGoodSpotAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if noGoodSpot.isSelected {
            let vc = storyboard.instantiateViewController(withIdentifier: "noGoodSpotVC")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Logger.warning("No Good Spot button is selected")
            noGoodSpot.isSelected = true
            if let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpWiFiWorksBestVC") as? XtendPlacementHelpWiFiWorksBestVC
            {
//                vc.refreshDelegateHelperScreen = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func placedXtendBtnAction(_ sender: Any) {
        // self.navigationController?.popViewController(animated: true)
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pluginXtendVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        Logger.info("Great I placed the xtender button clicked")
    }
    @IBAction func proactiveScreenBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelAction(_ sender: Any) {
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
                cancelVC.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(cancelVC, animated: true)
            }
        } else{
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
                cancelVC.refreshDelegate = self
                cancelVC.modalPresentationStyle = .fullScreen
                self.present(cancelVC, animated: true)
            }
        }
    }
}
*/
