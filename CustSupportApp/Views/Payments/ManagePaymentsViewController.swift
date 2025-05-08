//
//  ManagePaymentsViewController.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 23/08/24.
//

import UIKit

class ManagePaymentsViewController: UIViewController {
    
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var tableManagePayments: UITableView!
    @IBOutlet weak var viewAddPayment: UIView!
    
    var payMethods: [PayMethod] = []
    var selectedIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.fetchPaymethods()
        //CMAIOS-2104
        getEventNameAndTrackAction()
//        self.addShadow()
    }
    
    func trackGAEventAction(eventName:String){
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : eventName, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Billing.rawValue])
    }
    
    func getEventNameAndTrackAction() {
        var eventName = ""
        switch self.payMethods.count > 0 {
        case true:
            eventName = ManagePaymentMethod.BILLING_MANAGE_PAYMENT_METHOD.rawValue
        default:
            eventName = ManagePaymentMethod.BILLING_NO_MOP_SAVED.rawValue
        }
        trackGAEventAction(eventName:eventName)
    }
    
    private func registerTableViewCell() {
        self.tableManagePayments.register(UINib.init(nibName: "ManagePaymentsCell", bundle: nil), forCellReuseIdentifier: "ManagePaymentsCell")
        self.tableManagePayments.rowHeight = UITableView.automaticDimension;
        self.tableManagePayments.separatorStyle = .none
        self.tableManagePayments.dataSource = self
        self.tableManagePayments.delegate = self
        self.tableManagePayments.sectionFooterHeight = 0.0
    }
    
    private func addShadow() {
        // Add Shadow to close button view
        let shadowPath = UIBezierPath(rect: CGRect(x: self.viewAddPayment.bounds.origin.x, y: self.viewAddPayment.bounds.origin.y, width: currentScreenWidth, height: self.viewAddPayment.bounds.height))
        self.viewAddPayment.layer.masksToBounds = false
        self.viewAddPayment.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        self.viewAddPayment.layer.shadowOffset = CGSizeMake(0.0, -5.0)
        self.viewAddPayment.layer.shadowOpacity = 0.5
        self.viewAddPayment.layer.shadowPath = shadowPath.cgPath
    }
    
    // CMAIOS-2305
    @IBAction func actionAddPayment(_ sender: Any) {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = true
//        viewcontroller.flow = QuickPayManager.shared.isAutoPayEnabled() ? .editAutoPay: .managePayments
        viewcontroller.flow = .managePayments(editAutoAutoPayFlow: false) //CMAIOS-2858
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @IBAction func actionClose(_ sender: Any) {
        if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(billingPayController, animated: true)
            }
            return
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func fetchPaymethods() {
        self.payMethods = QuickPayManager.shared.getAllPayMethodMop()
        self.tableManagePayments.reloadData()
    }
    
}

