//
//  EditCCHeaderTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 06/12/24.
//

import UIKit

class EditCCHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var cardExpiryView: UIView!
    @IBOutlet weak var cardExpiryText: UILabel!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var cardExpiryImage: UIImageView!
    @IBOutlet weak var headerLabelBottomConstraintToSuperView: NSLayoutConstraint!
    @IBOutlet weak var headerLabelBottomConstraintToCardExpiry: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
