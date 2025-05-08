//
//  MyAccountViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 7/21/22.
//

import UIKit
import Shift
import Lottie
import SafariServices
import ASAPPSDK
protocol DismissingChildViewcontroller {
    func childViewcontrollerGettingDismissed()
    func pushChatVC(withIntentData: [String:Any]?)
}

struct MyAccountModel {
    
    var optionTitle: String?
    var optionID: Int?
    var optionImage: String
    
    static var myAccountTitles: [MyAccountModel] {
//        if MyWifiManager.shared.isPrimaryUser() {
//            if MyWifiManager.shared.hasBillPay()
//            {
//                return [
//                    MyAccountModel(optionTitle: "Billing", optionID: 3, optionImage: ""),
//                    MyAccountModel(optionTitle: "Manage my household", optionID: 1, optionImage: ""),
//                    MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: ""),
//                    MyAccountModel(optionTitle: "Share my feedback", optionID: 5, optionImage: ""),
//                    MyAccountModel(optionTitle: "Chat with us", optionID: 6, optionImage: "")]
//            }else
//            {
//                return [
//                    MyAccountModel(optionTitle: "Manage my household", optionID: 1, optionImage: ""),
//                    MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: ""),
//                    MyAccountModel(optionTitle: "Share my feedback", optionID: 5, optionImage: ""),
//                    MyAccountModel(optionTitle: "Chat with us", optionID: 6, optionImage: "")]
//            }
//        }else{
//            if MyWifiManager.shared.hasBillPay(){
//                return [
//                    MyAccountModel(optionTitle: "Billing", optionID: 3, optionImage: ""),
//                    MyAccountModel(optionTitle: "Manage my household", optionID: 1, optionImage: ""),
//                    MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: ""),
//                    MyAccountModel(optionTitle: "Share my feedback", optionID: 5, optionImage: ""),
//                    MyAccountModel(optionTitle: "Chat with us", optionID: 6, optionImage: "")]}
//            else
//            {
//                return [
//                    MyAccountModel(optionTitle: "Manage my household", optionID: 1, optionImage: ""),
//                    MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: ""),
//                    MyAccountModel(optionTitle: "Share my feedback", optionID: 5, optionImage: ""),
//                    MyAccountModel(optionTitle: "Chat with us", optionID: 6, optionImage: "")]
//            }
//        }
        return [
        MyAccountModel(optionTitle: "Manage my household", optionID: 1, optionImage: ""),
        MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: "")]
    }
    static var myAccountTitlesTVOnly: [MyAccountModel] {
//        if MyWifiManager.shared.hasBillPay()
//        {
//            return [
//                MyAccountModel(optionTitle: "Billing", optionID: 3, optionImage: ""),
//                MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: ""),
//                MyAccountModel(optionTitle: "Share my feedback", optionID: 5, optionImage: ""),
//                MyAccountModel(optionTitle: "Chat with us", optionID: 6, optionImage: "")]
//        } else {
//            return [
//                MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: ""),
//                MyAccountModel(optionTitle: "Share my feedback", optionID: 5, optionImage: ""),
//                MyAccountModel(optionTitle: "Chat with us", optionID: 6, optionImage: "")]
//        }
        return [MyAccountModel(optionTitle: "About My Optimum", optionID: 4, optionImage: "")]
    }
}

class MyAccountViewController: CommonNavigationVC, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {
    
