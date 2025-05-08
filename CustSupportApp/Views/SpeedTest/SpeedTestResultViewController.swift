//
//  SpeedTestResultViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/20/22.
//

import Lottie
import UIKit

class SpeedTestResultViewController: UIViewController {
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var downloadSpeed: UILabel!
    @IBOutlet var uploadSpeed: UILabel!
    @IBOutlet var header: UILabel!
    @IBOutlet var instructions: UILabel!
    @IBOutlet var learnMore: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    
    @IBOutlet weak var animationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var speedStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var stackBottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var labelStackView: UIStackView!
    var speedResult: SpeepTestResponse!
    var isRestartHappend: Bool = false
    var isMoveToHealthCheck = false
    var qualtricsAction : DispatchWorkItem?
    var bandwidth: Int {
        MyWifiManager.shared.bwDown
    }
    let tappableText = "what factors influence your speed"
    
    var isDownloadOnly: Bool {
        speedResult.uploadPercentage == nil
    }
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        if MyWifiManager.shared.isFromHealthCheck {
            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
                MyWifiManager.shared.isCloseButtonClicked = true
                 cancelVC.modalPresentationStyle = .fullScreen
                 self.navigationController?.pushViewController(cancelVC, animated: true)
             }
        } else {
            navigationController?.dismiss(animated: true, completion: {
                IntentsManager.sharedInstance.screenFlow = .none
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryAction.layer.borderWidth = 1
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        self.fadeInFadeOutUILabel(alpha: 0)
        updateUI()
        self.header.setLineHeight(1.2)
        self.header.textAlignment = .center
        self.instructions.setLineHeight(1.2)
        self.instructions.textAlignment = .center
        if self.closeButtonView.isHidden{
           self.setUpUIBeforeAnimation()
        }
        // Setup Learn more
        let text = "Learn more about what factors influence your speed."
        let linkText = NSMutableAttributedString(string: text, attributes: [.font: UIFont(name: "Regular-Medium", size: 15)!])
        let moreInfo = (text as NSString).range(of: tappableText)
        linkText.addAttribute(.foregroundColor, value: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0), range: moreInfo)
        learnMore.attributedText = linkText
    }
    
    func trackEventForExpectedPlanSpeed(){
        //For Firebase Analytics
        if self.isDownloadOnly {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_RESULT_EXPECTED_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
            
            AppRatingManager.shared.trackEventTriggeredFor(qualifyingExpType: .speedTest)
            if !MyWifiManager.shared.isFromHealthCheck {
                self.addQualtrics(screenName: SpeedTestScreenDetails.SPEEDTEST_RESULT_EXPECTED_SPEED.rawValue)
            }
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_DUAL_SPEED_PLAN_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
            if !MyWifiManager.shared.isFromHealthCheck {
                self.addQualtrics(screenName: SpeedTestScreenDetails.SPEEDTEST_DUAL_SPEED_PLAN_SPEED.rawValue)
            }
        }
    }
    
    func addQualtrics(screenName:String){
        qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    func trackEventForLessThan80Speed(){
        //For Firebase Analytics
        if self.isDownloadOnly {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_RESULT_SPEED_LESS_THAN_80_PLAN_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_DUAL_SPEED_LESS_THAN_80_PLAN_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
        }
        
    }
    
    func updateUI() {
        let size: CGFloat = isDownloadOnly ? 48 : 28
        let downloadText = speedFormat(speed: speedResult.downloadSpeed)
        let downUnit = downloadText.contains("Mbps") ? "Mbps" : "Gbps"
        let attributed = NSMutableAttributedString(string: downloadText, attributes: [.font: UIFont(name: "Regular-Bold", size: size)!])
        attributed.addAttribute(.font, value: UIFont(name: "Regular-Regular", size: 20)!, range: (downloadText as NSString).range(of: downUnit))
        downloadSpeed.attributedText = attributed
        uploadSpeed.superview?.isHidden = isDownloadOnly
        let uploadText = speedFormat(speed: speedResult.uploadSpeed ?? 0)
        let upUnit = uploadText.contains("Mbps") ? "Mbps" : "Gbps"
        let uploadAttributed = NSMutableAttributedString(string: uploadText, attributes: [.font: UIFont(name: "Regular-Bold", size: size)!])
        uploadAttributed.addAttribute(.font, value: UIFont(name: "Regular-Regular", size: 20)!, range: (uploadText as NSString).range(of: upUnit))
        uploadSpeed.attributedText = uploadAttributed
        let model = self.getSpeedUIOModel()
        header.text = model.header
        instructions.text = model.instructions
        animationView.animation = LottieAnimation.named(model.name)
        self.primaryAction.isHidden = false
        learnMore.isHidden = true
        self.primaryAction.setTitle(isRestartHappend ? "Contact us" : "Let’s do it", for: .normal)
        if MyWifiManager.shared.isFromHealthCheck {
            if model.percentage >= 80.0 {
                self.trackEventForExpectedPlanSpeed()
                secondaryAction.isHidden = true
                closeButtonView.isHidden = false
                primaryAction.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
                    if MyWifiManager.shared.isCloseButtonClicked {
                        self.isMoveToHealthCheck = true
                    } else {
                        self.moveToHealthCheck()
                    }
                }
            } else {
                self.closeButtonView.isHidden = true
                self.secondaryAction.isHidden = false
                trackEventForLessThan80Speed()
            }
        } else {
            closeButtonView.isHidden = true
            if model.percentage >= 80.0 {
                secondaryAction.isHidden = true
                primaryAction.setTitle("Great!", for: .normal)
                learnMore.isHidden = false
                instructions.isHidden = !isRestartHappend
                header.text = isRestartHappend ? "Restarting your \(MyWifiManager.shared.getWifiType()) worked!" : model.header
                if isRestartHappend {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_RESET_GATEWAY_WORKED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
                    AppRatingManager.shared.trackEventTriggeredFor(qualifyingExpType: .speedTest)
                    self.addQualtrics(screenName: SpeedTestScreenDetails.SPEEDTEST_RESET_GATEWAY_WORKED.rawValue)
                } else {
                    trackEventForExpectedPlanSpeed()
                }
            } else {
                secondaryAction.isHidden = false
                if isRestartHappend {
                    header.text = "Looks like you're still not getting your plan speed."
                    instructions.text = "Contact us so we can fix this."
                    //For Firebase Analytics
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEED_RESET_GATEWAY_DIDNT_IMPROVE_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
                } else {
                    trackEventForLessThan80Speed()
                }
            }
        }
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
    }
    
    func moveToHealthCheck() {
        self.qualtricsAction?.cancel()
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc.isKind(of: EquipmentCheckViewController.classForCoder()) {
                    let viewController = vc as! EquipmentCheckViewController
                    viewController.fromSpeedTestView()
                    self.navigationController?.popToViewController(viewController, animated: false)
                    break
                }
            }
        }
    }
    
    func setUpUIBeforeAnimation(){
        stackBottomViewConstraint.constant = -210
        stackBottomViewConstraint.priority = .defaultLow
    }
    
    func fadeInFadeOutUILabel(alpha:CGFloat){
        self.downloadImageView.alpha = alpha
        self.uploadImageView.alpha = alpha
        self.downloadSpeed.alpha = alpha
        self.uploadSpeed.alpha = alpha
        self.header.alpha = alpha
        self.instructions.alpha = alpha
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let animationDuration = 0.8 //self.animationView.animation?.duration ?? 2.0
        if !MyWifiManager.shared.isFromHealthCheck {
            navigationController?.isNavigationBarHidden = true
        } else {
            self.navigationItem.hidesBackButton = true
            navigationController?.isNavigationBarHidden = true
        }
        animationView.play() { _ in
            UIView.animate(withDuration: animationDuration) {
                self.fadeInFadeOutUILabel(alpha: 1.0)
            } completion:{_ in
                self.stackBottomViewConstraint.constant = 30
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        if MyWifiManager.shared.isCloseButtonClicked {
            MyWifiManager.shared.isCloseButtonClicked = false
            if self.isMoveToHealthCheck {
                self.moveToHealthCheck()
                self.isMoveToHealthCheck = false
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    
    @IBAction func onTapLearnMore(_ sender: UITapGestureRecognizer) {
        guard sender.didTapAttributedTextInLabel(label: learnMore, targetText: tappableText) else {
            return
        }
        self.qualtricsAction?.cancel()
        guard let vc = TipsContainerViewController.instantiateWithIdentifier(from: .speedTest) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapPrimaryAction(_ sender: UITapGestureRecognizer) {
        self.qualtricsAction?.cancel()
        if !isRestartHappend {
            guard speedResult.downloadPercentage ?? 0.0 >= 80 && (speedResult.uploadPercentage ?? 100 >= 80) else {
                APIRequests.shared.isReloadNotRequiredForMaui = true
                guard let vc = RestartMyGateWayViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                MyWifiManager.shared.isFromSpeedTest = true
                IntentsManager.sharedInstance.screenFlow = .mySpeedStillLessThan80
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            if !MyWifiManager.shared.isFromHealthCheck {
//                navigationController?.dismiss(animated: true, completion: {
//                    IntentsManager.sharedInstance.screenFlow = .none
//                })
                if let navigationControl = self.presentingViewController as? UINavigationController {
                    if let moreOptions = navigationControl.viewControllers.filter({$0 is AdvancedSettingsUIViewController}).first as? AdvancedSettingsUIViewController {
                        DispatchQueue.main.async {
                            navigationControl.dismiss(animated: false, completion: {
                                IntentsManager.sharedInstance.screenFlow = .none
                                navigationControl.popToViewController(moreOptions, animated: true)
                            })
                        }
                    }
                } else {
                    navigationController?.dismiss(animated: true, completion: {
                        IntentsManager.sharedInstance.screenFlow = .none
                    })
                }
            }
        } else {
            guard speedResult.downloadPercentage ?? 0.0 >= 80 && (speedResult.uploadPercentage ?? 100 >= 80) else {
                guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
                IntentsManager.sharedInstance.screenFlow = .mySpeedStillLessThan80
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            navigationController?.dismiss(animated: true, completion: {
                IntentsManager.sharedInstance.screenFlow = .none
            })
        }
    }
    
    func speedFormat(speed: Double) -> String {
        if speed < 1000 {
        return    "\(Int(round(speed))) Mbps"
        } else {
        let rounded = speed/1000
        let finalValue = round(rounded * 100) / 100.0
        return "\(finalValue) Gbps"
        }
    }
}

extension SpeedTestResultViewController {
    
    func getSpeedUIOModel() -> SpeedTestUIOModel {
        let uploadSupported = MyWifiManager.shared.isUploadSupported
        let downSupported = MyWifiManager.shared.isDownloadSupported
        var speedPercentage = 0.0
        if uploadSupported && downSupported {
            speedPercentage = min(speedResult.downloadPercentage ?? 0.0, speedResult.uploadPercentage ?? 100)
        } else {
            speedPercentage = speedResult.downloadPercentage ?? 0.0
        }
        let GettingPlanSpeed = "You’re getting your plan speed"
        let FastSpeeds = "Your speeds are fast"
        
        let speedModel: SpeedTestUIOModel = SpeedTestUIOModel()
        speedModel.percentage = speedPercentage
        switch speedPercentage {
        case 80...100 where bandwidth >= 900:
            speedModel.name = "SpeedBlazing_Rocket"
            speedModel.header = GettingPlanSpeed
            speedModel.instructions = ""
        case 80...100 where bandwidth >= 500 && bandwidth <= 899:
            speedModel.name = "SpeedVeryFast_Plane"
            speedModel.header = GettingPlanSpeed
            speedModel.instructions = ""
        case 80...100 where bandwidth < 500:
            speedModel.name = "SpeedFast_Train"
            speedModel.header = GettingPlanSpeed
            speedModel.instructions = ""
        case 60..<80 where bandwidth >= 900:
            speedModel.name = "SpeedVeryFast_Plane"
            speedModel.header = "Your speeds are very fast"
            speedModel.instructions = "Let’s see if we can make them BLAZING!"
        case 60..<80 where bandwidth >= 500 && bandwidth <= 899:
            speedModel.name = "SpeedFast_Train"
            speedModel.header = FastSpeeds
            speedModel.instructions = "Let’s see if we can make them very fast."
        case 60..<80 where bandwidth < 500:
            speedModel.name = "SpeedSlow_Vespa"
            speedModel.header = FastSpeeds
            speedModel.instructions = "Let’s see if we can make them better."
        case 40...60 where bandwidth >= 900:
            speedModel.name = "SpeedFast_Train"
            speedModel.header = FastSpeeds
            speedModel.instructions = "Let’s see if we can make them very fast."
        default:
            speedModel.name = "SpeedSlow_Vespa"
            speedModel.header = "Your speeds can be better"
            speedModel.instructions = "Let’s see what we can do to improve them!"
        }
        return speedModel
    }
    
}

class SpeedTestUIOModel {
    var name: String = ""
    var header: String = ""
    var instructions: String = ""
    var percentage: Double = 0.0
}
