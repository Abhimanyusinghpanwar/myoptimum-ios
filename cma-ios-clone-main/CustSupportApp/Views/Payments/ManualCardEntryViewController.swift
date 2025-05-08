//
//  AddCardViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 12/2/22.
//

import UIKit
import SafariServices
import Lottie

enum flowType: Equatable {
    case autopay
    case addCard(navType: NavScreenType = .home)
    case paymentFailure
    case noPayments
    case managePayments(editAutoAutoPayFlow: Bool) // editAutoAutoPayFlow == true only for CMAIOS-2841 flow
    case editAutoPay
    case autopayFromSP
    case autoPayFromLetsDoIt //CMAIOS-2516, 2518
    case none //CMAIOS-2516, 2518
    case appbNotEnrolled
}

enum NavScreenType {
    case home
    case choosePayment
    case makePayment
}

class ManualCardEntryViewController: BaseViewController {
    
    var isFirstTime: Bool = true
    let tappableText = "Pay Bill Terms and Conditions"
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var name: FloatLabelTextField!
    @IBOutlet var cardNumber: FloatLabelTextField!
    @IBOutlet var expireDate: FloatLabelTextField!
    @IBOutlet var nickName: FloatLabelTextField!
    @IBOutlet var addressLineOne: FloatLabelTextField!
    @IBOutlet var addressLineTwo: FloatLabelTextField!
    @IBOutlet var city: FloatLabelTextField!
    @IBOutlet var state: FloatLabelTextField!
    @IBOutlet var zip: FloatLabelTextField!
    @IBOutlet var errorName: VerticalAlignLabel! //CMAIOS-2202
    @IBOutlet var errorCardNumber: UILabel!
    @IBOutlet var errorExpireDate: UILabel!
    @IBOutlet var errorNickName: UILabel!
    @IBOutlet var errorAddressLineOne: UILabel!
    @IBOutlet var errorAddressLineTwo: UILabel!
    @IBOutlet var errorCity: UILabel!
    @IBOutlet var errorState: UILabel!
    @IBOutlet var errorZip: UILabel!
    @IBOutlet var addressStack: UIStackView!
    @IBOutlet var errorStack: UIStackView!
    @IBOutlet var saveToAccount: UIButton!
    @IBOutlet var saveAccountStack: UIStackView!
    @IBOutlet var sameBillingAddress: UIButton!
    @IBOutlet var acceptTerms: UIButton!
    @IBOutlet var tappableLabel: UILabel!
    @IBOutlet var errorTerms: UILabel!
    @IBOutlet weak var buttonPayNow: UIButton!
    @IBOutlet weak var payOrSaveView: UIView!
    @IBOutlet weak var payAnimationView: LottieAnimationView!
    @IBOutlet weak var saveAccountButtonStack: UIStackView!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var heightNameStackView: NSLayoutConstraint!
    @IBOutlet weak var heightCardNumberStackView: NSLayoutConstraint!
    @IBOutlet weak var heightExpireDateStackView: NSLayoutConstraint!
    @IBOutlet weak var heightNickNameStackView: NSLayoutConstraint!
    @IBOutlet weak var heightAddressLineOneStackView: NSLayoutConstraint!
    @IBOutlet weak var heightAddressLineTwoStackView: NSLayoutConstraint!
    @IBOutlet weak var heightCityStackView: NSLayoutConstraint!
    @IBOutlet weak var heightStateStackView: NSLayoutConstraint!
    @IBOutlet weak var heightZipStackView: NSLayoutConstraint!
    @IBOutlet weak var heightNameView: NSLayoutConstraint!
    @IBOutlet weak var heightCardNumberView: NSLayoutConstraint!
    @IBOutlet weak var heightExpireDateView: NSLayoutConstraint!
    @IBOutlet weak var heightNickNameView: NSLayoutConstraint!
    @IBOutlet weak var heightAddressLineOneView: NSLayoutConstraint!
    @IBOutlet weak var heightAddressLineTwoView: NSLayoutConstraint!
    @IBOutlet weak var heightCityView: NSLayoutConstraint!
    @IBOutlet weak var heightStateView: NSLayoutConstraint!
    @IBOutlet weak var heightZipView: NSLayoutConstraint!
    @IBOutlet weak var heightAutoPayStackView: NSLayoutConstraint!
    @IBOutlet weak var sameAddressLabel: UILabel!
    //CMAIOS-2528
    @IBOutlet weak var btnAutoPayCheckBox: UIButton!
    @IBOutlet weak var autoPayStack: UIStackView!
    @IBOutlet weak var lblAutoPay: UILabel!
    @IBOutlet weak var lblAutoPayDesc: UILabel!
    
    var cardExpiryFlow: ExpirationFlow = .none
    
