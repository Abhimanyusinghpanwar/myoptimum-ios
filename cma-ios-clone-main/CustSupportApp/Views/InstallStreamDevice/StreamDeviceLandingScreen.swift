//
//  StreamDeviceLandingScreen.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 16/05/24.
//

import UIKit

class StreamDeviceLandingScreen: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var secondryLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imgStream: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var tvPackageName = MyWifiManager.shared.getTVPackageName()
        if tvPackageName.isEmpty {
            tvPackageName = "Premier TV"
        }
        headerLabel.text = "Welcome to \(tvPackageName)"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : StreamSetUp.STREAM_LETSINSTALL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if APIRequests.shared.isReloadNotRequiredForMaui {
            APIRequests.shared.isReloadNotRequiredForMaui = false
        }
        dismiss(animated: true)
    }
    
    @IBAction func installOptimumStreamAction(_ sender: Any) {
        navToInstallStreamDevice()
    }
    
    func navToInstallStreamDevice() {
        //CMA-2651
        guard let vc = InitiateStreamDeviceSetUpVC.instantiateWithIdentifier(from: .TVHomeScreen) else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
