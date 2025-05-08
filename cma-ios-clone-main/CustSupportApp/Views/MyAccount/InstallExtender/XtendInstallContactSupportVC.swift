//
//  XtendInstallContactSupportVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/18/22.
//  GA-extender5_contact_support/extender6_contact_support

import UIKit
import ASAPPSDK

class XtendInstallContactSupportVC: BaseViewController, BarButtonItemDelegate {
    
    @IBOutlet weak var contactSupportTryAgain: UIButton!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var callUsBtn: RoundedButton!
    @IBOutlet weak var chatWithUSBtn: RoundedButton!
    let isTroubleshootFlow = ExtenderDataManager.shared.isExtenderTroubleshootFlow
    let supportRegion: String? = MyWifiManager.shared.getRegion()
    var streamInstallFlow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        if isTroubleshootFlow {
            contactSupportTryAgain.isHidden = true
            chatWithUSBtn.isHidden = false
            callUsBtn.isHidden = true
            primaryLbl.text = "Let's contact our technical experts to get you some help."
        } // CMAIOS-2216
        else if streamInstallFlow {
            primaryLbl.text = "Let's contact our installation experts to get you some help."
            chatWithUSBtn.isHidden = false
            callUsBtn.isHidden = true
            contactSupportTryAgain.isHidden = true
        }
        else { // Extender Install flow
            contactSupportTryAgain.isHidden = true
            chatWithUSBtn.isHidden = false
            callUsBtn.isHidden = true
            primaryLbl.text = "Let's contact our installation experts to get you some help."
        }
        
        
        if CurrentDevice.isLargeScreenDevice() {
            primaryLbl.setLineHeight(1.21)
        } else {
            primaryLbl.setLineHeight(1.15)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        if !streamInstallFlow {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_contact_support.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
        }
    }
    
    @IBAction func contactVCChatBtn(_ sender: Any) {
        if streamInstallFlow {
            IntentsManager.sharedInstance.screenFlow = .streamInstallFailure
        } else if isTroubleshootFlow {
            IntentsManager.sharedInstance.screenFlow = getIntentsForExtenders()
        } else {
            IntentsManager.sharedInstance.screenFlow = .extenderInstallFailure
        }
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: IntentsManager.sharedInstance.screenFlow)
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return }
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    @IBAction func contactVCCallBtn(_ sender: Any) {
        var contactNumber = ""
        if isTroubleshootFlow {
            contactNumber = ConfigService.shared.troubleShootingSupport
        } else {
            contactNumber = supportRegion?.lowercased() == "optimum" ? ConfigService.shared.customerSupportOptEast : ConfigService.shared.customerSupportOptWest
        }
        guard let phoneNumber = URL(string: "tel://" + contactNumber) else {return}
        if UIApplication.shared.canOpenURL(phoneNumber) {
            callUsBtn.isUserInteractionEnabled = true
            UIApplication.shared.open(phoneNumber)
        } else {
            callUsBtn.isUserInteractionEnabled = false
            let offsets = [1,5,9]
            for offset in offsets {
                let index = contactNumber.index(contactNumber.startIndex, offsetBy: offset)
                contactNumber.insert("-", at: index)
            }
            callUsBtn.setTitle("Call us at \(contactNumber)", for: .normal)
        }
        Logger.info("The Contact support screen call button clicked")
    }
    
    @IBAction func contactVCTryAgainBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendUpAndRunningVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getIntentsForExtenders() -> ContactUsScreenFlowTypes {
        switch ExtenderDataManager.shared.flowType {
        case .offlineFlow:
            return .extenderIsOfflineFlow
        case .weakFlow:
            return .extenderIsWeakFlow
        }
    }
    
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        // Cancel button
        if buttonType == .cancel && self.streamInstallFlow {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            navigationController?.dismiss(animated: true)
        } else if buttonType == .cancel {
            self.fallBackToDefaultCancel()
        }
        
        // BackArrow button
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func fallBackToDefaultCancel() {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
}
