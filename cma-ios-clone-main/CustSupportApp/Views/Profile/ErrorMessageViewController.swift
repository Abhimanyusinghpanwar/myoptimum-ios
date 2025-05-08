//
//  ErrorMessageViewController.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 28/01/23.
//

import UIKit

class ErrorMessageViewController: UIViewController {
    var state: ProfileSelectDeviceViewController.State?
    var navToProfileCompletionVC: Bool = false
    var isComingFromEditDeviceNameVC : Bool = false
    var isComingFromSpeedTestVC : Bool = false
    @IBOutlet weak var errorMessageLbl: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    var primayButtonTitle: String = ""
    @IBOutlet weak var primaryButton: UIButton!
    var errorMessageString: (headerTitle:String, subtitle:String) = ("", "")
    var isMessageLblExists: Bool = false
    var isComingFromProfileCreationScreen = false
    var isComingFromMyWifiPage:Bool = false
    var isComingFromBillingMenu = false
    var isComingFromCardInfoPage = false
    var isComingFromFinishSetup = false
    var isComingFromDeleteProfile = false
    var isComingFromAssignDeviceToProfileVC = false
    var isFromManagePayment = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        if primayButtonTitle != "" {
            primaryButton.setTitle(primayButtonTitle, for: .normal)
        }
        if errorMessageString.headerTitle != ""{
            errorMessageLbl.attributedText = NSMutableAttributedString(string: errorMessageString.headerTitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
        if isComingFromProfileCreationScreen
        {
            primaryButton.backgroundColor = .clear
            primaryButton.setTitle("", for: .normal)
            primaryButton.setImage(UIImage(named: "Close_Blue_Icon.png"), for: .normal)
        }
        messageLabel.attributedText = NSMutableAttributedString(string: errorMessageString.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTapAction(_ sender: Any) {
        if navToProfileCompletionVC
        {
            if !state!.isEdit {
                guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
                vc.state = .add(state!.profile)
                vc.isShowPauseSchedule = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
        else if isComingFromEditDeviceNameVC
        {
            //remove BG View used for deviceIcon Animation before dismissing
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RemoveBGAnimationView"),object: nil))
            //Dismiss to ViewMyNetworkScreen
            self.dismissToViewMyNetwork()
        }
        else if isComingFromCardInfoPage
        {
            self.onComingFromCardInfoPage()
        }
        else if isComingFromMyWifiPage
        {
            //Dismiss to MyWifiScreen
            MyWifiManager.shared.isCloseButtonClicked = true
            APIRequests.shared.isReloadNotRequiredForMaui = false
            self.dismissToMyWifiScreen()
        }
        else if isComingFromSpeedTestVC || isComingFromAssignDeviceToProfileVC
        {
            if isComingFromSpeedTestVC
            {
                MyWifiManager.shared.isCloseButtonClicked = true
            }
            self.dismissToMoreOptions()
        }
        else if isComingFromFinishSetup || isComingFromBillingMenu {
            self.onComingFromFinishSetup()
        }
        else if isComingFromProfileCreationScreen
        {
            if ProfileManager.shared.isFirstUserExperience {
                dismissToHome()
            } else {
                self.dismiss(animated: true)
            }
        }
        else if isComingFromDeleteProfile
        {
            dismissToManageMyHousehold()
        } else if isFromManagePayment {
            //CMAIOS-2578 handled okay button navigation
            if let managePaymentVC = self.navigationController?.viewControllers.filter({$0.isKind(of: ManagePaymentsViewController.classForCoder())}).first as? ManagePaymentsViewController {
              self.navigationController?.popToViewController(managePaymentVC, animated: true)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            self.dismiss(animated: true)
        }
    }
    
    func dismissToViewMyNetwork(){
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func dismissToMoreOptions(){
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func dismissToMyWifiScreen(){
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func dismissToHome() {
        //Dismiss to HomeScreen if error appears in First user experience
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func dismissToManageMyHousehold() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func onComingFromCardInfoPage() {
        //CMAIOS-2861
        if let managePaymentVC = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController { // CMAIOS:-2622
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managePaymentVC, animated: true)
            }
            return
        } else if let billingView = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingView, animated: true)
            }
            return
        } else {
            if  let navVC = self.presentingViewController as? UINavigationController, let homeScreen = navVC.viewControllers.first(where: { $0.isKind(of: HomeScreenViewController.self)}) {
                navVC.dismiss(animated: true) // CMAIOS:-2667
            } else {
                self.dismissToViewMyNetwork()
            }
        }
    }
    
    func onComingFromFinishSetup() {
        if let managePaymentVC = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController { // CMAIOS:-2622
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managePaymentVC, animated: true)
            }
            return
        } else  if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
            return
        } else if let navigationControl = self.presentingViewController as? UINavigationController {
            if let billingView = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: false, completion: {
                        navigationControl.popToViewController(billingView, animated: true)
                    })
                }
            } else if let homeView = navigationControl.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController {
                self.dismiss(animated: true) //Fixed navigation issue on click of okay button if the user is coming from OneTimeFailureScreen from Spotlight and tries to add new MOP after tapping use different method but it fails.
            }
        } else {
            if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            } else {
                if let homeView = self.navigationController?.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController { // CMAIOS:-2549
                    self.navigationController?.popToViewController(homeView, animated: true)
                    return
                }
                self.dismissToMoreOptions()
            }
        }
    }
}
