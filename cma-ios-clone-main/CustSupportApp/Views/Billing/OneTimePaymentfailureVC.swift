//
//  OneTimePaymentfailureVC.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 26/04/24.
//

import UIKit
import ASAPPSDK


enum ErrorType {
    case oneTime(OTPFailErrorType)
    case schedule(SPTFailErrorType)
    case autoPay(AutoPayFailErrorType)
    case autoPayBPH(AutoPayFailErrorTypeBPH)//CMAIOS-2378, 2380
    case none
}

// Depeding on type update UI.
// CMAIOS-2067
enum OTPFailErrorType {
    case OTPFailDefaultMOP // CMAIOS 2283
    case OTPFailSecondDefaultMOP // CMAIOS 2285
    case OTPFailTechnical // CMA2295
    case OTPFailTechnicalSecondTime // CMA2297
    case OTPFailExceedCard
    case OTPFailExceedCardNoAmountDue //2497
    case OTPFailExceedCheckingNoAmountDue //CMA2499
    case OTPFailNotValidCard // CMA2303
    case OTPFailNotValidCardExpired // CMA2304
    case OTPFailNotValidChecking // CMA2305
    case OTPFailNotValidCheckingRouting // CMA2306
    case OTPFailDuplicatePayment
    case OTPFailDuplicateScheduledPayment
    case OTPFailACH
    case OTPFailACHNoAmountDue
    case OTPCreditLimitFlow
    case OTPCreditLimitCreditCard
    case none
}

enum SPTFailErrorType {
    //case SPFFailDefaultMOP // CMAIOS 2283
    case SPFTechnicalAmountDue // CMA2309
    case SPFTechnicalNoAmountDue // CMA2310
    case SPFExceedLimitCardAmountDue // CMA2314
    case SPFExceedLimitCardNoAmountDue // CMA2345
    case SPFExceedLimitCheckingAmountDue // CMA2316
    case SPFExceedLimitCheckingNoAmountDue // CMA2379
    case SPFNotValidCardAmountDue // CMA2312
    case SPFNotValidCardNoAmountDue // CMA2347
    case SPFNotValidCheckingAmountDue // CMA2317 // CMA2319
    case SPFNotValidCheckingNoAmountDue // CMA2496
    case SPFDuplicateAmountDue // CMA2383
    case SPFDuplicateNoAmountDue // CMA2384
    case SPFFailCardExpired // CMA2313
    case SPFFailCardExpiredNoAmountDue // CMA2412
    case none
}

enum AutoPayFailErrorTypeBPH {
    case APTechnicalDifficultiesAmountDue
    case APTechnicalDifficultiesNoAmountDue
    case APExceedLimitCardNoAmountDue //CMAIOS-2379
    case APExceedLimitCardAmountDue //CMAIOS-2381
    case APCardExpiredNoAmountDue //CMAIOS-2383
    case APCardExpiredAmountDue //CMAIOS-2382
    case APExceedLimitCheckingAmountDue // CMAIOS-2663
    case APExceedLimitCheckingNoAmountDue // CMAIOS-2663
    case APNotValidCardAmountDue // CMAIOS-2663
    case APNotValidCardNoAmountDue // CMAIOS-2663
    case APNotValidCheckingAmountDue // CMAIOS-2663
    case APNotValidCheckingNoAmountDue // CMAIOS-2663
    case none
}

enum AutoPayFailErrorType {
    case APNotValidCardAmountDue // CMAIOS-2120
    case APNotValidCardNoAmountDue // CMAIOS-2118
    case APFailCardExpiredAmountDue // CMAIOS-2425
    case APFailCardExpiredNoAmountDue // CMAIOS-2428
    case APNotValidCheckingAmountDue // CMAIOS-2115
    case APNotValidCheckingNoAmountDue
    case APExceedLimitCheckingAmountDue // CMAIOS-2112
    case APExceedLimitCheckingNoAmountDue // CMAIOS-2104
    case APTechnicalDifficultiesNoAmountDue // CMAIOS-2365
    case APTechnicalDifficultiesAmountDue // CMAIOS-2431
    case APExceedLimitCardAmountDue // CMA2336
    case APExceedLimitCardNoAmountDue // CMA2380
    case none
}

class OneTimePaymentfailureVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnUseDiffPayment: RoundedButton!
    @IBOutlet weak var btnChatwithus: RoundedButton!
    @IBOutlet weak var heightCloseBottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var titleLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintChatwithus: NSLayoutConstraint!
    
    @IBOutlet weak var buttonClose: UIButton!
    let sharedManager = QuickPayManager.shared
    let diffMOPBtnTitle = "Use a different payment method"
    let tryAgnBtnTitle = "Try again"
    let maybeLtrBtnTitle = "Maybe later"
    let chatBtnTitle = "Chat with us"
    let strYourChkAcc = "checking account"
    let strYourCC = "credit/debit card"
    var state: ThanksPaymentState = .normal
    // CMAIOS-2067
    var errorType: ErrorType = .none
    var isMakePaymentFlow: Bool = false
    var isAutoPayFlow = false
    var cardData: SpotLightCardsGetResponse.CardData?
    //CMAIOS-2413
    var historyInfo: HistoryInfo?
    var selectedAmount: Double?
    var dismissCallBack: ((Bool) -> Void)?
    var chatFlow: Bool = false
    //CMAIOS-2435: Changed paymethod
    var payMethod: PayMethod!
    var isAutoPaymentErrorFlow = false
    var isFromSpotlight: Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIScheduledandOTP()
        //CMAIOS-2413 configure UI for payment error screen
        updateButtonsMessageForErrorType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Hide nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.chatFlow {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            self.dismissCallBack?(self.chatFlow)
        }
    }
    
    func configureUIScheduledandOTP(){
        switch errorType {
        case .oneTime(_), .none:
            imageIcon.isHidden = true
            titleLeftConstraint.constant = 20
            view.backgroundColor = .white
        case .schedule(_), .autoPay(_), .autoPayBPH(_):  //CMAIOS-2378, 2380
            imageIcon.isHidden = false
            titleLeftConstraint.constant = 70
            view.backgroundColor = midnightBlueRGB
            btnUseDiffPayment.backgroundColor = .white
            btnUseDiffPayment.borderWidth = 2
            btnUseDiffPayment.borderColor = .lightGray
            lblTitle.textColor = .white
            lblSubTitle.textColor = .white
            btnChatwithus.setTitleColor(.white, for: .normal)
            btnUseDiffPayment.setTitleColor(midnightBlueRGB, for: .normal)
            buttonClose.setImage(UIImage(named: "close_white"), for: .normal)
            //CMAIOS-2413
            payMethod = isFromSpotlight ? self.findPayMethod(withName: cardData?.payNickName ?? "", in: sharedManager.getAllPayMethodMop()) : self.historyInfo?.paymethod
        }
    }

    //get last four digit nickname
    func getLastFourDigits(payMethod: PayMethod) -> String? {
        var stringLastFourDigit = ""
        if let maskedBankAccountNumber = payMethod.bankEftPayMethod?.maskedBankAccountNumber, !maskedBankAccountNumber.isEmpty {
            // If maskedBankAccountNumber is not empty, get the last four digits
            stringLastFourDigit = String(maskedBankAccountNumber.suffix(4))
        } else if let maskedCreditCardNumber = payMethod.creditCardPayMethod?.maskedCreditCardNumber, !maskedCreditCardNumber.isEmpty {
            // If maskedBankAccountNumber is empty, check the credit card number
            stringLastFourDigit = maskedCreditCardNumber.count == 4 ? maskedCreditCardNumber : ""
        }
        return stringLastFourDigit
    }
    //CMAIOS-2267
    func checkIsAccountSaved(payMethods: [PayMethod], searchString: String) -> Bool {
        for payMethod in payMethods {
            if let name = payMethod.name {
                let nickName = name.components(separatedBy: "/").last ?? ""
                if nickName == searchString {
                    return true
                }
            }
        }
        return false
    }
    
    //CMAIOS-2323
    func checkIsAccountSavedLocally(payMethods: [LocalSavedPaymethod], searchString: String) -> Bool {
        for payMethod in payMethods {
            if let name = payMethod.payMethod?.name {
                let nickName = name.components(separatedBy: "/").last ?? ""
                if nickName == searchString {
                    return true
                }
            }
        }
        return false
    }
    
    
    //CMAIOS-2273
    func findPayMethod(withName name: String, in payMethods: [PayMethod]) -> PayMethod? {
        return payMethods.first { payMethod in
            payMethod.name == name || payMethod.name?.components(separatedBy: "/").last == name
        }
    }
    
    func setCloseViewHeight(isCloseView: Bool) {
        heightCloseBottomViewConstraint.constant = isCloseView ? 80 : 0
        bottomConstraintChatwithus.constant = isCloseView ? 20 : (UIDevice.current.hasNotch ? 45 : 30)
        self.view.updateConstraints()
    }
    
    @IBAction func useDifferentMethodBtnTapAction(_ sender: Any) {
        primaryButtontRouting()
    }
    
    @IBAction func chatWithUsBtnTapAction(_ sender: Any) {
        secondaryButtontRouting()
    }
    
    @IBAction func closeBtnTapAction(_ sender: Any) {
        navToBillingHome()
    }
    
    // CMAiOS-2070
    private func doPayNowAgain() {
        if let makePayVC = self.navigationController?.viewControllers.filter({$0 is MakePaymentViewController}).first as? MakePaymentViewController {
            makePayVC.payNowRetry = true
            makePayVC.autoRetry = true
            self.navigationController?.popToViewController(makePayVC, animated: true)
        }
    }
    
    // CMAIOS-2067
    func updateButtonsMessageForErrorType() {
        //CMAIOS-2413
        lblSubTitle.setLineHeight(1.2)
        lblTitle.setLineHeight(1.2)
        btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
        btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
        setCloseViewHeight(isCloseView: false)
        switch errorType {
        case .oneTime(let type):
            updateForOneTimePay(otpErrorType: type)
        case .schedule(let type):
            updateForSchedulePay(type: type)
        case .autoPay(let type):
            updateForAutoPay(type: type)
        case .autoPayBPH(let type): //CMAIOS-2378, 2380
            updateForAutoPayBPH(type: type)
        default: break
        }
    }
    
    // CMAIOS-2067
    func primaryButtontRouting() {
        switch errorType {
        case .oneTime(let type):
            handleOneTimePayPrimaryTap(type: type)
        case .schedule(let type):
            handleSchedulePrimaryTap(type: type)
        case .autoPay(let type):
            handleAutoPayPrimaryTap(type: type)
        case .autoPayBPH(let type): //CMAIOS-2378, 2380
            handleAutoPayPrimaryTapBPH(type: type)
        default:break
        }
    }
    
    // CMAIOS-2067
    func secondaryButtontRouting() {
        switch errorType {
        case .oneTime(let type):
            handleOneTimePaySecondaryTap(type: type)
        case .schedule(let type):
            handleScheduleSecondaryTap(type: type)
        case .autoPay(let type):
            handleAutoPaySecondaryTap(type: type)
        case .autoPayBPH(let type): //CMAIOS-2378, 2380
            handleAutoPaySecondaryTapBPH(type: type)
        default:break
        }
    }

}

extension OneTimePaymentfailureVC {
    
    // CMAIOS-2067
    func navToBillingHome() {
       // CMAIOS-2413
        switch isFromSpotlight {
        case true:
            if let navigationController = self.presentingViewController?.presentingViewController?.presentingViewController as? UINavigationController {
                self.navToBillingHomeVCFromNavVC(navigationController: navigationController)
            }
            
            if let navigationController = self.presentingViewController?.presentingViewController as? UINavigationController {
                self.navToBillingHomeVCFromNavVC(navigationController: navigationController)
            }
            
            if let navigationController = self.presentingViewController as? UINavigationController {
                self.navToBillingHomeVCFromNavVC(navigationController: navigationController)
            }
            
            if let navigationController = self.navigationController {
                self.navToBillingHomeVCFromNavVC(navigationController: navigationController)
            }
        case false:
            //CMAIOS-2413 //CMAIOS-2415
            self.navToBillingAndPaymentHistory()
        default:
            Logger.info("")
        }
    }
    
