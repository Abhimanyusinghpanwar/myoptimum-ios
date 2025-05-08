//
//  DevicesListTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

import UIKit

class DevicesListTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    //ImageView Outlet Connections
    @IBOutlet weak var imgViewType: UIImageView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    //ProgressView Outlet Connections
    @IBOutlet weak var progressViewStatus: UIProgressView!
    
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
        lblTitle.font = UIFont(name: "Regular-Medium", size: 16)
        progressViewStatus.progressTintColor = energyBlueRGB
    }
    ///Method for handling UI.
    func setUpDataInUI(onlineDeviceActivityData: [OnlineActivityDevice], indexpath: IndexPath, profileStatus: ProfileStatus?, topDevicesLabelShown: Bool = false) {
        let updatedIndexRow = topDevicesLabelShown ? indexpath.row - 1 : indexpath.row
        let onlineActivityDevice = onlineDeviceActivityData[updatedIndexRow]
        lblTitle.text = onlineActivityDevice.deviceName
        imgViewType.image = DeviceManager.IconType.gray.getDeviceImage(name: onlineActivityDevice.deviceIcon)
        self.progressViewStatus.progressTintColor = profileStatus != nil && profileStatus == .paused ? pauseBgColor : energyBlueRGB
        self.progressViewStatus.layer.masksToBounds = true
        self.progressViewStatus.layer.cornerRadius = 3.5
     }
    }
