//
//  SectionHeaderCellTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

import UIKit

class SectionHeaderCellTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwTopBackground: UIView!
    @IBOutlet weak var vwTopCornerRadius: UIView!
    @IBOutlet weak var vwBottomLine: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    //Button Outlet Connections
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnEditDevices: UIButton!
    var profile:ProfileModel?
    let lineTextColor = UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpUIAttributes()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///Method for handling UI attributes.
    func setUpUIAttributes() {
        vwTopCornerRadius.layer.cornerRadius = 10
        vwTopCornerRadius.layer.masksToBounds = true
        vwTopCornerRadius.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        vwBottomLine.backgroundColor = lineTextColor
        lblTitle.font = UIFont(name: "Regular-Medium", size: 24)
        btnEdit.isHidden = true
        btnEditDevices.isHidden = true
    }
    
    ///Method for handling UI values.
    func setUpUI(section: Int) {
        if section == 1 {
            vwTopBackground.backgroundColor = .clear
            let deviceCount = self.profile?.devices.count ?? 0
            if deviceCount == 0 {
//                if let profileObj = self.profile {
//                    if profileObj.isMaster {
//                        lblTitle.text = "Devices"
//                    } else {
//                        lblTitle.text =  (profile?.profileName ?? " ") + "'s devices"
//                    }
//                }
                lblTitle.text = "Devices"
            } else {
                if MyWifiManager.shared.checkOnlineActivityExistsForProfile(profile: self.profile){
                   let totalConnectedHours = MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: self.profile).0
                    lblTitle.text = totalConnectedHours > 1 ? "Online for \(totalConnectedHours) hours today" : ( totalConnectedHours == 1 ? "Online for \(totalConnectedHours) hour today" : "Online less than an hour today")
                } else {
                    lblTitle.text = "Time online today"
                }
            btnEdit.isHidden = true
            btnEditDevices.isHidden = true
        }
        } else if section == 2 {
            vwTopBackground.backgroundColor = .white
            lblTitle.text =  (profile?.profileName ?? " ") + "'s devices"
            btnEdit.isHidden = false
            btnEditDevices.isHidden = false
        } /*else if section == 3 {
            vwTopBackground.backgroundColor = .white
            lblTitle.text = "Automatically pause Internet" //Need to handle text dynamically
            btnEdit.isHidden = true
        }*/ else {
            vwTopBackground.backgroundColor = .white
            lblTitle.text = ""
        }
    }
}
