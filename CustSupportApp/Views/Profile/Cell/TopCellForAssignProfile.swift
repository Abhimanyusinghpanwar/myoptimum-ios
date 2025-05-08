//
//  TopCellForAssignProfile.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 08/05/23.
//

import UIKit
protocol sendDeviceImage {
    func getDeviceIconFromAssignProfileScreen(image : UIImageView)
}

class TopCellForAssignProfile: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceiconImageView: UIImageView!
    var delegateforDeviceIcon : sendDeviceImage?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }
    func passDeviceIcon () {
        delegateforDeviceIcon?.getDeviceIconFromAssignProfileScreen(image: self.deviceiconImageView)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
