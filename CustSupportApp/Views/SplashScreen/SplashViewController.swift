//
//  SplashViewController.swift
//  LaBoxApp
//
//  Created by Sriram Rajagopalan01 on 22/05/19.
//  Copyright © 2019 Altice USA. All rights reserved.
//

import UIKit
import VideoSubscriberAccount

class SplashViewController: UIViewController {
    
    // MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if  let loginData = PreferenceHandler.getValuesForKey("loginAuthenticationData") as? [String : AnyObject], let accessToken = loginData["access_token"] as? String, !accessToken.isEmpty {
            APIRequests.shared.performDeviceRegistration{status, error in
                Logger.info("",shouldLogContext: status)
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.isSplashShown {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SplashSSO"), object: true, userInfo: nil)
                appDelegate.dismissSplashOverlay()
            }
        }
        // Do any additional setup after loading the view.
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.SPLASH_SCREEN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
