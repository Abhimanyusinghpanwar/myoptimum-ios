//
//  CancelVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 9/2/22.
//  GA-extender5_install_cancel/extender6_install_cancel

import UIKit

class CancelVC: UIViewController {
    
    var dismissCompletion:((Bool) -> Void)?
    var refreshDelegate: RefreshSignalProtocol?
    @IBOutlet weak var cancelVCHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            cancelVCHeaderLabel.text = "Are you sure you want to cancel troubleshooting?"
        }
        cancelVCHeaderLabel.setLineHeight(1.14)
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_CANCEL_TROUBLESHOOTING.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_install_cancel.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
        }
    }
    @IBAction func yesBtn(_ sender: Any) {
        ExtenderDataManager.shared.extenderAPIFailure = false
        ExtenderDataManager.shared.wpsFailCount = 0
        APIRequests.shared.isReloadNotRequiredForMaui = false
        if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
        } else {
            navigationController?.dismiss(animated: true)
        }
    }
    
    @IBAction func noBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if refreshDelegate != nil {
            //            refreshDelegate?.refreshData()
        }
    }
}
