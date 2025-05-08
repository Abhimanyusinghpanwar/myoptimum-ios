//
//  DeviceCollectionViewCell.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 11/10/22.
//

import UIKit
import Lottie

class DeviceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellBackView: UIView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusColorLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    var profileModel: ProfileModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellBackView.backgroundColor = .clear
        self.circularView.backgroundColor = .white
        self.animationView.backgroundColor = .clear
        self.statusLbl.textColor = .black
        self.circularView.layer.cornerRadius = self.circularView.bounds.height/2
        self.statusView.isHidden = true

        self.circularView.layer.shadowColor = UIColor.shadowColor.cgColor
        self.circularView.layer.shadowOpacity = 1
        self.circularView.layer.shadowOffset = .zero
        self.circularView.layer.shadowRadius = 4
        self.statusColorLbl.layer.cornerRadius = self.statusColorLbl.bounds.height/2
        self.statusColorLbl.layer.masksToBounds = true
//        self.profileName.font = UIFont.init(name: "Regular_Medium", size: 18.0)
//        self.statusLbl.font = UIFont.init(name: "Regular-Regular", size: 14.0)
    }
    
    override func prepareForReuse() {
        self.statusView.isHidden = true
        self.statusLbl.text = ""
        profileName.text = ""
        self.statusColorLbl.backgroundColor = UIColor.StatusWeak
    }
    
    func configureCell(profile: ProfileModel)  {
        self.profileModel = profile
        animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .playOnce
        //self.animationView.animationSpeed = 1.0
        profileName.text = profile.profileName
        setStatus(status: profile.profileStatus)
    }
    
    func setStatus(status: ProfileStatus?) {
        guard let state = status else {
            self.animationView.animation = LottieAnimation.named(profileModel.avatarImage.offline)
            return
        }
        if state == .online {
            self.statusLbl.text = "Online"
        } else if state == .paused {
            self.statusLbl.text = "Paused"
        } else if state == .offline {
            self.statusLbl.text = "Offline"
        } else {
            self.statusLbl.text = ""
        }
        self.statusView.isHidden = false
        switch state {
        case .online:
            self.statusColorLbl.backgroundColor = UIColor.StatusOnline
            self.animationView.animation = LottieAnimation.named(profileModel.avatarImage.offline)
        case .offline:
            self.statusColorLbl.backgroundColor = UIColor.StatusOffline
            self.animationView.animation = LottieAnimation.named(profileModel.avatarImage.onlinePause)
        case .paused:
            self.statusLbl.textColor = .gray
            self.statusColorLbl.backgroundColor = UIColor.StatusPause
            self.animationView.animation = LottieAnimation.named(profileModel.avatarImage.offlinePause)
        }
        self.animationView.play()
    }
    
}
