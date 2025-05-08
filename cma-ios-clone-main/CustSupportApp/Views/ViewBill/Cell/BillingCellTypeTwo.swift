//
//  BillingCellTypeTwo.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 12/06/24.
//

import Foundation
import UIKit

protocol ViewDetialsButtonDelegate: AnyObject {
    func captureViewButtonTap(indexPath: IndexPath)
    func captureMoreInfoTap(indexPath: IndexPath)
}

class BillingHistoryCellTypeTwo: UITableViewCell {

    @IBOutlet weak var label_Amount: UILabel!
    @IBOutlet weak var label_Type: UILabel!
    @IBOutlet weak var label_FailMessage: UILabel!
    @IBOutlet weak var label_MonthYear: UILabel!
    @IBOutlet weak var buttonViewDetails: UIButton!
    @IBOutlet weak var failed_Message_View: UIView!
    @IBOutlet weak var stackFailureMessage: UIStackView!
    @IBOutlet weak var vectorImageView: UIImageView!
    @IBOutlet weak var label_ViewDetails: UILabel!
    @IBOutlet weak var moreInfoButton: RoundedButton!
    @IBOutlet weak var moreButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewDetailsLabelBottomContraint: NSLayoutConstraint!
    
    var delegateViewDetailsButtonTap: ViewDetialsButtonDelegate?
    var indexPath: IndexPath?
    let sharedManager =  QuickPayManager.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
                
