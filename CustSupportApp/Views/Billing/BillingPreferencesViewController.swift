//
//  BillingPreferencesViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 08/12/23.
//

import UIKit
import Lottie
import SafariServices

class BillingPreferencesViewController: UIViewController, SFSafariViewControllerDelegate {
    private enum InfoState {
           case warning, error, none
       }
    @IBOutlet weak var billingPreferencesTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var cardExpiryAlertLabel: UILabel!
    @IBOutlet weak var cardExpiryAlertImageView: UIImageView!
    @IBOutlet weak var cardExpiryAlertView: UIView!
    var isBillingPreferencesOffForAutoPay = true
    var isBillingPreferencesOffForPaperlessBilling = true
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var qualtricsAction : DispatchWorkItem?
    var screenType: FinishSetupType = .turnOnAutoPay //CMAIOS-2550
    var signInIsProgress = false
    var isFromAllsetScreen = false
    let sharedManager = QuickPayManager.shared //CMA-2798
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.billingPreferencesTableView.register(UINib(nibName: "BillingPreferencesOffTableViewCell", bundle: nil), forCellReuseIdentifier: "BillingPreferencesCell")
        self.billingPreferencesTableView.register(UINib(nibName: "BillingPreferencesOnTableViewCell", bundle: nil), forCellReuseIdentifier: "BillingPreferencesOnCell")
        self.billingPreferencesTableView.register(UINib(nibName: "BillingSeparatorTableViewCell", bundle: nil), forCellReuseIdentifier: "BillingSeparatorCell")
//        self.billingPreferencesTableView.isScrollEnabled = false
        self.showScreenHeaderAndDiscountView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        updateUI(type: getSubViewType())
        self.initialDataSetup()
        trackEvents()
        self.addQualtrics()
        QuickPayManager.shared.setEnrolType() //CMAIOS-2496
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isBillingPreferencesOffForAutoPay, !isBillingPreferencesOffForPaperlessBilling {
            self.qualtricsAction?.cancel()
        }
    }
    
    func addQualtrics(){
        if QuickPayManager.shared.isAutoPayEnabled(), QuickPayManager.shared.isPaperLessBillingEnabled() {
            qualtricsAction = self.checkQualtrics(screenName: PaymentScreens.MYBILL_BILLING_PREFENCES_BOTH_ON.rawValue , dispatchBlock: &qualtricsAction)
        }
    }
    private func initialDataSetup() {
        if QuickPayManager.shared.isFromAutoPaySettingsView {
            self.addLoader()
            self.mauiGetBillAccountApiRequest()
        }
        isBillingPreferencesOffForAutoPay = !QuickPayManager.shared.isAutoPayEnabled()
        isBillingPreferencesOffForPaperlessBilling = !QuickPayManager.shared.isPaperLessBillingEnabled()
        if QuickPayManager.shared.isDiscountBannerEligible() {
            self.discountView.isHidden = false
            self.discountView.layer.cornerRadius = 20
            self.discountView.layer.borderWidth = 1
            self.discountView.layer.borderColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1).cgColor
        } else {
            self.discountView.isHidden = true
        }
        self.billingPreferencesTableView.reloadData()
    }
    
    func showScreenHeaderAndDiscountView() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 1.2
        if !QuickPayManager.shared.isDiscountPresent() {
            titleLabel.attributedText = NSMutableAttributedString(string: "Auto Pay and \nPaperless Billing", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            return
        }
        if QuickPayManager.shared.isAutoPayEnabled() || QuickPayManager.shared.isPaperLessBillingEnabled() {
            //CMAIOS-2534,CMAIOS-2499
            titleLabel.attributedText = NSMutableAttributedString(string: "Auto Pay and \nPaperless Billing", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            //CMAIOS-2519
            titleLabel.attributedText = NSMutableAttributedString(string: "More options", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
        if QuickPayManager.shared.isDiscountBannerEligible() {
            paragraphStyle.lineHeightMultiple = 1.24
            self.discountLabel.attributedText = NSMutableAttributedString(string: "You're getting $5 off a month by being enrolled in Auto Pay and Paperless", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
    }
    
    @IBAction func crossButtonTapped(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        if isFromAllsetScreen {
            if let billingPayment = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billingPayment, animated: true)
                }
            }
        } else {
            if ((self.navigationController?.viewControllers.last(where: { $0.isKind(of: SetUpAutoPayPaperlessBillingVC.self) })) != nil) {
                switch (titleLabel.text == "More options",
                        QuickPayManager.shared.isAutoPayEnabled(),
                        QuickPayManager.shared.isPaperLessBillingEnabled()) { //CMAIOS-2800
                case (true, true, _), (true, _, true), (false, _, _):
                    if let billingPayment = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                        DispatchQueue.main.async {
                            self.navigationController?.popToViewController(billingPayment, animated: true)
                        }
                    }
                default:
                    self.navigationController?.popViewController(animated: true)
                }
                /*
                 if let billingPayment = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController, titleLabel.text != "More options" {
                 DispatchQueue.main.async {
                 self.navigationController?.popToViewController(billingPayment, animated: true)
                 }
                 } else {
                 self.navigationController?.popViewController(animated: true)
                 }
                 */
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            /*
             self.navigationController?.popViewController(animated: true)
             */
        }
    }
    
    func convertHeaderStringToAttributed(headerText: String) -> NSMutableAttributedString {
        let attributedStr = NSMutableAttributedString.init(string:"")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        let boldFont = UIFont(name: "Regular-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 18)
        let atrText = headerText
        attributedStr.append(NSMutableAttributedString.init(string:atrText ,attributes: [NSAttributedString.Key.font : boldFont, .paragraphStyle: paragraphStyle]))
        return attributedStr
    }
    
    func convertDescStringToAttributed(descText: String) -> NSMutableAttributedString {
        let descriptionStr = NSMutableAttributedString.init(string:"")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        let font = UIFont(name: "Regular-Regular", size: 16) ?? UIFont.systemFont(ofSize: 18)
        let lineText = descText
        descriptionStr.append(NSMutableAttributedString.init(string:lineText ,attributes: [NSAttributedString.Key.font : font, .paragraphStyle: paragraphStyle]))
        return descriptionStr
    }
    
    /// Get Auto pay information
    /// - Returns: // (scheduled amount, scheduled date, card or bank account info, expiry date(only for card as payment type, bool to check card or account))
    func getAutoPayInfo() -> (String, String, String, String, Bool) {
        var autoPayInfo = ("", "", "", "", false)
        let autoPaymentInfo = QuickPayManager.shared.getAutoPayMethodMop()
        let forExpiryDate = QuickPayManager.shared.payMethodInfo(payMethod: QuickPayManager.shared.getDefaultAutoPaymentMethod())
        autoPayInfo = (QuickPayManager.shared.getStatementBalanceAmount(),
                       QuickPayManager.shared.getAutoPayScheduleDate(),
                       autoPaymentInfo.1,
                       forExpiryDate.2, autoPaymentInfo.0) //CMAIOS-2504
        return autoPayInfo
    }
    
    @objc func billingPreferencesOffAction(sender: UIButton) {
        self.qualtricsAction?.cancel()
        if sender.tag == 0 {
            navigateToChoosePayment()
        } else {
            switch sharedManager.isAutoPayEnabled() { //CMA-2798
            case true:
                guard let cell = self.billingPreferencesTableView.cellForRow(at: IndexPath(row:0, section: sender.tag)) as? BillingPreferencesOffTableViewCell else {
                    return
                }
                validatePBEmailAndAndEnroll(cell: cell)
            case false:
                self.navigateToFinishSetup()
            }
        }
    }
    
    private func navigateToChoosePayment() {
        guard QuickPayManager.shared.getAllPayMethodMop().count < 1 else {
            guard let chooseViewController = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
            chooseViewController.paymentType = self.getPayMentType()
            chooseViewController.flowType = (isBillingPreferencesOffForAutoPay && isBillingPreferencesOffForPaperlessBilling) ? .appbNotEnrolled : .autopay //CMAIOS-2712
            if isBillingPreferencesOffForAutoPay && isBillingPreferencesOffForPaperlessBilling {
                QuickPayManager.shared.enrolType = .onlyAutoPay
            }
            chooseViewController.titleHeader = "Choose a payment method for Auto Pay"
//            chooseViewController.isFromSetupAPPB = true
            chooseViewController.isFromOtpOrSPF = true
            self.navigationController?.pushViewController(chooseViewController, animated: true)
            return
        }
        self.showAddCard()
    }
    
    private func getPayMentType() -> ChoosePaymentType {
        /*
        switch self.screenType {
        case .paperless: break
        case .autoPayEnroll: break
        case .turnOnAutoPay:
            return .turnOnAutoPay
        case .turnOnAutoPayFromSpotlight:
            return .turnOnAutoPayFromSpotlight
        case .turnOnPBFromMoreOptions(let isAutoPay):
            return .turnOnPBFromMoreOptions(isAutoPay: isAutoPay)
        }
        return .none
         */
        switch self.screenType {
        case .turnOnPBFromMoreOptions(let isAutoPay):
            return .turnOnPBFromMoreOptions(isAutoPay: isAutoPay)
        default:
            if QuickPayManager.shared.isDiscountPresent() == false {
                return .turnOnPBFromMoreOptions(isAutoPay: true) // To enable the new updated screens for non-eligible accounts for auto pay setup (that includes where to send billing notifications)
            } else {
                return .turnOnAutoPayFromSpotlight
            }
        }
    }
    
    private func showAddCard() {
        // CMAIOS-2099
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = false
        viewcontroller.flow = (isBillingPreferencesOffForAutoPay && isBillingPreferencesOffForPaperlessBilling) ? .appbNotEnrolled : .autopay
        if isBillingPreferencesOffForAutoPay && isBillingPreferencesOffForPaperlessBilling {
            QuickPayManager.shared.enrolType = .onlyAutoPay
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func navigateToFinishSetup() {
        guard let viewcontroller = FinishSetupViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.screenType = .turnOnPBFromMoreOptions(isAutoPay: false) //CMAIOS-2550
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    //
    
    @objc func billingPreferencesOnAction(sender: UIControl) {
        self.qualtricsAction?.cancel()
        if sender.tag == 0 {
            if (QuickPayManager.shared.legacyAutoPayHasProblem()){
                guard let url = URL(string: ConfigService.shared.grandFatheredLink) else { return }
                let safariVC = SFSafariViewController(url: url)
                safariVC.delegate = self
                self.present(safariVC, animated: true, completion: nil)
            }
            else if QuickPayManager.shared.isRouterContainsLegacySettings {
                guard let url = URL(string: ConfigService.shared.grandFatheredLink) else { return }
                let safariVC = SFSafariViewController(url: url)
                safariVC.delegate = self
                self.present(safariVC, animated: true, completion: nil)
            }
            else {
                guard let viewcontroller = EditAutoPayViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.editScreenType = .nonGrandfatherEditAutoPay
                viewcontroller.editAutoFlow = true
                viewcontroller.isDeleteAutoPayFlow = false
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        } else {
            guard let viewcontroller = EditBillingViewController.instantiateWithIdentifier(from: .editPayments) else { return }
            viewcontroller.screenType = .editScreen // CMAIOS:- 1862
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    private func mauiGetBillAccountApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                }
                self.removeLoaderView()
                self.initialDataSetup()
                QuickPayManager.shared.isFromAutoPaySettingsView = false
            }
        })
    }
    
    private func addLoader() {
        self.view.bringSubviewToFront(loadingView)
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
    
    private func updateUI(type: InfoState) {
        cardExpiryAlertView.layer.cornerRadius = 8.0
        cardExpiryAlertView.layer.borderWidth = 1.0
        switch type {
        case .warning:
            cardExpiryAlertLabel.text = "Auto Pay card expires soon "
            cardExpiryAlertImageView.image = UIImage(named: "AlertIcon")
            cardExpiryAlertView.layer.borderColor = UIColor(named: "notificationYellow")?.cgColor
        case .error:
            cardExpiryAlertLabel.text = "Auto Pay card has expired"
            cardExpiryAlertImageView.image = UIImage(named: "error_icon")
            cardExpiryAlertView.layer.borderColor = UIColor(named: "statusRed")?.cgColor
        case .none:
            cardExpiryAlertView.isHidden = true
        }
    }
    private func getSubViewType() -> InfoState {
        let isExpired = isDefaultAutoPaymentMethodExpired()
        let expiresSoon = isDefaultAutoPaymentMethodExpiresSoon()
        switch (isExpired, expiresSoon) {
        case (true,false):
            return .error
        case (false,true):
            return .warning
        default:
            return .none
        }
    }
    private func isDefaultAutoPaymentMethodExpired() -> Bool {
        QuickPayManager.shared.getDefaultAutoPaymentMethod()?.creditCardPayMethod?.isCardExpired ?? false
    }
    private func isDefaultAutoPaymentMethodExpiresSoon() -> Bool {
        QuickPayManager.shared.getDefaultAutoPaymentMethod()?.creditCardPayMethod?.isCardExpiresSoon ?? false
    }
    private func getAutoPayDescriptionText(_ str: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString.init(string: str)
        if let range = str.range(of: "Exp") {
            let boldFont = UIFont(name: "Regular-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
            let color = UIColor(named: "notificationRed") ?? .red
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: boldFont]
            attributedString.replaceCharacters(in: NSRange(range, in: attributedString.string), with: "Expired on")
            attributedString.addAttributes(attributes, range: NSRange(range.lowerBound..., in: attributedString.string))
        }
        return attributedString
    }
    
    private func trackEvents() {
        var screenTag = ""
        switch (isBillingPreferencesOffForAutoPay, isBillingPreferencesOffForPaperlessBilling) {
        case (true,true):
            screenTag = (titleLabel.text == "More options") ? DiscountEligible.MORE_OPTIONS_AUTO_PAY_AND_PAPERLESS_BILLING.rawValue : PaymentScreens.MYBILL_BILLING_PREFENCES_BOTH_OFF.rawValue
            qualtricsAction = self.checkQualtrics(screenName: screenTag, dispatchBlock: &qualtricsAction)
        case(true,false):
            screenTag = PaymentScreens.MYBILL_BILLING_PREFENCES_PAPERLESSBILLING_ON.rawValue
            
        case (false,true):
            screenTag = PaymentScreens.MYBILL_BILLING_PREFENCES_AUTO_PAY_ON.rawValue
        default:
            screenTag = PaymentScreens.MYBILL_BILLING_PREFENCES_BOTH_ON.rawValue
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
    }
}

extension BillingPreferencesViewController {
    
    //CMAIOS-2493
    private func navigateToSetUpScreen() {
        guard let viewcontroller = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.allSetType = .turnOnPaperlessBillingBP //CMAIOS-2537
        guard let navigationControl =  self.navigationController else {
            viewcontroller.modalPresentationStyle = .fullScreen
            viewcontroller.navigationController?.navigationBar.isHidden = false
            self.present(viewcontroller, animated: true)
            return
        }
        navigationControl.navigationBar.isHidden = true
        navigationControl.pushViewController(viewcontroller, animated: true)
    }
    
    func validatePBEmailAndAndEnroll(cell: BillingPreferencesOffTableViewCell) {
        let email = sharedManager.getBillCommunicationEmail()
        if !email.isEmpty, email.isValidEmail {
            self.signInIsProgress = true
            self.signInButtonAnimation(cell: cell)
            mauiUpdateBillCommunicationPreference(cell: cell)
        } else {
            self.signInFailedAnimation(cell: cell)
            self.showErrorMessageVC()
        }
    }
    
    // MARK: - Enroll in Paperless billing Button Animations
    func signInButtonAnimation(cell: BillingPreferencesOffTableViewCell) {
        //self.signInAnimView.alpha = 0.0
        cell.lottieAnimationView.isHidden = true
        cell.letsDoItButton.isHidden = true
        UIView.animate(withDuration: 1.0) {
            cell.lottieAnimationView.isHidden = false
        }
        cell.lottieAnimationView.backgroundColor = .clear
        cell.lottieAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        cell.lottieAnimationView.loopMode = .playOnce
        cell.lottieAnimationView.contentMode = .scaleAspectFit
       // cell.lottieAnimationView.center = cell.mainView.convert(cell.mainView.center, from: cell.mainView.superview)
        cell.lottieAnimationView.animationSpeed = 1.0
        cell.lottieAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                cell.lottieAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func signInFailedAnimation(cell: BillingPreferencesOffTableViewCell) {
        self.signInIsProgress = false
        cell.lottieAnimationView.currentProgress = 3.0
        cell.lottieAnimationView.stop()
        cell.lottieAnimationView.isHidden = true
        cell.letsDoItButton.alpha = 0.0
        cell.letsDoItButton.isHidden = false
        UIView.animate(withDuration: 1.0) {
            cell.letsDoItButton.alpha = 1.0
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
    private func mauiUpdateBillCommunicationPreference(cell:BillingPreferencesOffTableViewCell) {
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
                    self.valdiateUpdateBillResponse(cell: cell)
                } else {
                    self.signInFailedAnimation(cell: cell)
                    self.showErrorMessageVC()
                    Logger.info("Update Bill Communication is \(String(describing: error))")
                }
            }
        })
    }
    
    private  func valdiateUpdateBillResponse(cell: BillingPreferencesOffTableViewCell) {
        self.signInIsProgress = false
        cell.lottieAnimationView.pause()
        cell.lottieAnimationView.play(fromProgress: cell.lottieAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
            self.navigateToSetUpScreen()
        }
    }
}

extension BillingPreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if isBillingPreferencesOffForAutoPay {
            return 263
        }
        return 178
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isBillingPreferencesOffForAutoPay {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "BillingPreferencesCell") as? BillingPreferencesOffTableViewCell {
                    cell.billingPreferencesImage.image = UIImage(named: "Auto_Pay_New")
                    cell.lottieAnimationView.isHidden = true
                    cell.letsDoItButton.isHidden = false
                    var showDiscountLabels = false
                    if !isBillingPreferencesOffForPaperlessBilling {
                        switch QuickPayManager.shared.isDiscountPresent() {
                        case false ://Discount label will not come
                            showDiscountLabels = false
                        case true: // Discount label will come
                            showDiscountLabels = true
                        }
                    }
                    if showDiscountLabels {
                        //CMAIOS-2534
                        cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "Enroll in Auto Pay in addition to Paperless Billing and get $5 off every month")
                        cell.labelDescription.isHidden = true
                    } else {
                        //CMAIOS-2519
                        cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "Enroll in Auto Pay and make your life easier")
                        cell.labelDescription.isHidden = false
                        cell.labelDescription.attributedText = convertDescStringToAttributed(descText: "We will automatically collect your amount due on the due date every month.")
                    }
                    cell.letsDoItButton.addTarget(self, action: #selector(billingPreferencesOffAction(sender:)), for: .touchUpInside)
                    cell.letsDoItButton.tag = indexPath.section
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "BillingPreferencesOnCell") as? BillingPreferencesOnTableViewCell {
                    if(QuickPayManager.shared.legacyAutoPayHasProblem()) {
                        configureCellForLegacyAutoPayProblem(cell, indexPath: indexPath)
                    }else{
                        configureCellForNormalAutoPay(cell, indexPath: indexPath)
                    }
                    cell.editControl.tag = indexPath.section
                    return cell
                }
            }
        } else {
            if isBillingPreferencesOffForPaperlessBilling {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "BillingPreferencesCell") as? BillingPreferencesOffTableViewCell {
                    cell.billingPreferencesImage.image = UIImage(named: "Paperless_Billing_New")
                    //CMAIOS-2499 Added fix for showing incorrect UI
                    cell.lottieAnimationView.isHidden = true
                    cell.letsDoItButton.isHidden = false
                    var showDiscountLabels = false
                    if !isBillingPreferencesOffForAutoPay {
                        switch QuickPayManager.shared.isDiscountPresent() {
                        case false ://Discount label will not come
                            showDiscountLabels = false
                        case true: // Discount label will come
                            showDiscountLabels = true
                        }                    }
                    if !showDiscountLabels {
                        cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "Go Paperless and save the planet!")
                        cell.labelDescription.isHidden = false
                        cell.labelDescription.attributedText = convertDescStringToAttributed(descText: "You are saving trees and our environment with no paper bills and easy online access to view your statement every month.")
                    } else {
                        cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "Enroll in Paperless Billing in addition to Auto Pay and get $5 off every month")
                        cell.labelDescription.isHidden = true
                    }
                    cell.letsDoItButton.addTarget(self, action: #selector(billingPreferencesOffAction(sender:)), for: .touchUpInside)
                    cell.letsDoItButton.tag = indexPath.section
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "BillingPreferencesOnCell") as? BillingPreferencesOnTableViewCell {
                    cell.billingPreferencesImage.image = UIImage(named: "Paperless_Billing_New")
                    cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "Thank you for using Paperless Billing")
                    cell.labelDescription.attributedText = convertDescStringToAttributed(descText: "Bills will be sent to \(QuickPayManager.shared.getBillCommunicationEmail())")
                    cell.labelDescription.isHidden = false
                    cell.editControl.setTitle("Edit paperless billing", for: .normal)
                    cell.editControl.addTarget(self, action: #selector(billingPreferencesOnAction(sender:)), for: .touchUpInside)
                    cell.editControl.tag = indexPath.section
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if isBillingPreferencesOffForAutoPay && isBillingPreferencesOffForPaperlessBilling {
                return 20
            } else if !isBillingPreferencesOffForAutoPay && !isBillingPreferencesOffForPaperlessBilling {
                return 21
            } else if !isBillingPreferencesOffForAutoPay && isBillingPreferencesOffForPaperlessBilling {
                return 10
            } else {
                return 13
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if !isBillingPreferencesOffForAutoPay && !isBillingPreferencesOffForPaperlessBilling {
                guard let contentView =  Bundle.main.loadNibNamed("BillingSeparatorTableViewCell", owner: nil, options: nil) else {
                    // xib not loaded, or its top view is of the wrong type
                    return UIView()
                }
                if let headerView = contentView.first as? BillingSeparatorTableViewCell {
                    return headerView
                } else {
                    return UIView()
                }
            } else {
                let view = UIView()
                view.backgroundColor = UIColor.clear
                return view
            }
        }
        return UIView()
    }
    
    func configureCellForLegacyAutoPayProblem(_ cell: BillingPreferencesOnTableViewCell, indexPath: IndexPath) {
        cell.billingPreferencesImage.image = UIImage(named: "warningImage")
        cell.billingPreferencesImage.contentMode = .center
        cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "There's a problem with this month's Auto Pay")
        cell.labelDescription.attributedText = NSMutableAttributedString.init(string:"")
        cell.labelDescription.isHidden = false
        cell.labelDescription.text = "Your bill this month exceeds the max limit you set for Auto Pay. Please update your Auto Pay settings."
        configureEditControlLabel(cell, withText: "Edit Auto Pay on optimum.net  ", indexPath: indexPath)
    }

    func configureCellForNormalAutoPay(_ cell: BillingPreferencesOnTableViewCell, indexPath: IndexPath) {
        cell.contentView.isUserInteractionEnabled = true
        if QuickPayManager.shared.isDiscountBannerEligible() {
            cell.viewTopConstraint.constant = 0.0
        } else {
            cell.viewTopConstraint.constant = 20.0
        }
        cell.billingPreferencesImage.image = UIImage(named: "Auto_Pay_New")
        cell.labelHeader.attributedText = convertHeaderStringToAttributed(headerText: "Thank you for using Auto Pay")
        let autoPayInfo = self.getAutoPayInfo()
        
        switch (autoPayInfo.2.isEmpty, Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 <= 0, self.autoPayInfoAvailable()) {
        case (false, true, _): // CMAIOS:-2563 //CMAIOS-2533
//            cell.labelDescription.text = "Your next Auto Pay will be collected on your next payment due date with \(autoPayInfo.2)"
            cell.labelDescription.attributedText = self.checkAndUpdateExpiryLabel(baseString: "Your next Auto Pay will be collected on your next payment due date with \(autoPayInfo.2). ", isCard: autoPayInfo.4, mopInfo: autoPayInfo.3)
            cell.labelDescription.setLineHeight(1.2)
            cell.labelDescription.isHidden = false
        case (_, true, false):
            cell.labelDescription.text = ""
            cell.labelDescription.isHidden = true
        case (_, _, false): //CMAIOS-2784
//            cell.labelDescription.text = "Your next Auto Pay will be collected on your next payment due date with \(autoPayInfo.2)"
            cell.labelDescription.attributedText = self.checkAndUpdateExpiryLabel(baseString: "Your next Auto Pay will be collected on your next payment due date with \(autoPayInfo.2). ", isCard: autoPayInfo.4, mopInfo: autoPayInfo.3)
            cell.labelDescription.setLineHeight(1.2)
            cell.labelDescription.isHidden = false
        default:
            cell.labelDescription.isHidden = false
            var descText = "$\(autoPayInfo.0) will be paid on \(autoPayInfo.1) with \(autoPayInfo.2) "
            if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0 {
                descText = "$\(QuickPayManager.shared.getCurrentAmount()) will be paid on \(autoPayInfo.1) with \(autoPayInfo.2) "
            }
            //CMAIOS-2208: Fix for Expiry date
            let expiryText = (autoPayInfo.4) ? "Exp \(autoPayInfo.3)" : ""
            descText += expiryText
            if isDefaultAutoPaymentMethodExpired() {
                cell.labelDescription.attributedText = getAutoPayDescriptionText(descText)
                cell.labelDescription.setLineHeight(1.2)
            } else {
                cell.labelDescription.attributedText = convertDescStringToAttributed(descText: descText)
            }
        }
        
        /*
        if autoPayInfo.0.isEmpty || autoPayInfo.1.isEmpty || autoPayInfo.2.isEmpty || autoPayInfo.3.isEmpty || Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 <= 0 {
            cell.labelDescription.text = ""
            cell.labelDescription.isHidden = true
        } else {
            cell.labelDescription.isHidden = false
            var descText = "$\(autoPayInfo.0) will be paid on \(autoPayInfo.1) with \(autoPayInfo.2) "
            if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0 {
                descText = "$\(QuickPayManager.shared.getCurrentAmount()) will be paid on \(autoPayInfo.1) with \(autoPayInfo.2) "
            }
            //CMAIOS-2208: Fix for Expiry date
            let expiryText = (autoPayInfo.4) ? "Exp \(autoPayInfo.3)" : ""
            descText += expiryText
            if isDefaultAutoPaymentMethodExpired() {
                cell.labelDescription.attributedText = getAutoPayDescriptionText(descText)
                cell.labelDescription.setLineHeight(1.2)
            } else {
                cell.labelDescription.attributedText = convertDescStringToAttributed(descText: descText)
            }
        }
         */
        if QuickPayManager.shared.isRouterContainsLegacySettings {
            configureEditControlLabel(cell, withText: "Edit Auto Pay on optimum.net  ", indexPath: indexPath)
        } else {
            cell.editControl.setTitle("Edit Auto Pay", for: .normal)
        }
       
        cell.editControl.addTarget(self, action: #selector(billingPreferencesOnAction(sender:)), for: .touchUpInside)
        cell.editControl.tag = indexPath.section
    }

    func configureEditControlLabel(_ cell: BillingPreferencesOnTableViewCell, withText text: String, indexPath: IndexPath) {
        let customFont = UIFont(name: "InLineIcon", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let topMargin: CGFloat = -4.0 // You can adjust this value
        let imageIcon = NSAttributedString(string: "A", attributes: [
            NSAttributedString.Key.font: customFont,
            NSAttributedString.Key.foregroundColor: energyBlueRGB,
            NSAttributedString.Key.baselineOffset: topMargin
        ])
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.append(imageIcon)
        cell.editControl.setAttributedTitle(attributedString, for: .normal)
        cell.editControl.addTarget(self, action: #selector(billingPreferencesOnAction(sender:)), for: .touchUpInside)
        cell.editControl.tag = indexPath.section
    }
    
    // CMAIOS:-2563
    private func autoPayInfoAvailable() -> Bool {
        let autoPayInfo = self.getAutoPayInfo()
        if autoPayInfo.0.isEmpty || autoPayInfo.1.isEmpty || autoPayInfo.2.isEmpty || autoPayInfo.3.isEmpty {
            return false
        }
        return true
    }
    
    // CMAIOS-2831
    private func checkAndUpdateExpiryLabel(baseString: String, isCard: Bool, mopInfo: String) -> NSAttributedString {
        var descText = baseString
        descText += ""
        if isDefaultAutoPaymentMethodExpired() {
            let expiryText = (isCard) ? "Exp \(mopInfo)" : ""
            descText += expiryText
            return getAutoPayDescriptionText(descText)
        }
        return convertDescStringToAttributed(descText: descText)
    }
}
