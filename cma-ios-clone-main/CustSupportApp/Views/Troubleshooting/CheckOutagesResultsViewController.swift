//
//  CheckOutagesResultsViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 09/01/23.
//

import UIKit
import Lottie
import SafariServices
class CheckOutagesResultsViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var animatedView: LottieAnimationView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var letsFixButton: RoundedButton!
    @IBOutlet weak var secondryLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var lcImgToTxt: NSLayoutConstraint!
    @IBOutlet weak var lcImgHeight: NSLayoutConstraint!
    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonMaybeLater: UIButton!
    @IBOutlet weak var viewClose: UIView!

    var isFromDeviceAnimation = false
    var isTappingLetsFixButton = false
    var saveInProgress = false
    var isInitialAnimationEnds = false
    var isOutageDetected = false
    var isGateWayOnline = false
    var cardData: SpotLightCardsGetResponse.CardData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //updateUIInitialConstraints()
        APIRequests.shared.isReloadNotRequiredForMaui = true
        self.headerLabel.setLineHeight(1.2)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_TROUBLE_WITH_INTERNET.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                 CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue,
                                                                   EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
//    func updateUIInitialConstraints() {
//        self.closeTopConstraint.constant = CurrentDevice.forLargeSpotlights() ? 30 : 20
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        closeTopConstraint.constant = -150
        //This condition is to satisy for the SE 1st Gen.
        if (UIScreen.main.bounds.size.height == 568)
        {
            self.img.contentMode = .scaleAspectFit
            self.lcImgHeight.constant = 225
        }
        buttonMaybeLater.layer.borderWidth = 1
        buttonMaybeLater.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        performTransition()
    }
    
    func performTransition() {
        animatedView.alpha = 0.4
        headerLabel.alpha = 0.4
        secondryLabel.alpha = 0.4
        letsFixButton.alpha = 0.4
        UIView.animate(withDuration: 0.6) {
            self.animatedView.alpha = 1.0
            self.headerLabel.alpha = 1.0
            self.secondryLabel.alpha = 1.0
            self.letsFixButton.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.4) {
                self.closeTopConstraint.constant = 30
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func initiateGatewayStatus() {
        guard let deviceMAC = MyWifiManager.shared.deviceMAC, let deviceType = MyWifiManager.shared.deviceType else {
            //Gateway is offline
            self.isGateWayOnline = false
            self.showErrorMessageVC()
            return
        }
        let mapString = "\(deviceMAC)?devicetype=" + deviceType
        APIRequests.shared.isRebootOccured = true
        if !MyWifiManager.shared.accessTech.isEmpty, MyWifiManager.shared.accessTech == "gpon" {
            APIRequests.shared.initiateGatewayStatusAPIRequestForFiber(mapString) { success, response, error in //CMAIOS-2508
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
        
        if !self.isFromDeviceAnimation {
            self.animatedView.backgroundColor = .clear
            self.animatedView.animation = LottieAnimation.named("OutageMap")
            self.animatedView.loopMode = .playOnce
            self.animatedView.animationSpeed = 1.0
            self.animatedView.play {_ in
                if !self.isInitialAnimationEnds {
                    self.animatedView.animation = LottieAnimation.named("MagnifyingGlass")
                    self.animatedView.loopMode = .loop
                    self.animatedView.animationSpeed = 1.0
                    self.animatedView.play()
                }
            }
        }
        self.headerLabel.isHidden = false
        self.headerLabel.text = "First let’s check to make sure there are no outages in your area"
        self.headerLabel.font = UIFont(name: "Regular-Bold", size: 24)
        self.img.isHidden = true
    }
    
    func verifyOutageAndGateWayStatus() {
        self.animatedView.play( toProgress: 1.0, loopMode: .playOnce, completion: {_ in
            guard let cardInfo = MyWifiManager.shared.checkForOutagesWithSpotLight("Internet") else {
                self.isOutageDetected = false
                self.showNoOutageUI()
                return
            }
            self.cardData = cardInfo
            self.isOutageDetected = true
            self.showOutageScreen()
            /*
            if let cardInfo.priorityKey == "1.1" && cardInfo.button?.template == "midnightblue" {
                self.cardData = cardInfo
                self.isOutageDetected = true
                self.showOutageScreen()
            } else {
                self.isOutageDetected = false
                self.showNoOutageUI()
            }
             */
        })
    }
    
    func performRestartOperation(cmStatus: String) {
        APIRequests.shared.isRebootOccured = false
        if cmStatus.contains("operational") || cmStatus.contains("online") {
            self.isGateWayOnline = true
        }
    }
    
    /*
     func viewAnimationSetUp() {
     APIRequests.shared.mauiOutageAlertRequest(interceptor: nil) { success, value, error in
     DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
     if success {
     self.animatedView.play( toProgress: 1.0, loopMode: .playOnce, completion: {_ in
     QuickPayManager.shared.modelQuickPayeOutage = value
     MyWifiManager.shared.checkForOutages()
     if MyWifiManager.shared.outageTitle.isEmpty || MyWifiManager.shared.outageTitle == "RECENTLY_CLEARED" {
     CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_OUTAGE_NOT_FOUND.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
     self.isOutageDetected = false
     self.isInitialAnimationEnds = true
     self.animatedView.animation = nil
     self.animatedView.animation = LottieAnimation.named("NoOutage")
     self.animatedView.loopMode = .playOnce
     self.animatedView.animationSpeed = 1.0
     self.animatedView.play { _ in
     self.letsFixButton.setTitle("Let’s keep digging", for: .normal)
     self.letsFixButton.isHidden = false
     self.closeButton.isHidden = false
     self.headerLabel.text = "No outages found in your area!"
     self.secondryLabel.isHidden = true
     }
     } else if MyWifiManager.shared.outageTitle == "OUTAGE_ON_ACCOUNT" {
     CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_OUTAGE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
     self.isOutageDetected = true
     self.isInitialAnimationEnds = true
     self.animatedView.animation = nil
     self.animatedView.animation = LottieAnimation.named("Outage")
     self.animatedView.loopMode = .playOnce
     self.animatedView.animationSpeed = 1.0
     self.animatedView.play { _ in
     self.letsFixButton.setTitle("More info", for: .normal)
     self.letsFixButton.isHidden = false
     self.closeButton.isHidden = false
     self.headerLabel.text = "There’s an outage in your area"
     self.secondryLabel.isHidden = false
     self.secondryLabel.text = "We’re sorry about the inconvenience."
     }
     }
     })
     } else {
     guard let vc = OutageDetectionFailedViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
     self.navigationController?.navigationBar.isHidden = true
     self.navigationController?.pushViewController(vc, animated: true)
     }
     }
     }
     if !self.isFromDeviceAnimation {
     self.animatedView.backgroundColor = .clear
     self.animatedView.animation = LottieAnimation.named("OutageMap")
     self.animatedView.loopMode = .playOnce
     self.animatedView.animationSpeed = 1.0
     self.animatedView.play{_ in
     if !self.isInitialAnimationEnds {
     self.animatedView.animation = LottieAnimation.named("MagnifyingGlass")
     self.animatedView.loopMode = .loop
     self.animatedView.animationSpeed = 1.0
     self.animatedView.play()
     }
     }
     }
     self.headerLabel.isHidden = false
     self.headerLabel.text = "First let’s check to make sure there are no outages in your area"
     self.headerLabel.font = UIFont(name: "Regular-Bold", size: 24)
     self.img.isHidden = true
     
     }
     */
    
    func checkOutageStatus() {
        APIRequests.shared.mauiGetSpotLightCards(flowType: (true, self.isGateWayOnline), completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.verifyOutageAndGateWayStatus()
                } else {
                    self.showErrorMessageVC()
                }
            }
        })
    }
        
    @IBAction func letsFixAction(_ sender: Any) {
        if !self.isTappingLetsFixButton {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_CHECK_OUTAGE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            saveInProgress = true
            isTappingLetsFixButton = true
            self.viewClose.isHidden = true
            self.headerLabel.isHidden = true
            letsFixButton.isHidden = true
            self.secondryLabel.isHidden = true
            self.img.isHidden = true
            self.initiateGatewayStatus()
            self.headerLabel.setLineHeight(1.2)
        } else {
            
            switch (self.isOutageDetected, self.isGateWayOnline) {
            case (true, true), (false, true):
                //CMAIOS-2559
                if self.isOutageDetected && self.isGateWayOnline {
                    self.trackOnClickEvent(btnClickEventName: Troubleshooting.I_WANT_TO_TS_OUTAGE_IN_AREA.rawValue)
                }
                let vc = UIStoryboard(name: "TroubleshootInternet", bundle: Bundle.main).instantiateViewController(withIdentifier: "TroubleshootingDiagnoseViewController") as! TroubleshootingDiagnoseViewController
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (true, false): // More info
                self.navigateToOutageMoreInfo(cardData: self.cardData)
            default:
                let urlString = "https://www.optimum.net/support/outage/#/PmModemsOnline"
                self.navigateToInAppBrowser(urlString, title: "")
            }
        }
    }
    
    func navigateToOutageMoreInfo(cardData: SpotLightCardsGetResponse.CardData?) {
        guard let outageDetails = OutageDetailsVC.instantiateWithIdentifier(from: .Outage) else { return }
        if let spotlightCardData = cardData, let moreInfo = spotlightCardData.moreInfo {
            outageDetails.screenDetails = moreInfo
        }
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(outageDetails, animated: true)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if isOutageDetected == true && self.isGateWayOnline == false { // CMAIOS-2505
            if let myWifi = self.presentingViewController as? MyWiFiViewController {
                myWifi.homeScreenWillAppear = true
                DispatchQueue.main.async {
                    self.dismiss(animated: false) {
                        myWifi.dismiss(animated: true)
                    }
                }
                return
            }
        }
        
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.dismissCompletion = { (dismiss) in
                self.navigateToMyAccountScreen(fromVC: self)
            }
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    @IBAction func actionMayBeLater(_ sender: Any) {
        if isOutageDetected == true && self.isGateWayOnline == true { // CMAIOS-2509
            //CMAIOS-2559
            self.trackOnClickEvent(btnClickEventName: Troubleshooting.MAY_BE_LATER_OUTAGE_IN_AREA.rawValue)
            if self.navigationController?.viewControllers.filter({$0 is CheckOutagesResultsViewController}).first is CheckOutagesResultsViewController {
                self.navigationController?.dismiss(animated: true)
                return
            }
        }
        self.navigationController?.dismiss(animated: true)
    }
    
    func showErrorMessageVC() {
        DispatchQueue.main.async {
            APIRequests.shared.isRebootOccured = false
            guard let vc = OutageDetectionFailedViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showOutageScreen() {
        var eventName = ""
        if self.isGateWayOnline == false {
            eventName = Troubleshooting.TS_THERES_AN_OUTAGE_IN_YOUR_AREA.rawValue
            self.isOutageDetected = true
            self.isInitialAnimationEnds = true
            self.animatedView.animation = nil
            self.animatedView.animation = LottieAnimation.named("Outage")
            self.animatedView.loopMode = .playOnce
            self.animatedView.animationSpeed = 1.0
            self.animatedView.play { _ in
                self.letsFixButton.setTitle("More info", for: .normal)
                self.letsFixButton.isHidden = false
                self.viewClose.isHidden = false
                self.headerLabel.text = "There's an outage in your neighborhood"
                self.secondryLabel.isHidden = false
                self.secondryLabel.text = "We're sorry about the inconvenience"
            }
        }else {
            eventName = Troubleshooting.TS_THERES_AN_OUTAGE_IN_YOUR_AREA_IS_STILL_WANT_TO_TS.rawValue
            self.isOutageDetected = true
            self.isInitialAnimationEnds = true
            self.animatedView.animation = nil
            self.animatedView.animation = LottieAnimation.named("Outage")
            self.animatedView.loopMode = .playOnce
            self.animatedView.animationSpeed = 1.0
            self.animatedView.play { _ in
                self.letsFixButton.setTitle("I still want to troubleshoot", for: .normal)
                self.letsFixButton.isHidden = false
                self.buttonMaybeLater.setTitle("Maybe later", for: .normal)
                self.buttonMaybeLater.isHidden = false
                self.viewClose.isHidden = true
                self.headerLabel.text = "There's an outage in your area"
                self.secondryLabel.isHidden = false
                self.secondryLabel.text = "This may be affecting your Internet service."
            }
        }
        trackGATag(eventName: eventName)
    }
    
    //MARK: track GA events
    //CMAIOS-2559
    func trackGATag(eventName:String){
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : eventName, CUSTOM_PARAM_FIXED : Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func trackOnClickEvent(btnClickEventName:String){
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : btnClickEventName,
                        EVENT_SCREEN_NAME: Troubleshooting.TS_THERES_AN_OUTAGE_IN_YOUR_AREA_IS_STILL_WANT_TO_TS.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.WiFi.rawValue]
        )
    }
    //--------------
    
    func showNoOutageUI() {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_OUTAGE_NOT_FOUND.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        self.isOutageDetected = false
        self.isInitialAnimationEnds = true
        self.animatedView.animation = nil
        self.animatedView.animation = LottieAnimation.named("NoOutage")
        self.animatedView.loopMode = .playOnce
        self.animatedView.animationSpeed = 1.0
        self.animatedView.play { _ in
            self.letsFixButton.setTitle("Let’s keep digging", for: .normal)
            self.letsFixButton.isHidden = false
            self.viewClose.isHidden = false
            self.headerLabel.text = "No outages found in your area!"
            self.secondryLabel.isHidden = true
        }
    }
}

extension CheckOutagesResultsViewController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser(_ URLString : String, title : String) {

            let safariVC = SFSafariViewController(url: URL(string: URLString)!)
            safariVC.delegate = self
            
            //make status bar have default style for safariVC
            
            self.present(safariVC, animated: true, completion:nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //make status bar have light style since going back to UIApplication
    }
}