    // CMAIOS-2067 and CMAiOS-2070
    func navToChatwithus() {
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.paymentFailed)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return
        }
        self.chatFlow = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    func navToMakePayment(){
        if let makePaymentController = self.navigationController?.viewControllers.filter({$0 is MakePaymentViewController}).first as? MakePaymentViewController {
            //CMAIOS-2435:
            if payMethod != nil {
                makePaymentController.payMethod = payMethod
            }
            //
            self.navigationController?.popToViewController(makePaymentController, animated: true)
        }
    }
    
    func showAddCard() {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = isMakePaymentFlow
        viewcontroller.flow = .noPayments
        viewcontroller.selectedAmount = selectedAmount
        viewcontroller.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func clearSelectedPayMethods(isAutoPayFlow: Bool = false) -> Bool { //CMAIOS-2296 //CMAIOS-2435 // CMAIOS-2110
        /*
         if payMethod != nil {
         let payMethods = QuickPayManager.shared.getAllPayMethodMop().filter { $0.name != payMethod.name }
         return payMethods.isEmpty
         } else {
         if QuickPayManager.shared.getAllPayMethodMop().count > 0 {
         return false
         } else {
         return true
         }
         }
         */
        
        // CMAIOS-2110, isAutoPayFlow == true, Auto Pay Spot light Error flow
        // payMethod != nil, other fallback flows
        switch (payMethod != nil, isAutoPayFlow) {
        case ( _, true):
            return QuickPayManager.shared.getAllPayMethodMop().filter { QuickPayManager.shared.getOnlyNickName(paymethod: $0) != cardData?.payNickName }.isEmpty
        case ( true, _):
            return QuickPayManager.shared.getAllPayMethodMop().filter { $0.name != payMethod.name }.isEmpty
        default:
            if QuickPayManager.shared.getAllPayMethodMop().count > 0 {
                return false
            } else {
                return true
            }
        }
    }
        
    func navToChoosePayment(retryNow: Bool? = nil, isAutoPayFlow: Bool = false) {
        ///CMAIOS-2238
        if clearSelectedPayMethods() {
            self.showAddCard()
            return
        }
        
        guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        vc.modalPresentationStyle = .fullScreen
        //CMAIOS-2435
        if payMethod != nil {
            vc.payMethod = payMethod
            vc.selectedPayMethods = self.payMethod
        }
        vc.isMakePaymentFlow = true
        vc.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        vc.selectionHandler = { [weak self] payMethod in
            self?.payMethod = payMethod
            
            //Check if MakePaymentViewController already part of navigation controller
            if let makePaymentController = self?.navigationController?.viewControllers.filter({$0 is MakePaymentViewController}).first as? MakePaymentViewController {
                makePaymentController.firstTimeCardFlow = false
                makePaymentController.updatedPayMethod = payMethod
                if let retry = retryNow {
                    makePaymentController.payNowRetry = retry
                }
                self?.navigationController?.popToViewController(makePaymentController, animated: true)
            } else if QuickPayManager.shared.getCurrentAmount() == "" {
                self?.enterAmountScreen()
            } else {
                self?.moveToMakePaymentScreen(paymethod: payMethod, retryNow: retryNow)
            }
            
            /*
             //Navigate to enter payment screen if there is no amnt due else to MakePayment
             if QuickPayManager.shared.getCurrentAmount() == "" {
             self?.enterAmountScreen()
             } else {
             //Check if MakePaymentViewController already part of navigation controller
             if let makePaymentController = self?.navigationController?.viewControllers.filter({$0 is MakePaymentViewController}).first as? MakePaymentViewController {
             makePaymentController.firstTimeCardFlow = false
             makePaymentController.updatedPayMethod = payMethod
             if let retry = retryNow {
             makePaymentController.payNowRetry = retry
             }
             self?.navigationController?.popToViewController(makePaymentController, animated: true)
             } else {
             self?.moveToMakePaymentScreen(paymethod: payMethod, retryNow: retryNow)
             }
             }
             */
        }
        //CMAIOS-2354: Fix to call proper header for choose payment screen
        vc.isFromOtpOrSPF = true
        switch errorType {
        case .oneTime(let type):
            if type == .OTPCreditLimitFlow || type == .OTPFailNotValidChecking || type == .OTPFailNotValidCheckingRouting || type == .OTPFailNotValidCard || type == .OTPFailNotValidCardExpired || type == .OTPCreditLimitCreditCard || type == .OTPFailDefaultMOP  { //CMAIOS-2439 show correct title header for OTPFailDefaultMOP
                vc.titleHeader = "Choose a different payment method"
            } else {
                vc.titleHeader = "Choose a payment method"
            }
        case .schedule(let type):
            if type == .SPFNotValidCheckingAmountDue || type == .SPFNotValidCardAmountDue || type == .SPFFailCardExpired  || type == .SPFExceedLimitCheckingAmountDue || type == .SPFExceedLimitCardAmountDue {
                vc.titleHeader = "Choose a different payment method"
            } else {
                vc.titleHeader = "Choose a payment method"
            }
        case .autoPay(let type): // CMAIOS-2120
            if type == .APNotValidCardAmountDue || type == .APFailCardExpiredAmountDue || type == .APNotValidCheckingAmountDue || type == .APExceedLimitCheckingAmountDue || type == .APExceedLimitCardAmountDue {
                vc.titleHeader = "Choose a different payment method"
            } else {
                vc.titleHeader = "Choose a payment method"
            }
        case .autoPayBPH(let type):
            if type == .APNotValidCardAmountDue || type == .APNotValidCheckingAmountDue {
                vc.titleHeader = "Choose a different payment method"
            } else {
                vc.titleHeader = "Choose a payment method"
            }
        default: break
        }
        //
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func enterAmountScreen() {
        DispatchQueue.main.async {
            let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
            enterPayVC.amountStr = ""
            enterPayVC.balanceStateText = "No payment due at this time"
            enterPayVC.payMethod = self.payMethod
            enterPayVC.isOneTimeFailureFlow = true
            enterPayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow // CMAIOS-2119
            self.navigationController?.pushViewController(enterPayVC, animated: true)
        }
    }
    
    func moveToMakePaymentScreen(paymethod: PayMethod?, retryNow: Bool? = nil, autoTry: Bool = false) {
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        //CMAIOS-2435
        if paymethod != nil {
            makePayVC.updatedPayMethod = paymethod
        }
        if let retryNow = retryNow {
            makePayVC.payNowRetry = retryNow
            makePayVC.autoRetry = autoTry
        }
        makePayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow // CMAIOS-2119
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
    func navToHomeVC() {
        if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
            self.dismiss(animated: true)
        }
    }

    //CMAIOS-2415
    func navToBillingAndPaymentHistory(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func navToBillingHomeVCFromNavVC(navigationController: UINavigationController) {
        if let billingPayVC = navigationController.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
            DispatchQueue.main.async {
                navigationController.popToViewController(billingPayVC, animated: true)
            }
        }else{
            self.navToHomeVC()
        }
    }
}

//MARK: Handle OneTimePayment related

extension OneTimePaymentfailureVC {
    
    func updateForOneTimePay(otpErrorType: OTPFailErrorType) {
        //CMAIOS-2413
        let lastFourDigits = sharedManager.getPaymentInfo(payMethod: payMethod).lastFourDigits
        var screenTag = ""
        let isFromCC = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod).0
        let defaultNickName = isFromCC ? "credit/debit card" : "checking account"
        switch otpErrorType {
        case .OTPFailDefaultMOP:
            lblSubTitle.text = "Please pay with a different payment method or try again"
            //CMAIOS-2324
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(tryAgnBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
        case .OTPFailTechnical:
            btnUseDiffPayment.setTitle(tryAgnBtnTitle, for: .normal)
            lblSubTitle.text = "Due to technical difficulties, we couldn't take your payment.\n\nPlease try again."
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_FIRST_TIME_TECH_DIFFICULTY.rawValue
        case .OTPFailTechnicalSecondTime, .OTPFailSecondDefaultMOP:
            btnUseDiffPayment.setTitle("Chat with us", for: .normal)
            btnChatwithus.setTitle("Maybe later", for: .normal)
            btnUseDiffPayment.setTitle(chatBtnTitle, for: .normal)
            //CMAIOS-2439 Added fix for showing May be later btn title instead of showing two chat with us buttons
            btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: false)
            // CMAiOS-2070
            lblSubTitle.text = "We still can’t take your payment in the app right now. \n \nPlease chat with us or try again later"
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_SECOND_TIME_TECH_DIFFICULTY.rawValue
        case .OTPFailACH:
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
        case .OTPFailACHNoAmountDue:
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
        case .OTPFailDuplicatePayment:
            /*CMA-2377*/
            lblSubTitle.text = "For your protection, we don't allow duplicate payments within a 24 hour period.\n\nYou made a payment of $\(QuickPayManager.shared.currentMakepaymentAmount) using \(self.mopDetailsForOTPFailure(defaultNickName: "your " + defaultNickName)) on \(QuickPayManager.shared.currentMakepaymentDate).\n\nPlease use a different payment method, or pay a different amount."
            btnUseDiffPayment.setTitle("Update my payment info", for: .normal)
            btnChatwithus.setTitle("Cancel", for: .normal)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_DUPLICATE_PAYMENT_PROCESSED.rawValue
        case .OTPFailDuplicateScheduledPayment:
            btnUseDiffPayment.setTitle("Update payment info", for: .normal)
            btnChatwithus.setTitle("Cancel", for: .normal)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_DUPLICATE_PAYMENT_SCHEDULED.rawValue
        case .OTPFailNotValidCheckingRouting:
            /*CMA-2306 Error Invalid Bank or Finbr */
            lblTitle.text = "Sorry, this payment failed"
            lblSubTitle.text = "Looks like the routing number for your \(self.mopDetailsForOTPFailure(defaultNickName: strYourChkAcc)) is not correct.\n\nPlease use a different payment method, or chat with us to update your checking account."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_ACH_AMOUNT_DUE.rawValue
        case .OTPFailNotValidChecking:
            /*CMA-2305 Error 30170 */
            //CMAIOS-2292 copy updated
            lblTitle.text = "Sorry, this payment failed"
            lblSubTitle.text = "Looks like the account number for your \(self.mopDetailsForOTPFailure(defaultNickName: strYourChkAcc)) is not correct.\n\nPlease use a different payment method, or chat with us to update your checking account."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_ACH_AMOUNT_DUE.rawValue
        case .OTPFailNotValidCard:
            /* CMA-2303 Error Invalid CC number */
            lblSubTitle.text = "Looks like the card number for your \(self.mopDetailsForOTPFailure(defaultNickName: strYourCC)) is not correct.\n\nPlease use a different payment method, or chat with us to update your card."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_CARD_AMOUNT_DUE.rawValue
        case .OTPFailNotValidCardExpired:
            //CMA-2304
            lblSubTitle.text = "Looks like the expiration date for your \(self.mopDetailsForOTPFailure(defaultNickName: strYourCC)) is not correct.\n\nPlease use a different payment method, or chat with us to update your card."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_CARD_AMOUNT_DUE.rawValue
        case .OTPCreditLimitFlow : //CMAIOS-2068,
            /*CMA-2300*/
            lblSubTitle.text = "Your bank says \(self.mopDetailsForOTPFailure(defaultNickName: "your " + defaultNickName)) doesn't have enough available funds or is no longer valid.\n\nPlease use a different payment method, or contact your bank and try again."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
            btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: false)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_AMOUNT_DUE.rawValue
        case .OTPFailExceedCardNoAmountDue: // CMAIOS-2212
            /*CMA-2497*/
            lblSubTitle.text = "Your card provider says \(self.mopDetailsForOTPFailure(defaultNickName: "your " + defaultNickName)) has reached its limit or is no longer valid.\n\nPlease contact your card provider to resolve this issue."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: false)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_NO_AMOUNT_DUE.rawValue
        case .OTPCreditLimitCreditCard: // CMAIOS-2069
            /*CMA-2299*/
            lblSubTitle.text = "Your card provider says \(self.mopDetailsForOTPFailure(defaultNickName: "your " + defaultNickName)) has reached its limit or is no longer valid.\n\nPlease use a different payment method, or contact your card provider and try again."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)//CMAIOS-2278-Copy text
            btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: false)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_AMOUNT_DUE.rawValue
        case .OTPFailExceedCheckingNoAmountDue: // CMAIOS-2210
            /*CMA-2499*/
            lblSubTitle.text = "Your bank says \(self.mopDetailsForOTPFailure(defaultNickName: "your " + defaultNickName)) doesn't have enough available funds or is no longer valid.\n\nPlease contact your bank to resolve this issue."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: false)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_NO_AMOUNT_DUE.rawValue
        default: break
        }
        if !screenTag.isEmpty {
            if screenTag == "paymentfailed_validationerror_ach_amountdue" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            } else {
                let custParams = [EVENT_SCREEN_NAME : screenTag, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
            }
        }
    }
    
    func handleOneTimePayPrimaryTap(type: OTPFailErrorType)  {
        switch type {
        case .OTPFailDefaultMOP: // CMAIOS-2283
            navToChoosePayment(retryNow: true)
        case .OTPFailTechnical://CMAIOS-2267 and CMAIOS-2067
            let paymentInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
            let payMethods = sharedManager.getAllPayMethodMop()
            if !payMethods.isEmpty {
                checkIsAccountSaved(payMethods: sharedManager.getAllPayMethodMop(), searchString: paymentInfo.1) ? self.doPayNowAgain() : navToChoosePayment(retryNow: true)
            } else {
                //CMAIOS-2323 check if MOP is saved locally
                if let localSavedMethods = sharedManager.localSavedPaymethods {
                    //CMAIOS-2439 added fix
                    if checkIsAccountSavedLocally(payMethods: localSavedMethods, searchString: paymentInfo.1) {  navToChoosePayment(retryNow: true) }
                }
            }
        case .OTPFailTechnicalSecondTime, .OTPFailSecondDefaultMOP:
            self.navToChatwithus()
        case.OTPFailNotValidCheckingRouting, .OTPFailNotValidChecking, .OTPFailNotValidCard, .OTPFailNotValidCardExpired:
            navToChoosePayment()
        case .OTPFailExceedCardNoAmountDue: //CMAIOS-2212
            navToBillingHome()
        case .OTPCreditLimitFlow, .OTPCreditLimitCreditCard: //CMAIOS-2068, CMAIOS-2069
            navToChoosePayment()
        case .OTPFailDuplicatePayment: //CMAIOS-2066
            navToMakePayment()
        case .OTPFailExceedCheckingNoAmountDue: //CMAIOS-2329
            if let navigationController = self.navigationController {
                navToBillingHomeVCFromNavVC(navigationController: navigationController)
            }
        default:
            handleButtonOnCurrentTitle(title: btnUseDiffPayment.currentTitle ?? "")
        }
    }
    
    func handleButtonOnCurrentTitle(title: String) {
        if title == diffMOPBtnTitle {//CMAIOS-2278-Copy text
            self.navToChoosePayment()
        } else if title == chatBtnTitle {
            self.navToChatwithus()
        } else if title == "Okay" {
            self.navToBillingHome()
        } else if title == tryAgnBtnTitle {
            self.navToMakePayment()
        }
    }
    
    func handleOneTimePaySecondaryTap(type: OTPFailErrorType)  {
        switch type {
        case .OTPFailDefaultMOP: // CMAIOS-2283
            let paymentInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
            checkIsAccountSaved(payMethods: sharedManager.getAllPayMethodMop(), searchString: paymentInfo.1) ? self.doPayNowAgain() : navToChoosePayment(retryNow: true)
        case .OTPFailTechnical, .none, .OTPFailSecondDefaultMOP, .OTPFailTechnicalSecondTime: //CMAIOS-2442 added missing error case
            navToBillingHome()
        case.OTPFailNotValidCheckingRouting, .OTPFailNotValidChecking, .OTPFailNotValidCard, .OTPFailNotValidCardExpired:
            navToChatwithus()
        case .OTPCreditLimitFlow, .OTPCreditLimitCreditCard:  //CMAIOS-2068, CMAIOS-2069
            navToBillingHome()
        case .OTPFailDuplicatePayment: //CMAIOS-2066
            navToBillingHome()
        default:
            // fall back to billing Home.
            navToBillingHome()
        }
    }
    /*
    func getNickNameOrAccNo(payMethod: PayMethod?) -> String {
        // Get the nickname from the payMethod display info
        let nickname = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod).1
        var nicknameOrAccNo:String = ""
        if !nickname.isEmpty {
            nicknameOrAccNo = nickname
        } else if let maskedBankAccountNumber = payMethod?.bankEftPayMethod?.maskedBankAccountNumber, !maskedBankAccountNumber.isEmpty {
            // If nickname is empty, check the bank account number
            nicknameOrAccNo = String(maskedBankAccountNumber.suffix(4))
        } else if let maskedCreditCardNumber = payMethod?.creditCardPayMethod?.maskedCreditCardNumber, !maskedCreditCardNumber.isEmpty {
            // If both nickname and bank account number are empty, check the credit card number
            nicknameOrAccNo = maskedCreditCardNumber
        }
        
        return nicknameOrAccNo
    }
     */
}

