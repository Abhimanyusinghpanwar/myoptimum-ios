//
//  RoutingAccountTableViewCell.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 23/02/24.
//

import UIKit

protocol routingFieldDelegate: AnyObject {
    func reloadRoutingTableCell(_ selectedRow: Int, isWarningShown: Bool)
    func saveRoutingCellValue(_ selectedRow: Int, value: String)
    func saveNickNameFieldData(_ value: String)
    func checkNicknameValidation(_ value: String)
    //CMA-2450
    //func saveBankImgFieldData(_ value: UIImage)
}

class RoutingAccountTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var routingNumberTextField: FloatLabelTextField!
    @IBOutlet weak var routingView: UIView!
    @IBOutlet weak var routBankImg: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconSelectionView: UIControl!
    @IBOutlet weak var routerNumberHelpView: UIView!
    @IBOutlet weak var routerNumberImageView: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var leadingToRoutingViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingToSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewToTextfieldConstraint: NSLayoutConstraint!
    var routingDelegate: routingFieldDelegate!
    var selectedRow: Int!
    var nameVal: String?
    override func awakeFromNib() {
        super.awakeFromNib()

        routingView.layer.borderColor = UIColor.init(red: 0.941, green: 0.941, blue: 0.953, alpha: 1).cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
        //CMAIOS-2176. When we tapped/enter data in textfield, scroll the view to top and place holder is missing.
            routingNumberTextField.attributedPlaceholder = (selectedRow == 1) ? NSAttributedString(string: "Routing number") : NSAttributedString(string: "Account number")
        routingNumberTextField.setPlaceholderColor(UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1))
        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if selectedRow == 1  || selectedRow == 2 {
            adjustTableViewHeight(true) // CMAIOS-2176
            routingNumberTextField.setBorderColor(mode: .selected_color)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if selectedRow == 1 {
            routingDelegate.saveRoutingCellValue(selectedRow, value: textField.text!)
            if textField.text!.count >= 9 {
                adjustTableViewHeight(true)
                routingNumberTextField.setBorderColor(mode: .deselcted_color)
            } else {
                if textField.text!.count == 0 {
                    adjustTableViewHeight(false)
                }
                routingNumberTextField.setBorderColor(mode: .error_color)
                if let routingNumber = routingNumberTextField.text, routingNumber.count < 9 { //CMAIOS-2171/76, if user moves to other fields and we are displaying the err msg.
                    adjustTableViewHeight(false)
                }
            }
        } else if selectedRow == 2 {
            routingDelegate.saveRoutingCellValue(selectedRow, value: textField.text!)
            if textField.text!.count > 3 {
                routingNumberTextField.setBorderColor(mode: .deselcted_color)
            } else {
                //CMAIOS-2214 show error message if accnt no < 4
                adjustTableViewHeight(false)
                routingNumberTextField.setBorderColor(mode: .error_color)
            }
        }
        self.routingDelegate.checkNicknameValidation("")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if selectedRow == 1 {
            let maxCharacters = 9
            if string.isEmpty {
                let currentTextFieldData = textField.text! as NSString
                let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
                if newString.length <= 9 { // CMAIOS-2176
                    self.adjustTableViewHeight(true)
                }
                //CMAIOS-2214 do not show live validation
                /* // CMAIOS-2227
                 self.routingDelegate.saveNickNameFieldData("")
                 */
                return newString.length <= maxCharacters
            }
            let restrictedSet = NSCharacterSet(charactersIn: "0123456789").inverted
            let compSeperated = string.components(separatedBy: restrictedSet)
            let filteredData = compSeperated.joined(separator: "")
            if filteredData.isEmpty {
                return false
            }
            let currentTextFieldData = textField.text! as NSString
            let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
            if newString.length == 9 {
                self.adjustTableViewHeight(true)
                self.getBankingImageForNumber(number: newString as String)
                //CMAIOS-2214 do not show live validation if the user tries to enter 10th digit
            } else { // CMAIOS-2176
                self.adjustTableViewHeight(true)
            }
             return newString.length <= maxCharacters
        } else if selectedRow == 2 {
            let maxCharacters = 17
            if textField.text?.count ?? 0 >= maxCharacters && string != "" { //CMAIOS-2815 To avoid updating the logic if max characters are more than the limit
                return false
            }
            let userDefaults = UserDefaults.standard
            let bankCheckVal = userDefaults.object(forKey: "bankCheckVal") as? String
            if string.isEmpty {
                let currentTextFieldData = textField.text! as NSString
                let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
                if newString.length > 3 {
                    self.adjustTableViewHeight(true)
                    if(bankCheckVal == "NoVal"){
                        self.nameVal = ""
                    }else if(bankCheckVal == "Checking") {
                        self.nameVal = "Checking-" + newString.substring(from: (newString.length - 4))
                    }else if !((bankCheckVal?.isEmpty) == nil){//Having Bank name
                        self.nameVal = (bankCheckVal?.prefix(8) ?? "") + "-" + newString.substring(from: (newString.length - 4))
                    }
                    self.routingDelegate.saveNickNameFieldData(self.nameVal ?? "")
                    return newString.length <= maxCharacters
                }else { // CMAIOS-2147
                    routingDelegate.saveRoutingCellValue(selectedRow, value: newString as String)
                    self.routingDelegate.saveNickNameFieldData(((bankCheckVal == "NoVal") ? "" : bankCheckVal) ?? "")
                }
                //CMAIOS-2214 do not show live validation
                return newString.length <= maxCharacters
            }
            let restrictedSet = NSCharacterSet(charactersIn: "0123456789").inverted
            let compSeperated = string.components(separatedBy: restrictedSet)
            let filteredData = compSeperated.joined(separator: "")
            if filteredData.isEmpty {
                return false
            }
            let currentTextFieldData = textField.text! as NSString
            let newString: NSString = currentTextFieldData.replacingCharacters(in: range, with: string) as NSString
            if ((newString.length > 3) && (newString.length <= maxCharacters)){
                self.adjustTableViewHeight(true)
                
                if(bankCheckVal == "NoVal"){
                    self.nameVal = ""
                }else if(bankCheckVal == "Checking") {
                    self.nameVal = "Checking-" + textField.text!.suffix(3) + string
                }else if !((bankCheckVal?.isEmpty) == nil){//Having Bank name
                    self.nameVal = (bankCheckVal?.prefix(8) ?? "") + "-" + textField.text!.suffix(3) + string
                }
                self.routingDelegate.saveNickNameFieldData(self.nameVal ?? "")
                return newString.length <= maxCharacters
            } else {
                //CMAIOS-2214 do not show live validation
                self.routingDelegate.saveNickNameFieldData(((bankCheckVal == "NoVal") ? "" : bankCheckVal) ?? "")
                return newString.length <= maxCharacters
            }
        }
        else {
            return true
        }
    }
    
    func getBankingImageForNumber(number: String?) {
        guard let accNum = number, number != "" && accNum.count >= 9 else {
            //CMA-2450
            //self.routingDelegate.saveBankImgFieldData(UIImage(named: "routingBorderImage")!)
            return
        }
        APIRequests.shared.mauiGetBankImgFromRoutingNum(routNum: accNum as String , completionHandler: {isSuccess, valuee, err in
            if isSuccess {
                let userDefault = UserDefaults.standard
                if let value = valuee, let bankName = value.first?.bankName, !bankName.isEmpty {
                    if bankName.lowercased() == "checking" {
                        userDefault.set("Checking", forKey: "bankCheckVal")
                        self.routingDelegate.saveNickNameFieldData(bankName)
                    } else {
                        if bankName.count >= 13 {
                            self.routingDelegate.saveNickNameFieldData(String(bankName.prefix(13)))
                            userDefault.set((String(bankName.prefix(13))), forKey: "bankCheckVal")
                        } else {
                            self.routingDelegate.saveNickNameFieldData(bankName)
                            userDefault.set(bankName, forKey: "bankCheckVal")
                        }
                    }
                    userDefault.synchronize()
                }
                //CMA-2450
                //self.routingDelegate.saveBankImgFieldData(UIImage(named: "routingBorderImage")!)
                //self.routBankImg.image = UIImage(named: bankImg)
            }/*else{ //Error response
                self.routingDelegate.saveBankImgFieldData(UIImage(named: "routingBorderImage")!)
            }*/
        })
    }
    
    func adjustTableViewHeight(_ isWarningShown: Bool) {
        if !isWarningShown {
            if self.warningLabel.isHidden {
                self.routingDelegate.reloadRoutingTableCell(selectedRow, isWarningShown: true)
            }
            routingNumberTextField.setBorderColor(mode: .error_color)
            self.warningLabel.text = (selectedRow == 1) ? "Routing number must be 9 digits" : "Account number must be 4-17 digits"
            self.warningLabel.isHidden = isWarningShown
            let userDef = UserDefaults.standard
            if (selectedRow == 1) {
                userDef.set("NoVal", forKey: "bankCheckVal")
                userDef.synchronize()
            }
            self.routBankImg.image = UIImage(named: "routingBorderImage")
        } else {
            if !self.warningLabel.isHidden {
                self.routingDelegate.reloadRoutingTableCell(selectedRow, isWarningShown: false)
            }
            routingNumberTextField.setBorderColor(mode: .selected_color)
            self.warningLabel.isHidden = isWarningShown
        }
    }
    
    override func prepareForReuse() {
        routingNumberTextField.text = ""
    }
}
