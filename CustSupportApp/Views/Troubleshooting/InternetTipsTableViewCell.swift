//
//  InternetTipsTableViewCell.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 23/05/23.
//

import UIKit

class InternetTipsTableViewCell: UITableViewCell {
    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipDetailLabel: UILabel!
    @IBOutlet weak var tapLabel: TTTAttributedLabel!
    let tappableText = "optimize the WiFi in your home"
    var tap = UITapGestureRecognizer()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
