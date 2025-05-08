//
//  ProfileCompletionViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 23/11/22.
//

import UIKit
import Lottie

class ProfileCompletionViewController: UIViewController {
    enum State {
        case add(Profile)
        
        var profile: Profile {
            switch self {
            case let .add(profile):
                return profile
            }
        }
    }
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var animationView: LottieAnimationView!
    let buttonBorderColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    var state: State!
    var isShowPauseSchedule = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackAnalytics()
    }
    
    func trackAnalytics() {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ProfileEvent.Profiles_householdprofile_setup_complete.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func configureUI() {
        // Set the corner radius for the top corners
        let cornerRadius: CGFloat = 10
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        infoView.layer.mask = maskLayer
        if let profileText = state.profile.profile {        profileNameLabel.text = profileText
        let avatar: String
        
        var avatarId = state.profile.avatar_id ?? 13
            if avatarId >= 13 || avatarId == 0 {
                avatarId = 13
            }
            var avatarNames = AvatarConstants.names
            if let letter = state.profile.profile?.prefix(1).capitalized {
                avatarNames.append(letter)
            }
            avatar = avatarNames[avatarId - 1]
     //   }
//        else {
//            avatar = state.profile.profile?.prefix(1).capitalized ?? ""
//        }
        let name: String = "\(avatar)-Profile-Pause-Online"
        animationView.animation = LottieAnimation.named(name)
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        animationView.play()
        secondaryButton.layer.cornerRadius = 30
        secondaryButton.layer.borderWidth = 2
        secondaryButton.layer.borderColor = buttonBorderColor.cgColor
        if !isShowPauseSchedule {
            headerLabel.text = "Congratulations!"
            infoLabel.text = "You have added \(profileNameLabel.text ?? "")’s profile to your household."
            primaryButton.setTitle("Add another", for: .normal)
            secondaryButton.setTitle("I'm done", for: .normal)
        } else {
            headerLabel.text = "Do you want to automatically pause the internet for \(profileNameLabel.text ?? "")?"
            infoLabel.text = "You can schedule a pause at bedtime or during the day."
            primaryButton.setTitle("Yes", for: .normal)
            secondaryButton.setTitle("Not now", for: .normal)
            }
        }
        self.infoLabel.setLineHeight(1.2)
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        if let isExists = navigationController?.checkIfViewControllerExists(ofClass: ManageMyHouseholdDevicesVC.self), isExists {
            navigationController?.popToViewController(ofClass: ManageMyHouseholdDevicesVC.self)
        } else {
            if ProfileManager.shared.isFirstUserCompleted, let isExists = navigationController?.checkIfViewControllerExists(ofClass: NoDevicesInHouseholdVC.self), isExists {
                let vc = UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(identifier: "ManageMyHouseholdDevicesVC") as ManageMyHouseholdDevicesVC
                    vc.modalPresentationStyle = .fullScreen
                    pushViewControllerWithLeftToRightAnimation(vc, from: self)
                
            }
            else {
                navigationController?.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func primaryButtonAction(_ sender: UIButton) {
        if !isShowPauseSchedule {
            self.navigationController?.removeViewControllerIfExists(ofClass: ProfileNameViewController.self)
            guard let vc = ProfileNameViewController.instantiate() else { return }
            vc.state = .add(isMaster: false, name: "")
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            //Add Pause schedule navigation
            let vc = UIStoryboard(name: "PauseSchedule", bundle: nil).instantiateViewController(identifier: "PauseScheduleVC") as PauseScheduleViewController
            vc.state = .add(state.profile)
            navigationController?.pushViewController(vc, animated: true)
        }
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
