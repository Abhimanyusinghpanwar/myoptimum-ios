//
//  QuickPayAlertViewController.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 15/12/22.
//

import UIKit
import Lottie
import ASAPPSDK

class QuickPayAlertViewController: UIViewController {
 
    @IBOutlet weak var imageTitle: UIImageView!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var label_Subtitle: UILabel!
    @IBOutlet weak var button_LetsDoIt: UIButton!
    @IBOutlet weak var button_Close: UIButton!
    @IBOutlet weak var button_Yes: UIButton!
    @IBOutlet weak var button_NoContinue: UIButton!
    @IBOutlet weak var stack_VerticalButtons: UIStackView!
    @IBOutlet weak var stack_HorizontalButtons: UIStackView!
    @IBOutlet weak var stackPayMethod: UIStackView!
    @IBOutlet weak var headerStack: UIStackView!
    @IBOutlet weak var imageCard: UIImageView!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var yesButtonAnimationView: LottieAnimationView!
    @IBOutlet weak var yesbuttonStack: UIStackView!
    @IBOutlet weak var titleStackTopContraint: NSLayoutConstraint!
    @IBOutlet weak var YesButtonView: UIView!
    @IBOutlet weak var chatButtonView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var titleStackTrailingContraint: NSLayoutConstraint!
    var flowType: flowType = .none //CMAIOS-2516, 2518
    var alertType: QuickPayAlertType = .sureCancelCard
    var updateCommunicationPreference: [String: AnyObject]?
    var successHandler: (() -> Void)? = nil
    var signInIsProgress = false
    @IBOutlet weak var yesButtonViewBottomConstraint: NSLayoutConstraint!
    var dataRefreshRequiredAfterChat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        //CMAIOS-2101
        self.yesButtonViewBottomConstraint.constant = UIDevice.current.hasNotch ? 15 : 35
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.initialSetupOrChatRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.signInFailedAnimation()
    }
    
    private func initialSetupOrChatRefresh() {
        if APIRequests.shared.isReloadNotRequiredForMaui {
            APIRequests.shared.isReloadNotRequiredForMaui = false
        }
        if !dataRefreshRequiredAfterChat {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationItem.hidesBackButton = true
        } else {
            self.addLoader()
            self.mauiGetAccountActivityRequest()
        }
    }
    
    private func refreshViewAfterChat() {
        self.dataRefreshRequiredAfterChat = false
        QuickPayManager.shared.clearModelAfterChatRefresh()
        self.removeLoaderView()
        switch alertType {
        case .systemUnavailable, .paymentSytemUnavailable:
            self.systemUnavailableNavigation()
        case .billingApiFailure(let type):
            if type == .billApiError {
                if let navigationControl = self.navigationController {
                    if let billingview = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                        if let historyView = navigationControl.viewControllers.filter({$0 is PaymentHistoryViewController}).first {
                            navigationControl.popToViewController(historyView, animated: false)
                        } else {
                            billingview.dataRefreshRequiredAfterChat.0 = true
                            billingview.dataRefreshRequiredAfterChat.1 = isPaymentAndHistoryFlow() ? true: false
                            navigationControl.popToViewController(billingview, animated: false)
                        }
                    }
                }
            }
        case .systemUnavailableTypeOne: break
        default: break
        }
    }
    
    private func systemUnavailableNavigation() {
        if let myBillView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            self.navigationController?.popToViewController(myBillView, animated: true)
            return
        }
        self.dismiss(animated: true)
    }
    
    private func systemUnavailableTypeOneNavigation() {
        if let myBillView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            self.navigationController?.popToViewController(myBillView, animated: true)
            return
        }
        self.dismiss(animated: true)
    }
    
    func isPaymentAndHistoryFlow() -> Bool {
        if let _ = self.navigationController?.viewControllers.filter({$0 is PaymentHistoryViewController}).first {
            return true
        }
        return false
    }
    
    private func configureUI() {
        uiStyles()
        updateAccordingAllSetType(setType: alertType)
    }
    
    private func uiStyles() {
        button_NoContinue.layer.borderColor = UIColor(red: 152/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        button_NoContinue.layer.borderWidth = 2.0
    }
    
    private func updateAccordingAllSetType(setType: QuickPayAlertType) {
        stackPayMethod.isHidden = true
        chatButtonView.isHidden = true
        titleStackTrailingContraint.constant = 20.0
        switch setType {
        case .cancelAutoPay:
            label_Subtitle.isHidden = true
            stack_VerticalButtons.isHidden = true
            label_Subtitle.isHidden = true
            YesButtonView.isHidden = false
            label_Title.text = "Are you sure you want to cancel turning on Auto Pay?"
            button_Yes.setTitle("Yes", for: .normal)
            button_NoContinue.setTitle("No, continue", for: .normal)
            imageTitle.image = UIImage(named: "dollar_Circle")
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_CANCEL_TURNING_ON_AUTOPAY.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        case .autoPayThankYou:
            stackPayMethod.isHidden = false
            stack_VerticalButtons.isHidden = false
            YesButtonView.isHidden = true
            label_Subtitle.isHidden = false
            label_Title.text = "Thank you for using Auto Pay"
            label_Subtitle.text = "Your next Auto Pay is set for" + "\n" + QuickPayManager.shared.getDueDate()
            button_LetsDoIt.setTitle("I want to pay now", for: .normal)
            let payMethod = self.getAutoPaymentInfo()
            self.cardName.text = payMethod.1
            self.imageCard.image = UIImage(named: payMethod.2)
        case .paymentSytemUnavailable:
            imageTitle.isHidden = true
            stack_VerticalButtons.isHidden = false
            YesButtonView.isHidden = true
            button_Close.isHidden = false
            label_Subtitle.isHidden = false
            label_Title.text = "Sorry, our payment system is unavailable right now"
            label_Subtitle.text = "Please try again later or chat with us to get help."
            button_LetsDoIt.isHidden = true
            chatButtonView.isHidden = false // chatButtonView is hidden in xib
            titleStackTopContraint.constant = 154
            updateChatButtonStyle()
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ERROR_PAYMENT_SYSTEM_NOT_AVAILABLE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        case .sureCancelCard:
            label_Subtitle.isHidden = true
            stack_VerticalButtons.isHidden = true
            label_Subtitle.isHidden = true
            YesButtonView.isHidden = false
            label_Title.text = "Are you sure you want to cancel adding your card?"
            button_Yes.setTitle("Yes", for: .normal)
            button_NoContinue.setTitle("No, continue", for: .normal)
            imageTitle.image = UIImage(named: "Credit")
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ERROR_CANCEL_ADDING_CARD.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        case .systemUnavailable:
            stack_VerticalButtons.isHidden = false
            YesButtonView.isHidden = true
            button_Close.isHidden = false
            label_Subtitle.isHidden = false
            imageTitle.isHidden = true
            label_Title.text = "Sorry, our payment system is unavailable right now"
            label_Subtitle.text = "Please try again later or chat with us to get help."
            button_LetsDoIt.isHidden = true
            chatButtonView.isHidden = false // chatButtonView is hidden in xib
            titleStackTopContraint.constant = 154
            updateChatButtonStyle()
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ERROR_PAYMENT_SYSTEM_NOT_AVAILABLE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        case .turnOffPaperlessBilling:
            label_Subtitle.isHidden = true
            stack_VerticalButtons.isHidden = true
            label_Subtitle.isHidden = true
            YesButtonView.isHidden = false
            titleStackTrailingContraint.constant = (QuickPayManager.shared.isDiscountBannerEligible() ? 40.0 : 20.0)
            label_Title.text = "Are you sure you want to turn off Paperless Billing" + (QuickPayManager.shared.isDiscountBannerEligible() ? " and lose your $5 discount?"  : "?")
            button_Yes.setTitle("Yes, turn off", for: .normal)
            button_NoContinue.setTitle("No", for: .normal)
            imageTitle.image = UIImage(named: "No_Circle_Paperless")
            //For Google Analytics
            if QuickPayManager.shared.isUserRecievingDiscount() {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : DiscountEligible.ARE_YOU_SURE_YOU_WANT_TO_TURN_OFF_PB_LOSE_DISCOUNT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(
                    eventParam: [EVENT_SCREEN_NAME:  BillPayEvents.QUICKPAY_TURNOFF_PAPERLESSBILLING.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            }
//        case .turnOffAutoPay:
//            stack_VerticalButtons.isHidden = false
//            YesButtonView.isHidden = true
//            button_Close.isHidden = true
//            label_Subtitle.isHidden = false
//            imageTitle.isHidden = true
//            label_Title.text = "You have turned off Auto Pay"
//            label_Subtitle.text = "This will apply from your next payment due date  (Apr. 7, 2022)"
//            button_LetsDoIt.setTitle("Okay", for: .normal)
//        case .updateAutoPay:
//            stack_VerticalButtons.isHidden = false
//            YesButtonView.isHidden = true
//            button_Close.isHidden = true
//            label_Subtitle.isHidden = false
//            imageTitle.image = UIImage(named: "updatedGreen")
//            label_Title.text = "You’re all set!"
//            label_Subtitle.text = "Your Auto Pay settings have been updated."
//            button_LetsDoIt.setTitle("Okay", for: .normal)
//            headerStack.axis = .horizontal
//            headerStack.alignment = .center
        case .billingApiFailure(let type):
            imageTitle.isHidden = true
            stack_VerticalButtons.isHidden = false
            YesButtonView.isHidden = true
            button_Close.isHidden = false
            label_Subtitle.isHidden = false
            button_LetsDoIt.isHidden = true
            label_Title.text = "Sorry, we ran into a problem."
//          label_Subtitle.text = "We can’t show your " + title + " Please try again later"
            label_Subtitle.text = self.getBillingAPIAlertTitle(type: type)
//            button_LetsDoIt.setTitle("Okay", for: .normal)
            chatButtonView.isHidden = false // chatButtonView is hidden in xib
            updateChatButtonStyle()
            titleStackTopContraint.constant = 154
            self.view.layoutIfNeeded()
            if QuickPayManager.shared.initialScreenFlow == .noDue {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_QUICKPAY_VIEW_MY_LAST_BILL_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_QUICKPAY_VIEW_MY_BILL_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            }
            
            if type == .paymentHistoryError { // CMAIOS-1808
                chatButtonView.isHidden = true
            }
        case .turnOffAutoPay:
            label_Subtitle.isHidden = true
            stack_VerticalButtons.isHidden = true
            label_Subtitle.isHidden = true
            YesButtonView.isHidden = false
            titleStackTrailingContraint.constant = (QuickPayManager.shared.isDiscountBannerEligible() ? 40.0 : 20.0)
            label_Title.text = "Are you sure you want to turn off Auto Pay" + (QuickPayManager.shared.isDiscountBannerEligible() ? " and lose your $5 discount?"  : "?")
            button_Yes.setTitle("Yes, turn off", for: .normal)
            button_NoContinue.setTitle("No", for: .normal)
            imageTitle.image = UIImage(named: "dollar_Circle")
            if QuickPayManager.shared.isUserRecievingDiscount() {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : DiscountEligible.ARE_YOU_SURE_YOU_WANT_TO_TURN_OFF_AP_LOSE_DISCOUNT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            }
        case .plainErrorMessage:
            imageTitle.isHidden = true
            stack_VerticalButtons.isHidden = false
            YesButtonView.isHidden = true
            button_Close.isHidden = true
            label_Subtitle.isHidden = false
            label_Title.text = "Sorry, we ran into a problem."
            label_Subtitle.text = "Please try again later"
            button_LetsDoIt.setTitle("Okay", for: .normal)
            chatButtonView.isHidden = true // chatButtonView is hidden in xib
            titleStackTopContraint.constant = 154
            self.view.layoutIfNeeded()
        case .systemUnavailableTypeOne:
            stack_VerticalButtons.isHidden = false
            YesButtonView.isHidden = true
            button_Close.isHidden = false
            label_Subtitle.isHidden = false
            imageTitle.isHidden = true
            label_Title.text = "Sorry, our payment system is unavailable right now"
            label_Subtitle.text = "Please try again later or chat with us to get help."
            button_LetsDoIt.isHidden = true
            chatButtonView.isHidden = false // chatButtonView is hidden in xib
            titleStackTopContraint.constant = 154
            updateChatButtonStyle()
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ERROR_PAYMENT_SYSTEM_NOT_AVAILABLE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
        self.updateLineHeight()
    }
    
    private func updateLineHeight() {
        self.label_Title.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.label_Subtitle.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
    }
    
    private func updateChatButtonStyle() {
        self.chatButtonView.layer.borderColor = buttonBorderLightGrayColor.cgColor
        self.chatButtonView.layer.borderWidth = 2.0
        self.chatButtonView.layer.cornerRadius = 15.0
    }
    
    ///  Get pay method info (like nomral, autopay .......)
    /// - Returns: pay emthod (card or bank name, account or card nbumber, card or bank image)
    func getAutoPaymentInfo() -> (Bool, String, String) {
        var paymethodInfo = (false, "", "") // (bank or Card, card or bank acc number, image name)
        switch alertType {
        case .autoPayThankYou:
            paymethodInfo = QuickPayManager.shared.getAutoPayMethodMop()
        default: break
        }
        return paymethodInfo
    }
    
    @IBAction func actionLetsDoIt(_ sender: Any) {
        switch alertType {
        case .cancelAutoPay: break
        case .autoPayThankYou:
            self.navigationController?.popToRootViewController(animated: true)
        case .sureCancelCard: break
        case .systemUnavailable, .paymentSytemUnavailable:
            failureNavigations()
        case .turnOffPaperlessBilling: break
//        case .turnOffAutoPay, .updateAutoPay:
//            successHandler?()
        case .billingApiFailure(let type):
            if type == .billApiError {
                if let paymentView = self.navigationController?.viewControllers.filter({$0.isKind(of: PaymentHistoryViewController.classForCoder())}).first {
                    self.navigationController?.popToViewController(paymentView, animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            } else if type == .paymentHistoryError { // CMAIOS-1808
                if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingViewContrller.classForCoder())}).first {
                    self.navigationController?.popToViewController(billingView, animated: true)
                } else if let pdfviewController = self.navigationController?.viewControllers.filter({$0.isKind(of: BillPDFViewController.classForCoder())}).first {
                    self.navigationController?.popToViewController(pdfviewController, animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            } else {
                failureNavigations()
            }
        case .turnOffAutoPay: break
        case .plainErrorMessage:
//            if let viewController = self.presentingViewController?.presentingViewController as? AnimationViewController {
//                viewController.dismiss(animated: true)
//            }
            if let myBillView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    myBillView.dismiss(animated: false)
                }
                return
            } else {
                fallBackNavigation()
            }
        case .systemUnavailableTypeOne:
            failureNavigations()
        }
    }
    
    private func failureNavigations() {
        // CMAIOS-2099
        if let myBillView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(myBillView, animated: true)
            }
            return
        } else if let navigationCtrl = self.presentingViewController as? UINavigationController {
            if let _ = navigationCtrl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    navigationCtrl.dismiss(animated: false)
                }
                return
            } else if let _
                        = navigationCtrl.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                self.dismiss(animated: true) //Fixed navigation issue on click of close button if the user is coming from OneTimeFailureScreen from SP Spotlight card and lands upon make A payment screen after selecting differenyt MOP and taps on PayNow button
            }
        } else {
            if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            } else {
                fallBackNavigation()
            }
        }
    }
    
    private func fallBackNavigation() {
        self.dismiss(animated: true)
    }
    
    private func failureNavigationTypeOne() {
        if let myBillView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                // CMAIOS-2099
                self.navigationController?.popToViewController(myBillView, animated: true)
            }
            return
        } else if let navigationCtrl = self.presentingViewController?.presentingViewController as? AnimationViewController {
            self.dismiss(animated: false) {
                navigationCtrl.dismiss(animated: false)
            }
            return
        } else if let animationView = self.presentingViewController?.presentingViewController?.presentingViewController as? AnimationViewController {
            self.dismiss(animated: false) {
                animationView.dismiss(animated: false)
            }
            return
        }
    }

    @IBAction func actionClose(_ sender: Any) {
        switch alertType {
        case .systemUnavailable, .paymentSytemUnavailable:
            failureNavigations()
        case .billingApiFailure(let type):
            guard type == .paymentHistoryError else {
                self.defaultNavigation()
                return
            }
            if let pdfviewController = self.navigationController?.viewControllers.filter({$0.isKind(of: BillPDFViewController.classForCoder())}).first {
                self.navigationController?.popToViewController(pdfviewController, animated: true)
            } else if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
                self.navigationController?.popToViewController(billingView, animated: true)
            } else {
                self.dismiss(animated: true)
            }
        case .systemUnavailableTypeOne:
            failureNavigationTypeOne()
        default:
            self.defaultNavigation()
        }
    }
    
    private func popToBillingPreferencesVC() {
        if let billPreferenceVC = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPreferencesViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(billPreferenceVC, animated: true)
        }
    }
    
    private func defaultNavigation() {
        if let historyView = self.navigationController?.viewControllers.filter({$0.isKind(of: PaymentHistoryViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(historyView, animated: true)
        } else if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(billingView, animated: true)
        } else if  ((self.navigationController?.viewControllers.contains(self)) != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func actionYes(_ sender: Any) {
        switch alertType {
        case .cancelAutoPay:
            switch flowType { //CMAIOS-2516, 2518
            case .autoPayFromLetsDoIt:
                self.navigateToSchedulePaymentVC()
            default:
                self.navigateBackToStartOfFlow()
            }
        case .autoPayThankYou: break
        case .paymentSytemUnavailable: break
        case .sureCancelCard:
            self.moveToRootScreen(alertType: alertType)
        case .systemUnavailable: break
        case .turnOffPaperlessBilling:
            turnOffPaperlessBillingApiCall()
//        case .turnOffAutoPay, .updateAutoPay: break
        case .billingApiFailure(type: _): break
        case .turnOffAutoPay:
            turnOffAutoPayApiCall()
        case .plainErrorMessage: break
        case .systemUnavailableTypeOne: break
        }
    }
    
    @IBAction func actionChatWithUs(_ sender: Any) {
        var event = ""
        APIRequests.shared.isReloadNotRequiredForMaui = true
        if alertType == .paymentSytemUnavailable {
            event = ASAPChatScreen.Chat_Error_Payment_System_Not_Available.rawValue
        } else if alertType == .billingApiFailure(type: BillingApiAlert.billApiError) {
            event = ASAPChatScreen.Chat_View_My_Bill_Failed.rawValue
        }
        
        if !event.isEmpty {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
        
        guard let intentDict = getIntent() else {
            if let chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil) {
                chatViewController.modalPresentationStyle = .fullScreen
                self.trackAndNavigateToChat(chatVC: chatViewController)
            }
            return
        }
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentDict) else {
            return }
        if alertType == .billingApiFailure(type: BillingApiAlert.billApiError) {
            dataRefreshRequiredAfterChat = true
        }
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    private func getIntent() -> [String: Any]? {
        var intent: [String: Any]?
        if alertType == .paymentSytemUnavailable {
            intent = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.paymentSysytemDown)
        } else if alertType == .billingApiFailure(type: BillingApiAlert.billApiError) {
            intent = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.unableToLoadBill)
        }
        return intent
    }
    
    private func turnOffPaperlessBillingApiCall() {
        guard let jsonParams = updateCommunicationPreference else {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiUpdateBillCommunicationPreference(jsonParams: jsonParams, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.signInIsProgress = false
                    self.yesButtonAnimationView.pause()
                    self.yesButtonAnimationView.play(fromProgress: self.yesButtonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self.signInFailedAnimation()
                        QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences = QuickPayManager.shared.modelQuickPayUpdateBillPrefernce?.billCommunicationPreference
                        self.navigateToTurnOffAlert(allSetType: .turnOffBillingAlert)
                    }
                } else {
                    self.showErrorScreen()
                }
            }
        })
    }
    
    private func turnOffAutoPayApiCall() {
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiRemoveAutoPay() { [weak self] result in
            switch result {
            case .success:
                QuickPayManager.shared.mauiGetAccountBillRequest() { error in
                    self?.signInIsProgress = false
                    self?.yesButtonAnimationView.pause()
                    self?.yesButtonAnimationView.play(fromProgress: self?.yesButtonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        guard error == nil else {
                            self?.showErrorScreen()
                            return
                        }
                        self?.navigateToTurnOffAlert(allSetType: .turnOffAutoPay)
                    }
                }
            case .failure:
                self?.showErrorScreen()
            }
        }
    }

    private func showErrorScreen() {
        self.signInFailedAnimation()
        self.alertType = .systemUnavailable
        self.configureUI()
    }
    
    func handleErrorQuickPayAlert() {
        self.showErrorScreen()
    }
    
    //CMAIOS-2516, 2518
    private func navigateToSchedulePaymentVC() {
      if let vc = self.navigationController?.viewControllers.filter({$0 is SchedulePaymentViewController}).first as? SchedulePaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    private func navigateBackToStartOfFlow() {
        if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        } else if let vc = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        } else if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        } else  if let navigationControl = self.presentingViewController as? UINavigationController {
            if let vc = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: {
                        navigationControl.popToViewController(vc, animated: true)
                    })
                }
            } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func moveToRootScreen(alertType: QuickPayAlertType) {
        switch alertType {
        case .sureCancelCard:
            if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                /* self.dismiss(animated: true) */
                if let setupAutoPayViewController = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC { //CMAIOS-2882
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(setupAutoPayViewController, animated: true)
                    }
                } else {
                    self.dismiss(animated: true)
                }
            } else if let managedPayments = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController { //CMAIOS-2765
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(managedPayments, animated: true)
                }
                return
            } else if let billPreferenceVC = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billPreferenceVC, animated: true)
                }
                return
            } else if let setupView = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(setupView, animated: true)
                }
                return
            } else if let billPayView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billPayView, animated: true)
                }
                return
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        default:
            if self.presentingViewController?.presentingViewController is ChoosePaymentViewController
            {
                if let choosePayment = self.presentingViewController?.presentingViewController as? ChoosePaymentViewController {
                    choosePayment.dismiss(animated: true)
                    return
                }
            }
            if let navigationControl = self.presentingViewController?.presentingViewController as? UINavigationController {
                if let vc = navigationControl.viewControllers.filter({$0 is AddingPaymentMethodViewController}).first as? AddingPaymentMethodViewController {
                    DispatchQueue.main.async {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(vc, animated: true)
                        })
                    }
                    return
                }
            }
            if let navigationControl = self.presentingViewController?.presentingViewController as? UINavigationController {
                if let vc = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                    DispatchQueue.main.async {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(vc, animated: true)
                        })
                    }
                    return
                }
            }
            if let viewController = self.presentingViewController?.presentingViewController as? ThanksAutoPayViewController {
                DispatchQueue.main.async {
                    viewController.dismiss(animated: true)
                    return
                }
            }
        }
    }
    
    @IBAction func actionNoContinue(_ sender: Any) {
        switch alertType {
        case .turnOffPaperlessBilling, .turnOffAutoPay:
            if let editBillingView = self.navigationController?.viewControllers.filter({$0 is EditBillingViewController}).first as? EditBillingViewController {
                DispatchQueue.main.async {
                    //editBillingView.screenType = .landingScreen // CMAIOS-2474
                    self.navigationController?.popToViewController(editBillingView, animated: true)
                }
            } else if let editAutoPayView = self.navigationController?.viewControllers.filter({$0 is EditAutoPayViewController}).first as? EditAutoPayViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(editAutoPayView, animated: true)
//                    editAutoPayView.enableEditing = false
                }
            }
        default:
            // CMAIOS-2099
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func navigateToTurnOffAlert(allSetType: AllSetType) {
        let storyboard = UIStoryboard(name: "Payments", bundle: nil)
        if let alertViewController = storyboard.instantiateViewController(withIdentifier: "AutoPayAllSetViewController") as? AutoPayAllSetViewController {
            alertViewController.allSetType = allSetType
//            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(alertViewController, animated: true)
        }
    }
    
    // MARK: - Finish Setup Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.yesButtonAnimationView.isHidden = true
        self.stack_HorizontalButtons.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.yesButtonAnimationView.isHidden = false
        }
        self.yesButtonAnimationView.backgroundColor = .clear
        self.yesButtonAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.yesButtonAnimationView.loopMode = .playOnce
        self.yesButtonAnimationView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.yesButtonAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.yesButtonAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.yesButtonAnimationView.currentProgress = 3.0
        self.yesButtonAnimationView.stop()
        self.yesButtonAnimationView.isHidden = true
        self.stack_HorizontalButtons.alpha = 0.0
        self.stack_HorizontalButtons.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.stack_HorizontalButtons.alpha = 1.0
        }
    }
    
    private func getBillingAPIAlertTitle(type: BillingApiAlert) -> String {
        switch type {
        case .billApiError:
            return MessageConstants.billApiErrorMessage
        case .autoPayApiErrorMessage:
            return MessageConstants.autoApiErrorMessage
        case .paperlessApiErrorMessage:
            return MessageConstants.paperlessApiErrorMessage
        case .helpWithBillingErrorMessage:
            return MessageConstants.helpWithBillingErrorMessage
        case .paymentHistoryError:
            return MessageConstants.paymentHistoryErrorMessage
        }
    }
}

