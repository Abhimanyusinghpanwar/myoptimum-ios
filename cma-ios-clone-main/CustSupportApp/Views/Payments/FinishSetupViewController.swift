//
//  FinishSetupViewController.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 13/12/22.
//

import UIKit
import Lottie
import SafariServices

enum FinishSetupType {
    case paperless
    case autoPayEnroll
    case turnOnAutoPay
    case turnOnAutoPayFromSpotlight
    case turnOnPBFromMoreOptions(isAutoPay: Bool) //CMAIOS-2550
}

class FinishSetupViewController: BaseViewController, SFSafariViewControllerDelegate {

    @IBOutlet var email_Id: FloatLabelTextField!
    @IBOutlet weak var label_Email_Error_Msg: UILabel!
    @IBOutlet weak var button_CheckBox: UIButton!
    @IBOutlet weak var label_Tappable_Terms: UILabel!
    @IBOutlet weak var button_FinishSetup: UIButton!
    @IBOutlet weak var viewEmailTextField: UIView!
    @IBOutlet weak var sendBillingTitleLabel: UILabel!
    @IBOutlet weak var stackView_AlsoTurnOn: UIStackView!
    @IBOutlet weak var finishButtonView: UIView!
    @IBOutlet weak var finishAnimationView: LottieAnimationView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var label_SubTitle: UILabel!
    // CMAIOS-2101 constarint outlet created for buttons alignment
    @IBOutlet weak var autoPaySetupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var checkBoxStack: UIStackView!
    var flowType: flowType = .none //CMAIOS-2516, 2518
    let tapableText = FinishSetupConstants.tappableText
    var screenType: FinishSetupType = .paperless
    let sharedManager = QuickPayManager.shared
    var acceptanceTime = "2023-02-17T14:37:00-05:00"
    var signInIsProgress = false
    var termsConditionViewed = false
    var payMethod: PayMethod?

