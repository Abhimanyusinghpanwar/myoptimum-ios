//
//  XtendUpAndRunningVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 8/31/22.
//

import UIKit

class XtendUpAndRunningVC: BaseViewController {
    
    @IBOutlet weak var regulartextLbl: UILabel!
    @IBOutlet weak var boldTextLbl: UILabel!
    @IBOutlet weak var extenderImageView: UIImageView!
    @IBOutlet weak var xtendUpAndRunningStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendUpAndRunningStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendUpAndRunningBtnBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APIRequests.shared.isReloadNotRequiredForMaui = true
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideLeftBarItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //For Firebase Analytics
        let eventParameters: [String:Any] = [EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_get_extender_up_and_running.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance, EVENT_PARAMETER_CUSTOM_TYPE_Extender: getExtenderTypeString(),CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue]
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: eventParameters)
    }
    func updateUI() {
        
        if CurrentDevice.isLargeScreenDevice() {
            boldTextLbl.font = UIFont(name: "Regular-Bold", size: 24)
            regulartextLbl.font = UIFont(name: "Regular-Regular", size: 20)
            xtendUpAndRunningStackViewLeadingConstraint.constant = 30.0
            xtendUpAndRunningStackViewTrailingConstraint.constant = 30.0
            boldTextLbl.setLineHeight(1.21)
            regulartextLbl.setLineHeight(1.2)
        } else {
            boldTextLbl.setLineHeight(1.15)
            regulartextLbl.setLineHeight(1.2)
        }
        switch ExtenderDataManager.shared.extenderType {
        case 5:
            extenderImageView.image = UIImage(named: "extender5")
        case 7:
            extenderImageView.image = UIImage(named: "Extender-6E-3-4frontview")
        default:
            extenderImageView.image = UIImage(named: "extender6")
        }
    }
    
    @IBAction func letsGoBtn(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "takeOutXtendVC")
        //vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        //self.present(vc, animated: true, completion: nil)
        
    }
    func getExtenderTypeString() -> String {
        switch extenderType {
        case 5:
            return "extender5"
        case 6:
            return "extender6"
        default:
            return "extender6e"
        }
    }
}
extension UIViewController {
    
    func navigateToMyAccountScreen(fromVC: UIViewController) {
        for  destinavitonVC in fromVC.navigationController?.viewControllers ?? [] {
            if destinavitonVC.isKind(of: MyAccountViewController.self)
            {
                fromVC.navigationController?.popToViewController(destinavitonVC, animated: true)
                break
            }
        }
    }
}
