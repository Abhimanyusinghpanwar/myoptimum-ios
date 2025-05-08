//
//  AutoPaySettingsViewController.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 20/03/23.
//

import UIKit
import SafariServices

class AutoPaySettingsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var isFromHomePageCard = false
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var subTitleTextLabel: UILabel!
    @IBOutlet weak var goToOptimumBtn: RoundedButton!
    @IBOutlet weak var crossBtn: UIButton!
    //Params set for CMAIOS-2229
    var fromCardExpirySpotlight = false
    var titleLabelText = ""
    var subtitleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if isFromHomePageCard {
            if fromCardExpirySpotlight {
                configureUIForCardExpirySettings()
            } else {
                self.titleTextLabel.textColor = .white
                self.subTitleTextLabel.textColor = .white
                self.titleTextLabel.text = "Your bill this month exceeds the max limit you set for Auto Pay"
                self.subTitleTextLabel.text = ConfigService.shared.maxLimitExceedText
                self.view.backgroundColor = midnightBlueRGB
                self.goToOptimumBtn.backgroundColor = .white
                self.goToOptimumBtn.setTitleColor(midnightBlueRGB, for: .normal)
                self.goToOptimumBtn.setTitle(ConfigService.shared.maxLimitExceedButton, for: .normal)
                self.crossBtn.setImage(UIImage(named: "icon_close_white"), for: .normal)
            }
        } else {
            self.titleTextLabel.textColor = UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
            self.titleTextLabel.text = ConfigService.shared.grandFatheredText
            self.subTitleTextLabel.text = ""
            self.view.backgroundColor = .white
            self.goToOptimumBtn.backgroundColor = UIColor(red: 246.0/255.0, green: 102.0/255, blue: 8.0/255.0, alpha: 1.0)
            self.goToOptimumBtn.setTitleColor(.white, for: .normal)
            self.goToOptimumBtn.setTitle(ConfigService.shared.grandFatheredButton, for: .normal)
            self.crossBtn.setImage(UIImage(named: "closeImage"), for: .normal)
        }
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_AUTOPAY_LEGACYCUSTOMER.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func configureUIForCardExpirySettings() {
        self.titleTextLabel.textColor = .white
        self.subTitleTextLabel.textColor = .white
        self.titleTextLabel.text = self.titleLabelText
        self.subTitleTextLabel.text = self.subtitleText
        self.view.backgroundColor = midnightBlueRGB
        self.goToOptimumBtn.backgroundColor = .white
        self.goToOptimumBtn.setTitleColor(midnightBlueRGB, for: .normal)
        self.goToOptimumBtn.setTitle("Go to Optimum website", for: .normal)
        self.crossBtn.setImage(UIImage(named: "icon_close_white"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.AUTOPAY_LEGACY_EXCEED_MAX_LIMIT_SCREEN.rawValue,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        //        self.dismiss(animated: true)
        if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func goToOptimumBtnTapped(_ sender: Any) {
        guard let url = URL(string: ConfigService.shared.grandFatheredLink) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if !isFromHomePageCard {
            QuickPayManager.shared.isFromAutoPaySettingsView = true
//            QuickPayManager.shared.ismauiMainApiInProgress = (true, false)
            if let billingView = self.presentingViewController as? BillingViewContrller {
                billingView.dismiss(animated: true)
            }
        }
    }

}
