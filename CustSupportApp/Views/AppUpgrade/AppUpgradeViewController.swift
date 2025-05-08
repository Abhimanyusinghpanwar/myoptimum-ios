//
//  AppUpgradeViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 3/9/23.
//

import UIKit
import Lottie

class AppUpgradeViewController: UIViewController {
    
    
    @IBOutlet weak var appUpgradeAnimationView: LottieAnimationView!
    @IBOutlet weak var appUpgradeHeaderLbl: UILabel!
    @IBOutlet weak var appUpgradeTextLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.APP_UPGRADE_SCREEN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func updateUI() {
        appUpgradeAnimationView.animation = LottieAnimation.named("AppMajorUpgrade")
        appUpgradeAnimationView.backgroundColor = .clear
        appUpgradeAnimationView.loopMode = .loop
        appUpgradeAnimationView.animationSpeed = 1.0
        appUpgradeAnimationView.backgroundBehavior = .pauseAndRestore
        appUpgradeAnimationView.play()
    }
    @IBAction func goToAppStoreButton(_ sender: Any) {
        Logger.info("App Store button clicked...")
        launchAppStore()
    }
    
    func launchAppStore() {
        if let url = URL(string: ConfigService.shared.appUpdateUrl) {
            UIApplication.shared.canOpenURL(url)
            UIApplication.shared.open(url, options:[:]) {
                (opened) in
                if opened {
                    Logger.info("App Store opened...")
                } else {
                    Logger.warning("Can't open the URL on the simulator")
                }
            }
        }
    }
}
