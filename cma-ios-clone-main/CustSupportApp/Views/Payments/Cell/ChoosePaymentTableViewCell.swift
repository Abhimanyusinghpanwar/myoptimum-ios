//
//  ChoosePaymentTableViewCell.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 19/12/22.
//

import UIKit

class ChoosePaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var label_CardName: UILabel!
    @IBOutlet weak var label_CardExpiry: UILabel!
    @IBOutlet weak var checkImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpCellData(payMethod: PayMethod) {
        let cardInfo = QuickPayManager.shared.payMethodInfo(payMethod: payMethod)
        self.label_CardName.text = cardInfo.0
        //CMA-2450
        self.cardImage.image = UIImage(named: cardInfo.1)
        self.cardView.setBorderUIForBankMOP(paymethod: payMethod)
        var payMethodName = cardInfo.2
        if payMethodName == "Checking account" {
            payMethodName = payMethodName.replacingOccurrences(of: " account", with: "")
        }
        setImageAndText(payMethodName, payMethod: payMethod)
    }
    
    func setImageAndText(_ text: String, payMethod: PayMethod) {
        var textExpiry = NSAttributedString()

        if payMethod.creditCardPayMethod?.isCardExpired == true {
            let expiryText =  (text == "Checking") ? text: "Expired \(text)   " + "Update"
            textExpiry = expiryText.attributedString(with: [.font: UIFont(name: "Regular-Bold", size: 15) as Any, .foregroundColor: UIColor(red: 0.954, green: 0.208, blue: 0.342, alpha: 1)], and: "Update", with: [.font: UIFont(name: "Regular-Bold", size: 15) as Any, .foregroundColor: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1)])
        } else {
            self.label_CardExpiry.textColor = .black
            let attributedText = (text == "Checking") ? text: "Exp. \(text)"
            textExpiry = attributedText.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 15) as Any, .foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)], and: "")
        }
        let attributedText = NSMutableAttributedString(string: "•••• ")
        let lastFourDigit = getLastFourDigits(payMethod: payMethod).attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 15) as Any, .foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)], and: "")
        attributedText.append(lastFourDigit)
        attributedText.append(NSAttributedString(string: (payMethod.creditCardPayMethod?.isCardExpired == true) ? "  " : "   "))
        attributedText.append(textExpiry)
        self.label_CardExpiry.attributedText = attributedText
    }
    
    func getLastFourDigits(payMethod: PayMethod) -> String {
        var stringLastFourDigit = ""
        if let maskedBankAccountNumber = payMethod.bankEftPayMethod?.maskedBankAccountNumber, !maskedBankAccountNumber.isEmpty {
            // If maskedBankAccountNumber is not empty, get the last four digits
            stringLastFourDigit = String(maskedBankAccountNumber.suffix(4))
        } else if let maskedCreditCardNumber = payMethod.creditCardPayMethod?.maskedCreditCardNumber, !maskedCreditCardNumber.isEmpty {
            // If maskedBankAccountNumber is empty, check the credit card number
            stringLastFourDigit = maskedCreditCardNumber.count == 4 ? maskedCreditCardNumber : ""
        }
        return stringLastFourDigit
    }
}
