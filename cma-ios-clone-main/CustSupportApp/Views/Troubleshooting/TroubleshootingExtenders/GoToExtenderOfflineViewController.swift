//
//  GoToExtenderOfflineViewController.swift
//  CustSupportApp
//  CMAIOS-382
//
//  Created by vsamikeri on 2/10/23.
//

import UIKit

class GoToExtenderOfflineViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            if isFromTroubleShooting || ExtenderDataManager.shared.flowType == .offlineFlow {
                self.navigationController?.popViewController(animated: true)
            } else {
                APIRequests.shared.isReloadNotRequiredForMaui = false
                dismiss(animated: true)
            }
        } else {
            showCancelVC()
        }
    }
    @IBOutlet weak var goToExtenderOfflineImageView: UIImageView!
    @IBOutlet weak var goToExtenderOfflineHeaderLbl: UILabel!
    @IBOutlet weak var weakFlowTextLabel: UILabel!
    private let currentNavigationFlow = ExtenderDataManager.shared.flowType
    private let weakExtenders = MyWifiManager.shared.getWeakExtenders()
    private let offlineExtenders = MyWifiManager.shared.getOfflineExtenders()
    private var extenderFriendlyName = ""
    var isFromTroubleShooting = false
    private var screenTagTS: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APIRequests.shared.isReloadNotRequiredForMaui = true
        buttonDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        updateGoToExtenderOfflineUI()
    }
    func updateGoToExtenderOfflineUI() {
        var imageName = ""
        switch extenderType {
        case 5:
            imageName = "extender5"
        case 7:
            imageName = "Extender-6E-3-4frontview"
        default:
            imageName = "extender6"
        }
        goToExtenderOfflineImageView.image = UIImage(named: imageName)
        switch currentNavigationFlow {
        case .offlineFlow:
            extenderFriendlyName = WifiConfigValues.getExtenderName(offlineExtNode: offlineExtenders.first, onlineExtNode: nil)
            weakFlowTextLabel.isHidden = true
            goToExtenderOfflineHeaderLbl.text = "Go to your \(extenderFriendlyName) Extender"
            screenTagTS = ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_goto_extender.rawValue
            trackAnalyticsTS()
        case .weakFlow:
            weakFlowTextLabel.isHidden = false
            extenderFriendlyName = WifiConfigValues.getExtenderName(offlineExtNode: weakExtenders.first, onlineExtNode: nil)
            ExtenderDataManager.shared.extendersDeviceMac = []
            for node in weakExtenders {
                ExtenderDataManager.shared.extendersDeviceMac.append(node.device_mac ?? "")
            }
            updateUILabels()
        }
        ExtenderDataManager.shared.extenderFriendlyName = extenderFriendlyName
        if CurrentDevice.isLargeScreenDevice() {
            goToExtenderOfflineHeaderLbl.setLineHeight(1.21)
            weakFlowTextLabel.setLineHeight(1.15)
        } else {
            goToExtenderOfflineHeaderLbl.setLineHeight(1.15)
            weakFlowTextLabel.setLineHeight(1.15)
        }
    }
    @IBAction func goToExtenderOfflinePrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "unPlugExtenderViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showCancelVC() {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    private func updateUILabels() {
        switch weakExtenders.count {
        case 2...:
            goToExtenderOfflineHeaderLbl.text = "Let's fix your Extenders' weak signal, one at a time."
            weakFlowTextLabel.text = "Go to the Extender that has a weak signal, that's closest to your Gateway."
            screenTagTS = ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_mutliple_extenders_letsfix.rawValue
        case 1:
            goToExtenderOfflineHeaderLbl.text = "Let's fix your Extender's weak signal"
            weakFlowTextLabel.text = "Go to your \(extenderFriendlyName) Extender"
            screenTagTS = ExtenderTroubleshooting.ExtenderWeakSignalTS.extender_weaksignal_letsfix.rawValue
        default: // To cover fail scenarios(need more data)
            Logger.error("No Extenders to Troubleshoot")
            break
        }
        trackAnalyticsTS()
    }
    func trackAnalyticsTS() {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTagTS, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
}
