//
//  ExtenderWeakFindGoodSpotViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 2/21/23.
//

import UIKit

class ExtenderWeakFindGoodSpotViewController: BaseViewController {

    @IBOutlet weak var regularLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CurrentDevice.isLargeScreenDevice(){
            regularLbl.setLineHeight(1.2)
        }else {
            regularLbl.setLineHeight(1.2)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_move_extender_to_goodspot.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    @IBAction func findGoodSpotForWeakExtenderBtn(_ sender: Any) {
        ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallHalfWayVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
