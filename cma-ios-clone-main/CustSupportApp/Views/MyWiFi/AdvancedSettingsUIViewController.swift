//
//  AdvancedSettingsUIViewController.swift
//  CustSupportApp
//
//  Created by Jason Melvin Ready on 7/19/22.
//

import Foundation
import UIKit

class AdvancedSettingsUIViewController: CommonNavigationVC{
    
    
    let headerTextColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    let descriptionTextColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    let headerColor = UIColor.init(red: 39.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    let dividerColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 0.5)
    let headerFontSize = 18.0
    let descriptionFontSize = 15.0
    private var showInternetSpeedOption = true
    private var showManageMyHouseholdOption = false
    private var showManageRouterSettingsOption = false
    
    public var performTransition = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkInternetSpeedView: UIView!
    @IBOutlet weak var internetSpeedHeaderLabel: UILabel!
    @IBOutlet weak var internetSpeedDescriptionLabel: UILabel!
    @IBOutlet weak var internetSpeedButton: UIButton!
    @IBOutlet weak var manageMyHouseholdView: UIView!
    @IBOutlet weak var manageMyHouseholdHeaderLabel: UILabel!
    @IBOutlet weak var manageMyHouseholdDescriptionLabel: UILabel!
    @IBOutlet weak var manageMyHouseholdButton: UIButton!
    @IBOutlet weak var installAnExtenderView: UIView!
    @IBOutlet weak var installExtenderHeaderLabel: UILabel!
    
    @IBOutlet weak var installExtenderButton: UIButton!
    
    @IBOutlet weak var installExtenderDescriptionLabel: UILabel!
    
