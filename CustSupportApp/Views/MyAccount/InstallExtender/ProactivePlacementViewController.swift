//
//  ProactivePlacementViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 4/28/23.
//

import UIKit
import Lottie
import SmartWiFi

protocol RefreshSignalProtocol {
    func refreshData()
}

class ProactivePlacementViewController: BaseViewController, RefreshSignalProtocol {
    // MARK: - IBOutlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textLabelStackView: UIStackView!
    //    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var badSignalAnimationView: LottieAnimationView!
    @IBOutlet weak var goodSignalAnimationView: LottieAnimationView!
    @IBOutlet weak var textLabelOne: UILabel!
    @IBOutlet weak var textLabelTwo: UILabel!
    @IBOutlet weak var noGoodSpotLink: UIButton!
    @IBOutlet weak var greatPlacedButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var buttonStackViewBottomConstraint: NSLayoutConstraint!
    
    var rssis: [String] = ["",""]
    let containerViews: [UIView] = []
    var isRequestInProgress: Bool = false
    weak var signalTimer: Timer?
    var count = 0
    var identiyRequestFailCount = 0
    var signalQualityAPIFailCount = 0
    var greenCheckPlayed: Bool = false
    //    var transitionDone = false
    enum AnimationContext: String {
        case good = "Proactive-placement-Green-Check"
        case bad = "Proactive-placement-Red-cross"
        case loading = "Proactive-placement-Blue-stroke-Ripple"
    }
    enum SignalState {
        case good
        case bad(stateMessage: String, subStateMsg: String)
        case load
    }
    func refreshData() {
        getIdentityCheck()
        Logger.info("Get Identity local method called [-]")
    }
    // MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setup the UI
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        getIdentityCheck()
    }
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
        goodSignalAnimationView.animation = nil
    }
    override func viewDidDisappear(_ animated: Bool) {
        APIRequests.shared.logoutSession()
        Logger.info("viewDidDisappear")
    }
    // MARK: - Action methods
    @IBAction func greatPlacedButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pluginXtendVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        Logger.info("Great I placed the xtender button clicked")
    }
    @IBAction func noGoodSpotLinkAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if noGoodSpotLink.isSelected {
            let vc = storyboard.instantiateViewController(withIdentifier: "noGoodSpotVC")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Logger.warning("No Good Spot button is selected")
            noGoodSpotLink.isSelected = true
            if let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpWiFiWorksBestVC") as? XtendPlacementHelpWiFiWorksBestVC
            {
                vc.refreshDelegateHelperScreen = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    // MARK: - custom methods
    func setupUI() {
        //HeaderLabel
        headerLabel.isHidden = false
        //AnimationViews[1,2]
        goodSignalAnimationView.isHidden = true
        badSignalAnimationView.isHidden = false
        playAnimation(animationView: badSignalAnimationView,AnimationContext.loading.rawValue)
        //TextLabels[1,2]
        textLabelOne.text = ""
        textLabelTwo.text = ""
        rssis = ["",""]
        buttonStackView.isHidden = true
        //Buttons[1,2]
    }
    
    func getIdentityCheck() {
        //checking for identity check...
        APIRequests.shared.getIdentity { isSuccess, error in
            if isSuccess == true {
                Logger.info("getIdentity API is successful with a token!")
                if self == self.navigationController?.topViewController {
                    self.fetchSignalQuality()
                }
            } else {
                if error != nil {
                    if self.identiyRequestFailCount < 2 {
                        self.identiyRequestFailCount += 1
                        self.getIdentityCheck()
                    } else {
                        if self.identiyRequestFailCount == 2 {
                            Logger.info("ERROR NAVIGATION")
                            self.identiyRequestFailCount += 1
                            self.handleXtendAPIErrorNav(identifier: "xtendPlacementHelpWiFiWorksBestVC")
                        }
                    }
                }
                Logger.error("Failed to get Identity check with token!")
            }
        }
    }
    func fetchSignalQuality() {
        isRequestInProgress = true
        APIRequests.shared.getProActiveSignalAPIRequest("") { success, signalModel, error in
            self.isRequestInProgress = false
            if success {
                if self.count == 0 {
                    self.count += 1
                    if self == self.navigationController?.topViewController {
                        self.scheduleServiceCall()
                    }
                }
                
                DispatchQueue.main.async {
                    Logger.info("The RSSI is \(signalModel?.rssi_cat ?? [])", sendLog:"ProActive Signal API request success")
                    if let rssi = signalModel?.rssi_cat {
                        switch (rssi[0],rssi[1]) {
                        case ("good", _):
                            if rssi[0] != self.rssis[0] || rssi[1] != self.rssis[1]{
                                if rssi[1] == "too strong" {
                                    self.greenCheckPlayed = false
                                    self.updateSubviews(state:.bad(stateMessage: "A bit too close", subStateMsg: "Please move further from your Gateway"))
                                } else {
                                    self.updateSubviews(state: .good)
                                }
                            }
                        case ("too strong", _):
                            if rssi[0] != self.rssis[0] {
                                self.updateSubviews(state:.bad(stateMessage: "A bit too close", subStateMsg: "Please move further from your Gateway"))
                            }
                        case ("weak", _):
                            if rssi[0] != self.rssis[0] {
                                self.updateSubviews(state: .bad(stateMessage:"A bit too far",subStateMsg:"Please move closer to your network point"))
                            }
                        case ("no signal", _):
                            if rssi[0] != self.rssis[0] {
                                self.updateSubviews(state: .load)
                            }
                        default:
                            self.greenCheckPlayed = false
                            self.textLabelOne.text = "This is a Not a good location."
                            self.greatPlacedButton.isHidden = true
                            self.noGoodSpotLink.isHidden = false
                            self.headerLabel.isHidden = false
                            self.playAnimation(animationView: self.badSignalAnimationView, AnimationContext.bad.rawValue)
                        }
                        self.rssis = rssi
                    }
                }
            } else {
                if error != nil {
                    if self.signalQualityAPIFailCount == 0 {
                        self.signalQualityAPIFailCount += 1
                        self.handleXtendAPIErrorNav(identifier: "xtendInstallAPIFailVC")
                    }
                }
            }
        }
    }
    func scheduleServiceCall() {
        self.signalTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.signalTimer = timer
            if self.navigationController?.topViewController != nil &&  ((self.navigationController?.topViewController?.isKind(of: ProactivePlacementViewController.self)) != nil){
                if self.isRequestInProgress == false && self == self.navigationController?.topViewController {
                    //                    self.fetchProactiveSignals()
                    self.fetchSignalQuality()
                }
            }
        }
    }
    func handleXtendAPIErrorNav (identifier: String) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        ExtenderDataManager.shared.extenderAPIFailure = true
        self.stopTimer()
    }
    func stopTimer() {
        self.signalTimer?.invalidate()
        self.signalTimer = nil
        self.count = 0
    }
    func playAnimation(animationView: LottieAnimationView, _ string: String) {
        animationView.animation = LottieAnimation.named(string)
        animationView.backgroundColor = .clear
        animationView.animationSpeed = 1.0
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
        self.fadeInView(view: self.textLabelStackView)
        self.fadeInView(view: self.buttonStackView)
    }
    func playCheckMarkAnimation(animationView: LottieAnimationView, _ string: String) {
        animationView.animation = LottieAnimation.named(string)
        animationView.backgroundColor = .clear
        animationView.animationSpeed = 1.0
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion: {
            (finished) in
            if finished {
                self.greenCheckPlayed = true
                self.fadeInView(view: self.textLabelStackView)
                self.slideupView(view: self.buttonStackView)
            } else {
                
            }
        })
    }
    func updateSubviews(state: SignalState) {
        switch state {
        case .good:
            headerLabel.isHidden = true
            textLabelStackView.alpha = 0.0
            textLabelStackView.isHidden = false
            badSignalAnimationView.isHidden = true
            goodSignalAnimationView.isHidden = false
            self.badSignalAnimationView.isHidden = true
            self.goodSignalAnimationView.isHidden = false
            textLabelOne.text = "This is a good spot!"
            textLabelTwo.text = "You can place the Extender here"
            playCheckMarkAnimation(animationView: self.goodSignalAnimationView, AnimationContext.good.rawValue)
            buttonStackView.isHidden = false
            greatPlacedButton.isHidden = false
            buttonStackViewBottomConstraint.constant = -120.0
            noGoodSpotLink.isHidden = true
            trackAnalyticsForProactivePlacement(.good)
        case .bad(let stateMsg, let subStateMsg):
            greenCheckPlayed = false
            headerLabel.isHidden = false
            textLabelStackView.isHidden = false
            textLabelOne.text = stateMsg
            textLabelTwo.text = subStateMsg
            greatPlacedButton.isHidden = true
            noGoodSpotLink.isHidden = false
            self.badSignalAnimationView.isHidden = false
            self.goodSignalAnimationView.isHidden = true
            playAnimation(animationView: self.badSignalAnimationView, AnimationContext.bad.rawValue)
            if noGoodSpotLink.isSelected && stateMsg.contains("A bit too close") {
                noGoodSpotLink.setTitle("I still can't find a good spot", for: .normal)
                noGoodSpotLink.isSelected = true
            } else {
                noGoodSpotLink.isSelected = false
            }
            buttonStackView.isHidden = false
            trackAnalyticsForProactivePlacement(.bad(stateMessage: stateMsg, subStateMsg: subStateMsg))
        case .load:
            greenCheckPlayed = false
            headerLabel.isHidden = false
            textLabelStackView.isHidden = true
            greatPlacedButton.isHidden = true
            buttonStackView.isHidden = true
            badSignalAnimationView.isHidden = false
            goodSignalAnimationView.isHidden = true
            playAnimation(animationView: self.badSignalAnimationView, AnimationContext.loading.rawValue)
        }
    }
    // MARK: - Transition methods
    func fadeInView(view: UIView) {
        view.alpha = 0.0
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       animations:{
            view.alpha = 1.0
        }, completion: nil)
    }
    func fadeOutView(view: UIView) {
        view.alpha = 1.0
        UIView.animate(withDuration:0.2,
                       delay:0.1,
                       animations: {
            view.alpha = 0.0
        }, completion: nil)
    }
    func slideupView(view: UIView) {
        greatPlacedButton.isHidden = false
        UIView.animate(withDuration:1.0,
                       delay: 0.05,
                       animations: {
            self.buttonStackViewBottomConstraint.constant = 30.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    }
    // MARK: - Transition methods
    func trackAnalyticsForProactivePlacement(_ state: SignalState) {
        var screenName = ""
        switch state {
            
        case .good:
            screenName = ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_goodspot.extenderTitleWifi6
        case .bad(stateMessage: let stateMsg, subStateMsg: _):
            if stateMsg.contains("A bit too close") && !noGoodSpotLink.isSelected {
                screenName = ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_too_close.extenderTitleWifi6
            } else if stateMsg.contains("A bit too close") && noGoodSpotLink.isSelected {
                screenName = ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_too_close_still_cant_find_good_spot.extenderTitleWifi6
            }
            else {
                screenName = ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_too_far.extenderTitleWifi6
            }
        case .load:
            break
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenName, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
}
