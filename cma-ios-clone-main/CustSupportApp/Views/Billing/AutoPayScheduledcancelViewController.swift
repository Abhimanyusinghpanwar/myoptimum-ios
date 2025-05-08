//
//  AutoPayScheduledcancelViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 11/12/23.
//

import UIKit
import Lottie

class AutoPayScheduledcancelViewController: UIViewController {
    
    @IBOutlet weak var cancelVCHeaderLabel: UILabel!
    @IBOutlet weak var primaryButton: RoundedButton!
    @IBOutlet weak var secondaryButton: RoundedButton!
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    
    var isCancelConfirm:Bool = false
    var paymentHistoryObject: HistoryInfo?
    var yesInProgress = false
    var qualtricsAction : DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.handleUI()
        trackEvents()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
    
    func addQualtrics(screenName:String){
        self.qualtricsAction = self.checkQualtrics(screenName: screenName, dispatchBlock: &qualtricsAction)
    }
    
    func handleUI() {
        cancelVCHeaderLabel.setLineHeight(1.15)
        if let amount = paymentHistoryObject?.amount?.amount,
           let paymentDate = paymentHistoryObject?.paymentDate {
            let amountValue = String(format: "%.2f", amount)
            let autoPayOrOneTime = (paymentHistoryObject?.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT") ? "payment" : "Auto Pay"
            let cancellationText = isCancelConfirm ? "Your $\(amountValue) \(autoPayOrOneTime) has been canceled" :
            "Are you sure you want to cancel your $\(amountValue) \(autoPayOrOneTime) scheduled for \(CommonUtility.convertDateStringFormats(dateString: paymentDate, dateFormat: "MMM. d"))?"
            
            primaryButton.setTitle(isCancelConfirm ? "Okay" : "Yes", for: .normal)
            cancelVCHeaderLabel.text = cancellationText
            secondaryButton.isHidden = isCancelConfirm
        }
    }
    
    private func cancelSchedulePayment(paymentName: String?) {
        self.qualtricsAction?.cancel()
        guard let schduleId = paymentName else {
            self.showErrorMsgOnAPIFailure()
            return
        }
        var jsonParams = [String: AnyObject]()
        jsonParams["name"] = schduleId as AnyObject?
        
        QuickPayManager.shared.mauiCancelScheduledPayment(jsonParams: jsonParams, completionHanlder: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.clearModelAfterChatRefresh()
                    /*
                     DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                     self.yesInProgress = false
                     self.stopAnimationAndPerformAction()
                     }
                     */
                    self.mauiGetListPaymentApiRequest()
                } else {
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
    
    func showConfirmCancelVC() {
        self.qualtricsAction?.cancel()
        let storyboard = UIStoryboard(name: "BillPay", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "AutoPayScheduledcancelVC") as? AutoPayScheduledcancelViewController {
            cancelVC.isCancelConfirm = true
            cancelVC.paymentHistoryObject = self.paymentHistoryObject
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
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
    
    func stopAnimationAndPerformAction() {
        self.yesInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                self.showConfirmCancelVC()
            }
        }
    }
    
    func handleApiErrorCode() {
        self.showErrorMsgOnAPIFailure()
    }
    
    func showErrorMsgOnAPIFailure() {
        self.qualtricsAction?.cancel()
        var autoPayOrOneTime = ""
        if let paymentHistory = self.paymentHistoryObject {
            autoPayOrOneTime = (paymentHistory.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT") ? "payment" : "Auto Pay"
        }
        self.animationLoadingView.isHidden = true
        let vc = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "CancelPaymentErrorVC") as CancelPaymentErrorViewController
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .cancel_payment_API_failure, subTitleMessage: autoPayOrOneTime)
        //CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func yesBtn(_ sender: Any) {
        self.qualtricsAction?.cancel()
        if isCancelConfirm {
            if let controllers = self.navigationController?.viewControllers {
                for controller in controllers {
                    if controller is PaymentHistoryViewController {
                        self.navigationController?.popToViewController(controller, animated: true)
                        break
                    }
                }
            }
        } else {
            self.yesButtonAnimation()
            self.cancelSchedulePayment(paymentName: self.paymentHistoryObject?.paymentName)
        }
    }
    
    @IBAction func noBtn(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.navigationController?.popViewController(animated: true)
    }
    
    func trackEvents() {
        var screenTag = ""
        if isCancelConfirm {
            screenTag = (paymentHistoryObject?.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT") ? PaymentScreens.MYBILL_BILLING_PAYMENTHISTORY_ONE_TIME_PAYMENT_CANCEL_CONFIRMATION.rawValue : PaymentScreens.MYBILL_BILLING_PAYMENTHISTORY_AUTO_PAY_CANCEL_CONFIRMATION.rawValue
            self.addQualtrics(screenName: screenTag)
        } else {
            screenTag = (paymentHistoryObject?.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT") ? PaymentScreens.MYBILL_BILLING_PAYMENTHISTORY_ONE_TIME_PAYMENT_CANCEL_REQUEST.rawValue : PaymentScreens.MYBILL_BILLING_PAYMENTHISTORY_AUTO_PAY_CANCEL_REQUEST.rawValue
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
    }
}
