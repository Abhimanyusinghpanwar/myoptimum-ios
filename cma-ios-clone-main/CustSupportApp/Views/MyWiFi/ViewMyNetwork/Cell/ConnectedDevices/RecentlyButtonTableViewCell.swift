//
//  RecentlyButtonTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 24/08/22.
//

import UIKit

class RecentlyButtonTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwTopLine: UIView!
    //Button Outlet Connections
    @IBOutlet weak var recentlyButton: UIButton!
    @IBOutlet weak var vwTopLineToLabel: UIView!
    @IBOutlet weak var letusHelpBtn: RoundedButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelToLineConstraint: NSLayoutConstraint!
    let buttonBorderColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
        self.letusHelpBtn.backgroundColor = UIColor(red: 0.96, green: 0.4, blue: 0.03, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDefaultValues() {
        recentlyButton.setTitle("View recently disconnected devices", for: .normal)
        recentlyButton.layer.cornerRadius = 35
        recentlyButton.layer.borderWidth = 2
        recentlyButton.layer.borderColor = buttonBorderColor.cgColor
        vwContainer.layer.cornerRadius = 10.0
        self.vwContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        vwTopLine.isHidden = true
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
       // self.layer.cornerRadius = 10.0
        recentlyButton.titleLabel?.font = UIFont(name: "Regular-SemiBold", size: 18)
        vwTopLine.backgroundColor = UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    }
    
}
