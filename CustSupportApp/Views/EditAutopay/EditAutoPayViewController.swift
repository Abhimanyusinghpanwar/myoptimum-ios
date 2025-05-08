//
//  EditAutoPayViewController.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 08/02/23.
//

import UIKit
import Lottie

class EditAutoPayViewController: UIViewController {
    enum EditType {
        case nonGrandfatherEditAutoPay
        case grandfatherEditAutoPay
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cardExpirationView: UIView!
    @IBOutlet weak var cardExpirationStack: UIStackView!
    @IBOutlet weak var cardExpirationLabel: UILabel!
    @IBOutlet weak var cardExpirationImage: UIImageView!
    @IBOutlet weak var updateExpirationLabel: UILabel!
    
    @IBOutlet weak var cardStack: UIStackView!
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var label_PaidWith: UILabel!
    @IBOutlet weak var image_CarType: UIImageView!
    @IBOutlet weak var label_CardType: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var changeCardButtonLabel: UIButton!
    
    @IBOutlet weak var paymentDueStack: UIStackView!
    @IBOutlet weak var label_Payment_Due: UILabel!
    @IBOutlet weak var statementBalanceStack: UIStackView!
    @IBOutlet weak var label_Amount: UILabel!
    @IBOutlet weak var label_Balance: UILabel!
    @IBOutlet weak var label_Next_Auto_Pay: UILabel!
    @IBOutlet weak var label_Send_Billing_To: UILabel!
    @IBOutlet weak var label_Email_Id: UILabel!
    @IBOutlet weak var emailTextFieldBoarderView: UIView!
    @IBOutlet weak var emailTextField: FloatLabelTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var label_Date: UILabel!
    @IBOutlet weak var turnOffAutoPayButton: CornerRoundButton!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var button_Okay: UIButton!
    @IBOutlet weak var okayButtonAnimationView: UIView!
    @IBOutlet weak var okayButtonAnimation: LottieAnimationView!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var label_LastBill: UILabel!
    @IBOutlet weak var stackAmountBalance: UIStackView!
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var anyChangesAlertLabel: UILabel!
    @IBOutlet weak var leadingCardStack: NSLayoutConstraint!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var stackviewBottomConstraint: NSLayoutConstraint!
   // var qualtricsAction : DispatchWorkItem?
   
    var isCardExpiresSoon: Bool {
        payMethod?.creditCardPayMethod?.isCardExpiresSoon == true
    }
    
    var isCardExpired: Bool {
        payMethod?.creditCardPayMethod?.isCardExpired == true
    }
    @IBOutlet weak var selectPaymentDueStack: UIStackView!
    @IBOutlet weak var selectAmountStack: UIStackView!
    @IBOutlet weak var selectTenthOfMonthView: UIView!
    @IBOutlet weak var selectDueDateOfMonthView: UIView!
    @IBOutlet weak var selectMaxAmountView: UIView!
    @IBOutlet weak var selectStatementBalanceView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    var signInIsProgress = false
    var isFromSpotLightCard = false
    var editAutoFlow = false
    let dispatchGroup = DispatchGroup()
    var errors: [String: Error?] = [:]
    var flow: flowType = .editAutoPay
    var isDeleteAutoPayFlow = false

    var enableEditing: Bool = false { // Updating the flag would change to views(Autopay landing or Edit autopay)
        didSet {
            configureUI()
        }
    }
    lazy var email: String = sharedManager.getBillCommunicationEmail()
    
