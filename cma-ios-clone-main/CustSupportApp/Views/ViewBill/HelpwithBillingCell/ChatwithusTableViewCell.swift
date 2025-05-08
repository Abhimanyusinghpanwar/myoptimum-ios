//
//  ChatwithusTableViewCell.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 26/09/23.
//

import UIKit

class ChatwithusTableViewCell: UITableViewCell {
    @IBOutlet weak var viewChatwithus: UIView!
    @IBOutlet weak var buttonChat: UIButton!
    @IBOutlet weak var topConstraintViewChatus: NSLayoutConstraint!
    
    @IBOutlet weak var questionLabelTopConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewChatwithus.viewBorderAttributes(UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 0.5).cgColor, 2, 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