    @IBOutlet weak var installExtenderViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var manageRouterSettingsView: UIView!
    @IBOutlet weak var manageRouterSettingsHeaderLabel: UILabel!
    @IBOutlet weak var manageRouterSettingsDescriptionLabel: UILabel!
    @IBOutlet weak var manageRouterSettingsButton: UIButton!
    @IBOutlet weak var closePageView: UIView!
    @IBOutlet weak var closePageButton: UIButton!
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkInternetSpeedHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var manageMyHouseholdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var manageRouterSettingsHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var manageMyHouseholdTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var manageRouterSettingsDescLabelTrailingConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var mainView: UIView!
    var qualtricsAction : DispatchWorkItem?
    override func viewDidLoad() {
        setFontAndBackground()
        layoutViews(displayType: MyWifiManager.shared.wifiDisplayType)
        createDividers()
    }
    private func layoutViews(displayType:WifiOptionDisplayType){
        
        //check internet speed is only hidden if no supported gateway is found
        if displayType != .None{
            checkInternetSpeedHeightConstraint.constant = 77
            checkInternetSpeedView.isHidden = false
        }
        else{
            checkInternetSpeedHeightConstraint.constant = 0
            checkInternetSpeedView.isHidden = true
        }
        
        
        if MyWifiManager.shared.isSmartWifi() {
            //manage my household option only shown to users with gateway
            manageMyHouseholdHeightConstraint.constant = 113
            manageMyHouseholdView.isHidden = false
        }
        else{
            manageMyHouseholdHeightConstraint.constant = 0
            manageMyHouseholdView.isHidden = true
        }
        if displayType == .Gateway || displayType == .ManagedLegacyRouter {
            //manage router settings option shown to gateway users and users with managed legacy routers
            manageRouterSettingsHeightConstraint.constant = 95
            manageRouterSettingsView.isHidden = false
        }
        else{
            manageRouterSettingsHeightConstraint.constant = 0
            manageRouterSettingsView.isHidden = true
        }
        //Install an Extender hidden for non-SmartWifi devices CMAIOS-949
        if MyWifiManager.shared.isSmartWifi() {
            //Install extender view
            installExtenderViewHeightConstraint.constant = 95
            installAnExtenderView.isHidden = false
        } else {
            //Install extender view
            installExtenderViewHeightConstraint.constant = 0
            installAnExtenderView.isHidden = true
        }
        updateUIConstraints()
    }
    private func setFontAndBackground(){
        titleLabel.font = UIFont(name: "Regular-Bold", size: 28)
        titleLabel.textColor = .white
        view.backgroundColor = headerColor
        mainView.backgroundColor = .white
        
        for headerLabel in [internetSpeedHeaderLabel, manageMyHouseholdHeaderLabel, manageRouterSettingsHeaderLabel, installExtenderHeaderLabel]{
            headerLabel!.font = UIFont(name: "Regular-Bold", size: 18)
            headerLabel!.textColor = headerTextColor
            headerLabel?.setLineHeight()
        }
        for descriptionLabel in [internetSpeedDescriptionLabel, manageMyHouseholdDescriptionLabel, manageRouterSettingsDescriptionLabel, installExtenderDescriptionLabel]{
            descriptionLabel!.font = UIFont(name: "Regular-Regular", size: 15)
            descriptionLabel!.textColor = descriptionTextColor
            descriptionLabel?.setLineHeight(1.2)
        }
        for currentButton in [internetSpeedButton, manageMyHouseholdButton, manageRouterSettingsButton, installExtenderButton]{
            currentButton?.isUserInteractionEnabled = false
        }
        closePageButton.titleLabel?.text = ""
    }
    private func updateUIConstraints() {
        if CurrentDevice.isSmallScreenDevice() {
            manageMyHouseholdTrailingConstraint.constant = 28.0
            manageRouterSettingsDescLabelTrailingConstraint.constant = 28.0
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.qualtricsAction?.cancel()
    }
    override func viewWillAppear(_ animated: Bool) {
        MyWifiManager.shared.isFromHealthCheck = false
        MyWifiManager.shared.isFromSpeedTest = false
        MyWifiManager.shared.isCloseButtonClicked = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if performTransition{
            let screenHeight = UIApplication.shared.windows[0].frame.height
            mainViewTopConstraint.constant = screenHeight
            mainViewBottomConstraint.constant = -1.0 * screenHeight
            closePageView.alpha = 0.0
            closeViewHeightConstraint.constant = 40.0
            titleLabel.alpha = 0.25
            titleConstraint.constant = 0
            UIView.animate(withDuration: 1.0) {
                self.titleLabel.alpha = 1.0
            }
            view.layoutSubviews()
        }
        else{
            self.mainViewTopConstraint.constant = 22.0
            self.mainViewBottomConstraint.constant = 0
            self.closePageView.alpha = 1.0;
            self.view.layoutSubviews()
            self.closeViewHeightConstraint.constant = 80.0
            self.titleConstraint.constant = 15.0
            self.view.layoutSubviews()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if performTransition{
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.7) {
                self.mainViewTopConstraint.constant = 22.0
                self.mainViewBottomConstraint.constant = 0
                self.closePageView.alpha = 1.0;
                self.view.layoutSubviews()
                self.closeViewHeightConstraint.constant = 80.0
                self.titleConstraint.constant = 15.0
                self.view.layoutSubviews()
            }
            performTransition = false
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_MORE_OPTIONS.rawValue,
                                                                   CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                  CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                   CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue,
                                                                    EVENT_SCREEN_CLASS:self.classNameFromInstance])
        qualtricsAction = self.checkQualtrics(screenName: WiFiManagementScreenDetails.WIFI_MORE_OPTIONS.rawValue, dispatchBlock: &qualtricsAction)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func createDividers(){
        for currentView in [checkInternetSpeedView, manageMyHouseholdView, installAnExtenderView]{
            let lineLayer = CALayer()
            lineLayer.frame = CGRect(x: 0, y: currentView!.frame.height - 1.0, width: currentView!.frame.width, height: 1.0)
            lineLayer.backgroundColor = dividerColor.cgColor
            currentView!.layer.addSublayer(lineLayer)
            currentView!.clipsToBounds = true
        }
//        let lineLayer = CALayer()
//        lineLayer.frame = CGRect(x:0, y:0, width:closePageView.frame.width, height:1.0)
//        lineLayer.backgroundColor = dividerColor.cgColor
//        closePageView.layer.addSublayer(lineLayer)
    }
    
    @IBAction func internetSpeedButtonClicked(_ sender: Any) {
        // CMAIOS:-2506
        guard let cardInfo = MyWifiManager.shared.checkForOutagesWithSpotLight("Internet") else {
            self.qualtricsAction?.cancel()
            IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.checkIntSpeed
            guard let nav = UIViewController.instantiate(from: .speedTest) else { return }
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            return
        }
        guard let vc = CheckOutageStatusViewController.instantiateWithIdentifier(from: .speedTest) else { return }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: false)

        /*
        if MyWifiManager.shared.checkForOutagesWithSpotLight()?.priorityKey == "1.1" && MyWifiManager.shared.checkForOutagesWithSpotLight()?.button?.template == "midnightblue" {
            guard let vc = CheckOutageStatusViewController.instantiateWithIdentifier(from: .speedTest) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            self.qualtricsAction?.cancel()
            IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.checkIntSpeed
            guard let nav = UIViewController.instantiate(from: .speedTest) else { return }
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
         */
    }
    
    @IBAction func manageMyHouseholdButtonClicked(_ sender: Any) {
        self.qualtricsAction?.cancel()
        navigateToManageMyHousehold(householdProfilesExists: checkHasHouseHoldProfiles(), isFromMyAccount: false)
    }
    
    @IBAction func installAnExtenderButtonTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
        ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendUpAndRunningVC")
        
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navVC, animated: true)
        ExtenderDataManager.shared.isExtenderTroubleshootFlow = false
        
    }
    
    @IBAction func manageRouterSettingsButtonClicked(_ sender: Any) {
        self.qualtricsAction?.cancel()
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromRight
//        self.view.window?.layer.add(transition, forKey: kCATransition)
//        let storyboard = UIStoryboard(name: "WiFiScreen", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "routersettings")
//        vc.modalPresentationStyle = .fullScreen
//        DispatchQueue.main.async {
//            self.present(vc, animated: false)
//        }
        let storyboard = UIStoryboard(name: "WiFiScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "routersettings")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func closePageButtonPressed(_ sender: Any) {
        self.qualtricsAction?.cancel()
        UIView.animate(withDuration: 0.3){
            self.titleLabel.alpha = 0.0
            self.mainView.alpha = 0.0
            self.closePageView.alpha = 0.0
        } completion: { _ in
            IntentsManager.sharedInstance.screenFlow = .none
            self.dismiss(animated: false)
        }
        
    }
    
}
