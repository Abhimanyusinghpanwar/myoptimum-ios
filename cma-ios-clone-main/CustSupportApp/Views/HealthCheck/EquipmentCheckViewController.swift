//
//  EquipmentCheckViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 14/12/22.
//

import UIKit
import Lottie
import SafariServices

struct EquipmentDetails {
    var networkStatusText: String
    var networkStatus: UIColor
    var equipmentName: String
    var equipmentImage: UIImage
    var isWifi: Bool
}

class EquipmentCheckViewController: UIViewController {

    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkStatusLabel: UILabel!
    @IBOutlet weak var networkStatus: UIImageView!
    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentIcon: UIImageView!
   
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsBgView: UIView!
    
    @IBOutlet weak var closeButtonView: UIView!
    @IBAction func closeButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            MyWifiManager.shared.isCloseButtonClicked = true
             cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
         }
    }
    @IBOutlet weak var mainView: LottieAnimationView!
    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var secondAnimateView: UIView!
    @IBOutlet weak var secondNetworkStatusLabel: UILabel!
    @IBOutlet weak var secondNnetworkStatus: UIImageView!
    @IBOutlet weak var secondEquipmentNameLabel: UILabel!
    @IBOutlet weak var secondEquipmentIcon: UIImageView!
    @IBOutlet weak var healthCheckLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var deadZoneLabel: UILabel!
    @IBOutlet weak var threeDotsAnimation: LottieAnimationView!
    @IBOutlet weak var leadingConstraintToAnimationView: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraintToAnimationView: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintToAnimationView: NSLayoutConstraint!
    @IBOutlet weak var centreXConstraintToAnimationView: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraintTohealthCheckLabel: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraintTohealthCheckLabel: NSLayoutConstraint!
    @IBOutlet weak var healthCheckLabelToSecondaryLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondaryLabelToButtonViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var healthCheckLabelToButtonViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var greatButton: RoundedButton!
    @IBOutlet weak var issueButton: RoundedButton!

    var index1 = 0
    var translationX : CGFloat = 0.0
    var equipmentArray = NSMutableArray()
    var arrExtenders:[Extender] = []
    var devices: [ConnectedDevice] = []
    var animationCount = 0
    var isFromDeviceAnimation = false
    var isDeadZoneFailed = false
    var isShowDeadZoneProcess = false
    var isDeadZoneOccurred = false
    var isAnimationCompleted = false
    var isMoveToSpeedTest = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonsBgView.isHidden = true
        self.closeButtonView.isHidden = false
        self.navigationItem.hidesBackButton = true
        threeDotsAnimationSetup()
        self.mainView.backgroundColor = UIColor(red: 38.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        self.equipmentNameLabel.font = UIFont(name: "Regular-Medium", size: 18)
        self.secondEquipmentNameLabel.font = UIFont(name: "Regular-Medium", size: 18)
        self.healthCheckLabel.font = UIFont(name: "Regular-Medium", size: 24)
        self.healthCheckLabelToButtonViewConstraint.priority = UILayoutPriority(999)
        self.healthCheckLabelToSecondaryLabelConstraint.priority = UILayoutPriority(250)
        self.secondaryLabel.isHidden = true
        self.deadZoneLabel.isHidden = true
        if MyWifiManager.shared.getWifiType() == "Modem" {
            getModemDetails()
        } else {
            getExtenders()
            seggregateEquipmentData()
        }
        self.performDeadZoneRequest()
        self.devices = MyWifiManager.shared.populateConnectedDevices()?.arrOfConnectedDevices ?? []
        translationX = self.animateView.frame.origin.x - ((self.mainView.frame.width/2) - (self.animateView.frame.width/2))
        self.animationCount = self.equipmentArray.count
        greatButton.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1)
        if equipmentArray.count > 0 {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_CHECKING_NETWORK_HEALTH.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.repeatAnimation()
            }
        }
        self.healthCheckLabel.setLineHeight(1.2)
        self.healthCheckLabel.textAlignment = .center
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MyWifiManager.shared.isCloseButtonClicked {
            MyWifiManager.shared.isCloseButtonClicked = false
            if isMoveToSpeedTest {
                self.isMoveToSpeedTest = false
                guard let vc = CheckInternetSpeedViewController.instantiateWithIdentifier(from: .speedTest) else { return }
                MyWifiManager.shared.isFromHealthCheck = true
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: false)
            } else if !self.isAnimationCompleted {
                if self.index1 == self.animationCount {
                    self.view.layer.removeAllAnimations()
                    self.isAnimationCompleted = true
                    self.index1 = 0
                    self.threeDotsAnimation.stop()
                    self.threeDotsAnimation.isHidden = true
                    self.viewAnimationSetUp()
                } else {
                    if !self.threeDotsAnimation.isHidden {
                        self.threeDotsAnimation.play()
                    }
                }
            }
        }
    }
    
    func performDeadZoneRequest() {
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            APIRequests.shared.initiateDeadZoneRequest { success,value,error  in
                if success {
                    if let deadZone = value, let homeQoe = deadZone.home_qoe, !homeQoe.isEmpty {
                        if let homeQoeData = homeQoe.first, let qoeScore = homeQoeData.qoe_score, let threshold = Double(ConfigService.shared.qoeThreshold) {
                            self.isShowDeadZoneProcess = true
                            if qoeScore >= threshold {
                                self.isDeadZoneOccurred = false
                            } else {
                                self.isDeadZoneOccurred = true
                            }
                        }
                    } else {
                        self.isShowDeadZoneProcess = false
                    }
                } else {
                    self.isShowDeadZoneProcess = false
                }
            }
        } else {
            self.isShowDeadZoneProcess = false
        }
    }
    
    @IBAction func greateButtonTapping(_ sender: Any) {
        if !isDeadZoneFailed {
            //CMAIOS-2287
            self.trackOnClickEvent(eventLinkText: Troubleshooting.TS_INTERNET_WORKS_NOW.rawValue)
            APIRequests.shared.isReloadNotRequiredForMaui = false
            self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        } else {
            guard let url = URL(string: EXTENDER_URL) else { return }
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion:nil)
        }
    }
    @IBAction func issuesButtonTapping(_ sender: Any) {
        if !isDeadZoneFailed {
            //CMAIOS-2287
            self.trackOnClickEvent(eventLinkText: Troubleshooting.TS_INTERNET_ISSUE_NOT_RESOLVED.rawValue)
            guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.none
            APIRequests.shared.isReloadNotRequiredForMaui = false
            self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func seggregateEquipmentData() {
        let masterDetails = MyWifiManager.shared.getMasterGatewayDetails()
        if !masterDetails.name.isEmpty {
            equipmentArray.add(EquipmentDetails(networkStatusText: masterDetails.statusText, networkStatus: masterDetails.statusColor!, equipmentName: masterDetails.name, equipmentImage: masterDetails.equipmentImage, isWifi: true))
        }
        
        for extender in arrExtenders {
            var bgColor = UIColor()
            var statusText = ""
            if extender.status == "Offline" {
                statusText = extender.status
                bgColor = .StatusOffline
            } else {
                let colorStatus = extender.getColor()
                statusText = colorStatus.status
                bgColor = colorStatus.color
            }
            equipmentArray.add(EquipmentDetails(networkStatusText: statusText, networkStatus: bgColor, equipmentName: extender.title, equipmentImage: masterDetails.equipmentImage, isWifi: false))
        }
    }
    
    func getModemDetails() {
        if let macAddress = MyWifiManager.shared.deviceMAC, !macAddress.isEmpty {
            equipmentArray.add(EquipmentDetails(networkStatusText: (MyWifiManager.shared.getMyWifiStatus() == .runningSmoothly) ? "Online" : "Offline", networkStatus: (MyWifiManager.shared.getMyWifiStatus() == .runningSmoothly) ? .StatusOnline : .StatusOffline , equipmentName: macAddress, equipmentImage: UIImage(named: "icon_wifi_white")!, isWifi: true))
        }
    }
    
    func viewAnimationSetUp() {
        if !self.isFromDeviceAnimation {
            let wifiStatus = MyWifiManager.shared.getMyWifiStatus()
            if wifiStatus == .wifiDown {
                guard let vc = RestartHealthCheckFlowVC.instantiateWithIdentifier(from: .HealthCheck) else { return }
                vc.equipmentDetail = ""
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if MyWifiManager.shared.getOfflineExtenders().count > 0 || MyWifiManager.shared.getWeakExtenders().count > 0 {
                guard let vc = RestartHealthCheckFlowVC.instantiateWithIdentifier(from: .HealthCheck) else { return }
                vc.equipmentDetail = (MyWifiManager.shared.getOfflineExtenders().count > 0) ? "Offline" : "Weak"
                if vc.equipmentDetail == "Offline" {
                    vc.equipmentCount = MyWifiManager.shared.getOfflineExtenders().count
                } else if vc.equipmentDetail == "Weak" {
                    vc.equipmentCount = MyWifiManager.shared.getWeakExtenders().count
                }
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_NETWORK_EQUIPMENT_GOOD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                self.mainView.backgroundColor = .clear
                self.mainView.animation = LottieAnimation.named("circle_check")
                self.mainView.loopMode = .playOnce
                self.mainView.animationSpeed = 1.0
                self.mainView.play() { _ in
                    self.healthCheckLabel.text = "Your network equipment looks good!"
                    self.healthCheckLabel.font = UIFont(name: "Regular-Bold", size: 24)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                        self.mainView.play(fromProgress: 1.0, toProgress: 0.0, loopMode: .playOnce) { _ in
                            UIView.animate(withDuration: 0.5) {
                                self.healthCheckLabel.alpha = 0
                                self.mainView.transform = CGAffineTransform(scaleX: 0.76, y: 0.76)
                                self.mainView.alpha = 0.3
                                
//                                self.mainView.frame = CGRect(x: self.mainView.frame.origin.x, y: (UIDevice.current.hasNotch) ? self.mainView.frame.origin.y - 30 : self.mainView.frame.origin.y - 60, width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
                            }completion: { _ in
                                if !MyWifiManager.shared.isCloseButtonClicked {
                                    guard let vc = CheckInternetSpeedViewController.instantiateWithIdentifier(from: .speedTest) else { return }
                                    self.mainView.alpha = 1
                                    MyWifiManager.shared.isFromHealthCheck = true
                                    self.navigationController?.navigationBar.isHidden = false
                                    self.navigationController?.pushViewController(vc, animated: false)
                                } else {
                                    self.mainView.alpha = 1
                                    self.isMoveToSpeedTest = true
                                }
                            }
                            /*
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                if !MyWifiManager.shared.isCloseButtonClicked {
                                    guard let vc = CheckInternetSpeedViewController.instantiateWithIdentifier(from: .speedTest) else { return }
                                    MyWifiManager.shared.isFromHealthCheck = true
                                    self.mainView.alpha = 1
                                    self.navigationController?.navigationBar.isHidden = false
                                    self.navigationController?.pushViewController(vc, animated: false)
                                } else {
                                    self.mainView.alpha = 1
                                    self.isMoveToSpeedTest = true
                                }
                            }  */
//                        }
                    }
                }
            }
        } else {
            if  let weakDevicesDetail = MyWifiManager.shared.populateConnectedDevices(filterWeakStatus: true, withSections: true), weakDevicesDetail.arrOfSections?.count ?? 0 > 0 {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_DEVICES_HAVE_WEAK_SIGNAL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                self.showWeakDevicesVC(deviceDetails: weakDevicesDetail)
            } else {
                self.mainView.frame.size = CGSize(width: 256, height: 240)
                self.mainView.backgroundColor = .clear
                self.mainView.animation = LottieAnimation.named("CircleWithHeart")
                self.mainView.loopMode = .playOnce
                self.mainView.animationSpeed = 1.0
                self.mainView.play(toProgress: 0.5, completion:{ _ in
                    if MyWifiManager.shared.wifiDisplayType == .Gateway && !self.devices.isEmpty {
                        self.healthCheckLabel.isHidden = false
                        self.healthCheckLabel.alpha = 1.0
                        let numberOfDevices = (self.devices.count == 1) ? "device" : "devices"
                        self.healthCheckLabel.text = "Your \(numberOfDevices) look fine!"
                        self.healthCheckLabel.font = UIFont(name: "Regular-Bold", size: 24)
                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_DEVICES_FINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                    } else {
                        self.healthCheckLabel.isHidden = false
                        self.healthCheckLabel.alpha = 1.0
                        self.healthCheckLabel.font = UIFont(name: "Regular-Bold", size: 24)
                        self.healthCheckLabel.text = ""
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.mainView.backgroundColor = .clear
                        UIView.animate(withDuration: 0.5) {
                            self.leadingConstraintToAnimationView.priority = UILayoutPriority(999)
                            self.trailingConstraintToAnimationView.priority = UILayoutPriority(999)
                            self.widthConstraintToAnimationView.priority = UILayoutPriority(250)
                            self.centreXConstraintToAnimationView.priority = UILayoutPriority(250)
                            self.animateView.isHidden = true
                            self.secondAnimateView.isHidden = true
                            self.leadingConstraintTohealthCheckLabel.constant = 66.0
                            self.trailingConstraintTohealthCheckLabel.constant = 66.0
                        }
                        self.mainView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                            let connectionType = (MyWifiManager.shared.getWifiType() == "Modem") ? "Internet" : "WiFi"
                            self.healthCheckLabel.text = "Your \(connectionType) looks good"
                            self.greatButton.setTitle("Great!", for: .normal)
                            self.issueButton.setTitle("I'm still experiencing an issue", for: .normal)
                            self.buttonsBgView.isHidden = false
                            self.closeButtonView.isHidden = true
                            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_WIFI_GOOD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                        }
                    }
                })
            }
        }
    }
    
    //CMAIOS-2287
    func trackOnClickEvent(eventLinkText:String){
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : eventLinkText,
                        EVENT_SCREEN_NAME:Troubleshooting.TS_HEALTHCHECK_WIFI_GOOD.rawValue ,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue]
        )
    }
    
    func fromSpeedTestView() {
        self.mainView.animation = nil
        self.mainView.layer.borderWidth = 4.0
        self.mainView.layer.borderColor = energyBlueRGB.cgColor
//        self.mainView.frame = CGRect(x: self.mainView.frame.origin.x, y: (UIDevice.current.hasNotch) ? self.mainView.frame.origin.y + 30 : self.mainView.frame.origin.y + 60, width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 1.0) {
                self.mainView.transform = .identity
            }
            if self.isShowDeadZoneProcess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_CHECKING_WIFI_DEAD_ZONES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                    self.healthCheckLabel.isHidden = false
                    self.healthCheckLabel.alpha = 1.0
                    self.healthCheckLabel.font = UIFont(name: "Regular-Medium", size: 24)
                    self.healthCheckLabel.text = "Checking your WiFi coverage..."
                    self.mainView.layer.borderColor = UIColor.clear.cgColor
                    self.deadZoneLabel.isHidden = true
                    self.mainView.backgroundColor = .clear
                    self.mainView.animation = LottieAnimation.named("Checking_WiFi_Dead_Zone_Searching")
                    self.mainView.loopMode = .playOnce
                    self.mainView.animationSpeed = 1.0
                    self.mainView.play() { _ in
                        if !self.isDeadZoneOccurred {
                            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_NO_WIFI_DEAD_ZONES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                            self.mainView.backgroundColor = .clear
                            self.mainView.animation = nil
                            self.mainView.animation = LottieAnimation.named("Checking_WiFi_Dead_Zone_Success")
                            self.mainView.loopMode = .playOnce
                            self.mainView.animationSpeed = 1.0
                            self.mainView.play() { _ in
                                self.healthCheckLabel.font = UIFont(name: "Regular-Bold", size: 24)
                                self.healthCheckLabel.text = "Your WiFi coverage looks good"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    if self.devices.count > 0 {
                                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_CHECKING_DEVICES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                                        self.healthCheckLabel.font = UIFont(name: "Regular-Medium", size: 24)
                                        self.deadZoneLabel.isHidden = true
                                        self.healthCheckLabel.text = "Checking your devices..."
                                        self.mainView.animation = nil
                                        self.mainView.backgroundColor = UIColor(red: 38.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)//energyBlueRGB
                                        self.index1 = 0
                                        self.isAnimationCompleted = false
                                        self.isFromDeviceAnimation = true
                                        self.animationCount = self.devices.count
                                        self.threeDotsAnimation.isHidden = false
                                        self.threeDotsAnimationSetup()
                                        self.repeatAnimation()
                                    } else {
                                        self.mainView.layer.borderColor = UIColor.clear.cgColor
                                        self.deadZoneLabel.isHidden = true
                                        self.isFromDeviceAnimation = true
                                        self.viewAnimationSetUp()
                                    }
                                }
                            }
                        } else {
                            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_WIFI_DEAD_ZONES_DETECTED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                            self.isDeadZoneFailed = true
                            self.mainView.backgroundColor = .clear
                            self.mainView.animation = LottieAnimation.named("Checking_WiFi_Dead_Zone_Question")
                            self.mainView.loopMode = .playOnce
                            self.mainView.animationSpeed = 1.0
                            self.mainView.play() { _ in
                                self.healthCheckLabel.font = UIFont(name: "Regular-Bold", size: 24)
                                self.healthCheckLabel.text = "You may have a WiFi coverage problem"
                                self.secondaryLabel.isHidden = true
                                self.secondaryLabel.text = "An Extender may help."
                                self.healthCheckLabelToButtonViewConstraint.priority = UILayoutPriority(250)
                                self.healthCheckLabelToSecondaryLabelConstraint.priority = UILayoutPriority(250)
                                self.secondaryLabelToButtonViewConstraint.priority = UILayoutPriority(999)
                                self.greatButton.setTitle("Check if I need an Extender", for: .normal)
                                self.issueButton.setTitle("Maybe later", for: .normal)
                                self.buttonsBgView.isHidden = false
                                
                            }
                        }
                    } // For CMAIOS-1346.
                }
            } else if MyWifiManager.shared.wifiDisplayType == .Gateway {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if self.devices.count > 0 {
                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_CHECKING_DEVICES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                        self.mainView.layer.borderColor = UIColor.clear.cgColor
                        self.healthCheckLabel.font = UIFont(name: "Regular-Medium", size: 24)
                        self.deadZoneLabel.isHidden = true
                        self.healthCheckLabel.isHidden = false
                        self.healthCheckLabel.alpha = 1.0
                        self.healthCheckLabel.text = "Checking your devices..."
                        self.mainView.animation = nil
                        self.mainView.backgroundColor = UIColor(red: 38.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)//energyBlueRGB
                        self.index1 = 0
                        self.isFromDeviceAnimation = true
                        self.animationCount = self.devices.count
                        self.isAnimationCompleted = false
                        self.threeDotsAnimation.isHidden = false
                        self.threeDotsAnimationSetup()
                        self.repeatAnimation()
                    } else {
                        self.mainView.layer.borderColor = UIColor.clear.cgColor
                        self.deadZoneLabel.isHidden = true
                        self.isFromDeviceAnimation = true
                        self.viewAnimationSetUp()
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.mainView.layer.borderColor = UIColor.clear.cgColor
                    self.deadZoneLabel.isHidden = true
                    self.isFromDeviceAnimation = true
                    self.viewAnimationSetUp()
                }
            }
        }
    }
    
    func showWeakDevicesVC(deviceDetails: DeviceDetails) {
        let storyboard = UIStoryboard(name: "HealthCheck", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "WeakSignalDevicesAlertVC") as? WeakSignalDevicesAlertVC else {return}
        vc.deviceDetails = deviceDetails
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(vc , animated: true)
    }
    
    func threeDotsAnimationSetup() {
        self.threeDotsAnimation.backgroundColor = .clear
        self.threeDotsAnimation.animation = LottieAnimation.named("three_dots")
        self.threeDotsAnimation.loopMode = .loop
        self.threeDotsAnimation.animationSpeed = 1.0
        self.threeDotsAnimation.play()
    }
    
    func getExtenders() {
        let onlineExtenders = MyWifiManager.shared.getExtendersFromNodes()
        let offlineExtenders = MyWifiManager.shared.getOfflineExtenders()
        
        arrExtenders = onlineExtenders.map {nodes -> Extender in
            var color = ""
            if let val = nodes.color, !val.isEmpty {
                color = val
            } else {
                color = ""
            }
            let extenderName = WifiConfigValues.getExtenderName(offlineExtNode: nil, onlineExtNode: nodes)
            return Extender.init(title: extenderName, colorName: color, status: nodes.status ?? "", device_type: nodes.cma_equipment_type_display ?? nodes.device_type ?? "", conn_type: nodes.conn_type ?? "", macAddress: nodes.mac ?? "", ipAddress: nodes.ip ?? "", band: nodes.band ?? "", image: DeviceManager.IconType.white.getExtenderImage(name: nodes.cma_display_name), hostname: nodes.hostname ?? "", category: nodes.cma_category ?? "")
        }
        let offlines = offlineExtenders.map{nodes -> Extender in
            let color = ""
            let extenderName = WifiConfigValues.getExtenderName(offlineExtNode: nodes, onlineExtNode: nil)
            return Extender.init(title: extenderName, colorName: color, status: nodes.status ?? "", device_type: nodes.cma_equipment_type_display ?? "", conn_type: nodes.conn_type ?? "", macAddress: nodes.device_mac ?? "", ipAddress:"", band:"", image: DeviceManager.IconType.white.getExtenderImage(name: nodes.cma_display_name), hostname: nodes.hostname ?? "", category: nodes.cma_category ?? "")
        }
        arrExtenders.append(contentsOf: offlines)
    }
    
    func repeatAnimation() {
        let index2 = index1 % 2
        self.animateView.transform = CGAffineTransform(translationX: 0, y: 0)
        self.secondAnimateView.transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.6, animations: {
            if index2 == 0 {
                self.animateView.alpha = 0.5
                if !self.isFromDeviceAnimation {
                    self.networkStatusLabel.text = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).networkStatusText
                    self.networkStatus.backgroundColor = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).networkStatus
                    self.equipmentNameLabel.text = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).equipmentName
                    let isWifi = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).isWifi
                    if isWifi {
                        if MyWifiManager.shared.getWifiType() == "Modem" {
                            self.equipmentIcon.image = UIImage(named: "icon_wifi_white")
                        } else {
                            self.equipmentIcon.image = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).equipmentImage
                        }
                    } else {
                        self.equipmentIcon.image = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? UIImage(named: "Optimum-Extender 6E") : UIImage(named: "Extender_icon")
                    }
                } else {
                    self.equipmentNameLabel.text = self.validateOverflowingText(labelText: self.devices[self.index1].title as NSString)
                    self.equipmentIcon.image = self.devices[self.index1].deviceImage_White
                    let statusValues = self.devices[self.index1].getColor()
                    self.networkStatusLabel.text = statusValues.status
                    self.networkStatus.backgroundColor = statusValues.color
                }
                self.animateView.transform = CGAffineTransform(translationX: -self.translationX, y: 0)
            } else if index2 == 1 {
                self.secondAnimateView.alpha = 0.5
                if !self.isFromDeviceAnimation {
                    self.secondNetworkStatusLabel.text = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).networkStatusText
                    self.secondNnetworkStatus.backgroundColor = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).networkStatus
                    self.secondEquipmentNameLabel.text = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).equipmentName
                    let isWifi = ((self.equipmentArray.object(at: self.index1)) as! EquipmentDetails).isWifi
                    if isWifi {
                        self.secondEquipmentIcon.image = UIImage(named: "icon_wifi_white")
                    } else {
                        self.secondEquipmentIcon.image = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? UIImage(named: "Optimum-Extender 6E") : UIImage(named: "Extender_icon")
                    }
                } else {
                    self.secondEquipmentNameLabel.text = self.validateOverflowingText(labelText: self.devices[self.index1].title as NSString) 
                    self.secondEquipmentIcon.image = self.devices[self.index1].deviceImage_White
                    let statusValues = self.devices[self.index1].getColor()
                    self.secondNetworkStatusLabel.text = statusValues.status
                    self.secondNnetworkStatus.backgroundColor = statusValues.color
                }
                self.secondAnimateView.transform = CGAffineTransform(translationX: -self.translationX, y: 0)
            }
        }, completion: { finished in
            if index2 == 0 {
                self.animateView.alpha = 1.0
            } else if index2 == 1 {
                self.secondAnimateView.alpha = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.6, animations: {
                    if index2 == 0 {
                        self.animateView.alpha = 0.5
                        self.animateView.transform = CGAffineTransform(translationX: -(self.translationX * 2), y: 0)
                    } else if index2 == 1 {
                        self.secondAnimateView.alpha = 0.5
                        self.secondAnimateView.transform = CGAffineTransform(translationX: -(self.translationX * 2), y: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.index1 += 1
                        if self.index1 < self.animationCount {
                            self.repeatAnimation()
                        }
                    }
                }, completion: { finished in
                    if self.index1 == self.animationCount {
                        self.view.layer.removeAllAnimations()
                        self.isAnimationCompleted = true
                        self.index1 = 0
                        self.threeDotsAnimation.stop()
                        self.threeDotsAnimation.isHidden = true
                        self.viewAnimationSetUp()
                    }
                })
            }
        })
    }
    
    func validateOverflowingText(labelText:NSString) -> String {
        if labelText.length > 20 {
            let range1 = NSMakeRange(0, 9)
            let text1 = NSMutableString(string: labelText.substring(with: range1))
            let lastCharsLength = labelText.length - 8
            let range2 = NSMakeRange(lastCharsLength, 8)
            let text2 = NSMutableString(string: labelText.substring(with: range2))
            return String(text1) + "..." + String(text2)
        }
        return String(labelText)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
