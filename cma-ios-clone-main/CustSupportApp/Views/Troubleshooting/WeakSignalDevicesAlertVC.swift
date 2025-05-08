//
//  WeakSignalDevicesVC.swift
//  CustSupportApp
//
//  Created by vishali Test on 09/02/23.
//

import UIKit
import Lottie

class WeakSignalDevicesAlertVC: UIViewController {
   var deviceDetails:DeviceDetails? = nil
    
    @IBOutlet weak var animationWithConstraint: NSLayoutConstraint!
    @IBOutlet weak var animationVwTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var weakSignalAnimationView: LottieAnimationView!
    @IBOutlet weak var animationHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_LIST_DEVICES_WITH_WEAK_SIGNAL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        // Do any additional setup after loading the view.
        if currentScreenWidth < xibDesignWidth {
            //animationVwTopConstraint.constant = 10
            animationHeightConstraint.constant = ((animationHeightConstraint.constant/xibDesignHeight)*currentScreenHeight) - 20
            animationWithConstraint.constant = ((animationWithConstraint.constant/xibDesignWidth)*currentScreenWidth) - 20
            weakSignalAnimationView.layer.cornerRadius = 100
            }
        self.infoLabel.setLineHeight(1.2)
        self.infoLabel.textAlignment = .center
    }
    
    @IBAction func onClickLetsFixThisButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HealthCheck", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WeakSignalDevicesController") as! WeakSignalDevicesController
        vc.weakDevicesDetail = deviceDetails
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(vc , animated: true)
    }
    
    @IBAction func onClickMayBeLaterButton(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
