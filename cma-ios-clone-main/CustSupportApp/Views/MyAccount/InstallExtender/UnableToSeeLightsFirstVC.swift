//
//  UnableToSeeLightsFirstVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/17/22.
//  GA-extender5_power_off_and_on/extender6_power_off_and_on

import UIKit

class UnableToSeeLightsFirstVC: BaseViewController {
    @IBOutlet weak var unableToSeeLightsStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var unableToSeeLightsStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var unableToSeeLightsSecBtn: RoundedButton!
    @IBOutlet weak var unableToSeeLightsPrimaryBtn: RoundedButton!
    @IBOutlet weak var checkLightsTipsTableView: UITableView!
    
    @IBOutlet weak var checkLightsTipsHeaderLbl: UILabel!
    var checkLightsTipsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkLightsTipsTableView.register(UINib(nibName: "NoLightsTableViewCell", bundle: nil), forCellReuseIdentifier: "NoLightsTableViewCell")
        checkLightsTipsTableView.isUserInteractionEnabled = false
        checkLightsTipsTableView.separatorStyle = .none
        updateUnableToSeeLightsUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderType.extender5_power_off_and_on.extenderTitle, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateUnableToSeeLightsUI() {
        let extender = ExtenderDataManager.shared.extenderType
        switch extender {
        case 5:
            checkLightsTipsArray = ["Unplug the Extender and plug it back in.","Press the POWER button on the back and make sure it's pushed in."]
            unableToSeeLightsSecBtn.isHidden = true
            unableToSeeLightsPrimaryBtn.setTitle("I pressed the POWER button", for: .normal)
            checkLightsTipsHeaderLbl.text = "Try again by powering off and then powering on"
        case 7:
            checkLightsTipsArray = ["Unplug the Extender and plug it back in.","Make sure the POWER button on the back of the Extender is pressed in."]
            unableToSeeLightsSecBtn.isHidden = true
            unableToSeeLightsPrimaryBtn.setTitle("I’ve done it", for: .normal)
        default:
            checkLightsTipsArray = ["Unplug the Extender and plug it back in.","Make sure the POWER light comes on."]
        }
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            unableToSeeLightsStackViewLeadingConstraint.constant = 30.0
            unableToSeeLightsStackViewTrailingConstraint.constant = 30.0
            primaryLbl.font = UIFont(name: "Regular-Bold", size: 24)
            primaryLbl.setLineHeight(1.21)
        } else {
            primaryLbl.setLineHeight(1.15)
        }
    }
    func buildAttributedString(str: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 10
        let attributedStr = NSMutableAttributedString(string: str,
                                                      attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attributedStr
    }
    @IBAction func unableScreenPrimaryBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func unableScreenSecondaryBtn(_ sender: Any) {
        Logger.info("Unable to see correct light pattern screen secondarty button clicked")
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "XtendSupportViewController")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UnableToSeeLightsFirstVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.checkLightsTipsTableView.dequeueReusableCell(withIdentifier: "NoLightsTableViewCell") as! NoLightsTableViewCell
        cell.descriptionLabel.text = checkLightsTipsArray[indexPath.section]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return checkLightsTipsArray.count
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
