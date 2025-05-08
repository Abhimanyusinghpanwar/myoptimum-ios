//
//  MakePaymentViewController.swift
//  CustSupportApp
//
//  Created by Sudheer Kumar Mundru on 11/12/23.
//

import UIKit
import Lottie

class MakePaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var paymentDetailsTableView: UITableView!
    @IBOutlet weak var payNowAnimation: LottieAnimationView!
    @IBOutlet weak var buttonPayNow: RoundedButton!
    @IBOutlet weak var payViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var crossViewTopConstraint: NSLayoutConstraint!
    
    var cardTypeName = ""
    var cardImg = ""
    var signInIsProgress = false
    var paymentJson: [String: AnyObject]?
    var state: State = .normal
    var amountEdited = " "
    var isAmountEdited = false
    var enterPayDetStr = " "
    var firstTimeCardInfo: FirstTimeCardInfo?
    var flowType: flowType = .noPayments
    var noDueFlow = false
    var noDueAmountValue = ""
    var firstTimeCardFlow = false
    var tempPaymethod: PayMethod?
    var currentAmount  = ""
    var pastDueAmount = ""
    var isDeauthCurrently = false
    var allSchedulePayments  = ""
    var messageDeAuthState  = ""
    var refPaymentDate: String?
    var cellAmountHeightVal = 153.0
    var cellDateHeightVal = 153.0
    var cellCardHeightVal = 70.0
    var payNowRetry: Bool = false
    var dimissCallBack: ((Bool) -> Void)?
    var chatFlow: Bool = false
    var autoRetry: Bool = false
    var isAutoPaymentErrorFlow: Bool = false
    
    /**CMAIOS-2144 To fix the crash happening in below scenario for iOS 15.5 only
         Preconditions: Default MOP is expired, billState = no Due
          User selects another MOP from ChoosePayment-> EnterPaymentScreen -> presses Done-> App crashes
     **/
    var updatedPayMethod : PayMethod?
    var updatedAmount : String = ""
    var paymentDate: String? {
        didSet {
            self.paymentDetailsTableView.reloadData()
            self.updatePayNowButtonTitle()
        }
    }
    
    var paymentDateAfterEdit: String? {
        didSet {
            DispatchQueue.main.async {
                self.paymentDetailsTableView.reloadData()
                self.updatePayNowButtonTitle()
            }
        }
    }
    
    var paymentAmount: String = QuickPayManager.shared.getCurrentAmount() {
        didSet {
            self.paymentDetailsTableView.reloadData()
        }
    }
    
    var payMethod: PayMethod? {
        didSet {
            DispatchQueue.main.async {
                self.updateCardDetails()
                self.paymentDetailsTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUIElements()
    }
    
    func loadUIElements() {
        self.paymentDetailsTableView.register(UINib(nibName: "MakePaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "MakePaymentTableViewCell")
        self.paymentDetailsTableView.translatesAutoresizingMaskIntoConstraints = false
//        self.updateCardDetails()
        self.initialDataSetup()
        // CMAIOS-2154: For larger devices
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            self.payViewBottomConstraint.constant = 20
            self.crossViewTopConstraint.constant = 0
        }else {
            self.payViewBottomConstraint.constant = 10
            self.crossViewTopConstraint.constant = 10
        }
    }
    
    private func initialDataSetup() {
        //Show always today as per AC of CMAIOS-1771
        let currentDateString = Date().getDateStringForDueDate().components(separatedBy: "+")
        let formattedTodayDateString = currentDateString[0] + "Z"
        self.paymentDate = formattedTodayDateString
        self.paymentAmount = QuickPayManager.shared.getCurrentAmount() == "" ? "0": QuickPayManager.shared.getCurrentAmount()
        self.setPaymentType()
        self.updateCardDetails()
        self.paymentDetailsTableView.reloadData()
        self.pastDueAmount = QuickPayManager.shared.getPastDueAmount()
        self.isDeauthCurrently = QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" ? true : false
    }
    
    func setDeAuthStateMessage() -> Bool {
        let deAuthState = QuickPayManager.shared.getDeAuthState()
        var isDeAuthState = false
        
        if deAuthState == "DE_AUTH_STATE_DEAUTH" || deAuthState == "DE_AUTH_STATE_PREDEAUTH" {
            isDeAuthState = true
            messageDeAuthState = "Pay minimum $\(QuickPayManager.shared.getPastDueAmount()) to " + (deAuthState == "DE_AUTH_STATE_DEAUTH" ? "restore your services" : "avoid service interruption")
        }
        return isDeAuthState
    }
    
    private func setPaymentType() {
        if payMethod == nil {
            payMethod = QuickPayManager.shared.getDefaultPayMethod()
        }
    }
    
    // MARK: - Button Actions
    @IBAction func closeBtnAction(_ sender: Any) {
        QuickPayManager.shared.localSavedPaymethods = nil
        if let myBillView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(myBillView, animated: true)
        } else if let navigationControl = self.presentingViewController as? UINavigationController { // CMAIOS:-1882
            if let billingView = navigationControl.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: false, completion: {
                        navigationControl.popToViewController(billingView, animated: true)
                    })
                }
                return
            } else if navigationControl.viewControllers.contains(where: { $0 is HomeScreenViewController}){ //Added fix for CMA-2317
                self.navigationController?.dismiss(animated: true)
            } else {
                // CMAIOS-2444
                if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                /*
                 //// Used: GoToMyBill from Bill SpotlightCard -> MakePayment
                 self.navigationController?.popViewController(animated: true)
                 */
            }
        } else {
            if let myBillView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first { // Used: MyBill -> Enterpayment -> MakePayment
                self.navigationController?.popToViewController(myBillView, animated: true)
            } else {
                if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                    self.dismiss(animated: true)
                } else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func getCurrentAmountAndDate() {
        let dateString = self.getPaymentDate() != nil ? self.paymentDateAfterEdit ?? "" : Date().getDateStringForDueDate()
        let dateFormat = "MMM. d"
        let dateValue = CommonUtility.convertDateStringFormats(dateString: dateString, dateFormat: dateFormat)
        QuickPayManager.shared.currentMakepaymentAmount = self.getAmountAndBalanceStateFromCell().0 ?? "0.0"
        QuickPayManager.shared.currentMakepaymentDate = dateValue
    }
    
    @IBAction func payNowBtnAction(_ sender: Any) {
        if self.getAmountAndBalanceStateFromCell().0 == "0" {
            return
        }
        
        if enableDeAuth {
            let viewController = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "SchedulePaymentVC") as SchedulePaymentViewController
            viewController.paidAmount = paymentAmount
//            viewController.currentAmount = "10.55"
            viewController.currentAmount = QuickPayManager.shared.getCurrentAmount()
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        
        // CMAIOS-2002
        self.allSchedulePayments =  String(format: "%.2f", Double(QuickPayManager.shared.getScheduledPaymentAmountsTillDueDate()))
        
        switch (getPaymentDueDate() == "Today", self.isLocalPaymethod()) {
        case (true, false):
            self.DoImmediatePayment(isAutoPay: false)
        case (true, true):
            if isAchPaymentActive() {
                self.createAchOneTimePayment()
            } else {
                self.createOneTimePayment()
            }
        case (false, false):
            self.createSchedulePaymentWithExistingPaymethod()
        case (false, true):
            if isAchPaymentActive() {
                self.createScheduledPaymentWithNewAch()
            } else {
                self.createScheduledPaymentWithNewCard()
            }
        }
    }
    
    @objc func editAmount() {
        let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
        enterPayVC.amountStr = self.paymentAmount
        enterPayVC.balanceStateText = self.getAmountAndBalanceStateFromCell().1 ?? ""
        enterPayVC.callback = { (amnt, paymethod, isOneTimeFailureFlow) in
            self.isAmountEdited = true
            self.paymentAmount = amnt
            if isOneTimeFailureFlow{
                self.updatedPayMethod = paymethod
            }
            self.paymentDetailsTableView.reloadData()
        }
        self.noDueFlow = false
        self.navigationController?.pushViewController(enterPayVC, animated: true)
    }
    
    @objc func editBtnActionTapped(btn: UIButton) {
        guard self.signInIsProgress == false else {
            return
        }
        switch btn.tag {
        case 0:
            editAmount()
        case 1:
            showCalendarVC()
        case 2:
            changePaymentMethod()
        default:
            break
        }
    }
    
    func getDueDate() -> String {
        if let nextDue = QuickPayManager.shared.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate, !nextDue.isEmpty{
            return nextDue
        }
        return ""
    }
    
    private func isAchPaymentActive() -> Bool {
        if self.payMethod?.creditCardPayMethod?.expiryDate != nil {
            return false
        }
        return true
    }
    
    // MARK: - Edit DueDate Action
    func showCalendarVC() {
        let calendarVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "PaymentCalendarVC") as PaymentCalendarVC
            let dueDate = self.getDueDate()
            let dueAmnt = QuickPayManager.shared.getCurrentAmount()
           //show due date in calendar only if there is dueAmnt and dueDate
            if !dueDate.isEmpty && dueAmnt != "" {
               let formattedDueDate = dueDate.components(separatedBy: "T")
               calendarVC.currentSelectedDueDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDueDate[0])
            }
        
            if let editedDate = self.paymentDateAfterEdit {
                let formattedDate = editedDate.components(separatedBy: "T")
                calendarVC.dueDateAfterEdit = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDate[0])
            }
        calendarVC.delegate = self
        calendarVC.payMethod = payMethod
        calendarVC.paymentDateAfterEdit = self.paymentDateAfterEdit
        calendarVC.makePaymentViewController = self
        // CMAIOS-2099
        self.navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    @objc func changePaymentMethod() {
        guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        let currentPaymentDate = self.paymentDateAfterEdit == nil ? self.paymentDate : self.paymentDateAfterEdit
        vc.payMethod = payMethod
        vc.isMakePaymentFlow = true
        vc.makePaymentViewController = self
        vc.paymentDate = currentPaymentDate
        vc.schedulePaymentDate = currentPaymentDate
        vc.selectedAmount = Double(self.paymentAmount) ?? 0
        vc.selectionHandler = { [weak self] payMethod in
            self?.firstTimeCardFlow = false
            self?.payMethod = payMethod
            if self?.updatedPayMethod != nil {
                self?.updatedPayMethod = nil
                self?.updatedAmount = ""
            }
            // CMAIOS-2099
            //self?.navigationController?.popViewController(animated: true)
            // CMAIOS:-2708, 2673
            if let makePayment = self?.navigationController?.viewControllers.filter({$0 is MakePaymentViewController}).first as? MakePaymentViewController {
                DispatchQueue.main.async {
                    self?.navigationController?.popToViewController(makePayment, animated: true)
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateCardDetails() {
            let payMethodInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
            if payMethodInfo.2 != "" {
                self.cardImg = payMethodInfo.2
            }
            self.cardTypeName = payMethodInfo.1
//        }
    }
    
    // MARK: - UITableview Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.paymentDetailsTableView.dequeueReusableCell(withIdentifier: "MakePaymentTableViewCell") as! MakePaymentTableViewCell
        cell.selectionStyle = .none
        cell.lblAmount.sizeToFit()
        cell.lblPriceVal.sizeToFit()
        cell.lblAmountDue.sizeToFit()
        
        cell.editBtn.addTarget(self, action:#selector(self.editBtnActionTapped), for: .touchUpInside)
        var screenTag = ""
        switch QuickPayManager.shared.initialScreenFlow {
        case .noDue:
//            screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_NO_PAYMENT_DUE.rawValue
            if(indexPath.section == 0) {
                screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_NO_PAYMENT_DUE.rawValue
                cell.lblAmount.text = "Amount"
                cell.lblPriceVal.text = "$" + String(format: "%.2f", Double(self.paymentAmount) ?? 0)
                cell.lblAmountDue.text = "No payment due at this time"
                cell.lblAmountDue.isHidden = false
                cellAmountHeightVal = 133.0
                cell.editBtn.tag = 0
                
            } else if(indexPath.section == 1) {
                cell.lblAmount.text = "Date"
                cell.lblPriceVal.text = self.getPaymentDueDate()
                /* CMAIOS-1939
                 let isDateafterDue = dateSelectedAfterDueDate()
                 cell.lblAmountDue.text = getDueAccordingToDateSelection(needDueDate: isDateafterDue)
                 */
                cell.lblAmountDue.isHidden = true
                cellDateHeightVal = 105.0
                cell.editBtn.tag = 1
                
            } else if(indexPath.section == 2) {
                cell.lblAmount.text = "Pay with"
                self.setTruncatedPayMethodName(cell: cell)
                cell.lblAmountDue.isHidden = true
                cell.editBtn.tag = 2
            }
        case .normal:
//            screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
            if(indexPath.section == 0) {
                cell.lblAmount.text = "Amount"
                cell.lblPriceVal.text = "$" + String(format: "%.2f", Double(self.paymentAmount) ?? 0)
                cell.lblAmountDue.isHidden = false
                cellAmountHeightVal = 133.0
                switch (QuickPayManager.shared.getScheduledPaymentAmountsTillDueDate() > 0, self.isFullAmountEntered()) {
                case (true, false):
                    cell.lblAmountDue.text = "Amount due after scheduled payment: $\(calculateRemainingBalance())"
                    self.enterPayDetStr = "Amount due after scheduled payment: $\(calculateRemainingBalance())"
                    screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_SCHEDULED_PAYMENT_NOTIFICATION.rawValue
                case (true, true):
                    cell.lblAmountDue.isHidden = true
                    cellAmountHeightVal = 103.0
                    self.enterPayDetStr = " "
                    screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
                case (false, true):
                    cell.lblAmountDue.isHidden = true
                    cellAmountHeightVal = 103.0
                    self.enterPayDetStr = " "
                    screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
                case (false, false):
                    cell.lblAmountDue.text = "Amount due $\(QuickPayManager.shared.getCurrentAmount())"
                    self.enterPayDetStr = "Amount due $\(QuickPayManager.shared.getCurrentAmount())"
                    screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
                }
                
                cell.editBtn.tag = 0
                
            } else if(indexPath.section == 1) {
                cell.lblAmount.text = "Date"
                cell.lblPriceVal.text = self.getPaymentDueDate()
                let isDateafterDue = dateSelectedAfterDueDate()
                cell.lblAmountDue.isHidden = !isDateafterDue
                cellDateHeightVal = 133.0
                cell.lblAmountDue.text = getDueAccordingToDateSelection(needDueDate: isDateafterDue)
                cell.editBtn.tag = 1
                
            } else if(indexPath.section == 2) {
                cell.lblAmount.text = "Pay with"
                self.setTruncatedPayMethodName(cell: cell)
                cell.lblAmountDue.isHidden = true
                cell.editBtn.tag = 2
            }
            
        case .pastDue:
            //CMAIOS-2286
//            screenTag = isDeauthCurrently ? DeAuthServices.Billing_Deauth_Service_Suspended_Make_A_Payment.rawValue :  PaymentScreens.MYBILL_MAKEAPAYMENT_PAST_DUE_30.rawValue
            if(indexPath.section == 0) {
                screenTag = isDeauthCurrently ? DeAuthServices.Billing_Deauth_Service_Suspended_Make_A_Payment.rawValue :  PaymentScreens.MYBILL_MAKEAPAYMENT_PAST_DUE_30.rawValue
                cell.lblAmount.text = "Amount"
                cell.lblPriceVal.text = "$" + String(format: "%.2f", Double(self.paymentAmount) ?? 0)
                cell.lblAmountDue.isHidden = false
                cellAmountHeightVal = 133.0
                switch self.isFullAmountEntered() { // CMAIOS-1975
                case true:
                    if(setDeAuthStateMessage()) {
                        cell.lblAmountDue.text = messageDeAuthState
                        cell.lblAmountDue.isHidden = false
                        cellAmountHeightVal = 133.0
                    }else{
                        cell.lblAmountDue.isHidden = true
                        cellAmountHeightVal = 103.0
                    }
                    self.enterPayDetStr = " "
                case false:
                    let subTxt = "includes " + "$" + QuickPayManager.shared.getPastDueAmount() + " past due"
                    let mainTxt = "Amount due is $\(QuickPayManager.shared.getCurrentAmount()), \n\(subTxt)"
                    if(setDeAuthStateMessage()){
                        cell.lblAmountDue.text = messageDeAuthState
                    }else{
                        cell.lblAmountDue.attributedText = mainTxt.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 16) as Any], and: subTxt, with: [.font: UIFont(name: "Regular-Bold", size: 16) as Any])
                    }
                    self.enterPayDetStr = "Amount due is $\(QuickPayManager.shared.getCurrentAmount()), \n\(subTxt)"
//                    cell.lblAmountDue.attributedText = mainTxt.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 16) as Any], and: subTxt, with: [.font: UIFont(name: "Regular-Bold", size: 16) as Any])
                }
                
                /*
                switch (QuickPayManager.shared.getScheduledPaymentAmount() > 0, self.isFullAmountEntered()) {
                case (true, false):
                    cell.lblAmountDue.text = "Amount due after scheduled payment: $\(QuickPayManager.shared.getCurrentAmount())"
                    self.enterPayDetStr = "Amount due after scheduled payment: $\(QuickPayManager.shared.getCurrentAmount())"
                case (true, true):
                    cell.lblAmountDue.isHidden = true
                    self.enterPayDetStr = " "
                case (false, true):
                    cell.lblAmountDue.isHidden = true
                    self.enterPayDetStr = " "
                case (false, false):
                    let subTxt = "includes " + "$" + QuickPayManager.shared.getPastDueAmount() + " past due"
                    let mainTxt = "Amount due is $\(QuickPayManager.shared.getCurrentAmount()), \n\(subTxt)"
                    cell.lblAmountDue.attributedText = mainTxt.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 16) as Any], and: subTxt, with: [.font: UIFont(name: "Regular-Bold", size: 16) as Any])
                    self.enterPayDetStr = "Amount due is $\(QuickPayManager.shared.getCurrentAmount()), \n\(subTxt)"
                    cell.lblAmountDue.attributedText = mainTxt.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 16) as Any], and: subTxt, with: [.font: UIFont(name: "Regular-Bold", size: 16) as Any])
                }
                 */
                cell.editBtn.isHidden = false
                cellAmountHeightVal = 133.0
                cell.editBtn.tag = 0
                
            } else if(indexPath.section == 1) {
                cell.lblAmount.text = "Date"
                cell.lblPriceVal.text = self.getPaymentDueDate()
                let isDateafterDue = dateSelectedAfterDueDate()
                cell.lblAmountDue.isHidden = !isDateafterDue
                cell.lblAmountDue.text = getDueAccordingToDateSelection(needDueDate: isDateafterDue)
                cell.editBtn.tag = 1
                cellDateHeightVal = 133.0
                if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" {
                    cell.editBtn.isHidden = true
                } else {
                    cell.editBtn.isHidden = false
                }
            } else if(indexPath.section == 2) {
                cell.lblAmount.text = "Pay with"
                self.setTruncatedPayMethodName(cell: cell)
                cell.lblAmountDue.isHidden = true
                cell.editBtn.tag = 2
            }
            
        case .autoPay: //Scheduled Pay Notification
//            screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_SCHEDULED_PAYMENT_NOTIFICATION.rawValue
            if(indexPath.section == 0) {
                cell.lblAmount.text = "Amount"
                cell.lblPriceVal.text = "$" + String(format: "%.2f", Double(self.paymentAmount) ?? 0)
                cell.lblAmountDue.isHidden = false
                self.enterPayDetStr = " "
                cell.editBtn.tag = 0
                cellAmountHeightVal = 133.0
                if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0 {
                    switch (QuickPayManager.shared.getScheduledPaymentAmountsTillDueDate() > 0, self.isFullAmountEntered()) {
                    case (true, false):
                        cell.lblAmountDue.text = "Amount due after scheduled payment: $\(calculateRemainingBalance())"
                        self.enterPayDetStr = "Amount due after scheduled payment: $\(calculateRemainingBalance())"
                        screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_SCHEDULED_PAYMENT_NOTIFICATION.rawValue
                    case (true, true):
                        cell.lblAmountDue.isHidden = true
                        cellAmountHeightVal = 103.0
                        self.enterPayDetStr = " "
                        screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
                    case (false, true):
                        cell.lblAmountDue.isHidden = true
                        cellAmountHeightVal = 103.0
                        self.enterPayDetStr = " "
                        screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
                    case (false, false):
                        cell.lblAmountDue.text = "Amount due $\(QuickPayManager.shared.getCurrentAmount())"
                        screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_PAYMENT_DUE.rawValue
                    }
                } else {
                    screenTag = PaymentScreens.MYBILL_MAKEAPAYMENT_NO_PAYMENT_DUE.rawValue
                    cell.lblAmountDue.isHidden = true
                    cellAmountHeightVal = 103.0
                    self.enterPayDetStr = " "
                }
            } else if(indexPath.section == 1) {
                cell.lblAmount.text = "Date"
                cell.lblPriceVal.text = self.getPaymentDueDate()
                let isDateafterDue = dateSelectedAfterDueDate()
                cell.lblAmountDue.isHidden = !isDateafterDue
                cellDateHeightVal = 133.0
                cell.lblAmountDue.text = getDueAccordingToDateSelection(needDueDate: isDateafterDue)
                cell.editBtn.tag = 1
                
            } else if(indexPath.section == 2) {
                cell.lblAmount.text = "Pay with"
                self.setTruncatedPayMethodName(cell: cell)
                cell.lblAmountDue.isHidden = true
                cell.editBtn.tag = 2
            }
        default: break
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        assignIdsToEditBtn(btn: cell.editBtn) //For unit test cases
        return cell
    }
    func assignIdsToEditBtn(btn: UIButton) {
        switch btn.tag {
        case 0:
            btn.accessibilityIdentifier = "editAmountBtn"
        case 1:
            btn.accessibilityIdentifier = "editDateBtn"
        case 2:
            btn.accessibilityIdentifier = "editMOPBtn"
        default:
            btn.accessibilityIdentifier = "editMOPBtn"
        }
    }
    
   private func setTruncatedPayMethodName(cell : MakePaymentTableViewCell){
       //CMAIOS-2175 #3 Remove extra leading/trailing white spaces from card/bank name
        let updatedCardName = cardTypeName.trimExtraWhiteLeadingTrailingSpaces()
        cell.lblPriceVal.text = updatedCardName
        //CMAIOS-2294
        let actualSize = currentScreenWidth - 131 // ( 47 card image width + 42 edit icon width + 42 leading+ trailing space)
        let labelSizeRequired = cell.lblPriceVal.textWidth() - 47.0 // 47 is card image width
        var payMethodName = updatedCardName
       // Validating char count and label width for implementing truncation rule
        if (payMethodName.count > 12 || labelSizeRequired >  actualSize ) {
            payMethodName = payMethodName.getTruncatedString(first: 5, last: 4)
        }
       //CMAIOS-2175 Add space between imageIcon and card/bank name
        payMethodName = " " + payMethodName
        let imgText = NSTextAttachment()
        imgText.image = UIImage(named: self.cardImg)
       //CMAIOS-2175 bottom align image with label text
        imgText.bounds = CGRect(x: 0, y: 0, width: 47, height: 32)
        let attText = NSMutableAttributedString()
        attText.append(NSMutableAttributedString(attachment: imgText))
        attText.append(NSMutableAttributedString(string: payMethodName))
        cell.lblPriceVal.attributedText = attText
        cell.lblPriceVal.adjustsFontSizeToFitWidth = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section { //CMAIOS-2154(AC -1st point)
        case 0:
            return cellAmountHeightVal
        case 1:
            return cellDateHeightVal
        default:
            return cellCardHeightVal
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //CMAIOS-2333
        self.navigationController?.navigationBar.isHidden = true
        //
        paymentDetailsTableView.translatesAutoresizingMaskIntoConstraints = false
        QuickPayManager.shared.initialScreenType()
        if self.noDueFlow {
            self.paymentAmount = self.noDueAmountValue
        }
        if firstTimeCardFlow {
            self.payMethod = tempPaymethod
        }
        
        if updatedPayMethod != nil {
           payMethod = updatedPayMethod
        }
        if updatedAmount != "" {
           paymentAmount = updatedAmount
        }

        if payNowRetry && autoRetry {
            self.payNowBtnAction("")
        }
    }
    
    private func getAmountAndBalanceStateFromCell() -> (String?, String?) {
        var amount: String?
        var balanceState: String?

        guard let cell = self.paymentDetailsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MakePaymentTableViewCell else {
            return (amount, balanceState)
        }
        amount = cell.lblPriceVal.text?.replacingOccurrences(of: "$", with: "")
        balanceState = !cell.lblAmountDue.isHidden ? cell.lblAmountDue.text: ""
        return (amount, balanceState)
    }
    
    // MARK: - SignIn Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.payNowAnimation.isHidden = true
        self.buttonPayNow.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.payNowAnimation.isHidden = false
        }
        self.payNowAnimation.backgroundColor = .clear
        self.payNowAnimation.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.payNowAnimation.loopMode = .playOnce
        self.payNowAnimation.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.payNowAnimation.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.payNowAnimation.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.payNowAnimation.currentProgress = 3.0
        self.payNowAnimation.stop()
        self.payNowAnimation.isHidden = true
        self.buttonPayNow.alpha = 0.0
        self.buttonPayNow.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.buttonPayNow.alpha = 1.0
        }
    }
    
    func handleErrorImmediatePayment() {
        self.signInFailedAnimation()
        /*
         var isAutoPay = false
         switch state {
         case .pastDue, .normal:
         isAutoPay = false
         case .autoPay:
         isAutoPay = true
         default: break
         }
         paymentFailureFlow(isAutoPay: isAutoPay)
         */
        QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
        
        switch QuickPayManager.shared.currentApiType {
        case .oneTimePayment:
            self.paymentSystemFailure()
        case .schedulePaymentNewCard:
            self.paymentSystemFailure()
        case .immediatePaymentCC, .immediatePaymentACH:
            //execute only when immediate payment failure occurs and not when OTP failure errors occurs.
//            paymentFailureFlow(isAutoPay: false)
            // As part of CMAIOS-2283
            self.paymentSystemFailure()
        case .schedulePaymentExistingPaymenthod:
            self.paymentSystemFailure()
        default: break
        }
    }
    
    private func getPaymentDueDate() -> String {
        let dueDate: String?
        if let editedDate = paymentDateAfterEdit, !editedDate.isEmpty {
            dueDate = editedDate.components(separatedBy: "T")[0]
        } else {
            dueDate = self.paymentDate
        }
        var dateValue = "Today"
        guard let paymentDate = dueDate else {
            return dateValue
        }
        let currentDate = Date().getModifiedCurrentDate()
        let modifiedPaymentDate = CommonUtility.getDateFromDateStringWOTimeZone(dueDateString: paymentDate, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        if currentDate.isSameYearMonthAndDate(date2: modifiedPaymentDate) {
            dateValue = "Today"
        } else {
            //CMAIOS-2397 use short abbreviation for year in DateFormatter
            dateValue = CommonUtility.convertDateStringFormatToPlainStyle(dateString: paymentDate, dateFormat: "MMM. d, yyyy")
        }
        return dateValue
    }
    
    /// Payment failure flow with erro code 500
    /// - Parameter isAutoPay: autopay or normal
    func paymentFailureFlow(isAutoPay: Bool) {
        let jsonParams = generateJsonParam(isAutoPay: isAutoPay)
        if jsonParams.isEmpty {
            return
        }
        self.paymentJson = jsonParams
        self.showThanksPayment(paymentState: .paymentFailure, isAutoPay: isAutoPay)
    }
    
    func isFullAmountEntered() -> Bool {
        let updatedAmount = Double(self.paymentAmount)
        return QuickPayManager.shared.getCurrentAmount() == String(format: "%.2f", updatedAmount ?? 0)
    }
    
    // Set the button title according to the selected date (Today or Future date)
    func updatePayNowButtonTitle() {
        buttonPayNow.accessibilityIdentifier = "PayNowBtn"
        if self.getPaymentDueDate() == "Today" {
            self.buttonPayNow.setTitle("Pay now", for: .normal)
        } else {
            self.buttonPayNow.setTitle("Schedule payment", for: .normal)
        }
    }
    
    // Get Payment Date
    func getPaymentDate() -> String? {
        var date: String?
        if let editedDate = paymentDateAfterEdit, !editedDate.isEmpty {
            // 2023-01-31T00:00:00Z
            date = editedDate.components(separatedBy: "T")[0] + "T00:00:00Z"
        }
        return date
    }
    
    func dateSelectedAfterDueDate() -> Bool {
        var dateSelectedAfterDueDate = false
        // CMAIOS-1985
        var dateString = self.paymentDate
        if self.paymentDateAfterEdit != nil {
            dateString = self.paymentDateAfterEdit
        }
        // CMAIOS-1985
        
        // CMAIOS-1987
        let paymentDate = dateString?.components(separatedBy: "T")[0]
        let modifiedPaymentDate = CommonUtility.getDateFromDateStringWOTimeZone(dueDateString: paymentDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        if let nextDue = QuickPayManager.shared.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate {
            let dueDate = nextDue.components(separatedBy: "T")[0]
            let modifiedPaymentDueDate = CommonUtility.getDateFromDateStringWOTimeZone(dueDateString: dueDate, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            if modifiedPaymentDueDate < modifiedPaymentDate {
                dateSelectedAfterDueDate = true // Selected date is ahead of due date
            } else if modifiedPaymentDueDate > modifiedPaymentDate {
                // Selected date is behind the due date
            } else {
                // Selected date and due date is same
            }
        }
        // CMAIOS-1987

        /*
        if let nextDue = QuickPayManager.shared.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate,
           let editedDate = dateString
        {
            let formattedDueDate = CommonUtility.dateFromTimestamp(dateString: nextDue)
            let formattedDate = editedDate.components(separatedBy: "T")
            let formattedSelectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDate[0])
            if formattedDueDate < formattedSelectedDate {
                return true
            }
        }
         */
        return dateSelectedAfterDueDate
    }
    
    // If selelcted date is after due date return due date or return ""
    func getDueAccordingToDateSelection(needDueDate: Bool) -> String {
        if needDueDate {
            return "Due on " + QuickPayManager.shared.getDueDate()
        }
        return ""
    }
    
    func calculateRemainingBalance() -> String {
        let currentAmount = Double(QuickPayManager.shared.getCurrentAmount()) ?? 0
        let scheduledPaymentAmount = Double(QuickPayManager.shared.getScheduledPaymentAmountsTillDueDate())
        
        let dueAfterScheduledPayments = max(currentAmount - scheduledPaymentAmount, 0)

        return (dueAfterScheduledPayments == 0 ? "0" : String(format: "%.2f", dueAfterScheduledPayments))
    }
    
    func updateAfterExpirationFlow(paymethod: PayMethod?) {
        self.payMethod = paymethod
        self.paymentDateAfterEdit = self.refPaymentDate
    }
    
}

extension MakePaymentViewController {
    private func DoImmediatePayment(isAutoPay: Bool) {
        let jsonParams = generateJsonParam(isAutoPay: isAutoPay)
        if jsonParams.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        // If isDefaultPaymentMethod() == false, make paymethod as true
        QuickPayManager.shared.mauiImmediatePayment(jsonParams: jsonParams, makeDefault: !isDefaultPaymentMethod(), payMethod: self.payMethod, completionHanlder: { isSuccess, errorDec, error in
            QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
            if isSuccess {
                self.mauiBillAccountActivityApiRequest(payType: .immediate, nil, oneTimeCardInfo: nil, oneAchCardInfo: nil)
            } else {
                self.signInFailedAnimation()
                self.showQuickAlertViewController(alertType: .systemUnavailable)
            }
        })
    }
    
    private func mauiBillAccountActivityApiRequest(payType: PayType,  _ createSchedulePayment: CreateSchedulePayment?, oneTimeCardInfo: SchedulePaymentWithNewCard?, oneAchCardInfo: SchedulePaymentWithNewAch?) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        self.currentAmount = QuickPayManager.shared.getCurrentAmount()
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity: \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.verifyPayType(payType: payType, createSchedulePayment: createSchedulePayment, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneAchCardInfo)
                } else {
                    Logger.info("Get Account Bill Activity failure: \(String(describing: error))")
                    self.signInFailedAnimation()
                    self.showQuickAlertViewController(alertType: .systemUnavailableTypeOne)
                }
            }
        })
    }
    
    /// Refresh Get Account bill
    private func refreshGetAccountBill(payType: PayType, oneTimeCardInfo: SchedulePaymentWithNewCard?, oneTimeAchInfo: SchedulePaymentWithNewAch?) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                }
