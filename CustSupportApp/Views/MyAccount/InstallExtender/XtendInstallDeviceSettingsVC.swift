//
//  XtendInstallDeviceSettingsVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/21/22.
//  CMAIOS-809
//  GA-extender6_local_network_access_turned_off

import UIKit
import Network

class XtendInstallDeviceSettingsVC: BaseViewController {
    
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var secondaryLbl: UILabel!
    weak var delegate: LocalNetworkConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateXtendDeviceSettingsUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_local_network_access_turned_off.extenderTitleWifi6, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateXtendDeviceSettingsUI() {
        primaryLbl.attributedText = getAttributedTextForLabels(string: "  Go to Settings on this phone", image: "bulletImage_1")
        secondaryLbl.attributedText = getAttributedTextForLabels(string: "  Turn on the Local Network Access for this app", image: "bulletImage_2")
        if CurrentDevice.isLargeScreenDevice() {
            primaryLbl.setLineHeight(1.21)
            secondaryLbl.setLineHeight(1.2)
        } else {
            primaryLbl.setLineHeight(1.15)
            secondaryLbl.setLineHeight(1.2)
        }
        
    }
    
    func textAttachment(fontSize: CGFloat, imageName: String) -> NSTextAttachment {
        let font = UIFont(name: "Regular-Regular", size: 18)!
        let textAttachment = NSTextAttachment()
        let image = UIImage(named: imageName)!
        textAttachment.image = image
        let mid = font.descender + font.capHeight
        textAttachment.bounds = CGRectIntegral(CGRect(x: 0, y: font.descender - image.size.height / 2 + mid + 2, width: image.size.width, height: image.size.height))
        
        return textAttachment
    }
    
    func getAttributedTextForLabels(string: String, image: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        let imageString = NSAttributedString(attachment: textAttachment(fontSize: 18, imageName: image))
        attributedString.append(imageString)
        attributedString.append(NSAttributedString(string: string))
        
        return attributedString
    }
    
    @IBAction func xtendDeviceSettingsCancelBtn(_ sender: Any) {
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
                cancelVC.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(cancelVC, animated: true)
            }
        } else {
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
                cancelVC.modalPresentationStyle = .fullScreen
                self.present(cancelVC, animated: true)
            }
        }
    }
    
    @IBAction func xtendDeviceSettingsBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToSettingsBtn(_ sender: Any) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    Logger.info("User navigated to Device Settings ")
                }
            }
        }
    }
    
    @IBAction func installWithoutHomeNetworkBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendPlacementHelpWiFiWorksBestVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkNetworkState() {
        let connection = NWConnection(host: "192.168.1.1", port: 0, using: .tcp)
        if sharedConnection != nil  {
            sharedConnection?.cancel()
        }
        sharedConnection = LocalNetworkConnection(delegate: self, localConnection: connection, connectionStarted: true)
    }
    
}

extension XtendInstallDeviceSettingsVC: LocalNetworkConnectionDelegate {
    func localConnection(isAvailable: Bool, error: NWError?) {
        sharedConnection?.cancel()
        if isAvailable == true {
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "proactivePlacementViewController")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
        }
    }
}
