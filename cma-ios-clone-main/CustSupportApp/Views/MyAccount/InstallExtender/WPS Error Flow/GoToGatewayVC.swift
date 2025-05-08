//
//  GoToGatewayVC.swift
//  CustSupportApp
//
//  Created by Vishnu Samikeri on 8/23/23.
//

import UIKit

class GoToGatewayVC: BaseViewController {
    enum WpsErrorFlow {
    case GoToGatewayOne
    case GoToGatewayTwo
    }
    
    @IBOutlet weak var gotoGatewayImageView: UIImageView!
    @IBOutlet weak var gotoGatewayHeaderLbl: UILabel!
    @IBOutlet weak var gotoGatewayPrimaryLbl: UILabel!
    @IBOutlet weak var gotoGatewayPrimaryBtn: RoundedButton!
    private let gwDetails = MyWifiManager.shared.getMasterGatewayDetails()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let equipType = gwDetails.equipmentType as String?, !equipType.isEmpty, let gatewayImageName = ManualRestartImageManager.shared.getManualRestartImage(equipmentType: equipType) as String?, !gatewayImageName.isEmpty, let gateWayImage = UIImage(named: gatewayImageName) {
            self.gotoGatewayImageView.image = gateWayImage
            ExtenderDataManager.shared.gwEquipType = equipType
        } else {
            self.gotoGatewayImageView.image = UIImage(named: "plug")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    private func updateUI() {
        let wpsFailCount = ExtenderDataManager.shared.wpsFailCount
        if wpsFailCount >= 1 {
            gotoGatewayHeaderLbl.text = "There was a problem pairing your Extender. Let’s try it one more time."
        } else {
            gotoGatewayHeaderLbl.text = "First we’ll put your Gateway into pairing mode"
        }
        let screenTag = wpsFailCount >= 1 ? ExtenderInstallScreens.ExtenderManualPairing.extender_manual_pairing_first_time_failed : ExtenderInstallScreens.ExtenderManualPairing.extender_manual_pairing_go_to_gateway
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag.rawValue,
                                                                  CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue,
                                                                   EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    @IBAction func gotoGatewayPrimaryBtnAction(_ sender: Any) {
        gotoGatewayPrimaryBtn.isSelected = true
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "gatewayPairingModeVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
