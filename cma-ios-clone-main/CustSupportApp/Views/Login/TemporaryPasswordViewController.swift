//
//  TemporaryPasswordViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 24/06/22.
//

import UIKit
import SafariServices
import Lottie
class TemporaryPasswordViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var tempPassWordLabel1: UILabel!
    @IBOutlet weak var tempPassWordLabel2: UILabel!
    @IBOutlet weak var createPasswordButton: UIButton!
    var isTempPasswordExpired = false
    var activeTempPassLink = ConfigService.shared.activeTempResetPassUrl
    var expiredPasswordLink = ConfigService.shared.forgotPasswordURL
    
    var optimumId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        if isTempPasswordExpired {
            
            self.animationView.backgroundColor = .clear
            self.animationView.animation = nil
            self.animationView.animation = LottieAnimation.named("TempPasswordExpired")
            self.animationView.loopMode = .playOnce
            self.animationView.animationSpeed = 1.0
            self.animationView.play()
            tempPassWordLabel1.text = "Your temporary password has expired"
            tempPassWordLabel2.text = ""
            tempPassWordLabel2.isHidden = true
            createPasswordButton.setTitle("Reset Optimum password", for: .normal)
        } else {
            self.animationView.backgroundColor = .clear
            self.animationView.animation = nil
            self.animationView.animation = LottieAnimation.named("TempPassword")
            self.animationView.loopMode = .playOnce
            self.animationView.animationSpeed = 1.0
            self.animationView.play()
            tempPassWordLabel1.text = "You signed in with a temporary password"
            tempPassWordLabel2.isHidden = false
            tempPassWordLabel2.text = "Now, let's create a new, permanent password."
            createPasswordButton.setTitle("Create new password", for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool){
        //For Firebase Analytics
        if self.isTempPasswordExpired {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_ERROR_TEMPORARY_PASSWORD_EXPIRED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.AUTHENTICATION_SIGN_IN_TEMPORARY_PASSWORD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
        }
    }
    
    @IBAction func passwordButtonAction(_ sender: Any) {
        let resetURL = URL(string: isTempPasswordExpired ? expiredPasswordLink : activeTempPassLink + "&id=\(self.optimumId)")
        let safariVC = SFSafariViewController(url: resetURL!)
        safariVC.delegate = self
        if self.animationView.isAnimationPlaying {
            self.animationView.stop()
        }
        //make status bar have default style for safariVC
        self.present(safariVC, animated: true, completion:nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*--
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}
