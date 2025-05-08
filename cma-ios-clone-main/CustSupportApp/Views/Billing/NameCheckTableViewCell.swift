//
//  NameCheckTableViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 28/02/24.
//

import UIKit

protocol accountNameFieldDelegate: AnyObject {
    func reloadAccountNameTableCell(isWarningShown: Bool)
    func saveAccountNameValue(_ value: String)
}

class NameCheckTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        nameCheckTxtFld.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        // Initialization code
    }

   
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameCheckTxtFld: FloatLabelTextField!
    @IBOutlet weak var warningLabel: UILabel!
    var accountNameDelegate: accountNameFieldDelegate!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !warningLabel.isHidden {
            warningLabel.isHidden = true
            accountNameDelegate.reloadAccountNameTableCell(isWarningShown: false)
        }
        nameCheckTxtFld.setBorderColor(mode: .selected_color)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharacters = 27
        let currentTextFieldData = textField.text! as NSString
        let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxCharacters
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        accountNameDelegate.saveAccountNameValue(textField.text!)
        if textField.text!.count > 0 {
            nameCheckTxtFld.setBorderColor(mode: .deselcted_color)
            warningLabel.isHidden = true
        } else {
            nameCheckTxtFld.setBorderColor(mode: .error_color)
            warningLabel.isHidden = false
            accountNameDelegate.reloadAccountNameTableCell(isWarningShown: true)
        }
    }
    
//    override func prepareForReuse() {
//        nameCheckTxtFld.text = accountName
//    }
}
