//
//  AddCheckSaveAndTermsTableViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 26/02/24.
//

import UIKit

class AddCheckSaveAndTermsTableViewCell: UITableViewCell {


    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var btnTermsConditionCheckBox: UIButton!
    @IBOutlet weak var lblTermsAndCond: UILabel!
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    var isBtnTapped = false
    var isTermsTapped = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
