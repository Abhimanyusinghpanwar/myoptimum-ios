//
//  BillingPreferencesOnTableViewCell.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 08/12/23.
//

import UIKit

class BillingPreferencesOnTableViewCell: UITableViewCell {
    @IBOutlet weak var billingPreferencesImage: UIImageView!
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var editControl: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
