//
//  SchedulePaymentCellTableViewCell.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 30/11/23.
//

import UIKit

protocol CancelScheduleButtonDelegate: AnyObject {
    func captureCancelButtonTap(row: Int)
}

class SchedulePaymentCellTableViewCell: UITableViewCell {
    @IBOutlet weak var labelScheduleInfo: UILabel!
    @IBOutlet weak var labelScheduleTitle: UILabel!
    @IBOutlet weak var cancelButton: UIControl!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var bottomLeadingSupportLabel: UILabel!
    @IBOutlet weak var bottomTrailingSupportLabel: UILabel!
    @IBOutlet weak var topLeadingSupportLabel: UILabel!
    @IBOutlet weak var topTrailingSupportLabel: UILabel!
    
    var delegateCancelButtonTap: CancelScheduleButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addBorders(cornerRadiusFor: CornerRadius) {
        switch cornerRadiusFor {
        case .onlyTop:
            self.baseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.topLeadingSupportLabel.isHidden = true
            self.topTrailingSupportLabel.isHidden = true
            self.bottomLeadingSupportLabel.isHidden = false
            self.bottomTrailingSupportLabel.isHidden = false
        case .onlyBottom:
            self.baseView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.topLeadingSupportLabel.isHidden = false
            self.topTrailingSupportLabel.isHidden = false
            self.bottomLeadingSupportLabel.isHidden = true
            self.bottomTrailingSupportLabel.isHidden = true
        case .allSides:
            self.baseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.topLeadingSupportLabel.isHidden = true
            self.topTrailingSupportLabel.isHidden = true
            self.bottomLeadingSupportLabel.isHidden = true
            self.bottomTrailingSupportLabel.isHidden = true
        }
    }
    /*
     1) Your [dynamic amount scheduled ex $125.00] Auto Pay is scheduled for [Dynamic amount due ex Sep. 4] using [dynamic card]
        LINK: Cancel payment (CMA-1801)
     2) Your [dynamic amount scheduled ex $125.00] payment is scheduled for [Dynamic amount due ex Sep. 4] using [dynamic card]
     */
    func setupSchedulePaymentCell(historyInfo: HistoryInfo, indexpath: IndexPath) {
        if CurrentDevice.isLargeScreenDevice() {
            self.labelScheduleInfo.setLineHeight(1.21)
        } else {
            self.labelScheduleInfo.setLineHeight(1.15)
        }
        if let paymenthod = historyInfo.paymethod, let amount = historyInfo.amount?.amount, let paymentDate = historyInfo.paymentDate  {
            let amountValue = String(format: "%.2f", amount) /* CMAIOS:- 1866 */
            /*
             let paymethodInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: paymenthod)
             */
            let paymethodInfo = self.getOnlyPayMethodName(payMethod: paymenthod)
            let dateString = CommonUtility.convertDateStringFormats(dateString: paymentDate, dateFormat: "MMM. d")
            let autoPayOrOneTime = (historyInfo.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT") ? "payment": "Auto Pay"
            let cardInfoTitle = (paymethodInfo == "") ? "": " using \(paymethodInfo)"
            if autoPayOrOneTime == "Auto Pay" { //CMAIOS-2652 fix
                var scheduleAmount = 0.0
                if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0 {
                    scheduleAmount = Double(QuickPayManager.shared.getCurrentAmount()) ?? 0
                }
                self.labelScheduleInfo.text = "Your $\(scheduleAmount) Auto Pay is scheduled for \(dateString)\(cardInfoTitle)"
            } else {
                self.labelScheduleInfo.text = "Your $\(amountValue) \(autoPayOrOneTime) is scheduled for \(dateString)\(cardInfoTitle)"
            }
            self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTap(_:)), for: .touchUpInside)
            self.cancelButton.tag = indexpath.row
            
            let currentDate = Date().getModifiedCurrentDate()
            let modifiedPaymentDate = CommonUtility.getDateFromDueDateString(dueDateString: paymentDate, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            
            if modifiedPaymentDate > currentDate {
                self.cancelButton.isHidden = false
            } else {
                self.cancelButton.isHidden = true
            }
            
            /*
            let currentDate = Date().getModifiedCurrentDate()
            let modifiedPaymentDate = CommonUtility.getDateFromDueDateString(dueDateString: paymentDate, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            let difference = currentDate.distance(from: modifiedPaymentDate, only: .day)
            //        If  difference == 1 same day
            //        If  difference <= 0 Future day
            //        If  difference > 1  passeds days
            switch (difference == 1, difference <= 0, difference > 1) {
            case (true, _, _), (_, _, true):
                self.cancelButton.isHidden = true
            case (_, true, _):
                self.cancelButton.isHidden = false
            default: break
            }
            */
        }
    }
    
    @IBAction func cancelButtonTap( _ sender: UIControl) {
        self.delegateCancelButtonTap?.captureCancelButtonTap(row: sender.tag)
    }
    
    func getOnlyPayMethodName(payMethod: PayMethod?) -> String {
        return payMethod?.name?.components(separatedBy: "/").last ?? ""
    }
}

 enum CornerRadius: Equatable {
    case onlyTop
    case onlyBottom
    case allSides
}