extension ManagePaymentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return self.calculateHeaderAndFooterHeight()/2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.calculateHeaderAndFooterHeight()/2
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.tableManagePayments.frame.width,
                                              height: self.calculateHeaderAndFooterHeight()/2))
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.tableManagePayments.frame.width,
                                              height: self.calculateHeaderAndFooterHeight()/2))
        headerView.backgroundColor = .clear
        return headerView
    }
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payMethods.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        if let paymentName = QuickPayManager.shared.getDefaultAutoPaymentMethod(), paymentName.name == payMethods[indexPath.row].name {
            return 114.0 + 20.0
        }
        return 91.0 + 20.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManagePaymentsCell") as! ManagePaymentsCell
        cell.setUpCellData(payMethod: payMethods[indexPath.row])
        cell.tag = indexPath.row
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action:#selector(self.editButton(sender:)), for: .touchUpInside)
        cell.handler = { self.deleteButtonTap(sender: cell) }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
    }
    
    private func calculateHeaderAndFooterHeight() -> CGFloat {
        var headerHeight = 0.0
        var totalContentHeight = 0.0
        let tablePaymentListHeight = self.tableManagePayments.frame.height
        if payMethods.count > 0 {
            totalContentHeight = self.getRowHeight()
            totalContentHeight += ManageMOPConstants.titleHeight
            switch (totalContentHeight >= tablePaymentListHeight, totalContentHeight < tablePaymentListHeight) {
            case (true, _): // Long List UI (Close button view shadow, Scrolling Add card section, Scrolling Title)
                headerHeight = 0.0
            case (_, true): // No Long List, Should be validated tablePaymentListHeight - totalContentHeight
                let computedHeight = tablePaymentListHeight - totalContentHeight
                if computedHeight > 0 { // assign computedHeight to top section space
                    headerHeight = computedHeight
                }
            default: break
            }
        } else {
            return headerHeight
        }
        checkAndDisableScroll(headerHeight: headerHeight)
        return headerHeight
    }
     
     /// Set scroll compatibility for tableview depending on List
     /// - Parameter headerHeight: Used to add shadow for close button view for long list
    private func checkAndDisableScroll(headerHeight: CGFloat) {
//        self.tableManagePayments.alwaysBounceVertical = false
        if headerHeight <= 0.0 { // Add top shadow for Long List
            self.tableManagePayments.alwaysBounceVertical = true
            self.viewAddPayment.addTopShadow(topLight: true)
        } else { // Remove top shadow for Non Long List
            self.tableManagePayments.alwaysBounceVertical = false
            self.viewAddPayment.layer.shadowOpacity = 0
        }
    }
    
    @objc func editButton(sender: UIButton) {
        let mopDetails = payMethods[sender.tag]
        self.trackGAEventForEdit(selectedMOP: mopDetails)
        //CMAIOS-2627, 2620
        if mopDetails.bankEftPayMethod != nil {
            navigateToEditScreenVC(mopDetails: mopDetails)
        } else {
            navigateToEditScreenVCForCC(mopDetails: mopDetails)
        }
    }
    
    func navigateToEditScreenVC(mopDetails: PayMethod){
        guard let editVC = EditACHDetailVC.instantiateWithIdentifier(from: .billing) else { return }
        editVC.achMOPDetails = mopDetails
        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func navigateToEditScreenVCForCC(mopDetails: PayMethod){
        guard let viewcontroller = EditCCViewController.instantiateWithIdentifier(from: .editPayments) else { return }
        viewcontroller.payMethod = mopDetails
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    //CMAIOS-2014
    func trackGAEventForEdit(selectedMOP:PayMethod){
        var eventName = ""
        if selectedMOP.creditCardPayMethod != nil {
            eventName = ManagePaymentMethod.BILLING_EDIT_CARD.rawValue
        } else {
            eventName = ManagePaymentMethod.BILLING_EDIT_BANK.rawValue
        }
        self.trackGAEventAction(eventName: eventName)
    }
    
    func deleteButtonTap(sender: ManagePaymentsCell) {
        let payMethodInfo = payMethods[sender.tag]
        var eventName = ""
        
        //        //CMAIOS-2526
        //        if !sender.autoPayStackView.isHidden, !QuickPayManager.shared.isAutoPayScheduled() {
        //            showErrorMessageVC()
        //        }
        //        //
        let schedulePaymentInfo = QuickPayManager.shared.getSchduledPaymentsForSpecificMOP(selectedMOPInfo: payMethodInfo)
        var title = ""
        var subTitle = ""
        var primayButtonTitle = ""
        var secondaryButtonTitle = ""
        let mopName = QuickPayManager.shared.getAutoPayMethodMop()
        let mopDate = (QuickPayManager.shared.getAutoPayScheduleDate() == "") ? QuickPayManager.shared.getDueDate() : QuickPayManager.shared.getAutoPayScheduleDate()
        let deleteViewController = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "DeleteManagePayments") as DeleteManagePaymentOptionsViewController
        let payMethodNickname = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethodInfo).1
        let isAutoPayScheduled = (!sender.autoPayStackView.isHidden && QuickPayManager.shared.isAutoPayScheduled()) ? true : false
        switch (sender.autoPayStackView.isHidden, isAutoPayScheduled, schedulePaymentInfo.isPaymentScheduled) {
        case (true, _, true): // AUTO PAY NOT ENROLLED //OTP scheduled //CMAIOS-2578
            title = "Are you sure you want to delete \(payMethodNickname)?"
            primayButtonTitle = "Yes, delete"
            secondaryButtonTitle = "No"
            deleteViewController.isShowBottomLabel = true
            deleteViewController.payMethod = payMethodInfo
            deleteViewController.schedulePaymentInfo = schedulePaymentInfo
            eventName = "billing_mop_deletion_scheduled_payment"
            break
        case (false, true, _): // AUTO PAY ENROLLED AND SCHEDULED
            title = "You can't delete \(mopName.1) because you are using it for Auto Pay for \(mopDate)"
            subTitle = "If you still want to delete it, try again after \(mopDate)"
            primayButtonTitle = "Okay"
            secondaryButtonTitle = ""
            break
        case (false, false, _): // CMAIOS:-2582 //CMAIOS-2575
            title = "\(mopName.1) is being used for Auto Pay"
            if QuickPayManager.shared.isLegacyAccount() {
                subTitle = "If you want to delete it, manage your payment methods on the Optimum website."
                primayButtonTitle = "Go to Optimum website"
            } else {
                subTitle = "Before deleting it, choose a different payment method for Auto Pay."
                primayButtonTitle = "Edit Auto Pay"
            }
            secondaryButtonTitle = ""
            deleteViewController.isShowEditAutoPay =  true
            deleteViewController.payMethod = payMethodInfo
            deleteViewController.schedulePaymentInfo = schedulePaymentInfo
            eventName = "billing_default_card_deletion_warning"
        case (true, false, false):
            title = "Are you sure you want to delete \(payMethodNickname) from your account?"
            subTitle = ""
            primayButtonTitle = "Yes, delete"
            secondaryButtonTitle = "No"
            deleteViewController.payMethod = payMethodInfo
            eventName = "billing_delete_mop"
        default:
            break
        }
        if !eventName.isEmpty {
            self.trackGAEventAction(eventName: eventName)
        }
        deleteViewController.errorMessageString = (title, subTitle)
        deleteViewController.buttonTitleString = (primayButtonTitle, secondaryButtonTitle)
        deleteViewController.flow = .managePayments(editAutoAutoPayFlow: deleteViewController.isShowEditAutoPay)
        self.navigationController?.pushViewController(deleteViewController, animated: true)
    }
    
    //CMAIOS-2526
    func showErrorMessageVC() {
        let mopName = QuickPayManager.shared.getAutoPayMethodMop()
        let mopDate = (QuickPayManager.shared.getAutoPayScheduleDate() == "") ? QuickPayManager.shared.getDueDate() : QuickPayManager.shared.getAutoPayScheduleDate()
        let title = "You can't delete \(mopName.1) because you are using it for Auto Pay for \(mopDate)"
        let subTitle = "If you still want to delete it, try again after \(mopDate)"
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.errorMessageString = (title,subTitle)
        vc.primayButtonTitle = "Okay"
        vc.isFromManagePayment = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //
    
    private func showAddCard(manageCards: Bool = false) {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = true
        viewcontroller.flow = .managePayments(editAutoAutoPayFlow: false)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func getRowHeight() -> CGFloat {
        var headerHeight = 0.0
        if QuickPayManager.shared.isAutoPayEnabled() {
            headerHeight = Double(payMethods.count - 1) * ManageMOPConstants.cellHeightWithOutAP
            headerHeight += ManageMOPConstants.cellHeightWithAP
        } else {
            headerHeight = Double(payMethods.count) * ManageMOPConstants.cellHeightWithOutAP
        }
        headerHeight += Double(payMethods.count) * ManageMOPConstants.cellBottomSpace
        return headerHeight
    }
}


struct ManageMOPConstants {
    static let addCardButtonHeight = 144.0
    static let cellHeightWithAP = 119.0
    static let cellHeightWithOutAP = 79.0
    static let titleHeight = 68.0
    static let titleBuffer = 10.0
    static let cellBottomSpace = 20.0

}
