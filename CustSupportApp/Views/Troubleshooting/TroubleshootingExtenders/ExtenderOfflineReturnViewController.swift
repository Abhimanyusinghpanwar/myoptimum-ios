//
//  ExtenderOfflineReturnViewController.swift
//  CustSupportApp
//  CMAIOS-367
//
//  Created by vsamikeri on 1/30/23.
//

import UIKit
import SafariServices

struct ExtenderSuppressData: Codable {
    let extender_suppress_mac: String
    let extender_suppress_mac_LastCheck: String
}

class ExtenderOfflineReturnViewController: BaseViewController {
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var regularLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CurrentDevice.isLargeScreenDevice(){
            headerLbl.setLineHeight(1.21)
            regularLbl.setLineHeight(1.2)
        }else {
            headerLbl.setLineHeight(1.15)
            regularLbl.setLineHeight(1.2)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_return_extender.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    @IBAction func extenderReturnPrimaryBtn(_ sender: Any) {
        let returnUrl = MyWifiManager.shared.getRegion().lowercased() == "optimum" ? ConfigService.shared.returnOptEast : ConfigService.shared.returnOptWest
        guard let url = URL(string: returnUrl) else { return }
        let safariVC = SFSafariViewController(url: url)
        saveExtenderSuppressData()
        self.present(safariVC, animated: true, completion:nil)
    }
    @IBAction func extenderReturnSecBtn(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        dismiss(animated: true)
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        let getDate = dateFormatter.string(from: Date())
        
        return getDate
    }
    
    func saveExtenderSuppressData() {
        let currentDate = getCurrentDate()
        let extenderMac = ExtenderDataManager.shared.extendersDeviceMac.first
        var data: [ExtenderSuppressData] = []
        data.append(ExtenderSuppressData.init(extender_suppress_mac: extenderMac ?? "", extender_suppress_mac_LastCheck: currentDate))
        if let previousData = PreferenceHandler.getValuesForKey("extenderSuppressData")  as? Data {
            let decoder = JSONDecoder()
            if let decodedDataArray = try? decoder.decode([ExtenderSuppressData].self, from: previousData) {
                if (decodedDataArray.filter({$0.extender_suppress_mac != extenderMac}).count > 0) {
                    data.append(contentsOf: decodedDataArray)
                }
            }
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            PreferenceHandler.saveValue(encoded, forKey: "extenderSuppressData")
        }
        
        SpotLightsManager.shared.suppressOfflineExtenderCard() //CMAIOS-1298
    }
}

/*
 * Large screens, secondary btn
 */