    //CMAIOS-93 show options on basis of userType
    var titlesArray = [MyAccountModel]()
    //Animation Properties
    let transition = MyAccountTransitionDelegate()
    var shiftID: String = ""
    var delegate: DismissingChildViewcontroller?
    var homeScreenWillAppear = false
    var dataRefreshRequiredAfterChat = false
    @IBOutlet weak var myAcctUserNameLbl: UILabel!
    @IBOutlet weak var animationHelperView: UIView!
    @IBOutlet weak var accntTableView: UITableView!
    @IBOutlet weak var closeBtnView: UIView!
    @IBOutlet weak var btnSignOut: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var closeBtnYConstraint: NSLayoutConstraint!
    @IBOutlet weak var dispayAccountNumberLbl: UILabel!
    var qualtricsAction : DispatchWorkItem?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTransition()
    }
    
    func setupTransition() {
        transitioningDelegate = transition
        modalPresentationStyle = .custom
    }
    
    func getTitleArray() {
        if MyWifiManager.shared.getWifiType() == "Gateway" {
            titlesArray = MyAccountModel.myAccountTitles
        } else {
            if MyWifiManager.shared.hasInternet() || MyWifiManager.shared.isTVOnlyService() {
                titlesArray = MyAccountModel.myAccountTitlesTVOnly
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initialSetupOrChatRefresh()
    }
    
    private func initialSetupOrChatRefresh() {
        self.removeLoaderView()
        if QuickPayManager.shared.dataRefreshNeedOnMyAccountAfterChat {
            self.addLoader()
            self.mauiGetAccountActivityRequest()
            self.animateCloseBtnView()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animateCloseBtnView()
            }
        }
    }
    
    func animateCloseBtnView(){
        UIView.animate(withDuration: 0.8) {
            self.closeBtnYConstraint.constant = -10
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTitleArray()
        let userName = PreferenceHandler.getValuesForKey("username") as? String
//        let accountNumber = QuickPayManager.shared.modelAccountsList?.accounts?.first?.legacy?.displayAccountNumber
        myAcctUserNameLbl.text = userName
        dispayAccountNumberLbl.text = QuickPayManager.shared.getAccountDisplayNumber()
        viewShiftAnimationSetUp()
        setupTransition()
        ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
        if MyWifiManager.shared.hasBillPay() {
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_MYACCOUNT_BILLING_MENU.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
        self.accntTableView.sectionFooterHeight = 0.0
        self.accntTableView.register(UINib(nibName: "MyAccountListMenuCell", bundle: nil), forCellReuseIdentifier: "listViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        removeLoaderView()
        //Present Account VC with FadeIn effect
        UIView.animate(withDuration: 0.8) {
            self.animationHelperView.alpha = 1.0
        } completion: { _ in
            //For Firebase Analytics
            DispatchQueue.main.async {
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : MyAccountScreenDetails.MY_ACCOUNT_HOME.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.General.rawValue])
                self.qualtricsAction = self.checkQualtrics(screenName: MyAccountScreenDetails.MY_ACCOUNT_HOME.rawValue, dispatchBlock: &self.qualtricsAction)
            }
        }
    }
    
    func viewShiftAnimationSetUp() {
        //Handle transition duration when the user taps the MyAccount Button
        view.shift.id = shiftID
        shift.baselineDuration = 0.2 //0.80
    }
    
    private func addLoader() {
        loadingView.isHidden = false
        loadingAnimationView.isHidden = false
        showODotAnimation()
    }
    
    private func removeLoaderView() {
        if !loadingView.isHidden {
            loadingView.isHidden = true
            loadingAnimationView.stop()
            loadingAnimationView.isHidden = true
        }
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
                    self.refreshViewAfterChat()
                } else {
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                    self.handleRefreshApiFailures()
                }
            }
        })
    }
    
    private func refreshViewAfterChat() {
        QuickPayManager.shared.clearModelAfterChatRefresh()
        QuickPayManager.shared.dataRefreshNeedOnMyAccountAfterChat = false
        self.removeLoaderView()
    }
    
    private func handleRefreshApiFailures() {
        QuickPayManager.shared.dataRefreshNeedOnMyAccountAfterChat = false
        self.removeLoaderView()
        self.showQuickAlertViewController(alertType: .plainErrorMessage)
    }
    
    private func showQuickAlertViewController(alertType: QuickPayAlertType, animated: Bool = true) {
        self.qualtricsAction?.cancel()
        guard let viewcontroller = QuickPayAlertViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.alertType = alertType
        viewcontroller.modalPresentationStyle = .fullScreen
        viewcontroller.navigationController?.isNavigationBarHidden = true
        viewcontroller.navigationItem.hidesBackButton = true
        self.present(viewcontroller, animated: animated)
    }
    
    @IBAction func chatWithUsBtnTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_MyAccount.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        QuickPayManager.shared.dataRefreshNeedOnMyAccountAfterChat = true
        UIView.animate(withDuration: 0.3) {
            self.animationHelperView.alpha = 0.0
        } completion: { complete in
            self.delegate?.pushChatVC(withIntentData: nil)
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func shareFeedbackBtnTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
        var urlComponents = URLComponents(string: ConfigService.shared.feedbackURL)
        urlComponents?.queryItems = getQueryParameters()
        self.loadInAppBrowser(urlComponents?.url)
    }
    
    private func getQueryParameters() -> [URLQueryItem] {
        let params: [String:String] = [
            "tenure" : QuickPayManager.shared.getCustomerTenure(),
            "service_bundle" : MyWifiManager.shared.getServiceBundle(),
            "equipment" : (MyWifiManager.shared.accessTech == "gpon") ? "Fiber" : "HFC",
            "app_version" : App.versionNumber(),
            "device_id" : PreferenceHandler.getValuesForKey("deviceId") as? String ?? ""
        ]
        let queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        return queryItems
    }
    
    //MARK: UITableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //CMAIOS-93 //Manage UITableViewHeight on basis of available options
        tableViewHeight.constant = tableView.rowHeight * CGFloat(titlesArray.count)
        return titlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = titlesArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "listViewCell") as! MyAccountListMenuCell
        cell.listMenuLabel.text = model.optionTitle
        cell.listMenuLabel.font = UIFont(name: "Regular-Medium", size: 18)
        cell.listMenuLabel.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        if indexPath.row == titlesArray.count - 1 {
            cell.saperatorLine.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.qualtricsAction?.cancel()
        let model = titlesArray[indexPath.row]
        
        switch model.optionID ?? 0 {
            
        case 1:
             navigateToManageMyHousehold(householdProfilesExists: checkHasHouseHoldProfiles())
        case 2:
            //Firebase Analytics
            /*CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : MyAccountScreenDetails.MY_ACCOUNT_INSTALL_AN_EXTENDER.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])*/
            Logger.info("Removed Install Extender CMA-1393")
            
        case 4:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let billVC = storyboard.instantiateViewController(withIdentifier: "aboutMyOptimumViewController") as? AboutMyOptimumViewController {
                billVC.modalPresentationStyle = .fullScreen
                self.present(billVC, animated: true, completion: nil)
            }
//        case 5:
//            var shareURL = ConfigService.shared.feedbackURL
//            if let deviceId = PreferenceHandler.getValuesForKey("deviceId") as? String, !deviceId.isEmpty {
//                shareURL += "?device_id=" + deviceId
//            }
//            self.loadInAppBrowser(shareURL)
//        case 6:
//            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_MyAccount.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
//            QuickPayManager.shared.dataRefreshNeedOnMyAccountAfterChat = true
//            UIView.animate(withDuration: 0.3) {
//                self.animationHelperView.alpha = 0.0
//            } completion: { complete in
//                self.delegate?.pushChatVC(withIntentData: nil)
//                self.dismiss(animated: false)
//            }
        default: Logger.info("no case")
        }
    }
    
    //CMAIOS-1366
    func loadInAppBrowser(_ url:URL?) {

            let safariVC = SFSafariViewController(url: url!)
            safariVC.delegate = self
            self.present(safariVC, animated: true, completion:nil)
    }
    
    func billingNavigation() {
        if QuickPayManager.shared.isReAuthenticationRequired() { // CMAIOS-1480
            QuickPayManager.shared.reAuthOnTimeExpiry(category: .billingMenu)
        } else {
        }
    }
    
    
    private func navigateToBillingVc(iserror: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let aboutVC = storyboard.instantiateViewController(withIdentifier: "billingViewController") as? BillingViewContrller  {
            if iserror {
                aboutVC.isError = true
            }
//            aboutVC.modalPresentationStyle = .fullScreen
//            self.present(aboutVC, animated: true, completion: nil)
            let navVC = UINavigationController(rootViewController: aboutVC)
            navVC.modalPresentationStyle = .fullScreen
            navVC.setNavigationBarHidden(true, animated: false)
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    private func  navigatetoQuickPayViewController() {
    }
    
    private func showODotAnimation() {
        loadingAnimationView.animation = LottieAnimation.named("O_dot_loader")
        loadingAnimationView.backgroundColor = .clear
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.play()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.animationHelperView.isHidden = false
        self.homeScreenWillAppear = true
        //Dismiss AccountVC with fadeOut effect
        UIView.animate(withDuration: 0.4) {
            self.animationHelperView.alpha = 0.0
        } completion: { complete in
            self.dismiss(animated: true)
            let appDel = UIApplication.shared.delegate as? AppDelegate
            appDel?.acccountVC = nil
        }
        UIView.animate(withDuration: 0.3) {
            self.closeBtnYConstraint.constant = 40
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func signoutClicked(_ sender: UIButton) {
        self.qualtricsAction?.cancel()
        APIRequests.shared.isAccountSignedOut = true
        APIRequests.shared.initiateLogoutRequest() { success, response, error in
            self.removeSavedPrefernces()
            Logger.info("", shouldLogContext: success)
//            if success {
                DispatchQueue.main.async {
                    RequestBuilder.cancelAllRequests()
                    self.dismiss(animated: false) {
                        // self.navigationController?.popToRootViewController(animated: true)
                        let keyWindow = UIApplication
                            .shared
                            .connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .flatMap { $0.windows }
                            .first { $0.isKeyWindow }
                        
                        if let navVC = keyWindow?.rootViewController as? UINavigationController {
                            let viewControllers = navVC.viewControllers
                            for vc in viewControllers {
                                if vc.isKind(of: LoginViewController.classForCoder()) {
                                    let viewController = vc as! LoginViewController
                                    if viewController.usernameTextField != nil {
                                        viewController.usernameTextField.text = ""
                                    }
                                    if viewController.savedUserNameTextField != nil {
                                        viewController.savedUserNameTextField?.text = ""
                                    }
                                    viewController.isMauiReAuth = false
                                    viewController.configureUI()
                                    break
                                }
                            }
                            navVC.popToRootViewController(animated: true)
                        }
                    }
                }
//            }
        }
    }
    
    private func removeSavedPrefernces() {
        LoginPreferenceManager.sharedInstance.removeLoginPreferences()
        MyWifiManager.shared.removeWifiConfigValuesForSignOut()
        ProfileManager.shared.clearDataOnLogout()
        SpotLightsManager.shared.clearData()
        ExtenderDataManager.shared.clearData()
        PreferenceHandler.removeDataForKey("DeadZoneDate")
        PreferenceHandler.removeDataForKey("extenderSuppressData")
        QuickPayManager.shared.clearSharedData()
        PreferenceHandler.removeCacheZipIcons()
        QualtricsManager.shared.clearQualtricsPopCount()
        AppCheckTokenManager.shared.clearTokens()
        CustomGAdLoader.shared.resetValues()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //show fadeIn effect on HomeVC when the user dismiss AccountVC
        if homeScreenWillAppear {
            delegate?.childViewcontrollerGettingDismissed()
        }
        self.qualtricsAction?.cancel()
    }
    
    func handleApiErrorCode() {
        QuickPayManager.shared.dataRefreshNeedOnMyAccountAfterChat = false
        self.removeLoaderView()
    }
    
}


//MARK: Animation Extension
class MyAccountTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return MyAccountPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionDismissing()
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionPresenting()
    }
}

class MyAccountPresentationController: UIPresentationController {
    let width = CGFloat(275)
    let height = CGFloat(263)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            x: 0,//containerView.frame.width - 20 - width,
            y: 0,//containerView.frame.height - 20 - height,
            width: containerView.frame.width,//width,
            height: containerView.frame.height
        )
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: width, height: height)
    }
}


// MARK: ReAuth Refresh
extension MyAccountViewController {
    func refreshAfterReAuthOnTimeExpiry() {
    }
}

