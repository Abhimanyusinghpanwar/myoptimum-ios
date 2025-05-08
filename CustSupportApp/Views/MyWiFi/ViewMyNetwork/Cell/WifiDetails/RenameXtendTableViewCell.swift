//
//  RenameXtendTableViewCell.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/30/22.
//

import UIKit

class RenameXtendTableViewCell: UITableViewCell {

    @IBOutlet weak var renameXtendImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let extender = ExtenderDataManager.shared.extenderType
        if extender == 5 {
            renameXtendImageView.image = UIImage(named: "extender5")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
