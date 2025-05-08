//
//  ManageMyHouseholdCell.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 19/09/22.
//

import UIKit

class ManageMyHouseholdDeviceCell: UITableViewCell {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var profileAvatarImgView: UIImageView!
    @IBOutlet weak var imgDeleteIcon: UIImageView!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var btnDeleteProfile: UIButton!
    @IBOutlet weak var btnViewProfile: UIButton!
    
    @IBOutlet weak var btnViewProfileDevice: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCellData(profileDetail:Profile?) {
        guard let profile = profileDetail else {
            return
        }
        //set masterProfile data for index 0
        if let masterBit = profile.master_bit, masterBit == true {
            self.btnDeleteProfile.isHidden = true
            self.imgDeleteIcon.isHidden = true
        } else {
            self.btnDeleteProfile.isHidden = false
            self.imgDeleteIcon.isHidden = false
        }
        profileName.text = profile.profile
        if let avatarId = profile.avatar_id {
            let permissibleRange = 1...12
            if permissibleRange.contains(avatarId) {
                let imageName = "Online" + "\(avatarId)"
                btnViewProfile.setTitle(" ", for: .normal)
                btnViewProfile.backgroundColor = UIColor.clear
                btnViewProfile.setBackgroundImage(UIImage.init(named: " "), for: .normal)
                profileAvatarImgView.image = UIImage.init(named: imageName)
            } else  {
                if let profile = profile.profile, !profile.isEmpty
                {
                    let letter = profile.prefix(1).capitalized
                    btnViewProfile.backgroundColor = UIColor.white
                    btnViewProfile.setTitle(letter, for: .normal)
                    btnViewProfile.setBackgroundImage(UIImage.init(named: "ShadowView"), for: .normal)
                    profileAvatarImgView.image = UIImage.init(named: " ")
                } else {
                    btnViewProfile.setBackgroundImage(UIImage.init(named: "ShadowView"), for: .normal)
                    profileAvatarImgView.image = UIImage.init(named: " ")
                    btnViewProfile.setTitle(" ", for: .normal)
                }
            } 
        }
    }
}