    func setupHistoryCell(historyInfo: HistoryInfo, indexpath: IndexPath, schedulePaymentCount: Int = 0, showDetails: Bool = false) {
        if historyInfo.type == .failedPayments {
            self.label_Type.text = self.getPaymentTitle(historyInfo: historyInfo)
            self.label_FailMessage.text = self.getFailureErrorMessage(historyInfo: historyInfo)
            self.label_MonthYear.text = QuickPayManager.shared.getHistoryMonth(date: historyInfo.date, format: "MMMM d")
            self.failed_Message_View.layer.cornerRadius = 15.0
            self.buttonViewDetails.addTarget(self, action: #selector(viewDetails(sender:)), for: .touchUpInside)
            self.moreInfoButton.addTarget(self, action: #selector(moreInfoButtonTap(sender:)), for: .touchUpInside)
            self.indexPath = indexpath
            //CMAIOS-2634 show view Details for OTP
            if historyInfo.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT" && historyInfo.isImmediate == true {
                self.failed_Message_View.isHidden = false
                self.moreInfoButton.isHidden = true
                self.vectorImageView.isHidden =  false
                self.label_ViewDetails.isHidden = false
                self.buttonViewDetails.isHidden = false
                self.failed_Message_View.isHidden = !showDetails
                self.vectorImageView.image =  UIImage(named: showDetails ? "VectorUp": "VectorDown")
                self.label_ViewDetails.text = showDetails ? "Hide details": "View details"
                moreButtonBottomConstraint.priority = UILayoutPriority(250)
                viewDetailsLabelBottomContraint.priority = UILayoutPriority(999)
            } else {
                // CMAIOS-2348
                if let failureWithIn30Days = historyInfo.failureWithIn30Days, failureWithIn30Days == true {
                    self.failed_Message_View.isHidden = true
                    self.moreInfoButton.isHidden = false
                    self.vectorImageView.isHidden =  true
                    self.label_ViewDetails.isHidden = true
                    self.buttonViewDetails.isHidden = true
                    moreButtonBottomConstraint.priority = UILayoutPriority(999)
                    viewDetailsLabelBottomContraint.priority = UILayoutPriority(250)
                } else {
                    self.failed_Message_View.isHidden = false
                    self.moreInfoButton.isHidden = true
                    self.vectorImageView.isHidden =  false
                    self.label_ViewDetails.isHidden = false
                    self.buttonViewDetails.isHidden = false
                    self.failed_Message_View.isHidden = !showDetails
                    self.vectorImageView.image =  UIImage(named: showDetails ? "VectorUp": "VectorDown")
                    self.label_ViewDetails.text = showDetails ? "Hide details": "View details"
                    moreButtonBottomConstraint.priority = UILayoutPriority(250)
                    viewDetailsLabelBottomContraint.priority = UILayoutPriority(999)
                }
            }
            
            if CurrentDevice.isLargeScreenDevice() {
                self.label_Type.setLineHeight(1.21)
                self.label_FailMessage.setLineHeight(1.21)
            } else {
                self.label_Type.setLineHeight(1.15)
                self.label_FailMessage.setLineHeight(1.15)
            }
        }
    }
    
    func getAmountForPaymentType(historyInfo: HistoryInfo) -> String {
        var amountString = ""
        amountString = "$" + String(format: "%.2f", historyInfo.amount?.amount ?? "")
        return amountString
    }
    
    @objc func viewDetails(sender: UIButton) {
        if let viewDetialsCell =  sender.superview?.superview as? BillingHistoryCellTypeTwo {
           self.delegateViewDetailsButtonTap?.captureViewButtonTap(indexPath: viewDetialsCell.indexPath ?? IndexPath(row: 0, section: 0))
        }
    }
        
    @objc func moreInfoButtonTap(sender: UIButton) {
        if let moreInfoButton =  sender.superview?.superview as? BillingHistoryCellTypeTwo {
            self.delegateViewDetailsButtonTap?.captureMoreInfoTap(indexPath: moreInfoButton.indexPath ?? IndexPath(row: 0, section: 0))
        }
    }

    /* paymentPosted */
    // PAYMENT_POSTED_AUTO_PAYMENT
    // PAYMENT_POSTED_ONETIME_PAYMENT
    
    /* paymentStatus */
    // PAYMENT_STATUS_UNSPECIFIED
    // PAYMENT_STATUS_SCHEDULED
    // PAYMENT_STATUS_IN_PROGRESS
    // PAYMENT_STATUS_SUCCESS
    // PAYMENT_STATUS_FAILURE
    // PAYMENT_STATUS_CANCELLED
    
    // CMAIOS-2304
    // Finds the failure type (Auto pay, scheduled or one time payments) for title
    func getPaymentTitle(historyInfo: HistoryInfo) -> String {
        var title = ""
        switch (historyInfo.isImmediate, historyInfo.paymentPosted) {
        case (_, "PAYMENT_POSTED_AUTO_PAYMENT"):
            title = "Auto Pay for $" + String(format: "%.2f", historyInfo.amount?.amount ?? "") + " failed"
        case (true, "PAYMENT_POSTED_ONETIME_PAYMENT")://CMAIOS-2635
            title = "Payment for $" + String(format: "%.2f", historyInfo.amount?.amount ?? "") + " failed"
        case (nil, _):
            title = "Scheduled payment for $" + String(format: "%.2f", historyInfo.amount?.amount ?? "") + " failed"
        default: break
        }
        return title
    }
    
    // CMAIOS-2304
    // Get error message using the error code("errorCode") from api response
    func getFailureErrorMessage(historyInfo: HistoryInfo) -> String {
        var errorMessage = ""
        let genericConstant = "Due to technical difficulties, we couldn't process your payment."
        let isFromCC = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: historyInfo.paymethod).0
        let defaultNickName = isFromCC ? DefaultPaymentName.cardName : DefaultPaymentName.checkingAccount
        switch historyInfo.errorCode?.lowercased() {
        case "30170":
//            errorMessage = "Your bank says " + self.getBankDetails(payMethod: historyInfo.paymethod) + " doesn't have enough available funds or is no longer valid."
            errorMessage = "Your bank says " + sharedManager.mopDetailsForFailure(defaultNickName: "using your " + defaultNickName, payMethod: historyInfo.paymethod) + " doesn't have enough available funds or is no longer valid." // CMAIOS-2637
        case "903":
            //CMAIOS-2482, CMAIOS-2481, CMAIOS-2637
//            errorMessage = "Looks like the expiration date for your " + self.getCardDetails(payMethod: historyInfo.paymethod) + " is not correct."
            errorMessage = "Looks like the expiration date for your " + sharedManager.mopDetailsForFailure(defaultNickName: defaultNickName, payMethod: historyInfo.paymethod) + " is not correct."
        case "522", "card is expired":
            //CMAIOS-2303, CMAIOS-2452
            errorMessage = self.getPayMethodName(payMethod: historyInfo.paymethod) + " has expired."
        case "invalid bank or finbr", "numeric value out of range for xml tag eftt_bacct", "xml tag eftt_bacct should be numeric.", "750","751","307":
//            errorMessage = "Looks like the routing number for your " + self.getBankDetails(payMethod: historyInfo.paymethod) + " is not correct."
            errorMessage = "Looks like the routing number for your " + sharedManager.mopDetailsForFailure(defaultNickName: defaultNickName, payMethod: historyInfo.paymethod) + " is not correct." // CMAIOS-2637
        case "credit floor", "do not honor", "processor decline", "restraint", "lost/stolen", "suspected fraud", "insufficient fund", "pickup", "revocation of authorization","302","502","534","303","806","501","596","521","571", "572" : //CMAIOS-2350- CMA-2363 //CMAIOS-2389 // CMAIOS-2637
            let textString = historyInfo.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" ?  "the credit " : "its "
//            errorMessage = "Your card provider says " + self.getCardDetails(payMethod: historyInfo.paymethod) + " has reached " + textString + "limit or is no longer valid."
            errorMessage = "Your card provider says " + sharedManager.mopDetailsForFailure(defaultNickName: "using your " + defaultNickName, payMethod: historyInfo.paymethod) + " has reached " + textString + "limit or is no longer valid."
        case "30167", "30168", "90001"://CMAIOS-2345, CMA-2365, CMAIOS-2637
            errorMessage = "A payment with same amount and payment method was already made on the same date."
        case "invalid cc number", "invalid institution code","201","591","602","603": //CMA-2364,
//            errorMessage = "Looks like the card number for your " + self.getCardDetails(payMethod: historyInfo.paymethod) + " is not correct."
            errorMessage = "Looks like the card number for your " + sharedManager.mopDetailsForFailure(defaultNickName: defaultNickName, payMethod: historyInfo.paymethod) + " is not correct." // CMAIOS-2637
        case "generic error", "401": //CMA-2362
            errorMessage = genericConstant
        default:
            errorMessage = genericConstant
        }
        return errorMessage
    }
    
