//
//  AboutMyOptimumViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 7/21/22.
//

import UIKit


class AboutMyOptimumViewController: UIViewController {
    
    
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var displayAccountNumber: UILabel!
    var qualtricsAction : DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelText()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qualtricsAction = self.checkQualtrics(screenName: MyAccountScreenDetails.MY_ACCOUNT_ABOUT_MY_OPTIMUM.rawValue, dispatchBlock: &qualtricsAction)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : MyAccountScreenDetails.MY_ACCOUNT_ABOUT_MY_OPTIMUM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.General.rawValue])
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }

    @IBAction func aboutMyCloseBtn(_ sender: Any) {
        self.qualtricsAction?.cancel()
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    func setLabelText() {
        deviceIDLabel.text = PreferenceHandler.getValuesForKey("deviceId") as? String
        usernameLabel.text = PreferenceHandler.getValuesForKey("username") as? String
        versionNumberLabel.text = App.versionNumber()
        let accountNumber = QuickPayManager.shared.modelAccountsList?.accounts?.first?.legacy?.displayAccountNumber
        displayAccountNumber.text = QuickPayManager.shared.getAccountDisplayNumber()
    }
    
}
