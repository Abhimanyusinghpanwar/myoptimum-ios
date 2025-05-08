//
//  OutageDetectionFailedViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 27/01/23.
//

import UIKit

class OutageDetectionFailedViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var seconderyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_TS_CHECK_OUTAGE_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
    }
    

    @IBAction func okLetsContinueAction(_ sender: Any) {
        let vc = UIStoryboard(name: "TroubleshootInternet", bundle: Bundle.main).instantiateViewController(withIdentifier: "TroubleshootingDiagnoseViewController") as! TroubleshootingDiagnoseViewController
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func maybelaterAction(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
