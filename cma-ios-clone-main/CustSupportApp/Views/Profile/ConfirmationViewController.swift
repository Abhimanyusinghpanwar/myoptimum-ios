//
//  ConfirmationViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/16/22.
//

import UIKit

class ConfirmationViewController: UIViewController {
    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var subHeaderTitle: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    var primaryActionHandler: (() -> Void)?
    var secondaryActionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackAnalytics()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func trackAnalytics() {
        //CMAIOS-2215
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ProfileEvent.Profiles_addperson_cancel.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }
    
    func configure(headerTitle: String, subHeaderTitle: String?, primaryButtonTitle: String = "Yes", secondaryButtonTitle: String = "No, continue", primaryButtonAction: (() -> Void)?, secondaryButtonAction: (() -> Void)?) {
        loadViewIfNeeded()
        self.headerTitle.text = headerTitle
        self.subHeaderTitle.text = subHeaderTitle
        self.primaryAction.setTitle(primaryButtonTitle, for: .normal)
        self.secondaryAction.setTitle(secondaryButtonTitle, for: .normal)
        self.primaryActionHandler = primaryButtonAction
        self.secondaryActionHandler = secondaryButtonAction
    }
    
    @IBAction func onTapAction(_ sender: UIButton) {
        guard sender == primaryAction else {
            secondaryActionHandler?()
            return
        }
        primaryActionHandler?()
    }
}
