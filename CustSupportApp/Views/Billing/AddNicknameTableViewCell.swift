//
//  AddNicknameTableViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 29/02/24.
//

import UIKit

protocol nickNameFieldDelegate: AnyObject {
    func nickNameTableCell(isWarningShown: Bool)
    func saveNickNameValue(_ value: String, isNickNameEdit: Bool)
}

class AddNicknameTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        nicknameTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        // Initialization code
    }

    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameTxtFld: FloatLabelTextField!
    @IBOutlet weak var nicknameErrLbl: UILabel!
    var isSaveBtnTapped = true
    var nickNameDelegate: nickNameFieldDelegate!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !nicknameErrLbl.isHidden {
            nicknameErrLbl.isHidden = true
            nickNameDelegate.nickNameTableCell(isWarningShown: false)
        }
        nicknameTxtFld.setBorderColor(mode: .selected_color)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharacters = 13
        if textField.text?.count ?? 0 >= maxCharacters && string != "" { //CMAIOS-2815 To avoid updating the logic if max characters are more than the limit
            return false
        }
        let currentTextFieldData = textField.text! as NSString
        let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
        if(newString.length <= maxCharacters){
            nickNameDelegate.saveNickNameValue(newString as String, isNickNameEdit: true)
            nickNameDisplay(errMsg: " ", needToHide: true)
        } //CMAIOS-2214 Do not show any live validation if the user tries to enter 14th char
        return newString.length <= maxCharacters
    }
    
    //CMAIOS-2176. Added this func to display the Nickname err msg based on the conditions.
    func nickNameDisplay( errMsg : String, needToHide : Bool) {
        switch needToHide {
        case true :
            nicknameTxtFld.setBorderColor(mode: .deselcted_color)
            nicknameErrLbl.isHidden = true
            nickNameDelegate.nickNameTableCell(isWarningShown: false)
        case false:
            nicknameTxtFld.setBorderColor(mode: .error_color)
            nicknameErrLbl.text = errMsg
            nicknameErrLbl.isHidden = false
            nickNameDelegate.nickNameTableCell(isWarningShown: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isSaveBtnTapped {
        //show char limit error message if the user tap out of field or field has loss of focus
          
            if let textValue = textField.text, textValue.count > 0 {
//                if QuickPayManager.shared.checkingNameExists(newName: textField.text ?? "") {
//                    nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)
//                } else {
//                    nicknameTxtFld.setBorderColor(mode: .deselcted_color)
//                    nicknameErrLbl.isHidden = true
//                }
                //CMAIOS-2171, Verifying the nickname field for the Prefix & suffix spaces.
                if textValue.hasSuffix(" ") == true || textValue.hasPrefix(" ") == true {
                    nickNameDisplay(errMsg: "Nickname can’t start or end with space", needToHide: false)
                } else if QuickPayManager.shared.checkingNameExists(newName: textField.text ?? "") {
                    nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)
                } else if textValue.count > 13 {
                    nickNameDisplay(errMsg: "Nickname must be 13 characters", needToHide: false)
                } else {
                    nicknameTxtFld.setBorderColor(mode: .deselcted_color)
                    nicknameErrLbl.isHidden = true
                }
            } else {
                nickNameDisplay(errMsg: "Please enter a nickname", needToHide: false)
            }
        }
    }
    
}
