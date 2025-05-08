//
//  XtendInstallManualPickSpotVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/7/22.
// GA-extender5_manual_placement_goodspot/extender6_manual_placement_goodspot

import UIKit

class XtendInstallManualPickSpotVC: BaseViewController {
    

    @IBOutlet weak var manualPickSpotImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var manualPickSpotImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var manualPickSpotBottomStackViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateManualPickSpotUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_manual_placement_goodspot.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateManualPickSpotUI() {
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            manualPickSpotImageViewLeadingConstraint.constant = 30.0
            manualPickSpotImageViewTrailingConstraint.constant = 30.0
            headerLbl.setLineHeight(1.21)
            headerLbl.font = UIFont(name: "Regular-Bold", size: 24)
        } else {
            headerLbl.setLineHeight(1.15)
        }
    }
    
    @IBAction func manualPickSpotPrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pluginXtendVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func manualPickSpotSecondaryBtn(_ sender: Any) {
        self.navigationController?.popToViewController(ofClass: XtendPlacementHelpWiFiWorksBestVC.self)
    }
}