//MARK: Handle Schedule payment related

extension OneTimePaymentfailureVC {
    
    func updateForSchedulePay(type: SPTFailErrorType) {
        //CMAIOS-2413
        let paymentInfo = sharedManager.getPaymentInfo(payMethod: payMethod)
        let nickName = isFromSpotlight && payMethod == nil ? cardData?.payNickName ?? "" : paymentInfo.nickname //CMAIOS-2417
        //CMAIOS-2211
        var screenTag = ""
        switch type {
//        case .SPFFailDefaultMOP:
//            lblSubTitle.text = "Please pay with a different payment method or try again"
//            //CMAIOS-2324
//            btnUseDiffPayment.setTitle("Use a different payment method", for: .normal)
//            btnChatwithus.setTitle("Try again", for: .normal)
//            setCloseViewHeight(isCloseView: true)
        case .SPFFailCardExpiredNoAmountDue: // CMA-2412->CMAIOS-2415
            lblSubTitle.text = "Looks like the expiration date for your \(self.checkForCardDetails()) is not correct."
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: false)
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_CARD_AMOUNT_DUE.rawValue
        case .SPFFailCardExpired: // CMA-2313
            ////CMAIOS-2359 //CMAIOS-2413
            /*
            let commonText = "Looks like the expiration date for your \(self.checkForCardDetails()) is not correct."
            lblSubTitle.text = isFromSpotlight ? commonText + "\n\nPlease pay now with a different payment method, or chat with us to update your card." : commonText
            //CMAIOS-2324
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
            */
            /*
            // CMAIOS-2653
            lblSubTitle.text =  "Looks like the expiration date for your \(self.checkForCardDetails()) is not correct."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: true)
            */
            
            if let errorCode = historyInfo?.errorCode, errorCode == "522" {
                // CMAIOS-2653
                lblSubTitle.text =  "Looks like the expiration date for your \(self.checkForCardDetails()) is not correct."
                btnUseDiffPayment.setTitle("Make a payment", for: .normal)
                btnChatwithus.isHidden = true
                setCloseViewHeight(isCloseView: true)
            } else {
                let commonText = "Looks like the expiration date for your \(self.checkForCardDetails()) is not correct."
                lblSubTitle.text = isFromSpotlight ? commonText + "\n\nPlease pay now with a different payment method, or chat with us to update your card." : commonText
                //CMAIOS-2324
                btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
                btnChatwithus.setTitle(chatBtnTitle, for: .normal)
                setCloseViewHeight(isCloseView: true)
            }
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_CARD_AMOUNT_DUE.rawValue
        case .SPFTechnicalNoAmountDue: // CMA-2310
            //CMAIOS-2419
            let subTitleCommonText = "Due to technical difficulties, we couldn't process your scheduled payment."
            lblSubTitle.text = isFromSpotlight ?  (subTitleCommonText) + "\n\nYou have no amount due at this time." : subTitleCommonText
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
            screenTag = ScheduledPaymentFailureDetails.SCHEDULED_PAYMENT_FAILED_TECH_DIFFICULTY_NO_AMOUNT_DUE.rawValue
        case .SPFTechnicalAmountDue: // CMA-2309
            lblSubTitle.text = "Due to technical difficulties, we couldn't process your scheduled payment.\n\nPlease make a payment to keep your account up to date."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: false)
            screenTag = ScheduledPaymentFailureDetails.SCHEDULED_PAYMENT_FAILED_TECH_DIFFICULTY_AMOUNT_DUE.rawValue
            break
        case .SPFExceedLimitCardAmountDue: // CMA-2314
            //CMAIOS-2359
            let nickNameForSpotlight = cardData?.payNickName ?? "your " + strYourCC
            //
            let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourCC)
            let subtitleText = isFromSpotlight ? "Your card provider says \(nickNameForSpotlight) has reached its limit or is no longer valid.": "Your card provider says that \(nickName) has reached your credit limit, or the provider is saying the card is no longer valid."
            lblSubTitle.text = "\(subtitleText)\n\nPlease pay now with a different payment method, or contact your card provider and try again."
            //CMAIOS-2324
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: false)
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_AMOUNT_DUE.rawValue
            break
        case .SPFExceedLimitCardNoAmountDue: // CMA-2345
            //CMAIOS-2359
            //
            if isFromSpotlight {
                let nickName = cardData?.payNickName ?? "your " + strYourCC
                lblSubTitle.text = "Your card provider says \(nickName) has reached its limit or is no longer valid.\n\nPlease contact your card provider to resolve this issue."
            } else {
                //CMAIOS-2379
                let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourCC)
                lblSubTitle.text = "Your card provider says that \(nickName) has reached your credit limit, or the provider is saying the card is no longer valid.\n\nPlease contact the card provider to resolve the issue."
            }
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_NO_AMOUNT_DUE.rawValue
        case .SPFExceedLimitCheckingAmountDue: // CMA-2316
            //CMAIOS-2357
            let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourChkAcc)
            if isFromSpotlight {
                lblSubTitle.text = "Your bank says \(nickName) doesn't have enough available funds or is no longer valid.\n\nPlease use a different payment method, or contact your bank and try again."
                //CMAIOS-2324
                btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
                btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
                setCloseViewHeight(isCloseView: false)
            } else {
                //CMAIOS-2384
                if let info = historyInfo {
                    if info.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" {
                        lblSubTitle.text = "Your bank says \(nickName) doesn't have enough funds, or the bank is saying the account is no longer valid.\n\nPlease pay now with a different payment method or contact your bank to resolve this issue."
                        btnUseDiffPayment.setTitle("Make a payment", for: .normal)
                        btnChatwithus.isHidden = true
                        setCloseViewHeight(isCloseView: true)
                    } else {
                        lblSubTitle.text = "Your bank says \(nickName) doesn't have enough funds, or the bank is saying the account is no longer valid.\n\nPlease use a different payment method, or contact your bank and try again."
                        btnUseDiffPayment.setTitle("Use a different payment method", for: .normal)//CMAIOS-2278-Copy text
                        btnChatwithus.setTitle(maybeLtrBtnTitle, for: .normal)
                        setCloseViewHeight(isCloseView: false)
                    }
                }
            }
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_AMOUNT_DUE.rawValue
        case .SPFExceedLimitCheckingNoAmountDue: // CMA-2379
            //CMAIOS-2357
            let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourChkAcc)