    @IBOutlet weak var nameErrorLabelHeightConstraint: NSLayoutConstraint!
    var cardInfo: CardInfo?
    let sharedManager = QuickPayManager.shared
    var signInIsProgress = false
    var createOneTimePayMethod: CreateOneTimePayment? = nil
    var flow: flowType = .addCard(navType: .home)
    var isMakePaymentFlow: Bool = false
    var schedulePaymentDate: String?
    var selectedAmount: Double = 0.0
    var isAutoPaymentErrorFlow: Bool = false    
    @IBOutlet weak var paddingHeightForView: NSLayoutConstraint!
    @IBOutlet weak var mainStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainStackView: UIStackView!
    var isAutoPayStackHidden: Bool = false
    var isNickNameEdited = false
    var updatedAutoPayMethodName = ""
    var payMethodCardInfo: CreditCardPayMethod!
    var isDefaultCard = false
    var initialBottomConstraintOnLaunch = 0.0 //CMAIOS-2763, 2149: used to keep track initial value of Bottom constraint in order to maintain space by checking/unchecking billing check box
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        showOrHideAutoPayStack()
        configureUI()
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_CARDINFO_MANUAL_ADD_CARD.rawValue,
                       CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        //CMAIOS-2763, 2149: Bottom space(30 px) fix
        mainStackViewBottomConstraint.constant =  UIDevice().hasNotch ? 0 : 30
    }
    
    //CMAIOS-2149
    func isExtraPaddingRequired() {
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            let contentSize = self.detailsScrollView.contentSize.height + self.detailsScrollView.frame.minY
            if contentSize >= currentScreenHeight {
                //when the screen is already scrollable no need of adding extra padding
                self.addRemovePadding(paddingNeeded: 0)
            } else {
                
                //when the screen is not scrollable then adding extra padding to bottom align the button
                // screen size - content size (30px is top and bottom element spacing in stack view so totalSpacing for element becomes 60px )
                self.paddingHeightForView.constant = currentScreenHeight - contentSize - 60
                self.addRemovePadding(paddingNeeded: self.paddingHeightForView.constant)
            }
        }
    }
    
    //CMAIOS-2149
    func addRemovePadding(paddingNeeded: CGFloat){
        switch paddingNeeded   {
        case paddingNeeded where paddingNeeded > 0:
            paddingHeightForView.constant = paddingNeeded + 18
            let element = mainStackView.arrangedSubviews[6]
            element.isHidden = false
        case paddingNeeded where paddingNeeded < 0:
            //CMAIOS-2763,2149 Added check to address screen specific issue to fix 30 px bottom issue
            if (currentScreenHeight == 844 || currentScreenHeight == 852)  {
                if (-4.7 ... -2.0).contains(paddingNeeded) {
                    paddingHeightForView.constant = 13
                } else {
                    paddingHeightForView.constant = 0
                }
            } else {
                paddingHeightForView.constant = 0
            }
            let element = mainStackView.arrangedSubviews[6]
            element.isHidden = false
            //CMAIOS-2763, 2149: Bottom space(30 px) fix
            mainStackViewBottomConstraint.constant =  UIDevice().hasNotch ?  10 : 0
        default :
            paddingHeightForView.constant = 0
            let element = mainStackView.arrangedSubviews[6]
            element.isHidden = true
            //CMAIOS-2763, 2149: Bottom space(30 px) fix
            mainStackViewBottomConstraint.constant =  UIDevice().hasNotch ? 10 : 30
        }
        initialBottomConstraintOnLaunch = mainStackViewBottomConstraint.constant //CMAIOS-2763, 2149
        // Force the stack view to update its layout
        mainStackView.layoutIfNeeded()
    }
    
    //CMAIOS-2528
    func showOrHideAutoPayStack() {
        switch self.flow {
        case .managePayments(let editAutoAutoPayFlow):
            if editAutoAutoPayFlow { // CMAIOS-2841
                hideUnhideAutoPayStackView(hide: true)
            } else {
                if QuickPayManager.shared.isAutoPayEnabled() {
                    hideUnhideAutoPayStackView(hide: false)
                } else {
                    hideUnhideAutoPayStackView(hide: true)
                }
            }
        default:
            hideUnhideAutoPayStackView(hide:true)
        }
    }
    
    //CMAIOS-2860 Bottom align AutoPayStackView
    func hideUnhideAutoPayStackView(hide: Bool) {
        self.heightAutoPayStackView.constant = hide ? 0 : 75.0
        UIView.animate(withDuration: 0.01) {
            self.autoPayStack.isHidden = false  // Always make stack visible first
            self.mainStackView.layoutIfNeeded()
           self.view.layoutIfNeeded()
        } completion: { _ in
            if !hide {
                self.autoPayStack.isHidden = hide  // Only unhide after animation if needed
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.isExtraPaddingRequired()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.signInFailedAnimation()
    }
    
    func configureUI() {
        self.detailsScrollView.showsVerticalScrollIndicator = false
        let text = "I have read and agree to the Pay Bill Terms and Conditions"
        let linkText = NSMutableAttributedString(string: text, attributes: [.font: UIFont(name: "Regular-Bold", size: 18)!])
        let moreInfo = (text as NSString).range(of: tappableText)
        linkText.addAttribute(.foregroundColor, value: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0), range: moreInfo)
        tappableLabel.attributedText = linkText
        saveToAccount.isSelected = true
        saveToAccount.accessibilityIdentifier = "saveCardMOP"
        acceptTerms.accessibilityIdentifier = "cardTnC"
        sameBillingAddress.isSelected = false
        errorTerms.isHidden = true
        tappableLabel.setLineHeight(1.2)
        sameAddressLabel.setLineHeight(1.2)
        errorTerms.setLineHeight(1.4)
        //CMAIOS-2528
        lblAutoPay.setLineHeight(1.2)
        lblAutoPayDesc.setLineHeight(1.4)
        [saveToAccount, acceptTerms].forEach { button in
            button.tintColor = .clear
            button.setImage(UIImage(named: "selected-check"), for: .selected)
        }
        sameBillingAddress.tintColor = .clear
        sameBillingAddress.setImage(UIImage(named: "unselected-check"), for: .normal)
        
        let fields: [FloatLabelTextField] = [name, cardNumber, expireDate, nickName, addressLineOne, addressLineTwo, city, state, zip]
        fields.forEach { field in
            field.delegate = self
            field.setBorderColor(mode: BorderColor.deselcted_color)
            field.attributedPlaceholder = NSAttributedString(
                string: field.placeholder ?? "",
                attributes: [.foregroundColor: UIColor.placeholderText])
            //CMAIOS-2763: Addressed placeholder font color on textfields without text
            field.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        }
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        acceptTerms.superview?.isHidden = !isFirstTime
        addressStack.isHidden = !sameBillingAddress.isSelected
        // CMAIOS-1245
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnText(_:)))
        tapgesture.numberOfTapsRequired = 1
        tappableLabel.addGestureRecognizer(tapgesture)

        errorStack.layer.borderColor = UIColor.init(red: 234/255, green: 0/255, blue: 42/255, alpha: 1.0).cgColor
        if cardInfo != nil {
            prefillContentIfNavigatedFromCardScanner()
        }
        /*
         if !QuickPayManager.shared.getAllPayMethodMop().isEmpty || flow != .quickpay && QuickPayManager.shared.getAllPayMethodMop().isEmpty {
         saveAccountButtonStack.isHidden = true
         updateGoogleAnalytics(defaultSave: true)
         buttonPayNow.setTitle("Save", for: .normal)
         }
         */
        uISetupForFlowType()
    }
    
    // CMAIOS-1954
/*    private func checkScrollContentHeightForShadow() {
        DispatchQueue.main.async {
//            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            let totalHeight = self.detailsScrollView.contentSize.height + self.detailsScrollView.frame.minY
            if totalHeight > self.shadowView.frame.origin.y {
                self.shadowView.addTopShadow()
            } else {
                self.shadowView.layer.shadowOpacity = 0
            }
        }
    } */
    
    private func uISetupForFlowType() {
        buttonPayNow.accessibilityIdentifier = "payNowCardAction"
        buttonPayNow.setTitle("Save", for: .normal)
        switch flow {
        case .noPayments:
            buttonPayNow.setTitle("Continue", for: .normal)
            saveAccountButtonStack.isHidden = false
            updateGoogleAnalytics(defaultSave: true)
        case .autopayFromSP, .autopay: //CMAIOS-2712
            saveAccountButtonStack.isHidden = true
            buttonPayNow.setTitle("Finish setup", for: .normal)
        case .paymentFailure:
            buttonPayNow.setTitle("Continue", for: .normal)
            saveAccountButtonStack.isHidden = false
        case .addCard:
            saveAccountButtonStack.isHidden = true
            if isMakePaymentFlow {
                buttonPayNow.setTitle("Continue", for: .normal)
                saveAccountButtonStack.isHidden = false
            }
        case .managePayments:
            saveAccountButtonStack.isHidden = true
            buttonPayNow.setTitle("Save and continue", for: .normal) // CMAIOS:-2527
        case .editAutoPay, .appbNotEnrolled: // CMAIOS-2792
            saveAccountButtonStack.isHidden = true
        case .autoPayFromLetsDoIt, .none: //CMAIOS-2516, 2518
            break
        }
    }

    private func updateGoogleAnalytics(defaultSave: Bool) {
        var event: BillPayEvents = .QUICKPAY_CARDINFO_MANUAL_SAVE_CARD
        // Google Analytics
        if defaultSave {
            event = .QUICKPAY_CARDINFO_MANUAL_SAVE_CARD
        } else {
            event = .QUICKPAY_CARDINFO_MANUAL_NO_SAVE_CARD
        }
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: event.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func prefillContentIfNavigatedFromCardScanner() {
        cardNumber.text = addSpacesToCardNumber(number: cardInfo?.cardNumber)
        if let cardUsername = cardInfo?.cardName {
            name.text = cardUsername
        }
        if let image = cardInfo?.cardImage {
            cardImage.image = UIImage(named: image)
        }
        expireDate.text = cardInfo?.expirationDate
        self.checkAndPreFillNickName()
    }
    
    private func addSpacesToCardNumber(number: String?) -> String { // CMAIOS-1245
        var modifiedNumber = ""
        if let cardNumber = number {
            var actualNumber = NSMutableString(string: cardNumber)
            actualNumber.insert(" ", at: 4)
            actualNumber.insert(" ", at: 9)
            actualNumber.insert(" ", at: 14)
            modifiedNumber = actualNumber as String
        }
        return modifiedNumber
    }
    
    @IBAction func onTapCheckAction(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
        sender.tintColor = .clear
        switch sender {
        case sameBillingAddress:
            addressStack.isHidden = !sameBillingAddress.isSelected
            nickName.returnKeyType = sender.isSelected ? .done : .next
            expireDate.returnKeyType = sender.isSelected || !saveToAccount.isSelected ? .done : .next
            clearTextFields([addressLineOne, addressLineTwo, city, state, zip])
            if sender.isSelected {
                sender.setImage(UIImage(named: "selected-check"), for: .selected)
                //CMAIOS-2763, 2149: Bottom space(30 px) fix
                mainStackViewBottomConstraint.constant =  UIDevice().hasNotch ? 10 : 30
            }  else {
                sender.setImage(UIImage(named: "unselected-check"), for: .normal)
                //CMAIOS-2763, 2149: Bottom space(30 px) fix
                mainStackViewBottomConstraint.constant =  UIDevice().hasNotch ? (checkAnyErrorLabelIsVisible() ? 10 : initialBottomConstraintOnLaunch) : 30
            }
        case saveToAccount:
            expireDate.returnKeyType = sender.isSelected ? .done : .next
            updateGoogleAnalytics(defaultSave: sender.isSelected)
        case acceptTerms:
            if sender.isSelected {
                errorTerms.isHidden = sender.isSelected
            }
        case btnAutoPayCheckBox: //CMAIOS-2528
            if sender.isSelected {
                sender.setImage(UIImage(named: "selected-check"), for: .selected)
            }  else {
                sender.setImage(UIImage(named: "unselected-check"), for: .normal)
            }
        default: break
        }
        self.adjustHeightStackViews()
    }
    
    func clearTextFields(_ fields: [FloatLabelTextField]) {
        fields.forEach { textfield in
            textfield.text = nil
            textfield.setBorderColor(mode: .deselcted_color)
            getErrorLabel(textfield)?.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.returnKeyType != .done else {
            self.view.endEditing(true)
            return true
        }
        switch textField {
        case name:
            cardNumber.becomeFirstResponder()
        case cardNumber:
            expireDate.becomeFirstResponder()
        case expireDate:
            nickName.becomeFirstResponder()
        case nickName:
            addressLineOne.becomeFirstResponder()
        case addressLineOne:
            addressLineTwo.becomeFirstResponder()
        case addressLineTwo:
            city.becomeFirstResponder()
        case city:
            state.becomeFirstResponder()
        case state:
            zip.becomeFirstResponder()
        default: break
        }
        return true
    }
    
    @IBAction func onTapLinK(_ sender: UITapGestureRecognizer) {
    }
    
    // CMAIOS-1245
    @objc func tappedOnText(_ gesture: UITapGestureRecognizer) {
        guard gesture.didTapTermsAndConditions(label: tappableLabel, targetText: tappableText), let url = URL(string: TOS_URL) else {
            return
        }
        DispatchQueue.main.async {
            let safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .overFullScreen
            self.present(safari, animated: true, completion: nil)
        }
    }
    
    // MARK: - Finish Setup Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.payAnimationView.isHidden = true
        self.buttonPayNow.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.payAnimationView.isHidden = false
        }
        self.payAnimationView.backgroundColor = .clear
        self.payAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.payAnimationView.loopMode = .playOnce
        self.payAnimationView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.payAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.payAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.payAnimationView.currentProgress = 3.0
        self.payAnimationView.stop()
        self.payAnimationView.isHidden = true
        self.buttonPayNow.alpha = 0.0
        self.buttonPayNow.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.buttonPayNow.alpha = 1.0
        }
    }
    
    private func updatePayMethodToLocalDict() {
        if QuickPayManager.shared.localSavedPaymethods == nil {
            QuickPayManager.shared.localSavedPaymethods = []
        }
        let tempPaymethod = LocalSavedPaymethod(payMethod: self.generatePaymethod(), save: saveToAccount.isSelected)
        if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.self.generatePaymethod().name }), paymethodVal.count == 0 {
            QuickPayManager.shared.localSavedPaymethods?.append(tempPaymethod)
        }
    }
}

