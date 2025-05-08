//
//  XtendSupportViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 14/06/24.
//

import UIKit
import ASAPPSDK

class XtendSupportViewController: BaseViewController, BarButtonItemDelegate {
    @IBOutlet weak var contactSupportTryAgain: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var chatWithUSBtn: UIView!
    var isChatPresented = false
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        // Do any additional setup after loading the view.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        self.headerLabel.attributedText = NSMutableAttributedString(string: "Something seems to be wrong", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        self.bodyLabel.attributedText = NSMutableAttributedString(string: "Let's contact our installation experts to get you some help.", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isChatPresented {
            isChatPresented = false
            APIRequests.shared.isFromChat = true
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func chatUsAction(_ sender: UIButton) {
        IntentsManager.sharedInstance.screenFlow = .extenderInstallFailure
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: IntentsManager.sharedInstance.screenFlow)
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return }
        chatViewController.modalPresentationStyle = .fullScreen
        isChatPresented = true
        self.trackAndNavigateToChat(chatVC: chatViewController)
        
        /// CMAIOS-2629 Hide UI elements once UI is navigated to chat screen,
        /// done to avoid flicker issues on back nav from chat screen
        self.contactSupportTryAgain.isHidden = true
        self.bodyLabel.isHidden = true
        self.chatWithUSBtn.isHidden = true
        self.headerLabel.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func tryAgainButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendUpAndRunningVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        // Cancel button
       if buttonType == .cancel {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
