//
//  OutageDetailsVC.swift
//  CustSupportApp
//
//  Created by mac_admin on 12/09/24.
//

import UIKit

class OutageDetailsVC: UIViewController {
    
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabelLeadingToImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLeadingToSuperViewConstraint: NSLayoutConstraint!
    var screenDetails: SpotLightCardsGetResponse.MoreInfo? = nil
    var outageCardGAkey : String = "" //CMAIOS-2559

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let outageDetails = screenDetails else {return}
        configureUI(outageDetails: outageDetails)
        hideUnhideWarningImage(outageDetails: outageDetails)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //CMAIOS-2559 track Event For OutageMoreInfoVC
        self.getAndTrackEventForOutageMoreInfo(outageGAKey: outageCardGAkey)
    }
    
    func configureUI(outageDetails: SpotLightCardsGetResponse.MoreInfo) {
        
        //Set Title, Subtitle label
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
        
        if let title = outageDetails.title, !title.isEmpty {
            titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
        
        if let subTitle = outageDetails.body, !subTitle.isEmpty {
            subTitleLabel.attributedText = NSMutableAttributedString(string: subTitle.replacingOccurrences(of: "\\n\\n", with: "\n\n"), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }

        //Set Footer label UI
        if let footerText = outageDetails.footer, !footerText.isEmpty {
            footerLabel.isHidden = false
            footerLabel.text = outageDetails.footer
        } else {
            footerLabel.isHidden = true
        }
        
        //Set Primary Button UI
        primaryButton.layer.borderWidth = 2
        primaryButton.titleLabel?.text = outageDetails.buttons?[0].label
        setPrimaryButttonAndMainViewBackgroundColor(outageDetails: outageDetails)
    }

    func setPrimaryButttonAndMainViewBackgroundColor(outageDetails: SpotLightCardsGetResponse.MoreInfo){
        guard let buttons = outageDetails.buttons, !buttons.isEmpty, let template = buttons[0].template, !template.isEmpty else {return}
        guard let outageTemplate = outageDetails.template, !outageTemplate.isEmpty else { return }

        switch (template.lowercased(), outageTemplate.lowercased()){
        case ("white","midnightblue"):
            primaryButton.backgroundColor = .white
            primaryButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            view.backgroundColor = midnightBlueRGB
            titleLabel.textColor = UIColor.white
            subTitleLabel.textColor = UIColor.white

        case ("orange","blackandwhite"):
           // primaryButton.backgroundColor = UIColor(named: "CommonButtonColor")
            primaryButton.backgroundColor = btnBgOrangeColorRGB
            primaryButton.setTitleColor(.white, for: .normal)
            primaryButton.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
            subTitleLabel.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
            view.backgroundColor = .white
        default:
            break
        }
    }
    
    func hideUnhideWarningImage(outageDetails: SpotLightCardsGetResponse.MoreInfo){
        if let image = outageDetails.image, !image.isEmpty, image.lowercased() == "alert_white" {
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "icon_alert")
            titleLabelLeadingToImageViewConstraint.priority = UILayoutPriority(999)
            titleLabelLeadingToSuperViewConstraint.priority = UILayoutPriority(200)
        } else {
            self.imageView.isHidden = true
            self.imageView.image = UIImage(named: "")
            titleLabelLeadingToImageViewConstraint.priority = UILayoutPriority(200)
            titleLabelLeadingToSuperViewConstraint.priority = UILayoutPriority(999)        }
    }
    
   @IBAction func onTapPrimaryAction(sender:UIButton){
       if let navigationControl = self.presentingViewController as? UINavigationController, let _ = navigationControl.viewControllers.filter({$0 is HomeScreenViewController}).first as? HomeScreenViewController  {
           self.dismiss(animated: true)
       } else if let navigationControl = self.presentingViewController as? MyWiFiViewController {//CMAIOS-2669
           self.dismiss(animated: true)
       } else {
           self.navigationController?.popViewController(animated: true)
       }
    }
    
    //CMAIOS-2559 get Outage More info Event name wrt outage card
    func getAndTrackEventForOutageMoreInfo(outageGAKey: String ){
        var outageMoreInfoEvent = ""
        switch outageGAKey {
        case "homepagecard_2p3p_outagedetected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_2P3P_OUTAGEDETECTED.rawValue
        case "homepagecard_2p3p_informfirstetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_2P3P_INFORMFIRSTETR.rawValue
        case "homepagecard_2p3p_takinglongerthanexpected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_2P3P_TAKINGLONGERTHANEXPECTED.rawValue
        case "homepagecard_2p3p_knownewetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_2P3P_KNOWNEWETR.rawValue
        case "homepagecard_2p3p_theoutageiscleared":
           outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_2P3P_OUTAGECLEAREDMOREINFO.rawValue
        case "homepagecard_internet_outagedetected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_INTERNET_OUTAGEDETECTED.rawValue
        case "homepagecard_internet_informfirstetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_INTERNET_INFORMFIRSTETR.rawValue
        case "homepagecard_internet_takinglongerthanexpected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_INTERNET_TAKINGLONGERTHANEXPECTED.rawValue
        case "homepagecard_internet_knownewetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_INTERNET_KNOWNEWETR.rawValue
        case "homepagecard_internet_theoutageiscleared":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_INTERNET_OUTAGECLEAREDMOREINFO.rawValue
        case "homepagecard_tv_outagedetected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_TV_OUTAGEDETECTED.rawValue
        case "homepagecard_tv_informfirstetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_TV_INFORMFIRSTETR.rawValue
        case "homepagecard_tv_takinglongerthanexpected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_TV_TAKINGLONGERTHANEXPECTED.rawValue
        case "homepagecard_tv_knownewetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_TV_KNOWNEWETR.rawValue
        case "homepagecard_tv_theoutageiscleared":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_TV_OUTAGECLEAREDMOREINFO.rawValue
        case "homepagecard_phone_outagedetected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_PHONE_OUTAGEDETECTED.rawValue
        case "homepagecard_phone_informfirstetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_PHONE_INFORMFIRSTETR.rawValue
        case "homepagecard_phone_takinglongerthanexpected":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_PHONE_TAKINGLONGERTHANEXPECTED.rawValue
        case "homepagecard_phone_knownewetr":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_PHONE_KNOWNEWETR.rawValue
        case "homepagecard_phone_theoutageiscleared":
            outageMoreInfoEvent = OutageSpotlightMoreInfoEvent.OUTAGE_PHONE_OUTAGECLEAREDMOREINFO.rawValue
        default:
            break
        }
        if !outageMoreInfoEvent.isEmpty {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : outageMoreInfoEvent, CUSTOM_PARAM_FIXED : Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
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
