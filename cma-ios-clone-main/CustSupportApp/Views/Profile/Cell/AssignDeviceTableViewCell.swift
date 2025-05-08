//
//  AssignDeviceTableViewCell.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 16/11/22.
//

import UIKit
import Lottie

class AssignDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var profileAnimation: LottieAnimationView!
    
    @IBOutlet weak var seperatorLabel: UILabel!
    @IBOutlet weak var ContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileName.font = UIFont(name: "Regular-Medium", size: 20)
        seperatorLabel.backgroundColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
    }
    
    override func prepareForReuse() {
        profileName.text = ""
        checkImage.isHidden = true
        profileAnimation.animation = nil
    }
    
    func setUpCellData(profileDetail:ProfileModel?) {
        guard let profile = profileDetail else {
            return
        }
        profileAnimation.contentMode = .scaleToFill
        profileAnimation.loopMode = .playOnce
        profileAnimation.animationSpeed = 1.0
        profileName.text = profile.profileName
        self.profileAnimation.animation = LottieAnimation.named(profile.avatarImage.onlinePause)
    }
    
}
