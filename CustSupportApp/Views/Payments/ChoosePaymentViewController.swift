//
//  ChoosePaymentViewController.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 19/12/22.
//

import UIKit
import Lottie

enum ChoosePaymentType {
    case turnOnAutoPay
    case turnOnAutoPayFromSpotlight
    case turnOnPBFromMoreOptions(isAutoPay: Bool)
    case none
}

enum NavigationStyle {
    case push
    case present
    case presented
}

class ChoosePaymentViewController: BaseViewController {
    var dismissCompletion:((Bool) -> Void)?
    var selectionHandler: ((PayMethod) -> Void)?
    @IBOutlet weak var tablePaymentList: UITableView!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var viewCloseButton: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var viewChooseTitle: UIView!
    var selectedIndex: IndexPath? = nil
    var cardType: CreditCardType = .Visa
    var payMethods: [PayMethod] = []
    var selectedPayMethods: PayMethod?
    let sharedManager = QuickPayManager.shared
    var paymentType: ChoosePaymentType = .none
    var navigationStyle: NavigationStyle = .presented
    var payMethod: PayMethod?
    var isMakePaymentFlow: Bool = false
    var schedulePaymentDate: String?
    var paymentDate: String?
    weak var makePaymentViewController: MakePaymentViewController?
    var selectedAmount: Double?
    var payNowRetry: Bool = false
    var isFromOtpOrSPF = false
    var titleHeader = ""
    var isAutoPaymentErrorFlow: Bool = false // CMAIOS-2119
    var flowType: flowType = .none// //CMAIOS-2516, 2518, CMAIOS-2525
    var isFromSetupAPPB = false //CMAIOS-2485
    var signInIsProgress = false //CMAIOS-2495
    @IBOutlet weak var finishSetupAnimationView: LottieAnimationView! //CMAIOS-2495
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    //CMAIOS-2398: Fix for title header truncation
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var plusIconBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomStackView: UIStackView!

    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    //CMAIOS-2558
    var screenTag = ""
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCell()
        buttonDelegate = self
    }
    
    func updateHeaderForChoosePayment() {
        //CMAIOS-2153 Make Top space as 30 px
        self.titleLabelTopConstraint.constant = UIDevice.current.hasNotch ? 20 : 27
        //CMAIOS-2354: Fix to call proper header for choose payment screen
        
        switch paymentType {
        case .turnOnAutoPayFromSpotlight :
            //CMAIOS-2398: Fix for title header truncation
            titleLabelHeightConstraint.constant = 98.0
            self.viewChooseTitle.frame = CGRect(x: 0, y: 25, width: self.viewChooseTitle.frame.width, height: 98.0)
            //
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.14
            paragraphStyle.alignment = .left
            label_Title.attributedText = NSMutableAttributedString(string: titleHeader, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            self.cancelButton.isHidden = true
            if QuickPayManager.shared.isPaperLessBillingEnabled() {
                self.continueButton.setTitle("Finish setup", for: .normal)
            }
        case .turnOnPBFromMoreOptions(let isAutoPay):
            //CMAIOS-2398: Fix for title header truncation
            titleLabelHeightConstraint.constant = 98.0
            self.viewChooseTitle.frame = CGRect(x: 0, y: 25, width: self.viewChooseTitle.frame.width, height: 98.0)
            //
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.14
            paragraphStyle.alignment = .left
            label_Title.attributedText = NSMutableAttributedString(string: titleHeader, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            self.cancelButton.isHidden = true
            self.continueButton.setTitle("Continue", for: .normal)
        default:
            if isFromOtpOrSPF {
                //CMAIOS-2398: Fix for title header truncation
                titleLabelHeightConstraint.constant = 98.0
                self.viewChooseTitle.frame = CGRect(x: 0, y: 0, width: self.viewChooseTitle.frame.width, height: 98.0)
                //
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.14
                paragraphStyle.alignment = .left
                label_Title.attributedText = NSMutableAttributedString(string: titleHeader, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            }
        }
        
        /*
        if isFromOtpOrSPF || paymentType == .turnOnAutoPayFromSpotlight {
            //CMAIOS-2398: Fix for title header truncation
            titleLabelHeightConstraint.constant = 98.0
            self.viewChooseTitle.frame = CGRect(x: 0, y: (paymentType == .turnOnAutoPayFromSpotlight) ? 25 : 0, width: self.viewChooseTitle.frame.width, height: 98.0)
            //
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.14
            paragraphStyle.alignment = .left
            label_Title.attributedText = NSMutableAttributedString(string: titleHeader, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
        if paymentType == .turnOnAutoPayFromSpotlight {
            self.cancelButton.isHidden = true
            if QuickPayManager.shared.isPaperLessBillingEnabled() {
                self.continueButton.setTitle("Finish setup", for: .normal)
            } else {
                screenTag = DiscountEligible.SPOTLIGHT_CARD_CHOOSE_PAYMENT_ENROLL_AP.rawValue
            }
            if !screenTag.isEmpty {
                let custParams = [EVENT_SCREEN_NAME : screenTag, CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance]
                        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: custParams)
            }
        }
         */
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        switch paymentType {
        case .turnOnAutoPayFromSpotlight:
            self.navigationController?.navigationBar.isHidden = false
        case .turnOnPBFromMoreOptions(let isAutoPay):
            if isAutoPay {
                self.navigationController?.navigationBar.isHidden = false
            }
        default:
            self.navigationController?.navigationBar.isHidden = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : PaymentScreens.MYBILL_CHOOSE_A_PAYMENT_METHOD.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        }
            
        /*
         if !isFromSetupAPPB {
         self.navigationController?.navigationBar.isHidden = true
         } else {
         self.navigationController?.navigationBar.isHidden = false
         }
         */
        
        fetchPaymethods()
        updateHeaderForChoosePayment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }

    private func registerTableViewCell() {
        tablePaymentList.register(UINib.init(nibName: "ChoosePaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoosePaymentTableViewCell")
        self.tablePaymentList.rowHeight = UITableView.automaticDimension;
        self.tablePaymentList.separatorStyle = .none
        self.tablePaymentList.dataSource = self
        self.tablePaymentList.delegate = self
        self.tablePaymentList.sectionFooterHeight = 0.0
        //CMAIOS-2763, 2149: Bottom space(30 px) fix
        bottomViewBottomConstraint.constant = UIDevice().hasNotch ? -21 : 5
    }
    
    @IBAction func actionClose(_ sender: Any) {
        var isturnOnAutoPay = false
        switch paymentType {
        case .turnOnAutoPay:
            isturnOnAutoPay = true
        default: break
        }
        
        if let deleteMopErrorView = self.navigationController?.viewControllers.filter({$0.isKind(of: DeleteManagePaymentOptionsViewController.classForCoder())}).first as? DeleteManagePaymentOptionsViewController {
            self.navigationController?.popToViewController(deleteMopErrorView, animated: true)
        } else if self.navigationController?.viewControllers.last(where: { $0.isKind(of: BillingPreferencesViewController.self) }) != nil && isturnOnAutoPay {
            self.navigationController?.popViewController(animated: true)
            return
        } else if(selectedPayMethods != nil) {
            if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billingPayController, animated: true)
                }
                return
            } else {
                self.navToHomeVC()
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func actionAddCard(_ sender: Any) {
        showAddCard()
    }
    
    @IBAction func primaryButtonAction(_ sender: Any) {
        self.updateSelectedPaymentCard()
    }
    
    @IBAction func secondaryButtonAction(_ sender: Any) {
        self.actionClose("")
    }
    
    func navToHomeVC() {
        if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
            self.dismiss(animated: true)
        }
    }

    private func showAddCard() {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow // CMAIOS-2119
        viewcontroller.isMakePaymentFlow = isMakePaymentFlow
        viewcontroller.schedulePaymentDate = schedulePaymentDate
        viewcontroller.selectedAmount = selectedAmount
        /*
        viewcontroller.isTurnOnAutoPay = (paymentType == .turnOnAutoPay) ? true: false // CMAIOS:-2178
         */
        viewcontroller.isTurnOnAutoPay = self.getTurnOnAutoPayType()
        if flowType == .editAutoPay || flowType == .autopay || flowType == .autopayFromSP || flowType == .appbNotEnrolled {//CMAIOS-2712
            viewcontroller.flow = flowType
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func getTurnOnAutoPayType() -> Bool {
        switch paymentType {
        case .turnOnAutoPay:
            return true
        default:
            return false
        }
    }
    
    func fetchPaymethods() {
        payMethods = sharedManager.getAllPayMethodMop()
        
        switch paymentType {
        case .turnOnAutoPay:
            // Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.CHOOSE_PAYMENT_FOR_AUTOPAY_SCREEN.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
        default:
            if let list = QuickPayManager.shared.localSavedPaymethods, isMakePaymentFlow {
                let paymentList: [PayMethod] = list.map { dict in
                    if dict.payMethod?.creditCardPayMethod == nil {
                        return PayMethod(name: dict.payMethod?.name, creditCardPayMethod: nil, bankEftPayMethod: dict.payMethod?.bankEftPayMethod)
                    }
                    return PayMethod(name: dict.payMethod?.name, creditCardPayMethod: dict.payMethod?.creditCardPayMethod, bankEftPayMethod: nil)
                }
                if paymentList.count > 0 {
                    payMethods.append(contentsOf: paymentList)
                }
            }
            self.checkAndSupressAutoPayPaymethod() //CMAIOS-2841
            self.updateSelectionForDefaultPayMethod()
        }
        
        /*
        if paymentType != .turnOnAutoPay {
            if let list = QuickPayManager.shared.localSavedPaymethods, isMakePaymentFlow {
                let paymentList: [PayMethod] = list.map { dict in
                    if dict.payMethod?.creditCardPayMethod == nil {
                        return PayMethod(name: dict.payMethod?.name, creditCardPayMethod: nil, bankEftPayMethod: dict.payMethod?.bankEftPayMethod)
                    }
                    return PayMethod(name: dict.payMethod?.name, creditCardPayMethod: dict.payMethod?.creditCardPayMethod, bankEftPayMethod: nil)
                }
                if paymentList.count > 0 {
                    payMethods.append(contentsOf: paymentList)
                }
            }
            updateSelectionForDefaultPayMethod()
        } else {
            // Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.CHOOSE_PAYMENT_FOR_AUTOPAY_SCREEN.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
         */
        // Call the function to remove selectedPayMethods
        removeSelectedPayMethods()
        tablePaymentList.reloadData()

    }
    
    func removeSelectedPayMethods() {
        guard let selectedPayMethods = selectedPayMethods else {
            return
        }
        
        payMethods.removeAll { payMethod in
            if let name = payMethod.name {
                return name == selectedPayMethods.name
            }
            return false
        }
        selectedIndex = (payMethods.count == 0) ? nil : IndexPath(row: 0, section: 0)
    }
    
    private func updateSelectionForDefaultPayMethod() {
        if let paymethod = payMethod {
            return updateIndex(payMethod: paymethod)
        }
        if let payMethodValue = sharedManager.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod { // In default, the default paymenthod should be selected
            return updateIndex(payMethod: payMethodValue)
        }
        if let payMethodValue = sharedManager.modelQuickPayGetAccountBill?.billAccount?.payMethods?.first {
            return updateIndex(payMethod: payMethodValue)
        }
    }
    
    private func updateIndex(payMethod: PayMethod) {
        let paymethodInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod)
        let name = paymethodInfo.1
        
        /*
        if let index = payMethods.firstIndex(where: { $0.name?.contains(name) ?? false }) {
            selectedIndex = IndexPath(row: index, section: 0)
        }
         */
        
        if let index = payMethods.firstIndex(where: { $0.name?.lastPathComponent.lowercased() == name.lowercased() }) {
            selectedIndex = IndexPath(row: index, section: 0)
        }
    }
    
    //CMAIOS-2841
    /// Current AutoPay Paymenthod should be supressed as per CMAIOS-2841
    private func checkAndSupressAutoPayPaymethod() {
        switch flowType {
        case .managePayments(let editAutoAutoPayFlow):
            if editAutoAutoPayFlow {
                guard let payMethodRef = payMethod else {
                    return
                }
                let paymethodInfo = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethodRef)
                let name = paymethodInfo.1
                let filteredPaymethods = payMethods.filter({ $0.name?.lastPathComponent.lowercased() != name.lowercased() })
                payMethods = filteredPaymethods
            }
        default: break
        }
    }
    
    func updateSelectedPaymentCard() {
        guard let indexPath = selectedIndex else { return }
        self.tablePaymentList.reloadData()
        if let isExpired = payMethods[indexPath.row].creditCardPayMethod?.isCardExpired, isExpired {
            guard let viewcontroller = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
            viewcontroller.flow = .quickPay
            viewcontroller.payMethod = payMethods[indexPath.row]
            viewcontroller.successHandler = { [weak self] payMethod in
                self?.selectionHandler?(payMethod)
            }
            // CMAIOS-2099
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        } else {
            let selectPaymentMethod = payMethods[indexPath.row]
            if selectPaymentMethod.creditCardPayMethod != nil { // This condition is only applicable for creditcard paymethods not for checking accounts
                guard let expiryDateString = selectPaymentMethod.creditCardPayMethod?.expiryDate else { return }
                // CMAIOS-2141
                let formattedDueDate = expiryDateString.components(separatedBy: "T")
                let newCardDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDueDate[0])
                if var paymentDate = self.paymentDate, !paymentDate.isEmpty {
                    if let index = paymentDate.firstIndex(of: "T") {
                        paymentDate = String(paymentDate.prefix(upTo: index))
                    }
                    let calenderSelectedDate = CommonUtility.getOnlyMonthYearDate(paymentDate: paymentDate)
                    if calenderSelectedDate.checkIfPaymentDateIsSelectedAfterCardExpirationDate(cardExpirationDate: newCardDate) {
                        handleCardExpiredNotification(paymentDate)
                        return
                    }
                }
            }
            
            sharedManager.tempPaymethod = payMethods[indexPath.row] // Used on enrol autoPay (from Quickpay and Account) respectively
            self.checkPayMentType(rowOfIndex: indexPath.row)
        }
    }
    
    private func checkPayMentType(rowOfIndex: Int) {
        switch paymentType {
        case .turnOnAutoPay:
            navigateToFinishSetup()
        case .turnOnAutoPayFromSpotlight:
            if QuickPayManager.shared.isPaperLessBillingEnabled() {
                self.mauiCreateAutoPay()
            } else {
                navigateToFinishSetup()
            }
        case .turnOnPBFromMoreOptions(let isAutoPay):
            navigateToFinishSetup()
        default:
            guard navigationStyle == .presented else { //CMAIOS-1149
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromLeft
                self.view.window?.layer.add(transition, forKey: kCATransition)
                selectionHandler?(payMethods[rowOfIndex])
                return
            }
            // CMAIOS-2099
            DispatchQueue.main.async {
                self.selectionHandler?(self.payMethods[rowOfIndex])
            }
        }
        
        /*
        if paymentType == .turnOnAutoPay ||  paymentType == .turnOnAutoPayFromSpotlight || paymentType == .turnOnPBFromMoreOptions {
            if paymentType == .turnOnAutoPayFromSpotlight, QuickPayManager.shared.isPaperLessBillingEnabled() {
                self.mauiCreateAutoPay()
            } else {
                navigateToFinishSetup()
            }
        } else {
            guard navigationStyle == .presented else { //CMAIOS-1149
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromLeft
                self.view.window?.layer.add(transition, forKey: kCATransition)
                selectionHandler?(payMethods[indexPath.row])
                return
            }
            // CMAIOS-2099
            DispatchQueue.main.async {
                self.selectionHandler?(self.payMethods[indexPath.row])
            }
        }
         */

    }
    
    private func mauiCreateAutoPay() {
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        guard let jsonParam = generateParamAsPerFlow(), !jsonParam.isEmpty else {
            self.signInFailedAnimation()
            self.showErrorMessageVC()
            return
        }
        APIRequests.shared.mauiCreateAutoPayRequest(interceptor: QuickPayManager.shared.interceptor, param: jsonParam, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Create AutoPay is \(String(describing: value))", sendLog: "Create AutoPay success")
                    self.refreshGetAccountBill()
                } else {
                    self.signInFailedAnimation()
                    Logger.info("Create AutoPay is \(String(describing: error))")
                    self.showErrorMessageVC()
                }
            }
        })
    }
    
    //CMAIOS-2485 Handle maui token expire and reauth scenarios
    func handleErrorFinishSetupAutopay(isShowErrorMessage:Bool = true) {
        self.signInFailedAnimation()
        if isShowErrorMessage{
            self.showErrorMessageVC()
        }
    }

    /// refresh  mauiGetAccountBillRequest to get paymethods list
    private func refreshGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = sharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: sharedManager.interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Refresh Get Account Bill is \(String(describing: value))", sendLog: "Refresh Get Account Bill success")
                    self.sharedManager.modelQuickPayGetAccountBill = value
                }
                self.signInIsProgress = false
                self.finishSetupAnimationView.pause()
                self.finishSetupAnimationView.play(fromProgress: self.finishSetupAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.signInFailedAnimation()
                    self.navigateToAllSet() // Uncomment the above lines for actual flow, this line for mock validation
                }
            }
        })
    }
    
    private func navigateToAllSet() {
        guard let viewcontroller = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        // CMAIOS:- 2549
//        viewcontroller.allSetType = isAutoPay ? (isAutoPayTurnOnFlow() ? .turnOnAutoPay:  .newAutoPay) : .paperlessBilling
        viewcontroller.allSetType = .turnOnAutoPaySP
        
        if let autoPayMethod = QuickPayManager.shared.getDefaultAutoPaymentMethod() {
            viewcontroller.payMethod = autoPayMethod
        }
        guard let navigationControl =  self.navigationController else {
            viewcontroller.modalPresentationStyle = .fullScreen
            viewcontroller.navigationController?.navigationBar.isHidden = false
            self.present(viewcontroller, animated: true)
            return
        }
        navigationControl.navigationBar.isHidden = true
        navigationControl.pushViewController(viewcontroller, animated: true)
    }
    
    func showErrorMessageVC() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromFinishSetup = true
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func generateParamAsPerFlow() -> [String: AnyObject]? {
//        return generateJsonParamForSPFlow()
        return generateJsonParam()
    }
    
    private func getPaymethodNameForAutoPay() -> String? {
        if let paymethodName = QuickPayManager.shared.getPaymethodNameForAutoPaySetup() {
            return paymethodName
        }
        return nil
    }
    
    private func generateJsonParamForSPFlow() -> [String: AnyObject]? {
        var jsonParams: [String: AnyObject]?
        guard let paymethodName = self.getPaymethodNameForAutoPay() else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: paymethodName)
        let autopay = CreatAutoPayWithInitialPayment.AutoPay(payMethod: payMethod, initialPayAmount: AmountInfo(currencyCode: "USD", amount: Double(QuickPayManager.shared.getCurrentAmount())))
        let createAutoPayWithInitialPay = CreatAutoPayWithInitialPayment(parent: QuickPayManager.shared.getAccountName(), autoPay: autopay)
        do {
            let jsonData = try JSONEncoder().encode(createAutoPayWithInitialPay)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    private func generateJsonParam() -> [String: AnyObject]? {
        var jsonParams: [String: AnyObject]?
        guard let paymethodName = self.getPaymethodNameForAutoPay() else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: paymethodName)
        let autopay = CreatAutoPay.AutoPay(payMethod: payMethod)
        let createAutoPay = CreatAutoPay(parent: QuickPayManager.shared.getAccountName(), autoPay: autopay)
        do {
            let jsonData = try JSONEncoder().encode(createAutoPay)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    private func handleCardExpiredNotification(_ selectedDueDate: String) {
        let cardExpiredVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "CardExpiredNotifyVC") as CardExpiredNotifyVC
        cardExpiredVC.payMethod = payMethods[selectedIndex?.row ?? 0]
        cardExpiredVC.paymentDate = selectedDueDate
        cardExpiredVC.makePaymentViewController = makePaymentViewController
        cardExpiredVC.isComeChoosePayment = true
        cardExpiredVC.delegate = self
        // CMAIOS-2099
        self.navigationController?.pushViewController(cardExpiredVC, animated: true)
    }
    
    // MARK: - Finish Setup Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.finishSetupAnimationView.isHidden = true
        self.continueButton.isHidden = true
        UIView.animate(withDuration: 1.0) {
            self.finishSetupAnimationView.isHidden = false
        }
        self.finishSetupAnimationView.backgroundColor = .clear
        self.finishSetupAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.finishSetupAnimationView.loopMode = .playOnce
        self.finishSetupAnimationView.animationSpeed = 1.0
        self.finishSetupAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.finishSetupAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.finishSetupAnimationView.currentProgress = 3.0
        self.finishSetupAnimationView.stop()
        self.finishSetupAnimationView.isHidden = true
        self.continueButton.alpha = 0.0
        self.continueButton.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.continueButton.alpha = 1.0
        }
    }
}

