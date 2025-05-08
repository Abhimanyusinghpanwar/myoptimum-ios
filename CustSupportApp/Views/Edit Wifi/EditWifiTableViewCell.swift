//
//  EditWifiTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 14/07/22.
//

import UIKit

protocol EditWifiTableViewCellDelegate : AnyObject {
    func selectedRow(_ selectedRow: Int, ssidArray: NSMutableArray, selectedField: String)
    func reloadRow(_ selectedRow: Int, ssidArray: NSMutableArray)
    func resetWifiDataForEdit()
    //Added method to update tableView height
    func showErrorForSSIDPwd(selectedRow : Int, errorText : String)
}

let SSID_SPACE_ERROR = "Your Network name can't start or end with a space."
let SSID_KEYWORD_ERROR =  "The words Optimum, Altice, Suddenlink, or Cablewifi may not be used in the network name."

class EditWifiTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var ghzLabelView: UIView!
    @IBOutlet weak var ghzLabel: UILabel!
    @IBOutlet weak var networkNameTextField: FloatLabelTextField!
    @IBOutlet weak var passwordTextField: FloatLabelTextField!
    @IBOutlet weak var separatorImageView: UIView!
    @IBOutlet weak var networkNameTopSpace: NSLayoutConstraint!
    @IBOutlet weak var networkNameTopSpaceToLabel: NSLayoutConstraint!
    @IBOutlet weak var errorDescriptionView: UIView!
    @IBOutlet weak var errorDescriptionLabel: UILabel!
    @IBOutlet weak var errorDescriptionViewToUsernameView: NSLayoutConstraint!
    @IBOutlet weak var errorDescriptionViewToPasswordView: NSLayoutConstraint!
    @IBOutlet weak var passwordViewToNetworkNameView: NSLayoutConstraint!
    @IBOutlet weak var errorViewToPasswordView: NSLayoutConstraint!
    @IBOutlet weak var errorViewToSeparatorImageView: NSLayoutConstraint!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordValidImageView: UIImageView!
    weak var editWifiViewDelegate: EditWifiTableViewCellDelegate?
    @IBOutlet weak var errorLabelToLeading: NSLayoutConstraint!
    @IBOutlet weak var errorLabelLeadingToImage: NSLayoutConstraint!
    @IBOutlet weak var errorLabelToTop: NSLayoutConstraint!
    @IBOutlet weak var errorLabelAlignTopToImage: NSLayoutConstraint!
    
    var ssidArray: NSMutableArray!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        networkNameTextField.delegate = self
        passwordTextField.delegate = self
        networkNameTextField.autocorrectionType = .no
        networkNameTextField.spellCheckingType = .no
        passwordTextField.autocorrectionType = .no
        passwordTextField.spellCheckingType = .no
        self.networkNameTextField.setBorderColor(mode: BorderColor.deselcted_color)
        self.passwordTextField.setBorderColor(mode: BorderColor.deselcted_color)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        if textField == self.networkNameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        editWifiViewDelegate?.resetWifiDataForEdit()
        if textField == self.networkNameTextField  {
            self.errorDescriptionView.isHidden = true
//            self.errorDescriptionLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
//            self.errorDescriptionViewToPasswordView.priority = UILayoutPriority(rawValue: 250)
//            self.errorDescriptionViewToUsernameView.priority = UILayoutPriority(rawValue: 250)
//            self.passwordViewToNetworkNameView.priority = UILayoutPriority(rawValue: 999)
            editWifiViewDelegate?.selectedRow(textField.tag, ssidArray: ssidArray, selectedField: "NetworkName")
            if textField.text!.isEmpty {
                //To disappear all the SSID error messages
                editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: "")
            } else {
                if let textFieldString = textField.text?.lowercased(), textFieldString.contains("altice") || textFieldString.contains("optimum") || textFieldString.contains("suddenlink") || textFieldString.contains("cablewifi") {
                    //To display the SSID keyword error message
                    editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: SSID_KEYWORD_ERROR)
                } else if let textFieldString = textField.text as NSString?, textFieldString.hasPrefix(" ") || textFieldString.hasSuffix(" ") {
                    //To display the SSID prefix/suffix space error message
                    editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: SSID_SPACE_ERROR)
                }
            }
            self.networkNameTextField.setBorderColor(mode: .selected_color)
