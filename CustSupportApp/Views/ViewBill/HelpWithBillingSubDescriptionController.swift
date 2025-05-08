//
//  HelpWithBillingSubDescriptionController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 30/10/23.
//

import UIKit
import ASAPPSDK
import SafariServices

class HelpWithBillingSubDescriptionController: UIViewController {
    
    @IBOutlet weak var tableViewDescription: UITableView!
    @IBOutlet weak var viewClose: UIView!
    var dismissCallBack: ((Bool) -> Void)?
    var chatFlow: Bool = false
    
    var sectionShow:Int = 3
    var selectedIndex:Int = 0
    //var itemsDescription: [(String)] = [("")]
    var helpWithBilling : HelpBillingModel?
//    var items: [(title: String, description: String)] = [
//        ("Why did my monthly bill change this month?", "Several factors can contribute to an increase in your bill:"),
//        ("How can I lower my bill?", "We understand that managing expenses is important, and there are several ways you can explore to potentially lower your bill:"),
//        ("I'm having trouble making a payment online", "Our chat agents are available 24 hours a day to help you make a payment.")]
    let tappableText = "Optimum ACP "
    var qualtricsAction : DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register TableViewCells
        self.tableViewDescription.register(UINib(nibName: "HelpWithBillingSubDescriptionCell", bundle: nil), forCellReuseIdentifier: "HelpWithBillingSubDescriptionCell")
        self.tableViewDescription.register(UINib(nibName: "HelpWithBillingCell", bundle: nil), forCellReuseIdentifier: "HelpWithBillingCell")
        self.tableViewDescription.register(UINib(nibName: "ChatwithusTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatwithusTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTableViewScrollable()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableViewDescription.reloadData()
        if self.chatFlow {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            self.dismissCallBack?(self.chatFlow)
        }
        if self.selectedIndex == 0 {
            self.addQualtrics(screenName: WhatsNewBillingMenu.HELP_WITH_BILLING_BILL_CHANGE.rawValue)
        } else if selectedIndex == 1{
            self.addQualtrics(screenName: WhatsNewBillingMenu.HELP_WITH_BILLING_LOWER_MY_BILL.rawValue)
        } else {
            self.addQualtrics(screenName: WhatsNewBillingMenu.HELP_WITH_BILLING_PAYMENT_TROUBLE.rawValue)
        }
    }
    
    func addQualtrics(screenName:String){
        qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
     
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    @IBAction func onClickCloseButton(_ sender: Any) {
        self.qualtricsAction?.cancel()
//        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkTableViewScrollable(){
        if(tableViewDescription.contentSize.height > tableViewDescription.frame.size.height){
            self.viewClose.addTopShadow()
        }
    }
    
    @objc func chatButtonTapped() {
        self.qualtricsAction?.cancel()
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.billHelp)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return }
        self.chatFlow = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    func formatTextWithCustomFonts(_ text: String) -> NSAttributedString {
        if let range = text.range(of: ":") {
            let nsRange = NSRange(range, in: text)
            let attributedText = NSMutableAttributedString(string: text)
            let boldFont = UIFont(name: "Regular-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
            attributedText.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: nsRange.location + 1))
            // Apply custom regular font
            let regularFont = UIFont(name: "Regular-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
            attributedText.addAttribute(.font, value: regularFont, range: NSRange(location: nsRange.location + 1, length: text.count - nsRange.location - 1))
            
            if let tappableRange = text.range(of: (tappableText)){
                let tappableNsRange = NSRange(tappableRange, in: text)
                attributedText.addAttribute(.foregroundColor, value: energyBlueRGB, range: tappableNsRange)
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(named: "our-fleet-Copy")
                imageAttachment.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
                let imageString = NSAttributedString(attachment: imageAttachment)
                attributedText.append(imageString)
                let fullStop = NSAttributedString(string: " .")
                attributedText.append(fullStop)
            }
            return attributedText
        } else {
            return NSAttributedString(string: text)
        }
    }
    @objc func visitOptimumTap(_ sender: UITapGestureRecognizer) {
        self.qualtricsAction?.cancel()
        if let label = sender.view as? UILabel, let url = URL(string: OPTIMUM_ACP) {
            if sender.didTapAttributedTextInLabel(label: label, targetText: tappableText) {
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true)
            }
        }
    }
    
    func adjustTextForNotch(text: String) -> String {
        let hasNotch = UIDevice.current.hasNotch
        if !hasNotch {
            return text + "\n"
        }
        return text
    }
}