    //Get all the bank MOP details
    func getBankDetails(payMethod: PayMethod?) -> String {
        var paymethodTitle = ""
        let bankPaymethodInfo = QuickPayManager.shared.getLastFourDigitsOrNicknameForBank(payMethod: payMethod)
        if !bankPaymethodInfo.1.isEmpty {
            paymethodTitle = bankPaymethodInfo.1
        } else if !bankPaymethodInfo.0.isEmpty {
            paymethodTitle = "checking account ending with " + bankPaymethodInfo.0
        } else {
            paymethodTitle = "checking account"
        }
        return paymethodTitle
    }
    
    //Get all the card MOP details  //CMAIOS-2389
    func getCardDetails(payMethod: PayMethod?) -> String {
        var nickName = ""
        let cardPaymethodInfo = QuickPayManager.shared.getLastFourDigitsOfCCNickName(paymethod: payMethod)
        let dynamicCardName = cardPaymethodInfo.0
        let dynamicLastDigits = cardPaymethodInfo.1
        if !dynamicCardName.isEmpty {
            nickName = dynamicCardName
        } else if !dynamicLastDigits.isEmpty {
            nickName = "card ending with " + dynamicLastDigits
        } else {
            nickName = "credit/debit card"
        }
        return nickName
    }
    
    //Get any payMethod name irrespective of any MOP
    func getPayMethodName(payMethod: PayMethod?) -> String{
        return payMethod?.name?.components(separatedBy: "/").last ?? ""
    }
    
}

// CMAIOS:-2637
struct DefaultPaymentName {
    static let cardName = "credit/debit card"
    static let checkingAccount = "checking account"
}
