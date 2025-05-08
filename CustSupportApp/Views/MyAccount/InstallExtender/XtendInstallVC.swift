//
//  XtendInstallVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 9/1/22.
//  GA-extender5_find_goodspot

import UIKit

class XtendInstallVC: BaseViewController {
    @IBOutlet weak var xtendInstallHeaderLbl: UILabel!
    @IBOutlet weak var xtendInstallStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallBottomBtnBottomConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendInstallUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_find_goodspot.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    
    func updateXtendInstallUI() {
        if CurrentDevice.isLargeScreenDevice() {
            xtendInstallHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendInstallStackViewLeadingConstraint.constant = 30.0
            xtendInstallStackViewTrailingConstraint.constant = 30.0
            xtendInstallHeaderLbl.setLineHeight(1.21)
        } else {
            xtendInstallHeaderLbl.setLineHeight(1.15)
        }
    }
    @IBAction func letsDoItBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallHalfWayVC")
        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
