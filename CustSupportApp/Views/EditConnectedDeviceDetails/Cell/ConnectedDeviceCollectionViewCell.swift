//
//  ConnectedDeviceCollectionViewCell.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 09/11/22.
//

import UIKit
import Lottie

class ConnectedDeviceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var backgroundContentView: UIView!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundContentView.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        self.backgroundContentView.layer.cornerRadius = 20
        self.backgroundContentView.layer.borderWidth = 1
        deviceName.font = UIFont(name: "Regular-Medium", size: 13)
        backgroundWidth.constant = (CurrentDevice.forLargeSpotlights() || UIDevice().hasNotch) ? 95 : 85
    }
    
}
