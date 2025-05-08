//
//  NoGoodSpotVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 9/23/22.
//  GA-extender6_proactive_placement_return_extender

import UIKit
import SafariServices

class NoGoodSpotVC: BaseViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ExtenderInstallScreens.ExtenderProactivePlacementScreens.extender6_proactive_placement_return_extender.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func updateUI() {
        titleLbl.text = "It looks like you may not need an Extender"
        titleLbl.setLineHeight(0.98)
        descTextView.attributedText = getAttributedTextForDesc()
    }
    
    func getAttributedTextForDesc() -> NSAttributedString {
        let returnUrl = MyWifiManager.shared.getRegion().lowercased() == "optimum" ? ConfigService.shared.returnOptEast : ConfigService.shared.returnOptWest
        let attributedStr = NSMutableAttributedString.init(string:"")
        let url = URL(string: returnUrl)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.32
        let font = UIFont(name: "Regular-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let atrText = "Having too many network points in your home can actually interfere with your WiFi signal and make for a worse experience.\n\nPlease return it using these instructions."
        
        attributedStr.append(NSMutableAttributedString.init(string:atrText ,attributes: [NSAttributedString.Key.font : font, .paragraphStyle: paragraphStyle]))
        
        if let url = url {
            attributedStr.addAttributes([.link: url],  range: attributedStr.mutableString.range(of: "using these instructions."))
        }
        
        descTextView.isUserInteractionEnabled = true
        descTextView.isEditable = false
        descTextView.linkTextAttributes = [
            .font: font,
            .foregroundColor: UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1)]
        /*,
         .underlineStyle: NSUnderlineStyle.single.rawValue]*/
        descTextView.delegate = self
        
        return attributedStr
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        self.present(safariVC, animated: true, completion:nil)
        
        return false
    }
}
