//
//  BillingPreferencesOffTableViewCell.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 08/12/23.
//

import UIKit
import Lottie

class BillingPreferencesOffTableViewCell: UITableViewCell {
    @IBOutlet weak var billingPreferencesImage: UIImageView!
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var letsDoItButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lottieAnimationView: LottieAnimationView! //CMA-2798
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainView.layer.borderWidth = 1.0
        self.mainView.layer.cornerRadius = 20.0
        self.mainView.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 0.5).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
