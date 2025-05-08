//
//  DeviceDetailCell.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 23/08/22.
//

import UIKit

class ConnectedDeviceDetailCell: UITableViewCell {
    @IBOutlet weak var labelHeaderLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var lblDeviceInfoTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDeviceDetail: UILabel!
    @IBOutlet weak var lblDeviceInfo:  UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //For iPod
        if currentScreenWidth < xibDesignWidth {
            labelHeaderLeadingConstraint.constant = (labelHeaderLeadingConstraint.constant/xibDesignWidth)*currentScreenWidth
           // lblDeviceInfoTrailingConstraint.constant = labelHeaderLeadingConstraint.constant
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