extension ChoosePaymentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return calculateHeaderHeight()
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.tablePaymentList.frame.width,
                                              height: calculateHeaderHeight()))
        headerView.backgroundColor = .white
        return headerView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return calculateSectionFooter()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payMethods.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChooseMOPConstants.cellHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosePaymentTableViewCell") as! ChoosePaymentTableViewCell
        cell.selectionStyle = .default
        cell.checkImage.isHidden = (indexPath != selectedIndex)
        let bgcolor = (indexPath != selectedIndex) ? UIColor.white: UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1)
        cell.backgroundColor = bgcolor
        cell.setUpCellData(payMethod: payMethods[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        guard (selectedIndex != nil) else { return }
        self.tablePaymentList.reloadData()
        if let isExpired = payMethods[indexPath.row].creditCardPayMethod?.isCardExpired, isExpired {
            guard let viewcontroller = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
            viewcontroller.flow = .quickPay
            viewcontroller.payMethod = payMethods[indexPath.row]
            viewcontroller.successHandler = { [weak self] payMethod in
                if self?.selectionHandler != nil {
                    self?.selectionHandler?(payMethod)
                } else {
                    self?.navigationController?.popViewController(animated: true)//CMAIOS-2789
                }
                //self?.navigationController?.popViewController(animated: true)//CMAIOS-2673
            }
            // CMAIOS-2099
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    /* CMAIOS-1112 */
    /// Check totalContentHeight = no of cells, addcard button, title, titleBuffer heights to determine the top header space
    /// - Returns: Buffer height for tableview header
    private func calculateHeaderHeight() -> CGFloat {
        var turnOnAutoPayFromSpotlightLauyout = false
        switch paymentType {
        case .turnOnAutoPayFromSpotlight:
            turnOnAutoPayFromSpotlightLauyout = true
        default:
            turnOnAutoPayFromSpotlightLauyout = false
        }
        
        var headerHeight = 0.0
        var totalContentHeight = 0.0
        let tablePaymentListHeight = self.tablePaymentList.frame.height
        if payMethods.count > 0 {
            totalContentHeight = Double(payMethods.count) * 90.0
            totalContentHeight += ChooseMOPConstants.addCardButtonHeight
            totalContentHeight += ChooseMOPConstants.titleBuffer
            //CMAIOS-2398: Fix for title header truncation
            totalContentHeight += ( isFromOtpOrSPF || turnOnAutoPayFromSpotlightLauyout) ? ChooseMOPConstants.titleHeight + 30 : ChooseMOPConstants.titleHeight
            //
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
    
    /* CMAIOS-1112 */
    private func calculateSectionFooter() -> CGFloat {
        return 0.0
    }
    
    /// Set scroll compatibility for tableview depending on List
    /// - Parameter headerHeight: Used to add shadow for close button view for long list
    private func checkAndDisableScroll(headerHeight: CGFloat) {
        self.tablePaymentList.alwaysBounceVertical = false
        if headerHeight <= 0.0 { // Add top shadow for Long List
            self.viewCloseButton.addTopShadow(topLight: true)
            self.plusIconBottomConstraint.constant = 30
        } else { // Remove top shadow for Non Long List
            self.viewCloseButton.layer.shadowOpacity = 0
            self.plusIconBottomConstraint.constant = 0
        }
    }
    
    private func navigateToFinishSetup() {
        guard let viewcontroller = FinishSetupViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.screenType = self.getScreenType()
        viewcontroller.flowType = self.flowType //CMAIOS-2516, 2518
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    private func getScreenType() -> FinishSetupType {
        switch paymentType {
        case .turnOnAutoPay :
                return .turnOnAutoPay
        case .turnOnAutoPayFromSpotlight:
                return .turnOnAutoPayFromSpotlight
        case .turnOnPBFromMoreOptions(let isAutoPay):
                return .turnOnPBFromMoreOptions(isAutoPay: isAutoPay)
        default:
            return .turnOnAutoPay
        }
        
        /*
        if paymentType == .turnOnAutoPay {
            return .turnOnAutoPay
        } else if paymentType == .turnOnAutoPayFromSpotlight {
            return .turnOnAutoPayFromSpotlight
        } else if paymentType == .turnOnPBFromMoreOptions {
            return .turnOnPBFromMoreOptions
        }
        return .turnOnAutoPay
         */
    }
}

extension ChoosePaymentViewController: BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        switch buttonType {
        case .cancel:
//            self.dismiss(animated: true, completion: nil)
            switch paymentType {
            case .turnOnAutoPayFromSpotlight, .turnOnPBFromMoreOptions:
                if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                } else if let vc = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                    self.dismiss(animated: true)
                } else {
                    self.navigateToDesiredVCAsPerFlowType() //CMAIOS-2516, 2518
                }
            default:
                if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }
            /*
             if isFromSetupAPPB {
             if let homeScreen = self.navigationController?.viewControllers.filter({$0.isKind(of: HomeScreenViewController.classForCoder())}).first {
             DispatchQueue.main.async {
             self.navigationController?.popToViewController(homeScreen, animated: true)
             }
             }
             } else {
             if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
             DispatchQueue.main.async {
             self.navigationController?.popToViewController(vc, animated: true)
             }
             }
             }
             */
        case .back:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //CMAIOS-2516, 2518
    func navigateToDesiredVCAsPerFlowType(){
        switch self.flowType {
        case .autoPayFromLetsDoIt:
            if let vc = self.navigationController?.viewControllers.filter({$0 is SchedulePaymentViewController}).first as? SchedulePaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        default :
            if let vc = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
}

extension ChoosePaymentViewController: CardExpiredNotifyDelegate {
    func didDismissCardExpiredNotify(withPaymentMethod method: PayMethod?) {
        // Update the payment method when CardExpiredNotifyVC is dismissed
        self.payMethod = method
        self.titleHeader = "Choose a different payment method"
        self.isFromOtpOrSPF = true
        self.tablePaymentList.reloadData()
    }
}

struct ChooseMOPConstants {
    static let addCardButtonHeight = 70.0
    static let cellHeight = 90.0
    static let headerBufferHeight = 160.0
    static let titleHeight = 60.0
    static let titleBuffer = 10.0
}
