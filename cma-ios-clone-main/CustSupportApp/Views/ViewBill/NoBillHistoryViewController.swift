//
//  BillHistoryViewController.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 29/08/23.
//

import UIKit

class NoBillHistoryViewController: UIViewController {
    @IBOutlet weak var billHistotyImage: UIImageView!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var label_SubTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureUI()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_VIEW_MY_BILL_NEW_CUSTOMER.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func configureUI() {
        if CurrentDevice.isLargeScreenDevice() {
            self.label_Title.setLineHeight(1.21)
            self.label_SubTitle.setLineHeight(1.21)
        } else {
            self.label_Title.setLineHeight(1.15)
            self.label_SubTitle.setLineHeight(1.15)
        }
        self.label_Title.textAlignment = .center
        self.label_SubTitle.textAlignment = .center
        self.label_Title.text = "Hey \(MyWifiManager.shared.getFirstName()), thanks for choosing Optimum!"
        self.label_SubTitle.text = "Your first bill isn’t quite ready yet.\nCheck back \(self.getNextDueDate()) to view it."
    }
    
    private func getNextDueDate() -> String {
        var dateText = "later"
        if QuickPayManager.shared.isNoBillHistoryWithNextPayDate() {
            dateText = "on " + QuickPayManager.shared.getNextStatementDate()
        }
        return dateText
    }
    
    @IBAction func actionOkay(_ sender: Any) {
        if let pdfviewController = self.navigationController?.viewControllers.filter({$0.isKind(of: BillPDFViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(pdfviewController, animated: true)
        } else if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(billingView, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
