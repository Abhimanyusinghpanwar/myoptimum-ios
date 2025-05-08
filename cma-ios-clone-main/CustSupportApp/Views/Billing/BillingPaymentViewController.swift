//
//  BillingPaymentViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 28/11/23.
//

import UIKit
import Lottie
import ASAPPSDK

class BillingPaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.billingListTableView.dequeueReusableCell(withIdentifier: "BillingListCell") as! BillingTableViewCell
        cell.billingLabel.text = billingList[indexPath.row]
        if indexPath.row == billingList.count - 1 {
            cell.lineSeparator.isHidden = true
        } else {
            cell.lineSeparator.isHidden = false
        }
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 49
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.qualtricsAction?.cancel()
        switch indexPath.row {
        case 0:
            self.navigateToPaymentHistoryScreen()
            //CMAIOS-2310
        case 1:
            self.managePaymentMethods()
            //
        case 2:
            self.navigateToBillPrefFlow()
        case 3:
            navigateHelpwithBilling()
        default: break
        }
    }
    
    //CMAIOS-2497, 2498
    func navigateToBillPrefFlow(){
        let isBillingPreferencesOnForAutoPay = QuickPayManager.shared.isAutoPayEnabled()
        let isBillingPreferencesOnForPaperlessBilling = QuickPayManager.shared.isPaperLessBillingEnabled()
        if QuickPayManager.shared.isDiscountPresent() {
            switch (isBillingPreferencesOnForAutoPay, isBillingPreferencesOnForPaperlessBilling) {
            case (false, false):
                self.navigateToSetUpBothAPAndPB()
            default :
                self.navigateToBillingPreferencesVC()
            }
        } else {
            self.navigateToBillingPreferencesVC()
        }
    }
    
    func navigateToSetUpBothAPAndPB(){
        guard let viewcontroller = SetUpAutoPayPaperlessBillingVC.instantiateWithIdentifier(from: .editPayments) else { return }
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func navigateToBillingPreferencesVC(){
        guard let viewcontroller = BillingPreferencesViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        trackOnClickEvent(event: PaymentScreens.MYBILL_BILLING_PREFERENCES.rawValue)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }

    func navigateToPaymentHistoryScreen(){
        guard let viewcontroller = PaymentHistoryViewController.instantiateWithIdentifier(from: .billing) else { return }
        trackOnClickEvent(event: PaymentScreens.MYBILL_BILLING_PAYMENT_HISTORY.rawValue)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @IBAction func crossButtonTapped(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" {
            self.dismiss(animated: true)
        } else {
            if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            }
            UIView.animate(withDuration: 0.4) {
                self.view.bringSubviewToFront(self.loadingView)
                self.loadingView.isHidden = false
                self.loadingAnimationView.isHidden = true
                self.view.layoutIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.isManualBlock ? self.presentWithTopToBottomAnimation() : self.dismiss(animated: false)
                }
            }
        }
    }
    
    @IBAction func actionChatWithUs(_ sender: Any) {
        self.qualtricsAction?.cancel()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Quickpay_Online_Payment_Manual_Blocked.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.manualBlock)
        APIRequests.shared.isReloadNotRequiredForMaui = true
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return
        }
        self.dataRefreshRequiredAfterChat.0 = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.present(chatViewController, animated: true)
    }

    @IBAction func onTappingSchedulePaymentView(_ sender: Any) {
        self.navigateToPaymentHistoryScreen()
    }
    
    @IBAction func viewMyBillAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        trackOnClickEvent(event: PaymentScreens.MYBILL_VIEW_MY_BILL.rawValue)
        switch QuickPayManager.shared.getViewBillScreenState() {
        case .failedBillApi: //CMAIOS-1502
            DispatchQueue.main.async {
                guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.alertType = .billingApiFailure(type: .billApiError)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        case .noBillHistory: //CMAIOS-1514
            DispatchQueue.main.async {
                guard let viewcontroller = NoBillHistoryViewController.instantiateWithIdentifier(from: .payments) else { return }
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        default:
            DispatchQueue.main.async {
                guard let viewcontroller = BillPDFViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.pdfType = .viewBill
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        }
    }
    
    private func trackOnClickEvent() {
        var event: String = ""
        if QuickPayManager.shared.getInitialScreenFlowState() == .noDue { // CMAIOS-1515
            event = BillPayEvents.VIEW_MY_LAST_BILL_BUTTON_CLICK.rawValue
        } else {
            event = BillPayEvents.VIEW_MY_BILL_BUTTON_CLICK.rawValue
        }
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : event,
                        EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_MYACCOUNT_BILLING_MENU.rawValue,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
    }
    
    //CMAIOS-2310
    private func managePaymentMethods() {
        if sharedManager.getAllPayMethodMop().isEmpty {
            self.showAddCard(manageCards: true)
        } else {
            guard let vc = ManagePaymentsViewController.instantiateWithIdentifier(from: .billing) else { return }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    @IBOutlet weak var billingListTableView: UITableView!
    @IBOutlet weak var noPaymentView: UIView!
    @IBOutlet weak var noPaymentLabel: UILabel!
    @IBOutlet weak var paymentDueView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var preDeauthWarningView: UIView!
    @IBOutlet weak var autoPayView: UIView!
    @IBOutlet weak var autoPayContentLabel: VerticalAlignLabel!
    @IBOutlet weak var billingImageToTop: NSLayoutConstraint!
    @IBOutlet weak var billingImageTopToPreDeAuth: NSLayoutConstraint!
    @IBOutlet weak var makePaymentToNoPaymentViewTop: NSLayoutConstraint!
    @IBOutlet weak var makePaymentToPaymentDueTop: NSLayoutConstraint!
    @IBOutlet weak var preDeauthViewToTop: NSLayoutConstraint!
    @IBOutlet weak var autoPayViewToTop: NSLayoutConstraint!
    @IBOutlet weak var labelPreDeAuthMessage: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var chatButtonView: UIView!
    @IBOutlet weak var heightManualBlockView: NSLayoutConstraint!
    @IBOutlet weak var manualBlockView: UIView!
    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var viewBillToPaymentDueTop: NSLayoutConstraint!
    @IBOutlet weak var btnMakePayment: UIButton!
    @IBOutlet weak var lableManualBlockMsg: UILabel!
    @IBOutlet weak var heightManualCloseView: NSLayoutConstraint!
    @IBOutlet weak var autoPayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deauthViewToTop: NSLayoutConstraint!
    @IBOutlet weak var deAuthWarningView: UIView!
    @IBOutlet weak var labeldeAuthMessage: UILabel!
    
    var dataRefreshRequiredAfterChat: (Bool, Bool) = (false, false)
    var failureAlertShown = false
    var billingList = ["Billing & Payment History", "Manage payment methods", "Auto Pay and Paperless Billing", "Help with billing"] //CMAIOS-2497
    var isManualBlock:Bool = false
    let sharedManager = QuickPayManager.shared
    var qualtricsAction : DispatchWorkItem?
    var isMauiFailChatFlow : Bool = false //CMAIOS-2461
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.billingListTableView.register(UINib(nibName: "BillingTableViewCell", bundle: nil), forCellReuseIdentifier: "BillingListCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if isMauiFailChatFlow { //CMAIOS-2461 back button navigation fix
            isMauiFailChatFlow = false
            self.crossButtonTapped(UIButton())
            return
        }
        QuickPayManager.shared.localSavedPaymethods = nil
        if APIRequests.shared.isReloadNotRequiredForMaui {
            APIRequests.shared.isReloadNotRequiredForMaui = false
        }
        self.initialSetupOrChatRefresh()
        //  updateAnalyitcsEvents(event: getAnalyitcsEvents()) //CMAIOS-2753
        QuickPayManager.shared.setEnrolType() //CMAIOS-2496
    }
    
    func addQualtrics(screenName:String){
        self.qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    private func initialSetupOrChatRefresh() {
        /*
         if QuickPayManager.shared.dataAvailableToSkipLoader() {
         //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
         self.initialSetup()
         //            }
         } else {
         self.initialLoaderStateDetermination()
         }
         */
        
        if !dataRefreshRequiredAfterChat.0 {
            /*
             if QuickPayManager.shared.dataAvailableToSkipLoader() {
             self.initialSetup()
             } else {
             self.initialLoaderStateDetermination()
             }
             */
            /*
            self.initialLoaderStateDetermination()
             */
            self.checkMauiApiStateForRefresh() // CMAIOS-2480
        } else {
            self.addLoader()
            self.mauiBillAccountActivityApiRequest(chatFlow: true)  // CMAIOS-2480
        }
    }
    
    /// Tracks and updates initial API Progress to show loader or not
    private func initialLoaderStateDetermination() {
        guard QuickPayManager.shared.ismauiMainApiInProgress.isprogress else {
            if QuickPayManager.shared.ismauiMainApiInProgress.iserror {
                self.checkAndShowErrorScreen()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.initialSetup()
                }
            }
            return
        }
        addLoader()
        QuickPayManager.shared.ismauiMainApiInProgressLoader = { [weak self] in
            if QuickPayManager.shared.ismauiMainApiInProgress.isprogress {
                self?.addLoader()
            } else {
                if QuickPayManager.shared.ismauiMainApiInProgress.iserror {
                    self?.checkAndShowErrorScreen()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self?.initialSetup()
                    }
                }
            }
        }
    }
    
    private func initialSetup() {
        self.removeLoaderView()
        self.configureUIWithData()
    }
    
    private func configureUIWithData() {
        updateAnalyitcsEvents(event: getAnalyitcsEvents()) //CMAIOS-2753
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock() //CMAIOS-2085
        configureUIAsPerScreenType()
        addBorderSchedulePaymentView()
        addBorderdeAuthWarningView()
        updateLineHeight()
    }
    
    private func updateManualBlockViewStyle() {
        self.viewClose.isHidden = true
        self.billingListTableView.isHidden = true
        presentWithBottomToTopAnimation()
        let maskPath = UIBezierPath(
            roundedRect: manualBlockView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 12, height: 12)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.frame = manualBlockView.bounds
        maskLayer.path = maskPath.cgPath

        manualBlockView.layer.mask = maskLayer
        self.manualBlockView.backgroundColor = midnightBlueRGB
        self.chatButtonView.layer.cornerRadius = 15.0
    }
    
    // Function to present the view with a bottom-to-top animation
    func presentWithBottomToTopAnimation() {
        let screenHeight = UIScreen.main.bounds.height
        let viewHeight: CGFloat = 340
        manualBlockView.frame = CGRect(x: 0, y: screenHeight, width: view.frame.width, height: viewHeight)
        
        UIView.animate(withDuration: 0.5) {
            self.manualBlockView.frame = CGRect(x: 0, y: screenHeight - viewHeight, width: self.manualBlockView.frame.width, height: viewHeight)
        }
    }
    
    func presentWithTopToBottomAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.heightManualCloseView.constant = 0
            self.heightManualBlockView.constant = 0
            self.manualBlockView.alpha = 1.0
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: true)
        }
    }

    private func addBorderSchedulePaymentView() {
        self.autoPayView.clipsToBounds = false
        self.autoPayView.layer.cornerRadius = 12
        self.autoPayView.layer.borderColor = energyBlueRGB.cgColor
        self.autoPayView.layer.borderWidth = 1.0
    }
    
    private func addBorderdeAuthWarningView() {
        self.deAuthWarningView.clipsToBounds = false
        self.deAuthWarningView.layer.cornerRadius = 12
        self.deAuthWarningView.layer.borderColor = UIColor(red: 0.954, green: 0.208, blue: 0.342, alpha: 1).cgColor
        self.deAuthWarningView.layer.borderWidth = 1.0
    }
    
    private func updateLineHeight() {
        self.autoPayContentLabel.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
        self.labelPreDeAuthMessage.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
    }
    
    private func configureUIAsPerScreenType() {
        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let billingImageTopConstraint = (UIDevice.current.hasNotch) ? 105 + (keyWindow?.safeAreaInsets.top)! : 105
        billingImageToTop.constant = billingImageTopConstraint
        self.manualBlockView.isHidden = true
        labeldeAuthMessage.setLineHeight(1.2)
        //  QuickPayManager.shared.initialScreenTypeWithOutManualBlock() //CMAIOS-2753
        deAuthWarningView.isHidden = true
        switch QuickPayManager.shared.initialScreenFlow {
        case .noDue:
            preDeauthWarningView.isHidden = true
            autoPayView.isHidden = true
            makePaymentToPaymentDueTop.priority = UILayoutPriority(200)
            makePaymentToNoPaymentViewTop.priority = UILayoutPriority(999)
            noPaymentView.isHidden = false
            noPaymentLabel.text = "No payment due at this time"
            paymentDueView.isHidden = true
            checkForSchedulePayment()
            verificationForManualBlockState()
            if !QuickPayManager.shared.isAccountManualBlocked(){
                self.addQualtrics(screenName: PaymentScreens.MYBILL_NO_PAYMENT_DUE.rawValue)
            }
        case .normal: // Due
            preDeauthWarningView.isHidden = true
            autoPayView.isHidden = true
            makePaymentToPaymentDueTop.priority = UILayoutPriority(999)
            makePaymentToNoPaymentViewTop.priority = UILayoutPriority(200)
            noPaymentView.isHidden = true
            paymentDueView.isHidden = false
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            dueDateLabel.text = "Due " + QuickPayManager.shared.getDueDate()
            checkForSchedulePayment()
            verificationForManualBlockState()
            if !QuickPayManager.shared.isAccountManualBlocked() {
                self.addQualtrics(screenName: PaymentScreens.MYBILL_AMOUNT_DUE.rawValue)
            }
        case .pastDue:
            preDeauthViewToTop.constant = (UIDevice.current.hasNotch) ? ( (keyWindow?.safeAreaInsets.top)! + 35.0) : 35.0
            deauthViewToTop.constant = (UIDevice.current.hasNotch) ? ( (keyWindow?.safeAreaInsets.top)! + 15.0) : 30.0
            preDeauthWarningView.isHidden = true
            autoPayView.isHidden = true
            makePaymentToPaymentDueTop.priority = UILayoutPriority(999)
            makePaymentToNoPaymentViewTop.priority = UILayoutPriority(200)
            noPaymentView.isHidden = true
            paymentDueView.isHidden = false
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_NONE" {
                checkForSchedulePayment()
            }
            pastDueUiConfig()
            verificationForManualBlockState()
        case .autoPay:
            autoPayViewToTop.constant = (UIDevice.current.hasNotch) ? ((keyWindow?.safeAreaInsets.top)! + 30.0) : 30.0
            preDeauthWarningView.isHidden = true
            autoPayView.isHidden = true
            makePaymentToPaymentDueTop.priority = UILayoutPriority(999)
            makePaymentToNoPaymentViewTop.priority = UILayoutPriority(200)
            noPaymentView.isHidden = true
            paymentDueView.isHidden = false
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            if QuickPayManager.shared.getAutoPayScheduleDate() == "" {
                dueDateLabel.text = "Due " + QuickPayManager.shared.getDueDate()
                if !QuickPayManager.shared.isAccountManualBlocked(){
                    self.addQualtrics(screenName: PaymentScreens.MYBILL_AMOUNT_DUE.rawValue)
                }
            }
            else {
                dueDateLabel.text = "Auto Pay set for " + QuickPayManager.shared.getAutoPayScheduleDate()
                if !QuickPayManager.shared.isAccountManualBlocked(){
                    self.addQualtrics(screenName: PaymentScreens.MYBILL_AUTO_PAY.rawValue)
                }
            }
            if Double(QuickPayManager.shared.getCurrentAmount()) ?? 0 > 0 {
                checkForSchedulePayment()
            }
            verificationForManualBlockState()
            /*
             case .manualBlock:
             lableManualBlockMsg.setLineHeight(1.2)
             isManualBlock = true
             btnMakePayment.isHidden = true
             viewBillToPaymentDueTop.constant = 12
             manualBlockView.isHidden = false
             updateManualBlockViewStyle()
             noPaymentView.isHidden = true
             paymentDueView.isHidden = false
             amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
             pastDueUiConfig()
             */
        default:
            break
        }
    }
    
    private func pastDueUiConfig() {
        switch QuickPayManager.shared.getDeAuthState() {
            /* CMAIOS-1254 */
        case "DE_AUTH_STATE_NONE", "DE_AUTH_STATE_PREDEAUTH":
            dueDateLabel.isHidden = false
            if QuickPayManager.shared.getPastDueAmount() == QuickPayManager.shared.getCurrentAmount() {
                dueDateLabel.text = "Past due"
                if !QuickPayManager.shared.isAccountManualBlocked(){
                    self.addQualtrics(screenName: PaymentScreens.MYBILL_PAST_DUE_30.rawValue)
                }
//                event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE_PREVIOUSAMOUNT.rawValue
            } else {
                dueDateLabel.text  = "Includes " + "$" + QuickPayManager.shared.getPastDueAmount() + " past due"
//                event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE_30DAYS.rawValue
            }
            autoPayView.isHidden = true
            if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
                if !QuickPayManager.shared.isAccountManualBlocked(){
                    self.addQualtrics(screenName: PaymentScreens.MY_BILL_PREDEAUTH.rawValue)
                }
                preDeauthWarningView.isHidden = false
                deAuthWarningView.isHidden = true
                //Maintaining the space of 44px between billingImage and preDeauthWarningView
//                billingImageToTop.priority = UILayoutPriority(200)
//                billingImageTopToPreDeAuth.priority = UILayoutPriority(999)
            } else {
                preDeauthWarningView.isHidden = true
                if QuickPayManager.shared.getPastDueAmount() == QuickPayManager.shared.getCurrentAmount() {
                    deAuthWarningView.isHidden = false
                    labeldeAuthMessage.text = "Please pay now to avoid late fees."
                } else {
                    deAuthWarningView.isHidden = true
                }
            }
        case "DE_AUTH_STATE_DEAUTH":
            preDeauthWarningView.isHidden = true
            autoPayView.isHidden = true
            deAuthWarningView.isHidden = false
            /* CMAIOS-2045 */
            billingImageToTop.priority = UILayoutPriority(200)
            billingImageTopToPreDeAuth.priority = UILayoutPriority(999)
            labeldeAuthMessage.text = "Pay now to restore your Optimum service."
            if QuickPayManager.shared.getPastDueAmount() == QuickPayManager.shared.getCurrentAmount() {
                dueDateLabel.text = "Past due"
            } else {
                dueDateLabel.text  = "Includes " + "$" + QuickPayManager.shared.getPastDueAmount() + " past due"
            }
        default: break
        }
    }
    
    private func verificationForManualBlockState() {
        if QuickPayManager.shared.isAccountManualBlocked() {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : PaymentScreens.MANUAL_BLOCK.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            lableManualBlockMsg.setLineHeight(1.2)
            isManualBlock = true
            btnMakePayment.isHidden = true
            manualBlockView.isHidden = false
            autoPayView.isHidden = true
            updateManualBlockViewStyle()
            viewBillToPaymentDueTop.constant = 12
        }
    }
        
    private func checkForSchedulePayment() {
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock()
        QuickPayManager.shared.isOneTimePaymentScheduled(onCompletion: { paymentInfo, paymentScheduled in
            switch (paymentScheduled,
                    QuickPayManager.shared.initialScreenFlow == .pastDue,
                    QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH") {
            case (false, _, _):
                autoPayView.isHidden = true
            case (true, true, true):
                DispatchQueue.main.async { // CMAIOS-1864
                    self.showSchedulePaymentAlert(paymentInfo: paymentInfo)
                    self.preDeauthWarningView.isHidden = true
                    self.deAuthWarningView.isHidden = true
                }
            default:
                DispatchQueue.main.async { // CMAIOS-1864
                    self.showSchedulePaymentAlert(paymentInfo: paymentInfo)
                }
            }
        })
    }
    
    private func showSchedulePaymentAlert(paymentInfo: ListPayment?) {
        if let payMethod = paymentInfo?.payMethod,
           let scheduledAmount = paymentInfo?.paymentAmount?.amount,
           let scheduledDate = paymentInfo?.paymentDate  {
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            autoPayViewToTop.constant = (UIDevice.current.hasNotch) ? ((keyWindow?.safeAreaInsets.top)! + 30.0) : 36.0
            billingImageToTop.constant = autoPayViewToTop.constant + autoPayView.frame.height + 36.0
            let payMethodInfo = QuickPayManager.shared.payMethodInfo(payMethod: payMethod)
            let amount = "$" + String(format: "%.2f", scheduledAmount)
            let payemntDate = CommonUtility.convertDateStringFormats(dateString: scheduledDate, dateFormat: "MMM. d")
            let cardInfoTitle = (payMethodInfo.0 == "") ? "": " from \(payMethodInfo.0)"
            self.autoPayContentLabel.text = "We will collect \(amount) on \(payemntDate)\(cardInfoTitle)"
            if self.autoPayContentLabel.actualNumberOfLines == 1 {
                autoPayViewHeightConstraint.constant = 52
            } else {
                autoPayViewHeightConstraint.constant = 68
            }
            autoPayView.isHidden = false
        }
    }
    
    private func checkAndShowErrorScreen() {
        self.removeLoaderView()
        if !failureAlertShown { // Check to remove re-occurence
            self.qualtricsAction?.cancel()
            failureAlertShown = true
            self.showQuickAlertViewController(alertType: .systemUnavailable, animated: false)
        }
    }
    
    private func showQuickAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
    func handleErrorMyBillView() {
        /*
         if !self.loadingView.isHidden { // Handle homeview Maui api failures to remove the loader
         QuickPayManager.shared.ismauiMainApiInProgress = (false, true)
         return
         }
         */
        // CMAIOS-2542
        self.handleRefreshApiFailures(chatFlow: dataRefreshRequiredAfterChat.0)
    }
    
    // MARK: - O dot Animation View
    private func addLoader() {
        self.view.bringSubviewToFront(loadingView)
        loadingView.isHidden = false
        loadingAnimationView.isHidden = false
        showODotAnimation()
    }
    
    private func showODotAnimation() {
        loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        loadingAnimationView.backgroundColor = .clear
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.play()
    }
    
    private func removeLoaderView() {
        if !loadingView.isHidden {
            loadingView.isHidden = true
            loadingAnimationView.stop()
            loadingAnimationView.isHidden = true
        }
    }
    
    @IBAction func makePaymentAction(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        trackOnClickEvent(event: PaymentScreens.MYBILL_MAKE_PAYMENT.rawValue)
        
        /*
        if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
            self.showAddCard()
        } else {
            if QuickPayManager.shared.getCurrentAmount() == "" {
                self.enterAmountScreen()
            } else {
                self.moveToMakePaymentScreen()
            }
        }
         */
        
        switch (sharedManager.getAllPayMethodMop().isEmpty,
                sharedManager.hasDefaultPaymentMethod(),
                sharedManager.getDefaultPayMethod()?.creditCardPayMethod?.isCardExpired,
                sharedManager.getAllPayMethodMop().count > 1)
        {
        case (true, _, _, _):
            self.showAddCard()
        case (_, true, true, false), (_, false, true, false): // CMAIOS-2009 & CMAIOS-2161
            cardExpiredErrorScreen(paymethod: sharedManager.getDefaultPayMethod(), flow: .onlyDefaultExpired)
        case (_, true, true, true), (_, false, true, true): // CMAIOS-2012 & CMAIOS-2162
            cardExpiredErrorScreen(paymethod: sharedManager.getDefaultPayMethod(), flow: .defaultExpiredWithMoreMOPs)
        default:
            if QuickPayManager.shared.getCurrentAmount() == "" {
                self.enterAmountScreen()
            } else {
                self.moveToMakePaymentScreen()
            }
        }
        
        // Bank account pay method creation test method, should be move to respective screen once the new UI has been designed
        /*
        self.createBankAccountPaymethod()
         */
    }
    
    private func cardExpiredErrorScreen(paymethod: PayMethod?, flow: ExpirationFlow) {
        let cardExpiredVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "CardExpiredNotifyVC") as CardExpiredNotifyVC
        cardExpiredVC.payMethod = paymethod
        cardExpiredVC.cardExpiryFlow = flow
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(cardExpiredVC, animated: true)
    }
        
    private func moveToMakePaymentScreen() {
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock()
        makePayVC.dimissCallBack = { chatFlow in
            if chatFlow {
                if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first, let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first {
                    self.dataRefreshRequiredAfterChat.0 = true
                    self.navigationController?.popToViewController(billingView, animated: false)
                    DispatchQueue.main.async {
                        self.initialSetupOrChatRefresh()
                    }
                }  else {
                    self.dataRefreshRequiredAfterChat.0 = true
                    self.navigationController?.popViewController(animated: false)
                    DispatchQueue.main.async {
                        self.initialSetupOrChatRefresh()
                    }
                }
            } else {
                self.dismiss(animated: true)
            }
        }
        makePayVC.state = QuickPayManager.shared.getInitialScreenFlowState()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
    private func enterAmountScreen() {
        DispatchQueue.main.async {
            let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
            enterPayVC.amountStr = ""
            enterPayVC.balanceStateText = "No payment due at this time"
            self.navigationController?.pushViewController(enterPayVC, animated: true)
        }
    }
    
    private func showAddCard(manageCards: Bool = false) {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = true
        if !manageCards {
            viewcontroller.flow = .noPayments
        } else {
            viewcontroller.flow = .managePayments(editAutoAutoPayFlow: false)
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func navigateHelpwithBilling() {
        self.qualtricsAction?.cancel()
        guard let viewcontroller = HelpWithBillingViewController.instantiateWithIdentifier(from: .payments) else { return }
        IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.billHelp
        trackOnClickEvent(event: PaymentScreens.MYBILL_HELP_WITH_BILLING.rawValue)
        viewcontroller.dimissCallBack = { chatFlow in
            if chatFlow {
                if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingPaymentViewController.classForCoder())}).first, let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: HelpWithBillingSubDescriptionController.classForCoder())}).first {
                    self.dataRefreshRequiredAfterChat.0 = true
                    self.navigationController?.popToViewController(billingView, animated: false)
                    DispatchQueue.main.async {
                        self.initialSetupOrChatRefresh()
                    }
                }  else {
                    self.dataRefreshRequiredAfterChat.0 = true
                    self.navigationController?.popViewController(animated: false)
                    DispatchQueue.main.async {
                        self.initialSetupOrChatRefresh()
                    }
                }
            } else {
                self.dismiss(animated: true)
            }
        }
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    // MARK: - Date Refresh APIs after chat
    
    /*
    func mauiGetAccountActivityRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: nil, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity Response is \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiRequestGetAccountBill()
                } else {
                    Logger.info("Get Account Bill Activity Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    func mauiRequestGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.mauiGetListPaymentApiRequest()
                } else {
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: nil, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                    self.refreshViewAfterChat()
                } else {
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
     */
    
    private func handleRefreshApiFailures(chatFlow: Bool = false) {
        if chatFlow { self.dataRefreshRequiredAfterChat.0 = false }
        self.removeLoaderView()
        self.showAlertViewController(alertType: .plainErrorMessage, animated: false)
    }
    
    private func refreshViewAfterChat() {
        sharedManager.clearModelAfterChatRefresh()
        self.dataRefreshRequiredAfterChat = (false, false)
        self.initialSetup()
        self.configureUIWithData()
        self.removeLoaderView()
    }
    
    private func showAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        self.qualtricsAction?.cancel()
        guard let viewController = UIStoryboard(name: "WiFiScreen", bundle: nil).instantiateViewController(identifier: "MyWiFiScreen") as? MyWiFiViewController else {
            return
        }
      //  guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
       // viewController.alertType = alertType
        //CMAIOS-2461
        viewController.dismissCallBack = { chatFlow in
            if chatFlow {
                self.isMauiFailChatFlow = chatFlow
                self.navigationController?.popViewController(animated: false)
            }
        }
        viewController.navigationController?.isNavigationBarHidden = true
        viewController.forBillingFailure = true
        viewController.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    
    private func updateAnalyitcsEvents(event: String) {
        if event == "" {
            return
        }
        
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: event,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func getAnalyitcsEvents() -> String {
        var event = ""
        switch QuickPayManager.shared.getInitialScreenFlowState() {
        case .defaultDisclaimer: break
        case .expireDateError: break
        case .dueCreditApplied: break
        case .noDue:
            event = PaymentScreens.MYBILL_NO_PAYMENT_DUE.rawValue
        case .pastDue:
            if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
                event = PaymentScreens.MY_BILL_PREDEAUTH.rawValue
            } else {
                event = PaymentScreens.MYBILL_PAST_DUE_30.rawValue
            }
        case .normal:
            event = PaymentScreens.MYBILL_AMOUNT_DUE.rawValue
        case .autoPay:
            event = PaymentScreens.MYBILL_AUTO_PAY.rawValue
        case .manualBlock:
            event = PaymentScreens.MANUAL_BLOCK.rawValue
        }
        return event
    }
    
    private func trackOnClickEvent(event: String) {
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : event,
                        EVENT_SCREEN_NAME: self.getAnalyitcsEvents(),
                       EVENT_SCREEN_CLASS: self.classNameFromInstance, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue]
        )
    }
    
    /// Generate json parameter to create bank account paymethod
    /// - Returns: updated json paramerters
    private func generateJsonParam() -> (jsonParm: [String: AnyObject], bankAccPayMethod: BankEftPayMethod) {
        let maskedAccountNumber = PGPCryptoUtility.cardEncryption(cardNumber: "test123")
        var jsonParams = [String: AnyObject]()
        let bankAccDict = BankEftPayMethod(nameOnAccount: "Test User",
                                           maskedBankAccountNumber: "888271156",
                                           routingNumber: "122000247",
                                           accountType: "BANK_ACCOUNT_TYPE_CHECKING")
        let bankAccountInfo = BankAccout(newNickname: "MyCardTest12345", bankEftPayMethod: bankAccDict)
        do {
            let jsonData = try JSONEncoder().encode(bankAccountInfo)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))")}
        return (jsonParams, bankAccDict)
    }
    
    // Bank account pay method creation test method, should be move to respective screen once the new UI has been designed
    /// Creating new Bank Pay Method
    private func createBankAccountPaymethod(isDefault: Bool = false) {
        let parms = generateJsonParam()
        let jsonParams = parms.0
        if jsonParams.isEmpty {
            return
        }
        QuickPayManager.shared.mauiCreateBankPaymethod(jsonParams: jsonParams, isDefault: isDefault) { isSuccess, errorDesc, error in
            if isSuccess {
                if QuickPayManager.shared.modelQuickPayCreateBankAccount?.responseInfo?.statusCode == "00000" {
                    print("Success")
                } else {
                    print("Failed")
                }
            } else {
                print("API Failed")
            }
        }
    }
    
    // CMAIOS-2480
    func checkMauiApiStateForRefresh() {
        switch (QuickPayManager.shared.isMauiAccountListCompleted,
                QuickPayManager.shared.isGetAccountActivityCompleted,
                QuickPayManager.shared.isListBillsCompeletd,
                QuickPayManager.shared.isGetAccountBillCompleted) {
        case (false, _, _, _):
            self.addLoader()
            self.mauiAccoutsListRequest()
        case (true, false, _, _):
            self.addLoader()
            self.mauiBillAccountActivityApiRequest()
        case (true, true, false, _):
            self.addLoader()
            self.mauiGetBillAccountApiRequest()
        case (true, true, true, false):
            self.addLoader()
            self.mauiGetListPaymentApiRequest()
        default:
            self.initialSetup()
        }
    }
    
    func mauiAccoutsListRequest() {
        QuickPayManager.shared.currentApiType = .accountList
        APIRequests.shared.mauiAccoutsListRequest(interceptor: QuickPayManager.shared.interceptor, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.isMauiAccountListCompleted = true
                    QuickPayManager.shared.modelAccountsList = value
                    self.mauiBillAccountActivityApiRequest()
                    Logger.info("MAUI Account List Response is \(String(describing: value))", sendLog: "MAUI Account List success")
                } else {
                    Logger.info("MAUI Account List Response is \(String(describing: error))")
                    QuickPayManager.shared.isMauiAccountListCompleted = false
                    QuickPayManager.shared.updateTheRetryFlags()
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    private func mauiBillAccountActivityApiRequest(chatFlow: Bool = false) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        QuickPayManager.shared.currentApiType = .getBillActivity
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    QuickPayManager.shared.isGetAccountActivityCompleted = true
                    Logger.info("Get Account Bill Activity: \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiGetBillAccountApiRequest()
                } else {
                    QuickPayManager.shared.isGetAccountActivityCompleted = false
                    Logger.info("Get Account Bill Activity failure: \(String(describing: error))")
                    QuickPayManager.shared.updateTheRetryFlags()
                    self.handleRefreshApiFailures(chatFlow: chatFlow)
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest(chatFlow: Bool = false) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: QuickPayManager.shared.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    QuickPayManager.shared.isListBillsCompeletd = true
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                    if chatFlow {
                        self.refreshViewAfterChat()
                    } else {
                        self.removeLoaderView()
                        self.initialSetup()
                    }
                } else {
                    QuickPayManager.shared.isListBillsCompeletd = false
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                    self.handleRefreshApiFailures(chatFlow: chatFlow)
                }
            }
        })
    }
        
    private func mauiGetBillAccountApiRequest(chatFlow: Bool = false) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    QuickPayManager.shared.isGetAccountBillCompleted = true
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.mauiGetListPaymentApiRequest(chatFlow: chatFlow)
                } else {
                    QuickPayManager.shared.isGetAccountBillCompleted = false
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                    self.handleRefreshApiFailures(chatFlow: chatFlow)
                }
            }
        })
    }
}

//enum CardExpiryFlow {
//    case onlyDefaultExpired
//    case other
//}
