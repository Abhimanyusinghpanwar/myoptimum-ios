//
//  QuickPayDeAuthViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 2/22/23.
//

import Foundation
import UIKit
import ASAPPSDK
import Lottie

class QuickPayDeAuthViewController: UIViewController {
    
    @IBOutlet weak var deAuthTitle: UILabel!
    @IBOutlet weak var deAuthSubTitle: UILabel!
//    @IBOutlet weak var callUsLabel: UILabel!
//    @IBOutlet weak var callButton: RoundedButton!
    @IBOutlet weak var chatButtonControl: UIControl!
    @IBOutlet weak var payNowButtonControl: UIControl!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    
    var dataRefreshRequired = false
    var dismissCallBack: (() -> Void)?
    var deAuthFlow: DeAuthFlow = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.initialSetup()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME: DeAuthServices.Billing_Deauth_Service_suspended.rawValue,EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func initialSetup() {
        if !dataRefreshRequired {
            configureUI()
            mauiGetListPaymentApiRequest()
            //For Google Analytics
//            CMAAnalyticsManager.sharedInstance.trackAction(
//                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ONLINE_PAYMENT_BLOCKED_DE_AUTH.rawValue,
//                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
        } else {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            self.addLoader()
            self.mauiGetAccountActivityRequest()
        }
    }
    
    func configureUI() {
        /*
         callButton.isHidden = true
         callUsLabel.isHidden = false
         if CommonUtility.deviceHasPhoneCallFeature(phoneNumber: QuickPayViewConstants.phoneNumber) {
         callUsLabel.isHidden = true
         callButton.isHidden = false
         }
         */
        
        /*
        switch deAuthFlow {
        case .homeScreen: // CMAIOS-2462
            deAuthSubTitle.text = "You have a past due balance.\n\n Please chat with us now to make a payment and get you service up and running again"
            self.payNowButtonControl.isHidden = true
        case .none:
            deAuthSubTitle.text = "You have a past due balance. Please pay now to get your service up and running again."
        }
         */
        deAuthSubTitle.text = "You have a past due balance. Please pay now to get your service up and running again."
        
        self.chatButtonControl.layer.cornerRadius = 15.0
        self.payNowButtonControl.layer.cornerRadius = 15.0
        if CurrentDevice.isLargeScreenDevice() {
            deAuthTitle.setLineHeight(1.21)
            deAuthSubTitle.setLineHeight(1.21)
        } else {
            deAuthTitle.setLineHeight(1.15)
            deAuthSubTitle.setLineHeight(1.15)
        }
    }
    
    @IBAction func actionChatWithUs(_ sender: Any) {
//        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Quickpay_Online_Payment_Blocked_De_Auth.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        //CMAIOS-2015
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : DeAuthServices.Billing_Deauth_Chat.rawValue,
                        EVENT_SCREEN_NAME: DeAuthServices.Billing_Deauth_Service_suspended.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.deAuthServiceBlocked)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return
        }
        self.dataRefreshRequired = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    @IBAction func actionPayNowButtonClicked(_ sender: Any) {
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : DeAuthServices.Billing_Deauth_Pay_Now.rawValue,
                        EVENT_SCREEN_NAME: DeAuthServices.Billing_Deauth_Service_suspended.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
        let billPayment = UIStoryboard(name: "BillPay", bundle: Bundle.main).instantiateViewController(withIdentifier: "BillingPaymentViewController") as! BillingPaymentViewController
        let aNavigationController = UINavigationController(rootViewController: billPayment)
        aNavigationController.modalPresentationStyle = .fullScreen
        self.present(aNavigationController, animated: false, completion: nil)
    }
    
    @IBAction func actionCallButton(_ sender: Any) {
        CommonUtility.doPhoneCall(phoneNumber: BillingConstants.phoneNumber)
    }
    
    private func refreshDataAfterChatEnd() {
        QuickPayManager.shared.clearModelAfterChatRefresh()
        if QuickPayManager.shared.getDeAuthState() != "DE_AUTH_STATE_DEAUTH" {
            self.dismissCallBack?()
        }
    }
    
    // MARK: - Get Bill Activity API Call
    func mauiGetAccountActivityRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: nil, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                self.dataRefreshRequired = false
                self.removeLoaderView()
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity Response is \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiGetListPaymentApiRequest()
                    self.refreshDataAfterChatEnd()
                } else {
                    Logger.info("Get Account Bill Activity Response is \(String(describing: error))")
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest() {
//        if MyWifiManager.shared.hasBillPay() == false {
//            return
//        }
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: QuickPayManager.shared.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                } else {
//                    QuickPayManager.shared.ismauiMainApiInProgress.isprogress = false
//                    QuickPayManager.shared.ismauiMainApiInProgress.iserror = true
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                    // Error scenario
                }
            }
        })
    }
    
    // MARK: - O dot Animation View
    private func addLoader() {
        loadingView.isHidden = false
        loadingAnimationView.isHidden = false
        showODotAnimation()
    }
    
    // MARK: - O dot Animation View
    private func showODotAnimation() {
        loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        loadingAnimationView.backgroundColor = .clear
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.play()
    }
    
    private func removeLoaderView() {
        if !loadingView.isHidden {
            loadingView.isHidden = true
            loadingAnimationView.stop()
            loadingAnimationView.isHidden = true
        }
    }
    
}

struct BillingConstants {
    static let phoneNumber = "1-866-213-7456"
}

public enum DeAuthFlow { // CMAIOS-2462
    case homeScreen
    case none
}


