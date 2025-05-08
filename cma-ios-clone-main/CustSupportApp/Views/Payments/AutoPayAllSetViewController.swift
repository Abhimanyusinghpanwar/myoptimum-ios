//
//  AutoPayAllSetViewController.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 14/12/22.
//

import UIKit
import Lottie

class AutoPayAllSetViewController: UIViewController {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var label_Sub_Title: UILabel!
    @IBOutlet weak var label_PaidWith: UILabel!
    @IBOutlet weak var image_CarType: UIImageView!
    @IBOutlet weak var label_CardType: UILabel!
    @IBOutlet weak var label_Payment_Due: UILabel!
    @IBOutlet weak var label_Amount: UILabel!
    @IBOutlet weak var label_Balance: UILabel!
    @IBOutlet weak var label_Next_Auto_Pay: UILabel!
    @IBOutlet weak var label_Send_Billing_To: UILabel!
    @IBOutlet weak var label_Email_Id: UILabel!
    @IBOutlet weak var label_Date: UILabel!
    @IBOutlet weak var button_Okay: UIButton!
    @IBOutlet weak var label_LastBill: UILabel!
    @IBOutlet weak var stackPaidWith: UIStackView!
    @IBOutlet weak var stackAmountBalance: UIStackView!
    @IBOutlet weak var stackDate: UIStackView!
    @IBOutlet weak var billingVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var autoVerricalConstrint: NSLayoutConstraint!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var stackSendMail: UIStackView!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    // Sliding Drawer
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var buttonOkay_Drawer: UIButton!
    @IBOutlet weak var PayNowAnimationView: LottieAnimationView!
    @IBOutlet weak var stackPayNow: UIStackView!
    @IBOutlet weak var labelTitle_Drawer: UILabel!
    @IBOutlet weak var labelSubTitle_Drawer: UILabel!
    @IBOutlet weak var payButtonTopConstraint: NSLayoutConstraint!
    
