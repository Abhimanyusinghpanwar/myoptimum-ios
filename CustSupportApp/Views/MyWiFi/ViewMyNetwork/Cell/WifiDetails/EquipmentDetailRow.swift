//
//  EquipmentDetailRow.swift
//  CustSupportApp
//
//  Created by Namarta on 30/09/22.
//

import Foundation
class EquipmentDetailRow: UITableViewCell {
    //View Outlet Connections
    @IBOutlet weak var detailContentView: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblLeftColumn: UILabel!
    @IBOutlet weak var lblRightColumn: UILabel!
    @IBOutlet weak var lblLeftLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblRightTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
        adjustConstraintConstants()
    }
    
    func setDefaultValues() {
        lblLeftColumn.text = ""
        lblRightColumn.text = ""
        lblLeftColumn.font = UIFont(name: "Regular-Regular", size: 18)
        lblRightColumn.font = UIFont(name: "Regular-Bold", size: 18)
        lblRightColumn.numberOfLines = 0
        lblRightColumn.adjustsFontSizeToFitWidth = true
        lblRightColumn.minimumScaleFactor = 0.2
    }
    
    func adjustConstraintConstants(){
        switch currentScreenWidth {
        case 375:
            lblLeftLeadingConstraint.constant = 30.0
            lblRightTrailingConstraint.constant = 30.0
        default:
            lblLeftLeadingConstraint.constant = 40.0
            lblRightTrailingConstraint.constant = 40.0
        }
    }
    
    func setValues(title:String, value:String) {
        lblLeftColumn.text = title
        lblRightColumn.text = value
    }
    
}
