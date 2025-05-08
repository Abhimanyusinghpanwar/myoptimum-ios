//
//  ProfileAlertViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 23/11/22.
//

import UIKit

class ProfileAlertViewController: UIViewController {
    enum State {
        case add(Profile)
        
        var profile: Profile {
            switch self {
            case let .add(profile):
                return profile
            }
        }
    }
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var goBackButton: UIButton!
    var state: State!
    let buttonBorderColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        goBackButton.layer.cornerRadius = 30
        goBackButton.layer.borderWidth = 2
        goBackButton.layer.borderColor = buttonBorderColor.cgColor
        self.navigationItem.hidesBackButton = true
        headerLabel.text = "Are you sure you want to continue without adding any devices for \(state.profile.profile ?? "")?"
        if MyWifiManager.shared.isGateWayWifi6() {
            //infoLabel.text = "If you do, you won’t be able to automatically pause the internet for \(state.profile.profile ?? "")."
            infoLabel.text = "If you do, you won't be able to pause the Internet for \(state.profile.profile ?? "")."
        } else {
            infoLabel.text = ""
        }
        self.headerLabel.setLineHeight(1.14)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackAnalytics()
    }
    
    func trackAnalytics() {
        var event = ""
        if headerLabel.text?.contains("Are you sure you want to continue without adding") == true {
            event = ProfileEvent.Profiles_addperson_assigndevices_skip.rawValue
        }
        if event.isEmpty { return }
        //CMAIOS-2215
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
        vc.state = .add(state.profile)
        vc.isShowPauseSchedule = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissAlertAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
