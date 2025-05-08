//
//  SetUpAutoPayPaperlessBillingVC.swift
//  CustSupportApp
//
//  Created by Vishali on 10/10/24.
//

import UIKit
import Lottie

let AP_PB_OFF_HEADER_TEXT = "Enroll in Auto Pay and Paperless Billing and get $5 off every month"
let AP_ON_PB_OFF_HEADER_TEXT = "Enroll in Paperless Billing in addition to Auto Pay and get $5 off every month"
let AP_OFF_PB_ON_HEADER_TEXT = "Enroll in Auto Pay in addition to Paperless Billing and get $5 off every month"
let AP_PB_OFF_SUBTITLE_TEXT = "We'll collect your amount due on your payment due date every month and you can easily access your bills online."
let AP_ON_PB_OFF_SUBTITLE_TEXT = "Cut down on paper and easily access your bills online."
let AP_OFF_PB_ON_SUBTITLE_TEXT = "We'll collect your amount due on your payment due date every month."
let ENROLL_IN_PAPERLESS_BILLING = "Enroll in Paperless Billing"
let ENROLL_IN_AUTO_PAY = "Enroll in Auto Pay"
let VIEW_MORE_OPTIONS = "View more options"
let LETS_DO_IT = "Let's do it"
let MAYBE_LATER = "Maybe later"

class SetUpAutoPayPaperlessBillingVC: UIViewController {
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    
    @IBOutlet weak var animationView: LottieAnimationView!
    //Label Outlet Connections
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var lblDescriptionTwo: UILabel!

    //Button Outlet Connections
    @IBOutlet weak var btnLetsDoIt: RoundedButton!
    @IBOutlet weak var btnMayBeLater: RoundedButton!
    @IBOutlet weak var heightCloseBottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var animationViewHeightConstraint: NSLayoutConstraint!
    
