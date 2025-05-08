//
//  ConnectedDevicesTitleTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 24/08/22.
//

import UIKit

class ConnectedDevicesTitleTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwBottomLine: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDefaultValues() {
        
        lblTitle.text = "12 connected devices"
        lblTitle.font = UIFont(name: "Regular-Medium", size: 24)
        vwBottomLine.backgroundColor = UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        self.backgroundColor = .clear
        vwContainer.layer.cornerRadius = 10
        vwContainer.layer.masksToBounds = true
        vwContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
    class EmptyCell: UITableViewCell {
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
