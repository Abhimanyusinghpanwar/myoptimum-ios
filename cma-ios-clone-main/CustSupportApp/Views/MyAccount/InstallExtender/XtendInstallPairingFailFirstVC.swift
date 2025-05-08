//
//  XtendInstallPairingFailFirstVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/19/22.
//  GA-extender5_pairing_fail_first_time/extender6_pairing_fail_first_time

import UIKit
import Network

class XtendInstallPairingFailFirstVC: BaseViewController {
    
    @IBOutlet weak var xtendInstallPairingFailFirstHeaderLbl: UILabel!
    @IBOutlet weak var xtendInstallPairingFailFirstLblOne: UILabel!
    @IBOutlet weak var xtendInstallPairingFailFirstbtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsTableView: UITableView!
    
    let pairingFailextender = ExtenderDataManager.shared.extenderType
    var stepsArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stepsTableView.register(UINib(nibName: "NoLightsTableViewCell", bundle: nil), forCellReuseIdentifier: "NoLightsTableViewCell")
        stepsTableView.isUserInteractionEnabled = false
        stepsTableView.separatorStyle = .none
        updateXIPairingFailFirstTimeUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_pairing_fail_first_time.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateXIPairingFailFirstTimeUI() {
        
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            xtendInstallPairingFailFirstHeaderLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendInstallPairingFailFirstLblOne.font = UIFont(name: "Regular-Regular", size: 20)
            xtendInstallPairingFailFirstLblOne.setLineHeight(1.21)
        } else {
            xtendInstallPairingFailFirstLblOne.setLineHeight(1.15)
        }
        stepsArray = ["Unplug the Extender","Bring it to a new spot that’s closer to the Gateway"]
    }
    
    @IBAction func pairingFailFirstNewSpotBtn(_ sender: Any) {
        
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            if ExtenderDataManager.shared.extenderType == 5 {
                navigateNext(identifier: "pluginXtendVC")
            } else {
                APIRequests.shared.checkHomeIP { success, response, error in
                    DispatchQueue.main.async {
                        if success {
                            Logger.info("In home check Response is \(String(describing: response))", sendLog: "In Home check success")
                            if response?.isInHome == true {
                                //                            self.navigateNext(identifier: "xtendInstallDevicePermissionsVC")
                                ExtenderDataManager.shared.extenderHomeNetwork = true
                                self.selectXtendNavigationForPermissions()
                                return
                            }
                        }
                        let vc = storyboard.instantiateViewController(withIdentifier: "xtendConnectToHomeNetworkVC")
                        vc.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        else {
            let identifier = pairingFailextender == 5 ? "pluginXtendVC" : "proactivePlacementViewController"
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: identifier)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    func selectXtendNavigationForPermissions() {
        let isPermissionGiven = PreferenceHandler.getValuesForKey("localNetwork")
        
        if isPermissionGiven == nil {
            navigateNext(identifier: "xtendInstallDevicePermissionsVC")
        } else {
            checkLANFromXtendHalfwayVC()
        }
    }
    
    func navigateNext(identifier: String) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func checkLANFromXtendHalfwayVC() {
        let connection = NWConnection(host: "192.168.1.1", port: 0, using: .tcp)
        if sharedConnection != nil  {
            sharedConnection?.cancel()
        }
        sharedConnection = LocalNetworkConnection(delegate: self, localConnection: connection, connectionStarted: true)
    }
    
}

extension XtendInstallPairingFailFirstVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.stepsTableView.dequeueReusableCell(withIdentifier: "NoLightsTableViewCell") as! NoLightsTableViewCell
        cell.descriptionLabel.text = stepsArray[indexPath.section]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stepsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension XtendInstallPairingFailFirstVC:  LocalNetworkConnectionDelegate {
    func localConnection(isAvailable: Bool, error: NWError?) {
        sharedConnection?.cancel()
        if isAvailable == true {
            navigateNext(identifier: "proactivePlacementViewController")
        } else {
            navigateNext(identifier: "xtendInstallDeviceSettingsVC")
        }
    }
}
