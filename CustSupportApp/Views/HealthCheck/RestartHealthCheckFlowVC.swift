//
//  RestartHealthCheckFlowVC.swift
//  CustSupportApp
//
//  Created by vishali Test on 08/02/23.
//

import UIKit

class RestartHealthCheckFlowVC: UIViewController {

    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgDevice: UIImageView!
    @IBOutlet weak var imgStatusIndicator: UIImageView!
    @IBOutlet weak var multipleExtenderImage: UIImageView!
    var strCurrentDeviceName : String = ""
    var equipmentCount = 0
    var equipmentDetail = ""
    @IBOutlet weak var viewTopToLabel: NSLayoutConstraint!
    @IBOutlet weak var viewTopToImage: NSLayoutConstraint!
    @IBOutlet weak var statusViewSingleExtCentreConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusViewMultipleExtCentreConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgDeviceTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblDetail.font = UIFont(name: "Regular-Bold", size: 24)
        if equipmentDetail.isEmpty {
            multipleExtenderImage.isHidden = true
            let wifiType = MyWifiManager.shared.getWifiType()
            switch wifiType {
            case "Gateway":
                lblStatus.isHidden = false
                imgStatusIndicator.isHidden = false
                imgStatusIndicator.backgroundColor = UIColor.StatusOffline
                let imageName = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? "Gateway6E" : "Altice-Gateway"
                imgDevice.image = UIImage.init(named: imageName)
                lblName.text = wifiType
                lblDetail.text = "Your Gateway is offline"
            case "Modem":
                lblStatus.isHidden = true
                imgStatusIndicator.isHidden = true
                imgDevice.image = UIImage.init(named: "Modem")
                lblDetail.text = "Your modem is offline"
                lblName.isHidden = true
            case "Equipment":
                lblStatus.isHidden = true
                imgStatusIndicator.isHidden = true
                imgDevice.image = UIImage.init(named:"Router_Dlink")
                lblDetail.text = "Your equipment is offline"
                lblName.isHidden = true
            default:
                return
            }
        } else {
            if self.equipmentCount > 1 {
                lblStatus.isHidden = true
                imgStatusIndicator.isHidden = true
                imgDevice.isHidden = true
                lblName.isHidden = true
                multipleExtenderImage.isHidden = false
                multipleExtenderImage.image = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? ((equipmentDetail == "Weak") ? UIImage.init(named:"WeakExtender6E") : UIImage.init(named:"OfflineExtender6E")) : ((equipmentDetail == "Weak") ? UIImage.init(named:"extender_Weak_Mutiple") : UIImage.init(named:"extender_Offline_Mutiple"))
                lblDetail.text = (equipmentDetail == "Weak") ? "\(equipmentCount)" + MyWiFiConstants.multiple_ext_weak + "." : "\(equipmentCount)" + MyWiFiConstants.multiple_ext_offline + "."
            } else {
                multipleExtenderImage.isHidden = true
                lblStatus.isHidden = false
                lblStatus.text = (equipmentDetail == "Weak") ? "Weak signal" : "Offline"
                imgStatusIndicator.isHidden = false
                imgStatusIndicator.backgroundColor = (equipmentDetail == "Weak") ? UIColor.StatusWeak : UIColor.StatusOffline
                imgDevice.isHidden = false
                let imageName = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? "Optimum-Extender 6E" : "Extender_icon"
                imgDevice.image = UIImage(named: imageName)
                lblName.isHidden = false
                statusViewSingleExtCentreConstraint.isActive = true
                statusViewMultipleExtCentreConstraint.isActive = false
                viewTopToLabel.isActive = true
                viewTopToImage.isActive = false
                imgDeviceTopConstraint.constant = 66
                if equipmentDetail == "Weak" {
                    let weakExtenderName = WifiConfigValues.getExtenderName(offlineExtNode: MyWifiManager.shared.getWeakExtenders()[0], onlineExtNode: nil)
                    lblName.text = weakExtenderName
                    lblDetail.text = "Your " + (lblName.text ?? "") + MyWiFiConstants.one_ext_weak + "."
                } else {
                    let offlineExtender = WifiConfigValues.getExtenderName(offlineExtNode: MyWifiManager.shared.getOfflineExtenders()[0], onlineExtNode: nil)
                    lblName.text = offlineExtender
                    lblDetail.text = "Your " +  (lblName.text ?? "") +  MyWiFiConstants.one_ext_offline + "."
                }
                }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if equipmentDetail.isEmpty {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_GATEWAY_OFFLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        } else {
            if self.equipmentCount > 1 {
                if equipmentDetail == "Weak" {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_EXTENDERS_WEAKSIGNAL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                } else {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_EXTENDERS_OFFLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                }
            } else {
                if equipmentDetail == "Weak" {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_EXTENDER_WEAKSIGNAL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                } else {
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_HEALTHCHECK_EXTENDER_OFFLINE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
                }
            }
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func onClickLetsFixThisButton(_ sender: Any) {
        if equipmentDetail.isEmpty {
            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RestartFlowViewController")
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else if equipmentDetail == "Weak" {
            //CMA-400
            ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
            ExtenderDataManager.shared.flowType = .weakFlow
            ExtenderDataManager.shared.iTroubleshoot = .healthCheck
            ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            if let offlineExtenderFlowRootScreen = storyboard.instantiateViewController(withIdentifier: "goToExtenderOfflineViewController") as? GoToExtenderOfflineViewController {
                offlineExtenderFlowRootScreen.isFromTroubleShooting = true
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(offlineExtenderFlowRootScreen, animated: true)
            }
        } else {
            //CMA-377
            ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
            ExtenderDataManager.shared.flowType = .offlineFlow
            ExtenderDataManager.shared.iTroubleshoot = .healthCheck
            ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            if let offlineExtenderFlowRootScreen = storyboard.instantiateViewController(withIdentifier: "extenderOfflineViewController") as? ExtenderOfflineViewController {
                offlineExtenderFlowRootScreen.isFromTroubleShooting = true
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(offlineExtenderFlowRootScreen, animated: true)
            }
        }
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
