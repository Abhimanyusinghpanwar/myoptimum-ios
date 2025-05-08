//
//  TroubleshootContactSupportViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 28/01/23.
//

import UIKit
import ASAPPSDK

class TroubleshootContactSupportViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
//    @IBOutlet weak var callUsView: UIControl!
//    @IBOutlet weak var callUsLabel: UILabel!
    @IBOutlet weak var viewChatwithus: UIView!
    var screenType:ContactUsScreenFlowTypes?
    var isChatTapped = false
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var viewSubtitleLabel: UILabel!
    var isFromTV = false
    @IBAction func callUsAction(_ sender: UIControl) {
        guard let phoneNumber = URL(string: "tel://" + ConfigService.shared.troubleShootingSupport) else {return}
        if UIApplication.shared.canOpenURL(phoneNumber) {
            UIApplication.shared.open(phoneNumber)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        viewChatwithus.viewBorderAttributes(UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 0.5).cgColor, 2, 15)
        self.viewSubtitleLabel.text = isFromTV ? "Let’s contact our support experts to get you some help." : "Let's contact our technical experts to get you some help."
        self.viewTitleLabel.setLineHeight(1.2)
        self.viewSubtitleLabel.setLineHeight(1.2)
      /*  guard let phoneNumber = URL(string: "tel://" + ConfigService.shared.troubleShootingSupport) else {return}
        if UIApplication.shared.canOpenURL(phoneNumber) {
            callUsView.isUserInteractionEnabled = true
            callUsLabel.text = "Call us"
        } else {
            callUsView.isUserInteractionEnabled = false
            var phoneNumber = ConfigService.shared.troubleShootingSupport
            let offsets = [3,7]
            for offset in offsets {
                let index = phoneNumber.index(phoneNumber.startIndex, offsetBy: offset)
                phoneNumber.insert("-", at: index)
            }
            callUsLabel.text = "Call us at 1-\(phoneNumber)"
        }*/
        // Do any additional setup after loading the view.
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_CONTACT_SUPPORT.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isChatTapped {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            let appDel = UIApplication.shared.delegate as? AppDelegate
            if let window = appDel?.window, let rootView = window.rootViewController {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TSSupport"),object: nil))
                rootView.dismiss(animated: false)
            }
        }
    }

    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        isChatTapped = true
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: IntentsManager.sharedInstance.screenFlow)
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return }
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController) { _ in
            self.hideLeftBarItem()
            self.hideRightBarItem()
            self.view.alpha = 0.0
        }
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
