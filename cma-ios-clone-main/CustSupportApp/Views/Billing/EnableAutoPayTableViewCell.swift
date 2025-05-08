//
//  EnableAutoPayTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 21/08/24.
//

import UIKit

class EnableAutoPayTableViewCell: UITableViewCell {
    @IBOutlet weak var btnAutoPayCheckBox: UIButton!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
