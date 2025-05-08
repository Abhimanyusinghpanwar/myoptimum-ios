//
//  ProfileDetailWithoutDeviceCell.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 27/10/22.
//

import UIKit

class ProfileDetailWithoutDeviceCell: UITableViewCell {
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnTopSpacingFromHeaderLabel: NSLayoutConstraint!
    @IBOutlet weak var btnTopSpacingFromFirstLabel: NSLayoutConstraint!
    @IBOutlet weak var btnLetsDoIt: RoundedButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
