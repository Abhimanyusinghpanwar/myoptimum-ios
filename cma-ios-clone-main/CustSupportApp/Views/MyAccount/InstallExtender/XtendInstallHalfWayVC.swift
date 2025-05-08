//
//  XtendInstallHalfWayVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/9/22.
//  CMAIOS-159
// GA extender5_halfway_one_extender/extender5_halfway_multiple_extenders

import UIKit
import Lottie
import Network

class XtendInstallHalfWayVC: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {}
    
    @IBOutlet weak var xtendHalfWayAnimationView: LottieAnimationView!
    @IBOutlet weak var xtendHalfWayHeaderLbl: UILabel!
    @IBOutlet weak var xtendHalfWayStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendHalfWayStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallHalfWayBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendHalfwayLoadingAnimationView: LottieAnimationView!
    @IBOutlet weak var xtendHalfwayPrimaryBtn: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateXtendHalfWayUI()
        setupAnimationView()
        setupXtendHalfwayPrimaryBtn(hide: false)
    }
    
    func updateXtendHalfWayUI() {
        let onlineXtends = MyWifiManager.shared.getOnlineExtenders()
        if onlineXtends.count >= 1 {
            self.xtendHalfWayAnimationView.animation = (ExtenderDataManager.shared.extenderType == 7) ? LottieAnimation.named("Gateway6E-weak-WiFi-Floor") : LottieAnimation.named("Weak-WiFi-Floor")
            xtendHalfWayHeaderLbl.text = "Bring your Extender and power cable to a spot that's halfway between a network point and where you need WiFi"
        } else {
            self.xtendHalfWayAnimationView.animation = (ExtenderDataManager.shared.extenderType == 7) ? LottieAnimation.named("Gateway6E-weak-WiFi-Walls") : LottieAnimation.named("Weak_WiFi_Walls")
            xtendHalfWayHeaderLbl.text = "Bring your Extender and power cable to a spot that's halfway between your Gateway and where you need WiFi"
        }
        
        self.xtendHalfWayAnimationView.backgroundColor = .clear
        self.xtendHalfWayAnimationView.loopMode = .playOnce
        self.xtendHalfWayAnimationView.animationSpeed = 1.0
        self.xtendHalfWayAnimationView.backgroundBehavior = .pauseAndRestore
        self.xtendHalfWayAnimationView.play()
        Logger.info("The online extender(s) : \(onlineXtends.count)")
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow){
            xtendHalfWayStackViewLeadingConstraint.constant = 30.0
            xtendHalfWayStackViewTrailingConstraint.constant = 30.0
            xtendHalfWayHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendHalfWayHeaderLbl.setLineHeight(1.21)
        } else {
            xtendHalfWayHeaderLbl.setLineHeight(1.15)
        }
        let screenTag: String = (onlineXtends.count >= 1 ? ExtenderInstallScreens.ExtenderType.extender5_halfway_multiple_extenders.extenderTitle : ExtenderInstallScreens.ExtenderType.extender5_halfway_one_extender.extenderTitle)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    
    func setupAnimationView() {
        xtendHalfwayLoadingAnimationView.animation = LottieAnimation.named("OrangeFullWidthButton")
        xtendHalfwayLoadingAnimationView.loopMode = .playOnce
    }
    
    func setupXtendHalfwayPrimaryBtn(hide: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.xtendHalfwayPrimaryBtn.isHidden = hide
            self.xtendHalfwayLoadingAnimationView.isHidden = !hide
        }
    }
    
    @IBAction func xtendHalfWayPrimaryBtnAction(_ sender: Any) {
        setupXtendHalfwayPrimaryBtn(hide: true)
        xtendHalfwayLoadingAnimationView.play(toProgress: 0.11, loopMode: .none) { _ in
            self.xtendHalfwayLoadingAnimationView.loopMode = .loop
            self.xtendHalfwayLoadingAnimationView.play(fromProgress: 0.11, toProgress: 0.61) { _ in }
        }
        delay(seconds: 1.1) {
            self.makeInHomeAPICall()
        }
    }
    
    func makeInHomeAPICall() {
        if ExtenderDataManager.shared.extenderType == 5 {
            navigateNext(identifier: "xtendPlacementHelpWiFiWorksBestVC")
        } else {
            APIRequests.shared.checkHomeIP { success, response, error in
                
                DispatchQueue.main.async {
                    if success {
                        Logger.info("The in home check Response is \(String(describing: response))", sendLog: "The In home check success")
                        if response?.isInHome == true {
                            //                            self.navigateNext(identifier: "xtendInstallDevicePermissionsVC")
                            ExtenderDataManager.shared.extenderHomeNetwork = true
                            self.selectXtendNavigationForPermissions()
                            return
                        }
                    }
                    self.navigateNext(identifier: "xtendConnectToHomeNetworkVC")
                }
            }
        }
    }
    
    func selectXtendNavigationForPermissions() {
        let isPermissionGiven = PreferenceHandler.getValuesForKey("localNetwork")
        if isPermissionGiven == nil {
            navigateNext(identifier: "xtendInstallDevicePermissionsVC")
        } else {
            checkLANFromXtendHalfwayVC()
        }
    }
    
    func navigateNext(identifier: String) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        xtendHalfwayLoadingAnimationView.pause()
        xtendHalfwayLoadingAnimationView.play(fromProgress: self.xtendHalfwayLoadingAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func checkLANFromXtendHalfwayVC() {
        let connection = NWConnection(host: "192.168.1.1", port: 0, using: .tcp)
        if sharedConnection != nil  {
            sharedConnection?.cancel()
        }
        sharedConnection = LocalNetworkConnection(delegate: self, localConnection: connection, connectionStarted: true)
    }
    
    func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    }
}

extension XtendInstallHalfWayVC: LocalNetworkConnectionDelegate {
    func localConnection(isAvailable: Bool, error: NWError?) {
        sharedConnection?.cancel()
        if isAvailable == true {
            navigateNext(identifier: "proactivePlacementViewController")
        } else {
            navigateNext(identifier: "xtendInstallDeviceSettingsVC")
        }
    }
}
