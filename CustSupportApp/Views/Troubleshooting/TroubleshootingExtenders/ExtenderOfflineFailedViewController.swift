//
//  ExtenderOfflineFailedViewController.swift (Cannot connect to the Extender)
//  CustSupportApp
//
//  Created by vsamikeri on 2/15/23.
//

import UIKit

class ExtenderOfflineFailedViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        /* CMAIOS-1089
        if buttonType == .back {
            self.navigationController?.removeViewControllerIfExists(ofClass: RestartTimerExtenderViewController.self)
            self.navigationController?.popViewController(animated: true)
        } else {
            showCancelVC()
        }
        */
    }
    @IBOutlet weak var extenderNameLbl: UILabel!
    @IBOutlet weak var extendOfflineBottomStackView: UIStackView!
    @IBOutlet weak var extendOfflineTextLabel: UILabel!
    @IBOutlet weak var statusFailedImageView: UIImageView!
    @IBOutlet weak var extednerIconImageView: UIImageView!
    private let numOfExtenders = MyWifiManager.shared.getAllOnlineExtenders()
    private let friendlyName = ExtenderDataManager.shared.extenderFriendlyName
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonDelegate = self
        updateCurrentUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        if ExtenderDataManager.shared.flowType == .offlineFlow {
            hideNavigationBar(hiddenFlag: true)
        } else {
            hideNavigationBar(hiddenFlag: true)
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_restart_not_back_online.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    
    @IBAction func extenderConnectionFailedPrimaryBtn(_ sender: Any) {
        ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallHalfWayVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)   
    }
    
    
    @IBAction func extenderConnectionFailedSecBtn(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func transitionBottomStackView() {
        delay(seconds: 0.5) {
            UIView.transition(with: self.extendOfflineBottomStackView,
                              duration: 0.1,
                              options: .transitionFlipFromBottom,
                              animations: {
                self.extendOfflineBottomStackView.isHidden = false
                self.extendOfflineTextLabel.isHidden = false
            })
        }
    }
//    CMAIOS-1089
//    func showCancelVC() {
//        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
//        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
//            cancelVC.modalPresentationStyle = .fullScreen
//            self.navigationController?.pushViewController(cancelVC, animated: true)
//        }
//    }
    func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    }
    func updateCurrentUI() {
        statusFailedImageView.backgroundColor = UIColor.StatusOffline
        if extenderType == 7 {
            extednerIconImageView.image = UIImage(named: "Optimum-Extender 6E")
        } else {
            extednerIconImageView.image = UIImage(named: "Extender_icon")
        }
        if MyWifiManager.shared.getOfflineExtenders().count > 1 {
            extenderNameLbl.isHidden = true
            extenderNameLbl.text = ""
        } else {
            extenderNameLbl.isHidden = false
            extenderNameLbl.text = ExtenderDataManager.shared.extenderFriendlyName
        }
        transitionBottomStackView()
    }
}
