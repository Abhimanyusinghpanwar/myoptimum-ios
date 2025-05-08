//
//  ExtenderOfflineCheckLightsTipsViewController.swift
//  CustSupportApp
//  CMAIOS-372
//  Created by vsamikeri on 2/15/23.
//

import UIKit

class ExtenderOfflineCheckLightsTipsViewController: BaseViewController {
    
    @IBOutlet weak var tipsTableView: UITableView!
    var tipsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tipsTableView.register(UINib(nibName: "NoLightsTableViewCell", bundle: nil), forCellReuseIdentifier: "NoLightsTableViewCell")
        tipsTableView.isUserInteractionEnabled = false
        tipsTableView.separatorStyle = .none
        if extenderType == 5 {
            tipsArray = ["Check your wall switches, make sure they're in the ON position.","If your power outlet is controlled by a wall switch, make sure the switch is in the ON position.","Try plugging in to a different outlet or power strip.","Make sure the POWER button in the back is pushed in."]
        } else if extenderType == 6 {
            tipsArray = ["Check your wall switches, make sure they're in the ON position.","If your power outlet is controlled by a wall switch, make sure the switch is in the ON position.","Try plugging in to a different outlet or power strip."]
        } else {
            tipsArray = ["Check your wall switches, make sure they're in the ON position.","If your power outlet is controlled by a wall switch, make sure the switch is in the ON position.","Try plugging in to a different outlet or power strip.","Make sure the POWER button in the back is pushed in."]
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderTroubleshooting.ExtenderOfflineTS.extender_offline_tips_to_power_extender.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Extender.rawValue ])
    }
    @IBAction func tipsPrimaryBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "restartTimerExtenderViewController")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tipsSecondarybtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallContactSupportVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension ExtenderOfflineCheckLightsTipsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tipsTableView.dequeueReusableCell(withIdentifier: "NoLightsTableViewCell") as! NoLightsTableViewCell
        cell.descriptionLabel.text = tipsArray[indexPath.section]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tipsArray.count
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
