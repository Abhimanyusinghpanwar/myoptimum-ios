//
//  SpotLightFourSmall.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 27/05/24.
//

import UIKit

class SpotLightFourSmall: UICollectionViewCell {

    @IBOutlet weak var billImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTrailingConstraint: NSLayoutConstraint!
    var handler: (() -> Void)?
    var handler1: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    @IBOutlet weak var closeImage: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        handler?()
    }
    
    @IBAction func spotlightButtonAction(_ sender: UIButton) {
        handler1?()
    }
    
}
