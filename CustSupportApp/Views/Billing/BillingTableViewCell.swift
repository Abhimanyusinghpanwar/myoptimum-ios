//
//  BillingTableViewCell.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 28/11/23.
//

import UIKit

class BillingTableViewCell: UITableViewCell {

    @IBOutlet weak var lineSeparator: UIView!
    @IBOutlet weak var billingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
