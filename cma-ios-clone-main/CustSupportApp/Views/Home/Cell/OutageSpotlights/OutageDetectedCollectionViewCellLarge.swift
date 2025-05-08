//
//  OutageDetectedCollectionViewCellLarge.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 03/10/24.
//

import UIKit

class OutageDetectedCollectionViewCellLarge: UICollectionViewCell {

    var handler: (() -> Void)?
    var handler1: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    
    //CMAIOS-2467
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var outageImageView: UIImageView!
    @IBOutlet weak var outageDetectedView: UIStackView!
    @IBOutlet weak var outageClearedView: UIStackView!
    @IBOutlet weak var outageTitle: UILabel!
    @IBOutlet weak var outageSubTitle: UILabel!
    @IBOutlet weak var outageClearedTitle: UILabel!
    @IBOutlet weak var btnMoreInfo: UIButton!
    //
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func crossButtonAction(_ sender: UIButton) {
        handler1?()
    }
    
    @IBAction func moreInfoButtonAction(_ sender: UIButton) {
        handler?()
    }
    
}
