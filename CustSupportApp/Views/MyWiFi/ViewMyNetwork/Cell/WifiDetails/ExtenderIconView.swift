//
//  ExtenderIconView.swift
//  CustSupportApp
//
//  Created by Namarta on 01/09/22.
//

import Foundation
class ExtenderIconView: UIView {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblExtenderName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var btnExtender: UIButton!
    @IBOutlet weak var btnEdit: UIImageView!
    //Image View Outlet Connections
    @IBOutlet weak var imgVwExtender: UIImageView!
    //Constraint Outlet Connections
    @IBOutlet weak var vwContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var vwContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnEditWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
       // handleUI()
    }
    
    func setDefaultValues() {
        btnExtender.setTitle("", for: .normal)
    }
    
    ///Method for handling UI in small screen.
    func handleUI() {
        if currentScreenWidth == 320.0 {
            vwContainerWidth.constant = 100
            vwContainerHeight.constant = 100
        } else {
            vwContainerWidth.constant = 120
            vwContainerHeight.constant = 120
        }
    }
}

