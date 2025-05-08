//
//  ExtenderOfflineViewController.swift
//  CustSupportApp
//  CMAIOS-380
//
//  Created by vsamikeri on 1/27/23.
//

import UIKit

enum TroubleshootExtenders {
    case offlineFlow, weakFlow
}

class ExtenderOfflineViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            if isFromTroubleShooting {
                self.navigationController?.popViewController(animated: true)
            } else {
                APIRequests.shared.isReloadNotRequiredForMaui = false
                dismiss(animated: true)
            }
        } else {
            showCancelVC()
        }
    }
    
    @IBOutlet weak var extenderOfflinePrimaryBtnOutlet: RoundedButton!
    @IBOutlet weak var extenderOfflineImageView: UIImageView!
    @IBOutlet weak var extenderOfflineHeaderLbl: UILabel!
    var isFromTroubleShooting = false
    @IBOutlet weak var extenderOfflineTextLbl: UILabel!
    let offlineNodes = MyWifiManager.shared.getOfflineExtenders()
    override func viewDidLoad() {
        super.viewDidLoad()
        ExtenderDataManager.shared.offlineExtenderCount = 0
        updateExtendersOfflineView()
        APIRequests.shared.isReloadNotRequiredForMaui = true
        buttonDelegate = self
        if CurrentDevice.isLargeScreenDevice() {
            extenderOfflineHeaderLbl.setLineHeight(1.21)
        } else {
            extenderOfflineHeaderLbl.setLineHeight(1.15)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        ExtenderDataManager.shared.extendersDeviceMac = []
        for node in offlineNodes {
            ExtenderDataManager.shared.extendersDeviceMac.append(node.device_mac ?? "")
        }
        updateExtendersOfflineView()
    }
    
    @IBAction func extenderOfflinePrimaryBtn(_ sender: Any) {
        let storyBoardID = offlineNodes.count > 1 ? "unPlugExtenderViewController" : "goToExtenderOfflineViewController"
        navigate(identifier: storyBoardID)
    }
    @IBAction func extenderOfflineSecondaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "extenderOfflineReturnViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func updateExtendersOfflineView() {
        var screenTag: String = ""
        var imageName = ""
        switch extenderType {
        case 5:
            imageName = "extender5"
        case 7:
            imageName = "Extender-6E-3-4frontview"
        default:
            imageName = "extender6"
        }
        extenderOfflineImageView.image = UIImage(named: imageName)
        switch offlineNodes.count {
        case 2...:
            extenderOfflineHeaderLbl.text = "Let’s get your Extenders back online"
            extenderOfflineTextLbl.text = "Go to the Extender that’s offline, that’s closest to your Gateway."
            extenderOfflinePrimaryBtnOutlet.setTitle("I’m there", for: .normal)
            ExtenderDataManager.shared.offlineExtenderCount = offlineNodes.count
            screenTag = ExtenderTroubleshooting.ExtenderOfflineTS.mutliple_extenders_offline_get_extender_back_online.rawValue
        case 1:
            extenderOfflineHeaderLbl.text = "Let’s get your Extender back online"
            extenderOfflineTextLbl.isHidden = true
            extenderOfflinePrimaryBtnOutlet.setTitle("Let’s do it", for: .normal)
            ExtenderDataManager.shared.offlineExtenderCount = offlineNodes.count
            screenTag = ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_get_extender_back_online.rawValue
        default:// To cover fail scenarios(need more data)
            Logger.error("No Extenders to Troubleshoot")
            extenderOfflineTextLbl.text = ""
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])

    }
    
    func showCancelVC() {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    private func navigate(identifier: String) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
/*
 *large device
 */