//            passwordTextField.setBorderColor(mode: .deselcted_color)
        } else if textField == passwordTextField {
            self.errorView.isHidden = false
//            self.errorLabel.textColor  = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
            editWifiViewDelegate?.selectedRow(textField.tag, ssidArray: ssidArray, selectedField: "Password")
            if textField.text!.last == " " || textField.text!.first == " " {
                passwordTextField.setBorderColor(mode: .error_color)
            } else {
                self.errorLabel.textColor = .black
                passwordTextField.setBorderColor(mode: .selected_color)
            }
//            self.networkNameTextField.setBorderColor(mode: .deselcted_color)
//            if ssidArray.count == 1 {
//                self.errorDescriptionView.isHidden = true
//                self.errorDescriptionLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
//                self.errorDescriptionViewToPasswordView.priority = UILayoutPriority(rawValue: 250)
//                self.errorDescriptionViewToUsernameView.priority = UILayoutPriority(rawValue: 250)
//                self.passwordViewToNetworkNameView.priority = UILayoutPriority(rawValue: 999)
//            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var ghzString = ""
        if textField.tag == 0 {
            ghzString =  "2.4 GHz"
        } else {
            ghzString =  "5 GHz"
        }
        _ = ssidArray.map { let dict = $0.object(at: textField.tag) as! NSMutableDictionary
            let dict1 = dict[ghzString] as! NSMutableDictionary
            if textField == self.networkNameTextField {
                dict1["SSID"] = textField.text
            } else {
                dict1["password"] = textField.text
            }
        }
        editWifiViewDelegate?.reloadRow(textField.tag, ssidArray: ssidArray)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //CMAIOS-2327 replace copy pasted smart quotes to straight one
        let updatedString = string.replacingOccurrences(of: "’", with:"'" )
        if textField == self.networkNameTextField {
            networkNameTextField.setBorderColor(mode: .selected_color)
            networkNameTextField.smartQuotesType = .no
            let maxCharacters = self.getMaxCharLimitForSSID()
            if updatedString.isEmpty {
                let currentTextFieldData = textField.text! as NSString
                let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: updatedString) as NSString
                if newString.hasPrefix(" ") || newString.hasSuffix(" ") {
                    //To display the SSID prefix/suffix space error message
                    editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: SSID_SPACE_ERROR)
                    return newString.length <= maxCharacters
                }
                if let textFieldString = newString.lowercased as String?, textFieldString.contains("altice") || textFieldString.contains("optimum") || textFieldString.contains("suddenlink") || textFieldString.contains("cablewifi") {
                    //To display the SSID restricted keyword error message
                    editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: SSID_KEYWORD_ERROR)
                    return newString.length <= maxCharacters
                }
                //To reset the UI and hide all types of SSID error messages if the user deletes restricted keyword or prefix/suffix empty spaces
                editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: "")
                return newString.length <= maxCharacters
            }
            //CMAIOS-2225 check if entered string is valid ASCII char
            if !updatedString.validateSSIDPasswordInputText(invalidChars: INVALID_SSID_CHARS) {
                return false
            }
            let currentTextFieldData = textField.text! as NSString
            let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: updatedString) as NSString
            if newString.length > maxCharacters {
                if let lastChar = UnicodeScalar(newString.character(at: maxCharacters - 1)), lastChar == " " {
                    self.networkNameTextField.setBorderColor(mode: .error_color)
                    return false
                } else if let firstChar = UnicodeScalar(newString.character(at: 0)), firstChar == " ", let lastChar = UnicodeScalar(newString.character(at: 1)), lastChar == " " {
                    self.networkNameTextField.setBorderColor(mode: .error_color)
                    return false
                } else {
                    //To reset the UI and hide all types of SSID error messages if the user deletes restricted keyword or prefix/suffix empty spaces
                    editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: "")
                    return newString.length <= maxCharacters
                }
            }
            if newString.hasPrefix(" ") || newString.hasSuffix(" ") {
                //To display the SSID prefix/suffix space error message
                editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: SSID_SPACE_ERROR)
                return newString.length <= maxCharacters
            }
            if let textFieldString = newString.lowercased as String?, textFieldString.contains("altice") || textFieldString.contains("optimum") || textFieldString.contains("suddenlink") || textFieldString.contains("cablewifi") {
                //To display the SSID restricted keyword error message
                editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: SSID_KEYWORD_ERROR)
                return newString.length <= maxCharacters
            }
            //To reset the UI and hide all types of SSID error messages if the user deletes restricted keyword or prefix/suffix empty spaces
            editWifiViewDelegate?.showErrorForSSIDPwd(selectedRow: textField.tag, errorText: "")
            return newString.length <= maxCharacters
        } else {
            let maxCharacters = 63
            passwordTextField.setBorderColor(mode: .selected_color)
            if updatedString.isEmpty {
                let currentTextFieldData = textField.text! as NSString
                let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: updatedString) as NSString
                if newString.hasPrefix(" ") || newString.hasSuffix(" ") {
                    self.passwordValidImageView.isHidden = true
                    self.errorLabel.text = "Your password can't start or end with a space."
                    self.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
                    self.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
                    self.errorLabelToTop.priority = UILayoutPriority(rawValue: 999)
                    self.errorLabelToLeading.priority = UILayoutPriority(rawValue: 999)
                    self.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 250)
                    self.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 250)
                    passwordTextField.setBorderColor(mode: .error_color)
                    return newString.length <= maxCharacters
                }
                if newString.length > 7 {
                    self.passwordValidImageView.isHidden = false
                    self.errorLabel.text = "Minimum 8 characters"
                    self.errorLabel.textColor = .black
                    self.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
                    self.errorLabelToTop.priority = UILayoutPriority(rawValue: 250)
                    self.errorLabelToLeading.priority = UILayoutPriority(rawValue: 250)
                    self.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 999)
                    self.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 999)
                } else {
                    self.passwordValidImageView.isHidden = true
                    self.errorLabel.text = "Minimum 8 characters"
                    self.errorLabel.textColor = .black
                    self.errorLabel.font = UIFont(name: "Regular-Regular", size: 15)
                    self.errorLabelToTop.priority = UILayoutPriority(rawValue: 999)
                    self.errorLabelToLeading.priority = UILayoutPriority(rawValue: 999)
                    self.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 250)
                    self.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 250)
                }
                return newString.length <= maxCharacters
            }
            //CMAIOS-2224 Validate password input text
            if !updatedString.validateSSIDPasswordInputText(invalidChars: INVALID_SSID_PWD_CHARS) {
                return false
            }
            let currentTextFieldData = textField.text! as NSString
            let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: updatedString) as NSString
            if newString.length > 63 {
                if let lastChar = UnicodeScalar(newString.character(at: 62)), lastChar == " " {
                    self.passwordTextField.setBorderColor(mode: .error_color)
                    return false
                } else if let firstChar = UnicodeScalar(newString.character(at: 0)), firstChar == " ", let lastChar = UnicodeScalar(newString.character(at: 1)), lastChar == " " {
                    self.passwordTextField.setBorderColor(mode: .error_color)
                    return false
                } else {
                    return newString.length <= maxCharacters
                }
            }
            if newString.hasPrefix(" ") || newString.hasSuffix(" ") {
                self.passwordValidImageView.isHidden = true
                self.errorLabel.text = "Your password can't start or end with a space."
                self.errorLabel.textColor = UIColor(red: 234.0/255.0, green: 0/255.0, blue: 42.0/255.0, alpha: 1)
                self.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
                self.errorLabelToTop.priority = UILayoutPriority(rawValue: 999)
                self.errorLabelToLeading.priority = UILayoutPriority(rawValue: 999)
                self.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 250)
                self.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 250)
                passwordTextField.setBorderColor(mode: .error_color)
                return newString.length <= maxCharacters
            }
            if newString.length > 7 {
                self.passwordValidImageView.isHidden = false
                self.errorLabel.text = "Minimum 8 characters"
                self.errorLabel.textColor = .black
                self.errorLabel.font = UIFont(name: "Regular-Bold", size: 15)
                self.errorLabelToTop.priority = UILayoutPriority(rawValue: 250)
                self.errorLabelToLeading.priority = UILayoutPriority(rawValue: 250)
                self.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 999)
                self.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 999)
            } else {
                self.passwordValidImageView.isHidden = true
                self.errorLabel.text = "Minimum 8 characters"
                self.errorLabel.textColor = .black
                self.errorLabel.font = UIFont(name: "Regular-Regular", size: 15)
                self.errorLabelToTop.priority = UILayoutPriority(rawValue: 999)
                self.errorLabelToLeading.priority = UILayoutPriority(rawValue: 999)
                self.errorLabelLeadingToImage.priority = UILayoutPriority(rawValue: 250)
                self.errorLabelAlignTopToImage.priority = UILayoutPriority(rawValue: 250)
            }
            return newString.length <= maxCharacters
        }
    }
    
    //CMAIOS-2225 get character limit for legacy/nonSmartWifi/Split and Smart WiFi
    func getMaxCharLimitForSSID() -> Int {
        let limit = MyWifiManager.shared.isSplitSSID() ? 23 : 32
        return limit
    }
}
