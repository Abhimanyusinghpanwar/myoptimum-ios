//
//  TopDevicesTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

import UIKit

class TopDevicesTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///Method for handling UI attributes.
    func setUpUIAttributes(profile:ProfileModel?) {
        lblTitle.font = UIFont(name: "Regular-Regular", size: 15)
        if let profileExists  = profile, profileExists.devices.count > 0, MyWifiManager.shared.checkOnlineActivityExistsForProfile(profile:profileExists) {
            if MyWifiManager.shared.getTotalConnectedHoursAndDevices(profile: profileExists).1 > 4 {
                lblTitle.text = "Top Devices"
                lblTitle.textColor = UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
            }
        } else if MyWifiManager.shared.isClientUsageAPISucceeded { // if ClientUsage API not failing
            lblTitle.text = "No activity today since 12:00 AM"
            lblTitle.textColor = UIColor.black
        } else {
            //if ClientUsage API fails
            lblTitle.font = UIFont(name: "Regular-Regular", size: 20)
            lblTitle.text = "Sorry, activity isn’t available right now."
            lblTitle.textColor = UIColor(red: 113.0/255.0, green: 113.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_DEVICE_ACTIVITY_API_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])

        }
    }
}
