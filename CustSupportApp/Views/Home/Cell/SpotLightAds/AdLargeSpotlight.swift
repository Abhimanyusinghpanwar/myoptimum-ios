//
//  SpotLightTemplate_One_Large.swift
//  CustSupportApp
//
//  Created by Namarta on 30/10/22.
//

class AdLargeSpotlight: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var helperView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
