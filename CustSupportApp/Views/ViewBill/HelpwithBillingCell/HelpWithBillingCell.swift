//
//  HelpWithBillingCell.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 26/09/23.
//

import UIKit

class HelpWithBillingCell: UITableViewCell {
   @IBOutlet weak var titleTextLabel: TTTAttributedLabel!
   @IBOutlet weak var labelLeadingConstarint: NSLayoutConstraint!
   @IBOutlet weak var bulletViewWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
