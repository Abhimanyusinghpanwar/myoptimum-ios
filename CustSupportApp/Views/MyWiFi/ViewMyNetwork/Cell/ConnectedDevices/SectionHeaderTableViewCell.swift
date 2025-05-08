//
//  SectionHeaderTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 24/08/22.
//

import UIKit

class SectionHeaderTableViewCell: UIView {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
    }
    
    func setDefaultValues() {
        lblTitle.text = ""
        self.backgroundColor = .white
    }
    
}