extension QuickPayAlertViewController {
    // MARK: - MAUI APIs
    func mauiGetAccountActivityRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity Response is \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiRequestGetAccountBill()
                } else {
                    Logger.info("Get Account Bill Activity Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    /// To get the initial GetAccountBill data for home screen, but its not blocker API
    func mauiRequestGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.mauiGetListPaymentApiRequest()
                } else {
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: QuickPayManager.shared.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                    self.refreshViewAfterChat()
                } else {
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    private func handleRefreshApiFailures() {
        self.dataRefreshRequiredAfterChat = false
        self.removeLoaderView()
        self.alertType = .systemUnavailable
        self.configureUI()
    }
    
    private func showQuickAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        viewcontroller.modalPresentationStyle = .fullScreen
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        self.present(viewcontroller, animated: animated)
    }
    
    private func addLoader() {
        loadingView.backgroundColor = .systemBackground
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
        if !self.loadingView.isHidden {
            self.loadingView.isHidden = true
            self.loadingAnimationView.stop()
            self.loadingAnimationView.isHidden = true
        }
    }
}

public let buttonBorderLightGrayColor = UIColor(red: 152/255.0, green: 150/255.0, blue: 150/255.0, alpha: 0.5)

enum QuickPayAlertType: Equatable {
    case cancelAutoPay
    case autoPayThankYou
    case paymentSytemUnavailable
    case sureCancelCard
    case systemUnavailable
    case turnOffPaperlessBilling
//    case turnOffAutoPay
//    case updateAutoPay
    case billingApiFailure(type: BillingApiAlert)
    case turnOffAutoPay
    case plainErrorMessage
    case systemUnavailableTypeOne
}

enum BillingApiAlert: Equatable {
    case billApiError
    case paperlessApiErrorMessage
    case autoPayApiErrorMessage
    case helpWithBillingErrorMessage
    case paymentHistoryError
}

struct MessageConstants {
    static let billApiErrorMessage = "We can't show your bill right now. Please try again later or chat with us to get help."
    static let paperlessApiErrorMessage = "We can’t show your Paperless Billing information. Please try again later"
    static let autoApiErrorMessage = "We can’t show your Auto Pay information. Please try again later"
    static let helpWithBillingErrorMessage = "We can’t show Help with billing information. Please try again later"
    static let paymentHistoryErrorMessage = "We can't show your billing and payment history right now. Please try again later."
}
