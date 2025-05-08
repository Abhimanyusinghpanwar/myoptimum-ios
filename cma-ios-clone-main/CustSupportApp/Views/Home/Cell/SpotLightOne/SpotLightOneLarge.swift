//
//  SpotLightTemplate_One_Large.swift
//  CustSupportApp
//
//  Created by Namarta on 30/10/22.
//
import GoogleMobileAds

class SpotLightOneLarge: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    // @IBOutlet weak var letsFixBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bannerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleStackViewTrailingConstraint: NSLayoutConstraint!
    var spotlightId = ""
    @IBOutlet weak var imagetopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    // Google Ad outlets
    @IBOutlet weak var customAdView: UIView!
    @IBOutlet weak var headlineView: UILabel!
    @IBOutlet weak var bodyView: UILabel!
    @IBOutlet weak var callToActionView: UIButton!
    @IBOutlet weak var gAdContentImageView: UIImageView!
    @IBOutlet weak var gAdBadge: UIImageView!
    
//    var customAdObj: GADCustomNativeAd?
//    var adLoader: GADAdLoader!
//    var phoneURL = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerActivityIndicator.startAnimating()
        bannerActivityIndicator.isHidden = false
        customAdView.layer.cornerRadius = 16.0
        self.customAdView.isHidden = true
    }
    
    override func prepareForReuse() {
        self.actionButton.isHidden = false
        spotlightId = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if MyWifiManager.shared.wifiDisplayType == .Other
        {
            let  wifiStatus = MyWifiManager.shared.getMyWifiStatus()
            if wifiStatus == .wifiDown
            {
                self.titleLabelTopConstraint.constant = 10
            }
        }
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
    
//    //CMAIOS-2531
//    func trackGAEventForAd(){
//        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : HomePageCards.Google_Ad_Spotlight.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
//    }
}
/*
extension SpotLightOneLarge: GADAdLoaderDelegate, GADCustomNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        if SpotLightsManager.shared.adLoadingComplete {
            return
        }
        self.containerView.isHidden = true
        self.customAdView.isHidden = true
        bannerActivityIndicator.stopAnimating()
        bannerActivityIndicator.isHidden = true
        if SpotLightsManager.shared.arrSpotLights.isEmpty {
            SpotLightsManager.shared.configureSpotLightsForThankYou()
        } else if (SpotLightsManager.shared.arrSpotLights.count == 1) && SpotLightsManager.shared.arrSpotLights[0] == .adType {
            configureThanksCardUI()
        } else {
            SpotLightsManager.shared.suppressGAdCard()
        }
    }
    
    func configureThanksCardUI() {
        self.containerView.isHidden = false
        self.containerView.backgroundColor = .white
        self.actionButton.isHidden = true
        self.iconImage.image = UIImage(named: "thankyou")
        self.subTitle.text = "Thank you for being a customer"
        self.title.text = "We wouldn’t be here without you!"
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        Logger.info("ad loaded")
        bannerActivityIndicator.stopAnimating()
        bannerActivityIndicator.isHidden = true
        self.customAdView.isHidden = false
        SpotLightsManager.shared.adLoadingComplete = true
    }
}

extension SpotLightOneLarge: GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["12410678"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        Logger.info("Received custom native ad:")
        SpotLightsManager.shared.adLoadingComplete = true
        customNativeAd.delegate = self
        self.gAdContentImageView.image = customNativeAd.image(forKey: "LargeImage")?.image
        self.headlineView.text = customNativeAd.string(forKey: "Headline")
        //print(customNativeAd.availableAssetKeys)
        self.bodyView.text = customNativeAd.string(forKey: "BodyText")
        self.bodyView?.isHidden = customNativeAd.string(forKey: "BodyText")?.isEmpty == true
        customNativeAd.customClickHandler = nil
        //CMA-3106
        if MyWifiManager.shared.getRegion().lowercased() == "optimum" {
            self.phoneURL = customNativeAd.string(forKey: "eastphonenumber") ?? ""
        } else if MyWifiManager.shared.getRegion().lowercased() == "sdl" {
            self.phoneURL = customNativeAd.string(forKey: "westphonenumber") ?? ""
        }
        self.callToActionView.setTitle(customNativeAd.string(forKey: "CalltoAction"), for: .normal)
        self.callToActionView.isHidden = false
        self.callToActionView.addTarget(self, action: #selector(adButtonClick(_:)), for: .touchUpInside)
        self.callToActionView.layer.borderColor = UIColor.clear.cgColor
        self.callToActionView.titleLabel?.font = UIFont(name: "Regular-Bold", size: 16)
        self.callToActionView.layer.borderWidth = 2.0
        self.callToActionView.layer.cornerRadius = 16.0
        self.callToActionView.isUserInteractionEnabled = true
        self.customAdObj = customNativeAd
        
        let shadowPath = UIBezierPath(roundedRect: gAdBadge.bounds, cornerRadius: 5).cgPath
        gAdBadge.layer.masksToBounds = false
        gAdBadge.layer.shadowColor = UIColor.gray.cgColor
        gAdBadge.layer.shadowOffset = CGSize.zero
        gAdBadge.layer.shadowOpacity = 0.5
        gAdBadge.layer.shadowRadius = 5
        gAdBadge.layer.shadowPath = shadowPath
    }
    
    func customNativeAdDidRecordClick(_ nativeAd: GADCustomNativeAd) {
        Logger.info("click event")
    }
    
    @objc func adButtonClick(_ button: UIButton) {
        Logger.info("Ad button click")
        
        // Web click event
        if phoneURL.isEmpty {
            CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
                eventParam: [EVENT_LINK_TEXT : HomePageCards.Google_ad_spotlight_Event.rawValue,
                            EVENT_SCREEN_NAME: HomePageCards.Google_Ad_Spotlight_Click_to_web.rawValue,
                           EVENT_SCREEN_CLASS: self.classNameFromInstance]
            )
            self.customAdObj?.performClickOnAsset(withKey: "CalltoAction")
            return
        }
        
        // Phone click event
        if let url = URL(string: "tel://\(phoneURL)"), UIApplication.shared.canOpenURL(url) {
            CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
                eventParam: [EVENT_LINK_TEXT : HomePageCards.Google_ad_spotlight_Event.rawValue,
                            EVENT_SCREEN_NAME: HomePageCards.Google_Ad_Spotlight_Click_to_call.rawValue,
                           EVENT_SCREEN_CLASS: self.classNameFromInstance]
            )
            UIApplication.shared.open(url)
        }
    }
    
    
}
*/
