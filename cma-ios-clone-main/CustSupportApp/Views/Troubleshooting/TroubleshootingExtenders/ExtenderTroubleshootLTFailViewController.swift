//
//  ExtenderTroubleshootLTFailViewController.swift
//  CustSupportApp
//  CMAIOS-365-LT-Fail
//  Created by vsamikeri on 2/22/23.
//

import UIKit

class ExtenderTroubleshootLTFailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func extenderTroubleshootCloseButton(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
