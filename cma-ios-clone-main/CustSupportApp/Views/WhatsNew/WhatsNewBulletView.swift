//
//  WhatsNewBulletView.swift
//  CustSupportApp
//
//  Created by riyaz on 20/02/24.
//

import UIKit

class WhatsNewBulletView: UIView {
    
    @IBOutlet weak var bulletLbl: UILabel!
    
    @IBOutlet weak var bulletDescLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bulletLbl.layer.backgroundColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1).cgColor
        bulletLbl.layer.cornerRadius = bulletLbl.frame.width/2
        bulletLbl.layer.masksToBounds = true
        
    }
    
    class func instanceFromNib() -> WhatsNewBulletView {
        let view = (UINib(nibName: "WhatsNewBulletView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? WhatsNewBulletView)!
        return view
    }
    
    
    func updateBulletPoint(for text: String) {
        bulletDescLbl.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        bulletDescLbl.font = UIFont(name: "Regular-Regular", size: 18)
        bulletDescLbl.numberOfLines = 0
        bulletDescLbl.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        if CurrentDevice.forLargeSpotlights() {
            paragraphStyle.lineHeightMultiple = 1.195
        } else {
            paragraphStyle.lineHeightMultiple = 1.18
        }
        // Line height: 26 pt
        bulletDescLbl.attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    
}
