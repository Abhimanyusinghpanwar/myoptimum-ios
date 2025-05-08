//
//  WhatsNewCell.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 05/10/23.
//

import UIKit

class WhatsNewCell: UITableViewCell {
    @IBOutlet weak var label_Description: UILabel!
    
    @IBOutlet weak var labelStackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateStackView(intro: String, bulletPoints: [String], outro: String) {
        labelStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        if !intro.isEmpty {
            labelStackView.addArrangedSubview(getLabel(for: intro))
        }
        for bulletPoint in bulletPoints {
            let bulletView = WhatsNewBulletView.instanceFromNib()
            bulletView.updateBulletPoint(for: bulletPoint)
            labelStackView.addArrangedSubview(bulletView)
        }
        if !outro.isEmpty {
            labelStackView.addArrangedSubview(getLabel(for: outro))
        }
        labelStackView.layoutIfNeeded()
    }
    
    func getLabel(for text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "Regular-Regular", size: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        if CurrentDevice.forLargeSpotlights() {
            paragraphStyle.lineHeightMultiple = 1.195
        } else {
            paragraphStyle.lineHeightMultiple = 1.18
        }
        // Line height: 26 pt
        label.attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }
    
}
