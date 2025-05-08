//
//  EditCCCardDetailsTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 06/12/24.
//

import UIKit

class EditCCCardDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var cardDetailsLabel: UILabel!
    @IBOutlet weak var autopayStackView: UIStackView!
    @IBOutlet weak var cardImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
