//
//  AuthenticationErrorViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 30/12/22.
//

import UIKit
import Lottie
class AuthenticationErrorViewController: UIViewController {

    @IBOutlet weak var animationView: LottieAnimationView!
    
    @IBOutlet weak var businessAccountLbl: UILabel!
    @IBOutlet weak var descriptionLbll: UILabel!
    @IBOutlet weak var signInWithAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginPreferenceManager.sharedInstance.removeLoginPreferences()
        animation()
    }
    
    override func viewDidAppear(_ animated: Bool){
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_SIGN_IN_BUSINESS_ACCOUNT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
    }
    
    func animation(){
        self.animationView.backgroundColor = .clear
        self.animationView.animation = nil
        self.animationView.animation = LottieAnimation.named("BusinessAccount")
        self.animationView.loopMode = .playOnce
        self.animationView.animationSpeed = 1.0
        self.animationView.play()
    }
    @IBAction func signInMyHomeAccountAction(_ sender: Any) {
        DispatchQueue.main.async {
       //     let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as LoginViewController
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
