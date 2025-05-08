//
//  RestartMyGateWayViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 11/01/23.
//

import UIKit

class RestartMyGateWayViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var deadZoneLabel: UILabel!
    @IBOutlet weak var restartButton: RoundedButton!
    @IBOutlet weak var mayBeLaterButton: RoundedButton!
    var devices: [ConnectedDevice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        checkInternet()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.SYSTEMIC_RESTART.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func checkInternet(){
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            self.headerLabel.text = "Okay. Let's restart your Gateway."
            self.deadZoneLabel.text = "This should take about 5 minutes."
            self.restartButton.setTitle("Restart my Gateway", for: .normal)
            
        }else if MyWifiManager.shared.getWifiType() == "Equipment" {
            self.headerLabel.text = "Okay, Let’s restart your equipment"
            self.deadZoneLabel.text = "This should take about 5 minutes."
            self.restartButton.setTitle("Restart my equipment", for: .normal)
        }
        else if MyWifiManager.shared.getWifiType() == "Modem" {
            self.headerLabel.text = "Okay, Let’s restart your modem"
            self.deadZoneLabel.text = "This should take about 5 minutes."
            self.restartButton.setTitle("Restart my modem", for: .normal)
        }
    }
    @IBAction func restartMyAction(_ sender: Any) {
        guard let vc = RestartCountDownTimerViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
        vc.isFromManualRestart = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mayBeLaterAction(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
            IntentsManager.sharedInstance.screenFlow = .none
        })
    }
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    }
    
   


