//
//  SpotLightTemplate_One_Large.swift
//  CustSupportApp
//
//  Created by Namarta on 30/10/22.
//

import Foundation
import GoogleMobileAds
class SpotLightOneSmall: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imagetopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTrailingConstraint: NSLayoutConstraint!
    
   // @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerActivityIndicator: UIActivityIndicatorView!
    
    // Google Ad outlets
    @IBOutlet weak var customAdView: UIView!
    @IBOutlet weak var gAdContentImageView: UIImageView!
    @IBOutlet weak var headlineView: UILabel!
    @IBOutlet weak var bodyView: UILabel!
    @IBOutlet weak var callToActionView: UIButton!
    @IBOutlet weak var gAdBadge: UIImageView!
    
    var spotlightId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        if CurrentDevice.isSmallScreenDeviceSEFirstGen() {
//            return viewWidthConstraint.constant = 120
//    }
        self.customAdView.isHidden = true
        bannerActivityIndicator.startAnimating()
        bannerActivityIndicator.isHidden = false
        }
    
    override func prepareForReuse() {
        self.actionButton.isHidden = false
        spotlightId = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.actionButton.layer.cornerRadius = self.actionButton.layer.bounds.height / 2
//        if MyWifiManager.shared.wifiDisplayType == .Other
//        {
//           let  wifiStatus = MyWifiManager.shared.getMyWifiStatus()
//            if wifiStatus == .wifiDown
//            {
//                self.fixItBtnTopConstraint.constant = 60
//            }
//        }
        
    }
    
    func loadGoogleAdViews() {
        bannerActivityIndicator.stopAnimating()
        bannerActivityIndicator.isHidden = true
        self.gAdContentImageView.image = CustomGAdLoader.shared.adImage
        self.headlineView.text = CustomGAdLoader.shared.headlineText
        self.bodyView.text = CustomGAdLoader.shared.bodyText
        self.customAdView.isHidden = false
        
        self.callToActionView.setTitle(CustomGAdLoader.shared.callToActionText, for: .normal)
        self.callToActionView.isHidden = false
        //self.callToActionView.addTarget(self, action: #selector(adButtonClick(_:)), for: .touchUpInside)
        self.callToActionView.layer.borderColor = UIColor.clear.cgColor
        self.callToActionView.titleLabel?.font = UIFont(name: "Regular-Bold", size: 16)
        self.callToActionView.layer.borderWidth = 2.0
        self.callToActionView.layer.cornerRadius = 16.0
        self.callToActionView.isUserInteractionEnabled = true
        
        let shadowPath = UIBezierPath(roundedRect: gAdBadge.bounds, cornerRadius: 5).cgPath
        gAdBadge.layer.masksToBounds = false
        gAdBadge.layer.shadowColor = UIColor.gray.cgColor
        gAdBadge.layer.shadowOffset = CGSize.zero
        gAdBadge.layer.shadowOpacity = 0.5
        gAdBadge.layer.shadowRadius = 5
        gAdBadge.layer.shadowPath = shadowPath
    }
    
//    @objc func adButtonClick(_ button: UIButton) {
//        Logger.info("Ad button click")
//        
//        // Web click event
//        if let phoneURL = CustomGAdLoader.shared.phoneNumber, !phoneURL.isEmpty {
//            // Phone click event
//            if let url = URL(string: "tel://\(phoneURL)"), UIApplication.shared.canOpenURL(url) {
//                CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
//                    eventParam: [EVENT_LINK_TEXT : HomePageCards.Google_ad_spotlight_Event.rawValue,
//                                EVENT_SCREEN_NAME: HomePageCards.Google_Ad_Spotlight_Click_to_call.rawValue,
//                               EVENT_SCREEN_CLASS: self.classNameFromInstance]
//                )
//                UIApplication.shared.open(url)
//            }
//        } else {
//            CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
//                eventParam: [EVENT_LINK_TEXT : HomePageCards.Google_ad_spotlight_Event.rawValue,
//                            EVENT_SCREEN_NAME: HomePageCards.Google_Ad_Spotlight_Click_to_web.rawValue,
//                           EVENT_SCREEN_CLASS: self.classNameFromInstance]
//            )
//            CustomGAdLoader.shared.customAdObj?.performClickOnAsset(withKey: "CalltoAction")
//            return
//        }
//    }
}

