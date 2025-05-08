//
//  HelpWithBillingSubDescriptionCell.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 30/10/23.
//

import UIKit

class HelpWithBillingSubDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var bottomConstraintSubTitle: NSLayoutConstraint!
    @IBOutlet weak var LableTitle: UILabel!
    @IBOutlet weak var LableSubTitle: UILabel!
 
    @IBOutlet weak var subtitleLabelTopConstarint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
