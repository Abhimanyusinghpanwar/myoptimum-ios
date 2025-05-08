//
//  ManageMyHouseholdDetailCell.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 19/09/22.
//

import UIKit

class ManageMyHouseholdDetailCell: UITableViewCell {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var profileAvatarImgView: UIImageView!
    
    @IBOutlet weak var btnDeleteProfile: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
