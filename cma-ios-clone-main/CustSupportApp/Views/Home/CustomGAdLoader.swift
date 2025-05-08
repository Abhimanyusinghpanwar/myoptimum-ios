//
//  CustomGAdLoader.swift
//  CustSupportApp
//
//  Created by Namarta on 19/12/24.
//

import Foundation
import GoogleMobileAds
protocol GoogleAdLoadHandler: AnyObject {
    func didReceiveAdObjects()
    func didFailToLoadAd()
}
class CustomGAdLoader: NSObject {
    weak var delegate: GoogleAdLoadHandler?
    var customAdObj: GADCustomNativeAd?
    var adLoader: GADAdLoader!
    var adImage: UIImage?
    var headlineText: String?
    var bodyText: String?
    var callToActionText: String?
    var phoneNumber: String?
    class var shared: CustomGAdLoader {
        struct Singleton {
            static let instance = CustomGAdLoader()
        }
        return Singleton.instance
    }
    
    //Loads AdElements if its enabled
    func loadGoogleAd() {
        if ConfigService.shared.ad_enabled.lowercased() != "true" || SpotLightsManager.shared.gAdCardEligible == false {
            Logger.info("Google Ad not enabled")
            return
        }
        self.adLoader = GADAdLoader(adUnitID: ConfigService.shared.ad_id, rootViewController: HomeScreenViewController.init(), adTypes: [.customNative], options: nil)
        DispatchQueue.main.async {
            self.adLoader.load(GADRequest())
        }
        self.adLoader.delegate = CustomGAdLoader.shared
    }
    
    func resetValues() {
        self.adImage = nil
        self.headlineText = ""
        self.bodyText = ""
        self.callToActionText = ""
        self.phoneNumber = ""
        SpotLightsManager.shared.adLoadingComplete = false
    }
}

extension CustomGAdLoader: GADAdLoaderDelegate, GADCustomNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        if SpotLightsManager.shared.adLoadingComplete {
            return
        }
        self.handleAdFailure(0)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        Logger.info("ad loaded")
        //SpotLightsManager.shared.adLoadingComplete = true
    }
}


extension CustomGAdLoader: GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["12410678"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        Logger.info("Received custom native ad:")
        SpotLightsManager.shared.adLoadingComplete = true
        customNativeAd.delegate = self
        if CurrentDevice.forLargeSpotlights() {
            self.adImage = customNativeAd.image(forKey: "LargeImage")?.image
        } else {
            self.adImage = customNativeAd.image(forKey: "SmallImage")?.image
        }
        self.headlineText = customNativeAd.string(forKey: "Headline")
        self.bodyText = customNativeAd.string(forKey: "BodyText")
        if MyWifiManager.shared.getRegion().lowercased() == "optimum" {
            self.phoneNumber = customNativeAd.string(forKey: "eastphonenumber") ?? ""
        } else if MyWifiManager.shared.getRegion().lowercased() == "sdl" {
            self.phoneNumber = customNativeAd.string(forKey: "westphonenumber") ?? ""
        } else {
            self.phoneNumber = customNativeAd.string(forKey: "PhoneNumber") ?? "" //Added backup logic for phone number key value
        }
        self.callToActionText = customNativeAd.string(forKey: "CalltoAction")
        customNativeAd.customClickHandler = nil
        self.customAdObj = customNativeAd
        DispatchQueue.main.async {
            self.loadCardUI(0)
        }
       // self.loadCardUI(0)
    }
    
    // When googleAd elements are loaded before homescreen loads, the delegate will nil. 
    // Below recurssion is with retries to ensure loading google Ad UI.
    func loadCardUI(_ retry: Int) {
        if retry == 3 {
            return
        }
        if let del = self.delegate {
            del.didReceiveAdObjects()
        } else {
            let _retry = retry + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.loadCardUI(_retry)
            }
        }
    }
    // When googleAd elements are loaded before homescreen loads, the delegate will nil. 
    // Below recurssion is with retries handle to ensure loading google Ad failure.
    func handleAdFailure(_ retry: Int) {
        if retry == 3 {
            return
        }
        if let del = self.delegate {
            del.didFailToLoadAd()
        } else {
            let _retry = retry + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.handleAdFailure(_retry)
            }
        }
    }
    
    func customNativeAdDidRecordClick(_ nativeAd: GADCustomNativeAd) {
        Logger.info("click event")
    }
}
