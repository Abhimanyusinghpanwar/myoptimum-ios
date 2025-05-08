//
//  XtendIsNowPairedVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/3/22.
//  CMAIOS-223
//  GA-extender5_extender_paired/extender6_extender_paired

import UIKit

class XtendIsNowPairedVC: UIViewController {

    @IBOutlet weak var xtendNowPairedHeaderLabel: UILabel!
    @IBOutlet weak var xtendNowPairedPrimaryBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendNowPairedImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendNowPairedImageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendNowPairedImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendNowPairedUI()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_extender_paired.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateXtendNowPairedUI() {
        let extender = ExtenderDataManager.shared.extenderType
        
        switch extender {
        case 5:
            xtendNowPairedImageView.image = UIImage(named: "Xtend-5-Paired-Extender")
        case 7:
            xtendNowPairedImageView.image = UIImage(named: "Extender-6E-front-view-paired")
        default:
            xtendNowPairedImageView.image = UIImage(named: "Extender-6-front-view-paired")
        }
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendNowPairedImageViewLeadingConstraint.constant = 30.0
            xtendNowPairedImageViewTrailingConstraint.constant = 30.0
            xtendNowPairedHeaderLabel.font = UIFont(name: "Regular-Bold", size: 24)
            xtendNowPairedHeaderLabel.setLineHeight(1.21)
        } else {
            xtendNowPairedHeaderLabel.setLineHeight(1.15)
        }
    }
    @IBAction func xtendIsPairedPrimaryBtn(_ sender: Any) {
//        CMAIOS-824: The revised flow to remove rename extender screen.
//        let vc = XtendInstallRenameVC()
//        self.navigationController?.pushViewController(vc, animated: true)
//
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallSuccessVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

