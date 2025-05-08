//
//  EditCCDetailsTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 06/12/24.
//

import UIKit

protocol editCCFieldDelegate: AnyObject {
    func reloadDetailsTableCell(_ selectedRow: Int, isWarningShown: Bool, textFieldName: String, errorMessage: String)
}

class EditCCDetailsTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        cardNameTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        expiryDateTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        nickNameTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        addressLine1TxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        addressLine2TxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        cityTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        stateTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        zipCodeTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        // Initialization code
    }
    
    @IBOutlet weak var cardNameTxtFld: FloatLabelTextField!
    @IBOutlet weak var expiryDateTxtFld: FloatLabelTextField!
    @IBOutlet weak var nickNameTxtFld: FloatLabelTextField!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var addressLine1TxtFld: FloatLabelTextField!
    @IBOutlet weak var addressLine2TxtFld: FloatLabelTextField!
    @IBOutlet weak var cityTxtFld: FloatLabelTextField!
    @IBOutlet weak var stateTxtFld: FloatLabelTextField!
    @IBOutlet weak var zipCodeTxtFld: FloatLabelTextField!
    @IBOutlet weak var addressLabelBottomConstraintToSuperView: NSLayoutConstraint!
    @IBOutlet weak var addressLabelBottomConstraintToAddressView: NSLayoutConstraint!
    var editCCDelegate: editCCFieldDelegate!
    var selectedRow: Int!
    var existingNickName: String!
    //ExpiryDateErrorLabelConstraint
    @IBOutlet weak var expiryDateErrorLabel: UILabel!
    @IBOutlet weak var expiryDateBottomConstraintToNickname: NSLayoutConstraint!
    //
    //CardNameErrorLabelConstraint
    @IBOutlet weak var cardNameErrorLabel: UILabel!
    @IBOutlet weak var cardNameBottomConstraintToExpiryDate: NSLayoutConstraint!
    //
    //NickNameErrorLabelConstraint
    @IBOutlet weak var nickNameErrorLabel: UILabel!
    @IBOutlet weak var nickNameBottomConstraintToAddressView: NSLayoutConstraint!
    //
    //NickNameErrorLabelConstraint
    @IBOutlet weak var addressLine1ErrorLabel: UILabel!
    @IBOutlet weak var addressLine1BottomConstraintToAddressLine2: NSLayoutConstraint!
    //
    //NickNameErrorLabelConstraint
    @IBOutlet weak var cityErrorLabel: UILabel!
    @IBOutlet weak var cityBottomConstraintToState: NSLayoutConstraint!
    //
    //NickNameErrorLabelConstraint
    @IBOutlet weak var stateErrorLabel: UILabel!
    @IBOutlet weak var stateBottomConstraintToZipcode: NSLayoutConstraint!
    //
    //NickNameErrorLabelConstraint
    @IBOutlet weak var zipCodeErrorLabel: UILabel!
    //

    var handler: (() -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addressButtonAction(_ sender: UIButton) {
        handler?()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let floatTextField = textField as? FloatLabelTextField else {return false}
        floatTextField.setBorderColor(mode: BorderColor.selected_color)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let floatTextField = textField as? FloatLabelTextField else {return}
        validateErrorForTextFields(floatTextField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = getMaxLength(textField)
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if let textField = textField as? FloatLabelTextField, !updatedText.isEmpty && updatedText.count <= maxLength {
                if textField == expiryDateTxtFld {
                    textField.text = formatExpirationDate(updateText: updatedText, isBackspace: string.isEmpty)
                    return false
                }
            }
            return updatedText.count <= maxLength
        }
        return true
    }
    
    func creditCardPastDateValidation(text: String) -> Bool {
        guard let date = CommonUtility.expireDateFormatter.date(from: text), let enteredDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else { return false }
        return enteredDate > Date()
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
    
    func validateErrorForTextFields(_ textField: FloatLabelTextField) {
        if textField == addressLine2TxtFld, textField.text?.isEmpty == true {
            addressLine2TxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            return
        }
        let fieldName = getDisplay(textField)
        var errorMessage = ""
        switch textField {
        case expiryDateTxtFld:
            errorMessage = checkErrorExpiryDateTxtfield(textField, fieldName: fieldName)
        case cardNameTxtFld:
            errorMessage = checkErrorForCardNameTxtfield(textField, fieldName: fieldName)
        case nickNameTxtFld:
            errorMessage = checkErrorNickNameTxtfield(textField, fieldName: fieldName)
        case zipCodeTxtFld:
            errorMessage = checkErrorZipCodeTxtfield(textField, fieldName: fieldName)
        case stateTxtFld:
            errorMessage = checkErrorStateTxtfield(textField, fieldName: fieldName)
        case cityTxtFld:
            errorMessage = checkErrorCityTxtfield(textField, fieldName: fieldName)
        case addressLine1TxtFld:
            errorMessage = checkErrorAddressLine1Txtfield(textField, fieldName: fieldName)
        case addressLine2TxtFld:
            addressLine2TxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        default:
            break
        }
        editCCDelegate.reloadDetailsTableCell(selectedRow, isWarningShown: errorMessage.isEmpty ? false : true, textFieldName: fieldName, errorMessage: errorMessage)
    }
    
    func checkErrorAddressLine1Txtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        if let text = textField.text {
            if text.isEmpty {
                return "Please enter the address"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkErrorForCardNameTxtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        if let text = textField.text {
            if let message = checkForEmptyAndSpaceString(textField, field: fieldName) as String?, !message.isEmpty {
                return message
            } else if !text.validateName {
                return "\(fieldName) only contain letters of the alphabet and spaces"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkErrorExpiryDateTxtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        let minLength = getMinLength(textField)
        if let text = textField.text {
            if let message = checkForEmptyAndSpaceString(textField, field: fieldName) as String?, !message.isEmpty {
                return message
            } else if text.count <= minLength ?? 5 && !text.isValidExpireDate {
                return "\(fieldName) should be in MM/YY format."
            } else if !creditCardPastDateValidation(text: text) {
                return "\(fieldName) can’t be in the past"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkErrorNickNameTxtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        if let text = textField.text {
            if let message = checkForEmptyAndSpaceString(textField, field: fieldName) as String?, !message.isEmpty {
                return message
            } else if !text.isEmpty, text != existingNickName, QuickPayManager.shared.checkingNameExists(newName: textField.text ?? "") == true {
                return "One of your payment methods is already using this nickname."
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkErrorZipCodeTxtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        let minLength = getMinLength(textField)
        if let text = textField.text {
            if text.isEmpty {
                return "Please enter the zip code"
            } else if !text.isNumbersOnly {
                return "\(fieldName) should contain only numbers."
            } else if let length = minLength, text.count != minLength {
                return "\(fieldName) should contain minimum \(length) numbers."
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkErrorStateTxtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        let minLength = getMinLength(textField)
        if let text = textField.text {
            if text.isEmpty {
                return "Please enter the state"
            } else if !text.isValidState || text.count != minLength {
                return "\(fieldName) should contain two letters."
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkErrorCityTxtfield(_ textField: FloatLabelTextField, fieldName: String) -> String {
        if let text = textField.text {
            if text.isEmpty {
                return "Please enter the city"
            } else if !text.validateName {
                return "\(fieldName) only contain letters of the alphabet and spaces"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func checkForEmptyAndSpaceString(_ textField: FloatLabelTextField, field: String) -> String {
        guard textField.text?.isEmpty == false else {
            let prefix = textField == nickNameTxtFld ? "a" : "the"
            return "Please enter \(prefix) \(field.lowercased())."
        }
        guard textField.text?.hasSuffix(" ") == false || textField.text?.hasPrefix(" ") == false else {
            return "\(field) can’t start or end with space."
        }
        return ""
    }
    
    func getMaxLength(_ textField: UITextField) -> Int {
        switch textField {
        case cardNameTxtFld:
            return 100
        case expiryDateTxtFld:
            return 5
        case nickNameTxtFld:
            return 15
        case addressLine1TxtFld:
            return 32
        case addressLine2TxtFld:
            return 32
        case cityTxtFld:
            return 14
        case stateTxtFld:
            return 2
        case zipCodeTxtFld:
            return 5
        default: return 100
        }
    }
    
    func getMinLength(_ textField: UITextField) -> Int? {
        switch textField {
        case stateTxtFld: return 2
        case zipCodeTxtFld: return 5
        case expiryDateTxtFld: return 5
        default: return nil
        }
    }
    
    func getDisplay(_ textField: UITextField) -> String {
        switch textField {
        case cardNameTxtFld:
            return "Name on Card"
        case expiryDateTxtFld:
            return "Expiration date"
        case nickNameTxtFld:
            return "Nickname"
        case addressLine1TxtFld:
            return "Address"
        case addressLine2TxtFld:
            return "Address line 2"
        case cityTxtFld:
            return "City"
        case stateTxtFld:
            return "State"
        case zipCodeTxtFld:
            return "Zip code"
        default: return ""
        }
    }
    
}
