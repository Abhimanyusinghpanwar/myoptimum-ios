//
//  CheckLightsViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 02/02/23.
//

import UIKit

class CheckLightsViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    @IBOutlet weak var lightsOnButton: RoundedButton!
    @IBOutlet weak var lightsOffButton: RoundedButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var noLightsTableView: UITableView!
    var deviceName = MyWifiManager.shared.getWifiType()
    var descriptionArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        deviceName = (MyWifiManager.shared.getWifiType() == "Gateway") ? deviceName : deviceName.lowercased()
        self.noLightsTableView.register(UINib(nibName: "NoLightsTableViewCell", bundle: nil), forCellReuseIdentifier: "NoLightsTableViewCell")
        descriptionArray = ["If your power outlet is controlled by a wall switch, make sure the switch is in the ON position.","If you are using a power strip, make sure it's switched on.","Try plugging in to a different outlet or power strip.","If your \(deviceName) has a power switch, make sure it's turned on."]
        self.headerLabel.text = "Here are somethings you can try if your \(deviceName) isn’t getting power"
            self.lightsOnButton.setTitle("That worked, I see lights now ", for: .normal)
            self.lightsOffButton.setTitle("No, I still don’t see any lights", for: .normal)
            self.noLightsTableView.isHidden = false
            self.noLightsTableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_TIPS_TO_POWER_GATEWAY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue])
        } else if MyWifiManager.shared.getWifiType() == "Equipment" {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_TIPS_TO_POWER_EQUIPMENT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_MANUAL_RESTART_TIPS_TO_POWER_MODEM.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        }
    }
    
    @IBAction func lightsOnAction(_ sender: Any) {
        guard let vc = RestartCountDownTimerViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
        vc.isFromManualRestart = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func lightsOffAction(_ sender: Any) {
            guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController")
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

extension CheckLightsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.noLightsTableView.dequeueReusableCell(withIdentifier: "NoLightsTableViewCell") as! NoLightsTableViewCell
        cell.descriptionLabel.text = descriptionArray[indexPath.section]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
