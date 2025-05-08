//
//  StreamDeviceTableViewCell.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 05/01/24.
//

import UIKit

class StreamDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var propertyDetailsLabel: UILabel!
    @IBOutlet weak var propertyTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
