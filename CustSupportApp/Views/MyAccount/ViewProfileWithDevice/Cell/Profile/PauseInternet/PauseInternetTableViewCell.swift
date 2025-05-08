//
//  PauseInternetTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

import UIKit
import Lottie

class PauseInternetTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    //Image View Outlet Connections
    @IBOutlet weak var imgVwPause: UIImageView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwPause: UIView!
    @IBOutlet weak var btnPauseInternet: UIButton!
    var saveInProgress:Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///Method for handling UI attributes.
    func setUpUIAttributes(pauseBtnText : String, pauseImageName: String) {
        vwPause.layer.cornerRadius = 20
        lblTitle.font = UIFont(name: "Regular-Medium", size: 18)
        lblTitle.text = pauseBtnText
        imgVwPause.image = UIImage(named:pauseImageName)
    }
    
    ///Method for edit page action
    @IBAction func showEditPage(_ sender: Any) {
        
    }
}
