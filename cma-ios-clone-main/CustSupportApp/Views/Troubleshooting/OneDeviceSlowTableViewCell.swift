//
//  OneDeviceSlowTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 09/12/22.
//

import UIKit

class OneDeviceSlowTableViewCell: UITableViewCell {

    @IBOutlet weak var networkLabelBottomConstraintToUsername: NSLayoutConstraint!
    @IBOutlet weak var networkLabelBottomConstraintToSuperView: NSLayoutConstraint!
    @IBOutlet weak var usernameLabelBottomConstraintToPassword: NSLayoutConstraint!
    @IBOutlet weak var usernameLabelBottomConstraintToSuperview: NSLayoutConstraint!
    @IBOutlet weak var passwordLabelBottomConstraintToSuperview: NSLayoutConstraint!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var rangeOfNetworkLabel: TTTAttributedLabel!
    @IBOutlet weak var numberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
