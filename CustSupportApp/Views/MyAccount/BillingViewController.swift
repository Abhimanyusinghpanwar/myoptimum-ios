//
//  BillingViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 7/21/22.
//

import UIKit
import Lottie

struct BillingDataModel {
    
    var optionTitle: String?
    var optionID: Int?
    var isErrorState: Bool
    var isEnabled: Bool
    
    static var billingTitles: [BillingDataModel] { return [
        BillingDataModel(optionTitle: "Billing & Payment History", optionID: 0, isErrorState: false, isEnabled: false),
        BillingDataModel(optionTitle: "Auto Pay", optionID: 1, isErrorState: false, isEnabled: false),
        BillingDataModel(optionTitle: "Paperless Billing", optionID: 2, isErrorState: false, isEnabled: false),
        BillingDataModel(optionTitle: "Help with Billing", optionID: 3, isErrorState: false, isEnabled: false)]
    }
}

class BillingViewContrller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var billingTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var billingLabel: UILabel!
    @IBOutlet weak var closeButtonView: UIView!
    //Pull to refresh
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet var btnCloseBottomConstraint: NSLayoutConstraint!
    @IBOutlet var billingLabelStackTopConstraint: NSLayoutConstraint!
    @IBOutlet var amountViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var btnQuickPayWidthConstraint: NSLayoutConstraint!
    @IBOutlet var lblBillStatusHeightConstraint: NSLayoutConstraint!
    @IBOutlet var viewMyBillTopToBillAmountLblConstraint: NSLayoutConstraint!
    @IBOutlet var viewMyBillTopToBillStatusConstraint: NSLayoutConstraint!
    @IBOutlet var lblBillAmntTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pastDueWarningStack: UIStackView!
    @IBOutlet weak var lblBillStatus: UILabel!
    @IBOutlet weak var lblBillAmnt: UILabel!
    @IBOutlet weak var btnQuickPay: UIButton!
    @IBOutlet weak var labelViewMyBill: UILabel!
    @IBOutlet weak var viewMyBillHyperlink: UIControl!
    
    var isPullToRefresh: Bool = false
    var billingTitlesArray: [BillingDataModel] = BillingDataModel.billingTitles
    let sharedManager = QuickPayManager.shared
    var failureAlertShown = false
