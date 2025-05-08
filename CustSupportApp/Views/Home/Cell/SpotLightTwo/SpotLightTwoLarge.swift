//
//  SpotLightTemplate_One_Large.swift
//  CustSupportApp
//
//  Created by Namarta on 30/10/22.
//

class SpotLightTwoLarge: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var btnActionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    var handler: (() -> Void)?
    var spotlightId = ""
    var tapTarget = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        self.actionButton.isHidden = false
        spotlightId = ""
    }

    @IBAction func onTapPayNow(_ sender: UIButton) {
        handler?()
    }
}
