//
//  CheckOutageStatusViewController.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam
//

import Lottie
import UIKit

class CheckOutageStatusViewController: UIViewController {
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var header: UILabel!
    @IBOutlet weak var secondryLabel: UILabel!
    @IBOutlet var animationViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonMaybeLater: UIButton!
    @IBOutlet weak var buttonRunTest: RoundedButton!
    @IBOutlet weak var viewClose: UIView!
    var cardData: SpotLightCardsGetResponse.CardData?
    
    var isOutageDetected = false
    var isGateWayOnline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUIsetup()
        self.initiateGatewayStatus()
    }
    
    func initialUIsetup() {
        header.text = "Before running a speed test, let's make sure there are no outages in your area"
        animationViewCenterConstraint.constant = currentScreenWidth
        animationView.frame.origin.x = currentScreenWidth
        header.setLineHeight(1.2)
        header.textAlignment = .left
        secondryLabel.setLineHeight(1.2)
        secondryLabel.textAlignment = .left
        self.buttonRunTest.isHidden = true
        self.buttonMaybeLater.isHidden = true
        self.secondryLabel.isHidden = true
        buttonMaybeLater.layer.borderWidth = 1
        buttonMaybeLater.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //For Firebase Analytics
        trackGATag(eventName:SpeedTestScreenDetails.SPEEDTEST_CHECK_FOR_OUTAGE.rawValue)
    }
    
    //MARK: Track GA event methods
    //CMAIOS-2559
    func trackGATag(eventName:String){
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : eventName, CUSTOM_PARAM_FIXED : Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func trackOnClickEvent(btnClickEventName:String){
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : btnClickEventName,
                        EVENT_SCREEN_NAME: SpeedTestScreenDetails.SPEEDTEST_CHECK_FOR_OUTAGE_YES_OUTAGE_IN_AREA.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.WiFi.rawValue]
        )
    }
    //-----------------
    
    func checkOutageStatus() {
        APIRequests.shared.mauiGetSpotLightCards(flowType: (true, self.isGateWayOnline), completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.animationView.play(toProgress: 1.0, loopMode: .playOnce, completion: {_ in
                        guard let cardInfo = MyWifiManager.shared.checkForOutagesWithSpotLight("Internet") else {
                            self.isOutageDetected = false
                            self.showNoOutageScreen()
                            return
                        }
                        self.cardData = cardInfo
                        self.isOutageDetected = true
                        self.showOutageScreen()
                        /*
                        if cardInfo.priorityKey == "1.1" && cardInfo.button?.template == "midnightblue" {
                            self.cardData = cardInfo
                            self.isOutageDetected = true
                            self.showOutageScreen()
                        } else {
                            self.isOutageDetected = false
                            self.showNoOutageScreen()
                        }
                        */
                    })
                } else {
                    self.showErrorMessageVC()
                }
            }
        })
    }
    
    func initiateGatewayStatus() {
        self.playAnimationAndCallOutageAPI()
        guard let deviceMAC = MyWifiManager.shared.deviceMAC, let deviceType = MyWifiManager.shared.deviceType else {
            //Gateway is offline
            self.isGateWayOnline = false
            self.showErrorMessageVC()
            return
        }
        let mapString = "\(deviceMAC)?devicetype=" + deviceType
        APIRequests.shared.isRebootOccured = true
        if !MyWifiManager.shared.accessTech.isEmpty, MyWifiManager.shared.accessTech == "gpon" {
            APIRequests.shared.initiateGatewayStatusAPIRequestForFiber(mapString) { success, response, error in  //CMAIOS-2508
                if let operationalStatusResponse = response, let operationalStatus = operationalStatusResponse.operationalStatus, !operationalStatus.isEmpty, let cmStatus = operationalStatus.lowercased() as String? {
                    self.performRestartOperation(cmStatus: cmStatus)
                    self.checkOutageStatus()
                } else {
                    self.showErrorMessageVC()
                }
            }
        } else {
            APIRequests.shared.initiateGatewayStatusAPIRequest(mapString) { success, response, error in
                //CMAIOS-2508
                if let operationalStatusResponse = response, let operationalStatus = operationalStatusResponse.cm, let cmtsInfo = operationalStatus.cmtsInfo,  let cmStatus = cmtsInfo.cmStatus, !cmStatus.isEmpty, let status = cmStatus.lowercased() as String? {
                    self.performRestartOperation(cmStatus: status)
                    self.checkOutageStatus()
                } else {
                    self.showErrorMessageVC()
                }
            }
        }
    }
    
    func performRestartOperation(cmStatus: String) {
        APIRequests.shared.isRebootOccured = false
        if cmStatus.contains("operational") || cmStatus.contains("online") {
            self.isGateWayOnline = true
        }
    }
    
    func showNoOutageScreen() {
        /*
        IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.checkIntSpeed
        guard let nav = UIViewController.instantiate(from: .speedTest) else { return }
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
         */
        self.isOutageDetected = false
        self.animationView.animation = nil
        self.animationView.animation = LottieAnimation.named("NoOutage")
        self.animationView.loopMode = .playOnce
        self.animationView.animationSpeed = 1.0
        self.animationView.play { _ in
            self.buttonRunTest.setTitle("Run speed test", for: .normal)
            self.buttonRunTest.isHidden = false
            self.viewClose.isHidden = false
            self.header.text = "No outages found in your area!"
            self.secondryLabel.isHidden = true
            self.trackGATag(eventName: SpeedTestScreenDetails.SPEEDTEST_CHECK_FOR_OUTAGE_NO_OUTAGE_IN_AREA.rawValue)
        }
    }
    
    func showOutageScreen() {
        if self.isGateWayOnline == true {
            self.animationView.animation = nil
            self.animationView.animation = LottieAnimation.named("Outage")
            self.animationView.loopMode = .playOnce
            self.animationView.animationSpeed = 1.0
            self.animationView.play { _ in
                self.header.text = "There's an outage in your area"
                self.secondryLabel.isHidden = false
                self.secondryLabel.text = "This may be affecting your Internet speed."
                self.buttonRunTest.setTitle("I still want to run speed test", for: .normal)
                self.buttonRunTest.isHidden = false
                self.buttonMaybeLater.isHidden = false
                self.viewClose.isHidden = true
            }
            //CMAIOS-2559
            self.trackGATag(eventName: SpeedTestScreenDetails.SPEEDTEST_CHECK_FOR_OUTAGE_YES_OUTAGE_IN_AREA.rawValue)
        } else {
            self.animationView.animation = nil
            self.animationView.animation = LottieAnimation.named("Outage")
            self.animationView.loopMode = .playOnce
            self.animationView.animationSpeed = 1.0
            self.animationView.play { _ in
                self.header.text = "There's an outage in your neighborhood"
                self.secondryLabel.isHidden = false
                self.secondryLabel.text = "We're sorry about the inconvenience."
                self.buttonRunTest.setTitle("More info", for: .normal)
                self.buttonRunTest.isHidden = false
                self.buttonMaybeLater.isHidden = true
                self.viewClose.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func playAnimationAndCallOutageAPI() {
        self.animationView.animation = LottieAnimation.named("MagnifyingGlass")
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 1.0
        self.animationView.play()
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        if isOutageDetected == true && self.isGateWayOnline == false {
            if self.navigationController?.viewControllers.filter({$0 is AdvancedSettingsUIViewController}).first is AdvancedSettingsUIViewController {
                self.navigationController?.dismiss(animated: true)
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionPrimaryButton(_ sender: Any) {
        switch (self.isOutageDetected, self.isGateWayOnline) {
        case (true, true), (false, true):
            if isOutageDetected == true && self.isGateWayOnline == true {
                //CMAIOS-2559
                self.trackOnClickEvent(btnClickEventName: SpeedTestScreenDetails.OUTAGE_IN_AREA_IS_STILL_WANT_TO_RUN_SPEED_TEST.rawValue)
            }
            IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.checkIntSpeed
            guard let nav = UIViewController.instantiate(from: .speedTest) else { return }
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        case (true, false):
            self.navigateToOutageMoreInfo(cardData: self.cardData)
        default: break
        }
        
        /*
         if isOutageDetected == true {
         if self.isGateWayOnline == true {
         IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.checkIntSpeed
         guard let nav = UIViewController.instantiate(from: .speedTest) else { return }
         nav.modalPresentationStyle = .fullScreen
         self.present(nav, animated: true)
         } else {
         self.navigateToOutageMoreInfo(cardData: self.cardData)
         }
         }
         */
    }
    
    func navigateToOutageMoreInfo(cardData: SpotLightCardsGetResponse.CardData?) {
        guard let outageDetails = OutageDetailsVC.instantiateWithIdentifier(from: .Outage) else { return }
        if let spotlightCardData = cardData, let moreInfo = spotlightCardData.moreInfo {
            outageDetails.screenDetails = moreInfo
        }
        self.navigationController?.pushViewController(outageDetails, animated: true)
    }
    
    @IBAction func actionSecondaryButton(_ sender: Any) {
        //CMAIOS-2559
        self.trackOnClickEvent(btnClickEventName: SpeedTestScreenDetails.OUTAGE_IN_AREA_MAY_BE_LATER.rawValue)
        self.navigationController?.popViewController(animated: true)
    }
    
    func showErrorMessageVC() {
        DispatchQueue.main.async {
            APIRequests.shared.isRebootOccured = false
            guard let vc = OutageDetectionFailedViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
