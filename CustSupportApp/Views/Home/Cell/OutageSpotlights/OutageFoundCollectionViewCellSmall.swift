//
//  OutageFoundCollectionViewCellSmall.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 03/10/24.
//

import UIKit

class OutageFoundCollectionViewCellSmall: UICollectionViewCell {

    @IBOutlet weak var outageTitleLabel: UILabel!
    @IBOutlet weak var outageSubTitleLabel: UILabel!
    @IBOutlet weak var outageActionButton: UIButton!
    @IBOutlet weak var billImageView: UIImageView!
    var handler: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func outageButtonAction(_ sender: UIButton) {
        handler?()
    }
}