extension ManualCardEntryViewController: UITextFieldDelegate {
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        //CMAIOS-2214 show error message if any until the user taps out of the field and the field has loss of focus
        guard let textField1 = textField as? FloatLabelTextField else { return }
        if [zip, addressLineOne, addressLineTwo, city, state, name, expireDate, nickName, cardNumber].contains(textField1) {
            checkAndUpdateError(textField1, text: textField1.text, isEndValidation: true)
        }
        if !isNickNameEdited {
            self.checkAndPreFillNickName()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = getMaxLength(textField)
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if let textField = textField as? FloatLabelTextField, !updatedText.isEmpty && updatedText.count <= maxLength {
                // Autoformat Expiration Date
                if textField == expireDate {
                    textField.text = formatExpirationDate(updateText: updatedText, isBackspace: string.isEmpty)
                    return false
                }
                
                // Autoformat Card Number
                if textField == cardNumber { // CMAIOS-1245
                    var currentPosition = 0
                    if let selectedRange = textField.selectedTextRange {
                        let position = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                        currentPosition = validateCursorPosition(text: text, newString: string, position: position)
                    }
                    
                    textField.text = formatCardNumber(updateText: updatedText, isBackspace: string.isEmpty)
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    return false
                }
            } else if textField == cardNumber && updatedText.isEmpty {
                cardImage.image = UIImage(named: "Credit")
            }
            
            if textField == nickName && !isNickNameEdited {
                isNickNameEdited = true
            }
            
            return updatedText.count <= maxLength
        }
        return true
    }
    
    func formatExpirationDate(updateText: String, isBackspace: Bool) -> String {
        var text = updateText
        if !isBackspace {
            if updateText.count == 2 {
                text.append("/")
            } else if updateText.count == 3 && updateText.range(of: "/") == nil {
                var format = String(updateText.dropLast())
                format.append("/")
                text = format + updateText.suffix(1)
            }
        } else if updateText.count == 3 && isBackspace && updateText.hasSuffix("/") {
            text = String(text.dropLast())
        }
        return text
    }
    
    func formatCardNumber(updateText: String, isBackspace: Bool) -> String { // CMAIOS-1245
        var text = updateText
        if !isBackspace {
            switch updateText.count {
            case 4, 9, 14:
                text.append(" ")
            case 5, 10, 15:
                if !updateText.hasSuffix(" ") {
                    var format = String(updateText.dropLast())
                    format.append(" ")
                    text = format + updateText.suffix(1)
                }
            default: break
            }
        } else if isBackspace && updateText.hasSuffix(" ") {
            text = String(updateText.dropLast())
        }
        text = reArrangeCardNumber(number: text)
        return text
    }
    
    func checkAndUpdateError(_ textField: FloatLabelTextField, text: String?, isEndValidation: Bool = false) {
        let errorText = validateEntry(textField, text: text, isEndValidation: isEndValidation)
        if errorText != nil {
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_CARDINFO_MANUAL_INFO_ERROR.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
        let errorTitle = getErrorLabel(textField)
        errorTitle?.isHidden = errorText == nil
        errorTitle?.text = errorText
        let color: BorderColor = isEndValidation ? .deselcted_color : .selected_color
        adjustHeightStackViews()
        textField.setBorderColor(mode: errorTitle?.isHidden == true ? color : .error_color)
        //CMAIOS-2763, 2149: Bottom space(30 px) fix
        mainStackViewBottomConstraint.constant =  UIDevice().hasNotch ? 10 : 30
    }
    
    func reArrangeCardNumber(number: String) -> String {
        let numberstr = number.removeFormatSpaces
        let formatted = numberstr.inserting(" ", every: 4)
        return formatted
    }
    
    func validateCursorPosition(text: String, newString: String, position: Int) -> Int {
        var currentPosition = position
        if(newString == "") {
            switch currentPosition {
            case 6, 11, 16:
                currentPosition = currentPosition - 2
            default:
                if(currentPosition != 1) {
                    currentPosition = currentPosition - 1
                }
            }
        } else {
            switch currentPosition {
            case 4, 9, 14:
                currentPosition = currentPosition + 2
            default:
                currentPosition = currentPosition + 1
            }
        }
        return currentPosition
    }
    
    func getErrorLabel(_ textField: UITextField) -> UILabel? {
        switch textField {
        case name:
            return errorName
        case cardNumber:
            return errorCardNumber
        case expireDate:
            return errorExpireDate
        case nickName:
            return errorNickName
        case addressLineOne:
            return errorAddressLineOne
        case addressLineTwo:
            return errorAddressLineTwo
        case city:
            return errorCity
        case state:
            return errorState
        case zip:
            return errorZip
        default: return nil
        }
    }
    
    func getMaxLength(_ textField: UITextField) -> Int {
        switch textField {
        case name:
            return 100
        case cardNumber:
            return 19
        case expireDate:
            return 5
        case nickName:
            return 15
        case addressLineOne:
            return 32
        case addressLineTwo:
            return 32
        case city:
            return 14
        case state:
            return 2
        case zip:
            return 5
        default: return 100
        }
    }
    
    func getMinLength(_ textField: UITextField) -> Int? {
        switch textField {
        case cardNumber: return 16
        case state: return 2
        case zip: return 5
        case expireDate: return 5
        default: return nil
        }
    }
    
    func getDisplay(_ textField: UITextField) -> String {
        switch textField {
        case name:
            return "Name on Card"
        case cardNumber:
            return "Card Number"
        case expireDate:
            return "Expiration date"
        case nickName:
            return "Nickname"
        case addressLineOne:
            return "Address"
        case addressLineTwo:
            return "Address line 2"
        case city:
            return "City"
        case state:
            return "State"
        case zip:
            return "Zip code"
        default: return ""
        }
    }
    
    func checkAndPreFillNickName() {
        if errorCardNumber.isHidden, let cardNumber = cardNumber.text?.removeFormatSpaces, let cardType = CreditCardValidator.cardType(cardNumber: cardNumber), let text = nickName.text, text.isEmpty {
            clearTextFields([nickName])
            nickName.text = "\(cardType.cardName)-\(cardNumber.suffix(4))"
        }
    }
    
    func validateEntry(_ textField: UITextField, text: String?, isEndValidation: Bool = false) -> String? {
        if textField == addressLineTwo, textField.text?.isEmpty == true {
            return nil
        }
        let fieldName = getDisplay(textField)
        guard text?.isEmpty == false || !isEndValidation else {
            let prefix = textField == nickName ? "a" : "the"
            return "Please enter \(prefix) \(fieldName.lowercased())."
        }
        guard text?.hasSuffix(" ") == false || text?.hasPrefix(" ") == false else {
            return "\(fieldName) can’t start or end with space."
            
        }
        guard let text = text else { return nil }
        let minLength = getMinLength(textField)
        switch textField {
        case cardNumber:
            var cardNumberText = text.replacingOccurrences(of: " ", with: "")
            if !cardNumberText.isNumbersOnly {
                return "\(fieldName) should contain only numbers."
            } else {
                let type =  CreditCardValidator.cardType(cardNumber: cardNumberText)
                if let type = type {
                    cardImage.image = UIImage(named: type.cardImage)
                } else {
                    cardImage.image = UIImage(named: "Credit")
                }
                guard cardNumberText.count >= type?.minimumLength ?? 6 else {
                    guard isEndValidation else {
                        return nil
                    }
                    return "This is not a valid \(fieldName.lowercased()). Please try again"
                }
                guard CreditCardValidator.isValidNumber(cardNumber: cardNumberText, includeRegexValidation: true) else { return "This is not a valid \(fieldName.lowercased()). Please try again" }
            }
        case zip:
            if isEndValidation && text.isEmpty {
                return "Please enter the zip code"
            } else if !text.isNumbersOnly {
                    return "\(fieldName) should contain only numbers."
            } else {
                if let length = minLength, text.count != minLength {
                    return "\(fieldName) should contain minimum \(length) numbers."
                }
            }
        case expireDate:
            if text.count == minLength && !text.isValidExpireDate {
                return "\(fieldName) should be in MM/YY format."
            }
            guard text.count == minLength else { return nil }
            if !creditCardPastDateValidation(text: text) {
                return "\(fieldName) can’t be in the past"
            }
        case state:
            if isEndValidation && text.isEmpty {
                return "Please enter the state"
            } else {
                if !text.isValidState || text.count != minLength {
                    return "\(fieldName) should contain two letters."
                }
            }
        case name:
            if !text.validateName {
                return "\(fieldName) only contain letters of the alphabet and spaces"
            }
        case city:
            if isEndValidation && text.isEmpty {
                return "Please enter the city"
            } else {
                if !text.validateName {
                    return "\(fieldName) only contain letters of the alphabet and spaces"
                }
            }
        case addressLineOne:
            if isEndValidation && text.isEmpty {
                return "Please enter the address"
            }
        case nickName: 
            if QuickPayManager.shared.checkingNameExists(newName: text) == true {
                return "One of your payment methods is already using this nickname."
            }
        default:
            return nil
        }
        return nil
    }
    
    func adjustHeightStackViews() {
        adjustHeightForErrorLabel(errorLabel: errorName, stackViewHeight: heightNameStackView, viewHeight: heightNameView)
        adjustHeightForErrorLabel(errorLabel: errorCardNumber, stackViewHeight: heightCardNumberStackView, viewHeight: heightCardNumberView)
        adjustHeightForErrorLabel(errorLabel: errorExpireDate, stackViewHeight: heightExpireDateStackView, viewHeight: heightExpireDateView)
        adjustHeightForErrorLabel(errorLabel: errorNickName, stackViewHeight: heightNickNameStackView, viewHeight: heightNickNameView)
        adjustHeightForErrorLabel(errorLabel: errorAddressLineOne, stackViewHeight: heightAddressLineOneStackView, viewHeight: heightAddressLineOneView)
        adjustHeightForErrorLabel(errorLabel: errorAddressLineTwo, stackViewHeight: heightAddressLineTwoStackView, viewHeight: heightAddressLineTwoView)
        adjustHeightForErrorLabel(errorLabel: errorCity, stackViewHeight: heightCityStackView, viewHeight: heightCityView)
        adjustHeightForErrorLabel(errorLabel: errorState, stackViewHeight: heightStateStackView, viewHeight: heightStateView)
        adjustHeightForErrorLabel(errorLabel: errorZip, stackViewHeight: heightZipStackView, viewHeight: heightZipView)
    }
    
    func adjustHeightForErrorLabel(errorLabel: UILabel, stackViewHeight: NSLayoutConstraint, viewHeight: NSLayoutConstraint) {
        if errorLabel.isHidden {
            stackViewHeight.constant = 62
        } else {
            viewHeight.constant = 62
//            stackViewHeight.constant = 99
           if errorLabel == errorName { //CMAIOS-2202
                if errorName.actualNumberOfLines == 2 {
                    errorName.verticalAlignment = .middle
                    self.nameErrorLabelHeightConstraint.constant = 32 //(2 Lines Height )
                    stackViewHeight.constant = 99
                }else {
                    errorName.verticalAlignment = .top
                    self.nameErrorLabelHeightConstraint.constant = 16 //(Single Line Height)
                    stackViewHeight.constant = 83
                }
           } else if errorLabel == errorNickName {
               if errorNickName.text == "One of your payment methods is already using this nickname." {
                   stackViewHeight.constant = 99
               } else {
                   stackViewHeight.constant = 83
               }
           } else {
                stackViewHeight.constant = 83
            }
        }
    }

    @IBAction func onTapAction() {
        view.endEditing(true)
        let errors: [UILabel] = [errorName, errorCardNumber, errorExpireDate, errorNickName, errorAddressLineTwo, errorAddressLineOne, errorCity, errorState, errorZip, errorTerms]
        var requiredFields: [FloatLabelTextField] = [name, cardNumber, expireDate]
        requiredFields.append(nickName)
        if sameBillingAddress.isSelected {
            requiredFields.append(contentsOf: [addressLineOne, addressLineTwo, city, state, zip])
        }
        
        requiredFields.forEach { field in
            checkAndUpdateError(field, text: field.text, isEndValidation: true)
        }
        if acceptTerms.superview?.isHidden == false || acceptTerms.isSelected == false {
            errorTerms.isHidden = acceptTerms.isSelected
        }
        adjustHeightStackViews() // Adjust the height of the stack view
        guard errors.first(where: { !$0.isHidden }) == nil else {
            return
        }
        addCardOrOneTimePayment()
    }
    
    //CMAIOS-2763, 2149: Check if any inline error exists
    func checkAnyErrorLabelIsVisible()->Bool{
        let errors: [UILabel] = [errorName, errorCardNumber, errorExpireDate, errorNickName, errorAddressLineTwo, errorAddressLineOne, errorCity, errorState, errorZip, errorTerms]
        guard errors.first(where: { !$0.isHidden }) == nil else {
            return true
        }
        return false
    }
    
    /*
    private func addCardOrOneTimePayment() {
        //        if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
        //            createOneTimePayment()
        //        }
        if QuickPayManager.shared.getAllPayMethodMop().isEmpty && flow != .quickpay {
            createPayment(isDefault: true)
        } else if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
            createOneTimePayment()
        } else {
            createPayment()
        }
    }
     */
    
    private func addCardOrOneTimePayment() {
        if isCardExpDateAfterSchedulePaymentDate() {
            self.newCardExpDateErrorScreen(flow: .newCardDateExpired)
            return
        }
        
        switch flow {
        case .noPayments:
            if saveToAccount.isSelected {
                createPayment(isDefault: true)
            } else {
                self.moveToMakePayment()
            }
        case .addCard:
            if isMakePaymentFlow {
                if saveToAccount.isSelected {
                    createPayment(isDefault: cardExpiryFlow == .onlyDefaultExpired ? true : false)
                } else {
                    if cardExpiryFlow == .onlyDefaultExpired {
                        self.moveToMakePaymentForExpiryFlow()
                    } else {
                        self.updatePayMethodToLocalDict()
                        self.moveToHomeViewController()
                    }
                }
            } else {
                createPayment(isDefault: false)
            }
        case .paymentFailure: break
//            self.moveToMakePayment()
        case .autopay, .autopayFromSP, .appbNotEnrolled:
            createPayment(isDefault: true)
        case .managePayments,.editAutoPay : //CMAIOS-2528
            if saveToAccount.isSelected {
                createPayment(isDefault: true)
            } else {
                createPayment(isDefault: false)
            }
        case .autoPayFromLetsDoIt, .none:
            break
        }
    }
    
    //CMAIOS-2712
    private func mauiCreateAutoPay() {
        guard let jsonParam = generateParamAsPerFlow(), !jsonParam.isEmpty else {
            self.signInFailedAnimation()
            self.showErrorMsgOnPaymentFailure()
            return
        }
        APIRequests.shared.mauiCreateAutoPayRequest(interceptor: QuickPayManager.shared.interceptor, param: jsonParam, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Create AutoPay is \(String(describing: value))", sendLog: "Create AutoPay success")
                    self.refreshGetAccountBill()
                } else {
                    self.signInFailedAnimation()
                    Logger.info("Create AutoPay is \(String(describing: error))")
                    self.showErrorMsgOnPaymentFailure()
                }
            }
        })
    }
    
    private func navigateToAllSet() {
        guard let viewcontroller = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        // CMAIOS:- 2549
//        viewcontroller.allSetType = isAutoPay ? (isAutoPayTurnOnFlow() ? .turnOnAutoPay:  .newAutoPay) : .paperlessBilling
        viewcontroller.allSetType = .turnOnAutoPaySP
        
        if let autoPayMethod = QuickPayManager.shared.getDefaultAutoPaymentMethod() {
            viewcontroller.payMethod = autoPayMethod
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
    
    private func generateJsonParamForAutoPay() -> [String: AnyObject]? {
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
    
    private func generateParamAsPerFlow() -> [String: AnyObject]? {
        return generateJsonParamForAutoPay()
    }
    
    private func getPaymethodNameForAutoPay() -> String? {
        if let paymethodName = QuickPayManager.shared.getPaymethodNameForAutoPaySetup() {
            return paymethodName
        }
        return nil
    }
    
    private func isCardExpDateAfterSchedulePaymentDate() -> Bool {
        var isCardExpDateAfterSchedulePaymentDate = false
        guard let schedulePaymentDate = self.schedulePaymentDate else {
            return isCardExpDateAfterSchedulePaymentDate
        }
        let newCardDateString = CommonUtility.convertExpireDateStringToResponseFormat(dateString: expireDate.text ?? "")
        let formattedDueDate = newCardDateString?.components(separatedBy: "T")
        let newCardDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDueDate?[0] ?? "")
        let calenderSelectedDate = getOnlyMonthYearDate(paymentDate: schedulePaymentDate)
        if calenderSelectedDate.checkIfPaymentDateIsSelectedAfterCardExpirationDate(cardExpirationDate: newCardDate) {
            isCardExpDateAfterSchedulePaymentDate = true
        }
        return isCardExpDateAfterSchedulePaymentDate
    }
    
    private func getOnlyMonthYearDate(paymentDate: String) -> Date {
        let formattedScheduleDate = paymentDate.components(separatedBy: "T")
        let calenderSelectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedScheduleDate[0])
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        let newFormart = formatter.string(from: calenderSelectedDate)
        
        let finalFormat = CommonUtility.convertExpireDateStringToResponseFormat(dateString: newFormart)
        let formattedfinalDate = finalFormat?.components(separatedBy: "T")
        let requiredDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedfinalDate?[0] ?? "")
        return requiredDate
    }
    
    private func newCardExpDateErrorScreen(flow: ExpirationFlow) {
        let cardExpiredVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "CardExpiredNotifyVC") as CardExpiredNotifyVC
        cardExpiredVC.payMethod = self.generatePaymethod()
        cardExpiredVC.cardExpiryFlow = flow
        cardExpiredVC.schedulePaymentDate = schedulePaymentDate
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(cardExpiredVC, animated: true)
    }
    
    /// Creating new Payment Method
    private func createPayment(isDefault: Bool = false) {
        let parms = generateJsonParam(isOneTimePayment: false)
        let jsonParams = parms.0
        if jsonParams.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiCreatePayment(jsonParams: jsonParams, isDefault: isDefault) { isSuccess, errorDesc, error in
            if isSuccess {
                if QuickPayManager.shared.modelQuickPayCreatePayment?.responseInfo?.statusCode == "00000" {
//                    self.signInIsProgress = false
//                    self.payAnimationView.pause()
//                    self.payAnimationView.play(fromProgress: self.payAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
//                        self.signInFailedAnimation()
                        self.processCreatePaymentReponse(cardInfo: parms.1, isDefault: isDefault)
//                    }
                } else {
                    self.signInFailedAnimation()
                    self.showErrorMsgOnPaymentFailure()
                }
            } else {
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    /*
    /// Segregate the Create payment reponse (first time or not)
    /// - Parameters:
    ///   - cardInfo: Payment would be updated to model
    ///   - isDefault: (save + default) or only save
    private func processCreatePaymentReponse(cardInfo: CreditCardPayMethod, isDefault: Bool) {
        let cardDict = updateMaskedNumber(cardInfo: cardInfo)
        if isDefault {
            if flow == .paymentFailure {
                self.navigateAfterPaymenthodCreation(cardInfo: cardDict)
            } else {
                // AutoPay Enrol
                self.signInIsProgress = false
                self.payAnimationView.pause()
                self.payAnimationView.play(fromProgress: self.payAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.sharedManager.tempPaymethod = nil
                    self.sharedManager.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = PayMethod(name: self.sharedManager.getAccountName() + "/paymethods/" + (self.nickName.text ?? ""), creditCardPayMethod: cardDict, bankEftPayMethod: nil)
                    //                        self.sharedManager.mauiGetAccountBillRequest()
                    self.navigateToFinishSetup()
                }
            }
        } else {
            self.navigateAfterPaymenthodCreation(cardInfo: cardDict)
        }
    }
     */
    
    // Segregate the Create payment reponse (first time or not)
    /// - Parameters:
    ///   - cardInfo: Payment would be updated to model
    ///   - isDefault: (save + default) or only save
    private func processCreatePaymentReponse(cardInfo: CreditCardPayMethod, isDefault: Bool) {
        let cardDict = updateMaskedNumber(cardInfo: cardInfo)
        switch flow {
        case .noPayments:
            self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault)
        case .addCard:
            self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault)
        case .paymentFailure: break
        case .autopay, .autopayFromSP, .appbNotEnrolled:
            self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault)
        case .managePayments:
            /* self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault) */
            //CMAIOS-2858
            switch (QuickPayManager.shared.isAutoPayEnabled(), self.btnAutoPayCheckBox.isSelected) {
            case (true, true):
                let paymethod = PayMethod(name: QuickPayManager.shared.getAccountName() + "/paymethods/" + (self.nickName.text ?? ""), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
                self.makeUpdateAutoPayAPI(payMethod: paymethod, cardInfo: cardDict, isDefault: isDefault)
            default:
                self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault)
            }
        case .editAutoPay:
            //CMAIOS-2858
            /*
            if self.btnAutoPayCheckBox.isSelected {//CMAIOS-2528
                let paymethod = PayMethod(name: QuickPayManager.shared.getAccountName() + "/paymethods/" + (self.nickName.text ?? ""), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
                self.makeUpdateAutoPayAPI(payMethod: paymethod, cardInfo: cardDict, isDefault: isDefault)
            } else {
                self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault)
            }
             */
            self.navigateAfterPaymenthodCreation(cardInfo: cardDict, isDefault: isDefault)
        case .autoPayFromLetsDoIt, .none:
            break
        }
        
    }
    
    //CMAIOS-2528
    func makeUpdateAutoPayAPI(payMethod: PayMethod, cardInfo: CreditCardPayMethod, isDefault: Bool) {
        guard let oldAutoPay = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay else { return }
        var autoPay = oldAutoPay
        updatedAutoPayMethodName = payMethod.name?.lastPathComponent ?? ""
        payMethodCardInfo = cardInfo
        isDefaultCard = isDefault
        autoPay.update(payMethod: PayMethod(name: payMethod.name))
        QuickPayManager.shared.mauiUpdate(autoPay: autoPay) { result in
            switch result {
            case .success(let autoPay):
                if let index = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.firstIndex(where: {$0.name == payMethod.name}), payMethod.name != QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name {
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.remove(at: index)
               }
                if oldAutoPay.payMethod?.name != QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name, let paymethod = oldAutoPay.payMethod {
                    if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                        QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                    }
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
                }
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay = autoPay
                self.navigateAfterPaymenthodCreation(cardInfo:cardInfo, isDefault: isDefault)
            case let .failure(error):
                Logger.info("Expiration Update failed \(error.localizedDescription)")
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure(isAutoPayFailure: true, payMethodName: payMethod.name?.lastPathComponent ?? "")
            }
        }
    }
        
    private func navigateAfterPaymenthodCreation(cardInfo: CreditCardPayMethod, isDefault: Bool, isFromFailure: Bool = false) {
        var params = [String: AnyObject]()
        var cardPayMethod: PayMethod!
        params["name"] = sharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    let nickName = self.nickName.text?.trimExtraWhiteLeadingTrailingSpaces()
                    let paymethod = PayMethod(name: self.sharedManager.getAccountName() + "/paymethods/" + (nickName ?? ""), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
                    if !isDefault {
                        if let paymethodVal = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.filter({ $0.name == paymethod.name }), paymethodVal.count == 0 {
                            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                            }
                            QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
                        }
                    }
                    cardPayMethod = paymethod
                    self.updatePaymethodForNoCardFlow(payMethod: paymethod) // CMAIOS-1953 & CMAIOS-2177
                }
