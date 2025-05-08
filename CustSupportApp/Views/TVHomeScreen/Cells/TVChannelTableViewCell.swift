//
//  TVChannelTableViewCell.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 27/11/23.
//

import UIKit

class TVChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var serialNoLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
