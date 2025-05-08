//
//  CancelTroubleShootingViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 10/01/23.
//

import UIKit

class CancelTroubleShootingViewController: UIViewController {
    var dismissCompletion:((Bool) -> Void)?
    var isComeTVTroubleshooting: Bool = false
    @IBOutlet weak var screenTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenTitleLabel.setLineHeight(1.2)
        self.navigationItem.hidesBackButton = true
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_CANCEL_TROUBLESHOOTING.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    

    @IBAction func yesBtn(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        isComeTVTroubleshooting
        ? self.getTVPageController()
        : self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
            IntentsManager.sharedInstance.screenFlow = .none
        })
    }
    
    @IBAction func noBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getTVPageController(){
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
         
        })
    }
}
