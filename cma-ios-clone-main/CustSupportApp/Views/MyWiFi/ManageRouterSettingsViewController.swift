//
//  ManageRouterSettingsViewController.swift
//  CustSupportApp
//
//  Created by Jason Melvin Ready on 8/3/22.
//

import Foundation
import UIKit
import SafariServices

class ManageRouterSettingsViewController:UIViewController{
    
    let headerTextColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    let descriptionTextColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    let headerColor = UIColor.init(red: 39.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    let dividerColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 0.5)
    let headerFontSize = 18.0
    let descriptionFontSize = 15.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var portForwardingOptionView: UIView!
    @IBOutlet weak var portManagementOptionView: UIView!
    @IBOutlet weak var lanSetupOptionView: UIView!
    @IBOutlet weak var dnsManagementOptionView: UIView!
    @IBOutlet weak var wifiTroubleOptionView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var rebootGatewayButton: UIButton!
    @IBOutlet weak var portForwardingButton: UIButton!
    @IBOutlet weak var portManagementButton: UIButton!
    @IBOutlet weak var lanSetupButton: UIButton!
    @IBOutlet weak var dnsManagementButton: UIButton!
    
    @IBOutlet weak var portForwardingTitleLabel: UILabel!
    @IBOutlet weak var portManagementTitleLabel: UILabel!
    @IBOutlet weak var lanSetupTitleLabel: UILabel!
    @IBOutlet weak var dnsManagementTitleLabel: UILabel!
    @IBOutlet weak var wifiTroubleTitleLabel: UILabel!
    
    @IBOutlet weak var portForwardingDescriptionLabel: UILabel!
    @IBOutlet weak var portManagementDescriptionLabel: UILabel!
    @IBOutlet weak var lanSetupDescriptionLabel: UILabel!
    @IBOutlet weak var dnsManagementDescriptionLabel: UILabel!
    @IBOutlet weak var wifiTroubleDescriptionLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var qualtricsAction :DispatchWorkItem?
    @IBAction func portForwardingButtonPressed(_ sender: Any) {
        self.navigateToInAppBrowser(ConfigService.shared.portForwarding, title: "Manage Router")
    }
    @IBAction func portManagementButtonPressed(_ sender: Any) {
        self.navigateToInAppBrowser(ConfigService.shared.portManagement, title: "Port Management")
    }
    @IBAction func lanSetupButtonPressed(_ sender: Any){
        self.navigateToInAppBrowser(ConfigService.shared.lansetup, title: "Lan Setup")
    }
    @IBAction func dnsManagementButtonPressed(_ sender: Any) {
        self.navigateToInAppBrowser(ConfigService.shared.dnsManagement, title: "DNS Management")
    }
    
    
    
    @IBAction func rebootGatewayButtonPressed(_ sender: Any) {
        qualtricsAction?.cancel()
        APIRequests.shared.isReloadNotRequiredForMaui = true
        IntentsManager.sharedInstance.screenFlow = .restartMyInternetEquipment
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RestartCountDownTimerViewController")
        self.navigationController?.pushViewController(vc, animated: true)
//        APIRequests.shared.initiateRebootRequest() { success, error in
//                        
//        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
          qualtricsAction?.cancel()
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromLeft
//        self.view.window?.layer.add(transition, forKey: kCATransition)
//        DispatchQueue.main.async {
//            self.dismiss(animated: false)
//        }
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        qualtricsAction?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        qualtricsAction = self.checkQualtrics(screenName: WiFiManagementScreenDetails.WIFI_MANAGE_ROUTER_SETTINGS.rawValue, dispatchBlock: &qualtricsAction)
    }
    
    override func viewDidLoad() {
        setFontAndBackground()
        createDividers()
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(scrollView.contentSize.height > scrollView.frame.size.height){
            self.bottomView.addTopShadow()
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME :WiFiManagementScreenDetails.WIFI_MANAGE_ROUTER_SETTINGS.rawValue, 
                                                                   CUSTOM_PARAM_FIXED : Fixed.Data.rawValue,
                                                                   CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,
                                                                   CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue,
                                                                    EVENT_SCREEN_CLASS:self.classNameFromInstance])
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func createDividers(){
        for currentView in [portForwardingOptionView, portManagementOptionView, lanSetupOptionView, dnsManagementOptionView]{
            if let currentView = currentView{
                let lineLayer = CALayer()
                lineLayer.frame = CGRect(x: 0, y: currentView.frame.height - 1.0, width: currentView.frame.width, height: 1.0)
                lineLayer.backgroundColor = dividerColor.cgColor
                currentView.layer.addSublayer(lineLayer)
            }
            
        }
    }
    private func setFontAndBackground(){
        titleLabel.font = UIFont(name: "Regular-Bold", size: 28)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = headerColor
        
        for headerLabel in [portForwardingTitleLabel, portManagementTitleLabel, lanSetupTitleLabel, dnsManagementTitleLabel, wifiTroubleTitleLabel]{
            if let headerLabel = headerLabel{
                headerLabel.font = UIFont(name: "Regular-Bold", size: 18)
                headerLabel.setLineHeight(1.2)
                view.backgroundColor = headerColor
            }
        }
        for descriptionLabel in [portForwardingDescriptionLabel, portManagementDescriptionLabel, lanSetupDescriptionLabel, dnsManagementDescriptionLabel, wifiTroubleDescriptionLabel]{
            if let descriptionLabel = descriptionLabel{
                descriptionLabel.font = UIFont(name: "Regular-Regular", size: 15)
                descriptionLabel.textColor = descriptionTextColor
            }
        }
        for currentButton in [portForwardingButton, portManagementButton, lanSetupButton, dnsManagementButton, closeButton]
        {
            if let currentButton = currentButton{
                currentButton.setTitle("", for: .normal)
                currentButton.setTitle("", for: .selected)
            }
            if currentButton != closeButton{
                currentButton?.isUserInteractionEnabled = false
            }
        }
        
        if let rebootGatewayButton = rebootGatewayButton{
            rebootGatewayButton.layer.cornerRadius = 30
            rebootGatewayButton.layer.borderWidth = 2
            rebootGatewayButton.layer.borderColor = descriptionTextColor.cgColor
            rebootGatewayButton.titleLabel?.font = UIFont(name: "Regular-SemiBold", size: 18)
        }
    }
}

// MARK: - SFSafariViewController Delegates
extension ManageRouterSettingsViewController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser(_ URLString : String, title : String) {
            self.qualtricsAction?.cancel()
            let safariVC = SFSafariViewController(url: URL(string: URLString)!)
            safariVC.delegate = self
            
            //make status bar have default style for safariVC
            
            self.present(safariVC, animated: true, completion:nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //make status bar have light style since going back to UIApplication
    }
}

