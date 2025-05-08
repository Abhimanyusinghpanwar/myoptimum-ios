//
//  AutoPayUpdateAlertViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 2/26/23.
//

import UIKit

class AutoPayUpdateAlertViewController: UIViewController {
    enum State {
        case cardExpired
        case cardSettings
    }
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    var payMethod: PayMethod!
    var state: State = .cardExpired {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryAction.layer.borderColor = UIColor.white.cgColor
    }
    
    func updateUI() {
        let info = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
        let text = "Your Auto Pay card \(info.1) has expired."
        switch state {
        case .cardExpired:
            titleLabel.text = text
            primaryAction.setTitle("Update the expiration date", for: .normal)
        case .cardSettings:
            primaryAction.setTitle("Update Auto Pay settings", for: .normal)
            titleLabel.text = "Please update your Auto Pay settings"
            subTitleLabel.attributedText = text.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 20) as Any], and: info.1, with: [.font: UIFont(name: "Regular-Bold", size: 20) as Any])
        }
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onTapPrimaryAction(_ sender: UIButton) {
    }
    
    @IBAction func onTapSecondaryAction(_ sender: UIButton) {
    }
}
