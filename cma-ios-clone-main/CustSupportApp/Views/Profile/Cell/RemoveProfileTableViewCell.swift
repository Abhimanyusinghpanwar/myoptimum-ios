//
//  RemoveProfileTableViewCell.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 24/11/22.
//

import UIKit

class RemoveProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var check: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 12
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
        // Configure the view for the selected state
    }
    
}
