//
//  XtendInstallSuccessVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/12/22.
//  GA-extender5_install_success/extender6_install_success

import UIKit
import Lottie

class XtendInstallSuccessVC: UIViewController {
    @IBOutlet weak var successHeaderLbl: UILabel!
    @IBOutlet weak var successStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var extenderInstallSuccessAnimationView: LottieAnimationView!
    @IBOutlet weak var successViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var successViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var successNoteLabel: UILabel!
    var qualtricsAction : DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSuccessScreenUI()
        AppRatingManager.shared.trackEventTriggeredFor(qualifyingExpType: .selfInstall)
        ExtenderDataManager.shared.extenderAPIFailure = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_install_success.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
        let extender = ExtenderDataManager.shared.extenderType
        switch extender {
        case 5:
            self.addQualtrics(screenName: ExtenderInstallScreens.ExtenderType.extender5_install_success.rawValue)
        case 7:
            self.addQualtrics(screenName: ExtenderInstallScreens.ExtenderType.extender5_install_success.rawValue.replacingOccurrences(of: "5", with: "6e"))
        default:
            self.addQualtrics(screenName: ExtenderInstallScreens.ExtenderType.extender5_install_success.rawValue.replacingOccurrences(of: "5", with: "6"))
        }
    }
    
    func addQualtrics(screenName:String){
        qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    
    func updateSuccessScreenUI() {
        
        let extender = ExtenderDataManager.shared.extenderType
//        let extenderName = ExtenderDataManager.shared.extenderFriendlyName
//        CMAIOS-824: The revised flow to remove extender name in the screen.
        successHeaderLbl.text = "Congratulations, you’ve successfully set up your Extender!"
        successNoteLabel.attributedText = attributedStringForBold()
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            successViewLeadingConstraint.constant = 30.0
            successViewTrailingConstraint.constant = 30.0
            successHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            successHeaderLbl.setLineHeight(1.21)
        } else {
            successHeaderLbl.setLineHeight(1.15)
        }
        switch extender {
        case 5:
            playSuccessAnimation(str: "Pairing-success-Extender-5")
        case 7:
            playSuccessAnimation(str: "Extender6E-Pairing-success")
        default:
            playSuccessAnimation(str: "07_Xtend-6-Pairing-success")
        }
    }
    @IBAction func successManageMyWiFi(_ sender: Any) {
        self.qualtricsAction?.cancel()
        APIRequests.shared.isReloadNotRequiredForMaui = false
        let manageMyNetwork = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewMyNetwork") as! ViewMyNetworkViewController
        manageMyNetwork.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(manageMyNetwork, animated: true)
    }
    func playSuccessAnimation(str: String) {
        extenderInstallSuccessAnimationView.animation = LottieAnimation.named(str)
        extenderInstallSuccessAnimationView.backgroundColor = .clear
        extenderInstallSuccessAnimationView.loopMode = .playOnce
        extenderInstallSuccessAnimationView.animationSpeed = 1.0
        extenderInstallSuccessAnimationView.backgroundBehavior = .pauseAndRestore
        extenderInstallSuccessAnimationView.play()
    }
    func attributedStringForBold() -> NSAttributedString {
        let text = "Note: It can take up to 5 minutes for your new Extender to connect to your WiFi network"
        let attributedStr = NSMutableAttributedString(string: text)
        let boldAttributes = [NSAttributedString.Key.font: UIFont(name: "Regular-SemiBold", size: 16)]
        attributedStr.addAttributes(boldAttributes as [NSAttributedString.Key : Any], range: (text as NSString).range(of: "Note:"))
        
        return attributedStr
    }
}
