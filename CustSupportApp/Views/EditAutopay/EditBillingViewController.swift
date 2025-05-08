//
//  EditBiilingViewController.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 10/02/23.
//

import UIKit
import Lottie

class EditBillingViewController: UIViewController {
    
    enum EditBillingType {
        case landingScreen
        case editScreen
    }

    @IBOutlet var email_Id: FloatLabelTextField!
    @IBOutlet weak var label_Email_Error_Msg: UILabel!
    @IBOutlet weak var button_FinishSetup: UIButton!
    @IBOutlet weak var viewEmailTextField: UIView!
    @IBOutlet weak var sendBillingTitleLabel: UILabel!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var label_EmailId: UILabel!
    @IBOutlet weak var stackSecondary: UIStackView!
    @IBOutlet weak var stackVerticalButton: UIStackView!
    @IBOutlet weak var stackHorizontalButton: UIStackView!
    @IBOutlet weak var button_Edit: UIButton!
    @IBOutlet weak var buttonOkay: RoundedButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonTurnOffPaperlessBilling: CornerRoundButton!
    @IBOutlet weak var saveButtonStack: UIStackView!
    @IBOutlet weak var saveButtonAnimationView: LottieAnimationView!
    
    var screenType: EditBillingType = .landingScreen
    let sharedManager = QuickPayManager.shared
    var signInIsProgress = false
    var qualtricsAction : DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        // Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.SEND_BILLING_NOTFICATION_SCREEN.rawValue,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI() // CMAIOS-1838
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
        self.saveFailedAnimation()
        self.email_Id.resignFirstResponder()
    }
    
    private func configureUI() {
        switch screenType {
        case .landingScreen:
            label_EmailId.text = sharedManager.getBillCommunicationEmail()
            label_EmailId.isHidden = false
            stackVerticalButton.isHidden = false
            stackHorizontalButton.isHidden = true
            buttonOkay.isHidden = true
            button_Edit.isHidden = false
            buttonTurnOffPaperlessBilling.isHidden = true
            viewEmailTextField.isHidden = true
            label_Title.text = "Paperless Billing"
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_PAPERLESSBILLING_NOTIFICATION.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            qualtricsAction = self.checkQualtrics(screenName: BillPayEvents.QUICKPAY_PAPERLESSBILLING_NOTIFICATION.rawValue, dispatchBlock: &qualtricsAction)
            
        case .editScreen:
//            setBordercolor(emailError: false)
            email_Id.setBorderColor(mode: .deselcted_color)
            email_Id.delegate = self
            let overlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOutSideOfView))
            self.view?.addGestureRecognizer(overlayTapGesture)
            stackVerticalButton.isHidden = true
            stackHorizontalButton.isHidden = false
            button_Edit.isHidden = true
            buttonTurnOffPaperlessBilling.isHidden = false
            viewEmailTextField.isHidden = false
            label_EmailId.isHidden = true
            email_Id.text = sharedManager.getBillCommunicationEmail()
            label_Title.text = "Edit Paperless Billing"
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_EDIT_PAPERLESSBILLING.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
    }
    
    private func setBordercolor(emailError: Bool) {
        if emailError {
//            email_Id.layer.borderColor = UIColor(red: 243.0/255.0, green: 53.0/255.0, blue: 87.0/255.0, alpha: 1).cgColor
            email_Id.setBorderColor(mode: BorderColor.error_color)
        } else {
            email_Id.setBorderColor(mode: BorderColor.selected_color)
//            viewEmailTextField.layer.borderColor = energyBlueRGB.cgColor
        }
        label_Email_Error_Msg.isHidden = emailError ? false: true
    }
    
    @objc func tapOutSideOfView() {
        self.view.endEditing(true)
        label_Email_Error_Msg.isHidden = true
        email_Id.setBorderColor(mode: .selected_color)
    }
    
    /// Update Bill communication preference for updating the email id and paperless billing
    private func mauiUpdateBillCommunicationPreference(isEnabled: Bool) {
        var jsonParams = [String: AnyObject]()
        jsonParams["email"] = email_Id.text  as AnyObject?
        jsonParams["termsConditions"] = true as AnyObject?
        jsonParams["mailNotifyIndicator"] = true as AnyObject?
        jsonParams["paperBillIndicator"] = isEnabled as AnyObject?
        jsonParams["name"] = self.sharedManager.getAccountNam() as AnyObject?
        
        sharedManager.mauiUpdateBillCommunicationPreference(jsonParams: jsonParams, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.signInIsProgress = false
                    self.saveButtonAnimationView.pause()
                    self.saveButtonAnimationView.play(fromProgress: self.saveButtonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self.saveFailedAnimation()
                        self.sharedManager.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences = self.sharedManager.modelQuickPayUpdateBillPrefernce?.billCommunicationPreference
                        self.valdiateUpdateBillResponse(success: true)
                    }
                } else {
                    Logger.info("check Response is \(String(describing: error))")
                    self.saveFailedAnimation()
                    self.showErrorMessageVC()
                }
            }
        })
    }
    
    func showErrorMessageVC() {
        self.qualtricsAction?.cancel()
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromFinishSetup = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private  func valdiateUpdateBillResponse(success: Bool) {
        self.closeOrDismiss() //CMAIOS-2474
    }
    
    @IBAction func actionEdit(_ sender: Any) {
        screenType = .editScreen
        configureUI()
    }
    
    @IBAction func acionOkay(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.dismiss(animated: true)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
//        self.dismiss(animated: true)
        self.closeOrDismiss()
    }
    
    @IBAction func actionSave(_ sender: Any) {
        guard let email = email_Id.text, email.isValidEmail else {
            setBordercolor(emailError: true)
            return
        }
        if sharedManager.getBillCommunicationEmail() != email_Id.text {
            DispatchQueue.main.async {
                self.saveButtonAnimation()
            }
            self.signInIsProgress = true
            mauiUpdateBillCommunicationPreference(isEnabled: false)
        } else {
            //CMAIOS-2474
            self.closeOrDismiss()
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.closeOrDismiss()
    }
    
    private func closeOrDismiss() {
        self.qualtricsAction?.cancel()
        if  ((self.navigationController?.viewControllers.contains(self)) != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func actionTurnOffPaperLessBilling(_ sender: Any) {
        self.qualtricsAction?.cancel()
        var jsonParams = [String: AnyObject]()
        jsonParams["name"] = sharedManager.getAccountNam() as AnyObject?
        jsonParams["email"] = email_Id.text  as AnyObject?
        jsonParams["termsConditions"] = true as AnyObject?
        jsonParams["mailNotifyIndicator"] = true as AnyObject?
        jsonParams["paperBillIndicator"] = true as AnyObject?
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .turnOffPaperlessBilling
        viewcontroller.updateCommunicationPreference = jsonParams
        self.navigationController?.pushViewController(viewcontroller, animated: true)

    }
    
    // MARK: - Finish Setup Button Animations
    func saveButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.saveButtonAnimationView.isHidden = true
        self.saveButtonStack.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.saveButtonAnimationView.isHidden = false
        }
        self.saveButtonAnimationView.backgroundColor = .clear
        self.saveButtonAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.saveButtonAnimationView.loopMode = .playOnce
        self.saveButtonAnimationView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.saveButtonAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress && self.saveButtonAnimationView.isAnimationPlaying {
                self.saveButtonAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    func saveFailedAnimation() {
        self.signInIsProgress = false
        self.saveButtonAnimationView.currentProgress = 3.0
        self.saveButtonAnimationView.stop()
        self.saveButtonAnimationView.isHidden = true
        self.saveButtonStack.alpha = 0.0
        self.saveButtonStack.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.saveButtonStack.alpha = 1.0
        }
    }
}

extension EditBillingViewController: UITextFieldDelegate {
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
}

struct EditBillingConstants {
    static let emptyEmailId = "Please enter your Email Address."
    static let inValidEmail = "Please enter a valid email address"
    static let spaceError = "Your email address can’t start or end with space."
}

