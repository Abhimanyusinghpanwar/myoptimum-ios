//
//  EnterPaymentViewController.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 21/12/23.
//

import UIKit
import IQKeyboardManagerSwift

class EnterPaymentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDollar: UILabel!
    @IBOutlet weak var txtFldAmount: UITextField!
    @IBOutlet weak var lblMinimumMsg: UILabel!
    var callback : ((String, PayMethod?, Bool) -> Void)?
    var finAmt = ""
    var amountStr = ""
    var balanceStateText = ""
    var errMsgState = "Normal"
    var payMethod: PayMethod?
//    var updatedPaymentMethod : PayMethod?
    var flowType: flowType?
    var isAutoPaymentErrorFlow = false
    var isOneTimeFailureFlow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.loadUI()
        self.trackEvents()
    }
    
    func loadUI() {
        self.txtFldAmount.delegate = self
        self.txtFldAmount.becomeFirstResponder()
        /*
        self.txtFldAmount.text = amountStr == "0" ? "": amountStr
         */
        self.txtFldAmount.text = "" // CMAIOS-1977
        if amountStr == "0" {
            errMsgState = "Min"
        }
        self.lblMinimumMsg.isHidden = true
        self.txtFldAmount.addCancelDoneOnKeyboardWithTarget(self, cancelAction: #selector(cancelButtonAction), doneAction: #selector(doneButtonAction), titleText: "")
        self.changeCursorDollorColor()
        //        lblAmount.text = balanceStateText
        //        self.checkforAttributeLabel()
        self.processAmountDueLabelString() // CMAIOS-2007
    }
    
    /*
    private func checkforAttributeLabel() {
        if balanceStateText.contains("Includes")  {
            let strValues = balanceStateText.components(separatedBy: "\nIncludes")
            let subText = "includes \n\(strValues[1])"
            let fullText = strValues[0] + subText
            lblAmount.attributedText = fullText.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 16) as Any], and: subText, with: [.font: UIFont(name: "Regular-Bold", size: 16) as Any])
        } else {
            lblAmount.text =  balanceStateText.isEmpty ? "" : processAmountDueLabelString(balanceStateText)
        }
    }
     */
    
    func changeCursorDollorColor() {
        if (txtFldAmount.text?.count ?? 0 > 0) {
            self.lblDollar.textColor = .black
            self.txtFldAmount.tintColor = .black
        } else {
            self.lblDollar.textColor = .gray
            self.txtFldAmount.tintColor = .gray
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.validateUserAmount(textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.lblMinimumMsg.isHidden = true
        let str = (textField.text ?? " ") + string
        if !(str.count <= 8) {
            return false
        }else {
            return true
        }
    }
    
    func validateUserAmount(_ textField: String) {
        self.lblMinimumMsg.isHidden = true
        if !(finAmt.count > 0)
        {
            finAmt = textField
        }
        var strInt: String = ""
        var strDec: String = ""
        if (((textField.first == "." ) || (textField.count == 0)) || (String(textField.prefix(2)) == "0.")) {
            errMsgState = "Min"
        }else if((textField.count > 0) && (textField.count <= 8 )){ //This is having both integer and 2decimal val's
            var strVal: String = textField
            if(strVal.first == "0"){
                strVal.remove(at: strVal.startIndex)
            }
            if (strVal.contains("."))  {//&& (strVal?.count ?? 0 >= 7)){ //Here spliting the currency based on decimal val
                let StrArr = strVal.components(separatedBy: ".")
                strInt = StrArr[0]
                strDec = StrArr[1]
                if !(strDec.count <= 2) {
                    strDec =  String(strDec.prefix(2))
                }else if (strDec.count == 0) {
                    strInt = strVal
                }
            }else {
                strInt = strVal
            }
            
            let firstVal: String = strInt.replacingOccurrences(of: ",", with: "")
            if((firstVal.count <= 4) && (strDec.count <= 2)) {
                errMsgState = "Normal"
                if !(strDec.count == 0) { //If the decimal val is present
                    if(((firstVal.count == 4) && !(strInt.contains(","))) && !(strInt.contains("."))) {
                        strInt.insert(",", at: strInt.index(strInt.startIndex, offsetBy: 1))
                    }
                    txtFldAmount.text =  strInt + "." + strDec
                    finAmt = strInt + "." + strDec
                }else if (firstVal.count <= 3){
                    txtFldAmount.text =  firstVal
                    finAmt = firstVal
                }else  if ((!(strInt.contains(",")) && (strInt.count == 4))  && !(strInt.contains("."))) {
                    strInt.insert(",", at: strInt.index(strInt.startIndex, offsetBy: 1))
                    txtFldAmount.text =  strInt
                    finAmt = strInt
                }else {
                    txtFldAmount.text =  strInt
                    finAmt = strInt
                }
            } else if !(strInt.last == "."){
                strInt = String(strInt.dropLast())
                txtFldAmount.text = strInt
                finAmt = strInt
            } else {
                errMsgState = "Max"
            }
        } else {
            txtFldAmount.text = finAmt
        }
        self.changeCursorDollorColor()
    }
    
    // Verify entered amount
    private func validateAmountLimit(value: String) -> AmountLimit {
        var amountLimit: AmountLimit = .lessThan1
        let parsed = value.replacingOccurrences(of: ",", with: "")
        let finalValue = parsed.replacingOccurrences(of: "$", with: "")
        let doubleVal = Double(finalValue) ?? 0
        if doubleVal < 1 {
            amountLimit = .lessThan1
        } else if doubleVal >= 1 {
            amountLimit = .greaterThan1
        }
        return amountLimit
    }
    
    @objc func cancelButtonAction() {
        switch flowType {
        case .noPayments: // CMAIOS-2230
            if let myBillView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
                self.navigationController?.popToViewController(myBillView, animated: true)
            }
            return
        default:
            if let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first {
                self.callback?(amountStr, payMethod, isOneTimeFailureFlow)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func doneButtonAction() {
        self.lblMinimumMsg.font = UIFont(name: "Regular-Bold", size: 16)
        
        switch self.validateAmountLimit(value: txtFldAmount.text ?? "") {
        case .lessThan1:
            self.lblMinimumMsg.isHidden = false
            self.lblMinimumMsg.text = "Minimum payment amount is $1"
        case .greaterThan1:
            self.lblMinimumMsg.isHidden = true
            var finAmt: String = txtFldAmount.text ?? ""
            if (finAmt.contains(",")) {
                finAmt = finAmt.replacingOccurrences(of: ",", with: "")
            }
            if (finAmt.last == "."){
                finAmt = finAmt.replacingOccurrences(of: ".", with: "")
            }
            if finAmt == "" {
                finAmt = amountStr
            }
            updateModifiedAmount(amount: finAmt)
        }
    }
    
    private func updateModifiedAmount(amount: String) {
        //Fixed navigation issue
        if let makePaymentVC = self.navigationController?.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first as? MakePaymentViewController {
            if self.isOneTimeFailureFlow {
                makePaymentVC.updatedPayMethod = self.payMethod
                makePaymentVC.isAmountEdited = true
                makePaymentVC.paymentAmount = amount
            } else {
                self.callback?(amount, payMethod, isOneTimeFailureFlow)
            }
            self.navigationController?.popToViewController(makePaymentVC, animated: true)
        } else {
            self.moveToMakePaymentScreen(amount: amount)
        }
    }
    
    private func moveToMakePaymentScreen(amount: String) {
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock()
        makePayVC.state = QuickPayManager.shared.getInitialScreenFlowState()
        makePayVC.noDueAmountValue = amount
        makePayVC.noDueFlow = true
        if self.isOneTimeFailureFlow {
            makePayVC.updatedPayMethod = self.payMethod
        } else {
            if payMethod != nil { //CMAIOS-2161 & CMAIOS-2162
                makePayVC.firstTimeCardFlow = true
                makePayVC.tempPaymethod = self.payMethod
            }
        }
//        makePayVC.updatedPayMethod = self.updatedPaymentMethod //CMAIOS-2144
        makePayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
    private func trackEvents() {
        var screenTag = ""
        switch QuickPayManager.shared.getInitialScreenFlowState() {
        case .defaultDisclaimer: break
        case .expireDateError: break
        case .dueCreditApplied: break
        case .manualBlock: break
        case .autoPay: break
        case .noDue:
            screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_ENTER_PAYMENT_AMOUNT_NO_PAYMENT_DUE.rawValue
        case .pastDue:
            //CMAIOS-2286
            let deAuthState = QuickPayManager.shared.getDeAuthState()
            screenTag = deAuthState == "DE_AUTH_STATE_DEAUTH"  ? DeAuthServices.Billing_Deauth_Service_Suspended_Enter_Payment_Amount.rawValue : PaymentScreens.MYBILL_MAKEAPAYMENT_ENTERPAYMENTAMOUNT_PAST_DUE_30.rawValue
        case .normal:
            screenTag = balanceStateText.contains("scheduled") ? PaymentScreens.MYBILL_MAKEAPAYMENT_ENTER_PAYMENT_AMOUNT_WITH_SCHEDULED_PAYMENT.rawValue : PaymentScreens.MYBILL_MAKEAPAYMENT_ENTER_PAYMENT_AMOUNT_AMOUNT_DUE.rawValue
        }
        
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
    }
    //CMAIOS-1923
    func isFullAmountEntered() -> Bool {
        let updatedAmount = Double(self.amountStr)
        return QuickPayManager.shared.getCurrentAmount() == String(format: "%.2f", updatedAmount ?? 0)
    }
    /*
    //CMAIOS-1923
    private func processAmountDueLabelString(_ str: String) -> String {
        let flow = QuickPayManager.shared.initialScreenFlow
        if flow == .autoPay || flow == .normal {
            switch (QuickPayManager.shared.getScheduledPaymentAmount() > 0, self.isFullAmountEntered()) {
            case (true, false):
                return "Amount due after scheduled payment: $\(QuickPayManager.shared.getCurrentAmount())"
            case (false, false):
                return "Amount due is $\(QuickPayManager.shared.getCurrentAmount())"
            case (_, true):
                return str
            }
        }
        return str
    }
     */
    
    // CMAIOS-2007
    private func processAmountDueLabelString() {
        switch QuickPayManager.shared.initialScreenFlow {
        case .normal, .autoPay:
            switch (QuickPayManager.shared.getScheduledPaymentAmountsTillDueDate() > 0) {
            case true:
                var amount = "0"
                let dueAfterSchedulePayments = (Double(QuickPayManager.shared.getCurrentAmount()) ?? 0) - Double(QuickPayManager.shared.getScheduledPaymentAmountsTillDueDate())
                if dueAfterSchedulePayments > 0 {
                    amount = String(format: "%.2f", dueAfterSchedulePayments)
                }
                lblAmount.text = "Amount due after scheduled payment: $\(amount)."
            case false:
                lblAmount.text = "Amount due is $\(QuickPayManager.shared.getCurrentAmount())."
            }
        case .pastDue:
            if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" || QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
               // Pay minimum [Dynamic past due balance: EX: $270.00] to avoid service interruption
                lblAmount.text = "Pay minimum $\(QuickPayManager.shared.getPastDueAmount()) to " + (QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" ? "restore your services" : "avoid service interruption")
            } else {
                let subTxt = "includes \n" + "$" + QuickPayManager.shared.getPastDueAmount() + " past due."
                let mainTxt = "Amount due is $\(QuickPayManager.shared.getCurrentAmount()), \(subTxt)"
                lblAmount.attributedText = mainTxt.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 16) as Any], and: subTxt, with: [.font: UIFont(name: "Regular-Bold", size: 16) as Any])
            }
        case .noDue:
            lblAmount.text = "No payment is due at this time."
        default: break
        }
    }

}

enum AmountLimit {
    case lessThan1
    case greaterThan1
}
