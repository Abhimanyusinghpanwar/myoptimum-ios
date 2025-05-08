//
//  PaymentHistoryViewController.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 13/09/23.
//

import UIKit
import Lottie

class PaymentHistoryViewController: UIViewController {
    
    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var tableHistoryList: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var animationvView: LottieAnimationView!
    @IBOutlet weak var label_SubTitle: UILabel!
    @IBOutlet weak var stackViewSchedulePayments: UIStackView!
    
    var paymentHistoryList: [PaymentHistoryDict] = []
    let billHistoryCell = "BillHistoryCell"
    var qualtricsAction : DispatchWorkItem?
    var schedulePaymentCount = 0
    var isFromSpotlight = false
    var viewedFailedMessageList: [IndexPath] = []
    var flow: flowType = .addCard(navType: .home)
    var selectedMOPForDelete: PayMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableHistoryList.accessibilityIdentifier = "bphTable"
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : BillingMenuDetails.BILLING_AND_PAYMENT_HISTORY.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        DispatchQueue.main.async {
            self.showODotAnimation()
            self.initalSetup()
        }
    }
    
    func addQualtrics(){
        qualtricsAction = self.checkQualtrics(screenName: BillingMenuDetails.BILLING_AND_PAYMENT_HISTORY.rawValue, dispatchBlock: &qualtricsAction)
    }
    
    private func initalSetup() {
        self.viewClose.addTopShadow()
        if CurrentDevice.isLargeScreenDevice() {
            self.label_SubTitle.setLineHeight(1.21)
        } else {
            self.label_SubTitle.setLineHeight(1.15)
        }
        self.label_SubTitle.textAlignment = .left
        self.label_SubTitle.numberOfLines = 0
        if QuickPayManager.shared.isConsolidateDataAvailable() {
            self.removeLoaderView()
            self.processModelAndLoadData(value: QuickPayManager.shared.modelConsolidatedDetail)
        } else {
            self.mauiGetConsolidatedDetailsAPI()
        }
    }
    
    private func mauiGetConsolidatedDetailsAPI() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetConsolidatedDetails(interceptor: nil, params: params, completionHandler: { success, value, error in
            if success {
                self.removeLoaderView()
                QuickPayManager.shared.modelConsolidatedDetail = value
                if QuickPayManager.shared.isConsolidateDataAvailable() {
                    self.processModelAndLoadData(value: value)
                } else {
                    self.noBillingHistoryScreen()
                }
            } else {
                self.navigateToBillingErrorScreen()
            }
        })
    }
    
    private func noBillingHistoryScreen() {
        self.qualtricsAction?.cancel()
        guard let viewcontroller = NoBillHistoryViewController.instantiateWithIdentifier(from: .payments) else { return }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
    private func navigateToBillingErrorScreen() { // CMAIOS-1808
        self.qualtricsAction?.cancel()
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .billingApiFailure(type: .paymentHistoryError)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
    func processModelAndLoadData(value: ConsolidatedDetailsResponseModel?) {
//        PAYMENT_STATUS_SCHEDULED"
//        "PAYMENT_STATUS_IN_PROGRESS"
//        "PAYMENT_STATUS_SUCCESS"
//        "PAYMENT_STATUS_FAILURE"
//        "PAYMENT_STATUS_CANCELLED
        
        // Successful Payment List
        let fullucessPaymentList = value?.billDetails?.payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_SUCCESS" })
        let filteredSucessList = fullucessPaymentList?.filter({ $0.paymentDate?.getDateFromDateStringFormat1() ?? Date() <= Date() })
        let successfulPayments = filteredSucessList?.sorted(by: { $0.paymentDate?.getDateFromDateStringFormat1().compare($1.paymentDate?.getDateFromDateStringFormat1() ?? Date()) == .orderedDescending })
        
        // Cancelled Payment List // CMAIOS-2094
        let cancelledList1 = value?.billDetails?.payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_CANCELLED" })
        let filteredCancelledList = cancelledList1?.filter({ $0.paymentUpdateDate?.getDateFromDateStringFormat2() ?? Date() <= Date() })
        let cancelPayments = filteredCancelledList?.sorted(by: { $0.paymentUpdateDate?.getDateFromDateStringFormat2().compare($1.paymentUpdateDate?.getDateFromDateStringFormat2() ?? Date()) == .orderedDescending })
        
        // Scheduled Payment List
        let scheduledPayments = value?.billDetails?.payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_SCHEDULED" })
        let orderedScheduledPayments = scheduledPayments?.sorted(by: { $0.paymentDate?.getDateFromDateStringFormat1().compare($1.paymentDate?.getDateFromDateStringFormat1() ?? Date()) == .orderedDescending })
        
        // Failed Payment List
        // CMAIOS-2034
        let failedPayments = value?.billDetails?.payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_FAILURE" })
//        let filteredFailedPayments = failedPayments?.filter({ $0.paymentDate?.getDateFromDateStringFormat1() ?? Date() < Date().getDatebefore30Days() })
        let filteredFailedPayments = failedPayments?.filter({ $0.paymentDate?.getDateFromDateStringFormat1() ?? Date() <= Date() })
        let orderedFailedPayments = filteredFailedPayments?.sorted(by: {
            $0.paymentDate?.getDateFromDateStringFormat1().compare($1.paymentDate?.getDateFromDateStringFormat1() ?? Date()) == .orderedDescending })

        // Bill List
        let billLists = value?.billDetails?.billSummaryList?.sorted(by: { $0.statementDate?.getDateFromDateStringFormat1().compare($1.statementDate?.getDateFromDateStringFormat1() ?? Date()) == .orderedDescending })
        
        self.schedulePaymentCount = orderedScheduledPayments?.count ?? 0 //CMAIOS-1942
        
        let paymentBillingHistoryList: [PaymentHistoryDict] = {
            var sectionList: [HistoryInfo] = []
            var dictList: [PaymentHistoryDict] = []
            sectionList.append(contentsOf: self.sectionList(type: .otherPayments, successfulPayments, nil))
            sectionList.append(contentsOf: self.sectionList(type: .cancelledPayments, cancelPayments, nil)) // // CMAIOS-2094
            sectionList.append(contentsOf: self.sectionList(type: .failedPayments, orderedFailedPayments, nil)) // // CMAIOS-2034
            
            sectionList.append(contentsOf: self.sectionList(type: .statement, nil, billLists))
            sectionList = sectionList.sorted(by: { $0.date?.compare($1.date ?? Date()) == .orderedDescending })
            dictList = self.getPaymentHistoryList(sectionList: sectionList)
            dictList = dictList.sorted(by: { $0.date?.compare($1.date ?? Date()) == .orderedDescending })
            if orderedScheduledPayments?.count ?? 0 > 0 {
                var schedulePaymentList: [HistoryInfo] = []
//                orderedScheduledPayments = self.schedulePaymentOrdering(orderedScheduledPayments)
                schedulePaymentList = self.sectionList(type: .schedulePayments, orderedScheduledPayments, nil)
                schedulePaymentList = schedulePaymentList.sorted(by: { $0.date?.compare($1.date ?? Date()) == .orderedAscending })
                schedulePaymentList = self.schedulePaymentOrdering(schedulePaymentList)
                dictList.insert(PaymentHistoryDict(date: Date.now, historyList: schedulePaymentList, isSchedulePayment: true), at: 0)
            }
            return dictList
        }()
        DispatchQueue.main.async {
            if !paymentBillingHistoryList.isEmpty {
                self.paymentHistoryList = paymentBillingHistoryList
                self.tableHistoryList.reloadData()
                if let schedulePayments = scheduledPayments, schedulePayments.isEmpty {
                    self.addQualtrics()
                }
            }
        }
    }
        
    private func sectionList(type: PaymentType, _ payments: [ListPayment]?, _ listBills: [BillSummary]?) -> [HistoryInfo] {
        var sectionList: [HistoryInfo] = []
        switch type {
        case .statement:
            if let bills = listBills, !bills.isEmpty {
                for (_, billInfo) in bills.enumerated() {
                    let modifiedDate = CommonUtility.convertToDesiredDateFormat(dateString: billInfo.statementDate, dateFormat: "yyyy-MM-dd")
                    let historyInfo = HistoryInfo(date: modifiedDate, paymethod: nil, paymentStatus: nil, type: .statement, inserts: billInfo.billInserts, amount: billInfo.billAmountDue, billName: billInfo.name, statementDate: billInfo.statementDate, paymentDate: nil, paymentPosted: nil, paymentName: nil, isImmediate: nil, errorCode: nil, failureWithIn30Days: nil)
                    sectionList.append(historyInfo)
                }
            }
        case .otherPayments, .schedulePayments, .failedPayments:
            if let paymentList = payments, !paymentList.isEmpty {
                for (_, paymentInfo) in paymentList.enumerated() {
                    let modifiedDate = CommonUtility.convertToDesiredDateFormat(dateString: paymentInfo.paymentDate, dateFormat: "yyyy-MM-dd")
                    let failureWithIn30Days = (type == .failedPayments) ? self.isFailureWithIn30Days(paymentDate: paymentInfo.paymentDate): nil
                    let historyInfo = HistoryInfo(date: modifiedDate, paymethod: paymentInfo.payMethod, paymentStatus: paymentInfo.paymentStatus, type: type, inserts: nil, amount: paymentInfo.paymentAmount, billName: nil, statementDate: nil, paymentDate: paymentInfo.paymentDate, paymentPosted: paymentInfo.paymentPosted, paymentName: paymentInfo.name, isImmediate: paymentInfo.isImmediate, errorCode: paymentInfo.paymentErrorCode, failureWithIn30Days: failureWithIn30Days)
                    sectionList.append(historyInfo)
                }
            }
        case .cancelledPayments: // CMAIOS-2094
            if let paymentList = payments, !paymentList.isEmpty {
                for (_, paymentInfo) in paymentList.enumerated() {
                    let cancelledDate = paymentInfo.paymentUpdateDate?.components(separatedBy: "T")
                    let neutralDate = (cancelledDate?[0] ?? "") + "T00:00:00Z"
                    let modifiedDate = CommonUtility.convertToDesiredDateFormat(dateString: neutralDate, dateFormat: "yyyy-MM-dd")
                    let historyInfo = HistoryInfo(date: modifiedDate, paymethod: paymentInfo.payMethod, paymentStatus: paymentInfo.paymentStatus, type: type, inserts: nil, amount: paymentInfo.paymentAmount, billName: nil, statementDate: nil, paymentDate: paymentInfo.paymentDate, paymentPosted: paymentInfo.paymentPosted, paymentName: paymentInfo.name, isImmediate: paymentInfo.isImmediate, errorCode: paymentInfo.paymentErrorCode, failureWithIn30Days: nil)
                    sectionList.append(historyInfo)
                }
            }
        }
        return sectionList
    }
    
    private func getPaymentHistoryList(sectionList: [HistoryInfo]) -> [PaymentHistoryDict] {
        var paymentHistoryList: [PaymentHistoryDict] = []
        let getDates = sectionList.map { $0.date }
        for (_, uniqueDate) in getDates.enumerated() {
            if let date1 = uniqueDate {
                if paymentHistoryList.filter({ date1.isSameYearAndMonthFormat1(date2: $0.date ?? Date()) }).isEmpty {
                    let filterList = sectionList.filter({ date1.isSameYearAndMonthFormat1(date2: $0.date ?? Date()) })
                    paymentHistoryList.append(PaymentHistoryDict(date: uniqueDate, historyList: filterList, isSchedulePayment: false))
                }
            }
        }
        return paymentHistoryList
    }
    
    // Add AutoPay schedule payments list should be first on the list
    private func schedulePaymentOrdering(_ payments: [HistoryInfo]?) -> [HistoryInfo] {
        var paymentList: [HistoryInfo] = []
        let autoPayList = payments?.filter({ $0.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" })
        let oneTimePaymentList = payments?.filter({ $0.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT" })
        if let list = autoPayList, Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0 {
            paymentList.append(contentsOf: list)
        }
        if let list = oneTimePaymentList {
            paymentList.append(contentsOf: list)
        }
        return paymentList
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.qualtricsAction?.cancel()
        if !isFromSpotlight {
            //coming from CMAIOS-2578 delete intercept screen or from BillingMenu
            self.checkFlowAndNavigate()
        } else {
            self.dismiss(animated: true)
        }
//        if let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: BillPDFViewController.classForCoder())}).first {
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            self.navigationController?.dismiss(animated: true, completion: nil)
//        }
    }
    
    func checkFlowAndNavigate(){
        switch flow {
        case .managePayments(let editAutoAutoPayFlow): //coming from CMAIOS-2578 delete intercept screen
            let schedulePaymentInfo = QuickPayManager.shared.getSchduledPaymentsForSpecificMOP(selectedMOPInfo: self.selectedMOPForDelete)
            switch schedulePaymentInfo.isPaymentScheduled {
            case true:
                navigateToDeleteInterceptScreen(isRefreshRequired: false, schedulePaymentInfo: schedulePaymentInfo)
            case false:
                navigateToDeleteInterceptScreen(isRefreshRequired: true, schedulePaymentInfo: schedulePaymentInfo)
            }
        default:
            self.navigationController?.popViewController(animated: true)
        }
        
        /*
        if flow == .managePayments {//coming from CMAIOS-2578 delete intercept screen
            let schedulePaymentInfo = QuickPayManager.shared.getSchduledPaymentsForSpecificMOP(selectedMOPInfo: self.selectedMOPForDelete)
            switch schedulePaymentInfo.isPaymentScheduled {
            case true:
                navigateToDeleteInterceptScreen(isRefreshRequired: false, schedulePaymentInfo: schedulePaymentInfo)
            case false:
                navigateToDeleteInterceptScreen(isRefreshRequired: true, schedulePaymentInfo: schedulePaymentInfo)
            }
        }  else {
            self.navigationController?.popViewController(animated: true)
        }
         */
    }

    private func navigateToDeleteInterceptScreen(isRefreshRequired:Bool, schedulePaymentInfo:(Bool, Int)){
        //CMAIOS-2578 fallback logic if there are no schedulePayemts left then show CMAIOS-2577 else show CMAIOS-2578 with updated no. of SPs
      if let deleteMopErrorView = self.navigationController?.viewControllers.filter({$0.isKind(of: DeleteManagePaymentOptionsViewController.classForCoder())}).first as? DeleteManagePaymentOptionsViewController {
        deleteMopErrorView.refreshRequired = isRefreshRequired
        deleteMopErrorView.schedulePaymentInfo = schedulePaymentInfo
        deleteMopErrorView.isShowBottomLabel = !isRefreshRequired
        self.navigationController?.popToViewController(deleteMopErrorView, animated: true)
      } else {
          self.navigationController?.popViewController(animated: true)
      }
}
    
    private func navigateToPdfView(pdfInfo: PdfInfo?) {
        self.qualtricsAction?.cancel()
        guard let viewcontroller = BillPDFViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.pdfType = .inserts(pdfInfo: pdfInfo)
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    // MARK: - O dot Animation View
    private func showODotAnimation() {
        loadingView.isHidden = false
        animationvView .isHidden = false
        animationvView.animation = LottieAnimation.named("O_dot_loader")
        animationvView.backgroundColor = .clear
        animationvView.loopMode = .loop
        animationvView.animationSpeed = 1.0
        animationvView.play()
    }
    
    private func removeLoaderView() {
        if !loadingView.isHidden {
            loadingView.isHidden = true
            animationvView.stop()
            animationvView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.qualtricsAction?.cancel()
        self.removeLoaderView()
    }
    
    func showCancelVC(historyInfo: HistoryInfo) {
        self.qualtricsAction?.cancel()
        let storyboard = UIStoryboard(name: "BillPay", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "AutoPayScheduledcancelVC") as? AutoPayScheduledcancelViewController {
            cancelVC.paymentHistoryObject = historyInfo
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    // CMAIOS-2034
    // Only Update the selected cell on tapping View details/ Hide details
    func reloadTableCell(_ indexPath: IndexPath) {
        guard let cell = self.tableHistoryList.cellForRow(at: indexPath) as? BillingHistoryCellTypeTwo else {
            return
        }
        UIView.performWithoutAnimation {
            self.tableHistoryList.beginUpdates()
            if cell.failed_Message_View.isHidden {
                cell.failed_Message_View.isHidden = false
                cell.vectorImageView.image =  UIImage(named: "VectorUp")
                cell.label_ViewDetails.text = "Hide details"
            } else {
                cell.failed_Message_View.isHidden = true
                cell.vectorImageView.image =  UIImage(named: "VectorDown")
                cell.label_ViewDetails.text = "View details"
            }
            self.tableHistoryList.endUpdates()
        }
    }
    
    //CMAIOS-2450
    private func trackOnClickEvent(eventName: String, isInsertButton: Bool = false) {
      CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
        eventParam: [EVENT_LINK_TEXT : isInsertButton ? parseEventName(eventName: eventName): eventName,
                        EVENT_SCREEN_NAME: BillingMenuDetails.BILLING_AND_PAYMENT_HISTORY.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Billing.rawValue]
        )
    }
    
    //CMAIOS-2584
    private func parseEventName(eventName: String) -> String {
        var parsedEventName = ""
        parsedEventName = "bnp_" + eventName.lowercased().replacingOccurrences(of: " ", with: "_")
        return parsedEventName
    }
}

extension PaymentHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if self.paymentHistoryList.count > 0 {
           return self.paymentHistoryList[section].historyList?.count ?? 0
       }
       return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let isSchedulePayment = self.paymentHistoryList[indexPath.section].isSchedulePayment, isSchedulePayment else {
            /*
            /* Other Payment History List */
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "billHistoryCellIdentifier") as? BillHistoryCell else {
                return UITableViewCell()
            }
            guard let historyInfo = self.paymentHistoryList[indexPath.section].historyList?[indexPath.row] else {
                return UITableViewCell()
            }
            cell.setupHistoryCell(historyInfo: historyInfo, indexpath: indexPath, schedulePaymentCount: self.schedulePaymentCount)
            cell.delegateInsertButtonTap = self
            return cell
            /* Other Payment History List */
            */
            guard let historyInfo = self.paymentHistoryList[indexPath.section].historyList?[indexPath.row] else {
                return UITableViewCell()
            }
            // CMAIOS-2034
            switch historyInfo.paymentStatus {
            case "PAYMENT_STATUS_FAILURE":
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "billHistoryCellTypeTwo") as? BillingHistoryCellTypeTwo else {
                    return UITableViewCell()
                }
                cell.setupHistoryCell(historyInfo: historyInfo, indexpath: indexPath, schedulePaymentCount: self.schedulePaymentCount, showDetails: self.shouldShowFailedMessage(indexpath: indexPath))
                cell.delegateViewDetailsButtonTap = self
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "billHistoryCellIdentifier") as? BillHistoryCell else {
                    return UITableViewCell()
                }
                cell.setupHistoryCell(historyInfo: historyInfo, indexpath: indexPath, schedulePaymentCount: self.schedulePaymentCount)
                cell.delegateInsertButtonTap = self
                return cell
            }
        }
        /* Only Schedule Payment History List */
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SchedulePaymentCellTableViewCell") as? SchedulePaymentCellTableViewCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.labelScheduleTitle.isHidden = false
            cell.baseView.clipsToBounds = false
            cell.baseView.layer.cornerRadius = 10
            cell.baseView.layer.borderColor = buttonBorderGrayColor.cgColor
            cell.baseView.layer.borderWidth = 1.0
            if self.paymentHistoryList[indexPath.section].historyList?.count == 1 {
                cell.addBorders(cornerRadiusFor: .allSides)
            } else {
                cell.addBorders(cornerRadiusFor: .onlyTop)
            }
        } else if indexPath.row > 0 {
            cell.labelScheduleTitle.isHidden = true
            if (indexPath.row + 1) == self.paymentHistoryList[indexPath.section].historyList?.count {
                cell.baseView.clipsToBounds = false
                cell.baseView.layer.cornerRadius = 10
                cell.baseView.layer.borderColor = buttonBorderGrayColor.cgColor
                cell.baseView.layer.borderWidth = 1.0
                cell.addBorders(cornerRadiusFor: .onlyBottom)
            } else {
                cell.baseView.clipsToBounds = false
                cell.baseView.layer.cornerRadius = 10
                cell.baseView.layer.borderColor = buttonBorderGrayColor.cgColor
                cell.baseView.layer.borderWidth = 1.0
                cell.baseView.layer.cornerRadius = 0
            }
        }
        if let historyInfo = self.paymentHistoryList[indexPath.section].historyList?[indexPath.row] {
            cell.setupSchedulePaymentCell(historyInfo: historyInfo, indexpath: indexPath)
            cell.delegateCancelButtonTap = self
        }
        return cell
        /* Only Schedule Payment History List */
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.paymentHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let isSchedulePayment = self.paymentHistoryList[section].isSchedulePayment, isSchedulePayment else {
            guard let date =  self.paymentHistoryList[section].date else {
                return UIView()
            }
            var yPosition = 32
            if isSchedulePaymentsAvailable() {
                if section == 1 {
                    yPosition = 0
                }
            }
            let headerView = UIView()
            let headerLabel = UILabel()
            headerLabel.frame = CGRect(x: 20, y: yPosition, width: Int(UIScreen.main.bounds.width) - 20, height: 29)
            headerLabel.text = QuickPayManager.shared.getHistoryMonth(date: date, format: "MMMM yyyy")
            headerLabel.textAlignment = .left
            headerLabel.font = UIFont(name: "Regular-Medium", size: 24)
            headerView.addSubview(headerLabel)
            if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeight = 67.0
        if isSchedulePaymentsAvailable() {
            if section == 0 || section == 1 {
                headerHeight = 32.0
            }
        }
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
    }
    
    private func isSchedulePaymentsAvailable() -> Bool {
        guard let isSchedulePayment = self.paymentHistoryList[0].isSchedulePayment, isSchedulePayment == true else {
            return false
        }
        return true
    }
    
    // CMAIOS-2034
    // Verifies whether we need to show the failure message view or not
    // If viewedFailedMessageList has selcted indexpath it tends to in visible state
    private func shouldShowFailedMessage(indexpath: IndexPath) -> Bool {
        if viewedFailedMessageList.contains(indexpath) {
            return true
        }
        return false
    }
    
    private func isFailureWithIn30Days(paymentDate: String?) -> Bool {
        var failureWithIn30Days = true
        guard let date = paymentDate?.getDateFromDateStringFormat1() else {
            failureWithIn30Days = false
            return failureWithIn30Days
        }
        return date > Date().getDatebefore30Days()
    }
}

extension PaymentHistoryViewController: InsertButtonDelegate {
    func captureInsertButtonTap(sender: InsertButton) {
        guard let indexPath = sender.indexpath,
              let historyInfo = self.paymentHistoryList[indexPath.section].historyList?[indexPath.row] else {
            return
        }
        let pdfName = sender.tag == 0 ? historyInfo.billName: historyInfo.inserts?[sender.tag - 1].name
        let isBillInsert = sender.tag == 0 ? false: true
        var title: String?
        if sender.tag > 0 {
            title = historyInfo.inserts?[sender.tag - 1].alertText
        }
        //CMAIOS-2450
//        let eventName = title == "Rates & Packages" ? BillPayEvents.BNP_RATES_PACKAGES.rawValue : BillPayEvents.BNP_VIEW_BILL.rawValue
//        self.trackOnClickEvent(eventName: eventName)
        
        //CMAIOS-2584
        self.trackOnClickEvent(eventName: title ?? "", isInsertButton: true)
        let pdInfo = PdfInfo(isBillInsert: isBillInsert,
                             statementDate: historyInfo.statementDate,
                             pdfName: pdfName,
                             title: title)
        self.navigateToPdfView(pdfInfo: pdInfo)
    }
}

extension PaymentHistoryViewController: CancelScheduleButtonDelegate {
    func captureCancelButtonTap(row: Int) {
        //CMAIOS-2450
        self.trackOnClickEvent(eventName: BillPayEvents.BNP_CANCEL_PAYMENT.rawValue)
        guard let historyInfo = self.paymentHistoryList[0].historyList?[row] else {
            return
        }
        self.showCancelVC(historyInfo: historyInfo)
    }
}

extension PaymentHistoryViewController: ViewDetialsButtonDelegate {
    // CMAIOS-2034
    // Delegate to capture View detail/ Hide details button tap
    // We'll track the selected indepxpath to track the status while reloading the tableview
    func captureViewButtonTap(indexPath: IndexPath) {
        if viewedFailedMessageList.contains(indexPath) {
            viewedFailedMessageList.removeAll { $0 == indexPath }
        } else {
            viewedFailedMessageList.append(indexPath)
        }
        self.reloadTableCell(indexPath)
    }
    
    // CMAIOS-2348
    // Delegate to capture more button tap
    func captureMoreInfoTap(indexPath: IndexPath) {
        Logger.info("captureMoreInfoTap")
        guard let historyInfo = self.paymentHistoryList[indexPath.section].historyList?[indexPath.row], let errorCode = historyInfo.errorCode else {
            return
        }
        
        if historyInfo.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" {
            //CMAIOS-2378, CMAIOS-2380
            SPFSharedManager.shared.mapErrorCodeToAutoPayErrorType(errorCode: errorCode,historyInfo: historyInfo, presentingVC: self, isFromSpotlight: false)
        } else {
            //CMAIOS-2413
            SPFSharedManager.shared.mapErrorCodeToSPTErrorType(errorCode: errorCode,historyInfo: historyInfo, presentingVC: self, isFromSpotlight: false)
        }
    }
}

struct HistoryInfo {
    let date: Date?
    let paymethod: PayMethod?
    let paymentStatus: String?
    let type: PaymentType?
    let inserts: [BillInsert]?
    let amount: AmountInfo?
    let billName: String?
    let statementDate: String?
    let paymentDate: String?
    let paymentPosted: String?
    let paymentName: String?
    let isImmediate: Bool? // CMAIOS:-2304 // Indicates OTP or Schedule Payment
    let errorCode: String? // CMAIOS:-2304 // Failed Payment error code
    let failureWithIn30Days: Bool? // CMAIOS:-2348 // Identify failures happened less or more than 30 days
}

struct PaymentHistoryDict {
    let date: Date?
    let historyList: [HistoryInfo]?
    let isSchedulePayment: Bool?
}

enum PaymentType: Equatable {
    case statement
    case otherPayments
    case schedulePayments
    case cancelledPayments
    case failedPayments
}
