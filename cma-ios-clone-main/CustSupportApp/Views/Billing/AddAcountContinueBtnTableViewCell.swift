//
//  AddAcountContinueBtnTableViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 29/02/24.
//

import UIKit
import Lottie

class AddAcountContinueBtnTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueBtn: RoundedButton!
    @IBOutlet weak var continueAnimationView: LottieAnimationView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
