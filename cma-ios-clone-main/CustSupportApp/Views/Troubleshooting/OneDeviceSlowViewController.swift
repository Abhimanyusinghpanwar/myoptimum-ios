//
//  OneDeviceSlowViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 09/12/22.
//

import UIKit
import SafariServices

class OneDeviceSlowViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            if isComingFromLetUsHelp {
                self.navigationController?.dismiss(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            onTapCancel()
        }
    }
    @IBOutlet weak var oneDeviceSlowTableView: UITableView!
    @IBOutlet weak var okayButton: UIButton!
    var isComingFromLetUsHelp:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        okayButton.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1)
        self.oneDeviceSlowTableView.register(UINib(nibName: "OneDeviceSlowTableViewCell", bundle: nil), forCellReuseIdentifier: "OneDeviceSlowCell")
        self.oneDeviceSlowTableView.register(UINib(nibName: "OneDeviceSlowNetworkTableViewCell", bundle: nil), forCellReuseIdentifier: "OneDeviceSlowNetworkCell")

        self.oneDeviceSlowTableView.separatorStyle = .none
        buttonDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_PROBLEM_WITH_DEVICE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
    }
    
    func onTapCancel() {
            let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
                cancelVC.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    @IBAction func onClickOkayButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "OneDeviceConfirmationVC") as OneDeviceConfirmationVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
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

extension OneDeviceSlowViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.oneDeviceSlowTableView.dequeueReusableCell(withIdentifier: "OneDeviceSlowCell") as! OneDeviceSlowTableViewCell
        let networkCell = self.oneDeviceSlowTableView.dequeueReusableCell(withIdentifier: "OneDeviceSlowNetworkCell") as! OneDeviceSlowNetworkTableViewCell

        cell.numberLabel.isHidden = false
        cell.rangeOfNetworkLabel.isHidden = false
        cell.rangeOfNetworkLabel.delegate = self
        networkCell.rangeOfNetworkLabel.delegate = self
        networkCell.networkLabel.delegate = self
        cell.selectionStyle = .none
        networkCell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.usernameLabel.isHidden = false
            cell.passwordLabel.isHidden = true
            cell.numberLabel.text = String(indexPath.row + 1)
            cell.rangeOfNetworkLabel.text = "On your device, try turning WiFi off, and then back on. And, if applicable, turn airplane mode off."
            cell.usernameLabel.isHidden = true
            cell.networkLabelBottomConstraintToUsername.priority = UILayoutPriority(rawValue: 250)
            cell.networkLabelBottomConstraintToSuperView.priority = UILayoutPriority(rawValue: 999)
        } else if indexPath.row == 1 {
            cell.numberLabel.text = String(indexPath.row + 1)
            let passwordText = (MyWifiManager.shared.getWifiType() == "Modem") ? "password." : "password:"
            cell.rangeOfNetworkLabel.text = "Make sure your device is in the range of your network and connected with the correct " + passwordText
            if MyWifiManager.shared.getWifiType() == "Modem" {
                cell.usernameLabel.isHidden = true
                cell.passwordLabel.isHidden = true
                cell.networkLabelBottomConstraintToUsername.priority = UILayoutPriority(rawValue: 250)
                cell.networkLabelBottomConstraintToSuperView.priority = UILayoutPriority(rawValue: 999)
            } else {
                cell.usernameLabel.isHidden = false
                cell.passwordLabel.isHidden = false
                if let twoG = MyWifiManager.shared.twoGHome, twoG.allKeys.count > 0 {
                    if let ssid = twoG.value(forKey: "SSID") as? String, !ssid.isEmpty,
                       let password = twoG.value(forKey: "password") as? String, !password.isEmpty {
                        cell.usernameLabel.text = ssid
                        cell.passwordLabel.text = password
                    }
                }
                cell.usernameLabel.font = UIFont(name: "Regular-Bold", size: 18)
                cell.passwordLabel.font = UIFont(name: "Regular-Bold", size: 18)
                cell.networkLabelBottomConstraintToUsername.priority = UILayoutPriority(rawValue: 999)
                cell.networkLabelBottomConstraintToSuperView.priority = UILayoutPriority(rawValue: 250)
                cell.usernameLabelBottomConstraintToPassword.priority = UILayoutPriority(rawValue: 999)
                cell.usernameLabelBottomConstraintToSuperview.priority = UILayoutPriority(rawValue: 250)
                cell.passwordLabelBottomConstraintToSuperview.priority = UILayoutPriority(rawValue: 999)
            }
        } else if indexPath.row == 2 {
            cell.usernameLabel.isHidden = true
            cell.passwordLabel.isHidden = true
            cell.numberLabel.text = String(indexPath.row + 1)
            cell.rangeOfNetworkLabel.text = "If none of the previous steps works, restart your device."
            cell.networkLabelBottomConstraintToUsername.priority = UILayoutPriority(rawValue: 250)
            cell.networkLabelBottomConstraintToSuperView.priority = UILayoutPriority(rawValue: 999)
        } else {
            cell.usernameLabel.isHidden = true
            cell.passwordLabel.isHidden = true
            cell.numberLabel.text = String(indexPath.row + 1)
            networkCell.numberLabel.text = String(indexPath.row + 1)
            var extenderString: NSString = "you may need"
            var extenderSubString: NSString = "an Extender."
            if currentScreenWidth > 375 {
                extenderString = "you may need an"
                extenderSubString = "Extender."
            }
            networkCell.rangeOfNetworkLabel.text = extenderString as String
            networkCell.networkLabel.text = extenderSubString as String
            let extenderRange: NSRange = extenderString.range(of: extenderString as String)
            networkCell.rangeOfNetworkLabel.addLink(to: URL(string: "NeedExtender"), with: extenderRange)
            let extenderSubRange: NSRange = extenderSubString.range(of: extenderSubString as String)
            networkCell.networkLabel.addLink(to: URL(string: "NeedExtender"), with: extenderSubRange)
            networkCell.rangeOfNetworkLabel.changeLinkColor(font: UIFont(name: "Regular-Regular", size: 18)!)
            networkCell.networkLabel.changeLinkColor(font: UIFont(name: "Regular-Regular", size: 18)!)
            return networkCell
        }
        cell.rangeOfNetworkLabel.setLineHeight(1.2)
        return cell
    }
}

// MARK: - SFSafariViewController Delegates
extension OneDeviceSlowViewController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser(_ URLString : String, title : String) {

            let safariVC = SFSafariViewController(url: URL(string: URLString)!)
            safariVC.delegate = self
            
            //make status bar have default style for safariVC
            
            self.present(safariVC, animated: true, completion:nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //make status bar have light style since going back to UIApplication
        self.oneDeviceSlowTableView.reloadData()
    }
}

extension OneDeviceSlowViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        var linkURL = ""
        switch url.absoluteString {
        case "NeedExtender":
            linkURL = EXTENDER_URL
        default:
            linkURL = ""
        }
        self.navigateToInAppBrowser(linkURL, title: "")
    }
}
