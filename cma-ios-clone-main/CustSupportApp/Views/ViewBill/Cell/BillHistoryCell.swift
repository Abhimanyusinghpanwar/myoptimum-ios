//
//  BillHistoryCell.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 21/09/23.
//

import UIKit


protocol InsertButtonDelegate: AnyObject {
    func captureInsertButtonTap(sender: InsertButton)
}

class BillHistoryCell: UITableViewCell {

    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var insertsStack: UIStackView!
    @IBOutlet weak var label_Amount: UILabel!
    @IBOutlet weak var label_Type: UILabel!
    @IBOutlet weak var label_MonthYear: UILabel!
    @IBOutlet weak var insertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewButtonInserts: UIView!
    
    @IBOutlet weak var strikeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var strikeLabel: UILabel!
    var delegateInsertButtonTap: InsertButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.strikeLabel.isHidden = true
        strikeLabel.backgroundColor = UIColor(red: 0.95, green: 0.21, blue: 0.34, alpha: 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.strikeLabel.isHidden = true
    }
            
    func addInsertButton(titles: [BillInsert], indexpath: IndexPath) {
        for (_, view) in self.viewButtonInserts.subviews.enumerated() {
            view.removeFromSuperview()
        }
//        let viewBillButton = InsertButton(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        let viewBillButton = InsertButton()
        viewBillButton.setupStyle()
        viewBillButton.setTitle("View Bill", for: .normal)
        viewBillButton.sizeToFit()
        viewBillButton.frame = CGRect(x: 0, y: 0, width: viewBillButton.frame.width + 40, height: 30)
//        viewBillButton.frame = CGRect(x: viewBillButton.frame.origin.x, y: viewBillButton.frame.origin.y, width: viewBillButton.frame.width + 40, height: viewBillButton.frame.height)
        viewBillButton.tag = 0
        viewBillButton.indexpath = indexpath
        viewBillButton.setCorderRadiues()
        viewBillButton.addTarget(self, action: #selector(self.insertButtonTap(_:)), for: .touchUpInside)
        self.viewButtonInserts.addSubview(viewBillButton)
        
        if titles.isEmpty {
            return
        }
        
        for (index, title) in titles.enumerated() {
//            let yPosition = ((index + 1) * 30) + 10
            let yPosition = ((index + 1) * 30) + (10 * (index + 1))
            let otherButtons = InsertButton()
            otherButtons.tag = (index + 1)
            otherButtons.indexpath = indexpath
            otherButtons.setupStyle(withBorder: true)
            otherButtons.setTitle(title.alertText, for: .normal)
            otherButtons.sizeToFit()
//            otherButtons.frame = CGRect(x: otherButtons.frame.origin.x, y: CGFloat(yPosition), width: otherButtons.frame.width + 40, height: otherButtons.frame.height)
            var width = otherButtons.frame.width + 40
            if width > self.viewButtonInserts.frame.width {
                width = self.viewButtonInserts.frame.width
            }
            otherButtons.frame = CGRect(x: 0, y: CGFloat(yPosition), width: width, height: 30)
            otherButtons.setCorderRadiues()
            otherButtons.addTarget(self, action: #selector(self.insertButtonTap(_:)), for: .touchUpInside)
            self.viewButtonInserts.addSubview(otherButtons)
        }
    }
    
    func setupHistoryCell(historyInfo: HistoryInfo, indexpath: IndexPath, schedulePaymentCount: Int = 0) {
        self.updateUIforInsertButton(historyInfo: historyInfo, type: historyInfo.type ?? .otherPayments)
        if historyInfo.type == .otherPayments || historyInfo.type == .cancelledPayments {
            self.insertViewHeightConstraint.constant = 0
            if let paymenthod = historyInfo.paymethod {
                let paymethodInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: paymenthod)
                let getMaskeCardNumber = QuickPayManager.shared.getMaskedCardNumer(payMethod: paymenthod)
                // CMAIOS-2098
                // (credit card or bank account, payment name, last 4 digits of card)
                switch (paymethodInfo.0, paymethodInfo.1 == "", getMaskeCardNumber == "") {
                case (true, _, true):
                    self.cardImage.image =  UIImage(named: paymethodInfo.2)
                    self.cardName.text = "Credit/Debit card"
                case (true, _,false):
                    self.cardImage.image = UIImage(named: paymethodInfo.2)
                    self.cardName.text = "•••• " + getMaskeCardNumber
                default: // Bank account
                    self.cardImage.image = UIImage(named: paymethodInfo.2)
                    self.cardName.text = (paymethodInfo.1 == "") ? "Checking account": paymethodInfo.1
                }
                // CMAIOS-2098
                /*
                 self.cardImage.image = UIImage(named: paymethodInfo.2)
                 self.cardName.text = paymethodInfo.1
                 */
            }
        } else {
            // Inserts has to be shown only for last 3 months
            // If not inserts show only View bill button
            
            let scheduledCount = (schedulePaymentCount > 0) ? 1: 0 // CMAIOS-1942
            
            switch (indexpath.section < (scheduledCount + 3), historyInfo.inserts?.count ?? 0 > 0) {
            case (true, true):
                if let inserts = historyInfo.inserts, !inserts.isEmpty {
                    self.addInsertButton(titles: inserts, indexpath: indexpath)
                    self.insertViewHeightConstraint.constant = CGFloat(inserts.count * 30) + CGFloat(inserts.count * 10) + 30
                }
            case (false, _), (true, false):
                self.addInsertButton(titles: [], indexpath: indexpath)
                self.insertViewHeightConstraint.constant = 30.0
            }
        }
    }
    
    func updateUIforInsertButton(historyInfo: HistoryInfo, type: PaymentType) {
        if type == .otherPayments || type == .cancelledPayments {
            self.label_Type.text = self.getPaymentTitle(historyInfo: historyInfo)
            if historyInfo.paymentStatus == "PAYMENT_STATUS_CANCELLED" {
                self.label_Amount.attributedText = self.getAmountForPaymentType(historyInfo: historyInfo).addStrikeThrough(color: .clear)
                self.strikeLabel.isHidden = false
                self.strikeWidthConstraint.constant = self.label_Amount.intrinsicContentSize.width + 5
            } else {
                self.strikeLabel.isHidden = true
                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: self.getAmountForPaymentType(historyInfo: historyInfo), attributes: [:])
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                             value: 0,
                                             range: NSRange(location: 0,length: attributeString.length))
                self.label_Amount.attributedText = attributeString
            }
            self.viewButtonInserts.isHidden = true
            self.cardImage.isHidden = false
            self.cardName.isHidden = false
        } else {
            self.label_Type.text = "Bill statement issued"
//            self.label_Amount.text = self.getAmountForPaymentType(historyInfo: historyInfo)
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: self.getAmountForPaymentType(historyInfo: historyInfo), attributes: [:])
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: 0,
                                         range: NSRange(location: 0,length: attributeString.length))
            self.label_Amount.attributedText = attributeString
            self.cardImage.isHidden = true
            self.cardName.isHidden = true
            self.viewButtonInserts.isHidden = false
        }
        if CurrentDevice.isLargeScreenDevice() {
            self.label_Type.setLineHeight(1.21)
        } else {
            self.label_Type.setLineHeight(1.15)
        }
        self.label_Type.textAlignment = .left
        self.label_MonthYear.text = QuickPayManager.shared.getHistoryMonth(date: historyInfo.date, format: "MMMM d")
    }
    
    func getAmountForPaymentType(historyInfo: HistoryInfo) -> String {
        var amountString = ""
        switch historyInfo.paymentStatus {
        case "PAYMENT_STATUS_SUCCESS":
            amountString = "-$" + String(format: "%.2f", historyInfo.amount?.amount ?? "")
        case "PAYMENT_STATUS_CANCELLED":
            amountString = "$" + String(format: "%.2f", historyInfo.amount?.amount ?? "")
        default:
            amountString = "$" + String(format: "%.2f", historyInfo.amount?.amount ?? "")
        }
        return amountString
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
    
    func getPaymentTitle(historyInfo: HistoryInfo) -> String {
        var title = ""
        switch historyInfo.paymentStatus {
        case "PAYMENT_STATUS_SUCCESS":
            let dateString = CommonUtility.convertDateStringFormats(dateString: historyInfo.paymentDate ?? "", dateFormat: "MMM. d")
            if historyInfo.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" {
                title = "Auto Pay received"
            } else {
                title = "Payment received" //9dfd996374b - Issue with resolve conflicts
            }
        case "PAYMENT_STATUS_CANCELLED":
//            [Dynamic] scheduled payment method - Auto Pay or One time payment for [dynamic date ex Month Day] canceled [Dynamic negative number with -line through ex -$25.00]-
            let dateString = CommonUtility.convertDateStringFormats(dateString: historyInfo.paymentDate ?? "", dateFormat: "MMM. d")
            if historyInfo.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" {
                title = "Scheduled Auto Pay for \(dateString) canceled"
            } else {
                title = "Scheduled payment for \(dateString) canceled"
            }
            default: break
        }
        return title
    }
    
     @IBAction func insertButtonTap( _ sender: InsertButton) {
         self.delegateInsertButtonTap?.captureInsertButtonTap(sender: sender)
     }
}
