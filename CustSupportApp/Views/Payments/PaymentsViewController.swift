//
//  PaymentsViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 07/11/22.
//

import UIKit

class PaymentsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func NavigateToBackVc(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapOnCardScaning(_ sender: Any) {
        let scanner = CreditCardScanner()
        scanner.completionHandler = {cardNumber, expirationDate in
            if let cardType = CreditCardValidator.cardType(cardNumber: cardNumber){
                let cardName = cardType.cardName
                DispatchQueue.main.async {
//                    self.creditCardScannerTypeLabel.text = cardName
//                    self.creditCardScannerNumberLabel.text = cardNumber
//                    self.creditCardScannerDateLabel.text = expirationDate
                }
            }
        }
        DispatchQueue.main.async {
            self.navigationController?.present(scanner, animated: true)
        }
    }
    
}
