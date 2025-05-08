//
//  QuickPayViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 11/22/22.
//

import UIKit
import Lottie
import Alamofire
import ASAPPSDK

class QuickPayViewController: UIViewController {
    @IBOutlet var bottomCardConstraint: NSLayoutConstraint!
    @IBOutlet var bottomCard: UIView!
    @IBOutlet weak var centerStack: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet weak var dueCreditAppliedLabel: UILabel!
    @IBOutlet var cardNameLabel: UILabel!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var cardStack: UIStackView!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    @IBOutlet var editAction: UIButton!
    @IBOutlet var smileImage: UIImageView!
    @IBOutlet var okayButton: UIButton!
    @IBOutlet var PastDueWarningStack: UIStackView!
    @IBOutlet var blockedStack: UIStackView!
    @IBOutlet var sorryLabel: UILabel!
    @IBOutlet var callUsLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var creditTitleLabel: UILabel!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var payNowAnimation: LottieAnimationView!
    @IBOutlet weak var payNowView: UIView!
    @IBOutlet weak var cardExpiredView: UIView!
    @IBOutlet weak var centerStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var amountStackView: UIStackView!
    @IBOutlet weak var viewBillView: UIControl!
    @IBOutlet var viewBillLabel: UILabel!
    @IBOutlet weak var stackVwBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatButtonControl: UIControl!

    let sharedMananger = QuickPayManager.shared
    var state: State = .normal
    let transition = QuickPayTransitionDelegate()
    var shiftID:String = ""
    var shouldAnimate: Bool = true
    var signInIsProgress = false
    var delegate: DismissingChildViewcontroller?
    var isFromSpotlightCards = false
    var paymentJson: [String: AnyObject]?
    var homeScreenWillAppear = false
    var rePositioningRequired = false
    var failureAlertShown = false
    var isViewAlreadyLoaded = false
    var bottomCardMinY: CGFloat = 0.0
    var dataRefreshRequiredAfterChat: (Bool, Bool) = (false, false)

    var payMethod: PayMethod? {
        didSet {
//            if QuickPayManager.shared.initialScreenFlow != .noDue, payMethod?.creditCardPayMethod?.isCardExpired == true {
////                state = .expireDateError(isExpired: payMethod?.creditCardPayMethod?.isCardExpired == true)
//            } else {
//                updateState()
//            }
            updateState()
            refreshView()
            self.updateAnalyitcsEvents(event: self.getAnalyitcsEvents())
        }
    }
    
    //Pull to refresh
    @IBOutlet weak var vwPullToRefresh: UIView!
    @IBOutlet weak var vwPullToRefreshCircle: UIView!
    @IBOutlet weak var vwPullToRefreshAnimation: LottieAnimationView!
    @IBOutlet weak var vwPullToRefreshTop: NSLayoutConstraint!
    @IBOutlet weak var vwPullToRefreshHeight: NSLayoutConstraint!
    @IBOutlet var okayButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabelTopConstraint: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    let swipeDownGestureRecognizer = UISwipeGestureRecognizer()

    private func addLoader() {
        loadingView.backgroundColor = .systemBackground
        loadingView.isHidden = false
        loadingAnimationView.isHidden = false
        showODotAnimation()
    }
    
    /// Reload the Landing after Re-Auth
    func refreshViewOnReAuth() {
        QuickPayManager.shared.delegate = self
        initialViewDataSetup()
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
        //        DispatchQueue.main.async {
        if !self.loadingView.isHidden {
            self.loadingView.isHidden = true
            self.loadingAnimationView.stop()
            self.loadingAnimationView.isHidden = true
        }
        //        }
    }
    
    // MARK: - MAUI APIs
    func mauiGetAccountActivityRequest() {
        var params = [String: AnyObject]()
        params["name"] = sharedMananger.getAccountNam() as AnyObject?
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
        params["name"] = sharedMananger.getAccountNam() as AnyObject?
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
        params["name"] = sharedMananger.getAccountNam() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: sharedMananger.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
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
        QuickPayManager.shared.clearModelAfterChatRefresh()
        self.dataRefreshRequiredAfterChat = (false, false)
        self.removeLoaderView()
        QuickPayManager.shared.initialScreenType()
        updateState()
        refreshView()
        self.updateAnalyitcsEvents(event: self.getAnalyitcsEvents())
    }
    
    private func handleRefreshApiFailures() {
        self.dataRefreshRequiredAfterChat.0 = false
        self.removeLoaderView()
        self.showQuickAlertViewController(alertType: .systemUnavailable)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        setupTransition()
    }
    
