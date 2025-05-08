//
//  SchedulePaymentViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 18/12/23.
//

import UIKit
import Lottie

class SchedulePaymentViewController: UIViewController {
    
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var image_TitleTickMark: UIImageView!
    @IBOutlet weak var titleImageWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var label_Amount: UILabel!
    @IBOutlet weak var label_Date: UILabel!
    @IBOutlet weak var image_CarType: UIImageView!
    @IBOutlet weak var label_PaidTitle: UILabel!
    @IBOutlet weak var label_CardType: UILabel!
    @IBOutlet weak var label_NextAutoPayDate: UILabel!
    @IBOutlet weak var checkAnimationView: LottieAnimationView!
    @IBOutlet weak var viewTurnAutoPay: UIView!
    @IBOutlet weak var button_Okay: UIButton!
    @IBOutlet weak var heightViewTurnAutoPay: NSLayoutConstraint!
    @IBOutlet weak var label_TurnOn_Subtitle: UILabel!
    @IBOutlet weak var label_AutoPay_View_Title: UILabel!
    @IBOutlet weak var button_Lets_Do_It: RoundedButton!
    @IBOutlet weak var button_No_Thanks: RoundedButton!
    @IBOutlet weak var button_AnimationView: LottieAnimationView!
    @IBOutlet weak var buttons_StackView: UIStackView!
    
    var isPaymentScheduled = false
    var isPartialPayment = false
    var partialWithNoPayment = false
    var paidAmount: String = ""
    var dueAmount: String = ""
    var dueDate: String = ""
    var date: String = ""
    var paymentDate: String = ""
    var successPaymentType: SuccessPaymentType = .immediatePaymentSuccess
    var schedulePaymentDict: CreateSchedulePayment?
    var qualtricsAction : DispatchWorkItem?
    var oneTimePaymentDict: SchedulePaymentWithNewCard?
    var oneTimeAchPaymentDict: SchedulePaymentWithNewAch?
    var currentAmount: String = ""
    var allSchedulePayments: String = ""
    var isOkayButtonPressed = false
    var isScreenEnteredBG = false
    var isDeauthCurrently = false
    var isAutoPaymentErrorFlow = false
    var updateInProgress = false
    var showDiscountEligible = false
    
