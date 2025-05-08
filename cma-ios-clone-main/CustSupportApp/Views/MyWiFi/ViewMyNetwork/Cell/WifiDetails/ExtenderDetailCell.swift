//
//  ExtenderDetailCell.swift
//  CustSupportApp
//
//  Created by vishali Test on 26/04/24.
//

import UIKit

class ExtenderDetailCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblExtenderName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnLetsFixIt: UIButton!
    //Image View Outlet Connections
    @IBOutlet weak var imgVwExtender: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnLetsFixIt.layer.borderColor = UIColor.white.cgColor
        setLabelFont()
        // Initialization code
    }
    
    func setLabelFont(){
        if currentScreenWidth > 375.0{
            self.lblExtenderName.font = UIFont(name: "Regular-Medium", size: 18.0)
        } else {
            self.lblExtenderName.font = UIFont(name: "Regular-Medium", size: 17.5)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func updateExtenderName(extenderDetails: Extender?){
        self.lblExtenderName.text = extenderDetails?.title
        //CMAIOS-2355 get status color as per extender state(Weak, Offline, Online)
        let statusColor = extenderDetails?.getColor()
        self.lblStatus.text = statusColor?.status
        self.imgVwExtender.contentMode = .scaleAspectFit
        self.imgVwExtender.image = extenderDetails?.image
        if let color = extenderDetails?.getThemeColor(), let mac = extenderDetails?.macAddress, !mac.isEmpty {
            if color != energyBlueRGB {
                self.btnLetsFixIt.isHidden = false
            } else {
                self.btnLetsFixIt.isHidden = true
            }
            if extenderDetails?.status == "Offline" {
                self.imgStatus.backgroundColor = .StatusOffline
            } else {
                self.imgStatus.backgroundColor = statusColor?.color
            }
            self.vwContainer.backgroundColor = color
            self.contentView.backgroundColor = color
        } else {
            return
        }
    }
    
    func btnEditExtenderNameAction(){
        
    }

}