    func setupTransition() {
        transitioningDelegate = transition
        modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUIConstantsForPullToRefresh()
        //        initiatePullToRefresh()
        QuickPayManager.shared.delegate = self
        shouldAnimate = true
        self.fullViewAnimationSetup()
        self.initialUiColorSetupForAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func fullViewAnimationSetup() {
        view.shift.id = shiftID
        shift.baselineDuration = 0.2 //0.80
    }
    
    /// Hide the UI compoenents while screen transition animation
    /// Setup the background color according to the screen type to sync with animation
    private func initialUiColorSetupForAnimation() {
        changeSubviews(alpha: 0)
        QuickPayManager.shared.initialScreenType()
        switch QuickPayManager.shared.initialScreenFlow {
        case .manualBlock, .pastDue:
            view.backgroundColor = UIColor(red: 11/255, green: 41/255, blue: 96/255, alpha: 1)
            loadingView.backgroundColor = UIColor(red: 11/255, green: 41/255, blue: 96/255, alpha: 1)
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         self.initialViewSetup()
         */
        self.initialSetupOrChatRefresh()
    }
    
    private func initialSetupOrChatRefresh() {
        self.dueDateLabel.setLineHeight(1.04)
        self.dueDateLabel.textAlignment = .center
        if !dataRefreshRequiredAfterChat.0 {
            self.dueDateLabel.setLineHeight(1.04)
            self.dueDateLabel.textAlignment = .center
            if sharedMananger.dataAvailableToSkipLoader() {
                if self.isViewAlreadyLoaded {
                    self.configureUiWithData()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.configureUiWithData()
                    }
                }
            } else {
                self.initialLoaderStateDetermination()
            }
        } else {
            self.addLoader()
            self.mauiGetAccountActivityRequest()
        }
    }
    
    private func initialLoaderStateDetermination() {
        guard QuickPayManager.shared.ismauiMainApiInProgress.isprogress else {
            if QuickPayManager.shared.ismauiMainApiInProgress.iserror {
                self.checkAndShowErrorScreen()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.configureUiWithData()
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.configureUiWithData()
                    }
                }
            }
        }
    }
    
    private func checkAndShowErrorScreen() {
        self.removeLoaderView()
        self.changeSubviews(alpha: 0)
        if !failureAlertShown { // Check to remove re-occurence
            failureAlertShown = true
            self.showQuickAlertViewController(alertType: .systemUnavailable, animated: false)
        }
    }
    
    private func initialViewSetup() {
        if APIRequests.shared.isGetAccountBillApiFailed {
            changeSubviews(alpha: 0)
            if !failureAlertShown { // Check to remove re-occurence
                failureAlertShown = true
                self.showQuickAlertViewController(alertType: .systemUnavailable, animated: false)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.configureUiWithData()
            }
        }
        /*
         self.bottomCardMinY = bottomCard.frame.minY
         guard QuickPayManager.shared.ismauiMainApiInProgress.isprogress else {
         if QuickPayManager.shared.ismauiMainApiInProgress.iserror {
         self.removeLoaderView()
         self.showQuickAlertViewController(alertType: .systemUnavailable)
         } else {
         DispatchQueue.main.async {
         self.configureUiWithData()
         }
         }
         return
         }
         addLoader()
         QuickPayManager.shared.ismauiMainApiInProgressLoader = {[weak self] in
         if QuickPayManager.shared.ismauiMainApiInProgress.isprogress {
         self?.addLoader()
         } else {
         if QuickPayManager.shared.ismauiMainApiInProgress.iserror {
         self?.removeLoaderView()
         self?.showQuickAlertViewController(alertType: .systemUnavailable)
         } else {
         DispatchQueue.main.async {
         self?.configureUiWithData()
         }
         }
         }
         */
    }
    
    func viewShiftAnimationSetUp() {
        //Handle transition duration when the user taps the Quick Pay Button
        view.shift.id = shiftID
        shift.baselineDuration = 0.2 //0.80
        changeSubviews(alpha: 0)
        bottomCardConstraint.constant = -(bottomCard.bounds.size.height)
    }
    
    //MARK: LiveTopologyAPI response methods
 
//    @objc func lightSpeedAPICallBack() {
//        self.pullToRefresh(hideScreen: true)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
//    }
    //MARK: PullToRefresh methods
    ///Method for pull to refresh during swipe.
//    func initiatePullToRefresh() {
//        swipeDownGestureRecognizer.direction = .down
//        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
//        self.view?.addGestureRecognizer(swipeDownGestureRecognizer)
////        vwPullToRefreshCircle
//    }
    
    ///Method for initial constants in pull to refresh animation
    func initialUIConstantsForPullToRefresh(){
        self.vwPullToRefresh.isHidden = true
        vwPullToRefreshCircle.isHidden = true
        self.vwPullToRefreshHeight.constant = 0
        self.vwPullToRefreshCircle.layer.cornerRadius = self.vwPullToRefreshCircle.bounds.height / 2
    }
    
    ///Method for pull to refresh animation
