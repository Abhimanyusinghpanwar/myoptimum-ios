//
//  RenameCustomTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 09/11/22.
//

import UIKit

class RenameCustomTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var networkNameTextField: FloatLabelTextField!
    @IBOutlet weak var networkSelectionConfirmImage: UIImageView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var customLabel: UILabel!
    var customDelegate: RenameCustomDelegate!
    private let errorFont = UIFont(name: "Regular-Bold", size: 15)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.networkNameTextField.delegate = self
        // Initialization code
        self.networkNameTextField.setBorderColor(mode: BorderColor.deselcted_color)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.networkNameTextField.setBorderColor(mode: BorderColor.selected_color)
        customDelegate.updateCellSelection()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentTextFieldData = textField.text else {
            return true
        }
        guard let textRange = Range(range, in: currentTextFieldData) else {
            return false
        }
        let newString = currentTextFieldData.replacingCharacters(in: textRange, with: string)
        if newString.count > 32 {
            return false
        }
        if newString.isEmpty {
            resetUI()
            return true
        }
        if newString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && string == " " {
            configureErrorView(message: "Your Optimum Stream name can't start or end with a space")
            return true
        }
        if newString.hasPrefix(" ") || newString.hasSuffix(" ") {
            configureErrorView(message: "Your Optimum Stream name can't start or end with a space")
            return true
        }
        let restrictedStreamNames = ["altice","suddenlink","optimum","cablewifi"]
        let newStringLowercased = newString.lowercased
        if  restrictedStreamNames.contains(where: {
            newStringLowercased().contains($0)
        }){
            configureErrorView(message: "The words Optimum, Altice, Suddenlink, or Cablewifi may not be used")
            return true
        }
        resetUI()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
        super.setSelected(selected, animated: animated)
    }
    
    func updateUIFontForTV(isTv: Bool = false) {
        self.customLabel.font = isTv ? UIFont(name: "Regular-Medium", size: 20) : UIFont(name: "Regular-Regular", size: 20)
    }
    
}

extension RenameCustomTableViewCell {
    func showSecondView() {
        self.secondView.isHidden = false
    }
    func hideSecondView() {
        self.secondView.isHidden = true
    }
    func configureErrorView(message: String) {
        errorView.isHidden = false
        errorLabel.text = message
        errorLabel.font = errorFont
        errorLabel.textColor = UIColor(named: "statusRed")
        self.networkNameTextField.setBorderColor(mode: .error_color)
    }
    func resetUI() {
        errorView.isHidden = true
        self.networkNameTextField.setBorderColor(mode: .selected_color)
    }
}
