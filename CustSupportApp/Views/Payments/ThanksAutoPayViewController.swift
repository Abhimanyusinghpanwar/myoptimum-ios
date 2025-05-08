//
//  ThanksAutoPayViewController.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 09/12/22.
//

import UIKit
import Alamofire
import Lottie
import ASAPPSDK

class ThanksAutoPayViewController: UIViewController {
    @IBOutlet weak var label_Amount: UILabel!
    @IBOutlet weak var label_Date: UILabel!
    @IBOutlet weak var image_CarType: UIImageView!
    @IBOutlet weak var button_LetsDoIt: UIButton!
    @IBOutlet weak var button_NoThanks: UIButton!
    @IBOutlet weak var label_CardType: UILabel!
    @IBOutlet weak var viewTurnAutoPay: UIView!
    @IBOutlet weak var label_NextAutoPayDate: UILabel!
//    @IBOutlet weak var button_Okay: UIButton!
    @IBOutlet weak var label_Turn_AutoPay: UILabel!
    @IBOutlet weak var label_TurnOn_Subtitle: UILabel!
    @IBOutlet weak var titleImageHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackAmount: UIStackView!
    @IBOutlet weak var stackPaidCard: UIStackView!
    @IBOutlet weak var stackDate: UIStackView!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var label_PaidTitle: UILabel!
    @IBOutlet weak var image_TitleTickMark: UIImageView!
    @IBOutlet weak var stackTitleView: UIStackView!
    
    @IBOutlet weak var button_Okay: UIButton!
    @IBOutlet weak var button_TryAgain: UIButton!
    @IBOutlet weak var button_Close: UIButton!
    @IBOutlet weak var checkAnimationView: LottieAnimationView!
    @IBOutlet weak var checkMarkView: UIView!
    @IBOutlet weak var tryAgainAnimaionView: LottieAnimationView!
    @IBOutlet weak var viewTryAgain: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var cardView: UIView!
    
    let sharedManager = QuickPayManager.shared
    var state: ThanksPaymentState = .normal
    var retryPaymentJson: [String: AnyObject]?
    var isAutoPayFlow = false
    var oneTimeCardInfo: SchedulePaymentWithNewCard?
    var oneTimeAchInfo: SchedulePaymentWithNewAch?
    var isDefaultSave = false
    var isFromTryAgainFlow = false
    var checkMarkIsProgress = false
    var saveCard = false
    var tryAgainInProgress = false
    var dataRefreshRequiredAfterChat = false
    var isMakePaymentFlow: Bool = false

    // Need to handle nil scenarios
    lazy var payMethod: PayMethod! = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
        didSet {
//            configureUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initialSetupOrChatRefresh()
    }
    
    private func initialSetupOrChatRefresh() {
        if !dataRefreshRequiredAfterChat {
            if state == .oneTimePaymentFailure || state == .paymentFailure { // Setup Without Animation
                self.validateScreenState(paymentState: state)
            } else {
                self.setUpWithAnimationConfig()
            }
        } else {
//            self.handlePostChatSession()
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            self.addLoader()
            self.mauiGetAccountActivityRequest()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.tryAgainFailedAnimation()
    }
    
    private func setUpWithAnimationConfig() {
        viewShiftAnimationSetUp()
        self.validateScreenState(paymentState: self.state)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.animateSubviews(shouldShow: true) {
                self.checkMarkAnimation()
            }
        }
    }
    
    private func configureUI() {
        viewTurnAutoPay.clipsToBounds = true
        viewTurnAutoPay.layer.cornerRadius = 20.0
        viewTurnAutoPay.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        label_NextAutoPayDate.isHidden = true
    }

    // MARK: - Button Actions
    @IBAction func actionLetsDoIt(_ sender: Any) {
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : BillPayEvents.AUTOPAY_PROMPT_LETS_DO_IT_CLICK.rawValue,
                        EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_CARDINFO_PAYMENT_SUCCESS.rawValue,
                     CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,
                      CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue,
                      CUSTOM_PARAM_INTENT: Intent.Billing.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
        navigateToFinishSetup()
    }
    
