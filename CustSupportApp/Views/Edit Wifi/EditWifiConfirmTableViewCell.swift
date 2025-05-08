//
//  EditWifiConfirmTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 18/07/22.
//

import UIKit

class EditWifiConfirmTableViewCell: UITableViewCell {

    @IBOutlet weak var ghzLabel: UILabel!
    @IBOutlet weak var networkNameLabel: UILabel!
    @IBOutlet weak var networkNameTextLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextLabel: UILabel!
    @IBOutlet weak var lineSeparation: UIImageView!
    @IBOutlet weak var lineSeparationView: UIView!
    @IBOutlet weak var networkNameTopSpace: NSLayoutConstraint!
    @IBOutlet weak var networkNameTopSpaceToLabel: NSLayoutConstraint!
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
            networkNameTopSpace.constant = 19.0
        } else {
            networkNameTopSpace.constant = 24.5
        }
    }
}
