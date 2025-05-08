//
//  ProfileDetailsTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

import UIKit
import Lottie

class ProfileDetailsTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgStatus: UIImageView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    //Button Outlet Connections
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var profileIconLottieView: LottieAnimationView!
    @IBOutlet weak var profileAvatarLabel: UILabel!
    var profile:Profile?
    
    @IBOutlet weak var btnEditProfileName: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var lblTitleBottomConstraintToSuperview: NSLayoutConstraint!
    @IBOutlet weak var vwStatusBottomConstraintToSuperview: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    ///Method for handling UI attributes.
    func setUpUIAttributes(profile:ProfileModel?, arrHouseHoldProfiles:Profiles? = nil, isPauseUnpauseTapped:Bool) {
        lblTitle.font = UIFont(name: "Regular-Medium", size: 24)
        lblStatus.font = UIFont(name: "Regular-Medium", size: 15)
        lblTitle.text = profile?.profile?.profile
        btnEdit.setTitle("", for: .normal)
        if isPauseUnpauseTapped && (profile?.profileStatus == .paused) {
            self.profileIconLottieView.playAnimationForPauseUnpause(avatarID: profile?.profile?.avatar_id ?? 13, profileName: profile?.profileName, isProfileOnlinePause: true)
        } else if isPauseUnpauseTapped && profile?.profileStatus == .online{
            self.profileIconLottieView.playAnimationForPauseUnpause(avatarID: profile?.profile?.avatar_id ?? 13, profileName: profile?.profileName, isProfileOnlinePause: false)
        } else if !isPauseUnpauseTapped && (profile?.profileStatus == .paused){
            self.profileIconLottieView.playAnimationForPauseUnpause(avatarID: profile?.profile?.avatar_id ?? 13, profileName: profile?.profileName, isProfileOnlinePause: true)
        } else {
            self.profileIconLottieView.createStaticImageForProfileAvatar(avatarID: profile?.profile?.avatar_id ?? 13, profileName: profile?.profileName)
        }
    }
   
    func setProfileStatus(profileStatus:ProfileStatus?){
        if profileStatus != nil {
            self.vwStatusBottomConstraintToSuperview.priority = .defaultLow
            self.lblTitleBottomConstraintToSuperview.priority = .defaultHigh
            self.lblStatus.isHidden = false
            self.imgStatus.isHidden = false
            self.lblStatus.text = profileStatus?.rawValue ?? ""
            switch profileStatus {
            case .online :
                self.imgStatus.backgroundColor = UIColor.StatusOnline
            case .offline:
                self.imgStatus.backgroundColor = UIColor.StatusOffline
            case .paused:
                self.lblStatus.isHidden = !MyWifiManager.shared.isGateWayWifi6()
                self.imgStatus.isHidden = !MyWifiManager.shared.isGateWayWifi6()
                self.lblStatus.text = ProfileModelHelper.shared.getTimeForPauseInternet(isPauseForAnHour: true)
                self.imgStatus.backgroundColor = UIColor.StatusPause
            default :
                break
            }
        } else {
            self.lblStatus.isHidden = true
            self.imgStatus.isHidden = true
            self.vwStatusBottomConstraintToSuperview.priority = .defaultLow
            self.lblTitleBottomConstraintToSuperview.priority = .defaultHigh
        }
    }
    
    ///Button Action
    @IBAction func btnEditTapped(_ sender: UIButton) {
        
        
    }
    
    func setProfileAvatar(avatarId: Int?, profileName: String?)
    {
        let avatarType = Avatar().checkAvatarType(avatarId: avatarId)
        switch avatarType {
        case .alphabet:
            self.profileAvatarLabel.isHidden = false
            guard let houseHoldName = profileName, !houseHoldName.isEmpty else {
                self.profileAvatarLabel.text = " "
                break
            }
            self.profileAvatarLabel.text =  houseHoldName.prefix(1).capitalized
            self.profileIconLottieView.isHidden = true
        case .avatarIcon:
            self.profileIconLottieView.isHidden = false
            self.profileAvatarLabel.isHidden = true
            self.profileIconLottieView.createStaticImageForProfileAvatar(avatarID: avatarId, profileName: profileName)
        case .none:
            break
        }
    }
}