//                let payMethod = PayMethod(name: self.sharedManager.getAccountName() + "/paymethods/" + (self.nickName.text ?? ""), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
                self.signInIsProgress = false
                self.payNowAnimation.pause()
                self.payNowAnimation.play(fromProgress: self.payNowAnimation.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
//                    self.moveToPaymentSuccessScreen(isSchedulePayment: false, createSchedulePayment)
                    self.moveToPaymentSuccessScreen(payType: payType, nil, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
                }
            }
        })
    }
    
    private func createSchedulePaymentWithExistingPaymethod() {
        let jsonParams = self.generateJsonParamCreateSchedulePayment(isUpdate: false)
        if jsonParams.1.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiSchedulePaymentWithExistingCard(jsonParams: jsonParams.1, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
                if success {
                    self.mauiBillAccountActivityApiRequest(payType: .scheduleWithExistingCard, jsonParams.0, oneTimeCardInfo: nil, oneAchCardInfo: nil)
                } else {
                    self.signInFailedAnimation()
                    self.showQuickAlertViewController(alertType: .systemUnavailable)
                }
            }
        })
    }
    
    private func createOneTimePayment() {
        let (jsonParams, oneTimeCardInfo) = jsonParamForOneTimePaymentOrSchedule(isSchedulePayment: false)
        guard let jsonParameters = jsonParams, !jsonParameters.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiOneTimePaymentRequest(jsonParams: jsonParameters, isDefault: self.cardShouldbeSaved()) { isSuccess, errorDesc, error in
            QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
            if isSuccess {
                if QuickPayManager.shared.modelQuickPayOneTimePayment?.responseInfo?.statusCode != "00000" {
                    self.signInFailedAnimation()
                    self.showErrorMsgOnPaymentFailure() //CMAIOS-2323 Removed the implementation to show older screen on payment failure
                    //self.showThanksPaymentOneTimePayment(paymentState: .oneTimePaymentFailure, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: nil)
                } else {
                    self.mauiBillAccountActivityApiRequest(payType: .onetimePayment, nil, oneTimeCardInfo: oneTimeCardInfo, oneAchCardInfo: nil)
                }
            } else {
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    private func createAchOneTimePayment() {
        let (jsonParams, oneTimeAchInfo) = jsonParamForAchOneTimePaymentOrSchedule(isSchedulePayment: false)
        guard let jsonParameters = jsonParams, !jsonParameters.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiAchOneTimePaymentRequest(jsonParams: jsonParameters, isDefault: self.cardShouldbeSaved()) { isSuccess, errorDesc, error in
            QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
            if isSuccess {
                if QuickPayManager.shared.modelAchOneTimePayment?.responseInfo?.statusCode != "00000" {
                    self.signInFailedAnimation()
                    //self.showThanksPaymentOneTimePayment(paymentState: .oneTimePaymentFailure, oneTimeCardInfo: nil, oneTimeAchInfo: oneTimeAchInfo)
                    self.showErrorMsgOnPaymentFailure() //CMAIOS-2323 Removed the implementation to show older screen on payment failure
                } else {
                    self.mauiBillAccountActivityApiRequest(payType: .onetimePayment, nil, oneTimeCardInfo: nil, oneAchCardInfo: oneTimeAchInfo)
                }
            } else {
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    // Create Schedule Payment with new card
    private func createScheduledPaymentWithNewCard() {
        let (jsonParams, oneTimeCardInfo) = jsonParamForOneTimePaymentOrSchedule(isSchedulePayment: true)
        guard let jsonParameters = jsonParams, !jsonParameters.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiSchedulePaymentWithNewCard(jsonParams: jsonParameters, isDefault: self.cardShouldbeSaved()) { isSuccess, errorDesc, error in
            QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
            if isSuccess {
                if QuickPayManager.shared.modelSchedulePaymentNewCard?.responseInfo?.statusCode != "00000" {
                    self.signInFailedAnimation()
                   // self.showThanksPaymentOneTimePayment(paymentState: .oneTimePaymentFailure, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: nil)
                    self.showErrorMsgOnPaymentFailure() //CMAIOS-2323 Removed the implementation to show older screen on payment failure
                } else {
                    self.mauiBillAccountActivityApiRequest(payType: .scheduleWithNewCard, nil, oneTimeCardInfo: oneTimeCardInfo, oneAchCardInfo: nil)
                }
            } else {
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    // Create Schedule Payment with new ACH
    private func createScheduledPaymentWithNewAch() {
        let (jsonParams, oneTimeAchInfo) = jsonParamForAchOneTimePaymentOrSchedule(isSchedulePayment: true)
        guard let jsonParameters = jsonParams, !jsonParameters.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiSchedulePaymentWithNewACH(jsonParams: jsonParameters, isDefault: self.cardShouldbeSaved()) { isSuccess, errorDesc, error in
            QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
            if isSuccess {
                if QuickPayManager.shared.modelSchedulePaymentNewCard?.responseInfo?.statusCode != "00000" {
                    self.signInFailedAnimation()
                   // self.showThanksPaymentOneTimePayment(paymentState: .oneTimePaymentFailure, oneTimeCardInfo: nil, oneTimeAchInfo: oneTimeAchInfo)
                    self.showErrorMsgOnPaymentFailure() //CMAIOS-2323 Removed the implementation to show older screen on payment failure
                } else {
                    self.mauiBillAccountActivityApiRequest(payType: .scheduleWithNewCard, nil, oneTimeCardInfo: nil, oneAchCardInfo: oneTimeAchInfo)
                }
            } else {
                self.signInFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    /// Generate json parameters for create one time payment
    /// - Returns: updated json paramerters
    private func jsonParamForOneTimePaymentOrSchedule(isSchedulePayment: Bool) -> (jsonParam: [String: AnyObject]?, cardInfo: SchedulePaymentWithNewCard?) {
        var jsonParameters: [String: AnyObject]?
        guard let paymentCardInfo = self.genererateCardDict(),
                 let amount = self.getAmountAndBalanceStateFromCell().0  else {
            return (jsonParameters, nil)
        }
        
        var paymentInfo: SchedulePaymentWithNewCard?
        /// Cosntruct Json Param
        do {
            if isSchedulePayment {
                guard let scheduleDate = self.getPaymentDate() else {
                    return (jsonParameters, paymentInfo)
                }
                let paymentCardInfo = SchdulePaymentNewCardInfo(payMethod: paymentCardInfo, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(amount)), paymentDate: scheduleDate)
                paymentInfo = SchedulePaymentWithNewCard(payment: paymentCardInfo)
                let jsonData = try JSONEncoder().encode(paymentInfo)
                jsonParameters = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            } else {
                // One time payment need other requires values like amount, save
                let paymentCardInfo = SchdulePaymentNewCardInfo(payMethod: paymentCardInfo, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(amount)), paymentDate: nil)
                paymentInfo = SchedulePaymentWithNewCard(payment: paymentCardInfo)
//                let paymentDict = CreateOneTimePayment(payment: oneTimePaymentInfo)
                // createOneTimePayMethod = paymentDict // used for payment retry feature in payment failure scenario
                let jsonData = try JSONEncoder().encode(paymentInfo)
                jsonParameters = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            }
        } catch {
            Logger.info("\(String(describing: error))")
        }
        return (jsonParameters, paymentInfo)
    }
    
    /// Generate json parameters for create one time payment for ACH
    /// - Returns: updated json paramerters
    private func jsonParamForAchOneTimePaymentOrSchedule(isSchedulePayment: Bool) -> (jsonParam: [String: AnyObject]?, cardInfo: SchedulePaymentWithNewAch?) {
        var jsonParameters: [String: AnyObject]?
        guard let paymentCardInfo = self.genererateAchDict(),
              let amount = self.getAmountAndBalanceStateFromCell().0  else {
            return (jsonParameters, nil)
        }
        var paymentInfo: SchedulePaymentWithNewAch?
        /// Cosntruct Json Param
        do {
            if isSchedulePayment {
                guard let scheduleDate = self.getPaymentDate() else {
                    return (jsonParameters, paymentInfo)
                }
                let paymentCardInfo = SchdulePaymentNewAchInfo(payMethod: paymentCardInfo, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(amount)), paymentDate: scheduleDate)
                paymentInfo = SchedulePaymentWithNewAch(payment: paymentCardInfo)
                let jsonData = try JSONEncoder().encode(paymentInfo)
                jsonParameters = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            } else {
                // One time payment need other requires values like amount, save
                let paymentCardInfo = SchdulePaymentNewAchInfo(payMethod: paymentCardInfo, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(amount)), paymentDate: nil)
                paymentInfo = SchedulePaymentWithNewAch(payment: paymentCardInfo)
                //                let paymentDict = CreateOneTimePayment(payment: oneTimePaymentInfo)
                // createOneTimePayMethod = paymentDict // used for payment retry feature in payment failure scenario
                let jsonData = try JSONEncoder().encode(paymentInfo)
                jsonParameters = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            }
        } catch {
            Logger.info("\(String(describing: error))")
        }
        return (jsonParameters, paymentInfo)
    }
    
    private func generateJsonParam(isAutoPay: Bool) -> [String: AnyObject] {
        guard let amount = self.getAmountAndBalanceStateFromCell().0 else {
            return [:]
        }
        var jsonParams: [String: AnyObject] = [:]
        guard let payMethodName = payMethod?.name else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: payMethodName)
        let payment = Payment(payMethod: payMethod, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(amount)), isImmediate: true)
        let createpayment = CreateImmediatePayment(parent: QuickPayManager.shared.getAccountNam(), payment: payment)
        
        do {
            let jsonData = try JSONEncoder().encode(createpayment)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    private func generateJsonParamCreateSchedulePayment(isUpdate: Bool) -> (CreateSchedulePayment?, [String: AnyObject]) {
        var jsonParams: [String: AnyObject] = [:]
        var createSchedulepayment: CreateSchedulePayment?
        guard let payMethodName = payMethod?.name,
              let amount = self.getAmountAndBalanceStateFromCell().0,
              let dateString = self.getPaymentDate()  else {
            return (createSchedulepayment, [:])
        }
        
        let payMethod = PayMethodInfo(name: payMethodName)
        let payment = PaymentWithDate(payMethod: payMethod, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(amount)), isImmediate: false, paymentDate: dateString)
        do {
            createSchedulepayment = CreateSchedulePayment(parent: QuickPayManager.shared.getAccountNam(), payment: payment, isCreatePaymethod: false)
            let jsonData = try JSONEncoder().encode(createSchedulepayment)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return (createSchedulepayment, jsonParams)
        
        /*
        if !isUpdate {
            do {
                let createSchedulepayment = CreateSchedulePayment(parent: QuickPayManager.shared.getAccountNam(), payment: payment, isCreatePaymethod: false)
                let jsonData = try JSONEncoder().encode(createSchedulepayment)
                jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            } catch { Logger.info("\(String(describing: error))") }
        } else {
            do {
                let updateSchedulepayment = UpdateSchedulePayment(parent: QuickPayManager.shared.getAccountNam(), payment: payment)
                let jsonData = try JSONEncoder().encode(updateSchedulepayment)
                jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
            } catch { Logger.info("\(String(describing: error))") }
        }
        return jsonParams
         */
    }
    
    /// Check whether the selcted paymethod is default paymethod or not
    /// - Returns: default or not
    private func isDefaultPaymentMethod() -> Bool {
        var isDefault = false
        if payMethod?.name == QuickPayManager.shared.getDefaultPayMethod()?.name {
            isDefault = true
        }
        if QuickPayManager.shared.hasDefaultPaymentMethod() { // CMAIOS-1841
            isDefault = false
        }
        return isDefault
    }
    
    private func genererateCardDict() -> Card? {
        let nickName = self.payMethod?.name?.components(separatedBy: "/").last
        let cardInfo = Card(newNickname: nickName, creditCardPayMethod: self.payMethod?.creditCardPayMethod)
        return cardInfo
    }
    
    private func genererateAchDict() -> Ach? {
        let nickName = self.payMethod?.name?.components(separatedBy: "/").last
        let achInfo = Ach(newNickname: nickName, bankEftPayMethod: self.payMethod?.bankEftPayMethod)
        return achInfo
    }
    
    private func showQuickAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        // CMAIOS-2099
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func showThanksPayment(paymentState: ThanksPaymentState, isAutoPay: Bool) {
        let storyboard = UIStoryboard(name: "Payments", bundle: nil)
        if let thanksViewController = storyboard.instantiateViewController(withIdentifier: "ThanksAutoPayViewController") as? ThanksAutoPayViewController {
            thanksViewController.state = paymentState
            thanksViewController.payMethod = payMethod
            if paymentState == .paymentFailure { // Only for payment failure scenario
                guard let jsonParam = paymentJson else {
                    return
                }
                thanksViewController.retryPaymentJson = jsonParam
                thanksViewController.payMethod = self.payMethod
            }
            thanksViewController.isMakePaymentFlow = true
            thanksViewController.isAutoPayFlow = isAutoPay
//            let aNavigationController = UINavigationController(rootViewController: thanksViewController)
//            aNavigationController.modalPresentationStyle = .fullScreen
//            if self.navigationController != nil {
//                aNavigationController.navigationBar.isHidden = true
//            }
//            self.present(aNavigationController, animated: true)
            self.navigationController?.pushViewController(thanksViewController, animated: true)
        }
    }
    
    private func showThanksPaymentOneTimePayment(paymentState: ThanksPaymentState, oneTimeCardInfo: SchedulePaymentWithNewCard?, oneTimeAchInfo: SchedulePaymentWithNewAch?) {
        let storyboard = UIStoryboard(name: "Payments", bundle: nil)
        if let thanksViewController = storyboard.instantiateViewController(withIdentifier: "ThanksAutoPayViewController") as? ThanksAutoPayViewController {
            thanksViewController.state = paymentState
            thanksViewController.oneTimeCardInfo = oneTimeCardInfo
            thanksViewController.oneTimeAchInfo = oneTimeAchInfo
            thanksViewController.isAutoPayFlow = false
            thanksViewController.isMakePaymentFlow = true
            self.navigationController?.pushViewController(thanksViewController, animated: true)
        }
    }
    
    private func verifyPayType(payType: PayType, createSchedulePayment: CreateSchedulePayment?, oneTimeCardInfo: SchedulePaymentWithNewCard?, oneTimeAchInfo: SchedulePaymentWithNewAch?) {
        switch payType {
        case .immediate:
            self.signInIsProgress = false
            self.payNowAnimation.pause()
            self.payNowAnimation.play(fromProgress: self.payNowAnimation.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                self.signInFailedAnimation()
                self.moveToPaymentSuccessScreen(payType: payType, createSchedulePayment, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
            }
        case .scheduleWithExistingCard:
            self.mauiGetListPaymentApiRequest(payType: payType, createSchedulePayment: createSchedulePayment, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
        case .scheduleWithNewCard:
            self.mauiGetListPaymentApiRequest(payType: payType, createSchedulePayment: createSchedulePayment, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
        case .onetimePayment:
            self.refreshGetAccountBill(payType: payType, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
        }
    }
    
    private func mauiGetListPaymentApiRequest(payType: PayType, createSchedulePayment: CreateSchedulePayment?, oneTimeCardInfo: SchedulePaymentWithNewCard?, oneTimeAchInfo: SchedulePaymentWithNewAch?) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: nil, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    if payType == .scheduleWithNewCard {
                        self.refreshGetAccountBill(payType: payType, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
                    } else {
                        self.signInIsProgress = false
                        self.payNowAnimation.pause()
                        self.payNowAnimation.play(fromProgress: self.payNowAnimation.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                            self.signInFailedAnimation()
                            self.moveToPaymentSuccessScreen(payType: payType, createSchedulePayment, oneTimeCardInfo: oneTimeCardInfo, oneTimeAchInfo: oneTimeAchInfo)
                        }
                    }
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                } else {
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                    self.signInFailedAnimation()
                    self.showQuickAlertViewController(alertType: .systemUnavailableTypeOne)
                }
            }
        })
    }
        
    private func moveToPaymentSuccessScreen(payType: PayType, _ createSchedulePayment: CreateSchedulePayment?, oneTimeCardInfo: SchedulePaymentWithNewCard?, oneTimeAchInfo: SchedulePaymentWithNewAch?) {
        let viewController = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "SchedulePaymentVC") as SchedulePaymentViewController
        //        viewController.successPaymentType = isSchedulePayment ? SuccessPaymentType.schedulePaymentSuccess: SuccessPaymentType.immediatePaymentSuccess
        switch payType {
        case .immediate:
            viewController.payMethod = payMethod
            viewController.successPaymentType = SuccessPaymentType.immediatePaymentSuccess
        case .scheduleWithExistingCard:
            viewController.payMethod = payMethod
            viewController.successPaymentType = SuccessPaymentType.schedulePaymentSuccess
        case .scheduleWithNewCard:
            viewController.payMethod = payMethod
            viewController.successPaymentType = SuccessPaymentType.schedulePaymentSuccess
        case .onetimePayment:
            viewController.payMethod = payMethod
            viewController.successPaymentType = SuccessPaymentType.immediatePaymentSuccess
        }
        viewController.paidAmount = paymentAmount
        viewController.currentAmount = self.currentAmount
        viewController.dueAmount = self.pastDueAmount
        viewController.schedulePaymentDict = createSchedulePayment
        viewController.oneTimePaymentDict = oneTimeCardInfo
        viewController.oneTimeAchPaymentDict = oneTimeAchInfo
        viewController.allSchedulePayments = self.allSchedulePayments
        viewController.isDeauthCurrently = self.isDeauthCurrently
        viewController.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow // CMAIOS-2119
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showErrorMsgOnPaymentFailure() {
        // As part of CMAIOS-2283 //CMAIOS-2439 Corrected type casting to show dynamic failure screen as per error type instead of static screen
        let errorType = payNowRetry ? OTPFailErrorType.OTPFailSecondDefaultMOP : OTPFailErrorType .OTPFailDefaultMOP
        self.handleMakePaymentErrorCodes(error: errorType)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_ADDING_MOP_FAILED.rawValue , EVENT_SCREEN_CLASS: self.classNameFromInstance])

        /*
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_ADDING_MOP_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        vc.isComingFromBillingMenu = true
        vc.isComingFromCardInfoPage = false
        // CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
         */
    }
    
    private func paymentSystemFailure() {
        // As part of CMAIOS-2283 //CMAIOS-2439 Corrected type casting to show dynamic failure screen as per error type instead of static screen
        let errorType = payNowRetry ? OTPFailErrorType.OTPFailSecondDefaultMOP : OTPFailErrorType .OTPFailDefaultMOP
        self.handleMakePaymentErrorCodes(error: errorType)
        
        //        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        //        viewcontroller.alertType = .paymentSytemUnavailable
        //        // CMAIOS-2099
        //        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
    private func isLocalPaymethod() -> Bool {
        var localPaymethod = false
        if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
            localPaymethod = true
        }
        return localPaymethod
    }
    
    private func cardShouldbeSaved() -> Bool {
        var shouldSave = false
        if isLocalPaymethod() {
            if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.payMethod?.name }), paymethodVal.count > 0 {
                shouldSave = paymethodVal.first?.save ?? false
            }
        }
        return shouldSave
    }
    
}

extension MakePaymentViewController: UpdatePaymentDate {
    
    func updatePaymentDate(selectedDate: String) {
        self.paymentDateAfterEdit = selectedDate
    }
}

struct FirstTimeCardInfo {
    let cardPaymentInfo: Card?
    let saveCard: Bool?
}

enum PayType {
    case immediate
    case scheduleWithExistingCard
    case scheduleWithNewCard
    case onetimePayment
}
