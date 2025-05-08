//
//  OutageDetectedCollectionViewCellSmall.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 03/10/24.
//

import UIKit

class OutageDetectedCollectionViewCellSmall: UICollectionViewCell {

    @IBOutlet weak var outageImageView: UIImageView!
    @IBOutlet weak var outageDetectedView: UIStackView!
    @IBOutlet weak var outageClearedView: UIStackView!
    @IBOutlet weak var outageTitle: UILabel!
    @IBOutlet weak var outageSubTitle: UILabel!
    @IBOutlet weak var outageClearedTitle: UILabel!
    @IBOutlet weak var btnMoreInfo: UIButton!
    @IBOutlet weak var dismissView: UIView!
    var handler: (() -> Void)?
    var handler1: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func moreInfoButtonAction(_ sender: UIButton) {
        handler?()
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        handler1?()
    }
    
}
