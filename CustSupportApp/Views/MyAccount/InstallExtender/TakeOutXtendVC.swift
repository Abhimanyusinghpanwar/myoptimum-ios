//
//  TakeOutXtendVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 8/30/22.
//

import UIKit

class TakeOutXtendVC: BaseViewController {
    
    @IBOutlet weak var takeOutPrimaryBtn: UIButton!
    @IBOutlet weak var xtenderTypeImageView: UIImageView!
    @IBOutlet weak var takeOutXtendHeaderLbl: UILabel!
    @IBOutlet weak var takeOutXtendStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var takeOutXtendStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var takeOutXtendStackViewPrimaryBtnBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_takeout_extender.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateUI() {
        switch ExtenderDataManager.shared.extenderType {
        case 5:
            xtenderTypeImageView.image = UIImage(named: "extender_takeout5")
        case 7:
            xtenderTypeImageView.image = UIImage(named: "Extender-6E-and-power-cable")
        default:
            xtenderTypeImageView.image = UIImage(named: "extender_takeout6")
        }
        if CurrentDevice.isLargeScreenDevice() {
            takeOutXtendHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            takeOutXtendStackViewLeadingConstraint.constant = 30.0
            takeOutXtendStackViewTrailingConstraint.constant = 30.0
            takeOutXtendHeaderLbl.setLineHeight(1.21)
        } else {
            takeOutXtendHeaderLbl.setLineHeight(1.15)
        }
    }
    @IBAction func nextAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
