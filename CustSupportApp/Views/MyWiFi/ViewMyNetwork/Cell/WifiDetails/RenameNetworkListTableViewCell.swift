//
//  RenameNetworkListTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 09/11/22.
//

import UIKit

class RenameNetworkListTableViewCell: UITableViewCell {
    @IBOutlet weak var networkName: UILabel!
    @IBOutlet weak var networkSelectionConfirmImage: UIImageView!
    @IBOutlet weak var separationView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