//    @objc func pullToRefresh(hideScreen hide:Bool) {
//        vwPullToRefresh.isHidden = false
//        vwPullToRefreshCircle.isHidden = false
//        self.vwPullToRefreshAnimation.isHidden = false
//        self.vwPullToRefreshAnimation.animation = LottieAnimation.named("AutoLogin")
//        self.vwPullToRefreshAnimation.backgroundColor = .clear
//        self.vwPullToRefreshAnimation.loopMode = .loop
//        self.vwPullToRefreshAnimation.animationSpeed = 1.0
//        if !hide {
//            self.handleUserInteractionOnPullToRefresh(isAllowed: false)
//            UIView.animate(withDuration: 0.5) {
//                self.isPullToRefresh = true
//                self.vwPullToRefreshTop.constant = currentScreenWidth > 390.0 ? 40 : 60
//                self.vwPullToRefreshHeight.constant = 130
//                self.vwPullToRefreshAnimation.play()
//                self.handleUIForSmallerAndLargerDevices()
//                self.view.layoutIfNeeded()
//                self.didPullToRefresh()
//            }
//        } else {
//            self.handleUserInteractionOnPullToRefresh(isAllowed: true)
//            UIView.animate(withDuration: 0.5) {
//                self.isPullToRefresh = false
//                self.vwPullToRefreshAnimation.stop()
//                self.vwPullToRefreshAnimation.isHidden = true
//                self.vwPullToRefreshTop.constant = 80
//                self.vwPullToRefreshHeight.constant = 0
//                self.handleUIForSmallerAndLargerDevices()
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
    
    ///Method for enable/Disable user interaction
    func handleUserInteractionOnPullToRefresh(isAllowed: Bool) {
        self.okayButton.isUserInteractionEnabled = isAllowed
        self.bottomCard.isUserInteractionEnabled = isAllowed
    }
    ///Method for pull to refresh api call
