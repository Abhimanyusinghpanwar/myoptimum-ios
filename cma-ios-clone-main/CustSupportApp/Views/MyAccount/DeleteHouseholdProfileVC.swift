//
//  DeleteHouseholdProfileVC.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 23/09/22.
//

import UIKit
import Lottie

class DeleteHouseholdProfileVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    var profileDetail : ProfileModel?
    var saveInProgress : Bool = false
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //handle Font for iPod Touch
        if currentScreenHeight < xibDesignHeight {
            handleFontSizeForSmallerScreen(label: lblTitle, fontFamily:"Regular-Bold" , fontSize: 28.0)
        }
        if let profileName = self.profileDetail?.profile?.profile {
            lblTitle.text = "Are you sure you want to delete \(profileName)’s profile?"
        }
        // Do any additional setup after loading the view.
        self.lblTitle.setLineHeight(1.14)
        bottomViewBottomConstraint.constant = UIDevice().hasNotch ? -20 : 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackAnalytics()
    }
    
    func trackAnalytics() {
        //CMAIOS-2215 
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ProfileEvent.Profiles_deleteprofile.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }

    //MARK: Button Actions
    @IBAction func doNotDeleteProfile(_ sender: Any) {
        //do Not Delete Profile Action
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteProfileAction(_ sender: Any) {
        //show animation
        DispatchQueue.main.async {
            self.saveButtonAnimation()
        }
        //Delete HouseHoldProfile API call
        self.deleteHouseHoldProfile()
    }
}

extension UIViewController {
    
    //Handle font for iPod
    func handleFontSizeForSmallerScreen(label:UILabel, fontFamily:String, fontSize:CGFloat){
        label.font = UIFont(name: fontFamily, size: (fontSize/xibDesignWidth)*currentScreenWidth)
    }
    //Handle topConstraint for LargerScreens
    func handleTopSpaceForLargerScreens(topConstraint:NSLayoutConstraint, topConstraintConstant:CGFloat) {
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            topConstraint.constant = UIDevice.current.topInset + topConstraintConstant
        }
    }
    func getTopConstraintForScreens(topConstraintConstant : CGFloat) -> CGFloat {
        var topConstraintValue = 0.0
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            topConstraintValue = UIDevice.current.topInset + topConstraintConstant
        } else {
            topConstraintValue = topConstraintConstant
        }
        return topConstraintValue
    }
    
}

extension DeleteHouseholdProfileVC {
    //MARK: Save Button Animation methods
    func viewAnimationSetUp() {
        self.animationLoadingView.backgroundColor = .clear
        self.animationLoadingView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.animationLoadingView.loopMode = .playOnce
        self.animationLoadingView.animationSpeed = 1.0
        self.animationLoadingView.play(toProgress: 0.6, completion:{_ in
            if self.saveInProgress {
                self.animationLoadingView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func saveButtonAnimation(){
        saveInProgress = true
        buttonStackView.isHidden = true
        UIView.animate(withDuration: 1.0) {
            self.animationLoadingView.isHidden = false
        }
        viewAnimationSetUp()
    }
    
    func stopAnimationAndDismiss() {
        self.saveInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) {[weak self] _ in
                self?.dismiss(animated: true)
            }
        }
    }
    
    func saveButtonAPIFailedAnimation() {
        DispatchQueue.main.async {
            self.saveInProgress = false
            self.animationLoadingView.currentProgress = 3.0
            self.animationLoadingView.stop()
            self.animationLoadingView.isHidden = true
            self.buttonStackView.alpha = 0.0
            self.buttonStackView.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.buttonStackView.alpha = 1.0
            }
            self.delay(seconds: 0.5, execute: {
                self.presentErrorScreen()
            })
        }
    }
}

extension DeleteHouseholdProfileVC {
    //Make Call to deleteAPI
    func deleteHouseHoldProfile() {
        var params = [String:AnyObject]()
        if let profileID = self.profileDetail?.profile?.pid {
            params["pid"] = profileID as AnyObject?
            APIRequests.shared.performDeleteProfileRequest(params: params) {[weak self] success, _, error in
                if success {
                    DispatchQueue.main.async {
                        if let devices = self?.profileDetail?.devices, !devices.isEmpty {
                            if let presentingController = self?.presentingViewController?.presentingViewController?.presentingViewController, presentingController.isKind(of: MyWiFiViewController.self) {
                                for node in devices {
                                    MyWifiManager.shared.saveProfileChangeLocally(for: node.device?.mac ?? "", profileName: "", pid: 0)
                                }
                            }
                        }
                    }
                    self?.updateProfilesList()
                } else {
                    Logger.info("Delete API failed: " + (error?.errorDescription ?? ""))
                    self?.saveButtonAPIFailedAnimation()
                }
            }
        }
    }
    func updateProfilesList() {
        // updating ProfileManager with latest profiles after deleting profile
        ProfileManager.shared.getProfiles { _ in
            self.stopAnimationAndDismiss()
        }
    }
    func presentErrorScreen() {
        if let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as? ErrorMessageViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isComingFromDeleteProfile = true
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .delete_profile_failure)
            self.present(vc, animated: true)
        }
    }
    private func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    }
}
