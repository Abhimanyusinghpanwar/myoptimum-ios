//
//  SavePayToAccountTableViewCell.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 29/02/24.
//

import UIKit

class SavePayToAccountTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var savePayAccView: UIView!
    @IBOutlet weak var btnSavePayChckBox: UIButton!
    @IBOutlet weak var lblSavePay: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
