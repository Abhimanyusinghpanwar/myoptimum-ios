//
//  EditACHDetailVC.swift
//  CustSupportApp
//
//  Created by mac_admin on 05/12/24.
//

import UIKit
import Lottie

class EditACHDetailVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblBankName: UILabel!
    @IBOutlet weak var lblAccountNumber: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var autoPayStackView: UIStackView!
    @IBOutlet var nickNameTxtFld: FloatLabelTextField!
    @IBOutlet var nickNameView: UIView!
    @IBOutlet var achBankImage: UIImageView!
    @IBOutlet var achBankImageView: UIView!
    @IBOutlet var cancelBtn: UIButton!
    var achMOPDetails : PayMethod?
    @IBOutlet var achMopDetailsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonAnimationView: LottieAnimationView!
    @IBOutlet weak var saveButtonStack: UIStackView!
    var signInIsProgress = false
    var accountNameEdited = false
    var existingNickName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(payMethod: achMOPDetails)
        cancelBtn.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        nickNameView.layer.borderColor = UIColor(red: 0.941, green: 0.941, blue: 0.953, alpha: 1).cgColor
        
        // Do any additional setup after loading the view.
    }
    
    func configureUI(payMethod: PayMethod?) {
        let cardInfo = QuickPayManager.shared.payMethodInfo(payMethod: payMethod)
        self.lblBankName.text = cardInfo.0
        self.lblHeader.text = "Edit \(cardInfo.0)"
        //CMA-2450
        self.achBankImage.image = UIImage(named: cardInfo.1)
        self.achBankImageView.setBorderUIForBankMOP(paymethod: payMethod)
        var payMethodName = cardInfo.2
        if payMethodName == "Checking account" {
            payMethodName = payMethodName.replacingOccurrences(of: " account", with: "")
        }
        if let paymentName = QuickPayManager.shared.getDefaultAutoPaymentMethod(), paymentName.name == payMethod?.name {
            self.autoPayStackView.isHidden = false
            achMopDetailsViewHeight.constant = 153.0
        } else {
            self.autoPayStackView.isHidden = true
            achMopDetailsViewHeight.constant = 127.0
        }
        let attributedText = NSMutableAttributedString(string: "•••• ")
        let lastFourDigit = QuickPayManager.shared.getLastFourDigitsOrNicknameForBank(payMethod: payMethod).0.attributedString(with: [.font: UIFont(name: "Regular-Bold", size: 24) as Any, .foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)], and: "")
        attributedText.append(lastFourDigit)
        self.lblAccountNumber.attributedText = attributedText
        self.nickNameTxtFld.text = cardInfo.0
        existingNickName = cardInfo.0
    }

    
    @IBAction func onTapCancelBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapSaveBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        if !accountNameEdited {
            self.navigationController?.popViewController(animated: true)
            return
        }
        var isValidationSuccess = true
        guard let newNickName = self.nickNameTxtFld.text else {return}
        if newNickName != existingNickName, QuickPayManager.shared.checkingNameExists(newName: newNickName) {
            nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)
            isValidationSuccess = false
            return
        }
        if ((newNickName.removeFormatSpaces.isEmpty) || (newNickName.hasSuffix(" ") == true || newNickName.hasPrefix(" ") == true)) {
                isValidationSuccess = false
        }
        
        if let paymethod = achMOPDetails, isValidationSuccess {
            if isBankInfoUpdated(nickName: newNickName) {
                self.nickNameTxtFld.isUserInteractionEnabled = false
                self.updateEditedPaymethodToRemote(oldPayMethod: paymethod, newNickName: newNickName)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func updateEditedPaymethodToRemote(oldPayMethod: PayMethod, newNickName: String) {
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiUpdate(paymethod: oldPayMethod, newNickname: newNickName, updatePaymethod: nil, completionHandler: { [weak self] result in
            switch result {
            case let .success(payMethod):
                guard payMethod != nil else { return  Logger.info("Paymethod returned nil") }
                QuickPayManager.shared.mauiGetAccountBillRequest() { error in
                    self?.signInIsProgress = false
                    self?.buttonAnimationView.pause()
                    self?.buttonAnimationView.play(fromProgress: self?.buttonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(_):
                self?.signInFailedAnimation()
                self?.showErrorMsgOnUpdateFailure()
            }
        })
    }
    
    
    func isBankInfoUpdated(nickName: String) -> Bool {
        guard let oldPayMethod = achMOPDetails else {
            return true
        }
        if nickName != oldPayMethod.name?.lastPathComponent {
            return true
        }
        return false
    }
    
    
    func handleErrorUpdateNickname() {
        self.signInFailedAnimation()
        self.showErrorMsgOnUpdateFailure()
    }
    
    // CMAIOS-2734
    func showErrorMsgOnUpdateFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromCardInfoPage = true
        vc.isComingFromBillingMenu = false
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !lblError.isHidden {
            lblError.isHidden = true
        }
        nickNameTxtFld.setBorderColor(mode: .selected_color)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharacters = 13
        accountNameEdited = true
        let currentTextFieldData = textField.text! as NSString
        let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
        if(newString.length <= maxCharacters){
            nickNameDisplay(errMsg: " ", needToHide: true)
        } //CMAIOS-2214 Do not show any live validation if the user tries to enter 14th char
        return newString.length <= maxCharacters
    }
    
    //CMAIOS-2176. Added this func to display the Nickname err msg based on the conditions.
    func nickNameDisplay( errMsg : String, needToHide : Bool) {
        switch needToHide {
        case true :
            nickNameTxtFld.setBorderColor(mode: .selected_color)//Fix for border color
            lblError.isHidden = true
        case false:
            nickNameTxtFld.setBorderColor(mode: .error_color)
            lblError.text = errMsg
            lblError.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //show char limit error message if the user tap out of field or field has loss of focus
          if let textValue = textField.text, textValue.count > 13 {
            nickNameDisplay(errMsg: "Nickname must be 13 characters", needToHide: false)
            return
          }
            if let textValue = textField.text, textValue.count > 0 {
                //CMAIOS-2171, Verifying the nickname field for the Prefix & suffix spaces.
                if textValue.hasSuffix(" ") == true || textValue.hasPrefix(" ") == true {
                    nickNameDisplay(errMsg: "Nickname can’t start or end with space", needToHide: false)
                } else if textValue != existingNickName, QuickPayManager.shared.checkingNameExists(newName: textValue) {
                    nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)
                }
                else {
                    nickNameTxtFld.setBorderColor(mode: .deselcted_color)
                    lblError.isHidden = true
                }
            } else {
                nickNameDisplay(errMsg: "Please enter a nickname", needToHide: false)
            }
    }
    
}