    @IBAction func actionNoThanks(_ sender: Any) {
//        viewTurnAutoPay.isHidden = true
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : BillPayEvents.AUTOPAY_PROMPT_NO_THANKS_CLICK.rawValue,
                        EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_CARDINFO_PAYMENT_SUCCESS.rawValue,
                     CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,
                      CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue,
                      CUSTOM_PARAM_INTENT: Intent.Billing.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
        self.actionOkay(sender)
    }
    
    @IBAction func actionOkay(_ sender: Any) {
        switch state {
        case .updatingAutoPayment: break
        case .autoPay, .normal:
            if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billingPayController, animated: true)
                }
                return
            }
        case .paymentFailure, .oneTimePaymentFailure: // Use differnt paymethod button action
            if QuickPayManager.shared.getAllPayMethodMop().isEmpty && QuickPayManager.shared.localSavedPaymethods?.count ?? 0 <= 0 {
                self.showAddCard()
                return
            }
            guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
            vc.payMethod = payMethod
            vc.isMakePaymentFlow = isMakePaymentFlow
            vc.modalPresentationStyle = .fullScreen
            vc.selectionHandler = { [weak self] payMethod in
                self?.payMethod = payMethod
                if let makePaymentController = self?.navigationController?.viewControllers.filter({$0 is MakePaymentViewController}).first as? MakePaymentViewController {
                    self?.dismiss(animated: false) {
                        makePaymentController.payMethod = payMethod
                        self?.navigationController?.popToViewController(makePaymentController, animated: true)
                    }
                }
            }
            let aNavigationController = UINavigationController(rootViewController: vc)
            aNavigationController.modalPresentationStyle = .fullScreen
            aNavigationController.setNavigationBarHidden(true, animated: true)
            self.present(aNavigationController, animated: true, completion: nil)
        case .oneTimePaymentSuccess(let saveCard):
            if let navigationControl = self.presentingViewController?.presentingViewController as? UINavigationController {
                if let vc = navigationControl.viewControllers.filter({$0 is BillingViewContrller}).first as? BillingViewContrller {
                    DispatchQueue.main.async {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                            self.updateAmountInfoAfterPayment(saveCard: saveCard)
                            navigationControl.popToViewController(vc, animated: true)
                        })
                    }
                }
            }
        }
    }
    
    private func updateAmountInfoAfterPayment(saveCard: Bool) {
        // Amount will be refreshed only we move to home view.
        // So its needs to be updated for "Account->Blling->QuickPay" Flow
        self.sharedManager.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.totalAmountDue?.amount = nil
        if !saveCard { // If card is not being saved, remove the saved defaultPayMethod
            self.sharedManager.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = nil
        }
    }
    
    ///  Configure the UI data according to the payment type (eg. autopay, normal...)
    /// - Parameter paymentState: Gives payement type  (eg. autopay, normal...)
    private func validateScreenState(paymentState: ThanksPaymentState) {
        self.configureUI()
        button_Close.isHidden = true
        viewTryAgain.isHidden = true
        switch paymentState {
        case .updatingAutoPayment: break
        case .autoPay, .normal, .oneTimePaymentSuccess:
//            //For Google Analytics
//            CMAAnalyticsManager.sharedInstance.trackAction(
//                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_CARDINFO_PAYMENT_SUCCESS.rawValue,
//                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
            if paymentState == .autoPay {
                //For Google Analytics
                CMAAnalyticsManager.sharedInstance.trackAction(
                    eventParam: [EVENT_SCREEN_NAME: BillPayEvents.AUTOPAY_THANKYOU_SCREEN.rawValue,
                                EVENT_SCREEN_CLASS: self.classNameFromInstance])
            } else {
                //For Google Analytics
                CMAAnalyticsManager.sharedInstance.trackAction(
                    eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_CARDINFO_PAYMENT_SUCCESS.rawValue,
                              CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,
                               CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue,
                               CUSTOM_PARAM_INTENT: Intent.Billing.rawValue,
                                EVENT_SCREEN_CLASS: self.classNameFromInstance])
            }
            AppRatingManager.shared.trackConsecutiveQuickPaySuccess()
            configureNormalAndAutoPay()
        case .paymentFailure, .oneTimePaymentFailure:
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_PAYMENT_FAILED.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            AppRatingManager.shared.resetQuickPayCount()
            configurePaymentFailure()
        }
    }
    
    ///  Configure UI for Normal and Autopay Thanks page
    private func configureNormalAndAutoPay() {
        self.stackAmount.isHidden = false
        self.stackDate.isHidden = false
        self.viewTurnAutoPay.isHidden = false
        self.checkMarkView.isHidden = false
        self.button_Okay.setTitle("Okay", for: .normal)
        self.label_Title.text = "Thank you for your payment!"
        self.label_PaidTitle.text = "Paid with"
        /* CMAIOS-1050 */
        //        if let nextPayDue = sharedManager.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate {
        //            let dateString = CommonUtility.convertDateStringFormats(dateString: nextPayDue, dateFormat: "MMM. d, YYYY")
        //            self.label_NextAutoPayDate.text = "Your next Auto Pay is set for \(dateString)"
        //        }
        label_NextAutoPayDate.isHidden = true
        viewTurnAutoPay.isHidden = true
        /* CMAIOS-1050 */
        self.label_Amount.text = sharedManager.getCurrentAmount()
        self.label_Date.text = CommonUtility.convertDateStringFormats(dateString: CommonUtility.getCurrentDateString(), dateFormat: "MMM. d, YYYY")
        if isFromTryAgainFlow {
            if oneTimeCardInfo != nil {
                cardInfoOneTimePayment()
            } else {
                cardInfoImmediatePayment()
            }
        } else {
            if payMethod == nil {
                payMethod = QuickPayManager.shared.getDefaultPayMethod()
            }
            let defaultPaymethod = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
            image_CarType.image = UIImage(named: defaultPaymethod.2)
            label_CardType.text = defaultPaymethod.1
        }
        switch state {
        case .autoPay:
            // CMAIOS-1050
            //            label_NextAutoPayDate.isHidden = false
            viewTurnAutoPay.isHidden = true
        case .oneTimePaymentSuccess(let saveCard):
            viewTurnAutoPay.isHidden = !saveCard //true = Card is being saved while doing one time payment and vice versa for FALSE
            commonUIComponents()
        case .normal:
            viewTurnAutoPay.isHidden = false
            validateTryAgainFlow()
            commonUIComponents()
        default: break
        }
    }
    
    private func validateTryAgainFlow() {
        if isFromTryAgainFlow {
            if oneTimeCardInfo != nil {
                if !isDefaultSave {
                    viewTurnAutoPay.isHidden = true
                }
            } else {
                viewTurnAutoPay.isHidden = sharedManager.isAutoPayEnabled()
            }
        }
    }
    
    private func commonUIComponents() {
        let defaultPaymethod = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
        self.label_TurnOn_Subtitle.text = "Pay your amount due automatically each month using \(defaultPaymethod.1)" //CMAIOS-2504
        label_NextAutoPayDate.isHidden = true
    }
    
    ///  Configure UI for Payment failure page
    private func configurePaymentFailure() {
        stackAmount.isHidden = true
        stackDate.isHidden = true
        viewTurnAutoPay.isHidden = true
        checkMarkView.isHidden = true
        viewTryAgain.isHidden = false
        button_Close.isHidden = false
        button_Okay.setTitle("Use a different payment method", for: .normal)
        label_Title.text = "Sorry, that didn’t work."
        label_PaidTitle.text = "Your payment failed for"
        switch state {
        case .paymentFailure:
            cardInfoImmediatePayment()
        case .oneTimePaymentFailure:
            cardInfoOneTimePayment()
        default: break
        }
    }
    
    private func cardInfoImmediatePayment() {
        if let paymethod = payMethod, paymethod.creditCardPayMethod != nil{
            if let cardType = paymethod.creditCardPayMethod?.cardType {
                image_CarType.image = UIImage(named: sharedManager.getCardType(cardType: cardType))
            }
            if let nickName = paymethod.name?.components(separatedBy: "/").last {
                label_CardType.text = nickName
            }
        } else {
            //CMAIOS-2157
            let paymentInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
                image_CarType.image = UIImage(named: paymentInfo.2)
                label_CardType.text = paymentInfo.1
                self.cardView.setBorderUIForBankMOP(paymethod: payMethod)
        }
    }
    
    private func cardInfoOneTimePayment() {
        if let dictOTP = oneTimeCardInfo {
            if let cardType = dictOTP.payment?.payMethod?.creditCardPayMethod?.cardType {
                image_CarType.image = UIImage(named: sharedManager.getCardType(cardType: cardType))
            }
            if let nickName = dictOTP.payment?.payMethod?.newNickname {
                label_CardType.text = nickName
            }
        } else if let dictAchOTP = oneTimeAchInfo {
            if dictAchOTP.payment?.payMethod?.bankEftPayMethod?.nameOnAccount != nil {
                image_CarType.image = UIImage(named: "CheckingImage")
            } else {
                //CMAIOS-2157
                image_CarType.image = UIImage(named: "CheckingImage")
            }
            if let nickName = dictAchOTP.payment?.payMethod?.newNickname {
                label_CardType.text = nickName
            }
            //CMAIOS-2157
            self.cardView.setBorderUIForBankMOP(payACHMethod: dictAchOTP.payment?.payMethod)
        }
    }
    
    /// If payment failed: Retry payment triggered here
    @IBAction func actionChatWithUs(_ sender: Any) {
        /*
         DispatchQueue.main.async {
         self.tryAgainButtonAnimation()
         }
         self.tryAgainInProgress = true
         if state == .oneTimePaymentFailure {
         createOneTimePayment()
         } else if state == .paymentFailure {
         tryImmediatePayment()
         }
         */
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Quickpay_Payment_Failed.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.paymentFailed)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return
        }
        self.dataRefreshRequiredAfterChat = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.present(chatViewController, animated: true)
    }
    
    /// Create immediate payment
    private func tryImmediatePayment() {
        guard let jsonParam = retryPaymentJson else {
            self.tryAgainFailedAnimation()
            return
        }
        QuickPayManager.shared.mauiImmediatePayment(jsonParams: jsonParam, makeDefault: !isDefaultPaymethod(), completionHanlder: { isSuccess, errorDec, error in
            if isSuccess {
                self.tryAgainInProgress = false
                self.tryAgainAnimaionView.pause()
                self.tryAgainAnimaionView.play(fromProgress: self.tryAgainAnimaionView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.tryAgainFailedAnimation()
                    self.updateScreenTypeOnRetrySuccess()
                }
            } else {
                self.tryAgainFailedAnimation()
                self.showQuickAlertViewController()
            }
        })
    }
    
    /// Create One Time payment
    private func createOneTimePayment() {
        guard let jsonParam = retryPaymentJson else {
            self.tryAgainFailedAnimation()
            return
        }
        QuickPayManager.shared.mauiOneTimePaymentRequest(jsonParams: jsonParam, isDefault: isDefaultSave) { isSuccess, errorDesc, error in
            if isSuccess {
                if self.sharedManager.modelQuickPayOneTimePayment?.responseInfo?.statusCode == "00000" {
//                    self.tryAgainInProgress = false
//                    self.tryAgainAnimaionView.pause()
//                    self.tryAgainAnimaionView.play(fromProgress: self.tryAgainAnimaionView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
//                        self.tryAgainFailedAnimation()
//                        self.updateScreenTypeOnRetrySuccess()
//                    }
                    self.refreshGetAccountBill()
                } else {
                    self.tryAgainFailedAnimation()
                }
            } else {
                self.tryAgainFailedAnimation()
                self.showQuickAlertViewController()
            }
        }
    }
    
    /// Refresh Get Account bill
    private func refreshGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = sharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                }
                self.tryAgainInProgress = false
                self.tryAgainAnimaionView.pause()
                self.tryAgainAnimaionView.play(fromProgress: self.tryAgainAnimaionView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.tryAgainFailedAnimation()
                    self.updateScreenTypeOnRetrySuccess()
                }
            }
        })
    }
    
    /// If error code == 500 for immediate, still user need to show error screen
    /// But for one time payment, we need to show the failure alert
    func handleErrorThaksAutoPayView() {
        self.tryAgainFailedAnimation()
        if QuickPayManager.shared.currentApiType == .oneTimePayment {
            self.showQuickAlertViewController()
        }
    }

    private func showQuickAlertViewController() {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .systemUnavailable
        viewcontroller.modalPresentationStyle = .fullScreen
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        self.present(viewcontroller, animated: true)
    }
    
    private func updateScreenTypeOnRetrySuccess() {
        isFromTryAgainFlow = true
        if sharedManager.isAutoPayEnabled() {
            self.state = .autoPay
        } else {
            self.state = .normal
        }
        self.setUpWithAnimationConfig()
//        self.validateScreenState(paymentState: self.state)
    }
    
    private func isDefaultPaymethod() -> Bool {
        var isDefault = false
        if payMethod.name == QuickPayManager.shared.getDefaultPayMethod()?.name {
            isDefault = true
        }
        return isDefault
    }
        
    @IBAction func actionClose(_ sender: Any) {
        //        self.dismiss(animated: true)
        switch state {
        case .paymentFailure, .oneTimePaymentFailure:
            closeButtonNavigation()
        default:
            self.dismiss(animated: true)
        }
    }

    private func closeButtonNavigation() {
        if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
            return
        }
        
        if let navigationControl = self.presentingViewController as? UINavigationController {
            if let vc = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: true)
                }
                return
            }
        }
    }
    
    private func navigateToFinishSetup() {
        guard let viewcontroller = FinishSetupViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.screenType = .autoPayEnroll
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func showAddCard() {
        guard let addCardView = AddCardViewController.instantiateWithIdentifier(from: .payments) else { return }
        addCardView.flow = .paymentFailure
        // CMAIOS-2099
        self.navigationController?.pushViewController(addCardView, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    func animateSubviews(shouldShow: Bool, completion: (() -> Void)? = nil) {
        changeSubviews(alpha: shouldShow ? 0 : 1)
        UIView.animate(withDuration: 1.0, animations: {
            self.stackDate.alpha = shouldShow ? 1 : 0
            self.stackPaidCard.alpha = shouldShow ? 1 : 0
            self.stackAmount.alpha = shouldShow ? 1 : 0
            self.stackTitleView.alpha = shouldShow ? 1 : 0
            self.button_Okay.alpha = shouldShow ? 1 : 0
        }, completion: { finished in
            completion?()
        })
    }
    
    func viewShiftAnimationSetUp() {
        changeSubviews(alpha: 0)
    }
    
    func changeSubviews(alpha: CGFloat) {
        [stackDate, stackAmount, stackPaidCard, stackTitleView, button_Okay].forEach { subview in
            subview?.alpha = alpha
        }
    }
    
    // MARK: -  Animation
    func tryAgainButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.tryAgainAnimaionView.isHidden = true
        self.button_TryAgain.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.tryAgainAnimaionView.isHidden = false
        }
        self.tryAgainAnimaionView.backgroundColor = .clear
        self.tryAgainAnimaionView.animation = LottieAnimation.named("HollowButtonFullWidth")
        self.tryAgainAnimaionView.loopMode = .playOnce
        self.tryAgainAnimaionView.animationSpeed = 1.0
        // self.signInAnimView.currentProgress = 0.4
        self.tryAgainAnimaionView.play(toProgress: 0.6, completion:{_ in
            if self.tryAgainInProgress {
                self.tryAgainAnimaionView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func tryAgainFailedAnimation() {
        /*
         self.tryAgainInProgress = false
         self.tryAgainAnimaionView.currentProgress = 3.0
         self.tryAgainAnimaionView.stop()
         self.tryAgainAnimaionView.isHidden = true
         self.button_TryAgain.alpha = 0.0
         self.button_TryAgain.isHidden = false
         UIView.animate(withDuration: 1.0) {
         self.button_TryAgain.alpha = 1.0
         }
         */
    }
    
    private func handlePostChatSession() { // CMAIOS-1618
        self.dataRefreshRequiredAfterChat = false
        self.removeLoaderView()
        if let myBillView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            self.navigationController?.popToViewController(myBillView, animated: false)
        } else if let addcard = self.navigationController?.viewControllers.filter({$0 is AddCardViewController}).first as? AddCardViewController {
            self.navigationController?.dismiss(animated: false)
        }
    }
}

extension ThanksAutoPayViewController {
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
//                    if self.dataRefreshRequiredAfterChat {
                        self.mauiGetListPaymentApiRequest()
//                    } else {
//                        self.refreshViewAfterChat()
//                    }
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
                    self.handlePostChatSession()
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
        self.showQuickAlertViewController(alertType: .systemUnavailable, animated: false)
    }
    
    private func showQuickAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
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

enum ThanksPaymentState: Equatable {
    case normal
    case updatingAutoPayment
    case paymentFailure
    case autoPay
    case oneTimePaymentFailure
    case oneTimePaymentSuccess(saveCard: Bool)
}