//MARK: UITableView Delegate/DataSource
extension HelpWithBillingSubDescriptionController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < sectionShow - 1 {
            if indexPath.section == 0 || indexPath.section == 2{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "HelpWithBillingSubDescriptionCell") as? HelpWithBillingSubDescriptionCell {
                   // let item = items[selectedIndex]
                    let helpWithBilling = self.helpWithBilling
                    cell.LableTitle.text = indexPath.section == 2 ? "" : helpWithBilling?.text
                    cell.LableTitle.setLineHeight(1.2)
                    if helpWithBilling?.id == "1" {
                        if indexPath.section == 0 {
                            cell.subtitleLabelTopConstarint.constant = 15
                        }
                    } else {
                        cell.subtitleLabelTopConstarint.constant = 20
                    }
                    cell.LableSubTitle.text = indexPath.section == 2 ? helpWithBilling?.screenSubTitle : helpWithBilling?.screenTitle
                    cell.LableSubTitle.setLineHeight(1.2)//CMAIOS-1807
                    if(helpWithBilling?.data?.count == 0){
                        cell.bottomConstraintSubTitle.constant = 30
                    }
                switch selectedIndex {
                    case 0:
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : WhatsNewBillingMenu.HELP_WITH_BILLING_BILL_CHANGE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
                    case 1:
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : WhatsNewBillingMenu.HELP_WITH_BILLING_LOWER_MY_BILL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
                    default :
                    CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : WhatsNewBillingMenu.HELP_WITH_BILLING_PAYMENT_TROUBLE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
                    
                }
                    return cell
                }
            }
            else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "HelpWithBillingCell") as? HelpWithBillingCell {
                    cell.titleTextLabel.delegate = self
                    var attributedString = NSAttributedString()
                    if helpWithBilling?.id == "2" {
                        if helpWithBilling?.data?[indexPath.row].hyperLinkText != "" && helpWithBilling?.data?[indexPath.row].hyperLinkURL != "" {
                            let contentText = adjustTextForNotch(text: (helpWithBilling?.data?[indexPath.row].content)!)
                            let text :NSString = (helpWithBilling?.data?[indexPath.row].startContentWithBold)! + contentText + (helpWithBilling?.data?[indexPath.row].hyperLinkText)! as NSString
                            cell.titleTextLabel.text = text
                            let text1 = (helpWithBilling?.data?[indexPath.row].startContentWithBold)!
                            let text2 = (helpWithBilling?.data?[indexPath.row].content)!
                            let linkText = NSMutableAttributedString(string: text as String, attributes: [.font: UIFont(name: "Regular-Regular", size: 18)!])
                            cell.titleTextLabel.text = linkText
                            let tappableText: NSString = "Optimum ACP" as NSString
                            let labelSubRange: NSRange = text.range(of: tappableText as String)
                            let labelRange : NSRange = text.range(of: text1 as String)
                            let labelBOldRange : NSRange = text.range(of: text2)
                           cell.titleTextLabel.addLink(to: URL(string: "optimumacp"), with: labelSubRange)
                            cell.titleTextLabel.setAttributedTextAndLink(firstFont: UIFont(name: "Regular-Bold", size: 18)!, secondFont: UIFont(name: "Regular-Medium", size: 18)!, thirdFont: UIFont(name: "Regular-Medium", size: 18)!, firstRange: labelBOldRange, secondRange: labelRange, thirdRange: labelSubRange, mainLableRange: labelSubRange)
                            cell.titleTextLabel.isUserInteractionEnabled = true
                            attributedString = formatTextWithCustomFonts((helpWithBilling?.data?[indexPath.row].startContentWithBold)! + (helpWithBilling?.data?[indexPath.row].content)!)
                        } else {
                            attributedString = formatTextWithCustomFonts((helpWithBilling?.data?[indexPath.row].startContentWithBold)! + (helpWithBilling?.data?[indexPath.row].content)!)
                            cell.titleTextLabel.attributedText = attributedString
                        }
                    } else {
                        attributedString = formatTextWithCustomFonts((helpWithBilling?.data?[indexPath.row].startContentWithBold)! + (helpWithBilling?.data?[indexPath.row].content)!)
                        cell.titleTextLabel.attributedText = attributedString
                    }
                    cell.titleTextLabel.textColor = textSoftBlackColor
                    cell.bulletViewWidthConstraint.constant = 6
                    cell.labelLeadingConstarint.constant = 9
                    cell.titleTextLabel.setLineHeight(1.15)//CMAIOS-1807
                   //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(visitOptimumTap(_:)))
//                    cell.lableTitle.addGestureRecognizer(tapGesture)
                    return cell
                }
            }
        } else if indexPath.section == sectionShow - 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatwithusTableViewCell") as? ChatwithusTableViewCell {
                if(self.helpWithBilling?.data?.count == 0){
                    cell.topConstraintViewChatus.constant = -54
                }
                if self.helpWithBilling?.id == "1" {
                    cell.questionLabelTopConstraint.constant = 20
                }
                cell.buttonChat.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
                return cell
            }
        }
        // Return a default cell if something went wrong
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (section < sectionShow - 1) ? ((section == 0) ? 1 : (section == 1) ? itemsDescription.count : (section == 2) ? 1 : 0) : ((section == sectionShow - 1) ? 1 : 0)
        if section == 1 {
            return self.helpWithBilling?.data?.count ?? 0
        }
        return 1
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionShow
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < sectionShow - 1 {
            return UITableView.automaticDimension
        } else if indexPath.section == sectionShow - 1 {
            return 160.0
        }
        return 0.0
    }
}
extension HelpWithBillingSubDescriptionController : TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        self.qualtricsAction?.cancel()
        var linkURL = ""
        switch url.absoluteString {
        case "optimumacp":
            linkURL = OPTIMUM_ACP
        default:
            linkURL = ""
        }
        self.navigateToInAppBrowser(linkURL, title: "")
    }
}
extension HelpWithBillingSubDescriptionController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser(_ URLString : String, title : String) {
        let safariVC = SFSafariViewController(url: URL(string: URLString)!)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion:nil)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.tableViewDescription.reloadData()
    }
}
