//
//  EditWifiUpdatedTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 18/07/22.
//

import UIKit

class EditWifiUpdatedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var updatedLabel: UILabel!

    
    @IBOutlet weak var iconTopSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateTopSpace()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateTopSpace() {
        if CurrentDevice.forLargeSpotlights() {
            iconTopSpace.constant = 1.0
        } else {
            iconTopSpace.constant = 3.0
        }
    }
}
