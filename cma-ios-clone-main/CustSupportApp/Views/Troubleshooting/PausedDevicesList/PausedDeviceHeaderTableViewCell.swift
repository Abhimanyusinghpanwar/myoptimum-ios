//
//  PausedDeviceHeaderTableViewCell.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 22/01/23.
//

import UIKit

class PausedDeviceHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lineSeparationView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
