//
//  OneDeviceConfirmationVC.swift
//  CustSupportApp
//
//  Created by vishali Test on 06/02/23.
//

import UIKit

class OneDeviceConfirmationVC: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_PROBLEM_WITH_DEVICE_PROBLEM_FIXED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
     }
    
    @IBAction func onClickMyDeviceWorksNow(_ sender: Any) {
        AppRatingManager.shared.trackEventTriggeredFor(qualifyingExpType: .troubleshooting)
        IntentsManager.sharedInstance.screenFlow = .none
        self.trackOnClickEvent(eventLinkText: Troubleshooting.TS_DEVICE_WORKS_NOW.rawValue)
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickStillExperiencingAnIssue(_ sender: Any) {
        IntentsManager.sharedInstance.screenFlow = .none
        self.trackOnClickEvent(eventLinkText: Troubleshooting.TS_DEVICE_ISSUE_NOT_RESOLVED.rawValue)
        let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "ContactManufacturerVC") as ContactManufacturerVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func trackOnClickEvent(eventLinkText:String){
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : eventLinkText,
                        EVENT_SCREEN_NAME:Troubleshooting.TS_PROBLEM_WITH_DEVICE_PROBLEM_FIXED.rawValue ,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue]
        )
    }
}