//                self.verifyAndUpdatePayMethod(cardInfo: cardInfo) // CMAIOS-1860
                //CMAIOS-2712
                if isFromFailure, !self.updatedAutoPayMethodName.isEmpty {
                    self.signInFailedAnimation()
                    self.showErrorMsgOnPaymentFailure(isAutoPayFailure: true)
                    return
                }
                switch self.flow{
                case .autopay, .autopayFromSP:
                    self.mauiCreateAutoPay()
                default:
                    self.signInIsProgress = false
                    self.payAnimationView.pause()
                    self.payAnimationView.play(fromProgress: self.payAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self.signInFailedAnimation()
    //                    self.moveToHomeViewController(isOneTimePayment: false, payMethod: nil)
                        self.navigateToSuccessScreen(cardPayMethod)
                    }
                }
            }
        })
    }
    
    private func updatePaymethodForNoCardFlow(payMethod: PayMethod?) {
        guard let payMethodRef = payMethod else {
            return
        }
        switch (self.flow == .noPayments, self.saveToAccount.isSelected, self.flow == .autopay || self.flow == .autopayFromSP || self.flow == .appbNotEnrolled) {
        case (_, _, true), (true, true, _):
            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == nil {
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = payMethodRef
            }
        default: break
        }
        /*
         if self.flow == .noPayments && self.saveToAccount.isSelected {
         if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == nil {
         QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = payMethodRef
         }
         }
         */
    }

    private func verifyAndUpdatePayMethod(cardInfo: CreditCardPayMethod) {
        let paymethodName = self.sharedManager.getAccountName() + "/paymethods/" + (self.nickName.text ?? "")
        let paymethod = PayMethod(name: paymethodName, creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
        
        switch flow {
        case .noPayments:
            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == nil {
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = paymethod
            }
        case .addCard:
            if let paymethodVal = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.filter({ $0.name == paymethodName }), paymethodVal.count == 0 {
                if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                }
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
            }
        case .paymentFailure: break
        case .autopay, .autopayFromSP, .appbNotEnrolled:
            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == nil {
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = paymethod
            }
        case .managePayments: break
        case .editAutoPay,.autoPayFromLetsDoIt, .none:
            break
        }
    }
    
    private func generatePaymethod() -> PayMethod {
        let paymethodName = self.sharedManager.getAccountName() + "/paymethods/" + (self.nickName.text ?? "")
        let paymethod = PayMethod(name: paymethodName, creditCardPayMethod: self.generateJsonForFirstTimeCard()?.creditCardPayMethod, bankEftPayMethod: nil)
//        if let paymethodVal = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.filter({ $0.name == paymethodName }), paymethodVal.count == 0 {
//            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
//                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
//            }
//            QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
//        }
        return paymethod
    }
    
    private func navigateToSuccessScreen(_ paymethod: PayMethod? = nil) {
        switch flow {
        case .noPayments:
            self.moveToMakePayment()
        case .addCard(let type):
            handleAddCardNavigation(type: type)
        case .paymentFailure: break
        case .autopay, .autopayFromSP:
            self.navigateToFinishSetup(screenType: (flow == .autopay) ? .turnOnAutoPay : .turnOnAutoPayFromSpotlight)
        case .appbNotEnrolled:
            self.navigateToFinishSetup(screenType: (flow == .autopay) ? .turnOnAutoPay : .turnOnAutoPayFromSpotlight, paymethod: paymethod)
        case .managePayments(let editAutoAutoPayFlow): //CMAIOS-2858 //CMAIOS-2841
            if editAutoAutoPayFlow { //CMAIOS-2841
                self.moveToEditAutoPay(paymethod)
            } else {
                DispatchQueue.main.async {
                    self.moveManagePayments()
                }
                /*
                if !self.btnAutoPayCheckBox.isSelected {
                    if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                        DispatchQueue.main.async {
                            self.moveManagePayments()
                        }
                    } else {
                        handleAddCardNavigation(type: .home)
                    }
                } else {
                    self.moveManagePayments()
                }
                 */
            }
        case .editAutoPay://CMAIOS-2858
            if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                DispatchQueue.main.async {
                    self.moveManagePayments()
                }
            } else {
                handleAddCardNavigation(type: .home)
            }
        case .autoPayFromLetsDoIt, .none:
            break
        }
    }
    
    func handleAddCardNavigation(type: NavScreenType) {
        switch type {
        case .makePayment:
            self.moveToMakePayment()
        default:
            self.moveToHomeViewController()
        }
    }
    
    private func moveToMakePayment() {
        if QuickPayManager.shared.getCurrentAmount() == "" && selectedAmount == 0 { // CMAIOS-2164
            if !saveToAccount.isSelected {
                self.updatePayMethodToLocalDict()
            }
            self.enterAmountScreen()
            return
        }
        
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        if !saveToAccount.isSelected {
            self.updatePayMethodToLocalDict()
            makePayVC.firstTimeCardFlow = true
            makePayVC.tempPaymethod = self.generatePaymethod()
        }
        if selectedAmount != 0 {
            makePayVC.updatedAmount = selectedAmount.description
        }
        makePayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
    // CMAIOS-2305
    private func moveManagePayments() {
        if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managePayment, animated: true)
            }
        } else {
            guard let vc = ManagePaymentsViewController.instantiateWithIdentifier(from: .billing) else { return }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // CMAIOS-2841
    private func moveToEditAutoPay(_ paymethod: PayMethod? = nil) {
        if let editAutoPay = self.navigationController?.viewControllers.filter({$0 is EditAutoPayViewController}).first as? EditAutoPayViewController {
            DispatchQueue.main.async {
                editAutoPay.payMethod = paymethod
            }
            self.navigationController?.popToViewController(editAutoPay, animated: true)
        } else  if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managePayment, animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func enterAmountScreen() {
        let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
        enterPayVC.payMethod = self.generatePaymethod()
        enterPayVC.flowType = flow // CMAIOS-2230
        enterPayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.pushViewController(enterPayVC, animated: true)
    }

    /// Refresh Get Account bill
    private func refreshGetAccountBill() { //CMAIOS-2712
        var params = [String: AnyObject]()
        params["name"] = sharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                }
                self.signInIsProgress = false
                self.payAnimationView.pause()
                self.payAnimationView.play(fromProgress: self.payAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.navigateToAllSet()
                }
            }
        })
    }
    
    /*
    private func navigateAfterPaymenthodCreation(cardInfo: CreditCardPayMethod) {
        //        let paymethod = PayMethod(name: self.sharedManager.getAccountName() + "/paymethods/" + (self.nickName.text ?? ""), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
        //        if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
        //            QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
        //        }
        //        QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
        //        self.moveToHomeViewController(isOneTimePayment: false, payMethod: nil)
        var params = [String: AnyObject]()
        params["name"] = sharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                } else {
                    let paymethod = PayMethod(name: self.sharedManager.getAccountName() + "/paymethods/" + (self.nickName.text ?? ""), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
                    if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                        QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                    }
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
                }
                self.signInIsProgress = false
                self.payAnimationView.pause()
                self.payAnimationView.play(fromProgress: self.payAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.moveToHomeViewController(isOneTimePayment: false, payMethod: nil)
                }
            }
        })
    }
     */
    
    /// Create One Time payment
    private func createOneTimePayment() {
        if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 <= 0 {
            return
        }
        let (jsonParams, cardInfo) = generateJsonParam(isOneTimePayment: true)
//        let jsonParams = generateJsonParam(isOneTimePayment: true).0
        if jsonParams.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiOneTimePaymentRequest(jsonParams: jsonParams, isDefault: saveToAccount.isSelected) { isSuccess, errorDesc, error in
            if isSuccess {
                if self.sharedManager.modelQuickPayOneTimePayment?.responseInfo?.statusCode != "00000" {
                    self.signInFailedAnimation()
                    self.showThanksPayment(paymentState: .oneTimePaymentFailure, paymentJson: jsonParams)
                } else {
                    self.refreshGetAccountBill()
                }
            } else {
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    
    // Create Schedule Payment with new card
    private func createScheduledPaymentWithNewCard() {
        if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 <= 0 {
            return
        }
        let jsonParams = generateJsonParamForSchedule()
        if jsonParams.isEmpty {
            return
        }
        QuickPayManager.shared.mauiSchedulePaymentWithNewCard(jsonParams: jsonParams, isDefault: saveToAccount.isSelected) { isSuccess, errorDesc, error in
            if isSuccess {
                if self.sharedManager.modelSchedulePaymentNewCard?.responseInfo?.statusCode != "00000" {
                } else {
                }
            } else {
            }
        }
    }
    
    private func updateMaskedNumber(cardInfo: CreditCardPayMethod) -> CreditCardPayMethod {
        let cardDict = CreditCardPayMethod(nameOnCard: cardInfo.nameOnCard,
                                           maskedCreditCardNumber: (cardNumber.text?.removeFormatSpaces ?? "").getTrimmedString(isPrefix: false, length: 4),
                                           cardType: cardInfo.cardType,
                                           methodType: cardInfo.methodType,
                                           expiryDate: cardInfo.expiryDate,
                                           addressLine1: cardInfo.addressLine1,
                                           addressLine2: cardInfo.addressLine2,
                                           city: cardInfo.city,
                                           state: cardInfo.state,
                                           zip: cardInfo.zip)
        return cardDict
    }
    
    private func navigateToFinishSetup(screenType: FinishSetupType, paymethod: PayMethod? = nil) {
        guard let viewcontroller = FinishSetupViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.screenType = screenType
        if flow == .appbNotEnrolled {
            viewcontroller.flowType = .appbNotEnrolled
            viewcontroller.payMethod = paymethod
        }
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    // This Method isn't being used
    private func showThanksPayment(paymentState: ThanksPaymentState, paymentJson: [String: AnyObject]) {
        let storyboard = UIStoryboard(name: "Payments", bundle: nil)
        if let thanksViewController = storyboard.instantiateViewController(withIdentifier: "ThanksAutoPayViewController") as? ThanksAutoPayViewController {
            thanksViewController.modalPresentationStyle = .fullScreen
            thanksViewController.state = paymentState
//            thanksViewController.createOneTimePaymethod = createOneTimePayMethod
            thanksViewController.retryPaymentJson = paymentJson
            thanksViewController.isAutoPayFlow = false
            thanksViewController.isDefaultSave = saveToAccount.isSelected
            self.present(thanksViewController, animated: true)
        }
    }
    
    /// handle Api errorcode 500
    func handleErrorOTPAndCreatePayment() {
        if QuickPayManager.shared.currentApiType != .updateAutoPay {
            self.signInFailedAnimation()
        }
        switch QuickPayManager.shared.currentApiType {
        case .oneTimePayment:
            self.paymentSystemFailure()
        case .createPayment:
            self.showErrorMsgOnPaymentFailure()
        case .updateAutoPay://CMAIOS-2858
            self.navigateAfterPaymenthodCreation(cardInfo:payMethodCardInfo, isDefault: isDefaultCard, isFromFailure: true)
        case .createAutoPay: //CMAIOS-2841
            self.showErrorMsgOnPaymentFailure(isAutoPayFailure: false)
        default: break
        }
    }
    
    private func moveToHomeViewController(payMethod: PayMethod? = nil) {
        // CMAIOS-2099
        if let chooseViewController = self.navigationController?.viewControllers.filter({$0.isKind(of: ChoosePaymentViewController.classForCoder())}).first as? ChoosePaymentViewController {
            DispatchQueue.main.async {
                chooseViewController.fetchPaymethods()
            }
            self.navigationController?.popToViewController(chooseViewController, animated: true)
            return
        }
    }
    
    private func moveToMakePaymentForExpiryFlow() {
        self.moveToMakePayment()
    }
    
    // This Method isn't being used
    private func moveToThankYouScreen(payMethod: PayMethod?) {
        let storyboard = UIStoryboard(name: "Payments", bundle: nil)
        if let thanksViewController = storyboard.instantiateViewController(withIdentifier: "ThanksAutoPayViewController") as? ThanksAutoPayViewController {
            thanksViewController.modalPresentationStyle = .fullScreen
            thanksViewController.payMethod = payMethod
            thanksViewController.state = .oneTimePaymentSuccess(saveCard: saveToAccount.isSelected)
            self.present(thanksViewController, animated: true)
        }
    }
    
    /// Generate json parameters for create payment and create one time payment
    /// - Parameter isOneTimePayment: Create payment or create one time payment
    /// - Returns: updated json paramerters
    private func generateJsonParam(isOneTimePayment: Bool) -> (jasonParm: [String: AnyObject], creditCardPayMethod: CreditCardPayMethod) {
        let expiryDate = CommonUtility.dateStringToTimeStamp(dateString: expireDate.text ?? "", dateFormat: "MM/yy")
        let replaceNewLineCard = PGPCryptoUtility.cardEncryption(cardNumber: cardNumber.text?.removeFormatSpaces ?? "")?.replacingOccurrences(of: "\n", with: "\\n")
        //        let replaceNewLineCard = PGPCryptoUtility.cardEncryption(cardNumber: cardNumber.text ?? "")
        var jsonParams = [String: AnyObject]()
        //CMAIOS-2175 add card name without extra trailing spaces
        let cardName = name.text?.trimExtraWhiteLeadingTrailingSpaces()
        let nickName = nickName.text?.trimExtraWhiteLeadingTrailingSpaces()
        let cardDict = CreditCardPayMethod(nameOnCard: cardName,
                                           maskedCreditCardNumber: replaceNewLineCard ?? "" ,
                                           cardType: getCardTypeForServiceRequest(),
                                           methodType: "CC_METHOD_TYPE_CREDIT",
                                           expiryDate: expiryDate,
                                           addressLine1: sameBillingAddress.isSelected ? addressLineOne.text: "" ,
                                           addressLine2: sameBillingAddress.isSelected ? addressLineTwo.text: "",
                                           city: sameBillingAddress.isSelected ? city.text: "",
                                           state: sameBillingAddress.isSelected ? state.text: "",
                                           zip: sameBillingAddress.isSelected ? zip.text: "")
        
        let cardPaymentInfo = Card(newNickname: nickName, creditCardPayMethod: cardDict)
        
        if isOneTimePayment {
            // One time payment need other requires values like amount, save
            let oneTimePaymentInfo = OneTimePaymentInfo(payMethod: cardPaymentInfo, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(QuickPayManager.shared.getCurrentAmount())))
            let paymentDict = CreateOneTimePayment(payment: oneTimePaymentInfo)
            createOneTimePayMethod = paymentDict // used for payment retry feature in payment failure scenario
            do {
                let jsonData = try JSONEncoder().encode(paymentDict)
                jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            } catch { Logger.info("\(String(describing: error))") }
        } else {
            // We no need to add amount and save keys since it is only for creating a Payment method
            do {
                let jsonData = try JSONEncoder().encode(cardPaymentInfo)
                jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            } catch { Logger.info("\(String(describing: error))")}
        }
        return (jsonParams, cardDict)
    }
    
    /// Generate json parameters for Create Schedule payment with New card
    /// - Returns: updated json paramerters
    private func generateJsonParamForSchedule() -> ([String: AnyObject]) {
        let expiryDate = CommonUtility.dateStringToTimeStamp(dateString: expireDate.text ?? "", dateFormat: "MM/yy")
        let replaceNewLineCard = PGPCryptoUtility.cardEncryption(cardNumber: cardNumber.text?.removeFormatSpaces ?? "")?.replacingOccurrences(of: "\n", with: "\\n")
        //        let replaceNewLineCard = PGPCryptoUtility.cardEncryption(cardNumber: cardNumber.text ?? "")
        var jsonParams = [String: AnyObject]()
        let cardDict = CreditCardPayMethod(nameOnCard: name.text ?? "",
                                           maskedCreditCardNumber: replaceNewLineCard ?? "" ,
                                           cardType: getCardTypeForServiceRequest(),
                                           methodType: "CC_METHOD_TYPE_CREDIT",
                                           expiryDate: expiryDate,
                                           addressLine1: sameBillingAddress.isSelected ? addressLineOne.text: "" ,
                                           addressLine2: sameBillingAddress.isSelected ? addressLineTwo.text: "",
                                           city: sameBillingAddress.isSelected ? city.text: "",
                                           state: sameBillingAddress.isSelected ? state.text: "",
                                           zip: sameBillingAddress.isSelected ? zip.text: "")
        
        let cardPaymentInfo = Card(newNickname: nickName.text, creditCardPayMethod: cardDict)
        
        let paymentInfo = SchdulePaymentNewCardInfo(payMethod: cardPaymentInfo, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(QuickPayManager.shared.getCurrentAmount())), paymentDate: CommonUtility.getCurrentDateString())
        let paymentDict = SchedulePaymentWithNewCard(payment: paymentInfo)
        do {
            let jsonData = try JSONEncoder().encode(paymentDict)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    private func generateJsonForFirstTimeCard() -> Card? {
        let expiryDate = CommonUtility.dateStringToTimeStamp(dateString: expireDate.text ?? "", dateFormat: "MM/yy")
        let replaceNewLineCard = PGPCryptoUtility.cardEncryption(cardNumber: cardNumber.text?.removeFormatSpaces ?? "")?.replacingOccurrences(of: "\n", with: "\\n")
        //        let replaceNewLineCard = PGPCryptoUtility.cardEncryption(cardNumber: cardNumber.text ?? "")
        var jsonParams = [String: AnyObject]()
        let cardDict = CreditCardPayMethod(nameOnCard: name.text ?? "",
                                           maskedCreditCardNumber: replaceNewLineCard ?? "" ,
                                           cardType: getCardTypeForServiceRequest(),
                                           methodType: "CC_METHOD_TYPE_CREDIT",
                                           expiryDate: expiryDate,
                                           addressLine1: sameBillingAddress.isSelected ? addressLineOne.text: "" ,
                                           addressLine2: sameBillingAddress.isSelected ? addressLineTwo.text: "",
                                           city: sameBillingAddress.isSelected ? city.text: "",
                                           state: sameBillingAddress.isSelected ? state.text: "",
                                           zip: sameBillingAddress.isSelected ? zip.text: "")
        
        let cardPaymentInfo = Card(newNickname: nickName.text, creditCardPayMethod: cardDict)
        return cardPaymentInfo
    }
    
    /// Check whether set_Default need (true or false)
    /// - Parameter isOntimePayment: create payment or onetime payment flow
    /// - Returns: set_default true or false
    private func cardShouldBeDefault(isOntimePayment: Bool) -> Bool {
        var isDefault = false
        switch (isOntimePayment, saveToAccount.isSelected) {
        case (true, true):
            isDefault = true
        case (false, _):
            isDefault = true
        default :
            isDefault = false
        }
        return isDefault
    }
    
    /// Gives card type integer for API requesty
    /// - Returns: card type integer
    private func getCardTypeForServiceRequest() -> String {
        var type = "CREDIT_CARD_TYPE_VISA"
        guard let cardType = CreditCardValidator.cardType(cardNumber: cardNumber.text?.removeFormatSpaces ?? "") else {
            return type
        }
        switch cardType {
        case .Visa :
            type = "CREDIT_CARD_TYPE_VISA"
        case .Amex:
            type = "CREDIT_CARD_TYPE_AMERICAN_EXPRESS"
        case .Mastercard:
            type = "CREDIT_CARD_TYPE_MASTERCARD"
        case .Discover:
            type = "CREDIT_CARD_TYPE_DISCOVER"
        }
        return type
    }
    
    @IBAction func onTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    func creditCardPastDateValidation(text: String) -> Bool {
        guard let date = CommonUtility.expireDateFormatter.date(from: text), let enteredDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else { return false }
        return enteredDate > Date()
    }
    
    // This Method isn't being used
    private func paymentSystemFailure() {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .paymentSytemUnavailable
        viewcontroller.modalPresentationStyle = .fullScreen
        self.present(viewcontroller, animated: true, completion: nil)
    }
    
    func showErrorMsgOnPaymentFailure(isAutoPayFailure: Bool = false, payMethodName: String = "") {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        //CMAIOS-2528
        switch flow {
        case .managePayments(_) where QuickPayManager.shared.isAutoPayEnabled():
            if isAutoPayFailure { // CMAIOS-2623
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .autoPay_setup_API_failure_after_MOP, subTitleMessage: updatedAutoPayMethodName)
            }
            vc.isComingFromFinishSetup = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_AUTOPAY_ENROLLMENT_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        default:
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_ADDING_MOP_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            if buttonPayNow.currentTitle == "Save" {
                vc.isComingFromCardInfoPage = true
                vc.isComingFromBillingMenu = false
            } else {
                vc.isComingFromBillingMenu = true
                vc.isComingFromCardInfoPage = false
            }
            self.determineAndUpdateGAReport()
        }
        
        /*
        if flow == .managePayments && QuickPayManager.shared.isAutoPayEnabled() { //CMAIOS-2858
            if isAutoPayFailure { // CMAIOS-2623
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .autoPay_setup_API_failure_after_MOP, subTitleMessage: payMethodName)
            }
            vc.isComingFromFinishSetup = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_AUTOPAY_ENROLLMENT_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_ADDING_MOP_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            if buttonPayNow.currentTitle == "Save" {
                vc.isComingFromCardInfoPage = true
                vc.isComingFromBillingMenu = false
            } else {
                vc.isComingFromBillingMenu = true
                vc.isComingFromCardInfoPage = false
            }
            self.determineAndUpdateGAReport()
        }
         */
        self.determineAndUpdateGAReport()
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Only capture the create payment error
    private func determineAndUpdateGAReport() {
        switch (QuickPayManager.shared.getAllPayMethodMop().isEmpty && flow != .addCard(),
                QuickPayManager.shared.getAllPayMethodMop().isEmpty) {
        case (true, _), (_,false):
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.ERROR_ON_SAVE_MOP_SCREEN.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
        default: break
        }
    }
    
    private func showCancelAlertView() {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .sureCancelCard
        // CMAIOS-2099
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
}

extension ManualCardEntryViewController: BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        switch buttonType {
        case .cancel:
            showCancelAlertView()
        case .back:
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
    
    func inserting(_ char: String, every index: Int) -> String {
        return self.split(by: index).joined(separator: char)
    }
}