    @IBAction func actionFinishSetup(_ sender: Any) {
        guard let email = email_Id.text, email.isValidEmail else {
            setBordercolor(emailError: true)
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
//        mauiUpdateBillCommunicationPreference()
        self.verifyEnrolFlow()
    }
    
    private func verifyEnrolFlow() {
        switch screenType {
        case .turnOnAutoPayFromSpotlight:
            switch QuickPayManager.shared.enrolType {
            case .onlyAutoPay:
                self.mauiCreateAutoPay()
            case .both:
                self.mauiUpdateBillCommunicationPreference(enablePaperless: true)
            case .onlyPaperless:
                self.mauiUpdateBillCommunicationPreference(enablePaperless: true)
            case .none: break
            }
        case .turnOnPBFromMoreOptions(let isAutopPay):
            if isAutopPay {
                self.mauiCreateAutoPay()
            } else {
                self.mauiUpdateBillCommunicationPreference(enablePaperless: true)
            }
        default:
            self.mauiUpdateBillCommunicationPreference(enablePaperless: false)
        }
        
        /*
         if screenType == .turnOnAutoPayFromSpotlight {
         switch QuickPayManager.shared.enrolType {
         case .onlyAutoPay:
         self.mauiCreateAutoPay()
         case .both:
         self.mauiUpdateBillCommunicationPreference(enablePaperless: true)
         case .onlyPaperless:
         self.mauiUpdateBillCommunicationPreference(enablePaperless: true)
         case .none: break
         }
         } else {
         self.mauiUpdateBillCommunicationPreference(enablePaperless: false)
         }
         */
    }
    
    @IBAction func actionClose(_ sender: Any) {
//        self.dismiss(animated: true)
        //CMAIOS-2308
        if self.navigationController?.viewControllers.last(where: { $0.isKind(of: BillingPreferencesViewController.self) }) != nil {
            self.navigationController?.popViewController(animated: true)
        } else if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
        } else {
            if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            } else{
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func actionCheckBox(_ sender: Any) {
        if button_CheckBox.currentImage == UIImage(named: "check") {
            button_CheckBox.setImage(UIImage(named: "unCheck"), for: .normal)
        } else {
            button_CheckBox.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        // Do any additional setup after loading the view.
        configureUI()
        
        switch screenType {
        case .turnOnAutoPay:
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_ENROLL.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        case .turnOnAutoPayFromSpotlight:
            let custParams = [EVENT_SCREEN_NAME : DiscountEligible.SPOTLIGHT_CARD_BILLING_NOTIFICATIONS_ENROLL_BOTH_AP_PB.rawValue, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
        default: break
        }
        
        /*
        if screenType == .turnOnAutoPay || screenType == .turnOnAutoPayFromSpotlight  {
        if screenType == .turnOnAutoPay {
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_ENROLL.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        } else if screenType == .turnOnAutoPayFromSpotlight {
            let custParams = [EVENT_SCREEN_NAME : DiscountEligible.SPOTLIGHT_CARD_BILLING_NOTIFICATIONS_ENROLL_BOTH_AP_PB.rawValue, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
        }
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
//        if screenType == .paperless || screenType == .turnOnPBFromMoreOptions {//CMAIOS-2550
//            self.navigationController?.navigationBar.isHidden = true
//        }
        
        switch self.screenType {
        case .paperless:
            self.navigationController?.navigationBar.isHidden = true
        case .turnOnPBFromMoreOptions(let isAutoPay):
            if isAutoPay {
                self.navigationController?.navigationBar.isHidden = false
            } else {
                self.navigationController?.navigationBar.isHidden = true
            }
        case .autoPayEnroll: break
        case .turnOnAutoPay: break
        case .turnOnAutoPayFromSpotlight: break
        }
        
        // Hide navigation bar if coming from MOP Entry screen(Card/ Checking)
        switch self.flowType { // CMAIOS-2792
        case .appbNotEnrolled where !self.isNavigatedFromChooseMop():
            self.navigationController?.navigationBar.isHidden = true
        default: break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.signInFailedAnimation()
    }
    
    private func configureUI() {
        if let termsConditions = sharedManager.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences?.termsConditions {
            termsConditionViewed = termsConditions
        }
//        setBordercolor(emailError: false)
        email_Id.setBorderColor(mode: .deselcted_color)
        setTappableText()
        email_Id.delegate = self
        let overlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOutSideOfView))
        self.view?.addGestureRecognizer(overlayTapGesture)
        
        stackView_AlsoTurnOn.isHidden = false
        sendBillingTitleLabel.isHidden = true
        switch screenType {
        case .autoPayEnroll, .paperless, .turnOnAutoPay, .turnOnAutoPayFromSpotlight, .turnOnPBFromMoreOptions:
            let imageName = sharedManager.isPaperLessBillingEnabled() ? "check": "unCheck"
            button_CheckBox.setImage(UIImage(named: imageName), for: .normal)
            email_Id.text = sharedManager.getBillCommunicationEmail()
            
            switch screenType {
            case .paperless:
                stackView_AlsoTurnOn.isHidden = true
                sendBillingTitleLabel.isHidden = false
                button_FinishSetup.setTitle("Finish Paperless Billing setup", for: .normal)
                self.navigationController?.navigationBar.isHidden = true
            case .turnOnAutoPay:
                buttonClose.isHidden = true
                // CMAIOS-2101
                self.closeButtonView.isHidden = true
                self.autoPaySetupBottomConstraint.constant = UIDevice.current.hasNotch ? -18 : -48
                button_CheckBox.setImage(UIImage(named: "check"), for: .normal)
            case .turnOnAutoPayFromSpotlight:
                buttonClose.isHidden = true
                // CMAIOS-2101
                self.closeButtonView.isHidden = true
                self.autoPaySetupBottomConstraint.constant = UIDevice.current.hasNotch ? -18 : -48
                self.checkBoxStack.isHidden = true
                self.button_CheckBox.isHidden = true
                self.button_FinishSetup.setTitle("Finish setup", for: .normal)
                if QuickPayManager.shared.enrolType == .onlyAutoPay { // CMAIOS:2548
                    self.sendBillingTitleLabel.isHidden = true
                    if self.flowType == .appbNotEnrolled {
                        self.button_FinishSetup.setTitle("Finish Auto Pay setup", for: .normal)
                    }
                } else {
                    self.sendBillingTitleLabel.font = UIFont(name: "Regular-Regular", size: 18.0)//CMA-3109
                    self.sendBillingTitleLabel.isHidden = false
                    self.sendBillingTitleLabel.text = "We'll send you an email every month when your paperless statement is ready to view and your Auto Pay has gone through."
                }
            case .turnOnPBFromMoreOptions(let isAutoPay): //CMAIOS-2550 //CMAIOS-2565
                label_Title.text = "Where should we send your billing notification?"
                if isAutoPay {
                    buttonClose.isHidden = true
                    // CMAIOS-2101
                    self.closeButtonView.isHidden = true
                    self.autoPaySetupBottomConstraint.constant = UIDevice.current.hasNotch ? -18 : -48
                    self.checkBoxStack.isHidden = true
                    self.button_CheckBox.isHidden = true
                    self.button_FinishSetup.setTitle("Finish Auto Pay setup", for: .normal)
                    self.sendBillingTitleLabel.isHidden = true
                } else {
                    stackView_AlsoTurnOn.isHidden = true
                    sendBillingTitleLabel.isHidden = true
                    button_FinishSetup.setTitle("Finish Paperless Billing setup", for: .normal)
                }
            default: break
            }
            /*
            if screenType == .paperless {
                stackView_AlsoTurnOn.isHidden = true
                sendBillingTitleLabel.isHidden = false
                button_FinishSetup.setTitle("Finish Paperless Billing setup", for: .normal)
            }
            if screenType == .turnOnAutoPay {
                buttonClose.isHidden = true
                // CMAIOS-2101
                self.closeButtonView.isHidden = true
                self.autoPaySetupBottomConstraint.constant = UIDevice.current.hasNotch ? -18 : -48
                button_CheckBox.setImage(UIImage(named: "check"), for: .normal)
            }
            if screenType == .paperless {
                self.navigationController?.navigationBar.isHidden = true
            }
             */
        }
        self.updateLineHeight()
    }
    
    private func updateLineHeight() {
        self.label_Title.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.label_SubTitle.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.label_Tappable_Terms.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.sendBillingTitleLabel.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
    }
    
    private func setBordercolor(emailError: Bool) {
        if emailError {
            viewEmailTextField.layer.borderColor = UIColor(red: 243.0/255.0, green: 53.0/255.0, blue: 87.0/255.0, alpha: 1).cgColor
        } else {
            viewEmailTextField.layer.borderColor = energyBlueRGB.cgColor
        }
        label_Email_Error_Msg.isHidden = emailError ? false: true
    }
    
    private func setTappableText() {
        let text = FinishSetupConstants.termAndConitions
        guard let font = UIFont(name: FinishSetupConstants.fontRegular, size: 15) else { return }
        let linkText = NSMutableAttributedString(string: text, attributes: [.font: font])
        let termsAndCondition = (text as NSString).range(of: tapableText)
        let color =  UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0)
        linkText.addAttribute(.foregroundColor, value: color, range: termsAndCondition)
//        linkText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsAndCondition)
//        linkText.addAttribute(.underlineColor, value: color, range: termsAndCondition)
        label_Tappable_Terms.attributedText = linkText
        label_Tappable_Terms.isUserInteractionEnabled = true
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnText(_:)))
        tapgesture.numberOfTapsRequired = 1
        label_Tappable_Terms.addGestureRecognizer(tapgesture)
    }

