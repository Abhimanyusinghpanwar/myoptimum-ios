//
//  CardExpirationViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 1/19/23.
//

import Lottie
import UIKit

enum ExpirationFlow {
    case quickPay
    case autoPay
    case scheduledPayment
    case onlyDefaultExpired
    case defaultExpiredWithMoreMOPs
    case newCardDateExpired
    case autoPaymentFailure
    case none
}

class CardExpirationViewController: UIViewController {
    
    @IBOutlet var expirationTitleLabel: UILabel!
    @IBOutlet var expirationSubTitleLabel: UILabel!
    @IBOutlet var cardView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet var field: FloatLabelTextField!
    @IBOutlet var secondaryAction: UIButton!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet weak var imageCardType: UIImageView!
    @IBOutlet weak var labelCardType: UILabel!
    @IBOutlet weak var buttonAnimationView: LottieAnimationView!
    @IBOutlet weak var saveButtonStack: UIStackView!
    @IBOutlet weak var cardStack: UIStackView!
    var isFromSpotLightCard = false
    var successHandler: ((PayMethod) -> Void)?
    var payMethod: PayMethod?
    var flow: ExpirationFlow = .quickPay
    var signInIsProgress = false
    var qualtricsAction : DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.qualtricsAction?.cancel()
        super.viewWillDisappear(true)
        self.signInFailedAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true //CMAIOS-2789
    }
    
    // MARK: - O dot Animation View
    private func showODotAnimation() {
        loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        loadingAnimationView.backgroundColor = .clear
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.play()
    }
    
    func configureUI() {
        field.delegate = self
        field.setBorderColor(mode: BorderColor.deselcted_color)
        field.attributedPlaceholder = NSAttributedString(
            string: field.placeholder ?? "",
            attributes: [.foregroundColor: UIColor.placeholderText])
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        switch flow {
        case .quickPay:
            expirationTitleLabel.text = "Your card has expired"
            let cardName = getPaymentInfo().0
            let subtitle = "To use this card, enter the new expiration date for " + cardName
            expirationSubTitleLabel.attributedText = subtitle.attributedString(
                with: [.font: UIFont(name: "Regular-Regular", size: 20) as Any],
                and: cardName,
                with: [.font: UIFont(name: "Regular-Bold", size: 20) as Any]
            )
            primaryAction.setTitle("Continue", for: .normal)
            expirationSubTitleLabel.isHidden = false
            cardStack.isHidden = true
            errorLabel.isHidden = true
            changeButton.isHidden = true
            self.trackGAEvents(flowType: .quickPay)
        case .autoPay, .autoPaymentFailure:
            expirationTitleLabel.text = "Enter new expiration date for"
            expirationSubTitleLabel.isHidden = true
            cardStack.isHidden = false
            cardView.isHidden = false
            errorLabel.isHidden = true
            changeButton.isHidden = true
            primaryAction.setTitle("Save", for: .normal)
            labelCardType.text = getPaymentInfo().0
            if getPaymentInfo().1 == "" {
                imageCardType.isHidden = true
            } else {
                imageCardType.isHidden = false
                imageCardType.image = UIImage(named: getPaymentInfo().1)
            }
        case .scheduledPayment, .onlyDefaultExpired, .defaultExpiredWithMoreMOPs:
            expirationTitleLabel.text = "Enter new expiration date for"
            expirationSubTitleLabel.isHidden = true
            cardStack.isHidden = false
            cardView.isHidden = false
            errorLabel.isHidden = true
            changeButton.isHidden = true
            primaryAction.setTitle("Save", for: .normal)
            labelCardType.text = getPaymentInfo().0
            if getPaymentInfo().1 == "" {
                imageCardType.isHidden = true
            } else {
                imageCardType.isHidden = false
                imageCardType.image = UIImage(named: getPaymentInfo().1)
            }
            if flow == .scheduledPayment {
                qualtricsAction = self.checkQualtrics(screenName: PaymentScreens.MYBILL_MAKEPAYMENT_SCHEDULEPAYMENT_ENTER_NEW_EXPIRATION_DATE.rawValue, dispatchBlock: &qualtricsAction)
                self.trackGAEvents(flowType: .scheduledPayment)
            }
        case .none: break
        case .newCardDateExpired: break
        }
    }
    func trackGAEvents(flowType : ExpirationFlow){
        var customParm: [String : String] = [:]
        var type = ""
        switch flowType {
        case .quickPay :
            type = BillPayEvents.QUICKPAY_UPDATE_EXPIRATION.rawValue
            customParm = [CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue]
        case .scheduledPayment:
            type = PaymentScreens.MYBILL_MAKEPAYMENT_SCHEDULEPAYMENT_ENTER_NEW_EXPIRATION_DATE.rawValue
        case .autoPay: break
        case .onlyDefaultExpired: break
        case .none: break
        case .defaultExpiredWithMoreMOPs: break
        case .newCardDateExpired: break
        case .autoPaymentFailure: break
        }
        if type.isEmpty { return }
        var params = [EVENT_SCREEN_NAME : type
                      , EVENT_SCREEN_CLASS: self.classNameFromInstance]
        params = params.merging(customParm){ (current,_) in  current}
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:params)
    }
    
    private func getPaymentInfo() -> (String, String) {
        if let paymethod = payMethod {
            let info = QuickPayManager.shared.payMethodInfo(payMethod: paymethod)
            return (info.0, info.1)
        }
        return ("", "")
    }
    
    @IBAction func onTapChangePaymentMethod(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        vc.payMethod = payMethod
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapPrimaryAction(_ sender: RoundedButton) {
        self.qualtricsAction?.cancel()
        checkAndUpdateError(field, text: field.text, isEndValidation: true)
        guard errorLabel.isHidden else { return }
        if let paymethod = payMethod, let date = field.text {
            DispatchQueue.main.async {
                self.signInButtonAnimation()
            }
            self.signInIsProgress = true
            QuickPayManager.shared.mauiUpdate(paymethod: paymethod, expireDate: date, completionHandler: { [weak self] result in
                switch result {
                case let .success(payMethod):
                    guard let payMethod = payMethod else { return  Logger.info("Paymethod returned nil") }
                    QuickPayManager.shared.mauiGetAccountBillRequest() { error in
                        self?.signInIsProgress = false
                        self?.buttonAnimationView.pause()
                        self?.buttonAnimationView.play(fromProgress: self?.buttonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                            self?.signInFailedAnimation()
                        }
                        guard error == nil else { return }
                        switch self?.flow {
                        case .autoPay: // CMAIOS-1180
                            self?.navigateToQuickPayAlert(type: .updateAutopay, payMethod: payMethod)
                        case .scheduledPayment:
                            self?.navigateToQuickPayAlert(type: .updateScheduledPayment, payMethod: payMethod)
                        case .onlyDefaultExpired,.defaultExpiredWithMoreMOPs:
                            self?.onlyDefaultCardExpiredFlow()
                        default:
                            // CMAIOS-2099
                            DispatchQueue.main.async {
                                self?.successHandler?(payMethod)
                            }
                            // CMAIOS:-2708
//                            self?.navigationController?.popToViewController(ofClass: MakePaymentViewController.self, animated: true)//CMAIOS-2673
                        }
                    }
                case let .failure(error):
                    self?.signInFailedAnimation()
                    Logger.info("Expiration Update failed \(error.localizedDescription)")
                    self?.showQuickAlertViewController()
                }
            })
        }
    }
    
    private func navigateToQuickPayAlert(type: AllSetType, payMethod: PayMethod) {
        guard let vc = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        vc.allSetType = type
        vc.successHandler = { [weak self] in
            self?.successHandler?(payMethod)
        }
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleErrorUpdateExpiration() {
        self.signInFailedAnimation()
        self.showQuickAlertViewController()
    }
    
    private func showQuickAlertViewController() {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .systemUnavailable
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func onlyDefaultCardExpiredFlow() { // CMAIOS-2009
        switch (QuickPayManager.shared.getCurrentAmount() == "",
                QuickPayManager.shared.getScheduledPaymentAmount() > 0) {
        case (true, _), (_, true):
            self.enterAmountScreen()
        default:
            self.moveToMakePaymentScreen()
        }
    }
    
    private func enterAmountScreen() {
        DispatchQueue.main.async {
            let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
            enterPayVC.amountStr = ""
            enterPayVC.balanceStateText = "No payment due at this time"
            self.navigationController?.pushViewController(enterPayVC, animated: true)
        }
    }
    
    private func moveToMakePaymentScreen() {
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock()
        makePayVC.state = QuickPayManager.shared.getInitialScreenFlowState()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
    @IBAction func onTapSecondaryAction(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        //CMAIOS-2234
        if self.isFromSpotLightCard {
            self.dismiss(animated: true)
            return
        }
        // CMAIOS-2099
        self.navigationController?.popViewController(animated: true)
    }
    
    func showDifferentPaymentMethod() {
        if let numberOfPayments = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.count, numberOfPayments > 1 {
            changeButton.isHidden = false
        } else {
            changeButton.isHidden = true
        }
    }
    
    // MARK: - Save Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.buttonAnimationView.isHidden = true
        self.saveButtonStack.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.buttonAnimationView.isHidden = false
        }
        self.buttonAnimationView.backgroundColor = .clear
        self.buttonAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.buttonAnimationView.loopMode = .playOnce
        self.buttonAnimationView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.buttonAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.buttonAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.buttonAnimationView.currentProgress = 3.0
        self.buttonAnimationView.stop()
        self.buttonAnimationView.isHidden = true
        self.saveButtonStack.alpha = 0.0
        self.saveButtonStack.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.saveButtonStack.alpha = 1.0
        }
    }
}