    lazy var payMethod: PayMethod! = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
        didSet {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func willEnterForeground() {
        isScreenEnteredBG = false
        if self.isDeauthCurrently, paidAmountLimit() != .paidLess  {
            if CommonUtility.checkRemainingTime() > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(CommonUtility.checkRemainingTime())) {
                    self.performReload()
                }
            } else {
                self.dismissQuickPayAndLoadLogin(false)
            }
        }
    }
    
    @objc func appDidEnterBackground() {
        isScreenEnteredBG = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //CMAIOS-2335 Fixed display of back button after tapping back from enroll now in AutoPay
        self.navigationController?.navigationBar.isHidden = true
        self.configureUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func configureUI(){
        self.setUpWithAnimationConfig()
        if let amount =  Double(self.paidAmount) {
            label_Amount.text = "$" + String(format: "%.2f", amount)
        }
        let defaultPaymethod = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
        image_CarType.image = UIImage(named: defaultPaymethod.2)
        label_CardType.text = defaultPaymethod.1
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
        self.label_Title.attributedText = NSMutableAttributedString(string: successPaymentType == .schedulePaymentSuccess ? "Your payment has been scheduled" : "Thank you for your payment!", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label_NextAutoPayDate.isHidden = true
        validateInitialUIData()
    }
    
    func showDeauthLabels() {
        switch paidAmountLimit() {
        case .paidFull:
            label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
            performReload()
            label_NextAutoPayDate.text = "Your services will resume within a few hours after this payment has posted. You will be charged a restore service fee on your next bill"
        case .paidLess:
            let dueDate = QuickPayManager.shared.getDueDate("MMM. d")
            //CMAIOS-2456 issue fix
            label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
            label_NextAutoPayDate.text = "Make sure to pay the minimum amount due to restore your service"
            
        default:
            label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
            performReload()
            label_NextAutoPayDate.text = "Your services will resume within a few hours after this payment has posted. You will be charged a restore service fee on your next bill"
        }
        button_Okay.isHidden = false
        viewTurnAutoPay.isHidden = true
        label_NextAutoPayDate.isHidden = false
        
    }
    private func validateInitialUIData() {
//        QuickPayManager.shared.initialScreenType()
        //        let currentSelectedDueDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: QuickPayManager.shared.getDueDate("YYYY-MM-DD"))
        var screenTag = ""
        //CMAIOS-2042
        if self.isDeauthCurrently {
            let deAuthPaymentDate = CommonUtility.convertDateToSpecifiedUTCStringFormat(Date())
            PreferenceHandler.saveValue(deAuthPaymentDate, forKey: "DEAUTH_PAYMENT_MADE_TIMESTAMP")
            showDeauthLabels()
            //CMAIOS-2286
            screenTag = DeAuthServices.Billing_Deauth_Service_Suspended_Thank_You_For_Your_Payment.rawValue
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue])
            return
        }
        showDiscountEligible = false
        switch (successPaymentType, paidAmountLimit(), QuickPayManager.shared.initialScreenFlow) {
        case (.immediatePaymentSuccess, _, .noDue), (.schedulePaymentSuccess, _, .noDue):
            if successPaymentType == .schedulePaymentSuccess {
                updatePaymentScheduleDate()
            } else {
                label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
            }
            
            switch (isAutoPaymentErrorFlow, canUpdateAutoPayPaymethod(), isEligibileForAutoPayCard()) {
            case (true, true, _): // CMAIOS-2119
                self.presentWithBottomToTopAnimation()
                self.updateTurnOnAutoPayDrawerUI()
                screenTag = AutoPayFailureDetails.THANK_YOU_PAGE_CHANGE_AUTO_PAY_PROMPT.rawValue //CMAIOS-2465
            case (false, _, true):
                presentWithBottomToTopAnimation()
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_NO_BILL_DUE.rawValue)
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_NO_BILL_DUE.rawValue
            default :
                label_NextAutoPayDate.text = "This payment will be applied to your next bill"
                label_NextAutoPayDate.isHidden = false
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_NO_BILL_DUE.rawValue)
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_NO_BILL_DUE.rawValue
            }
        case (.immediatePaymentSuccess, .paidFull, _):
            label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
            // CMAIOS-2119
            
            /*
            if !isAutoPaymentErrorFlow, QuickPayManager.shared.isDiscountPresent(), (isEligibileForAutoPayCard() || !QuickPayManager.shared.isPaperLessBillingEnabled()) {
                if let promoDismissalActive = SpotLightsManager.shared.spotLightCards.promoDismissalActive,
                      promoDismissalActive == false { //CMAIOS-2680
                    showDiscountEligible = true
                    presentWithBottomToTopAnimation()
                    return
                }
            }
             */
            
            if self.shouldShowDiscountCard() { //CMAIOS-2808
                showDiscountEligible = true
                presentWithBottomToTopAnimation()
                return
            }
            
            switch (isAutoPaymentErrorFlow, canUpdateAutoPayPaymethod(), isEligibileForAutoPayCard()) {
            case (true, true, _): // CMAIOS-2119
                presentWithBottomToTopAnimation()
                self.updateTurnOnAutoPayDrawerUI()
                screenTag = AutoPayFailureDetails.THANK_YOU_PAGE_CHANGE_AUTO_PAY_PROMPT.rawValue //CMAIOS-2465
            case (false, _, true):
                presentWithBottomToTopAnimation()
            default :
                label_NextAutoPayDate.isHidden = true
            }          
        case (.immediatePaymentSuccess, .paidLess, _):
            let dueDate = QuickPayManager.shared.getDueDate("MMM. d")
            let paymentDate = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "yyyy-MM-dd")
            
            label_NextAutoPayDate.isHidden = false
    
            switch (QuickPayManager.shared.initialScreenFlow == .pastDue,
                    isPaymentAfter48Hours(paymentDate: paymentDate),
                    isPaymentBefore48Hours(paymentDate: paymentDate)) {
            case (true, true, _):
                label_NextAutoPayDate.text = "Please make sure to pay your remaining balance to avoid additional late fees."
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_AFTER_48_HOURS_DUE_DATE.rawValue
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_AFTER_48_HOURS_DUE_DATE.rawValue)
            case (true, _, true):
                label_NextAutoPayDate.text = "Please make sure to pay your remaining balance to avoid late fees."
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_WITHIN_48_HOURS_DUE_DATE.rawValue
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_WITHIN_48_HOURS_DUE_DATE.rawValue)
            default:
                // CMAIOS-2002
                let remainingAmount = self.getRemininigBalance()
                if remainingAmount == "0" {
                    label_NextAutoPayDate.isHidden = true
                } else {
                    label_NextAutoPayDate.isHidden = false
                    label_NextAutoPayDate.text = "Please make sure you pay the remaining $\(remainingAmount) due \(dueDate)."
                }
                // CMAIOS-2002
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_WITH_BALANCE.rawValue
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_WITH_BALANCE.rawValue)
            }
            label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
            
        case (.schedulePaymentSuccess, .paidFull, _), (.schedulePaymentSuccess, .paidMore, _):
            updatePaymentScheduleDate()
            if successPaymentType == .schedulePaymentSuccess && self.paidAmountLimit() == .paidFull {
                screenTag = PaymentScreens.MYBILL_YOUR_FULL_PAYMENT_SCHEDULED.rawValue
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_FULL_PAYMENT_SCHEDULED.rawValue)
            }
            
            //CMAIOS-1962: removed warning label for payment full amount
            switch (isAutoPaymentErrorFlow, canUpdateAutoPayPaymethod(), isEligibileForAutoPayCard()) {
            case (true, true, _): // CMAIOS-2119
                presentWithBottomToTopAnimation()
                self.updateTurnOnAutoPayDrawerUI()
                screenTag = AutoPayFailureDetails.THANK_YOU_PAGE_CHANGE_AUTO_PAY_PROMPT.rawValue //CMAIOS-2465
            case (false, _, true):
                presentWithBottomToTopAnimation()
            default :
                label_NextAutoPayDate.isHidden = true
            }
        case (.schedulePaymentSuccess, .paidLess, _):
            updatePaymentScheduleDate()
            let dueDate = QuickPayManager.shared.getDueDate("MMM. d")
            
            label_NextAutoPayDate.isHidden = false
            switch (QuickPayManager.shared.initialScreenFlow == .pastDue,
                    isPaymentAfter48Hours(paymentDate: self.paymentDate),
                    isPaymentBefore48Hours(paymentDate: self.paymentDate),
                    isPaymentInitiateAfterDue()) {
            case (true, true, _, _):
                label_NextAutoPayDate.text = "Please make sure to pay your remaining balance to avoid additional late fees."
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_AFTER_48_HOURS_DUE_DATE.rawValue
            case (true, _, true, _):
                label_NextAutoPayDate.text = "Please make sure to pay your remaining balance to avoid late fees."
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_WITHIN_48_HOURS_DUE_DATE.rawValue
            case (_, _, _, true):
                showWarningScheduledAfterDue()
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_SCHEDULED_AFTER_DUE_DATE.rawValue
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_SCHEDULED_AFTER_DUE_DATE.rawValue)
            default:
                // CMAIOS-2002
                let remainingAmount = self.getRemininigBalance()
                if remainingAmount == "0" {
                    label_NextAutoPayDate.isHidden = true
                } else {
                    label_NextAutoPayDate.isHidden = false
                    label_NextAutoPayDate.text = "Please make sure you pay the remaining $\(remainingAmount) due \(dueDate)."
                }
                // CMAIOS-2002
                screenTag = PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_SCHEDULED_BEFORE_DUE_DATE.rawValue
                self.addQualtrics(screenName: PaymentScreens.MYBILL_YOUR_PARTIAL_PAYMENT_SCHEDULED_BEFORE_DUE_DATE.rawValue)
            }
        default: break
        }
        
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
    }
    
    func performReload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (TimeInterval(ConfigService.shared.service_restoration_window) ?? 0)) {
            if !self.isOkayButtonPressed, !self.isScreenEnteredBG {
                self.dismissQuickPayAndLoadLogin(false)
            }
        }
    }
    
    /// Checks the pre-conditions:
    ///  1) No AutoPay or paperless billing enrolled
    ///  2) saved Paymethod
    ///  3) promoDismissalActive is false
    ///  4) discountEligible is true
    /// - Returns: Whether the discount card cane shown or nor
    func shouldShowDiscountCard() -> Bool {
        var shouldShow = false
        switch (isAutoPaymentErrorFlow,
                QuickPayManager.shared.isDiscountPresent(),
                isEligibileForAutoPayCard(),
                QuickPayManager.shared.isPaperLessBillingEnabled())
        {
        case (false, true, true, _), (false, true, _, false):
            if let promoDismissalActive = SpotLightsManager.shared.spotLightCards.promoDismissalActive,
               promoDismissalActive == false { //CMAIOS-2680
                shouldShow = true
            }
        default: break
        }
        return shouldShow
    }
    
    func dismissQuickPayAndLoadLogin(_ isPaidLess: Bool) {
//        App.endSimulationForDeAuth()
        // CMAIOS:-2569
        if let quickPayDeauth = self.navigationController?.presentingViewController?.isKind(of: QuickPayDeAuthViewController.classForCoder()), quickPayDeauth {
            PreferenceHandler.removeDataForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP")
            let quickPay = self.navigationController?.presentingViewController! as! QuickPayDeAuthViewController
            self.navigationController?.dismiss(animated: false)
            if !isPaidLess {
                quickPay.dismissCallBack?()
            }
            return
        }
        
        // CMAIOS:-2570
        if let navigationControl = self.presentingViewController as? UINavigationController {
            if let quickPayDeauth = navigationControl.viewControllers.filter({$0 is QuickPayDeAuthViewController}).first as? QuickPayDeAuthViewController {
                PreferenceHandler.removeDataForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP")
                if !isPaidLess {
                    quickPayDeauth.dismissCallBack?()
                } else {
                    DispatchQueue.main.async {
                        navigationControl.dismiss(animated: false, completion: {
                            navigationControl.popToViewController(quickPayDeauth, animated: true)
                        })
                    }
                }
            }
        }
    }
    
    /// Whether the selected payment date is after the due date
    /// - Returns: isPaymentAfterdueDate
    func isPaymentInitiateAfterDue() -> Bool {
        let currentSelectedDueDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: QuickPayManager.shared.getDueDate("yyyy-MM-dd"))
        var isPaymentAfterdueDate = false
        let selectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: self.paymentDate)
        if currentSelectedDueDate.checkIfDateIsSelectedAfterDueDate(selectedDueDate: selectedDate, checkIsSameRequired: false) {
            isPaymentAfterdueDate = true
        }
        return isPaymentAfterdueDate
    }
    
    func isPaymentBefore48Hours(paymentDate: String) -> Bool {
        let currentSelectedDueDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: QuickPayManager.shared.getDueDate("yyyy-MM-dd"))
        var isPaymentBefore48HoursDate = false
        let selectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: paymentDate)
        if currentSelectedDueDate.checkIfDateIsSelectedBefore48Hours(selectedDueDate: selectedDate) {
            isPaymentBefore48HoursDate = true
        }
        return isPaymentBefore48HoursDate
    }
    
    func isPaymentAfter48Hours(paymentDate: String) -> Bool {
        let currentSelectedDueDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: QuickPayManager.shared.getDueDate("yyyy-MM-dd"))
        var isPaymentAfter48HoursDate = false
        let selectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: paymentDate)
        if currentSelectedDueDate.checkIfDateIsSelectedAfter48Hours(selectedDueDate: selectedDate) {
            isPaymentAfter48HoursDate = true
        }
        return isPaymentAfter48HoursDate
    }
    
    func showWarningScheduledAfterDue() {
        let dueDate = QuickPayManager.shared.getDueDate("MMM. d")
        label_NextAutoPayDate.text = "Please make sure to pay the full amount due by \(dueDate) to avoid late fees."
        label_NextAutoPayDate.isHidden = false
    }
    
    private func isLocalPaymethod() -> Bool {
        var localPaymethod = false
        if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
            localPaymethod = true
        }
        return localPaymethod
    }
    
    private func cardSavedToAccount() -> Bool {
        var shouldSave = false
        if isLocalPaymethod() {
            if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
                shouldSave = paymethodVal.first?.save ?? false
            }
        }
        return shouldSave
    }
    
    /// Whether we need to show Auto pay enrol drawer or not
    /// 1) Not eligible for unasaved new paymethod
    /// 2) Applicable only if Auto pay is not enrolled
    /// - Returns: Auto Paymethod can be updated or not
    private func isEligibileForAutoPayCard() -> Bool {
        var localPaymethod = false
        if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
            localPaymethod = true
        }
        var savedCard = false
        if isLocalPaymethod() {
            if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
                savedCard = paymethodVal.first?.save ?? false
            }
        }
        var eligible = false
        switch (localPaymethod, savedCard, QuickPayManager.shared.isAutoPayEnabled()) {
        case (true, true, false), (false, _, false):
            eligible = true
        case (true, false, false), (true, true, true):
            eligible = false
        default : break
        }
        
        return eligible
    }
        
    // CMAIOS-2119
    /// Whether we need to show Auto pay update drawer or not (From -> Auto Payment failure Spotlight Flow)
    /// 1) Not eligible for unasaved new paymethod
    /// 2) Check already account enrolled for Auto pay
    /// - Returns: Auto Paymethod can be updated or not
    private func canUpdateAutoPayPaymethod() -> Bool {
        var savedCard = false
        let isLocalPaymethod = self.isLocalPaymethod()
        if isLocalPaymethod {
            if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
                savedCard = paymethodVal.first?.save ?? false
            }
        }
        var eligible = false
        switch (isLocalPaymethod, savedCard, QuickPayManager.shared.isAutoPayEnabled()) {
        case (true, true, true), (false, _, true):
            eligible = true
        case (true, false, true), (true, true, false):
            eligible = false
        default : break
        }
        return eligible
    }
  
    func addQualtrics(screenName:String){
        self.qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    private func updatePaymentScheduleDate() {
        if let scheduledDate = schedulePaymentDict, let paymentDate = scheduledDate.payment?.paymentDate {
            self.showSchedulePaymentDate(paymentDate: paymentDate)
        } else if let scheduledDate = oneTimePaymentDict, let paymentDate = scheduledDate.payment?.paymentDate {
            self.showSchedulePaymentDate(paymentDate: paymentDate)
        } else if let scheduledDate = oneTimeAchPaymentDict, let paymentDate = scheduledDate.payment?.paymentDate {
            self.showSchedulePaymentDate(paymentDate: paymentDate)
        }
    }
    
    private func showSchedulePaymentDate(paymentDate: String?) {
        label_Date.text = CommonUtility.convertDateStringFormats(dateString: paymentDate ?? "", dateFormat: "MMM. d, YYYY")
        self.paymentDate = CommonUtility.convertDateStringFormats(dateString: paymentDate ?? "", dateFormat: "yyyy-MM-dd")
    }
    
    func isFullAmountPaid() -> Bool {
        let updatedAmount = Double(self.paidAmount)
        return self.currentAmount == String(format: "%.2f", updatedAmount ?? 0)
    }
    
    func paidAmountLimit() -> PaymentLimit {
        var limit: PaymentLimit = .paidLess
        let totalAmountDue = Double(self.currentAmount) ?? 0
        let paidAmount = Double(String(format: "%.2f", Double(self.paidAmount) ?? 0)) ?? 0
      //  let pastDueAmount = Double(String(format: "%.2f", Double(QuickPayManager.shared.getPastDueAmount()) ?? 0)) ?? 0
        //CMAIOS-2042
        if isDeauthCurrently {
            let pastDueDeauth = Double(String(format: "%.2f", Double(self.dueAmount) ?? 0)) ?? 0
            if paidAmount >= totalAmountDue || paidAmount >= pastDueDeauth {
                limit = .paidFull
            } else if paidAmount < pastDueDeauth {
                limit = .paidLess
            }
        } else {
            if totalAmountDue == paidAmount {
                limit = .paidFull
            } else if totalAmountDue > paidAmount {
                limit = .paidLess
            } else if totalAmountDue < paidAmount {
                limit = .paidMore
            }
        }
        return limit
    }
    
    func getRemininigBalance() -> String {
        // CMAIOS-2002
        let totalAmountDue = Double(self.currentAmount) ?? 0
        let paidIncludingAllSchedulePayment = (Double(self.allSchedulePayments) ?? 0) + (Double(self.paidAmount) ?? 0)
        let totalPaidAmount = Double(String(format: "%.2f", paidIncludingAllSchedulePayment)) ?? 0
        let balance = totalAmountDue - totalPaidAmount
        if balance <= 0 {
            return "0"
        }
        return String(format: "%.2f", Double(balance))
        // CMAIOS-2002
    }
    
    private func updateTurnOnAutoPayDrawerUI() {
        /* CMAIOS-2119 */
        let defaultPaymethod = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
        self.label_AutoPay_View_Title.text = "Change Auto Pay payment method to \(defaultPaymethod.1)?"
        self.label_AutoPay_View_Title.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.label_TurnOn_Subtitle.isHidden =  false
        self.label_TurnOn_Subtitle.text = "Or please contact the provider of \(QuickPayManager.shared.cardDataDict?.payNickName ?? "") to resolve the issue."
        self.button_Lets_Do_It.setTitle("Yes, change it", for: .normal)
        self.button_No_Thanks.setTitle("No", for: .normal)
        /* CMAIOS-2119 */
    }
    
    private func setUpWithAnimationConfig() {
        self.checkMarkAnimation()
    }
    
    // MARK: - Check Success Animation
    func checkMarkAnimation() {
        self.checkAnimationView.isHidden = true
        self.image_TitleTickMark.isHidden = true
        UIView.animate(withDuration: 1.0) {
            self.checkAnimationView.isHidden = false
        }
        self.checkAnimationView.backgroundColor = .clear
        self.checkAnimationView.animation = LottieAnimation.named("SuccessCheck")
        self.checkAnimationView.loopMode = .playOnce
        self.checkAnimationView.animationSpeed = 1.0
        self.checkAnimationView.play(toProgress: 0.6, completion: {_ in
            self.checkAnimationView.isHidden = true
            self.image_TitleTickMark.isHidden = false
            self.image_TitleTickMark.alpha = 1.0
            Logger.info("Animation Completed")
        })
    }
    
    private func configureViewAutoPayUI() {
        viewTurnAutoPay.clipsToBounds = true
        viewTurnAutoPay.layer.cornerRadius = 12.0
        viewTurnAutoPay.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let defaultPaymethod = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
        button_Okay.isHidden = true
        viewTurnAutoPay.isHidden = false
        var screenTag = ""
        if showDiscountEligible {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            paragraphStyle.alignment = .left
            self.label_AutoPay_View_Title.text = "Save $5 a month"
            var subTitle = ""
            switch (QuickPayManager.shared.isAutoPayEnabled(), QuickPayManager.shared.isPaperLessBillingEnabled()) {
            case (false,false):
                subTitle = "Enroll in Auto Pay & Paperless Billing today"
                screenTag = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_AND_PB_TODAY.rawValue
            case (true, false):
                subTitle = "Enroll in Paperless Billing in addition to Auto Pay."
                screenTag = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_PB_TODAY.rawValue
            case (false, true):
                subTitle = "Enroll in Auto Pay in addition to Paperless Billing"
                screenTag = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_TODAY.rawValue
            default:
                break
            }
            self.label_TurnOn_Subtitle.attributedText = NSMutableAttributedString(string: subTitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            if !screenTag.isEmpty {
                let custParams = [EVENT_SCREEN_NAME : screenTag, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
            }
        } else {
            label_TurnOn_Subtitle.text = "Pay your amount due automatically each month using \(defaultPaymethod.1)." //CMAIOS-2504
        }
    }
    
    func presentWithBottomToTopAnimation() {
        self.configureViewAutoPayUI()
        let screenHeight = UIScreen.main.bounds.height
        let viewHeight: CGFloat = 242
        viewTurnAutoPay.frame = CGRect(x: 0, y: screenHeight, width: view.frame.width, height: viewHeight)
        
        UIView.animate(withDuration: 0.5) {
            self.viewTurnAutoPay.frame = CGRect(x: 0, y: screenHeight - viewHeight, width: self.viewTurnAutoPay.frame.width, height: viewHeight)
        }
    }
    
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
    
    private func navigateToFinishSetup() {
        guard let viewcontroller = FinishSetupViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.screenType = .autoPayEnroll
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func navigateToPreviousScreens() {
        if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.qualtricsAction?.cancel()
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
            return
        } else if let navigationControl = self.presentingViewController as? UINavigationController { // CMAIOS:-1882
            if let billingView = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: false, completion: {
                        navigationControl.popToViewController(billingView, animated: true)
                    })
                }
                return
            }//CMAIOS-2335 home navigation fix
            else  if let homeVC = navigationControl.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: false, completion: {
                        navigationControl.popToViewController(homeVC, animated: true)
                    })
                }
            }
    }
        else {
            navToHomeVC()
        }
    }

    @IBAction func actionLetsDoIt(_ sender: Any) {
        //CMAIOS-2465
        var eventName = ""
        var screenName = ""
        if showDiscountEligible {
            switch (QuickPayManager.shared.isAutoPayEnabled(), QuickPayManager.shared.isPaperLessBillingEnabled()) {
            case (false,false):
                eventName = DiscountEligible.LETS_DO_IT_ENROLL_IN_AP_PB.rawValue
                screenName = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_AND_PB_TODAY.rawValue
            case (true, false):
                eventName = DiscountEligible.LETS_DO_IT_ADD_PB_TO_AP.rawValue
                screenName = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_PB_TODAY.rawValue
            case (false, true):
                eventName = DiscountEligible.LETS_DO_IT_ADD_AP_TO_PB.rawValue
                screenName = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_TODAY.rawValue
            default:
                break
            }
            if !QuickPayManager.shared.isAutoPayEnabled() {
                guard let chooseViewController = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
                chooseViewController.paymentType = .turnOnAutoPayFromSpotlight
                chooseViewController.flowType = .autoPayFromLetsDoIt//CMAIOS-2516, 2518
                chooseViewController.titleHeader = "Choose a payment method for Auto Pay"
                self.navigationController?.pushViewController(chooseViewController, animated: true)
            } else if !QuickPayManager.shared.isPaperLessBillingEnabled() {
                self.validatePBEmailAndAndEnroll()
            }
        } else {
            if self.isAutoPaymentErrorFlow { // CMAIOS-2119
                eventName =  AutoPayFailureDetails.THANK_YOU_AUTO_PAY_CHANGE_IT.rawValue
                screenName = AutoPayFailureDetails.THANK_YOU_PAGE_CHANGE_AUTO_PAY_PROMPT.rawValue
                self.makeUpdateAutoPayAPI()
            } else {
                eventName = BillPayEvents.AUTOPAY_PROMPT_LETS_DO_IT_CLICK.rawValue
                screenName = BillPayEvents.QUICKPAY_CARDINFO_PAYMENT_SUCCESS.rawValue
                self.navigateToFinishSetup()
            }
        }
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : eventName,
                        EVENT_SCREEN_NAME: screenName, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
    }
    
    @IBAction func actionNoThanks(_ sender: Any) {
        //CMAIOS-2465
        var eventName = ""
        var screenName = ""
        if showDiscountEligible {
            SpotLightsManager.shared.updateDismissStatus() //CMAIOS-2680
//            APIRequests.shared.isUpdateSpotlightCardRequests = true
            switch (QuickPayManager.shared.isAutoPayEnabled(), QuickPayManager.shared.isPaperLessBillingEnabled()) {
            case (false,false):
                eventName = DiscountEligible.MAYBE_LATER_ENROLL_IN_AP_PB.rawValue
                screenName = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_AND_PB_TODAY.rawValue
            case (true, false):
                eventName = DiscountEligible.MAYBE_LATER_ADD_PB_TO_AP.rawValue
                screenName = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_PB_TODAY.rawValue
            case (false, true):
                eventName = DiscountEligible.MAYBE_LATER_ADD_AP_TO_PB.rawValue
                screenName = DiscountEligible.THANK_YOUR_FOR_YOUR_PAYMENT_ENROLL_IN_AP_TODAY.rawValue
            default:
                break
            }
        } else {
//            APIRequests.shared.isUpdateSpotlightCardRequests = false
            if self.isAutoPaymentErrorFlow { // CMAIOS-2119
                eventName =  AutoPayFailureDetails.THANK_YOU_AUTO_PAY_NO.rawValue
                screenName = AutoPayFailureDetails.THANK_YOU_PAGE_CHANGE_AUTO_PAY_PROMPT.rawValue
            } else {
                eventName =  BillPayEvents.AUTOPAY_PROMPT_NO_THANKS_CLICK.rawValue
                screenName = BillPayEvents.QUICKPAY_CARDINFO_PAYMENT_SUCCESS.rawValue
            }
        }
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : eventName,
                        EVENT_SCREEN_NAME: screenName,
                     CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,
                      CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue,
                      CUSTOM_PARAM_INTENT: Intent.Billing.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
        self.navigateToPreviousScreens()
    }
    
    @IBAction func actionOkay(_ sender: Any) {
        //        self.dismiss(animated: true)
        if isDeauthCurrently {
            self.isOkayButtonPressed = true
            if paidAmountLimit() == .paidLess {
                dismissQuickPayAndLoadLogin(true)
                return
            }
            if CommonUtility.checkRemainingTime() > 0 {
                guard let viewcontroller = DeAuthDueViewController.instantiateWithIdentifier(from: .BillPay) else { return }
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        } else {
            self.navigateToPreviousScreens()
        }
    }
    
    func navToHomeVC() {
        guard let navigationController = self.navigationController else { return }
        if let homeVC = navigationController.viewControllers.first(where: { $0.isKind(of: HomeScreenViewController.self) }) {
            DispatchQueue.main.async {
                navigationController.popToViewController(homeVC, animated: true)
            }
        }
    }
}