//    var dataRefreshRequiredAfterChat = false
    var dataRefreshRequiredAfterChat: (Bool, Bool) = (false, false)
    var isViewAlreadyLoaded = false

    var isError: Bool = false
    var event = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUIConstantsForPullToRefresh()
      //  initiatePullToRefresh()
        //For Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_MYACCOUNT_BILLING_MENU_AUTOPAY.rawValue,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        self.removeLoaderView()
        //        self.refreshBillingAfterLegacyFlow()
        self.initialSetupOrChatRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isViewAlreadyLoaded = true
    }
    
    private func initialSetupOrChatRefresh() {
        if QuickPayManager.shared.dataAvailableToSkipLoader() {
            if self.isViewAlreadyLoaded {
                self.initialViewDetermination()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.initialViewDetermination()
                }
            }
        } else {
            self.initialLoaderStateDetermination()
        }
        /*
        if !dataRefreshRequiredAfterChat.0 {
            if QuickPayManager.shared.dataAvailableToSkipLoader() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.initialViewDetermination()
                }
            } else {
                self.initialLoaderStateDetermination()
            }
        } else {
            self.addLoader()
            self.mauiGetAccountActivityRequest()
        }
         */
    }
    
    private func initialViewDetermination() {
        if QuickPayManager.shared.isFromAutoPaySettingsView {
            self.addLoader()
            self.mauiGetBillAccountApiRequest()
        }
        self.initialUiSetup()
        self.configureUIWithData()
    }
    
    private func initialLoaderStateDetermination() {
        guard QuickPayManager.shared.ismauiMainApiInProgress.isprogress else {
            if QuickPayManager.shared.ismauiMainApiInProgress.iserror {
                self.checkAndShowErrorScreen()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.initialViewDetermination()
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
                        self?.initialViewDetermination()
                    }
                }
            }
        }
    }
    
    private func checkAndShowErrorScreen() {
        self.removeLoaderView()
        if !failureAlertShown { // Check to remove re-occurence
            failureAlertShown = true
            self.showQuickAlertViewController(alertType: .systemUnavailable, animated: false)
        }
    }
    
    private func showQuickAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        viewcontroller.modalPresentationStyle = .fullScreen
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        self.present(viewcontroller, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : MyAccountScreenDetails.MY_ACCOUNT_BILLING.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    private func configureUIWithData() {
        QuickPayManager.shared.initialScreenType()
        configureUIAsPerScreenType()
    }
    
    func configureUIAsPerScreenType() {
        self.viewMyBillHyperlink.isHidden = false
        self.btnQuickPay.isHidden = false
        switch QuickPayManager.shared.getInitialScreenFlowState() {
        case .normal: //CMAIOS-1557
            lblBillAmnt.text = "$" + QuickPayManager.shared.getCurrentAmount()
            lblBillStatus.text = "Due " + QuickPayManager.shared.getDueDate()
            lblBillStatus.isHidden = false
            btnQuickPay.isHidden = false
            btnQuickPayWidthConstraint.constant = 171
            lblBillAmnt.font = UIFont(name: "Regular-Bold", size: 38)
            lblBillStatusHeightConstraint.constant = 23
            viewMyBillTopToBillStatusConstraint.priority = UILayoutPriority.init(rawValue: 1000)
            viewMyBillTopToBillAmountLblConstraint.priority = UILayoutPriority.init(rawValue: 999)
            lblBillAmntTrailingConstraint.constant = 20
            amountViewTopConstraint.constant = 30
            event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_PAYMENTDUE.rawValue
        case .autoPay:
            lblBillAmnt.text = "$" + QuickPayManager.shared.getCurrentAmount()
            lblBillAmnt.font = UIFont(name: "Regular-Bold", size: 38)
            lblBillStatusHeightConstraint.constant = 23
            viewMyBillTopToBillStatusConstraint.priority = UILayoutPriority.init(rawValue: 1000 )
            viewMyBillTopToBillAmountLblConstraint.priority = UILayoutPriority.init(rawValue: 999)
            if QuickPayManager.shared.getAutoPayScheduleDate() == "" {
                lblBillStatus.text = "Due " + QuickPayManager.shared.getDueDate()
            }
            else {
                lblBillStatus.text = "Auto Pay set for " + QuickPayManager.shared.getAutoPayScheduleDate()
                event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_AUTOPAYSET.rawValue
            }
            btnQuickPay.isHidden = false
            lblBillStatus.isHidden = false
            btnQuickPayWidthConstraint.constant = 171
            lblBillAmntTrailingConstraint.constant = 20
            amountViewTopConstraint.constant = 30
        case .noDue:
            labelViewMyBill.text = "View my last bill"
            lblBillAmnt.text = "No payment is due at this time"
            lblBillAmnt.numberOfLines = 0
            lblBillAmnt.font = UIFont(name: "Regular-Bold", size: 28)
            lblBillStatus.isHidden = true
            btnQuickPay.isHidden = true
            btnQuickPayWidthConstraint.constant = 0
            lblBillStatusHeightConstraint.constant = 0
            viewMyBillTopToBillStatusConstraint.priority = UILayoutPriority.init(rawValue: 999 )
            viewMyBillTopToBillAmountLblConstraint.priority = UILayoutPriority.init(rawValue: 1000 )
            lblBillAmntTrailingConstraint.constant = 0
            amountViewTopConstraint.constant = 30
            event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_NOPAYMENTDUE.rawValue
        case .pastDue:
            lblBillAmnt.text = "$" + QuickPayManager.shared.getCurrentAmount()
            lblBillAmnt.font = UIFont(name: "Regular-Bold", size: 38)
            btnQuickPay.isHidden = false
            btnQuickPayWidthConstraint.constant = 171
            lblBillStatusHeightConstraint.constant = 23
            pastDueUiConfig()
            viewMyBillTopToBillStatusConstraint.priority = UILayoutPriority.init(rawValue: 1000 )
            viewMyBillTopToBillAmountLblConstraint.priority = UILayoutPriority.init(rawValue: 999 )
            lblBillAmntTrailingConstraint.constant = 20
        default:
            break
        }
        if event.isEmpty { return }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        self.view.layoutIfNeeded()
    }
    
    private func pastDueUiConfig() {
        switch QuickPayManager.shared.getDeAuthState() {
            /* CMAIOS-1254 */
        case "DE_AUTH_STATE_NONE", "DE_AUTH_STATE_PREDEAUTH":
            pastDueWarningStack.isHidden = true
            lblBillStatus.isHidden = false
            amountViewTopConstraint.constant = 30
            if QuickPayManager.shared.getPastDueAmount() == QuickPayManager.shared.getCurrentAmount() {
                lblBillStatus.text = "Past due"
                event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE_PREVIOUSAMOUNT.rawValue
            } else {
                lblBillStatus.text  = "Includes " + "$" + QuickPayManager.shared.getPastDueAmount() + " past due"
                lblBillStatus.font = UIFont(name: "Regular-Bold", size: 18)
                event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_PASTDUE_30DAYS.rawValue
            }
            
            if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
                pastDueWarningStack.isHidden = false
                amountViewTopConstraint.constant = 46
                event = BillPayEvents.MY_ACCOUNT_BILLING_BILLINGMENU_PREDEAUTH.rawValue
            }
        default: break
        }
    }
    
    private func refreshBillingAfterLegacyFlow() {
        if QuickPayManager.shared.isFromAutoPaySettingsView {
            QuickPayManager.shared.isFromAutoPaySettingsView = false
            if QuickPayManager.shared.isAutoPayEnabled() && !QuickPayManager.shared.isRouterContainsLegacySettings {
                self.billingTableView.selectRow(at: IndexPath(row: 1, section: 0), animated: true, scrollPosition: .none)
                self.tableView(self.billingTableView, didSelectRowAt: IndexPath(row: 1, section: 0))
            }
        }
    }
    
    private func mauiGetBillAccountApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.sharedManager.modelQuickPayGetAccountBill = value
                }
                self.removeLoaderView()
                self.initialUiSetup()
                QuickPayManager.shared.isFromAutoPaySettingsView = false
            }
        })
    }
    
    func mauiGetAccountActivityRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
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
    
    /// To get the initial GetAccountBill data for home screen, but its not blocker API
    func mauiRequestGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    if self.dataRefreshRequiredAfterChat.1 {
                        self.mauiGetListPaymentApiRequest()
                    } else {
                        self.refreshViewAfterChat()
                    }
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
        APIRequests.shared.mauiListPaymentRequest(interceptor: QuickPayManager.shared.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
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
    
    private func refreshViewAfterChat() {
        sharedManager.clearModelAfterChatRefresh()
        self.dataRefreshRequiredAfterChat = (false, false)
        self.initialUiSetup()
        self.configureUIWithData()
        self.removeLoaderView()
    }
    
    private func handleRefreshApiFailures() {
        self.dataRefreshRequiredAfterChat.0 = false
        self.removeLoaderView()
        self.showAlertViewController(alertType: .plainErrorMessage)
    }
    
    private func showAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        viewcontroller.modalPresentationStyle = .fullScreen
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        self.present(viewcontroller, animated: animated)
    }
    
    //MARK: ViewMyBill Action
    @IBAction func onClickViewMyBillAction(_ sender: Any) {
        self.trackOnClickEvent()
        switch QuickPayManager.shared.getViewBillScreenState() {
        case .failedBillApi: //CMAIOS-1502
            DispatchQueue.main.async {
                guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.alertType = .billingApiFailure(type: .billApiError)
                viewcontroller.modalPresentationStyle = .fullScreen
                self.present(viewcontroller, animated: true, completion: nil)
            }
        case .noBillHistory: //CMAIOS-1514
            DispatchQueue.main.async {
                guard let vc = NoBillHistoryViewController.instantiateWithIdentifier(from: .payments) else { return }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        default:
            DispatchQueue.main.async {
                //                guard let vc = BillPDFViewController.instantiateWithIdentifier(from: .payments) else { return }
                //                vc.modalPresentationStyle = .fullScreen
                //                self.present(vc, animated: true)
                guard let viewcontroller = BillPDFViewController.instantiateWithIdentifier(from: .payments) else { return }
                let navigationController = UINavigationController(rootViewController: viewcontroller)
                navigationController.setNavigationBarHidden(true, animated: true)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onClickQuickPayAction(_ sender: Any) {
        self.navigateToQuickPay()
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
       
    //MARK: LiveTopologyAPI response methods
 
    @objc func lightSpeedAPICallBack() {
        self.pullToRefresh(hideScreen: true, isComplete: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
    }
    //MARK: PullToRefresh methods
    ///Method for pull to refresh during swipe.
    func initiatePullToRefresh() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
        self.view?.addGestureRecognizer(swipeDownGestureRecognizer)
        self.vwPullToRefreshCircle.backgroundColor = energyBlueRGB
//        vwPullToRefreshCircle
    }
    
    ///Method for initial constants in pull to refresh animation
    func initialUIConstantsForPullToRefresh(){
        self.vwPullToRefresh.isHidden = true
        vwPullToRefreshCircle.isHidden = true
        self.vwPullToRefreshHeight.constant = 0
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
    }
    
    ///Method for pull to refresh animation
    @objc func pullToRefresh(hideScreen hide:Bool, isComplete: Bool = false) {
        vwPullToRefresh.isHidden = false
        vwPullToRefreshCircle.isHidden = false
        self.vwPullToRefreshAnimation.isHidden = false
        self.vwPullToRefreshAnimation.animation = LottieAnimation.named("AutoLogin")
        self.vwPullToRefreshAnimation.backgroundColor = .clear
        self.vwPullToRefreshAnimation.loopMode = !isComplete ? .loop : .playOnce
        self.vwPullToRefreshAnimation.animationSpeed = 1.0
        if !hide {
            self.handleUserInteractionOnPullToRefresh(isAllowed: false)
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
                self.vwPullToRefreshHeight.constant = 130
                self.vwPullToRefreshAnimation.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.handleUIForSmallerAndLargerDevices()
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
            }
        } else {
            self.vwPullToRefreshAnimation.play() { _ in
                self.handleUserInteractionOnPullToRefresh(isAllowed: true)
                UIView.animate(withDuration: 0.5) {
                    self.isPullToRefresh = false
                    self.vwPullToRefreshAnimation.stop()
                    self.vwPullToRefreshAnimation.isHidden = true
                    self.vwPullToRefreshTop.constant = 80
                    self.vwPullToRefreshHeight.constant = 0
                    self.handleUIForSmallerAndLargerDevices()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func handleErrorBillingView() {
        if !self.loadingView.isHidden { // Handle homeview Maui api failures to remove the loader
            QuickPayManager.shared.ismauiMainApiInProgress = (false, true)
            return
        }
    }
    
    ///Method for enable/Disable user interaction
    func handleUserInteractionOnPullToRefresh(isAllowed: Bool) {
        self.billingTableView.isUserInteractionEnabled = isAllowed
        self.closeButtonView.isUserInteractionEnabled = isAllowed
    }
    ///Method for pull to refresh api call
    func didPullToRefresh() {
        // After Refresh
        if MyWifiManager.shared.accountsNetworkPoints != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
            MyWifiManager.shared.triggerOperationalStatus()
        } else {
            // If Map is nil in Accounts API reponse, LightSpeed API shouldn't be triggered
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.pullToRefresh(hideScreen: true, isComplete: true)
            }
        }
    }
    
    func handleUIForSmallerAndLargerDevices() {
        self.view.frame.origin.y = isPullToRefresh ? 10 : 0
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            self.billingLabelStackTopConstraint.constant = isPullToRefresh ? self.billingLabelStackTopConstraint.constant + 50 : 27
        } else {
            self.billingLabelStackTopConstraint.constant = isPullToRefresh ? self.billingLabelStackTopConstraint.constant + 50 : 27
            self.btnCloseBottomConstraint.constant = isPullToRefresh ? -20 : 0
        }
        //For iPod
        if currentScreenWidth < xibDesignWidth {
           self.btnCloseBottomConstraint.constant = isPullToRefresh ? -40 : 0
        }
    }
    ///

    private func addLoader() {
        self.view.bringSubviewToFront(loadingView)
        loadingView.isHidden = false
        loadingAnimationView.isHidden = false
        showODotAnimation()
    }
    
    // MARK: - O dot Animation View
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        billingTitlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = billingTitlesArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "billingListViewCell") as! BillingListMenuCell
        cell.billingListMenuLabel.text = model.optionTitle
        cell.billingListMenuLabel.font = UIFont(name: "Regular-Bold", size: 18)
        cell.billingListMenuLabel.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        cell.billingListMenuSwitchLbl.font = UIFont(name: "Regular-Medium", size: 16)
        cell.billingListMenuSwitchLbl.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        cell.hideOnOffUsingErrorState(model: model)
        if indexPath.row == billingTitlesArray.count - 1 {
            cell.saperatorView.isHidden = true
        } else {
            cell.saperatorView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = billingTitlesArray[indexPath.row]
        navigateToSelectedScreen(model: model)
    }
    
    private func initialUiSetup() {
        self.removeLoaderView()
        let isEnabled = MyWifiManager.shared.hasBillPay()
        modifyBillingDataModel(type: "Billing & Payment History", isError: isError, isEnabled: isEnabled)
        modifyBillingDataModel(type: "Auto Pay", isError: isError, isEnabled: sharedManager.isAutoPayEnabled())
        modifyBillingDataModel(type: "Paperless Billing", isError: isError, isEnabled: sharedManager.isPaperLessBillingEnabled())
        self.billingTableView.reloadData()
    }
    
//    private func initialSetupRequests() {
//        addLoader()
//        self.refreshView()
//    }
    
//    func refreshView() {
//        sharedManager.delegate = self
//        if sharedManager.getAccountName() == "" {
//            sharedManager.initialBasicQuickPayInfo()
//        } else {
//            sharedManager.mauiGetAccountBillRequest()
//        }
//    }
    
    /// Modify the BillingDataModel for tableview according to the Autopay, paperless states
    /// - Parameters:
    ///   - type: (autopay, paperless billing)
    ///   - isEnabled: enabled or not
    private func modifyBillingDataModel(type: String, isError: Bool, isEnabled: Bool) {
        if let selectedIndex = billingTitlesArray.firstIndex(where: { $0.optionTitle == type }) {
            billingTitlesArray[selectedIndex].isEnabled = isEnabled
            billingTitlesArray[selectedIndex].isErrorState = isError
        }
    }
    
    /// Update the error state in BillingDataModel for tableview according to the Autopay, paperless error states
    /// - Parameters:
    ///   - type: (autopay, paperless billing)
    ///   - isEnabled: enabled or not
    private func updateErrorStateOnDateModel(type: String, isErrorState: Bool) {
        if let selectedIndex = billingTitlesArray.firstIndex(where: { $0.optionTitle == type }) {
            billingTitlesArray[selectedIndex].isErrorState = isErrorState
        }
    }
    
    @IBAction func billingCloseBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func navigateToSelectedScreen(model: BillingDataModel) {
        switch model.optionID {
        case 0:
            self.navigateToPaymentHistory()
            return
        case 1:
            if model.isErrorState {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_SELECT_AUTOPAY_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
//                apiFailureAlert(title: "Auto Pay information.")
                apiFailureAlert(type: .autoPayApiErrorMessage)
            } else {
                self.navigateAutoPayFlow(isEnabled: model.isEnabled)
            }
        case 2:
            if model.isErrorState {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_SELECT_PAPERLESSBILLING_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
//                apiFailureAlert(title: "Paperless Billing information.")
                apiFailureAlert(type: .paperlessApiErrorMessage)
            } else {
                navigatePaperlessBilling(isEnabled: model.isEnabled)
            }
        case 3:
            if model.isErrorState {
                apiFailureAlert(type: .helpWithBillingErrorMessage)
            } else {
                navigateHelpwithBilling(isEnabled: model.isEnabled)
            }
        default: break
        }
    }
    
//    private func navigateToPaymentHistory() {
//        guard let viewcontroller = PaymentHistoryViewController.instantiateWithIdentifier(from: .billing) else { return }
//        let navigationController = UINavigationController(rootViewController: viewcontroller)
//        navigationController.modalPresentationStyle = .fullScreen
//        self.navigationController?.isNavigationBarHidden = true
//        self.present(navigationController, animated: true, completion: nil)
//    }
    
    private func navigateToQuickPay() {
    }
    
    private func navigateToPaymentHistory() {
        guard let viewcontroller = PaymentHistoryViewController.instantiateWithIdentifier(from: .billing) else { return }
//        let navigationController = UINavigationController(rootViewController: viewcontroller)
//        navigationController.modalPresentationStyle = .fullScreen
//        self.navigationController?.isNavigationBarHidden = true
//        self.present(navigationController, animated: true, completion: nil)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func navigateAutoPayFlow(isEnabled: Bool) {
        if isEnabled {
            if QuickPayManager.shared.isRouterContainsLegacySettings {
                guard let viewcontroller = AutoPaySettingsViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.isFromHomePageCard = false
//                viewcontroller.modalPresentationStyle = .fullScreen
//                self.present(viewcontroller, animated: true, completion: nil)
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            } else {
                guard let viewcontroller = EditAutoPayViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.editScreenType = .nonGrandfatherEditAutoPay
//                let navigationController = UINavigationController(rootViewController: viewcontroller)
//                navigationController.modalPresentationStyle = .fullScreen
//                self.present(navigationController, animated: true, completion: nil)
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
        } else {
            guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
//            let navigationController = UINavigationController(rootViewController: viewcontroller)
//            navigationController.modalPresentationStyle = .fullScreen
//            self.present(navigationController, animated: true, completion: nil)
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    private func navigatePaperlessBilling(isEnabled: Bool) {
        if isEnabled {
            guard let viewcontroller = EditBillingViewController.instantiateWithIdentifier(from: .editPayments) else { return }
//            viewcontroller.modalPresentationStyle = .fullScreen
            viewcontroller.screenType = .landingScreen
//            self.present(viewcontroller, animated: true, completion: nil)
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        } else {
            guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
//            viewcontroller.modalPresentationStyle = .fullScreen
//            viewcontroller.navigationController?.navigationBar.isHidden = false
//            self.present(viewcontroller, animated: true)
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    private func navigateHelpwithBilling(isEnabled: Bool) {
        guard let viewcontroller = HelpWithBillingViewController.instantiateWithIdentifier(from: .payments) else { return }
        IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.billHelp
        viewcontroller.dimissCallBack = { chatFlow in
            if chatFlow {
                if let billingView = self.navigationController?.viewControllers.filter({$0.isKind(of: BillingViewContrller.classForCoder())}).first, let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: HelpWithBillingSubDescriptionController.classForCoder())}).first {
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
//                if self.navigationController is HelpWithBillingSubDescriptionController {
//                    self.dismiss(animated: false) {
//                        self.dataRefreshRequiredAfterChat.0 = true
//                        self.navigationController?.popViewController(animated: false)
//                        DispatchQueue.main.async {
//                            self.initialSetupOrChatRefresh()
//                        }
//                    }
//                } else {
//                    self.dataRefreshRequiredAfterChat.0 = true
//                    self.navigationController?.popViewController(animated: false)
//                    DispatchQueue.main.async {
//                        self.initialSetupOrChatRefresh()
//                    }
//                }
            } else {
                self.dismiss(animated: true)
            }
        }
        viewcontroller.modalPresentationStyle = .fullScreen
//        self.present(viewcontroller, animated: true, completion: nil)
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    private func apiFailureAlert(type: BillingApiAlert) {
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = .billingApiFailure(type: type)
        viewcontroller.modalPresentationStyle = .fullScreen
        self.present(viewcontroller, animated: true, completion: nil)
    }
}