    @objc func tappedOnText(_ gesture: UITapGestureRecognizer) {
        termsConditionViewed = true
        /* CMAIOS-511 */
        var redirectURL = ConfigService.shared.autopayTosURL + "/auto-pay"
//        if screenType == .paperless { redirectURL = ConfigService.shared.paperlessTosUrl }
        switch screenType {
        case .paperless:
            redirectURL = ConfigService.shared.paperlessTosUrl
        case .turnOnPBFromMoreOptions(let isAutoPay): //CMAIOS-2870
            if !isAutoPay {
                redirectURL = ConfigService.shared.paperlessTosUrl
            }
        default: break
        }
        guard let url = URL(string: redirectURL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    @objc func tapOutSideOfView() {
        self.view.endEditing(true)
        label_Email_Error_Msg.isHidden = true
        email_Id.setBorderColor(mode: .selected_color)
    }
    
    /// Update Bill communication preference for updating the email id and paperless billing
    /// enablePaperless it will be used for discount flow from/ Billing prefernce and spotlight
    /// Other fows paperless billiing is verified using the user selection w.r.t self.isPaperlessEnabled()
    private func mauiUpdateBillCommunicationPreference(enablePaperless: Bool = false) {
        var jsonParams = [String: AnyObject]()
        jsonParams["name"] = sharedManager.getAccountNam() as AnyObject?
        jsonParams["email"] = email_Id.text  as AnyObject?
        jsonParams["termsConditions"] = true as AnyObject?
        jsonParams["mailNotifyIndicator"] = true as AnyObject?
        jsonParams["paperBillIndicator"] = (enablePaperless == true) ?  false as AnyObject:  self.isPaperlessEnabled() as AnyObject?
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
        switch screenType {
        case .turnOnAutoPayFromSpotlight:
            switch QuickPayManager.shared.enrolType {
            case .onlyAutoPay:break
            case .both:
                self.mauiCreateAutoPay()
            case .onlyPaperless:
                self.signInIsProgress = false
                self.finishAnimationView.pause()
                self.finishAnimationView.play(fromProgress: self.finishAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.navigateToAllSet(isAutoPay: false)
                }
            case .none: break
            }
        case .paperless:
            self.signInIsProgress = false
            self.finishAnimationView.pause()
            self.finishAnimationView.play(fromProgress: self.finishAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                self.signInFailedAnimation()
                self.navigateToAllSet(isAutoPay: false)
            }
        case .turnOnPBFromMoreOptions(_):
            self.signInIsProgress = false
            self.finishAnimationView.pause()
            self.finishAnimationView.play(fromProgress: self.finishAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                self.signInFailedAnimation()
                self.navigateToAllSet(isAutoPay: false)
            }
        default:
            self.mauiCreateAutoPay()

        }
        /*
        if screenType == .turnOnAutoPayFromSpotlight {
            switch QuickPayManager.shared.enrolType {
            case .onlyAutoPay:break
            case .both:
                self.mauiCreateAutoPay()
            case .onlyPaperless:
                self.signInIsProgress = false
                self.finishAnimationView.pause()
                self.finishAnimationView.play(fromProgress: self.finishAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.navigateToAllSet(isAutoPay: false)
                }
            case .none: break
            }
        } else {
            if screenType == .paperless || screenType == .turnOnPBFromMoreOptions { //CMAIOS-2550 Fix issue of enrolling to Autopay when the user is enrolling for only PB.
                self.signInIsProgress = false
                self.finishAnimationView.pause()
                self.finishAnimationView.play(fromProgress: self.finishAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.navigateToAllSet(isAutoPay: false)
                }
            } else {
                self.mauiCreateAutoPay()
            }
        }
         */
    }
    
    /// Enrol Autopay
    private func mauiCreateAutoPay() {
        guard let jsonParam = generateParamAsPerFlow(), !jsonParam.isEmpty else {
            self.signInFailedAnimation()
            self.showErrorMessageVC()
            return
        }
        APIRequests.shared.mauiCreateAutoPayRequest(interceptor: QuickPayManager.shared.interceptor, param: jsonParam, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Create AutoPay is \(String(describing: value))", sendLog: "Create AutoPay success")
//                    self.sharedManager.tempPaymethod = nil
                    self.refreshGetAccountBill()
                } else {
                    self.signInFailedAnimation()
                    Logger.info("Create AutoPay is \(String(describing: error))")
                    self.showErrorMessageVC()
                }
            }
        })
    }
    
    // CMAIOS-2549
    private func generateParamAsPerFlow() -> [String: AnyObject]? {
        var param: [String: AnyObject]?
        param = generateJsonParam()
        /*
         switch (screenType == .turnOnAutoPayFromSpotlight,
         Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0,
         QuickPayManager.shared.getDueDate() != "") {
         case (true, true, true):
         //            param = generateJsonParamForSPFlow() // Spot Light Flow // TBD
         param = generateJsonParam()
         default:
         param = generateJsonParam()
         }
         */
        return param
    }
    
    /// refresh  mauiGetAccountBillRequest to get paymethods list
    private func refreshGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = sharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: sharedManager.interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Refresh Get Account Bill is \(String(describing: value))", sendLog: "Refresh Get Account Bill success")
                    self.sharedManager.modelQuickPayGetAccountBill = value
                }
                self.signInIsProgress = false
                self.finishAnimationView.pause()
                self.finishAnimationView.play(fromProgress: self.finishAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.navigateToAllSet(isAutoPay: true) // Uncomment the above lines for actual flow, this line for mock validation
                }
            }
        })
    }
    
    func handleErrorFinishSetupAutopay() {
        self.signInFailedAnimation()
        self.showErrorMessageVC()
    }
        
    private func generateJsonParam() -> [String: AnyObject]? {
        var jsonParams: [String: AnyObject]?
        guard let paymethodName = self.getPaymethodNameForAutoPay() else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: paymethodName)
        let autopay = CreatAutoPay.AutoPay(payMethod: payMethod)
        let createAutoPay = CreatAutoPay(parent: QuickPayManager.shared.getAccountName(), autoPay: autopay)
        do {
            let jsonData = try JSONEncoder().encode(createAutoPay)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    private func generateJsonParamForSPFlow() -> [String: AnyObject]? {
        var jsonParams: [String: AnyObject]?
        guard let paymethodName = self.getPaymethodNameForAutoPay() else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: paymethodName)
        let autopay = CreatAutoPayWithInitialPayment.AutoPay(payMethod: payMethod, initialPayAmount: AmountInfo(currencyCode: "USD", amount: Double(QuickPayManager.shared.getCurrentAmount())))
        let createAutoPayWithInitialPay = CreatAutoPayWithInitialPayment(parent: QuickPayManager.shared.getAccountName(), autoPay: autopay)
        do {
            let jsonData = try JSONEncoder().encode(createAutoPayWithInitialPay)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    // CMAIOS:-2178
    private func getPaymethodNameForAutoPay() -> String? {
        if let paymethod = self.payMethod, let paymethodName = paymethod.name {
            return paymethodName
        } else {
            if let paymethodName = QuickPayManager.shared.getPaymethodNameForAutoPaySetup() {
                return paymethodName
            }
        }
        return nil
    }
    
    ///  Gives whether the paperless billing should be enabled or diabled
    /// - Returns: enabled or disabled
    ///  If paperless is enabled, we should set paperBillIndicator as false and true in API request
    private func isPaperlessEnabled() -> Bool {
        var isEnabled = true
        if button_CheckBox.currentImage == UIImage(named: "check") {
            isEnabled = false
        }
        
        switch screenType {
        case .paperless:
            isEnabled = false
        case .turnOnPBFromMoreOptions(let isAutoPay):
            isEnabled = false
        default: break
        }
        /*
        if screenType == .paperless || screenType == .turnOnPBFromMoreOptions { // Paperless enroll from Account/ Billing/ Paperless billing
            //CMAIOS-2550 Fix issue of enrolling to Autopay when the user is enrolling for only PB.
            isEnabled = false
        }
         */
        return isEnabled
    }
    
    private func navigateToAllSet(isAutoPay: Bool) {
        guard let viewcontroller = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        // CMAIOS:- 2549
//        viewcontroller.allSetType = isAutoPay ? (isAutoPayTurnOnFlow() ? .turnOnAutoPay:  .newAutoPay) : .paperlessBilling
        viewcontroller.allSetType = self.getAllSetType(isAutoPay: isAutoPay)
        viewcontroller.flowType = self.flowType //CMAIOS-2516
        
        if payMethod != nil {  // CMAIOS-2178
            viewcontroller.payMethod = payMethod
        }
        guard let navigationControl =  self.navigationController else {
            viewcontroller.modalPresentationStyle = .fullScreen
            viewcontroller.navigationController?.navigationBar.isHidden = false
            self.present(viewcontroller, animated: true)
            return
        }
        navigationControl.navigationBar.isHidden = true
        navigationControl.pushViewController(viewcontroller, animated: true)
    }
    
    private func getAllSetType(isAutoPay: Bool) -> AllSetType {
        var allSetType: AllSetType = .paperlessBilling // Not a auto pay flow
        switch screenType {
        case .turnOnAutoPay where isAutoPay == true:
            allSetType = .turnOnAutoPay
        case .turnOnAutoPayFromSpotlight where isAutoPay == true:
            allSetType = .turnOnAutoPaySP
        case .turnOnPBFromMoreOptions(let isAutoPay):
            allSetType = .turnOnPBFromMoreOptions(isAutoPay: isAutoPay)
        default:
            if isAutoPay {
                allSetType = .newAutoPay
            }
        }
        
        /*
        switch (isAutoPay, screenType == .turnOnAutoPay, screenType == .turnOnAutoPayFromSpotlight) {
        case (true, true, _):
            allSetType = .turnOnAutoPay
        case (true, _, true):
            allSetType = .turnOnAutoPaySP
        case (true, false, _):
            allSetType = .newAutoPay
        default: break
        }
         */
        return allSetType
    }
    
    private func isAutoPayTurnOnFlow() -> Bool {
        /*
         return screenType == .turnOnAutoPay
         */
        switch screenType {
        case .turnOnAutoPay:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Finish Setup Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.finishAnimationView.isHidden = true
        self.button_FinishSetup.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.finishAnimationView.isHidden = false
        }
        self.finishAnimationView.backgroundColor = .clear
        self.finishAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.finishAnimationView.loopMode = .playOnce
        self.finishAnimationView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.finishAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.finishAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.finishAnimationView.currentProgress = 3.0
        self.finishAnimationView.stop()
        self.finishAnimationView.isHidden = true
        self.button_FinishSetup.alpha = 0.0
        self.button_FinishSetup.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.button_FinishSetup.alpha = 1.0
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
    
    private func isNavigatedFromChooseMop() -> Bool {
        guard let isMOPScreen = (self.previousViewController?.isKind(of: ChoosePaymentViewController.self)),
              isMOPScreen == true else {
            return false
        }
        return true
    }
    
}

extension FinishSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        label_Email_Error_Msg.isHidden = true
        email_Id.setBorderColor(mode: .selected_color)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkAndUpdateError(textField.text, isEndValidation: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString: NSString = ""
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            newString = updatedText as NSString
            if newString.length > 0 && newString.length <= 50 {
                checkAndUpdateError(updatedText)
            }
        }
        if newString.length > 50 {
            if let lastChar = UnicodeScalar(newString.character(at: 49)), lastChar == " " {
                return false
            }else if let firstChar = UnicodeScalar(newString.character(at: 0)), firstChar == " ", let lastChar = UnicodeScalar(newString.character(at: 1)), lastChar == " " {
                return false
            }
        }
        return newString.length <= 50
    }
    
    func checkAndUpdateError(_ text: String?, isEndValidation: Bool = false) {
        let errorText = validateInput(text, checkForEmpty: isEndValidation)
        label_Email_Error_Msg.isHidden = errorText == nil
        label_Email_Error_Msg.text = errorText
        let color: BorderColor = isEndValidation ? .deselcted_color : .selected_color
        email_Id.setBorderColor(mode: label_Email_Error_Msg.isHidden ? color : .error_color)
    }
    
    func validateInput(_ input: String?, checkForEmpty: Bool = false) -> String? {
        var message: String?
        switch checkForEmpty {
        case true:
            guard input?.isEmpty == false else {
                message = FinishSetupConstants.emptyEmailId
                return message
            }
            guard input?.isValidEmail == true else {
                message =  FinishSetupConstants.inValidEmail
                return message
            }
        case false:
            if let inputText = input, (inputText.rangeOfCharacter(from: .whitespacesAndNewlines) != nil) {
                message =  FinishSetupConstants.spaceError
                return message
            }
        }
        return message
    }
    
    private func showCancelAlertView() {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .cancelAutoPay
        viewcontroller.flowType = self.flowType //CMAIOS-2516, 2518
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
}

extension FinishSetupViewController: BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        switch buttonType {
        case .cancel:
            self.showCancelAlertView()
        case .back:
            self.navigationController?.popViewController(animated: true)
        }
    }
}

struct FinishSetupConstants {
    static let emptyEmailId = "Please enter your Email Address."
    static let inValidEmail = "Please enter a valid email address"
    static let spaceError = "Your email address can’t start or end with space."
    static let termAndConitions = "By tapping the button below, you agree to our \nTerms & Conditions"
    static let fontRegular = "Regular-Regular"
    static let tappableText = "Terms & Conditions"
}


