//
//  SpotLightThreeSmall.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 24/05/24.
//

import UIKit

class SpotLightThreeSmall: UICollectionViewCell {

    @IBOutlet weak var billImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var buttonView: UIControl!
    @IBOutlet weak var subTitleToButtonView: NSLayoutConstraint!
    @IBOutlet weak var subTitleToSuperView: NSLayoutConstraint!
    @IBOutlet weak var crossViewLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeImage: UIImageView!
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
    
    @IBAction func closeButtonAction(_ sender: Any) {
        handler?()
    }
    @IBAction func billButtonAction(_ sender: UIControl) {
        handler1?()
    }
    @IBAction func btnMoreInfoAction(_ sender: UIControl) {
        handler2?()
    }
}