//            let nickname = mopDetails.isMOPDataPresent ? mopDetails.nickname : mopDetails.defaultNickname
            // CMAIOS:-2648
            lblSubTitle.text = "Your bank says \(nickName) doesn't have enough available funds or is no longer valid.\n\nPlease contact your bank to resolve this issue."
            /*
            if isFromSpotlight {
                lblSubTitle.text = "Your bank says \(nickName) doesn't have enough available funds or is no longer valid.\n\nPlease contact your bank to resolve this issue."
            } else {
                lblSubTitle.text = "Your bank says \(nickName) has reached its limit or is no longer valid.\n\nPlease contact your bank to resolve this issue."
            }
             */
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_NO_AMOUNT_DUE.rawValue
        case .SPFNotValidCardAmountDue: // CMA-2312
            /*
             //CMAIOS-2359
             lblSubTitle.text =  "Looks like the card number for your \((self.checkForCardDetails())) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your card."
             
             //CMAIOS-2324
             btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
             btnChatwithus.setTitle(chatBtnTitle, for: .normal)
             setCloseViewHeight(isCloseView: true)
             */
            /*
            // CMAIOS-2653
            lblSubTitle.text = "Looks like the card number for your \((self.checkForCardDetails())) is not correct."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: true)
             */
            if let errorCode = historyInfo?.errorCode, (errorCode == "201" || errorCode == "591") {
                // CMAIOS-2653
                lblSubTitle.text = "Looks like the card number for your \((self.checkForCardDetails())) is not correct."
                btnUseDiffPayment.setTitle("Make a payment", for: .normal)
                btnChatwithus.isHidden = true
                setCloseViewHeight(isCloseView: true)
            } else {
                //CMAIOS-2359
                lblSubTitle.text =  "Looks like the card number for your \((self.checkForCardDetails())) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your card."
                //CMAIOS-2324
                btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
                btnChatwithus.setTitle(chatBtnTitle, for: .normal)
                setCloseViewHeight(isCloseView: true)
            }
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_CARD_AMOUNT_DUE.rawValue
        case .SPFNotValidCardNoAmountDue: // CMA-2347
            //CMAIOS-2250: Need data from middleware for card
            //CMAIOS-2359
            lblSubTitle.text = "Looks like the card number for your \((self.checkForCardDetails())) is not correct."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_CARD_NO_AMOUNT_DUE.rawValue
        case .SPFNotValidCheckingAmountDue: // CMA-2317 // CMA-2319
            /*
            //CMAIOS-2357
            let nickName = self.isMOPNickNameAvailable(defaultNickName: strYourChkAcc)
            lblSubTitle.text = "Looks like the routing number for your \(nickName) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your checking account."
            //CMAIOS-2324
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
             */
            /*
            // CMAIOS-2653
            lblSubTitle.text = "Looks like the routing number for your \(nickName) is not correct."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: true)
             */
            
            if let errorCode = historyInfo?.errorCode, (errorCode == "751" || errorCode == "750") {
                // CMAIOS-2653
                lblSubTitle.text = "Looks like the routing number for your \(nickName) is not correct."
                btnUseDiffPayment.setTitle("Make a payment", for: .normal)
                btnChatwithus.isHidden = true
                setCloseViewHeight(isCloseView: true)
            } else {
                //CMAIOS-2357
                let nickName = self.isMOPNickNameAvailable(defaultNickName: strYourChkAcc)
                lblSubTitle.text = "Looks like the routing number for your \(nickName) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your checking account."
                //CMAIOS-2324
                btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
                btnChatwithus.setTitle(chatBtnTitle, for: .normal)
                setCloseViewHeight(isCloseView: true)
            }
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_AMOUNT_DUE.rawValue
        case .SPFNotValidCheckingNoAmountDue: // CMA-2496
            /*
            if lastFourDigits.isEmpty {
                lblSubTitle.text = "Looks like the routing number for your checking account is not correct."
            } else {
                lblSubTitle.text = "Looks like the routing number for your checking account ending with \(lastFourDigits) is not correct."
            }
             */
            // CMAIOS-2438
            let nickName = self.isMOPNickNameAvailable(defaultNickName: strYourChkAcc)
            lblSubTitle.text = "Looks like the routing number for your \(nickName) is not correct."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
            screenTag = PaymentFailureScreen.PAYMENT_FAILED_VALIDATION_ERROR_ACH_NO_AMOUNT_DUE.rawValue
        case .SPFDuplicateAmountDue: // CMA-2383
            let paymentDetails  = self.getAmntAndPaymentDate()
            //CMAIOS-2416->CMA2413
            let middleText = isFromSpotlight ? "You made a" : "You already have a scheduled"
            lblSubTitle.text = "For your protection, we don’t allow duplicate payments within a 24 hour period.\n\n\(middleText) payment of \(paymentDetails.amnt ?? "") using \(nickName) on \(paymentDetails.paymentDate ?? "").\n\nIf you still want to make a payment, please use a different payment method or pay a different amount."
            btnChatwithus.isHidden = false
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            btnChatwithus.setTitle("Cancel", for: .normal)
            screenTag = ScheduledPaymentFailureDetails.SCHEDULED_PAYMENT_FAILED_DUPLICATE_AMOUNT_DUE.rawValue
        case .SPFDuplicateNoAmountDue: // CMA-2384
            //CMAIOS-2417
            let paymentDetails  = self.getAmntAndPaymentDate()
            let subtitleText = isFromSpotlight ? "You made a payment of \(paymentDetails.amnt ?? "") using \(nickName) on \(paymentDetails.paymentDate ?? "")" : "You already have a scheduled payment of \(paymentDetails.amnt ?? "") using \(nickName) ending in \(paymentInfo.lastFourDigits) earlier today.\n\nYou have no amount due at this time"
            lblSubTitle.text = "For your protection, we don’t allow duplicate payments within a 24 hour period.\n\n\(subtitleText)"
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            screenTag = ScheduledPaymentFailureDetails.SCHEDULED_PAYMENT_FAILED_DUPLICATE_NO_AMOUNT_DUE.rawValue
        case .none:
            let subTitleCommonText = "Due to technical difficulties, we couldn't process your scheduled payment."
            lblSubTitle.text = isFromSpotlight ?  (subTitleCommonText) + "\n\nYou have no amount due at this time." : subTitleCommonText
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        }
        if !screenTag.isEmpty {
            if screenTag == "paymentfailed_validationerror_ach_noamountdue" {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            } else {
                let custParams = [EVENT_SCREEN_NAME : screenTag, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
            }
        }
    }
    
    //CMAIOS-2413
    func getAmntAndPaymentDate()->(amnt: String?, paymentDate: String?) {
        let amntValue = isFromSpotlight ? self.cardData?.amount :  String(format: "$%.2f", self.historyInfo?.amount?.amount ?? "") //CMAIOS-2416->CMA2413
        let date = isFromSpotlight ? self.cardData?.date : self.historyInfo?.paymentDate
        let formattedDate = CommonUtility.convertDateStringFormats(dateString: date ?? "", dateFormat: "MMM. d")
        return(amntValue, formattedDate)
    }
    
    /*
    //CMAIOS-2357 check whether MOP full details are available or not....
    func isMOPNickNameAndCardDataPresent(nickName: String, lastFourDigits : String) -> (isMOPDataPresent : Bool, lastFourDigits : String, nickname : String, defaultNickname: String){
        var dynamicNickname = nickName
        var isMOPDataPresent = true
        if lastFourDigits.isEmpty || dynamicNickname.isEmpty {
            isMOPDataPresent = false
        } else {
            dynamicNickname =  "\(dynamicNickname) ending with \(lastFourDigits)"
        }
        return (isMOPDataPresent, lastFourDigits, dynamicNickname, "checking account")
    }
    */
 
    // CMAIOS-2357 check whether MOP full details are available or not....
    // CMAIOS-2438
    func isMOPNickNameAvailable(defaultNickName: String) -> String {
        /*
         var dynamicNickname = cardData?.payNickName ?? ""
         var isMOPDataPresent = true
         if lastFourDigits.isEmpty || dynamicNickname.isEmpty {
         isMOPDataPresent = false
         }
         return (isMOPDataPresent, lastFourDigits, dynamicNickname, "checking account")
         */
        //CMAIOS-2414 backup message update as per data from Spotlight Card flow or B&PH flow
        let payMethodInfo = sharedManager.getPaymentInfo(payMethod: payMethod)
        let lastFourDigits = payMethodInfo.lastFourDigits
        let nickName = isFromSpotlight ? cardData?.payNickName : payMethodInfo.nickname
        var checkingNickName = defaultNickName
        if let nicName = nickName , !nicName.isEmpty {
            checkingNickName = nicName
        } else if !lastFourDigits.isEmpty {
            checkingNickName = "\(defaultNickName) ending with \(lastFourDigits)"
        }
        return checkingNickName
    }
    
    // Refer:- CMA-2614, CMA-2605 for card details copy text changes
    // This is only for SPF failure scenario
    func checkForCardDetails(isPrefixRequired: Bool = false, uppercasePrefixNeeded: Bool = false) -> String {
        var cardDetails = !isPrefixRequired ? strYourCC : uppercasePrefixNeeded ? "Your " + strYourCC : "your " + strYourCC
        if let card = cardData, let nickName = card.payNickName, nickName.isEmpty {
            cardDetails = nickName
        } else {
            if payMethod != nil {
                return self.isMOPNickNameAvailable(defaultNickName: "your " + strYourCC)
            }
        }
        /*
         else if !lastFourDigits.isEmpty {
         cardDetails = "credit/debit card ending with \(lastFourDigits)"
         }
        */
        return cardDetails
    }

    // This is only for OTP failure scenario
    // CMA-2614
    func mopDetailsForOTPFailure(defaultNickName: String) -> String {
        let payMethod = sharedManager.getPaymentInfo(payMethod: payMethod)
        let nickNameMOP = payMethod.nickname
        var nickName = defaultNickName
        let lastFourDigits = payMethod.lastFourDigits
        if !nickNameMOP.isEmpty {
            nickName = nickNameMOP
        } else if !lastFourDigits.isEmpty {
            nickName = "\(defaultNickName) ending with \(lastFourDigits)"
        }
        return nickName
    }
    
    //
    func handleSchedulePrimaryTap(type: SPTFailErrorType)  {
        switch type {
        case .SPFExceedLimitCheckingAmountDue, .SPFExceedLimitCardAmountDue:
            if type == .SPFExceedLimitCheckingAmountDue, let info = historyInfo, info.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" {
                self.moveToMakePaymentScreen(paymethod: self.payMethod)
            } else {
                navToChoosePayment()
            }
//        case .SPFFailDefaultMOP:
//            navToChoosePayment(retryNow: true)
        case.SPFTechnicalNoAmountDue,.SPFDuplicateNoAmountDue,.SPFNotValidCardNoAmountDue, .SPFNotValidCheckingNoAmountDue, .SPFExceedLimitCardNoAmountDue, .SPFExceedLimitCheckingNoAmountDue,.SPFFailCardExpiredNoAmountDue, .none: //CMA-2310 //CMA-2347 // CMAIOS-2663
            //navigate to homeScreen on click of Okay button
            isFromSpotlight ? navToHomeVC() : navToBillingAndPaymentHistory() //CMAIOS-2415 -CMA-2412
        case.SPFTechnicalAmountDue, .SPFDuplicateAmountDue, .SPFNotValidCardAmountDue, .SPFFailCardExpired, .SPFNotValidCheckingAmountDue:
            self.verifyErrorCode(type: type)
        }
    }

    func handleScheduleSecondaryTap(type: SPTFailErrorType)  {
        switch type {
        case.SPFFailCardExpired, .SPFNotValidCheckingAmountDue, .SPFNotValidCardAmountDue:
            navToChatwithus()
        case.SPFExceedLimitCardAmountDue, .SPFExceedLimitCheckingAmountDue,  .SPFTechnicalAmountDue, .SPFDuplicateAmountDue:
            isFromSpotlight ? navToHomeVC() : navToBillingAndPaymentHistory() //CMAIOS-2416->CMA2413
//        case .SPFFailDefaultMOP:
//            self.moveToMakePaymentScreen(paymethod: self.payMethod, retryNow: true, autoTry: true)
        default:
            // fall back to billing Home.
            navToBillingHome()
        }
    }
    
    // CMAIOS-2797
    private func verifyErrorCode(type: SPTFailErrorType) {
        switch type {
        case .SPFNotValidCardAmountDue, .SPFFailCardExpired, .SPFNotValidCheckingAmountDue:
            if let errorCode = historyInfo?.errorCode, (errorCode == "201" || errorCode == "591" || errorCode == "522" || errorCode == "751" || errorCode == "750") {
                self.moveToMakePaymentScreen(paymethod: self.payMethod)
            } else {
                navToChoosePayment()
            }
        default:
            //CMAIOS-2086 nav to MakeAPaymentVC
            self.moveToMakePaymentScreen(paymethod: self.payMethod)
        }
    }
}
