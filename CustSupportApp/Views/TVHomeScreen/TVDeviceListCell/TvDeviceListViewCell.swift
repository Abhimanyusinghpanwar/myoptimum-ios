//
//  TvDeviceListViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 27/11/23.
//

import UIKit

class TvDeviceListViewCell: UICollectionViewCell {

    @IBOutlet weak var lblDeviceStatus: UILabel!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblStream: UILabel!
    @IBOutlet weak var streamIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblDeviceStatus.layer.masksToBounds = true
        self.lblDeviceStatus.layer.cornerRadius = 7
     
    }

}