    var allSetType: AllSetType = .paperlessBilling
    let sharedManager = QuickPayManager.shared
    var emailIdConfirmation = ""
    var successHandler: (() -> Void)? = nil
    var qualtricsAction : DispatchWorkItem?
    var payMethod :PayMethod?
    var flowType: flowType = .none //CMAIOS-2516
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        updateAccordingAllSetType(setType: allSetType)
    }
    
    private func updateAccordingAllSetType(setType: AllSetType) {
        label_Sub_Title.numberOfLines = 2
        switch setType {
        case .newAutoPay:
            updateVisibility(show: false)
            configureNewAutoPay()
        case .turnOnAutoPay:
            updateVisibility(show: false)
            configureTurnOnAutoPay()
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_ENROLLMENT_CONFIRMATION.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            self.addQualtrics(screenName: BillPayEvents.QUICKPAY_AUTOPAY_ENROLLMENT_CONFIRMATION.rawValue)
        case .paperlessBilling:
            self.paperlessBillingUiSetup()
        case .turnOnPaperlessBillingBP://CMAIOS-2537 //CMAIOS-2766
            self.paperlessBillingUiSetup()
            self.setLabelContentAsPerDiscountEligibility()  //CMAIOS-2551
            label_Sub_Title.numberOfLines = 0
            if QuickPayManager.shared.isDiscountEligible() {
                label_Sub_Title.text = (label_Sub_Title.text ?? "") + "\n\nWe'll send the billing notifications to \(QuickPayManager.shared.modelQuickPayUpdateBillPrefernce?.billCommunicationPreference?.email ?? "")"
            }
        case .turnOffBillingAlert:
            updateVisibility(show: true)
            titleImage.isHidden = true
            label_Title.text = "You have turned off Paperless Billing"
            label_Sub_Title.text = "Your next available statement will be mailed to your billing address."
            stackSendMail.isHidden = true
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_PAPERLESSBILLING_CANCEL.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            self.addQualtrics(screenName: BillPayEvents.QUICKPAY_PAPERLESSBILLING_CANCEL.rawValue)
        case .updateAutopay:
            updateVisibility(show: true)
            stackSendMail.isHidden = true
            label_Sub_Title.text = "Your Auto Pay settings have been updated."
        case .updateScheduledPayment:
            updateVisibility(show: true)
            stackSendMail.isHidden = true
            label_Sub_Title.text = "Your Scheduled payment has been updated"
            self.addQualtrics(screenName: PaymentScreens.SCHEDULED_PAYMENT_HAS_BEEN_UPDATED.rawValue)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : PaymentScreens.SCHEDULED_PAYMENT_HAS_BEEN_UPDATED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        case .turnOffAutoPay:
            updateVisibility(show: true)
            stackSendMail.isHidden = true
            titleImage.isHidden = true
            label_Title.text = "You have turned off Auto Pay"
            /* CMAIOS-1639
            var date = ""
            if let nextPayDue = sharedManager.modelListPayment?.payments?.first?.paymentDate {
                let dateString = CommonUtility.convertDateStringFormats(dateString: nextPayDue, dateFormat: "MMM. d, YYYY")
                date = " on \(dateString)."
            }
             */
            /* CMAIOS-2545
            let date = (sharedManager.getAutoPayScheduleDate() == "" ? "": " on \(sharedManager.getAutoPayScheduleDate()).")*/
            label_Sub_Title.text = "This change will take effect with your next bill."
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_TURNED_OFF.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            self.addQualtrics(screenName: BillPayEvents.QUICKPAY_AUTOPAY_TURNED_OFF.rawValue)
        case .autoPaymentErrorFlow:
            //CMAIOS-2103
            updateVisibility(show: true)
            stackSendMail.isHidden = true
            titleImage.isHidden = false
            label_Title.text = "You're all set!"
            label_Sub_Title.numberOfLines = 0
            label_Sub_Title.text = "Your Auto Pay settings have been updated \n\nThese changes will take effect starting with the next billing period."
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AutoPayFailureDetails.AUTO_PAY_MOP_UPDATE_SUCCESS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]) //CMAIOS-2465
        case .turnOnAutoPaySP:
            // CMAIOS-2549
            updateVisibility(show: true)
            label_Sub_Title.numberOfLines = 0
            self.stackSendMail.isHidden = true
            self.updateTitleMessage()
            if QuickPayManager.shared.isDiscountPresent() { //CMAIOS-2878
                self.updateforAutoPaySetupSuccess()
            }
        case .turnOnPaperlessBillingSP: //CMAIOS-2493
            self.setGAPageNames(DiscountEligible.PAPERLESS_BILLING_YOURE_ALL_SET_CONFIRMATION.rawValue)
            updateVisibility(show: true)
            self.billingVerticalConstraint.priority = UILayoutPriority(999)
            self.autoVerricalConstrint.priority = UILayoutPriority(250)
            stackPaidWith.isHidden = true
            stackDate.isHidden = true
            stackAmountBalance.isHidden = true
            setLabelContentAsPerDiscountEligibility()  //CMAIOS-2551
            label_Send_Billing_To.isHidden = true
            label_Email_Id.isHidden = true
            label_Sub_Title.numberOfLines = 0
            label_Sub_Title.text = (label_Sub_Title.text ?? "") + "\n\nWe'll send the billing notifications to \(sharedManager.getBillCommunicationEmail())" //CMAIOS-2880
        case .turnOnPBFromMoreOptions(let isAutoPay):
            // CMAIOS-2565
            updateVisibility(show: true)
            label_Sub_Title.numberOfLines = 0
            self.stackSendMail.isHidden = true
            self.updateTitleMessageForMoreOptionFlow(isAutoPay: isAutoPay)
            if QuickPayManager.shared.isDiscountPresent() { //CMAIOS-2878
                self.updateforAutoPaySetupSuccessForMoreOption(isAutoPay: isAutoPay)
            }
        }
        self.updateLineHeight()
    }
    
    // CMAIOS-2766
    private func paperlessBillingUiSetup() {
        updateVisibility(show: true)
        self.billingVerticalConstraint.priority = UILayoutPriority(999)
        self.autoVerricalConstrint.priority = UILayoutPriority(250)
        stackPaidWith.isHidden = true
        stackDate.isHidden = true
        stackAmountBalance.isHidden = true
        label_Send_Billing_To.isHidden = true
        label_Sub_Title.text = "You’re now enrolled in Paperless Billing."
        label_Email_Id.isHidden = true
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_PAPERLESSBILLING_ENROLL_SUCCESS.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        self.addQualtrics(screenName: BillPayEvents.QUICKPAY_PAPERLESSBILLING_ENROLL_SUCCESS.rawValue)
    }
    
    private func updateTitleMessageForMoreOptionFlow(isAutoPay: Bool) {
        //CMA-3337
        if isAutoPay {
            label_Title.text = "You're enrolled"
            label_Sub_Title.text = "You're now enrolled in Auto Pay.\n\nYour first Auto Pay will be collected on the next payment due date with \(self.getCurrentPaymethod())."
        } else {
            label_Sub_Title.text = "You're now enrolled in Paperless Billing.\n\nWe'll send the billing notifications to \(sharedManager.getBillCommunicationEmail())"
        }
    }
        
    /// Show Auto Pay information as per the enroltypes
    private func updateforAutoPaySetupSuccess() {
        switch QuickPayManager.shared.enrolType {
        case .both:
            self.presentWithBottomToTopAnimation(hasAmoutDue: Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0)
        case .onlyAutoPay:
            self.presentWithBottomToTopAnimation(hasAmoutDue: Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0)
        case .onlyPaperless:
            break
        case .none: break
        }
    }
    
    /// Show Auto Pay More Option as per the enroltypes
    private func updateforAutoPaySetupSuccessForMoreOption(isAutoPay: Bool) {
        if isAutoPay {
            self.presentWithBottomToTopAnimation(hasAmoutDue: Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0)
        }
    }
    
    //CMAIOS-2558
    func setGAPageNames(_ screenTag: String) {
        if !screenTag.isEmpty {
            let custParams = [EVENT_SCREEN_NAME : screenTag, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
        }
    }
    
    //CMAIOS-2551
    func setLabelContentAsPerDiscountEligibility() {
        switch QuickPayManager.shared.isDiscountEligible() {
        case true:
            label_Sub_Title.text = "You're enrolled in Paperless Billing and get $5 off every month."
        case false:
            label_Sub_Title.text = "You're now enrolled in Paperless Billing.\n\nWe'll send the billing notifications to \(sharedManager.getBillCommunicationEmail())" // CMAIOS-2551
        }
    }
    
    private func getCurrentPaymethod() -> String {
        var payMethod = ""
        if let paymethod = sharedManager.tempPaymethod {
            let autoPaymethod = sharedManager.payMethodInfo(payMethod: paymethod)
            payMethod = autoPaymethod.0
        } else {
            if let autoPayMethod = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
                let paymethod = sharedManager.payMethodInfo(payMethod: autoPayMethod)
                payMethod = paymethod.0
            }
        }
        return payMethod
    }
    
    private func updateTitleMessage() {
        switch QuickPayManager.shared.enrolType {
        case .onlyAutoPay:
            // CMAIOS:2549
            switch (QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.discountEligible ?? false,
                    Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0) {
            case (true, _): // CMAIOS:-2496
                //                label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing and get $5 off every month.\n\nYour first Auto Pay will be collected next month with \(self.getCurrentPaymethod()). We'll send billing notifications to \(sharedManager.getBillCommunicationEmail())"
                //                label_Sub_Title.text = "You're enrolled in Auto Pay and get $5 off every month."
                label_Title.text = "You're enrolled"
                let subTitle = (flowType == .appbNotEnrolled) ? "." : " and get $5 off every month."
                label_Sub_Title.text = "You're now enrolled in Auto Pay" + subTitle + "\n\nYour first Auto Pay will be collected on the next payment due date with \(self.getCurrentPaymethod())."
                self.setGAPageNames(DiscountEligible.CONFIRMATION_ENROLLED_IN_AUTO_PAY.rawValue)
            case (false, _), (_, false):
                label_Sub_Title.text = "You're now enrolled in Auto Pay."
            default: break
            }
        case .both:
            // CMAIOS-2675 // CMAIOS-2676
            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.discountEligible ?? false {
                if (Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0) {
                    label_Title.text = "You're enrolled"
                    label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing and get $5 off every month.\n\nYour first Auto Pay will be collected on the next payment due date with \(self.getCurrentPaymethod())."
                } else {
                    label_Title.text = "You're enrolled"
                    //CMAIOS-2791 Copy update fix
                    label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing and get $5 off every month.\n\nYour first Auto Pay will be collected on the next payment due date with \(self.getCurrentPaymethod())."
                }
            } else {
                if (Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0) {
                    label_Title.text = "You're enrolled"
                    label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing.\n\nYour first Auto Pay will be collected on the next payment due date with \(self.getCurrentPaymethod())."
                } else {
                    label_Title.text = "You're enrolled"
                    //CMAIOS-2791 Copy update fix
                    label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing.\n\nYour first Auto Pay will be collected on the next payment due date with \(self.getCurrentPaymethod())."
                }
            }
            //            label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing and get $5 off every month.\n\nYour first Auto Pay will be collected next month with \(self.getCurrentPaymethod()). We'll send billing notifications to \(sharedManager.getBillCommunicationEmail())"
            self.setGAPageNames(DiscountEligible.CONFIRMATION_ENROLLED_AP_AND_PB.rawValue)
        case .onlyPaperless: // Message should be change
            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.discountEligible ?? false {
                label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing and get $5 off every month.\n\nYour first Auto Pay will be collected next month with \(self.getCurrentPaymethod()). We'll send billing notifications to \(sharedManager.getBillCommunicationEmail())"
            } else {
                label_Sub_Title.text = "You're now enrolled in Auto Pay and Paperless Billing.\n\nYour first Auto Pay will be collected next month with \(self.getCurrentPaymethod()). We'll send billing notifications to \(sharedManager.getBillCommunicationEmail())"
            }
        case .none: break
        }
    }
    
    private func addQualtrics(screenName: String) {
        self.qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    private func updateLineHeight() {
        self.label_Sub_Title.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.label_Sub_Title.textAlignment = .left
        self.labelTitle_Drawer.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.labelTitle_Drawer.textAlignment = .left
    }
    
    private func updateVisibility(show: Bool) {
        stackPaidWith.isHidden = show
        stackDate.isHidden = show
        stackAmountBalance.isHidden = show
    }
    
    private func configureNewAutoPay() {
        /* CMAIOS-1573
         if let nextPayDue = sharedManager.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate {
         let dateString = CommonUtility.convertDateStringFormats(dateString: nextPayDue, dateFormat: "MMM. d, YYYY") // TBD
         self.label_Next_Auto_Pay.text = "Next Auto Pay Date is \(dateString)"
         }
         */
        self.label_Next_Auto_Pay.isHidden = true
        if QuickPayManager.shared.getAutoPayScheduleDate() != "" {
            self.label_Next_Auto_Pay.isHidden = false
            self.label_Next_Auto_Pay.text = QuickPayManager.shared.getAutoPayScheduleDate()
        }
//        self.label_LastBill.text = "Last bill was $" + sharedManager.getCurrentAmount() // CMAIOS-1714
        self.label_LastBill.isHidden = true
        self.label_Email_Id.text = sharedManager.getBillCommunicationEmail()
        self.label_PaidWith.text = "Pay with"
        if let paymethod = sharedManager.tempPaymethod {
            let autoPaymethod = sharedManager.payMethodInfo(payMethod: paymethod)
            image_CarType.image = UIImage(named: autoPaymethod.1)
            label_CardType.text = autoPaymethod.0
            expirationDateLabel.text =  (autoPaymethod.2 == "Checking account") ?  autoPaymethod.2: "Exp.\(autoPaymethod.2)"
        } else {
            if let autoPayMethod = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
                let paymethod = sharedManager.payMethodInfo(payMethod: autoPayMethod)
                image_CarType.image = UIImage(named: paymethod.1)
                label_CardType.text = paymethod.0
                expirationDateLabel.text = (paymethod.2 == "Checking account") ?  paymethod.2: "Exp.\(paymethod.2)"
            }
        }
    }
    
    private func configureTurnOnAutoPay() {
        // CMAIOS-1249
//        if let nextPayDue = sharedManager.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate { /* CMAIOS - 1249 */
//            let dateString = CommonUtility.convertDateStringFormats(dateString: nextPayDue, dateFormat: "MMM. d, YYYY") // TBD
//            self.label_Next_Auto_Pay.text = dateString
//        }
        self.label_PaidWith.text = "Pay with"
        /* CMAIOS-1249 */
//        self.label_LastBill.text = "Amount $" + sharedManager.getCurrentAmount()
        self.label_LastBill.isHidden = true
        self.label_Next_Auto_Pay.isHidden = true
        /* CMAIOS-1249 */
        self.label_Email_Id.text = sharedManager.getBillCommunicationEmail()
        
        if let paymethod = payMethod {
            self.updateCommonUiComponents(paymethod: paymethod)
        } else if let paymethod = sharedManager.tempPaymethod {
            self.updateCommonUiComponents(paymethod: paymethod)
        } else {
            if let autoPayMethod = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
                let paymethod = sharedManager.payMethodInfo(payMethod: autoPayMethod)
                image_CarType.image = UIImage(named: paymethod.1)
                label_CardType.text = paymethod.0
                expirationDateLabel.text = (paymethod.2 == "Checking account") ?  paymethod.2: "Exp.\(paymethod.2)"
                self.cardView.setBorderUIForBankMOP(paymethod: autoPayMethod)
            }
        }
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.AUTOPAY_YOU_ARE_ALL_SET.rawValue,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func updateCommonUiComponents(paymethod: PayMethod) {
        let autoPaymethod = sharedManager.payMethodInfo(payMethod: paymethod)
        image_CarType.image = UIImage(named: autoPaymethod.1)
        label_CardType.text = autoPaymethod.0
        expirationDateLabel.text =  (autoPaymethod.2 == "Checking account") ?  autoPaymethod.2: "Exp.\(autoPaymethod.2)"
        self.cardView.setBorderUIForBankMOP(paymethod: paymethod)
    }
    
    @IBAction func actionOkay(_ sender: Any) {
        self.qualtricsAction?.cancel()
        switch allSetType {
        case .newAutoPay:
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
            } else if let navigationControl = self.presentingViewController as? UINavigationController {
                if let vc = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(vc, animated: true)
                        })
                    }
                }  //CMAIOS-2335 Home Navigation fix
                else if let vc = navigationControl.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(vc, animated: true)
                        })
                    }
                }
            } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            }
        case .turnOnAutoPay:
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
            } else if let navigationControl = self.presentingViewController as? UINavigationController {
                if let vc = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(vc, animated: true)
                        })
                    }
                }
            }
        case .paperlessBilling:
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        case .turnOnPaperlessBillingBP: //CMAIOS-2537
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        case .turnOffBillingAlert,.turnOffAutoPay : //CMAIOS-2545, CMAIOS-2546
            let isAPEnabled = QuickPayManager.shared.isAutoPayEnabled()
            let isPBEnabled = QuickPayManager.shared.isPaperLessBillingEnabled()
            switch (isAPEnabled,isPBEnabled) {
            case (false, false):
                navigateToDesiredVC()
            default:
                /* ManagePaymentsViewController Flow */
                if let deleteManagePayments = self.navigationController?.viewControllers.filter({$0 is DeleteManagePaymentOptionsViewController}).first as? DeleteManagePaymentOptionsViewController { //CMAIOS-2841
                    deleteManagePayments.isShowBottomLabel = false
                    deleteManagePayments.buttonTitleString = ("Yes, delete", "No")
                    deleteManagePayments.refreshRequired = true
                    self.navigationController?.popToViewController(deleteManagePayments, animated: true)
                } else if let vc = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                } else if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                    self.dismiss(animated: true)
                }
            }
        case .updateAutopay:
            navigateToDesiredVC()
        case .updateScheduledPayment:
            successHandler?()
        case .autoPaymentErrorFlow, .turnOnPaperlessBillingSP:
            //CMAIOS-2103 //CMAIOS-2493
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            } else if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        case .turnOnAutoPaySP:
            if flowType == .appbNotEnrolled && self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first is BillingPaymentViewController { //CMAIOS-2798
                guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
                self.navigationController?.navigationBar.isHidden = true
                viewcontroller.isFromAllsetScreen = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
                return
            }
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            } else if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            } else if let homeVc = self.navigationController?.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                self.navigationController?.popToViewController(homeVc, animated: true)
            } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            }
        case .turnOnPBFromMoreOptions(isAutoPay: _):
            // TBD
            guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
            self.navigationController?.navigationBar.isHidden = true
            viewcontroller.isFromAllsetScreen = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    func navigateToDesiredVC(){
        if let vc = self.navigationController?.viewControllers.filter({$0 is DeleteManagePaymentOptionsViewController}).first as? DeleteManagePaymentOptionsViewController {
            vc.isShowBottomLabel = false
            vc.buttonTitleString = ("Yes, delete", "No")
            vc.refreshRequired = true
            self.navigationController?.popToViewController(vc, animated: true)
        } else if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            self.navigationController?.popToViewController(vc, animated: true)
        } else if let viewController = self.presentingViewController?.presentingViewController as? UINavigationController {
            DispatchQueue.main.async {
                viewController.dismiss(animated: true)
            }
        } else if let viewController = self.presentingViewController as? UINavigationController {
            DispatchQueue.main.async {
                viewController.dismiss(animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    
    // Drawer Animation
    func presentWithBottomToTopAnimation(hasAmoutDue: Bool = false) {
        if hasAmoutDue {
            self.configureDrawerViewUI(showPayNow: hasAmoutDue)
            DispatchQueue.main.async {
                let screenHeight = UIScreen.main.bounds.height
                let viewHeight: CGFloat = 242
                self.drawerView.frame = CGRect(x: 0, y: screenHeight, width: self.view.frame.width, height: viewHeight)
                
                UIView.animate(withDuration: 0.5) {
                    self.drawerView.frame = CGRect(x: 0, y: screenHeight - viewHeight, width: self.drawerView.frame.width, height: viewHeight)
                }
            }
        } else {
            self.drawerView.isHidden = true
        }
    }
    
    private func configureDrawerViewUI(showPayNow: Bool) {
        if !showPayNow {
            self.setGAPageNames(DiscountEligible.CONFIRMATION_ENROLLED_AP_AND_PB_DONT_FORGET_TO_PAY.rawValue)
        } else {
            self.setGAPageNames(DiscountEligible.CONFIRMATION_ENROLLED_AP_AND_PB_PAY_NOW.rawValue)
        }
        self.drawerView.clipsToBounds = true
        self.drawerView.layer.cornerRadius = 12.0
        self.drawerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.button_Okay.isHidden = true
        self.drawerView.isHidden = false
        /*
        self.labelTitle_Drawer.text = showPayNow ? "Don't forget to pay this month's bill.": "Don't forget to pay this month's bill when you receive it."
        self.labelSubTitle_Drawer.text = "Your first Auto Pay starts next month."
        self.buttonOkay_Drawer.isHidden = showPayNow ? true: false
        self.stackPayNow.isHidden = showPayNow ? false: true
        self.payButtonTopConstraint.constant = showPayNow ? 40 : 30
         */
        self.labelTitle_Drawer.text = "Don't forget to pay your bill"
        self.labelSubTitle_Drawer.isHidden = true
        self.buttonOkay_Drawer.isHidden = true
        self.stackPayNow.isHidden = false
        self.payButtonTopConstraint.constant = 40
    }
    
    /*
    func presentWithTopToBottomAnimation() {
        button_Okay.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.heightViewTurnAutoPay.constant = 0
            self.viewTurnAutoPay.alpha = 1.0
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: true)
        }
    }
     */
    
    @IBAction func actionOkayDrawer(_ sender: Any) {
        switch allSetType {
        case .turnOnAutoPaySP:
            switch flowType { //CMAIOS-2516
            case .autoPayFromLetsDoIt:
                if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                        self.navigationController?.popToViewController(vc, animated: true)
                }
            default :
                if let homeVc = self.navigationController?.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(homeVc, animated: true)
                    }
                } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                    self.dismiss(animated: true)
                } else {
                    guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
                    self.navigationController?.navigationBar.isHidden = true
                    viewcontroller.isFromAllsetScreen = true
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
        case .turnOnPBFromMoreOptions(_):
            // TBD
            guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
            self.navigationController?.navigationBar.isHidden = true
            viewcontroller.isFromAllsetScreen = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        default: break
        }
    }
    
    @IBAction func actionPayNow(_ sender: Any) {
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : DiscountEligible.ENROLLED_PAY_NOW.rawValue,
                        EVENT_SCREEN_NAME: DiscountEligible.CONFIRMATION_ENROLLED_AP_AND_PB_PAY_NOW.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
        self.moveToMakePaymentScreen()
    }
    
    @IBAction func actionDoItLater(_ sender: Any) {
        switch allSetType {
        case .turnOnAutoPaySP:
            if let homeVc = self.navigationController?.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(homeVc, animated: true)
                }
            } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            } else {
                guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
                self.navigationController?.navigationBar.isHidden = true
                viewcontroller.isFromAllsetScreen = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        case .turnOnPBFromMoreOptions(let isAutoPay):
            /*
            if let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) {
                self.navigationController?.navigationBar.isHidden = true
                viewcontroller.isFromAllsetScreen = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
             */
            if let billingPreferences = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                DispatchQueue.main.async {
                    billingPreferences.showScreenHeaderAndDiscountView()
                }
                self.navigationController?.popToViewController(billingPreferences, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        default: break
        }
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : DiscountEligible.ENROLLED_ILL_DO_IT_LATER.rawValue,
                        EVENT_SCREEN_NAME: DiscountEligible.CONFIRMATION_ENROLLED_AP_AND_PB_PAY_NOW.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
    }
    
    private func moveToMakePaymentScreen() {
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock()
        makePayVC.state = QuickPayManager.shared.getInitialScreenFlowState()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
}

enum AllSetType {
    case newAutoPay
    case paperlessBilling
    case turnOffBillingAlert
//    case turnOffAutoPayAlert
    case turnOnAutoPay
    case updateAutopay
    case updateScheduledPayment
    case turnOffAutoPay
    case autoPaymentErrorFlow //CMAIOS-2103
    case turnOnAutoPaySP // SP -> Spot light flow
    case turnOnPaperlessBillingSP // SP -> Spot light flow CMAIOS-2493
    case turnOnPaperlessBillingBP // BP -> BillingPrefrence flow CMAIOS-2537 when autoPay is turned on already
    case turnOnPBFromMoreOptions(isAutoPay: Bool) // CMAIOS:-2565
}