extension SchedulePaymentViewController {
    
    // CMAIOS-2119
    func makeUpdateAutoPayAPI() {
        guard let oldAutoPay = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay else { return }
        // Animation
        self.updateInProgress = true
        self.startButtonAmnimation()
        // Animation
        var autoPay = oldAutoPay
        autoPay.update(payMethod: PayMethod(name: payMethod.name))
        QuickPayManager.shared.mauiUpdate(autoPay: autoPay) { result in
            switch result {
            case .success(let autoPay):
                if let index = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.firstIndex(where: {$0.name == self.payMethod.name}), self.payMethod.name != QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name {
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.remove(at: index)
               }
                if oldAutoPay.payMethod?.name != QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name, let paymethod = oldAutoPay.payMethod {
                    if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                        QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                    }
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
                }
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay = autoPay
                //CMAIOS-2103: Updated enum for new error flow
                self.navigateToSuccessAlert(type: .autoPaymentErrorFlow)
            case let .failure(error):
                Logger.info("Expiration Update failed \(error.localizedDescription)")
                self.updateAutoPayFailedAnimation()
            }
        }
    }
    
    func validatePBEmailAndAndEnroll(){
        let email = QuickPayManager.shared.getBillCommunicationEmail()
        if !email.isEmpty, email.isValidEmail {
            self.updateInProgress = true
            self.startButtonAmnimation()
            mauiUpdateBillCommunicationPreference()
        } else {
            self.updateAutoPayFailedAnimation()
            self.showErrorMessageVC()
        }
    }
    
    /// Update Bill communication preference for updating the email id and paperless billing
    private func mauiUpdateBillCommunicationPreference() {
        var jsonParams = [String: AnyObject]()
        jsonParams["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        jsonParams["email"] = QuickPayManager.shared.getBillCommunicationEmail()  as AnyObject?
        jsonParams["termsConditions"] = true as AnyObject?
        jsonParams["mailNotifyIndicator"] = true as AnyObject?
        jsonParams["paperBillIndicator"] = false as AnyObject? //CMAIOS-2492
        QuickPayManager.shared.mauiUpdateBillCommunicationPreference(jsonParams: jsonParams, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Update Bill Communication Response is \(String(describing: value))", sendLog: "Update Bill Communication success")
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences = QuickPayManager.shared.modelQuickPayUpdateBillPrefernce?.billCommunicationPreference
                    self.valdiateUpdateBillResponse()
                } else {
                    self.updateAutoPayFailedAnimation()
                    self.showErrorMessageVC()
                    Logger.info("Update Bill Communication is \(String(describing: error))")
                }
            }
        })
    }
    
    func showErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromFinishSetup = true
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // CMAIOS-2119
    func startButtonAmnimation() {
        self.buttons_StackView.isHidden = true
        self.button_AnimationView.isHidden = true
        UIView.animate(withDuration: 0.8) {
            self.button_AnimationView.isHidden = false
        }
        self.button_AnimationView.backgroundColor = .clear
        self.button_AnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.button_AnimationView.loopMode = .playOnce
        self.button_AnimationView.animationSpeed = 1.0
        self.button_AnimationView.play(toProgress: 0.6, completion:{_ in
            if self.updateInProgress {
                self.button_AnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    private  func valdiateUpdateBillResponse() {
        self.updateInProgress = false
        self.button_AnimationView.pause()
        self.button_AnimationView.play(fromProgress: self.button_AnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
            self.navigateToSetUpScreen()
        }
    }
    
    private func navigateToSetUpScreen() {
        guard let viewcontroller = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.allSetType = .turnOnPaperlessBillingSP
        guard let navigationControl =  self.navigationController else {
            viewcontroller.modalPresentationStyle = .fullScreen
            viewcontroller.navigationController?.navigationBar.isHidden = false
            self.present(viewcontroller, animated: true)
            return
        }
        navigationControl.navigationBar.isHidden = true
        navigationControl.pushViewController(viewcontroller, animated: true)
    }
    
    func updateAutoPayFailedAnimation() {
        self.updateInProgress = false
        self.buttons_StackView.isHidden = false
        self.button_AnimationView.currentProgress = 5.0
        self.button_AnimationView.stop()
        self.button_AnimationView.isHidden = true
        self.buttons_StackView.alpha = 0.0
        self.buttons_StackView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.buttons_StackView.alpha = 1.0
        }
    }
    
    private func navigateToSuccessAlert(type: AllSetType) {
        guard let vc = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        vc.allSetType = type
        vc.successHandler = { [weak self] in
            if let presentingVC = self?.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self?.dismiss(animated: true)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

enum SuccessPaymentType {
    case schedulePaymentSuccess
    case immediatePaymentSuccess
}

enum PaymentLimit {
    case paidFull
    case paidLess
    case paidMore
}