    // Need to handle nil scenarios
    lazy var payMethod: PayMethod! = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
        didSet {
            configureUI()
        }
    }
    var editScreenType: EditType = .nonGrandfatherEditAutoPay
    let sharedManager = QuickPayManager.shared
    var emailIdConfirmation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        DispatchQueue.main.async {
            self.configureUI()
            /*
             if self.isFromSpotLightCard { // Expires soon flow from spotlight card, directly shows edit UI
             self.enableEditing = true
             }
             */
            self.enableEditing = true // CMAIOS:- 1862
        }
        anyChangesAlertLabel.setLineHeight(1.2)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateAutoPayFailedAnimation()
        self.emailTextField.resignFirstResponder()
        //self.qualtricsAction?.cancel()
    }
    
    private func configureUI() {
        updateAccordingAllSetType(setType: editScreenType)
        guard enableEditing else { return }
        editingModeUI()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func updateAccordingAllSetType(setType: EditType) {
        switch setType {
        case .nonGrandfatherEditAutoPay:
            configureNonGranfatherEditAutoPay()
        case .grandfatherEditAutoPay:
            configureGranfatherEditAutoPay()
        }
        updatePayMethod()
    }
    
    private func updatePayMethod() {
        let defaultPaymethod = sharedManager.payMethodInfo(payMethod: payMethod)
        //CMA-2450 to show border around the generic bank image
        self.cardView.setBorderUIForBankMOP(paymethod: payMethod)
        image_CarType.image = UIImage(named: defaultPaymethod.1)
        label_CardType.text = defaultPaymethod.0
        // CMAIOS-1264
//        if defaultPaymethod.2 == "Bank" {
//            self.expirationDateLabel.isHidden = true
//        }
//        else {
//            self.expirationDateLabel.isHidden = false
//            self.expirationDateLabel.text = "Exp.\(defaultPaymethod.2)"
//        }
        // CMAIOS-1264
    }
    
    func okayAnimation() {
        //self.signInAnimView.alpha = 0.0
        secondaryButton.isHidden = true
        self.okayButtonAnimation.isHidden = true
        self.button_Okay.isHidden = true
        UIView.animate(withDuration: 0.8) {
            //self.signInAnimView.alpha = 1.0
            self.okayButtonAnimation.isHidden = false
        }
        self.okayButtonAnimation.backgroundColor = .clear
        self.okayButtonAnimation.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.okayButtonAnimation.loopMode = .playOnce
        self.okayButtonAnimation.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.okayButtonAnimation.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.okayButtonAnimation.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func updateAutoPayFailedAnimation() {
        self.signInIsProgress = false
        secondaryButton.isHidden = false
        self.okayButtonAnimation.currentProgress = 5.0
        self.okayButtonAnimation.stop()
        self.okayButtonAnimation.isHidden = true
        self.button_Okay.alpha = 0.0
        self.button_Okay.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.button_Okay.alpha = 1.0
        }
    }
    
    @IBAction func actionOkay(_ sender: Any) {
        errors = [:] // Clear error values
        checkAndUpdateError(emailTextField, text: emailTextField.text, isEndValidation: true)
        guard emailErrorLabel.isHidden else { return }
        switch editScreenType {
        case .nonGrandfatherEditAutoPay:
//            let dispatchGroup = DispatchGroup()
//            var errors: [String: Error?] = [:]
            let handler: ((String, Error?) -> Void) = { (key, error) in
                self.errors[key] = error
            }
            if sharedManager.getBillCommunicationEmail() != emailTextField.text {
                //CMAIOS-2474
                self.emailTextField.resignFirstResponder()
                self.signInIsProgress = true
                self.okayAnimation()
                makeUpdateEmailAPI(dispatchGroup, errorHandler: handler)
            }
            if sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod?.name != payMethod.name {
                if !self.signInIsProgress {
                    self.signInIsProgress = true
                    self.okayAnimation()
                }
                makeUpdateAutoPayAPI(dispatchGroup, errorHandler: handler)
            }
            self.dispatchGroup.notify(queue: .main) { [weak self] in
                guard self?.signInIsProgress == true else { // Nothing updated dimiss the screen on save button tap
                    if self?.errors["tokenExpiry"] != nil { // CMAIOS-1461
                        return
                    }
                   // self?.enableEditing = false // CMAIOS-1250
                    self?.handleCancelButtonNavigation() //CMAIOS-2474
                    return
                }
                self?.signInIsProgress = false
                self?.okayButtonAnimation.pause()
                self?.okayButtonAnimation.play(fromProgress: self?.okayButtonAnimation.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self?.updateAutoPayFailedAnimation()
                    guard let errorrDict = self?.errors, !errorrDict.isEmpty else {
                        //CMAIOS-2786 //CMAIOS-2862
                        if self?.isDeleteAutoPayFlow == true || self?.isFromSpotLightCard == true {
                            self?.navigateToQuickPayAlert(type: .updateAutopay)
                        } else {
                            self?.handleCancelButtonNavigation() //CMAIOS-2502
                        }
                        //
                        return
                    }
                    if self?.errors["unacceptableCode"] != nil {
                        DispatchQueue.main.async {
                            self?.showErrorMessageVC()
                        }
                    }
                }
            }
        case .grandfatherEditAutoPay: break
            
        }
    }
    
    func makeUpdateEmailAPI(_ dispatchGroup: DispatchGroup, errorHandler: @escaping ((String, Error?) -> Void)) {
        dispatchGroup.enter()
        let params: [String: AnyObject]
        if var preference = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences {
            preference.update(email: emailTextField.text)
            params = (preference.dictionary as? [String: AnyObject]) ?? [:]
        } else {
            params = ["email": emailTextField.text as AnyObject]
        }
        sharedManager.mauiUpdateBillCommunicationPreference(jsonParams: params, completionHanlder: { success, value, error in
            if success {
                self.sharedManager.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences = self.sharedManager.modelQuickPayUpdateBillPrefernce?.billCommunicationPreference
            } else {
                errorHandler("unacceptableCode", error)
                Logger.info("check Response is \(String(describing: error))")
            }
            dispatchGroup.leave()
        })
    }
    
    func makeUpdateAutoPayAPI(_ dispatchGroup: DispatchGroup, errorHandler: @escaping ((String, Error?) -> Void)) {
        dispatchGroup.enter()
        guard let oldAutoPay = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay else { return }
        var autoPay = oldAutoPay
        autoPay.update(payMethod: PayMethod(name: payMethod.name))
        sharedManager.mauiUpdate(autoPay: autoPay) { result in
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
                dispatchGroup.leave()
            case let .failure(error):
                errorHandler("unacceptableCode", error)
                Logger.info("Expiration Update failed \(error.localizedDescription)")
                dispatchGroup.leave()
            }
        }
    }
    
    func configureNonGranfatherEditAutoPay() {
        image_CarType.heightAnchor.constraint(equalToConstant: 35).isActive = true
        cardBackgroundView.backgroundColor = UIColor.white
        emailTextField.isHidden = true
        titleLabel.text = "Auto Pay"
        changeCardButtonLabel.isHidden = true
        button_Okay.isHidden = true
        label_Email_Id.isHidden = false
        secondaryButton.layer.borderWidth = 0
        emailTextFieldBoarderView.isHidden = true
        editButton.isHidden = false
        buttonStack.axis = .vertical
        emailErrorLabel.isHidden = true
        turnOffAutoPayButton.isHidden = true
        selectPaymentDueStack.isHidden = true
        selectAmountStack.isHidden = true
        secondaryButton.setTitle("", for: .normal)
        self.stackviewBottomConstraint.constant = 20
        secondaryButton.setImage(UIImage(named: "closeImage") , for: .normal)
        anyChangesAlertLabel.isHidden = true
        leadingCardStack.constant = 0.0
        cardStack.spacing = 0
        label_Email_Id.text = sharedManager.getBillCommunicationEmail()
        /* CMAIOS-1639
        if let nextPayDue = sharedManager.modelListPayment?.payments?.first?.paymentDate {
            let dateString = CommonUtility.convertDateStringFormats(dateString: nextPayDue, dateFormat: "MMM. d, YYYY") // TBD
            self.label_Next_Auto_Pay.text = dateString
        } else {
            self.label_Next_Auto_Pay.text = ""
        }
         */
        self.label_Next_Auto_Pay.text = sharedManager.getAutoPayScheduleDate()
        self.label_LastBill.text = "Last bill was $" + sharedManager.getStatementBalanceAmount() //CMAIOS-2504
        upDateCardLabelEdit(expired: isCardExpired)
        if isCardExpiresSoon {
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_CARD_EXPIRES_SOON.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            cardExpirationViewAtrribute(color: UIColor(named: "notificationYellow")?.cgColor ?? UIColor.systemYellow.cgColor)
            updateExpirationLabel.text = ""
            cardExpirationImage.image = UIImage(named: "AlertIcon")
            cardExpirationLabel.text = "Card expires soon "
        } else if isCardExpired {
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_CARD_HAS_EXPIRED.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            cardExpirationViewAtrribute(color: UIColor(named: "statusRed")?.cgColor ?? UIColor.systemRed.cgColor)
            updateExpirationLabel.text = ""
            cardExpirationImage.image = UIImage(named: "error_icon")
            cardExpirationLabel.text = "Card has expired"
        } else {
            cardExpirationView.isHidden = true
        }
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_HOME_PAGE.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
       // self.qualtricsAction =  self.checkQualtrics(screenName: BillPayEvents.QUICKPAY_AUTOPAY_HOME_PAGE.rawValue, dispatchBlock: &qualtricsAction)
    }
    
    func configureGranfatherEditAutoPay() {
        image_CarType.heightAnchor.constraint(equalToConstant: 35).isActive = true
        cardBackgroundView.backgroundColor = UIColor.white
        emailTextField.isHidden = true
        titleLabel.text = "Auto Pay"
        changeCardButtonLabel.isHidden = true
        label_Email_Id.isHidden = false
        secondaryButton.layer.borderWidth = 0
        emailTextFieldBoarderView.isHidden = true
        editButton.isHidden = false
        button_Okay.isHidden = true
        emailErrorLabel.isHidden = true
        turnOffAutoPayButton.isHidden = true
        selectPaymentDueStack.isHidden = true
        selectAmountStack.isHidden = true
        secondaryButton.setTitle("", for: .normal)
        self.stackviewBottomConstraint.constant = 20
        secondaryButton.setImage(UIImage(named: "closeImage") , for: .normal)
        anyChangesAlertLabel.isHidden = true
        upDateCardLabelEdit(expired: isCardExpired)
        
        if isCardExpiresSoon {
            cardExpirationViewAtrribute(color: UIColor.systemYellow.cgColor)
            updateExpirationLabel.text = ""
        } else if isCardExpired {
            cardExpirationViewAtrribute(color: UIColor.systemRed.cgColor)
            updateExpirationLabel.text = ""
            cardExpirationImage.image = UIImage(named: "error_icon")
            cardExpirationLabel.text = "Card has expired"
        } else {
            cardExpirationView.isHidden = true
        }
    }
    
    private func upDateCardLabelEdit(expired: Bool?) {
        let defaultPaymethod = sharedManager.payMethodInfo(payMethod: payMethod)
        if let isExpired = expired, isExpired {
            self.expirationDateLabel.text = "Expired \(defaultPaymethod.2)"
            self.expirationDateLabel.textColor = UIColor(red: 0.954, green: 0.208, blue: 0.342, alpha: 1)
            self.expirationDateLabel.font = UIFont(name: "Regular-Bold", size: 16)
        } else {
            self.expirationDateLabel.textColor = .black
            self.expirationDateLabel.font = UIFont(name: "Regular-Regular", size: 16)
            if defaultPaymethod.2 == "Checking account" {
                self.expirationDateLabel.isHidden = true
            } else {
                self.expirationDateLabel.isHidden = false
                self.expirationDateLabel.text = "Exp.\(defaultPaymethod.2)"
            }
        }
    }
    
    private func cardExpirationViewAtrribute(color: CGColor) {
        updateExpirationLabel.isHidden = true
        cardExpirationView.isHidden = false
        cardExpirationView.layer.borderWidth = 1
        cardExpirationView.layer.borderColor = color
        cardExpirationView.layer.cornerRadius = 8
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        enableEditing = true
    }
    
    func editingModeUI() {
        emailTextField.setBorderColor(mode: BorderColor.deselcted_color)
        cardBackgroundView.backgroundColor = .systemGray6
        changeCardButtonLabel.isHidden = false
        editButton.isHidden = true
        label_Email_Id.isHidden = true
        emailTextField.isHidden = false
        emailErrorLabel.isHidden = true
        turnOffAutoPayButton.isHidden = false
        titleLabel.text = "Edit Auto Pay"
        updateExpirationLabel.isHidden = false
        selectPaymentDueStack.isHidden = false
        selectAmountStack.isHidden = true
        statementBalanceStack.isHidden = true
        paymentDueStack.isHidden = true
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        button_Okay.setTitle("Save", for: .normal)
        button_Okay.isHidden = false
        secondaryButton.setImage(nil, for: .normal)
        secondaryButton.setTitle("Cancel", for: .normal)
        secondaryButton.layer.borderWidth = 2.0
        secondaryButton.layer.borderColor = UIColor(red: 152/255, green: 150/255, blue: 150/255, alpha: 1).cgColor
        emailTextFieldBoarderView.isHidden = false
        secondaryButton.layer.cornerRadius = 30
        //CMAIOS-2101 close button alignment
        self.stackviewBottomConstraint.constant = UIDevice.current.hasNotch ? 43 : 35 //CMAIOS-2763, 2149: Bottom space(30 px) fix
        anyChangesAlertLabel.isHidden = false
        emailTextField.text = email
        leadingCardStack.constant = 20.0
        cardStack.spacing = 10
        if isCardExpired {

        } else if isCardExpired {
            
        }
        addExpirationTapGesture()
        switch editScreenType {
        case .grandfatherEditAutoPay:
            editingModeGrandFather()
        case .nonGrandfatherEditAutoPay:
            editingModeNonGrandFather()
        }
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_EDIT_AUTOPAY.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    //configuredata here
    private func editingModeNonGrandFather() {
        selectPaymentDueStack.isHidden = true
        selectAmountStack.isHidden = true
        
    }
    //configuredata here
    private func editingModeGrandFather() {
        configureSelectDueAndAmountViews()
        statementBalanceStack.isHidden = true
        paymentDueStack.isHidden = true
    }
    
    private func configureSelectDueAndAmountViews() {
        [selectStatementBalanceView, selectMaxAmountView,
         selectTenthOfMonthView, selectDueDateOfMonthView].forEach { view in
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemGray3.cgColor
            view.layer.cornerRadius = 10
            if [selectStatementBalanceView, selectDueDateOfMonthView].contains(view) {
                view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
    }
    
    private func addExpirationTapGesture() {
        let text = "Please update expiration date"
        let tappableText = "update expiration date"
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.didTapUpdateExpiration(_:)))
        updateExpirationLabel.attributedText = text.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 15)], and: tappableText, with: [.font: UIFont(name: "Regular-Bold", size: 15), .foregroundColor: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1)])
        updateExpirationLabel.isUserInteractionEnabled = true
        updateExpirationLabel.addGestureRecognizer(tapAction)

    }
    
    // MARK: - O dot Animation View
    private func showODotAnimation() {
        loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        loadingAnimationView.backgroundColor = .clear
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.play()
    }
    
    @IBAction func didTapSelectedAmount(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        updateSelectedView(view: view)
    }
    
    @IBAction func didTapSelectedPaymentDate(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        updateSelectedView(view: view)
    }
    
    private func updateSelectedView(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1).cgColor
        view.subviews.first(where: { $0 is UIImageView })?.isHidden = false
        let otherView: UIView
        if selectMaxAmountView == view {
            otherView = selectStatementBalanceView
            
        } else if selectStatementBalanceView == view {
            otherView = selectMaxAmountView
        } else if selectTenthOfMonthView == view {
            otherView = selectDueDateOfMonthView
        } else {
            otherView = selectTenthOfMonthView
        }
        otherView.subviews.first(where: { $0 is UIImageView })?.isHidden = true
        grayBoarderColor(view: otherView)
    }
    
    private func grayBoarderColor(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray3.cgColor
    }
    
    @objc func didTapUpdateExpiration(_ sender: UITapGestureRecognizer) {
        //self.qualtricsAction?.cancel()
        guard sender.didTapAttributedTextInLabel(label: updateExpirationLabel, targetText: "update expiration date") else { return }
        guard let vc = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
        vc.flow = .autoPay
        vc.payMethod = payMethod
        vc.successHandler = { [weak self] payMethod in
            if self?.isFromSpotLightCard == true { // CMAIOS-1361 & CMAIOS-1362
                self?.isFromSpotLightCard = false
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self?.payMethod = payMethod
                // CMAIOS-2099
                if let ediAutoPay = self?.navigationController?.viewControllers.filter({$0 is EditAutoPayViewController}).first as? EditAutoPayViewController {
                    DispatchQueue.main.async {
                        self?.navigationController?.popToViewController(ediAutoPay, animated: true)
                    }
                    return
                }
                self?.enableEditing = false
            }
        }
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func changeCardTapped(_ sender: UIButton) {
        switch self.flow {
        case .managePayments(let editAutoAutoPayFlow):
            if editAutoAutoPayFlow && QuickPayManager.shared.getAllPayMethodMop().count <= 1 {
                self.showAddCard()
            } else {
                self.navigateToChooseMop()
            }
        default:
            self.navigateToChooseMop()
        }
    }
    
    private func showAddCard() {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.flow = self.flow
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func navigateToChooseMop() {
        //self.qualtricsAction?.cancel()
        guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        vc.payMethod = payMethod
        vc.flowType = self.flow // CMAIOS:-2582
        vc.selectionHandler = { [weak self] payMethod in
            self?.payMethod = payMethod
            if let editAutoPay = self?.navigationController?.viewControllers.filter({$0.isKind(of: EditAutoPayViewController.classForCoder())}).first { //CMAIOS-2789
                self?.navigationController?.popToViewController(editAutoPay, animated: true)
            } else {
                // CMAIOS-2099
                self?.navigationController?.popViewController(animated: true)
            }

            //CMAIOS-2862
//            if self?.isFromSpotLightCard == true { // CMAIOS-1361 & CMAIOS-1362
//                self?.isFromSpotLightCard = false
//            }
        }
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true) 
    }
    
    @IBAction func didTapTurnOffAutoPay(_ sender: CornerRoundButton) {
        //self.qualtricsAction?.cancel()
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .turnOffAutoPay
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func updatePaymethod(payMethod: PayMethod?) {
        self.payMethod = payMethod
        self.configureUI()
    }
    
    func handleErrorEditAutoPay(tokenExpiry: Bool) {
        switch tokenExpiry {
        case true:
            DispatchQueue.main.async {
                self.okayButtonAnimation.currentProgress = 1.0 // To stop animation immediately to invoke error case
                self.errors["tokenExpiry"] = CustomError.tokenExpiry
                self.dispatchGroup.leave()
            }
        case false: // 500 Finish setup APIs
            DispatchQueue.main.async {
                self.okayButtonAnimation.currentProgress = 1.0 // To stop animation immediately to invoke error case
                self.errors["unacceptableCode"] = CustomError.unacceptableCode
                self.dispatchGroup.leave()
            }
        }
    }
    
    func showErrorMessageVC() {
        //self.qualtricsAction?.cancel()
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromFinishSetup = true
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_AUTOPAY_ENROLLMENT_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToQuickPayAlert(type: AllSetType) {
        guard let vc = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        vc.allSetType = type
        vc.successHandler = { [weak self] in
            switch vc.allSetType {
            case .turnOffAutoPay:
                self?.presentingViewController?.dismiss(animated: true)
            default:
                self?.navigationController?.popViewController(animated: true)
                self?.enableEditing = false
            }
            /*
             if vc.allSetType == .turnOffAutoPay {
             self?.presentingViewController?.dismiss(animated: true)
             } else {
             self?.navigationController?.popViewController(animated: true)
             self?.enableEditing = false
             }
             */
        }
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        //CMAIOS-2474
        handleCancelButtonNavigation()
    }
    
    //CMAIOS-2474
    func handleCancelButtonNavigation(){
        switch (isFromSpotLightCard, enableEditing) {
        case (true, _):
            self.dismiss(animated: true)
        case (_, false):
            if self.navigationController?.viewControllers.count ?? 0 < 2 {
                self.dismiss(animated: true)
            } else if ((self.navigationController?.viewControllers.contains(self)) != nil) {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        case (_, true):
            switch flow {
            case .managePayments(let editAutoAutoPayFlow):
                self.managePaymentsAndEditAutoPayNavigation()
            case .editAutoPay:
                self.managePaymentsAndEditAutoPayNavigation()
            default: break
            }
            
            /*
            if flow == .managePayments || flow == .editAutoPay {
                if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(managePayment, animated: true)
                    }
                } else {
                    guard self.editAutoFlow else {
                        if let payMethodRef = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
                            payMethod = payMethodRef
                        }
                        email = sharedManager.getBillCommunicationEmail()
                        self.enableEditing = false
                        self.editAutoFlow = false
                        return
                    }
                    // CMAIOS-2099
                    self.navigationController?.popViewController(animated: true)
                }
            }
             */
        }
    }
    
    private func managePaymentsAndEditAutoPayNavigation() {
        if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managePayment, animated: true)
            }
        } else {
            guard self.editAutoFlow else {
                if let payMethodRef = sharedManager.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
                    payMethod = payMethodRef
                }
                email = sharedManager.getBillCommunicationEmail()
                self.enableEditing = false
                self.editAutoFlow = false
                return
            }
            // CMAIOS-2099
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}

extension EditAutoPayViewController: UITextFieldDelegate {
    
    //CMAIOS-2706
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailErrorLabel.isHidden = true
        emailTextField.setBorderColor(mode: .selected_color)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkAndUpdateError(textField as! FloatLabelTextField, text: textField.text)
        email = textField.text ?? ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkAndUpdateError(textField as! FloatLabelTextField, text: textField.text, isEndValidation: true)
    }
    
    func checkAndUpdateError(_ textField: FloatLabelTextField, text: String?, isEndValidation: Bool = false) {
        let errorText = validateEntry(textField, text: text, isEndValidation: isEndValidation)
        emailErrorLabel?.isHidden = errorText == nil
        emailErrorLabel?.text = errorText
        let color: BorderColor = isEndValidation ? .deselcted_color : .selected_color
        textField.setBorderColor(mode: emailErrorLabel?.isHidden == true ? color : .error_color)
    }
    
    func validateEntry(_ textField: UITextField, text: String?, isEndValidation: Bool = false) -> String? {
        guard isEndValidation else { return nil }
        guard text?.isEmpty == false else {
            return "Please enter email address."
        }
        guard text?.hasSuffix(" ") == false || text?.hasPrefix(" ") == false else {
            return "Email can’t start or end with space."
            
        }
        guard let text = text else { return nil }
        
        if text.isValidEmail {
            return nil
        } else {
            return "Please enter a valid email address."
        }
    }
}

enum CustomError: Error {
    case tokenExpiry
    case unacceptableCode
}
