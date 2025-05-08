//
//  ExtenderBackOnlineViewController.swift
//  CustSupportApp
//  CMAIOS-374
//
//  Created by vsamikeri on 2/14/23.
//

import UIKit

class ExtenderBackOnlineViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.removeViewControllerIfExists(ofClass: RestartTimerExtenderViewController.self)
            self.navigationController?.popViewController(animated: true)
        } else {
            showCancelVC()
        }
    }
    
    @IBOutlet weak var extenderBackOnlineSecBtnOutlet: UIButton!
    @IBOutlet weak var extenderBackOnlinePrimaryBtnOutlet: UIButton!
    @IBOutlet weak var extenderBackOnlineView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var extenderName: UILabel!
    @IBOutlet weak var extenderBackOnlineHeaderLbl: UILabel!
    @IBOutlet weak var extenderBackOnlineSecLbl: UILabel!
    @IBOutlet weak var extenderIconImageView: UIImageView!
    let currentStatus = MyWifiManager.shared.getOnlineExtenders().filter({
        ExtenderDataManager.shared.extendersDeviceMac.contains($0.device_mac ?? "")
    })
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        updateExtenderBackOnlineUI()
        if ExtenderDataManager.shared.flowType == .offlineFlow {
            hideNavigationBar(hiddenFlag: true)
        } else {
            hideNavigationBar(hiddenFlag: false)
        }
    }
    func updateExtenderBackOnlineUI() {
        checkCurrentStatus()
        var screenTag: String = ""
        let extenderFriendlyName = ExtenderDataManager.shared.extenderFriendlyName
        extenderBackOnlineView.layer.cornerRadius = extenderBackOnlineView.frame.width/2
        extenderName.text = ExtenderDataManager.shared.extenderFriendlyName
        if extenderType == 7 {
            extenderIconImageView.image = UIImage(named: "Optimum-Extender 6E")
        } else {
            extenderIconImageView.image = UIImage(named: "Extender_icon")
        }
        if CurrentDevice.isLargeScreenDevice() {
            extenderBackOnlineHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
        }
        if ExtenderDataManager.shared.flowType == .offlineFlow {
            //check is
            extenderBackOnlineHeaderLbl.text = "\(extenderFriendlyName ?? "")" + " Extender is back online"
            extenderBackOnlineSecLbl.isHidden = true
            if ExtenderDataManager.shared.iTroubleshoot == .troubleshoot {
                screenTag = ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_extender_back_online.rawValue
                trackAnalyticsTS(screenTag)
            }
        } else {
            if currentStatus.count > 1 {
                extenderBackOnlineHeaderLbl.text = "\(currentStatus.count) of your extenders now have good signals"
                if ExtenderDataManager.shared.iTroubleshoot == .troubleshoot {
                    screenTag = ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_issue_resolved_at_newspot.rawValue
                    trackAnalyticsTS(screenTag)
                }
            } else {
                extenderBackOnlineHeaderLbl.text = "Your \(extenderFriendlyName ?? "")" + " Extender now has a good signal"
                if ExtenderDataManager.shared.iTroubleshoot == .troubleshoot {
                    screenTag = ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_issue_resolved_at_newspot.rawValue
                    trackAnalyticsTS(screenTag)
                }
            }
        }
        if ExtenderDataManager.shared.iTroubleshoot == .healthCheck {
            extenderBackOnlineSecBtnOutlet.isHidden = false
            extenderBackOnlineSecLbl.isHidden = false
            extenderBackOnlinePrimaryBtnOutlet.setTitle("Yes, my Internet works now", for: .normal)
            extenderBackOnlineSecBtnOutlet.setTitle("No, I'm still experiencing an issue", for: .normal)
            if ExtenderDataManager.shared.flowType == .offlineFlow {
                screenTag = ExtenderTroubleshooting.ExtenderOfflineTS.healthcheck_extender_offline_extender_back_online.rawValue
                trackAnalyticsTS(screenTag)
            } else {
                screenTag = ExtenderTroubleshooting.ExtenderWeakSignalTS.healthcheck_extender_weaksignal_issue_resolved_at_newspot.rawValue
                trackAnalyticsTS(screenTag)
            }
        } else {
            extenderBackOnlinePrimaryBtnOutlet.setTitle("Great!", for: .normal)
            extenderBackOnlineSecLbl.isHidden = true
        }
    }
    @IBAction func extenderBackOnlinePrimaryBtn(_ sender: Any) {
        AppRatingManager.shared.trackEventTriggeredFor(qualifyingExpType: .troubleshooting)
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func extenderBackOnlineSecBtn(_ sender: Any) {
        guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showCancelVC() {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    func hideNavigationBar(flag: Bool) {
        self.navigationController?.setNavigationBarHidden(flag, animated: true)
    }
    func checkCurrentStatus() {
        switch currentStatus.count {
        case 1:
            statusImageView.backgroundColor = UIColor.StatusOnline
            statusLabel.text = "Online"
            ExtenderDataManager.shared.extenderFriendlyName = WifiConfigValues.getExtenderName(offlineExtNode: currentStatus.first, onlineExtNode: nil)
        case 2...:
            statusImageView.backgroundColor = UIColor.StatusOnline
            statusLabel.text = "Online"
            ExtenderDataManager.shared.extenderFriendlyName = ""
        default:
            statusImageView.backgroundColor = UIColor.StatusWeak
            statusLabel.text = "Weak signal"
        }
    }
    func trackAnalyticsTS(_ pageName: String) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : pageName, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
}
