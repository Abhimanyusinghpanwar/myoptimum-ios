//
//  HelpMeOptimizeViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/24/22.
//

import SafariServices
import UIKit

struct optimizeOptions {
    var optionTitle: String
    var optionDetails: String
    var optionLink : String
    var image : String
}
class HelpMeOptimizeViewController: UITableViewController {
    @IBOutlet var tappableLabel: UILabel!
    let tappableText = "Check to see if you need an Extender"
    var optimizeOptionsArray = [optimizeOptions]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "HelpMeOptimizeTableViewCell", bundle: nil), forCellReuseIdentifier: "optimizeOption")
        self.tableView.register(UINib(nibName: "HelpMeOptimizeWithExtenderTableViewCell", bundle: nil), forCellReuseIdentifier: "optimizeOptionWithExtender")
        // Setup Get Extender
        let text = "Check to see if you need an Extender"
        let linkText = NSMutableAttributedString(string: text, attributes: [.font: UIFont(name: "Regular-Bold", size: 16)!])
        let moreInfo = (text as NSString).range(of: tappableText)
        linkText.addAttribute(.foregroundColor, value: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0), range: moreInfo)
        tappableLabel.attributedText = linkText
        optimizeOptionsArray = [optimizeOptions(optionTitle: "Don’t crowd your Gateway", optionDetails: "Fewer objects and walls between your device and your router or Gateway will improve the signal strength.", optionLink: "", image: "dontcrowd"), optimizeOptions(optionTitle: "Get an Extender", optionDetails: "If you have WiFi dead zones in your home, we can help you get better coverage with one or more Extenders.", optionLink: "Check to see if you need an Extender", image: "getanextender"), optimizeOptions(optionTitle: "Move your device closer to your Gateway or Extender", optionDetails: "The closer you are to your router or Gateway, the faster the WiFi connection.", optionLink: "", image: "movecloser"), optimizeOptions(optionTitle: "Use a wired connection", optionDetails: "For devices such as Internet capable TVs, or gaming systems it’s best to wire them to your modem or Gateway using an Ethernet connection, when possible. ", optionLink: "", image: "ethernet"), optimizeOptions(optionTitle: "Update the software on your devices", optionDetails: "Outdated operating systems, drivers, and firmware can slow down the speed of your device.", optionLink: "", image: "updatedevices"), optimizeOptions(optionTitle: "Time for a new device?", optionDetails: "WiFi speeds may be slower on older computers, laptops, tablets, and smartphones that are unable to handle today's faster speeds.", optionLink: "", image: "newdevice")]
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_TIPS_TO_OPTIMIZE_WIFI.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
    }
    
    @IBAction func onTapLabel(_ sender: UITapGestureRecognizer) {
        guard sender.didTapAttributedTextInLabel(label: tappableLabel, targetText: tappableText), let url = URL(string: EXTENDER_URL) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        navigationController?.present(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let optimizeExtenderCell = tableView.dequeueReusableCell(withIdentifier: "optimizeOptionWithExtender") as! HelpMeOptimizeWithExtenderTableViewCell
            optimizeExtenderCell.tappbleDelegateforExtenderLink = self
            optimizeExtenderCell.extenderTitle.text = optimizeOptionsArray[indexPath.row].optionTitle
            optimizeExtenderCell.optimizeExtenderDetail.text = optimizeOptionsArray[indexPath.row].optionDetails
            let text = "Check to see if you need an Extender"
            let linkText = NSMutableAttributedString(string: text, attributes: [.font: UIFont(name: "Regular-Bold", size: 16)!])
            let moreInfo = (text as NSString).range(of: tappableText)
            linkText.addAttribute(.foregroundColor, value: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0), range: moreInfo)
            //tappableLabel.attributedText = linkText
            optimizeExtenderCell.optimizeOptionLink.attributedText = linkText
            let image = UIImage(named: optimizeOptionsArray[indexPath.row].image)
            optimizeExtenderCell.optimizeExtenderImage.image = image
            optimizeExtenderCell.extenderTitle.setLineHeight(1.2)
            optimizeExtenderCell.optimizeExtenderDetail.setLineHeight(1.2)
            optimizeExtenderCell.optimizeOptionLink.setLineHeight(1.2)
            return optimizeExtenderCell
            
        } else {
            let optimizeCell = tableView.dequeueReusableCell(withIdentifier: "optimizeOption") as! HelpMeOptimizeTableViewCell
            optimizeCell.optionTitle.text = optimizeOptionsArray[indexPath.row].optionTitle
            optimizeCell.optionDetails.text = optimizeOptionsArray[indexPath.row].optionDetails
            let image = UIImage(named: optimizeOptionsArray[indexPath.row].image)
            optimizeCell.iptionImage.image = image
            optimizeCell.optionTitle.setLineHeight(1.2)
            optimizeCell.optionDetails.setLineHeight(1.2)
            return optimizeCell
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optimizeOptionsArray.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
extension HelpMeOptimizeViewController:TappbaleLabelForExtenderLink
{
    func checkTappableLabelForExtenderLink(label: UILabel, text: String, sender: UITapGestureRecognizer) {
        guard sender.didTapAttributedTextInLabel(label: label, targetText: tappableText), let url = URL(string: EXTENDER_URL) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        navigationController?.present(vc, animated: true)
    }
}
