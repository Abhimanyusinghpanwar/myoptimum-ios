//
//  CancelPaymentErrorViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 14/12/23.
//

import UIKit

class CancelPaymentErrorViewController: UIViewController {
    
    @IBOutlet weak var titleErrorMessageLbl: UILabel!
    @IBOutlet weak var subTitleMessageLbl: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    
    var errorMessageString: (headerTitle:String, subtitle:String) = ("", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialUiSetup()
        initialDateSetup()
    }

    private func initialUiSetup() {
        titleErrorMessageLbl.setDefaultLineHeight()
        subTitleMessageLbl.setDefaultLineHeight()
    }
    
    private func initialDateSetup() {
        titleErrorMessageLbl.text = errorMessageString.headerTitle
        subTitleMessageLbl.text = errorMessageString.subtitle
    }
    
    @IBAction func onTapAction(_ sender: Any) {
        self.dismissToCancelPayment()
    }
    
    func dismissToCancelPayment(){
        //CMAIOS-2099
        if let paymentHistory = self.navigationController?.viewControllers.filter({$0 is PaymentHistoryViewController}).first as? PaymentHistoryViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(paymentHistory, animated: true)
            }
            return
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
