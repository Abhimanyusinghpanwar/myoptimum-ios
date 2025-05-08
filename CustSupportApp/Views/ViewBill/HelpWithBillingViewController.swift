//
//  HelpWithBillingViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 26/09/23.
//

import UIKit
import SafariServices
import ASAPPSDK
class HelpWithBillingViewController: UIViewController {
    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var tableViewQuestionAns: UITableView!
    var helpWithBillingModel : [HelpBillingModel]?
    var dimissCallBack: ((Bool) -> Void)?
    var chatFlow: Bool = false
    var qualtricsAction : DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.readLocalJSONFile(forName: "get_help_with_billing_content")
        // register TableViewCells
        self.tableViewQuestionAns.register(UINib(nibName: "HelpWithBillingCell", bundle: nil), forCellReuseIdentifier: "HelpWithBillingCell")
        self.tableViewQuestionAns.register(UINib(nibName: "ChatwithusTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatwithusTableViewCell")
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : WhatsNewBillingMenu.HELP_WITH_BILLING.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
     }
    
    func readLocalJSONFile(forName name: String){
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                do {
                    let data = try Data(contentsOf: fileUrl)
                    self.helpWithBillingModel = try JSONDecoder().decode([HelpBillingModel].self, from: data)
                   } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.chatFlow {
            if APIRequests.shared.isReloadNotRequiredForMaui {
                APIRequests.shared.isReloadNotRequiredForMaui = false
            }
            self.dimissCallBack?(self.chatFlow)
        }
        qualtricsAction = self.checkQualtrics(screenName: WhatsNewBillingMenu.HELP_WITH_BILLING.rawValue, dispatchBlock: &qualtricsAction)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTableViewScrollable()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    
    func checkTableViewScrollable(){
        if(tableViewQuestionAns.contentSize.height > tableViewQuestionAns.frame.size.height){
            self.viewClose.addTopShadow()
        }
    }
    
    @IBAction func onClickCloseButton(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chatButtonTapped() {
        self.qualtricsAction?.cancel()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Billingmenu_HelpwithBilling.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        // Handle the click action on the "ChatwithusTableViewCell"
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.billHelp)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return }
        self.chatFlow = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
}

//MARK: UITableView Delegate/DataSource
extension HelpWithBillingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.helpWithBillingModel?.count {
            // This is the last cell, so dequeue and configure the ChatwithusTableViewCell
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatwithusTableViewCell") as? ChatwithusTableViewCell {
                cell.selectionStyle = .none
                cell.questionLabelTopConstraint.constant = 25
                cell.buttonChat.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
                return cell
            }
        } else {
            // This is a regular cell, dequeue and configure HelpWithBillingCell
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HelpWithBillingCell") as? HelpWithBillingCell {
                cell.selectionStyle = .none
                let item = self.helpWithBillingModel?[indexPath.row]
                cell.titleTextLabel.setLineHeight(1.14)
                cell.labelLeadingConstarint.constant = 0
                cell.bulletViewWidthConstraint.constant = 0
                if item?.id == "3"{
                    cell.titleTextLabel.text = (item?.text ?? "") + "."
                } else {
                    cell.titleTextLabel.text = item?.text
                }
                return cell
            }
        }
        // Return a default cell if something went wrong
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < helpWithBillingModel?.count ?? 0 {
            self.qualtricsAction?.cancel()
            guard let viewcontroller = HelpWithBillingSubDescriptionController.instantiateWithIdentifier(from: .payments) else { return }
            viewcontroller.dismissCallBack = { chatFlow in
                if chatFlow {
                    self.dimissCallBack?(chatFlow)
                }
            }
            viewcontroller.selectedIndex = indexPath.row
            viewcontroller.sectionShow = (indexPath.row == 0) ? 4 : 3
           // viewcontroller.itemsDescription = (indexPath.row == 0) ? itemsWhyDidBill : (indexPath.row == 1) ? itemsHowCanBill : []
            viewcontroller.helpWithBilling = self.helpWithBillingModel?[indexPath.row]
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.helpWithBillingModel?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == self.helpWithBillingModel?.count ? 165.0 : UITableView.automaticDimension
    }
}
