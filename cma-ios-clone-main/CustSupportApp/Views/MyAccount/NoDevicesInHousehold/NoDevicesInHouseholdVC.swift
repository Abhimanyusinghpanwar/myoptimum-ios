//
//  NoDevicesInHouseholdVC.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 19/09/22.
//

import UIKit
import Lottie
class NoDevicesInHouseholdVC: UIViewController {
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    
    @IBOutlet weak var animationView: LottieAnimationView!
    //Label Outlet Connections
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var lblDescriptionTwo: UILabel!

    //Button Outlet Connections
    @IBOutlet weak var btnLetsDoIt: UIButton!
    @IBOutlet weak var btnMayBeLater: UIButton!
    //Constraint Outlet Connections
    @IBOutlet weak var lblHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnMayBeLaterTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnMayBeLaterBottomConstraint: NSLayoutConstraint!
    var isFirstUserExperience = false
    //Color for UI and description text
    let descriptionTextColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
    let btnBorderColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        handleUIConstants()
        self.lblHeader.setLineHeight(1.2)
        let smartWifiValue = MyWifiManager.shared.isGateWayWifi5OrAbove()
         switch smartWifiValue {
//         case 6:
//            lblDescriptionnewAdded.isHidden = false
//            //lblDescriptionTwo.text = "\u{2022} Encourage healthy screen time habits! Pause the Internet for bedtime, homework and more - automatically."
//            lblDescriptionTwo.text = "\u{2022} Encourage healthy screen time habits!"
//            lblDescriptionThree.text = "\u{2022} Easily pause the Internet for members of your household"
//             lblDescriptionnewAdded.text = "\u{2022} See how much time everyone spends online"
            
         case 5,6,7:
             let arrayOfLines = ["Encourage healthy screen time habits!","See how much time everyone spends online"]
             lblDescriptionTwo.add(stringList: arrayOfLines, font: UIFont(name: "Regular-Regular", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0))
         default:
            //handle text below WIFI5
             break
         }
        if isFirstUserExperience
        {
            self.btnMayBeLater.titleLabel?.font = UIFont(name: "Regular-Medium", size: 18)
            self.btnMayBeLater.setTitle("Maybe Later", for: .normal)
            setUpUI()
        }
        else
        {
            self.btnMayBeLater.titleLabel?.text = ""
            self.btnMayBeLater.setImage(UIImage(named: "closeImage.png"), for: .normal)
            btnMayBeLater.layer.borderWidth = 0
            // cross button here
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackAnalytics()
        viewAnimationSetUp()
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func trackAnalytics() {
        var event = ""
        if isFirstUserExperience {
            event = ProfileEvent.Profiles_firstuse_managemyhousehold.rawValue
        }
        else {
            event = ProfileEvent.Profiles_managemyhousehold_nohouseholdpofiles.rawValue
        }
        if event.isEmpty { return }
        //CMAIOS-2215 pass custom params to existing track action
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func viewAnimationSetUp() {
        self.animationView.animation = nil
        self.animationView.animation = LottieAnimation.named("FirstSetupFamily")
        self.animationView.loopMode = .playOnce
        self.animationView.animationSpeed = 1.0
        self.animationView.play { _ in
        }
    }
    ///Method for handling UI text and attributes
    func setUpUI() {
        btnMayBeLater.layer.borderWidth = 2
        btnMayBeLater.layer.borderColor = btnBorderColor.cgColor
    }
    
    ///Method for handling UI constants as per screen size
    func handleUIConstants() {
        if currentScreenWidth == 320.0 {
            ///Constraints for small screens
            handleUIFonts(isSmallScreen: true)
            smallMediumUIConstants()
           // imgViewWidthConstraint.constant = currentScreenWidth
            lblHeaderHeightConstraint.constant = 18
            //viewDotDescTwoTopConstraint.constant = 11
            //viewDotDescThreeTopConstraint.constant = 11
            btnMayBeLaterTopConstraint.constant = 15
            btnMayBeLaterBottomConstraint.constant = 15
        } else if currentScreenWidth <= 375.0 {
            ///Constraints for medium screens
            handleUIFonts(isSmallScreen: false)
            smallMediumUIConstants()
            mediumLargeUIConstants()
            //imgViewWidthConstraint.constant = currentScreenWidth
            //viewDotDescTwoTopConstraint.constant = 9
        } else {
            ///Constraints for large screens
            //imgViewWidthConstraint.constant = 375
            handleUIFonts(isSmallScreen: false)
            mediumLargeUIConstants()
            //lblDescOneHeightConstraint.constant = 22
           // lblDescTwoHeightConstraint.constant = 22
           // viewDotDescTwoTopConstraint.constant = 7
        }
        
    }
    ///Method for handling UI fonts as per screen size
    func handleUIFonts(isSmallScreen: Bool) {
        if isSmallScreen {
            ///Font and Constraint for small screen
            lblHeader.font = UIFont(name: "Regular-Bold", size: 20)
            
            lblDescriptionTwo.font = UIFont(name: "Regular-Regular", size: 15)
        } else {
            ///Font and Constraint for medium and large screen
            lblHeader.font = UIFont(name: "Regular-Bold", size: 24)
            
            lblDescriptionTwo.font = UIFont(name: "Regular-Regular", size: 18)
        }
    }
    ///Method for medium and large screen common constants
    func mediumLargeUIConstants() {
        lblHeaderHeightConstraint.constant = 60

        //lblHeaderTopConstraint.constant = 20

       // lblDescTwoTopConstraint.constant = 10
       // lblDescThreeTopConstraint.constant = 10
        btnMayBeLaterTopConstraint.constant = 30
        btnMayBeLaterBottomConstraint.constant = 30
    }
    ///Method for small and medium screen common constants
    func smallMediumUIConstants() {
       // lblDescOneHeightConstraint.constant = 44
        //lblDescTwoHeightConstraint.constant = 44
    }

    // MARK: - UIButton Action
    @IBAction func btnLetsDoItTapAction(_ sender: Any) {
        self.navigationController?.removeViewControllerIfExists(ofClass: ProfileNameViewController.self)
        guard let vc = ProfileNameViewController.instantiate() else { return }
        vc.state = .add(isMaster: false, name: "")
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnMayBeLaterTapAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
