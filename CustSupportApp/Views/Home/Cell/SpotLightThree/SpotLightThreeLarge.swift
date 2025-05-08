//
//  SpotLightThreeLarge.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 24/05/24.
//

import UIKit

class SpotLightThreeLarge: UICollectionViewCell {

    @IBOutlet weak var billImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var crossImage: UIImageView!
    @IBOutlet weak var crossButton: UIButton!
    var handler: (() -> Void)?
    var handler1: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    var accountName = ""
    
    //CMAIOS-2541
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var billView: UIView!
    @IBOutlet weak var discountImageView: UIImageView!
    @IBOutlet weak var discountTitleLabel: UILabel!
    @IBOutlet weak var discountSubTitleLabel: UILabel!
    @IBOutlet weak var moreInfoBtnView: UIView!
    @IBOutlet weak var btnMoreInfo: UIButton!
    var handler2: (() -> Void)?
    //
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btnMoreInfoAction(_ sender: UIControl) {
        handler2?()
    }
    
    @IBAction func crossButtonAction(_ sender: UIButton) {
        handler?()
    }
    
    @IBAction func billButtonAction(_ sender: UIButton) {
        handler1?()
    }
    
}
