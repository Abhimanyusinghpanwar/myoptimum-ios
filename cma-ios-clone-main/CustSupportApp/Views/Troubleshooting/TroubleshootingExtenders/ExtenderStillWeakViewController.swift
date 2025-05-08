//
//  ExtenderStillWeakViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 2/17/23.
//

import UIKit

class ExtenderStillWeakViewController: BaseViewController {
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var regularLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CurrentDevice.isLargeScreenDevice(){
            headerLbl.setLineHeight(1.21)
            regularLbl.setLineHeight(1.2)
        }else {
            headerLbl.setLineHeight(1.15)
            regularLbl.setLineHeight(1.2)
        }
        if let extenderFriendlyName = ExtenderDataManager.shared.extenderFriendlyName, !extenderFriendlyName.isEmpty {
            headerLbl.text = "Your \(extenderFriendlyName) Extender still has a weak signal"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_issue_notresolved_at_newspot.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    @IBAction func extenderStillWeakPrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallHalfWayVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func extenderStillWeakSecBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallContactSupportVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
