//
//  DeleteManagePaymentOptionsViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 04/09/24.
//

import UIKit
import Lottie
import SafariServices

class DeleteManagePaymentOptionsViewController: UIViewController {
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var editAutoPayButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    var yesInProgress = false
    var successHandler: (() -> Void)? = nil
    var errorMessageString: (headerTitle: String, subtitle: String) = ("", "")
    var buttonTitleString: (primaryButtonTitle: String, secondaryButtonTitle: String) = ("", "")
    var isShowEditAutoPay = false
    var isShowBottomLabel = false
    var schedulePaymentInfo : (isPaymentScheduled:Bool, totalSPs:Int)?
    var flow: flowType = .addCard(navType: .home)
    var refreshRequired = false
    var payMethod: PayMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configureUI()
    }
    
    func configureUI() {
        switch (isShowEditAutoPay, refreshRequired, schedulePaymentInfo?.isPaymentScheduled) {
        case (true, false, _):
            self.bottomView.isHidden = true
            self.closeButtonView.isHidden = false
            editAutoPayButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1).cgColor
            editAutoPayButton.setTitle(buttonTitleString.primaryButtonTitle, for: .normal)
            editAutoPayButton.setTitleColor(.white, for: .normal)
            self.setTitleTexts(titleLabelText: errorMessageString.headerTitle, subTitleLabelText: errorMessageString.subtitle)
        case (true, true, _): // CMAIOS:-2582
            self.refreshRequired = false
            let oldAutoPayCardName = (QuickPayManager.shared.getOnlyNickName(paymethod: payMethod))
            self.setTitleTexts(titleLabelText: "Do you still want to delete \(oldAutoPayCardName) from your account", subTitleLabelText: "")
            self.setButtonTitles()
        case (false, false, nil): //CMAIOS-2577 //CMAIOS-2526 //CMAIOS-2581
            self.setTitleTexts(titleLabelText: errorMessageString.headerTitle, subTitleLabelText: errorMessageString.subtitle)
            self.setButtonTitles()
        case (false, true, false): //CMAIOS-2577 if the user cancels all the SPs wrt MOP from BPH screen present from CMAIOS-2578 SP link
            errorMessageString.headerTitle =  errorMessageString.headerTitle.replacingOccurrences(of: "?", with: " from your account?")
            self.setTitleTexts(titleLabelText: errorMessageString.headerTitle, subTitleLabelText: "")
            self.setButtonTitles()
        case (false, false, true)://CMAIOS-2578
            self.setTitleTexts(titleLabelText: errorMessageString.headerTitle, subTitleLabelText: "")
            let endString = schedulePaymentInfo?.totalSPs ?? 0 > 1 ? "scheduled payments" : "scheduled payment"
            errorMessageString.subtitle = "This payment method is being used for \n\(schedulePaymentInfo?.totalSPs ?? 0) \(endString)."
            self.setButtonTitles()
            setTappableText()
            // Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            subTitleLabel.isUserInteractionEnabled = true
            subTitleLabel.addGestureRecognizer(tapGesture)
        default:
            break
        }
        self.bottomLabel.isHidden = self.isShowBottomLabel ? false : true
        if self.isShowBottomLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            bottomLabel.attributedText = NSMutableAttributedString(string: "If you delete this card, your scheduled payments will be canceled", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
    }
    
    func setTitleTexts(titleLabelText: String, subTitleLabelText: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        if !titleLabelText.isEmpty {
            titleLabel.attributedText = NSMutableAttributedString(string: titleLabelText, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            titleLabel.text = ""
        }
        if !subTitleLabelText.isEmpty {
            subTitleLabel.attributedText = NSMutableAttributedString(string: subTitleLabelText, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            subTitleLabel.text = ""
        }
    }
    
    func setButtonTitles() {
        self.bottomView.isHidden = false
        self.closeButtonView.isHidden = true
        primaryButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1).cgColor
        primaryButton.setTitle(buttonTitleString.primaryButtonTitle, for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        if buttonTitleString.secondaryButtonTitle.isEmpty {
            secondaryButton.isHidden = true
        } else {
            secondaryButton.isHidden = false
            secondaryButton.setTitle(buttonTitleString.secondaryButtonTitle, for: .normal)
            secondaryButton.setTitleColor(.black, for: .normal)
            secondaryButton.layer.borderWidth = 2
            secondaryButton.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        }
    }

    // CMAIOS:-2582
    @IBAction func editAutoPay(_ sender: Any) {
        if QuickPayManager.shared.isLegacyAccount() {
            self.navigateToInAppBrowser()
            return
        }
        guard let viewcontroller = EditAutoPayViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.editScreenType = .nonGrandfatherEditAutoPay
        viewcontroller.editAutoFlow = true
        viewcontroller.flow = self.flow
        viewcontroller.isDeleteAutoPayFlow = true
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    //Loader
    
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
    
    //
    
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // CMAIOS:-2582
    @IBAction func onTapAction(_ sender: UIButton) {
        switch sender {
        case primaryButton:
            if errorMessageString.headerTitle == "You're all set!" {
                successHandler?()
            } else if primaryButton.titleLabel?.text == "Okay" { //CMAIOS-2526
                self.navigationController?.popViewController(animated: true)
            } else {
                //CMAIOS-2578, 2577
                self.yesButtonAnimation()
                self.deleteSelectedMOP()
            }
        case secondaryButton:
            self.navigationController?.popViewController(animated: true)
        default:
            print("")
        }
    }
    
    //Make Delete MOP API call
    func deleteSelectedMOP(){
        guard let name = self.payMethod?.name else {return}
        QuickPayManager.shared.mauiDeletePaymentMethod(payMethodName: name) { success, value, error in
            if success{
                //CMAIOS-2819
                self.trackGATagForDeleteSuccess()
                Logger.info("Maui Delete MOP is \(String(describing: value))",sendLog: "Maui Delete MOP success")
                self.refreshManagePaymentScreenAfterPaymethodDeletion()
            } else {
                //CMAIOS-2578 Added error handling
                self.showErrorMsgOnAPIFailure()
            }
        }
    }
    
    //CMAIOS-2819
    func trackGATagForDeleteSuccess(){
          CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ManagePaymentMethod.DELETE_MOP_CONFIRMATION_SCREEN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Billing.rawValue])
    }
    
    //Make GetAccountBill API call to get available/updated MOPs after deletion
    private func refreshManagePaymentScreenAfterPaymethodDeletion(_ isFromLegacy: Bool = false) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        QuickPayManager.shared.modelQuickPayGetAccountBill = value
                        if let spInfo = self.schedulePaymentInfo, spInfo.isPaymentScheduled {
                            QuickPayManager.shared.clearModelAfterChatRefresh()
                            self.mauiGetListPaymentApiRequest()
                        } else {
                            if isFromLegacy {
                                QuickPayManager.shared.clearModelAfterChatRefresh()
                                self.mauiGetListPaymentApiRequest()
                            } else {
                                self.yesInProgress = false
                                self.stopAnimationAndPerformAction()
                            }
                        }
                    }
                } else {
                    //CMAIOS-2578 Added error handling
                    self.showErrorMsgOnAPIFailure()
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiListPaymentRequest(interceptor: nil, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.yesInProgress = false
                        self.stopAnimationAndPerformAction()
                    }
                } else {
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                    self.showErrorMsgOnAPIFailure()
                }
            }
        })
    }
    
    //Get underlined attributed text for subtitle for CMAIOS-2578
    private func setTappableText() {
        // Create a mutable attributed string with the full text
        let attributedString = NSMutableAttributedString(string: errorMessageString.subtitle)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        // Define the range of the text to underline""
        if let rangeOfTextToUnderline = self.getRangeOftappableText(text: errorMessageString.subtitle) {
            let underlineAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(red: 0.216, green: 0.372, blue: 0.910, alpha: 1.0),
                                                                      .underlineStyle: NSUnderlineStyle.single.rawValue, .paragraphStyle: paragraphStyle
            ]
            // Apply underline attributes to the specified range
            attributedString.addAttributes(underlineAttributes, range: rangeOfTextToUnderline)
        }
        // Assign the attributed string to the UILabel
        self.subTitleLabel.attributedText = attributedString
    }
    
    //Get range for text to be underlined for subtitle CMAIOS-2578
    func getRangeOftappableText(text: String)-> NSRange?{
        let arrOfStrings = text.components(separatedBy: "\n")
        let tappableString = arrOfStrings[1]
        let tappableStringWithoutDot = tappableString.components(separatedBy: ".")
        let exactTappableString = tappableStringWithoutDot[0]
        let fullText =  errorMessageString.subtitle
        if let rangeOfTextToUnderline = fullText.range(of: exactTappableString) {
            let nsRangeToUnderline = NSRange(rangeOfTextToUnderline.lowerBound..<rangeOfTextToUnderline.upperBound, in: fullText)
            return nsRangeToUnderline
        } else {
            return nil
        }
    }
    
    //Link to BPH screen after tapping underlined text CMAIOS-2578
    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.subTitleLabel)
        let textStorage = NSTextStorage(attributedString: self.subTitleLabel.attributedText!)
        let textContainer = NSTextContainer(size: self.subTitleLabel.bounds.size)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Determine if the tap was within the underlined text range
        if let rangeOfTextToUnderline = self.getRangeOftappableText(text: errorMessageString.subtitle) {
            if rangeOfTextToUnderline.location <= characterIndex && characterIndex <= rangeOfTextToUnderline.location + rangeOfTextToUnderline.length {
                navigateToPaymentHistoryScreen()
            }
        }
    }
    
    //NavigateToPaymentHistoryScreen after tapping underlined text CMAIOS-2578
    func navigateToPaymentHistoryScreen() {
        guard let viewcontroller = PaymentHistoryViewController.instantiateWithIdentifier(from: .billing) else { return }
        viewcontroller.flow = .managePayments(editAutoAutoPayFlow: false)
        viewcontroller.selectedMOPForDelete = self.payMethod //CMAIOS-2478
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    //Perform lottie animation on tap of delete button
    func yesButtonAnimation(){
        yesInProgress = true
        primaryButton.isHidden = true
        secondaryButton.isHidden = true
        animationLoadingView.isHidden = false
        viewAnimationSetUp()
    }
    
    func viewAnimationSetUp() {
        self.animationLoadingView.backgroundColor = .clear
        self.animationLoadingView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.animationLoadingView.loopMode = .playOnce
        self.animationLoadingView.animationSpeed = 1.0
        self.animationLoadingView.play(toProgress: 0.6, completion:{_ in
            if self.yesInProgress {
                self.animationLoadingView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    //Stop lottie animation after success
    func stopAnimationAndPerformAction() {
        self.yesInProgress = false
        if QuickPayManager.shared.isLegacyAccount() {
            removeLoaderView()
            if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
                self.showAddCard()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                if QuickPayManager.shared.getAllPayMethodMop().isEmpty {
                    self.showAddCard()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAddCard(manageCards: Bool = false) {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = true
        viewcontroller.flow = .managePayments(editAutoAutoPayFlow: false)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    //Show Error Message //CMAIOS-2578 Added error handling
    func showErrorMsgOnAPIFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.isFromManagePayment = true
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension DeleteManagePaymentOptionsViewController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser() {
        let safariVC = SFSafariViewController(url: URL(string: "https://www.optimum.net/pay-bill/manage-payments/")!)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion:nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        addLoader()
        refreshManagePaymentScreenAfterPaymethodDeletion(true)
    }
}