extension CardExpirationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as? FloatLabelTextField)?.setBorderColor(mode: errorLabel?.isHidden == true ? .selected_color : .error_color)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 5
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if let textField = textField as? FloatLabelTextField, !updatedText.isEmpty && updatedText.count <= maxLength {
                // Do live validations for selected fields
                if field.contains(textField) {
                    checkAndUpdateError(textField, text: updatedText)
                }
                // Autoformat Expiration Date
                if textField == field {
                    textField.text = formatExpirationDate(updateText: updatedText, isBackspace: string.isEmpty)
                    return false
                }
            }
            return updatedText.count <= maxLength
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? FloatLabelTextField else { return }
        checkAndUpdateError(textField, text: textField.text, isEndValidation: true)
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
    
    func checkAndUpdateError(_ textField: FloatLabelTextField, text: String?, isEndValidation: Bool = false) {
        let errorText = validateEntry(textField, text: text, isEndValidation: isEndValidation)
        errorLabel?.isHidden = errorText == nil
        errorLabel?.text = errorText
        let color: BorderColor = isEndValidation ? .deselcted_color : .selected_color
        textField.setBorderColor(mode: errorLabel?.isHidden == true ? color : .error_color)
    }
    
    func validateEntry(_ textField: UITextField, text: String?, isEndValidation: Bool = false) -> String? {
        // CMAIOS-1180
        let minLength = 5
        guard let text = text else { return nil }
        if isEndValidation {
            if text.isEmpty {
               return "Please enter expiration date."
            } else if text.count < 5 {
                return "Please enter valid expiration date"
            }
        }
        guard text.count == minLength else { return nil }
        if !creditCardPastDateValidation(text: text) {
            return "Expiration date can’t be in the past"
        }
        /*
        guard text?.isEmpty == false && isEndValidation else {
            return "Please enter expiration date."
        }
        
        guard text?.hasSuffix(" ") == false || text?.hasPrefix(" ") == false else {
            return "Expiration can’t start or end with space."
        }
        
        guard let text = text else { return nil }
        //            if text.count != minLength && !text.isValidExpireDate {
        //                return "Expiration should be in MM/YY format."
        //            }
        if text.count == minLength && !text.isValidExpireDate {
            return "Expiration should be in MM/YY format."
        }
        guard text.count == minLength else { return nil }
        if !creditCardPastDateValidation(text: text) {
            return "Expiration date can’t be in the past"
        }
         */
        return nil
    }
    
    func creditCardPastDateValidation(text: String) -> Bool {
        guard let date = CommonUtility.expireDateFormatter.date(from: text), let enteredDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else { return false }
        return enteredDate > Date()
    }
}
