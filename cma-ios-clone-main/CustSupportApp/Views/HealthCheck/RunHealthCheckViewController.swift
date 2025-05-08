//
//  RunHealthCheckViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 05/01/23.
//

import UIKit

class RunHealthCheckViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.none
            self.navigationController?.popViewController(animated: true)
        } else {
            cancel()
        }
    }

    @IBOutlet weak var discLabel: UILabel!
    @IBAction func runHealthCheckAction(_ sender: Any) {
        DispatchQueue.main.async {
            guard let vc = EquipmentCheckViewController.instantiateWithIdentifier(from: .HealthCheck) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_START.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
    }

    func cancel() {
        IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.none
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
             cancelVC.modalPresentationStyle = .fullScreen
             self.navigationController?.pushViewController(cancelVC, animated: true)
         }
    }
}
