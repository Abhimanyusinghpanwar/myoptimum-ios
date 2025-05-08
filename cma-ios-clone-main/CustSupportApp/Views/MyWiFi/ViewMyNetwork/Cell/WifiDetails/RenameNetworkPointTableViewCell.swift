//
//  RenameNetworkPointTableViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 08/11/22.
//

import UIKit
import Lottie
class RenameNetworkPointTableViewCell: UITableViewCell {

    @IBOutlet weak var networkStatus: UILabel!
    @IBOutlet weak var networkStatusImage: UIImageView!
    @IBOutlet weak var networkPointName: UILabel!
    @IBOutlet weak var networkPointIcon: UIImageView!
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    @IBOutlet weak var viewAnimationTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tvNetworkPointName: UILabel!
    @IBOutlet weak var tvNetworkPointIcon: UIImageView!

    @IBOutlet weak var tvNetworkIconTopConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if UIDevice.current.hasNotch {
            viewAnimationTopConstraint.constant = 0
        } else {
            viewAnimationTopConstraint.constant = 10
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showCircleAnimation() {
        viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseDefault")
        viewAnimation.backgroundColor = .clear
        viewAnimation.loopMode = .loop
        viewAnimation.animationSpeed = 1.0
        viewAnimation.play()
    }
    
}
