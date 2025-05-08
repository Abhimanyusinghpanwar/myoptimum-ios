//
//  MakePaymentTableViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 11/12/23.
//

import UIKit

class MakePaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPriceVal: UILabel!
    @IBOutlet weak var lblAmountDue: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override public func layoutSubviews() {
            super.layoutSubviews()
            if bounds.size != intrinsicContentSize {
                invalidateIntrinsicContentSize()
            }
        }
        
//        override public var intrinsicContentSize: CGSize {
//            layoutIfNeeded()
//            return contentSize
//        }
    
   
}
