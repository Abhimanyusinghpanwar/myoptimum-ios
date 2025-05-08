//
//  XtendInstallAPIFailVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/15/22.
//

import UIKit

class XtendInstallAPIFailVC: UIViewController {

    @IBOutlet weak var xtendInstallAPIFailButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallAPIFailStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendInstallAPIFailStackViewLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendAPIFailUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        Logger.info("..Local GW API Failure screen..")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func updateXtendAPIFailUI() {
        if CurrentDevice.isLargeScreenDevice() {
            xtendInstallAPIFailStackViewTrailingConstraint.constant = 30.0
            xtendInstallAPIFailStackViewLeadingConstraint.constant = 30.0
        }
    }
    @IBAction func xtendAPIFailPrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpWiFiWorksBestVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