    var isFromSpotlight: Bool = false
    @IBOutlet weak var primaryButtonView: UIView!
    @IBOutlet weak var primaryButtonAnimationView: LottieAnimationView!
    var signInIsProgress = false
    let sharedManager = QuickPayManager.shared
    let isAutoPayOn = QuickPayManager.shared.isAutoPayEnabled()
    let isPaperLessBillingOn = QuickPayManager.shared.isPaperLessBillingEnabled()
    //CMAIOS-2558
    var screenTag = ""
    //
    //Color for UI and description text
    let descriptionTextColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
    let btnBorderColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblDescriptionTwo.setLineHeight(1.2)
        self.lblHeader.setLineHeight(1.2)
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        viewAnimationSetUp()
    }

    func viewAnimationSetUp() {
        self.animationView.animation = nil
        self.animationView.animation = LottieAnimation.named("Piggy-bank-discount")
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 1.0
        self.animationView.play { _ in
        }
    }
    ///Method for handling UI text and attributes
    func setUpUI() {
        switch (isFromSpotlight,isAutoPayOn, isPaperLessBillingOn) {
        case (true, false, false): //CMAIOS-2486
            setCloseViewHeight(isCloseView: false)
            btnLetsDoIt.setTitle(LETS_DO_IT, for: .normal)
            btnMayBeLater.setTitle(MAYBE_LATER, for: .normal)
            self.animationViewHeightConstraint.constant = 200
            self.lblHeader.text = AP_PB_OFF_HEADER_TEXT
            self.lblDescriptionTwo.text = AP_PB_OFF_SUBTITLE_TEXT
            QuickPayManager.shared.enrolType = .both
            screenTag = DiscountEligible.SPOTLIGHT_CARD_INTERRUPT_ENROLL_BOTH_AP_PB.rawValue
        case (true, true, false): //CMAIOS-2492
            setCloseViewHeight(isCloseView: false)
            btnLetsDoIt.setTitle(ENROLL_IN_PAPERLESS_BILLING, for: .normal)
            btnMayBeLater.setTitle(MAYBE_LATER, for: .normal)
            self.animationViewHeightConstraint.constant = 200
            self.lblHeader.text = AP_ON_PB_OFF_HEADER_TEXT
            self.lblDescriptionTwo.text = AP_ON_PB_OFF_SUBTITLE_TEXT
            QuickPayManager.shared.enrolType = .onlyPaperless
            screenTag = DiscountEligible.ADD_PAPERLESS_BILLING_GET_DISCOUNT.rawValue
        case (true, false, true): //CMAIOS-2439
            setCloseViewHeight(isCloseView: false)
            btnLetsDoIt.setTitle(ENROLL_IN_AUTO_PAY, for: .normal)
            btnMayBeLater.setTitle(MAYBE_LATER, for: .normal)
            self.animationViewHeightConstraint.constant = 200
            self.lblHeader.text = AP_OFF_PB_ON_HEADER_TEXT
            self.lblDescriptionTwo.text = AP_OFF_PB_ON_SUBTITLE_TEXT
            QuickPayManager.shared.enrolType  = .onlyAutoPay
            screenTag = DiscountEligible.ADD_AUTO_PAY_GET_DISCOUNT.rawValue
        case (false, false, false) : //CMAIOS-2498
            setCloseViewHeight(isCloseView: true)
            btnMayBeLater.setTitle(VIEW_MORE_OPTIONS, for: .normal)
            btnLetsDoIt.setTitle(LETS_DO_IT, for: .normal)
            self.animationViewHeightConstraint.constant = 170
            self.lblHeader.text = AP_PB_OFF_HEADER_TEXT
            self.lblDescriptionTwo.text = AP_PB_OFF_SUBTITLE_TEXT
            QuickPayManager.shared.enrolType = .both
            screenTag = DiscountEligible.MY_BILL_ENROLL_IN_AUTO_PAY_AND_PAPERLESS_BILLING_INTERRUPT.rawValue
        default:
            break
        }
        btnMayBeLater.layer.borderWidth = 2
        btnMayBeLater.layer.borderColor = btnBorderColor.cgColor
        if !screenTag.isEmpty {
            let custParams = [EVENT_SCREEN_NAME : screenTag, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
        }
    }
    
    //CMAIOS-2498
    func setCloseViewHeight(isCloseView: Bool) {
        heightCloseBottomViewConstraint.constant = isCloseView ? 80 : 0
        stackViewBottomConstraint.constant = isCloseView ? 10 : UIDevice.current.hasNotch ?  45 : 30
        buttonClose.isHidden = !isCloseView
        self.view.updateConstraints()
    }

    //MARK: Handle button navigations
    ///CMAIOS-2486 //CMAIOS-2498 //CMAIOS-2439
    private func navigateToChoosePayment() {
        guard QuickPayManager.shared.getAllPayMethodMop().count < 1 else {
            guard let chooseViewController = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
            chooseViewController.paymentType = .turnOnAutoPayFromSpotlight
            chooseViewController.flowType = (!isAutoPayOn && !isPaperLessBillingOn) ? .appbNotEnrolled : .autopayFromSP //CMAIOS-2712
            chooseViewController.titleHeader = "Choose a payment method for Auto Pay"
//            chooseViewController.isFromSetupAPPB = true
            self.navigationController?.pushViewController(chooseViewController, animated: true)
            return
        }
        self.showAddCard()
    }
    
    //CMAIOS-2493
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
    
    //CMAIOS-2519
    func navigateToBillingPreferencesVC() {
        guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.screenType = .turnOnPBFromMoreOptions(isAutoPay: true) //CMAIOS-2550
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    //TODO:-CMAIOS-2486,2539,2492
    func navToHomeVC() {
        if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
            self.dismiss(animated: true)
        }
    }
    
    private func showAddCard() {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = false
        viewcontroller.flow = (!isAutoPayOn && !isPaperLessBillingOn) ? .appbNotEnrolled : .autopayFromSP //CMAIOS-2712
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    // MARK: - UIButton Action
    @IBAction func btnLetsDoItTapAction(_ sender: Any) {
        switch (isFromSpotlight,isAutoPayOn, isPaperLessBillingOn) {
        case (true, false, false), (false, false, false): //CMAIOS-2486 //CMAIOS-2498 //CMAIOS-2439
            navigateToChoosePayment()
        case (true, false, true):
            CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
                eventParam: [EVENT_LINK_TEXT : DiscountEligible.ENROLL_IN_AUTO_PAY.rawValue,
                            EVENT_SCREEN_NAME: DiscountEligible.ADD_AUTO_PAY_GET_DISCOUNT.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
            )
            navigateToChoosePayment()
        case (true, true, false): //CMAIOS-2492
            //CMA-2789
            validatePBEmailAndAndEnroll()
        default:
            break
            
        }
    }
    
    @IBAction func btnMayBeLaterTapAction(_ sender: Any) {
        switch (isFromSpotlight, isAutoPayOn, isPaperLessBillingOn){
        case (true, false, false),(true, true, false): //CMAIOS-2486 //CMAIOS-2492 //CMAIOS-2439
            navToHomeVC()
        case (false,false, false): //CMAIOS-2498
            navigateToBillingPreferencesVC()
        case (true, false, true):
            CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
                eventParam: [EVENT_LINK_TEXT : DiscountEligible.AUTO_PAY_MAYBE_LATER.rawValue,
                            EVENT_SCREEN_NAME: DiscountEligible.ADD_AUTO_PAY_GET_DISCOUNT.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
            )
            navToHomeVC()
        default:
            break
        }
    }
    
    @IBAction func closeBtnTapAction(_ sender: Any) {
        //CMAIOS-2498
        self.navigationController?.popViewController(animated: true)
    }
    
    //CMAIOS-2492
    func validatePBEmailAndAndEnroll(){
        let email = sharedManager.getBillCommunicationEmail()
        if !email.isEmpty, email.isValidEmail {
            self.signInIsProgress = true
            self.signInButtonAnimation()
            mauiUpdateBillCommunicationPreference()
        } else {
            self.signInFailedAnimation()
            self.showErrorMessageVC()
        }
    }
    
    // MARK: - Enroll in Paperless billing Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.primaryButtonAnimationView.isHidden = true
        self.btnLetsDoIt.isHidden = true
        self.btnMayBeLater.isHidden = true
        UIView.animate(withDuration: 1.0) {
            self.primaryButtonAnimationView.isHidden = false
        }
        self.primaryButtonAnimationView.backgroundColor = .clear
        self.primaryButtonAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.primaryButtonAnimationView.loopMode = .playOnce
        self.primaryButtonAnimationView.animationSpeed = 1.0
        self.primaryButtonAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.primaryButtonAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.primaryButtonAnimationView.currentProgress = 3.0
        self.primaryButtonAnimationView.stop()
        self.primaryButtonAnimationView.isHidden = true
        self.btnLetsDoIt.alpha = 0.0
        self.btnMayBeLater.alpha = 0.0
        self.btnLetsDoIt.isHidden = false
        self.btnMayBeLater.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.btnLetsDoIt.alpha = 1.0
            self.btnMayBeLater.alpha = 1.0
        }
    }
    
    func showErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromFinishSetup = true
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Update Bill communication preference for updating the email id and paperless billing
    private func mauiUpdateBillCommunicationPreference() {
        var jsonParams = [String: AnyObject]()
        jsonParams["name"] = sharedManager.getAccountNam() as AnyObject?
        jsonParams["email"] = sharedManager.getBillCommunicationEmail()  as AnyObject?
        jsonParams["termsConditions"] = true as AnyObject?
        jsonParams["mailNotifyIndicator"] = true as AnyObject?
        jsonParams["paperBillIndicator"] = false as AnyObject? //CMAIOS-2492
        sharedManager.mauiUpdateBillCommunicationPreference(jsonParams: jsonParams, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Update Bill Communication Response is \(String(describing: value))", sendLog: "Update Bill Communication success")
                    self.sharedManager.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences = self.sharedManager.modelQuickPayUpdateBillPrefernce?.billCommunicationPreference
                    self.valdiateUpdateBillResponse()
                } else {
                    self.signInFailedAnimation()
                    self.showErrorMessageVC()
                    Logger.info("Update Bill Communication is \(String(describing: error))")
                }
            }
        })
    }
    
    private  func valdiateUpdateBillResponse() {
        self.signInIsProgress = false
        self.primaryButtonAnimationView.pause()
        self.primaryButtonAnimationView.play(fromProgress: self.primaryButtonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
            self.navigateToSetUpScreen()
        }
    }
    
    //CMAIOS-2492 Handle maui token expire and reauth scenarios
    func handleErrorFinishSetupPaperlessBilling(isShowErrorMessage:Bool = true) {
        self.signInFailedAnimation()
        if isShowErrorMessage{
            self.showErrorMessageVC()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
