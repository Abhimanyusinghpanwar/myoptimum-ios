//
//  BillingListMenuCell.swift
//  CustSupportApp
//
//  Created by vsamikeri on 7/21/22.
//

import UIKit

class BillingListMenuCell: UITableViewCell {
    
    @IBOutlet weak var billingListMenuLabel: UILabel!
    @IBOutlet weak var billingListMenuSwitchLbl: UILabel!
    @IBOutlet weak var saperatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }
    
    func hideOnOffUsingErrorState(model: BillingDataModel) {
        if model.optionID == 0 || model.optionID == 3 {
            billingListMenuSwitchLbl.text = ""
        } else {
            billingListMenuSwitchLbl.isHidden = model.isErrorState // hide if error state is true
            billingListMenuSwitchLbl.text = model.isEnabled ? "On": "Off"
        }
    }

}
