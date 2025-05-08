//
//  SpeedFactorsViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/24/22.
//

import UIKit

struct Tips {
    var tipTitle: String
    var tipDetails: String
}
class SpeedFactorsViewController: UITableViewController {
    @IBOutlet var tappableLabel: UILabel!
    let tappableText = "optimize the WiFi in your home"
    var tipsArray = [Tips]()
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.setLineHeight(1.2)
        self.tableView.register(UINib(nibName: "InternetTipsTableViewCell", bundle: nil), forCellReuseIdentifier: "internettipscell")
        // Setup optimize tips
        let text = "If you are getting good speed on your gateway but not on your device, then you should try to optimize the WiFi in your home."
        let linkText = NSMutableAttributedString(string: text, attributes: [.font: UIFont(name: "Regular-Regular", size: 18)!])
        let moreInfo = (text as NSString).range(of: tappableText)
        linkText.addAttribute(.foregroundColor, value: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0), range: moreInfo)
        tappableLabel.attributedText = linkText
        tipsArray = [Tips(tipTitle: "What does the Optimum Speed Test measure?", tipDetails: "This test measures the speed coming from Optimum to your Gateway. It's the best way to make sure you’re getting your plan speed."), Tips(tipTitle: "Why do other speed tests give me different results than this one?", tipDetails: "Other tests available on the web are measuring the speed to the device you are using at that moment. Lots of things can affect that speed, especially if the device is using WiFi instead of a wired connection."),Tips(tipTitle: "Why is the speed to my Gateway sometimes slower than usual?", tipDetails: "Gateway speed can be affected momentarily by congestion in your network, like when someone is downloading a large movie."),Tips(tipTitle: "Why does the internet still feel slow?", tipDetails: "If you are getting good speed on your Gateway but not on your device, then you should try to optimize they WiFi in your home.")]
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -25 , right: 0)
    }
    
    
    @IBAction func onTapLabel(_ sender: UITapGestureRecognizer) {
        guard sender.didTapAttributedTextInLabel(label: tappableLabel, targetText: tappableText) else {
            return
        }
        guard let vc = TipsContainerViewController.instantiateWithIdentifier(from: .speedTest) else { return }
        vc.viewOption = .optimizeTips
        navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "internettipscell") as! InternetTipsTableViewCell
        cell.tapLabel.delegate = self
        cell.tipTitleLabel.text = tipsArray[indexPath.row].tipTitle
        cell.tipTitleLabel.setLineHeight(1.2)
        if indexPath.row == 3 {
            cell.tipDetailLabel.isHidden = true
            cell.tapLabel.isHidden = false
            let text :NSString = "If you are getting good speed on your gateway but not on your device, then you should try to optimize the WiFi in your home."
            cell.tapLabel.text = text
            let text1 = "If you are getting good speed on your gateway but not on your device, then you should try to"
            let linkText = NSMutableAttributedString(string: text as String, attributes: [.font: UIFont(name: "Regular-Regular", size: 18)!])
            cell.tapLabel.text = linkText
            let tappableText: NSString = "optimize the WiFi in your home" as NSString
            let labelSubRange: NSRange = text.range(of: tappableText as String)
            let labelRange : NSRange = text.range(of: text1 as String)
            cell.tapLabel.addLink(to: URL(string: "optimizeWiFi"), with: labelSubRange)
            cell.tapLabel.changeLinkColorForLabel(font: UIFont(name: "Regular-Regular", size: 18)!, color: energyBlueRGB, range: labelSubRange, mainLabelRange: labelRange)
            cell.tapLabel.setLineHeight(1.2)
           } else {
            cell.tipDetailLabel.isHidden = false
            cell.tapLabel.isHidden = true
            cell.tipDetailLabel.isUserInteractionEnabled = false
            cell.tipDetailLabel.text = tipsArray[indexPath.row].tipDetails
            cell.tipDetailLabel.setLineHeight(1.2)
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tipsArray.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}

extension SpeedFactorsViewController : TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "optimizeWiFi" {
            guard let vc = TipsContainerViewController.instantiateWithIdentifier(from: .speedTest) else { return }
            vc.viewOption = .optimizeTips
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