//    func didPullToRefresh() {
//        // After Refresh
//        if MyWifiManager.shared.accountsNetworkPoints != nil {
//            NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBack), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
//            MyWifiManager.shared.triggerOperationalStatus()
//        } else {
//            // If Map is nil in Accounts API reponse, LightSpeed API shouldn't be triggered
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.pullToRefresh(hideScreen: true)
//            }
//        }
//    }
    
    func handleUIForSmallerAndLargerDevices() {
        self.view.frame.origin.y = isPullToRefresh ? 10 : 0
        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
            self.titleLabelTopConstraint.constant = isPullToRefresh ? self.titleLabelTopConstraint.constant + 70 : 20
        } else {
            self.titleLabelTopConstraint.constant = isPullToRefresh ? self.titleLabelTopConstraint.constant + 50 : 20
            if okayButton.isHidden {
                self.bottomCardConstraint.constant = isPullToRefresh ? -40 : -20
            } else {
                self.okayButtonBottomConstraint.constant = isPullToRefresh ? -50 : 0
            }
        }
        //For iPod
        if currentScreenWidth < xibDesignWidth {
            if okayButton.isHidden {
                self.bottomCardConstraint.constant = isPullToRefresh ? -80 : -20
            } else {
                self.okayButtonBottomConstraint.constant = isPullToRefresh ? -100 : 0
            }
        }
    }
    
    func configureUI() {
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        secondaryAction.isHidden = true
        primaryAction.setTitle("Pay now", for: .normal)
        view.backgroundColor = UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0)
        smileImage.isHidden = true
        okayButton.isHidden = true
        blockedStack.isHidden = true
        chatButtonControl.isHidden = true
        PastDueWarningStack.isHidden = true
        creditTitleLabel.isHidden = true
        dueCreditAppliedLabel.isHidden = true
        dueCreditAppliedLabel.text = "Includes any payments or credits\n" + "since your last bill"
        editAction.isHidden = false
        cardExpiredView.isHidden = true
        amountStackView.spacing = 15.0
        self.stackVwBottomConstraint.constant = UIDevice.current.hasNotch ? 52: 40
        switch state {
        case .defaultDisclaimer:
            smileImage.isHidden = true
            okayButton.isHidden = true
            PastDueWarningStack.isHidden = true
            blockedStack.isHidden = true
            chatButtonControl.isHidden = true
            dueCreditAppliedLabel.isHidden = false
        case .expireDateError:
            /*
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            primaryAction.setTitle("Update expiration date", for: .normal)
            secondaryAction.isHidden = false
            smileImage.isHidden = true
            view.backgroundColor = UIColor(red: 11/255, green: 41/255, blue: 96/255, alpha: 1)
            cardImage.image = UIImage(named: "payment-error")
            editAction.isHidden = true
            okayButton.isHidden = true
            checkmarkAction.isHidden = true
            useThisDefaultPaymentLabel.isHidden = true
            PastDueWarningStack.isHidden = true
            blockedStack.isHidden = true
            dueCreditAppliedLabel.isHidden = false
            */
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            dueDateLabel.text = "Due " + QuickPayManager.shared.getDueDate()
            dueCreditAppliedLabel.isHidden = false
            cardExpiredView.isHidden = false
            cardExpiredView.viewBorderAttributes(UIColor.systemRed.cgColor, 1, 8)
        case .dueCreditApplied:
            amountLabel.text = "-$" + QuickPayManager.shared.getCurrentAmount().replceCharecter(charcter: "-")
            dueDateLabel.text = "Next bill due is\n" + QuickPayManager.shared.getDueDate()
            dueDateLabel.textAlignment = .center
            okayButton.isHidden = false
            okayButtonBottomConstraint.constant = UIDevice.current.hasNotch ? 10 : -10
            creditTitleLabel.isHidden = false
            PastDueWarningStack.isHidden = true
            blockedStack.isHidden = true
            chatButtonControl.isHidden = true
            bottomCard.isHidden = true
            dueCreditAppliedLabel.isHidden = false
        case .noDue:
//            NSLayoutConstraint(item: centerStack, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.7, constant: 0).isActive = true
            amountStackView.spacing = 20.0
//            okayButton.setTitle("Okay", for: .normal)
            amountLabel.text = "No payment is due at this time"
            amountLabel.numberOfLines = 0
            amountLabel.textAlignment = .center
            amountLabel.font = UIFont(name: "Regular-Bold", size: 38)
            dueDateLabel.isHidden = true // CMA-171
            bottomCard.isHidden = true
            smileImage.isHidden = false
            okayButton.isHidden = false
            okayButtonBottomConstraint.constant = UIDevice.current.hasNotch ? 10 : -10
            blockedStack.isHidden = true
            chatButtonControl.isHidden = true
            PastDueWarningStack.isHidden = true
            viewBillView.isHidden = false
            viewBillLabel.text = "View my last bill"
        case .pastDue:
            view.backgroundColor = UIColor(red: 11/255, green: 41/255, blue: 96/255, alpha: 1)
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            pastDueUiConfig()
            primaryAction.isHidden = false
            cardStack.isHidden = false
            checkAndUpdateCardExpiredUI()
        case .normal:
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            dueDateLabel.text = "Due " + QuickPayManager.shared.getDueDate()
            dueCreditAppliedLabel.isHidden = true
            viewBillView.isHidden = false
            viewBillLabel.text = "View my bill"
            primaryAction.isHidden = false
            cardStack.isHidden = false
            checkAndUpdateCardExpiredUI()
        case .autoPay:
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            if QuickPayManager.shared.getAutoPayScheduleDate() == "" {
                dueDateLabel.text = "Due " + QuickPayManager.shared.getDueDate()
            }
            else {
                dueDateLabel.text = "Auto Pay set for" + "\n" + QuickPayManager.shared.getAutoPayScheduleDate()
            }
            dueCreditAppliedLabel.isHidden = true
            viewBillView.isHidden = false
            viewBillLabel.text = "View my bill"
            primaryAction.isHidden = false
            cardStack.isHidden = false
            checkAndUpdateCardExpiredUI()
        case .manualBlock:
            view.backgroundColor = UIColor(red: 11/255, green: 41/255, blue: 96/255, alpha: 1)
            blockedStack.isHidden = false
            chatButtonControl.isHidden = false
            cardStack.isHidden = true
            dueCreditAppliedLabel.isHidden = true
            dueDateLabel.text = "Due " + QuickPayManager.shared.getDueDate()
            amountLabel.text = "$" + QuickPayManager.shared.getCurrentAmount()
            viewBillLabel.text = "View my bill" // CMAIOS-1567
            manualBlockUiConfig()
        }
        self.updateLineHeight()
        self.centerAmountStack()
    }
    
    private func centerAmountStack() {
        guard !rePositioningRequired else {
            return
        }
        rePositioningRequired = true
        var originsPadding = bottomCardMinY - titleStackView.frame.maxY
        if state == .noDue {
            originsPadding = okayButton.frame.minY - titleStackView.frame.maxY
        }
        let amountContentHeight = centerStack.frame.height
        let padding = (originsPadding - amountContentHeight) / 2
        if padding > 0 {
            centerStackTopConstraint.constant = (state == .noDue) ? padding * 0.7: padding
        }
    }
    
    private func updateLineHeight() {
        switch state {
        case .defaultDisclaimer, .expireDateError, .dueCreditApplied, .manualBlock: break
        case .noDue:
            self.amountLabel.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
            self.amountLabel.textAlignment = .center
        case .pastDue, .normal:
            self.dueDateLabel.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
            self.dueDateLabel.textAlignment = .center
        case .autoPay:
            if QuickPayManager.shared.getAutoPayScheduleDate() != "" {
                self.dueDateLabel.setLineHeight(CurrentDevice.isLargeScreenDevice() ? 1.21: 1.15)
                self.dueDateLabel.textAlignment = .center
            }
        }
    }
    
    /// Set initial Paymethod
    private func setPayMethod() {
        let payMethodInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
//        if case let .expireDateError(isExpired) = state {
//            if !isExpired {
//                cardNameLabel.text = payMethodInfo.1 + " is about expire"
//            } else {
//                cardNameLabel.text = "Your \(payMethodInfo.1) has expired"
//            }
//            return
//        }
        if payMethodInfo.2 != "" {
            cardImage.image = UIImage(named: payMethodInfo.2)
        }
        cardNameLabel.text = payMethodInfo.1
        // Truncate middle if text length exceeds 24
        /*
         if let labelString = cardNameLabel.text, labelString.count > 24 {
         let prefix = labelString.getTrimmedString(isPrefix: true, length: 12)
         let suffix = labelString.getTrimmedString(isPrefix: false, length: 12)
         let parsedString = prefix + suffix
         let cardName = NSMutableString(string: parsedString)
         cardName.insert("...", at: 11)
         cardNameLabel.attributedText = NSAttributedString(string: cardName as String)
         }
         */
        if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
            editAction.isHidden = true
        }
    }
    
    private func checkAndUpdateCardExpiredUI() {
        if isPaymentCardExpired() {
            cardExpiredView.isHidden = false
            cardExpiredView.viewBorderAttributes(UIColor.systemRed.cgColor, 1, 8)
        }
    }
    
    private func isPaymentCardExpired() -> Bool {
        if let paymethod = self.payMethod, paymethod.creditCardPayMethod?.isCardExpired == true {
            return true
        }
        return false
    }
    
    func changeSubviews(alpha: CGFloat) {
        [titleLabel, okayButton, PastDueWarningStack, amountLabel.superview, dueDateLabel.superview, viewBillView].forEach { subview in
            subview?.alpha = alpha
        }
    }
    
    private func manualBlockUiConfig() {
//        if CommonUtility.deviceHasPhoneCallFeature(phoneNumber: QuickPayViewConstants.phoneNumber) {
//            primaryAction.setTitle("Call now", for: .normal)
//        } else {
//            let descriptionText = "Call us at " + QuickPayViewConstants.phoneNumber + " to make a payment."
//            callUsLabel.attributedText = descriptionText.attributedString(with: [.font: UIFont(name: "Regular-Regular", size: 18) as Any], and: QuickPayViewConstants.phoneNumber, with: [.font: UIFont(name: "Regular-Bold", size: 18) as Any])
//            primaryAction.isHidden = true
//        }
        primaryAction.isHidden = true
        updateChatButtonStyle()
    }
    
    private func pastDueUiConfig() {
        switch sharedMananger.getDeAuthState() {
        /* CMAIOS-1254 */
        case "DE_AUTH_STATE_NONE", "DE_AUTH_STATE_PREDEAUTH":
            dueCreditAppliedLabel.isHidden = true
            PastDueWarningStack.isHidden = true
            dueDateLabel.isHidden = false
            viewBillView.isHidden = false
            viewBillLabel.text = "View my bill"
            
            if sharedMananger.getPastDueAmount() == sharedMananger.getCurrentAmount() {
                dueDateLabel.text = "Past due"
            } else {
//                dueCreditAppliedLabel.text  = "Includes " + "$" + sharedMananger.getPastDueAmount() + " past due"
//                dueCreditAppliedLabel.font = UIFont(name: "Regular-Bold", size: 18)
//                dueDateLabel.isHidden = true
                dueDateLabel.text  = "Includes " + "$" + sharedMananger.getPastDueAmount() + " past due"
                dueDateLabel.font = UIFont(name: "Regular-Bold", size: 18)
            }
            if sharedMananger.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
//                NSLayoutConstraint(item: centerStack as Any, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.6, constant: 0).isActive = true
                PastDueWarningStack.isHidden = false
            }
        default: break
        }
        /* CMAIOS-1254 */
    }
    
    private func updateChatButtonStyle() {
        self.chatButtonControl.layer.borderColor = buttonBorderLightGrayColor.cgColor
        self.chatButtonControl.layer.borderWidth = 2.0
        self.chatButtonControl.layer.cornerRadius = 15.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isViewAlreadyLoaded = true
        self.removeLoaderView()
        self.signInFailedAnimation()
        if QuickPayManager.shared.initialScreenFlow == .manualBlock { // CMAIOS-1567
            self.manualBlockUiConfig()
        }
        if self.homeScreenWillAppear {
            delegate?.childViewcontrollerGettingDismissed()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        animateSubviews(shouldShow: false) {
            self.closeOrDismiss()
        }
    }
    
    private func closeOrDismiss() {
        if  ((self.navigationController?.viewControllers.contains(self)) != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onTapSecondaryAction(_ sender: UIButton) {
        guard QuickPayManager.shared.getAllPayMethodMop().count <= 1 else {
            self.navigateChoosePayment()
            return
        }
        self.showAddCard()
    }
    
    private func navigateChoosePayment() {
        DispatchQueue.main.async {
            let transition = CATransition() //CMAIOS-1149
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            self.view.window?.layer.add(transition, forKey: kCATransition)
            guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
            vc.payMethod = self.payMethod
            vc.navigationStyle = .push
            vc.modalPresentationStyle = .fullScreen
            vc.payMethod = self.payMethod
            vc.selectionHandler = { [weak self] payMethod in
                self?.payMethod = payMethod
                self?.dismiss(animated: false)
            }
            self.present(vc, animated: false)
        }
    }
    
    func animateSubviews(shouldShow: Bool, completion: (() -> Void)? = nil) {
        if !shouldShow {
            homeScreenWillAppear = true
        }
        changeSubviews(alpha: shouldShow ? 0 : 1)
        bottomCardConstraint.constant = shouldShow ? -(self.bottomCard.bounds.size.height) : -20
        UIView.animate(withDuration: 0.6, animations: {
            self.titleLabel.alpha = shouldShow ? 1 : 0
            self.amountLabel.superview?.alpha = shouldShow ? 1 : 0
            self.okayButton.alpha = shouldShow ? 1 : 0
            self.PastDueWarningStack.alpha = shouldShow ? 1 : 0
            self.dueDateLabel.superview?.alpha = shouldShow ? 1 : 0
//            self.cardExpiredView.alpha = shouldShow ? 1 : 0
            self.viewBillView.alpha = shouldShow ? 1 : 0
        }, completion: { finished in
            self.bottomCardConstraint.constant = shouldShow ? -20 : -(self.bottomCard.bounds.size.height)
            UIView.animate(withDuration: 0.5, animations: {
//                self.primaryAction.superview?.alpha = shouldShow ? 1 : 0
                self.view.layoutIfNeeded()
            }, completion: { finished in
                completion?()
            })
        })
    }
        
    @IBAction func primaryButtonTapped(_ sender: RoundedButton) {
        switch state {
        case .defaultDisclaimer:
            self.navigateToFinishSetup()
        case .expireDateError:
            self.navigateToExpiration()
        case .pastDue:
            commonPayNowAction(isAutopay: false)
        case .noDue, .dueCreditApplied:
            animateSubviews(shouldShow: false) {
//                self.dismiss(animated: true)
                self.closeOrDismiss()
            }
        case .manualBlock:
            CommonUtility.doPhoneCall(phoneNumber: QuickPayViewConstants.phoneNumber)
        case .autoPay:
            commonPayNowAction(isAutopay: true)
        case .normal:
            commonPayNowAction(isAutopay: false)
        }
    }
    
    private func commonPayNowAction(isAutopay: Bool) {
        if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
            self.showAddCard()
        } else {
            DoImmediatePayment(isAutoPay: isAutopay) // Uncomment to validate actual payment scenario
            //                self.showThanksPayment(paymentState: .normal, isAutoPay: false) // Uncomment to validate actual payment scenario
        }
    }
    
    @IBAction func actionEditMop(_ sender: Any) {
        guard QuickPayManager.shared.getAllPayMethodMop().count < 1 else {
            navigateChoosePayment()
            return
        }
        self.showAddCard()
    }
    
    @IBAction func actionCardExpiredLink(_ sender: Any) {
        // CMAIOS-1048
//        self.navigateToExpiration()
    }
    
    @IBAction func actionChatWithUs(_ sender: Any) {
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Quickpay_Online_Payment_Manual_Blocked.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        let intentData = IntentsManager.sharedInstance.getIntentcodeAndDescription(screenFlow: ContactUsScreenFlowTypes.manualBlock)
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: intentData) else {
            return
        }
        self.dataRefreshRequiredAfterChat.0 = true
        chatViewController.modalPresentationStyle = .fullScreen
        self.trackAndNavigateToChat(chatVC: chatViewController)
    }
    
    private func navigateToFinishSetup() {
        guard let vc = UINavigationController.instantiate(from: .payments, identifier: "FinishSetupNavigation") else { return }
        self.present(vc, animated: true)
    }
    
    private func navigateToExpiration() {
        guard let vc = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
        vc.payMethod = payMethod
        vc.flow = .quickPay
        vc.modalPresentationStyle = .fullScreen
        vc.successHandler = { [weak self] payMethod in
            self?.payMethod = payMethod
            self?.dismiss(animated: true)
        }
        self.present(vc, animated: true)
    }
    
    private func showAddCard() {
        guard let navigationController = UINavigationController.instantiate(from: .payments, identifier: "FinishSetupNavigation") else { return }
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
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
            thanksViewController.isAutoPayFlow = isAutoPay
            let aNavigationController = UINavigationController(rootViewController: thanksViewController)
            aNavigationController.modalPresentationStyle = .fullScreen
            if self.navigationController != nil {
                aNavigationController.navigationBar.isHidden = true
            }
            self.present(aNavigationController, animated: true)
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
    
    /// Get the ScreenType to Configure UI
    private func setScreenType() {
        updateState()
        if payMethod == nil {
            payMethod = QuickPayManager.shared.getDefaultPayMethod()
        }
        guard shouldAnimate else { return }
        self.bottomCardMinY = bottomCard.frame.minY
        viewShiftAnimationSetUp()
        animateSubviews(shouldShow: true) {
            self.shouldAnimate = false
        }
    }
    
    private func updateState() {
        state = QuickPayManager.shared.getInitialScreenFlowState()
    }
    
    private func refreshView() {
        DispatchQueue.main.async {
            self.configureUI()
            self.setPayMethod()
        }
    }
     
    private func initialViewDataSetup() {
        DispatchQueue.main.async {
            self.addLoader()
            if self.sharedMananger.getAccountName() == "" {
                self.sharedMananger.accountsListRequest()
            } else {
                self.configureUiWithData()
            }
        }
    }
    
    private func configureUiWithData() {
        removeLoaderView()
        QuickPayManager.shared.initialScreenType()
        setScreenType()
    }
        
    // MARK: - SignIn Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.payNowAnimation.isHidden = true
        self.primaryAction.isHidden = true
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
        self.primaryAction.alpha = 0.0
        self.primaryAction.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.primaryAction.alpha = 1.0
        }
    }
    
    @IBAction func viewBillTap(_ sender: Any) {
        /*
         guard let dict = QuickPayManager.shared.modelQuickPayListBill?.billSummaryList?.first,
         let name = dict.name, let dueDate = dict.billDueDate?.components(separatedBy: "T").first else {
         return
         }
         QuickPayManager.shared.downloadBillPdf(name: name, fileName: dueDate) { success in
         if success {
         DispatchQueue.main.async {
         guard let vc = BillPDFViewController.instantiateWithIdentifier(from: .payments) else { return }
         vc.fileName = dueDate
         vc.modalPresentationStyle = .fullScreen
         self.present(vc, animated: true)
         }
         }
         }
         */
        self.trackOnClickEvent()
        self.validateViewMyBillTapForNavigation()
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
                        EVENT_SCREEN_NAME: self.getAnalyitcsEvents(),
                       EVENT_SCREEN_CLASS: self.classNameFromInstance]
        )
    }
    
    private func validateViewMyBillTapForNavigation() {
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
                viewcontroller.pdfType = .viewBill
                let navigationController = UINavigationController(rootViewController: viewcontroller)
                navigationController.setNavigationBarHidden(true, animated: true)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - MAUI API delegates
extension QuickPayViewController: MauiApisStatusDelegate {
    func sequenceApiStatus(isCompleted: Bool) {
    }
    func apiRequestSuccess(type: ApiType) {
        switch type {
        case .accountList:
            QuickPayManager.shared.mauiGetAccountBillRequest()
        case .paymethodList: break
        case .listBills, .getBill: break
        case .getBillAccount:
            QuickPayManager.shared.mauiGetAccountActivityRequest()
        case .getBillActivity:
//            QuickPayManager.shared.mauiGetAutoPay()
            configureUiWithData()
        case .getCommunicationPreference, .createPayment, .updateCommunicationPreference: break
        case .getAutoPay, .setDefaultPayment, .nextPaymentDue: break
//            configureUiWithData()
        default: break
        }
    }
    func apiRequestFailure(type: ApiType) {
        removeLoaderView()
        switch type {
        case .paymethodList, .accountList, .getBillAccount:
            DispatchQueue.main.async {
                self.showQuickAlertViewController(alertType: .systemUnavailable)
            }
        case .getBillActivity:
            configureUiWithData()
        case .listBills, .getBill, .nextPaymentDue, .getAutoPay: break
        case .getCommunicationPreference, .createPayment, .updateCommunicationPreference, .setDefaultPayment: break
        default: break
        }
    }
}

extension QuickPayViewController {
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
        QuickPayManager.shared.mauiImmediatePayment(jsonParams: jsonParams, makeDefault: !isDefaultPaymentMethod(), completionHanlder: { isSuccess, errorDec, error in
            if isSuccess {
                self.signInIsProgress = false
                self.payNowAnimation.pause()
                self.payNowAnimation.play(fromProgress: self.payNowAnimation.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    let thanksPaymentState = isAutoPay == true ? ThanksPaymentState.autoPay: ThanksPaymentState.normal
                    self.showThanksPayment(paymentState: thanksPaymentState, isAutoPay: isAutoPay)
                }
            } else {
                self.signInFailedAnimation()
                self.showQuickAlertViewController(alertType: .systemUnavailable)
            }
        })
    }
    
    /* Reference for Schedule payment API calls (Cancel, Update, Create(with existing paymethod)), Will be removed once integrated
    private func testCancelSchedulePayment() {
        let schduleId = "tenants/atus1/customers/1b1d65a8-ea0e-4099-b03e-97ebf5e38c60/accounts/30373830-3135-3837-3336-343031202020/payments/904791582"
        var jsonParams = [String: AnyObject]()
        jsonParams["name"] = schduleId as AnyObject?
        
        QuickPayManager.shared.mauiCancelScheduledPayment(jsonParams: jsonParams, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    print(QuickPayManager.shared.modelRemoveSchedulePayment as Any)
                } else {
                    print("Failed")
                }
            }
        })
    }
    
    private func testCreateSchedulePaymentWithExistingPaymethod() {
        let jsonparamm = self.generateJsonParamCreateSchedulePayment(isUpdate: false)
        QuickPayManager.shared.mauiSchedulePaymentWithExistingCard(jsonParams: jsonparamm, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    print(QuickPayManager.shared.modelSchedulePaymentCreate as Any)
                } else {
                    print("Failed")
                }
            }
        })
    }
    
    private func testUpdateSchedulePayment() {
        let jsonparamm = self.generateJsonParamCreateSchedulePayment(isUpdate: true)
        QuickPayManager.shared.mauiUpdateSchedulePayment(jsonParams: jsonparamm, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    print(QuickPayManager.shared.modelSchedulePaymentUpdate as Any)
                } else {
                    print("Failed")
                }
            }
        })
    }
    
    private func generateJsonParamCreateSchedulePayment(isUpdate: Bool) -> [String: AnyObject] {
        var jsonParams: [String: AnyObject] = [:]
        let payMethodName = isUpdate ?
        "tenants/atus1/customers/1b1d65a8-ea0e-4099-b03e-97ebf5e38c60/accounts/30373830-3135-3837-3336-343031202020/paymethods/Visa-9015" :
        "tenants/atus1/customers/1b1d65a8-ea0e-4099-b03e-97ebf5e38c60/accounts/30373830-3135-3837-3336-343031202020/paymethods/Visa-4604"
        let payMethod = PayMethodInfo(name: payMethodName)
        let payment = PaymentWithDate(payMethod: payMethod, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(0.04)), isImmediate: false, paymentDate: "2023-12-21T00:00:00Z")
        
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
    }
    */
    
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
    
    func handleErrorImmediatePayment() {
        if !self.loadingView.isHidden { // Handle homeview Maui api failures to remove the loader
            QuickPayManager.shared.ismauiMainApiInProgress = (false, true)
            if self.dataRefreshRequiredAfterChat.0 { // handling the Getactivity and Get bill API errors after chat refrersh
                self.showQuickAlertViewController(alertType: .systemUnavailable)
            }
            return
        }
        if !signInIsProgress { // Only proceed if immediate payment api triggered, signInIsProgress == true if API triggered
            return
        }
        self.signInFailedAnimation()
        
        var isAutoPay = false
        switch state {
        case .pastDue, .normal:
            isAutoPay = false
        case .autoPay:
            isAutoPay = true
        default: break
        }
        paymentFailureFlow(isAutoPay: isAutoPay)
    }
    
    private func generateJsonParam(isAutoPay: Bool) -> [String: AnyObject] {
        var jsonParams: [String: AnyObject] = [:]
        guard let payMethodName = payMethod?.name else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: payMethodName)
        let payment = Payment(payMethod: payMethod, paymentAmount: AmountInfo(currencyCode: "USD", amount: Double(QuickPayManager.shared.getCurrentAmount())), isImmediate: true)
        let createpayment = CreateImmediatePayment(parent: QuickPayManager.shared.getAccountNam(), payment: payment)
        
        do {
            let jsonData = try JSONEncoder().encode(createpayment)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    /// Check whether the selcted paymethod is default paymethod or not
    /// - Returns: default or not
    private func isDefaultPaymentMethod() -> Bool {
        var isDefault = false
        if payMethod?.name == QuickPayManager.shared.getDefaultPayMethod()?.name {
            isDefault = true
        }
        return isDefault
    }
    
    /// Get Default paymethod for immediate payment API call
    /// - Returns: make selected PayMethod as default paymethod
    private func getDefaultPaymentMethod() -> PayMethod? {
        var payMethodVal: PayMethod?
        if isDefaultPaymentMethod() {
            guard let payMeth = QuickPayManager.shared.getDefaultPayMethod() else {
                return payMethodVal
            }
            payMethodVal = payMeth
        } else {
            guard let payMeth = payMethod else {
                return payMethodVal
            }
            payMethodVal = payMeth
        }
        return payMethodVal
    }
}

// MARK: - Firebase analytics
extension QuickPayViewController {
    private func updateAnalyitcsEvents(event: String) {
        var eventParam: [String : String] = [EVENT_SCREEN_NAME: event,
                                            EVENT_SCREEN_CLASS: self.classNameFromInstance]
        let customParm = [CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue]
        if event == "" {
            return
        }
        if event == BillPayEvents.QUICKPAY_HOME_PAGE_PAYMENT_DUE.rawValue {
            if !sharedMananger.isAutoPayEnabled() {
                CMAAnalyticsManager.sharedInstance.trackAction(
                    eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_NO_AUTOPAY_ENABLED.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            } else {
                eventParam = eventParam.merging(customParm){ (current,_) in  current}
            }
        }
        if event == BillPayEvents.QUICKPAY_NO_AUTOPAY_DEFAULT_CARD_EXPIRED.rawValue || event == BillPayEvents.QUICKPAY_PAYMENT_PAST_DUE.rawValue || event == BillPayEvents.QUICKPAY_PAYMENT_PRE_DEAUTH.rawValue || event == BillPayEvents.QUICKPAY_ONLINE_PAYMENT_MANUAL_BLOCKED.rawValue {
            eventParam = eventParam.merging(customParm){ (current,_) in  current}
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: eventParam)
    }
    
    private func getAnalyitcsEvents() -> String {
        var event = ""
        switch state {
        case .defaultDisclaimer: break
        case .expireDateError: break
        case .dueCreditApplied: break
        case .noDue:
            event = BillPayEvents.QUICKPAY_NO_PAYMENT_DUE.rawValue
        case .pastDue:
            if sharedMananger.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
                event = BillPayEvents.QUICKPAY_PAYMENT_PRE_DEAUTH.rawValue
            } else {
                event = BillPayEvents.QUICKPAY_PAYMENT_PAST_DUE.rawValue
            }
        case .normal:
            event = BillPayEvents.QUICKPAY_HOME_PAGE_PAYMENT_DUE.rawValue
            if isPaymentCardExpired() {
                event = BillPayEvents.QUICKPAY_NO_AUTOPAY_DEFAULT_CARD_EXPIRED.rawValue
            }
        case .autoPay: break
        case .manualBlock:
            event = BillPayEvents.QUICKPAY_ONLINE_PAYMENT_MANUAL_BLOCKED.rawValue
        }
        return event
    }
}


