//
//  ManageHouseholdViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/20/22.
//

import UIKit

class ManageHouseholdViewController: UIViewController {
    @IBOutlet var subHeaderTitle: UILabel!
    @IBOutlet var firstDescription: UILabel!
    @IBOutlet var secondDescription: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    @IBOutlet weak var subheaderStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func configureUI() {
        primaryAction.titleLabel?.font = UIFont(name: "Regular-Bold", size: 18)
        secondaryAction.titleLabel?.font = UIFont(name: "Regular-Semibold", size: 18)
        let smartWifiValue = MyWifiManager.shared.isGateWayWifi5OrAbove()
         switch smartWifiValue {
         case 6...:
            firstDescription.text = "\u{2022} Encourage healthy screen time habits! Pause the Internet for bedtime, homework and more - automatically."
            secondDescription.text = "\u{2022} See how much time everyone spends online"
         case 5:
            firstDescription.text = "\u{2022} Encourage healthy screen time habits!"
            secondDescription.text = "\u{2022} See how much time everyone spends online"
         default:
            //handle text below WIFI5
             break
         }
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        setUpStackViewSpacing()
    }
    
    ///Method for handling UI text and attributes
    func setUpStackViewSpacing() {
        if currentScreenWidth < xibDesignWidth {
           self.subheaderStackView.spacing = 4
        }
        if currentScreenWidth >= 375.0 {
            self.subheaderStackView.spacing = 10.0
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onTapAction(_ sender: UIButton) {
        if sender == primaryAction, let vc = ProfileNameViewController.instantiate() {
            vc.state = .add(isMaster: false)
            navigationController?.pushViewController(vc, animated: true)
        } else if sender == secondaryAction {
            navigationController?.dismiss(animated: true)
        }
    }
}
