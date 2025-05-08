//
//  RestartFlowViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 13/01/23.
//

import UIKit

class RestartFlowViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            IntentsManager.sharedInstance.screenFlow = .none
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }

    @IBOutlet weak var imThereButton: RoundedButton!
    @IBOutlet weak var pluginImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var isTypeModem : Bool = false
    var selectedType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        let gatewayDetails = MyWifiManager.shared.getMasterGatewayDetails()
        switch MyWifiManager.shared.getWifiType() {
        case "Gateway":
            self.headerLabel.text = "Go to your Gateway"
            self.imThereButton.setTitle("I’m there", for: .normal)
            self.titleLabel.isHidden = true
            if let equipType = gatewayDetails.equipmentType as String?, !equipType.isEmpty, let gatewayImageName = ManualRestartImageManager.shared.getManualRestartImage(equipmentType: equipType) as String?, !gatewayImageName.isEmpty, let gateWayImage = UIImage(named: gatewayImageName) {
                self.pluginImage.image = gateWayImage
            } else {
                self.pluginImage.image = UIImage(named: "plug")
            }
        case "Equipment":
            if !isTypeModem {
                selectedType = "router"
                self.headerLabel.text = "Go to your router"
                self.imThereButton.setTitle("I’m at my router", for: .normal)
                self.titleLabel.isHidden = true
                if let equipType = gatewayDetails.equipmentType as String?, !equipType.isEmpty, let gatewayImageName = ManualRestartImageManager.shared.getManualRestartImage(equipmentType: equipType) as String?, !gatewayImageName.isEmpty, let gateWayImage = UIImage(named: gatewayImageName) {
                    self.pluginImage.image = gateWayImage
                } else {
                    self.pluginImage.image = UIImage(named: "Router_Dlink")
                }
            } else {
                selectedType = "modem"
                self.titleLabel.isHidden = false
                self.headerLabel.text = "Now go to your modem"
                self.imThereButton.setTitle("I’m at my modem", for: .normal)
                self.pluginImage.image = UIImage(named: "Modem")
            }
        case "Modem":
            self.titleLabel.isHidden = false
            selectedType = ""
            self.headerLabel.text = "Go to your modem"
            self.imThereButton.setTitle("I’m at my modem", for: .normal)
            if let equipType = gatewayDetails.equipmentType as String?, !equipType.isEmpty, let gatewayImageName = ManualRestartImageManager.shared.getManualRestartImage(equipmentType: equipType) as String?, !gatewayImageName.isEmpty, let gateWayImage = UIImage(named: gatewayImageName) {
                self.pluginImage.image = gateWayImage
            } else {
                self.pluginImage.image = UIImage(named: "Modem")
            }
        default:
            self.headerLabel.text = "Go to your Gateway"
            self.imThereButton.setTitle("I’m there", for: .normal)
            self.titleLabel.isHidden = true
            if let equipType = gatewayDetails.equipmentType as String?, !equipType.isEmpty, let gatewayImageName = ManualRestartImageManager.shared.getManualRestartImage(equipmentType: equipType) as String?, !gatewayImageName.isEmpty, let gateWayImage = UIImage(named: gatewayImageName) {
                self.pluginImage.image = gateWayImage
            } else {
                self.pluginImage.image = UIImage(named: "plug")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch MyWifiManager.shared.getWifiType() {
        case "Gateway":
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GOTO_GATEWAY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        case "Equipment":
            if !isTypeModem {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GOTO_ROUTER.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
            } else {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GOTO_MODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                
            }
        case "Modem":
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GOTOMODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        default:
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_GOTO_GATEWAY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        }
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController")
        //vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
        }
  
    @IBAction func imThereAction(_ sender: Any) {
        guard let vc = UnplugGatewayViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
        vc.wifiLegacyType = selectedType
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
