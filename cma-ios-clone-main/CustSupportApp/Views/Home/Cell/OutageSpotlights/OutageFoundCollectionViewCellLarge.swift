//
//  OutageFoundCollectionViewCellLarge.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 03/10/24.
//

import UIKit

class OutageFoundCollectionViewCellLarge: UICollectionViewCell {

    @IBOutlet weak var outageActionButton: UIButton!
    @IBOutlet weak var outageTitleLabel: UILabel!
    @IBOutlet weak var outageSubTitleLabel: UILabel!
    @IBOutlet weak var outageImageView: UIImageView!
    var spotlightId = ""
    var tapTarget = ""
    var handler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func outageButtonAction(_ sender: UIButton) {
        handler?()
    }
}
