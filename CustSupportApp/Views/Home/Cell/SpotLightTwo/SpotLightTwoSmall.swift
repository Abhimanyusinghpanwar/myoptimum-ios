//
//  SpotLightTemplate_One_Large.swift
//  CustSupportApp
//
//  Created by Namarta on 30/10/22.
//

import Foundation
class SpotLightTwoSmall: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    var handler: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerView.layer.cornerRadius = 20
        self.bottomView.layer.cornerRadius = 20
        self.topView.layer.cornerRadius = 20
        self.headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        if CurrentDevice.isSmallScreenDevice(){
            self.topViewHeightConstraint.constant = 130
            }else{
            self.topViewHeightConstraint.constant = 170
            }
         }
    
    override func prepareForReuse() {
        self.actionButton.isHidden = false
        spotlightId = ""
    }

    @IBAction func onTapPayNow(_ sender: UIButton) {
        handler?()
    }
}
