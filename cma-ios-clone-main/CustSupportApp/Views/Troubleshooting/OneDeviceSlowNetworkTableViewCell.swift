//
//  OneDeviceSlowNetworkTableViewCell.swift
//  CustSupportApp
//
//  Created by riyaz on 13/04/23.
//

import UIKit

class OneDeviceSlowNetworkTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ifProblemLabel: TTTAttributedLabel!
    @IBOutlet weak var rangeOfNetworkLabel: TTTAttributedLabel!
    @IBOutlet weak var networkLabel: TTTAttributedLabel!
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
