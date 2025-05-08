//
//  ManualRebootViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 06/01/23.
//

import UIKit

class ManualRebootViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            goToBackController()
        } else {
            cancel()
        }
    }
    
    @IBOutlet weak var networkDownLabel: UILabel!
    @IBOutlet weak var restartLabel: UILabel!
    @IBOutlet weak var letsDoItButton: RoundedButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        APIRequests.shared.isReloadNotRequiredForMaui = true
      buttonDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiElements()
    }
    
    func uiElements(){
        switch(MyWifiManager.shared.getWifiType()) {
        case "Gateway","Equipment":
            self.restartLabel.isHidden = false
            self.networkDownLabel.text = "Sorry your network is down"
            self.restartLabel.text = "Let’s try a manual restart."
            //CMAIOS-2215 update GA tags with custom param
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
        case "Modem":
            self.networkDownLabel.text = "Let’s try a manual restart"
            self.restartLabel.isHidden = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_MODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        default:
            break
        }
        self.letsDoItButton.setTitle("Let’s do it", for: .normal)
    }
    
    func goToBackController() {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        dismiss(animated: true)
    }
    
    func cancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.dismissCompletion = { (dismiss) in
                self.navigateToMyAccountScreen(fromVC: self)
            }
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    @IBAction func letsDoitAction(_ sender: Any) {
        IntentsManager.sharedInstance.screenFlow = .networkDown
        guard let vc = RestartFlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
