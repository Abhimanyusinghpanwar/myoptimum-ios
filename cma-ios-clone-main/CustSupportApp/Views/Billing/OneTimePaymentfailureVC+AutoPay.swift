//
//  OneTimePaymentfailureVC+AutoPay.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 08/07/24.
//

import Foundation

//MARK: Handle Auto payment failures Flows

extension OneTimePaymentfailureVC {
    
    func updateForAutoPay(type: AutoPayFailErrorType) {
        var screenTag = ""
        switch type {
        case .APNotValidCardAmountDue:
            /* CMAIOS-2120 Error Invalid CC number */
            lblSubTitle.text = "Looks like the card number for \(self.mopDetailsForOTPFailure(defaultNickName: "your credit/debit card")) is not correct.\n\nPlease pay the bill now with a different payment method, or chat with us to fix the problem."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
        case .APNotValidCardNoAmountDue:
            /* CMAIOS-2118 Error Invalid CC number */
            lblSubTitle.text = "Looks like the card number for \(self.mopDetailsForOTPFailure(defaultNickName: "your credit/debit card")) is not correct."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APFailCardExpiredAmountDue:
            /* CMAIOS-2425 */
            //            lblSubTitle.text = "Looks like the expiration date for \(self.checkForCardDetails()) is not correct.\n\nPlease pay the bill now with a different payment method, or chat with us to fix the problem."
            //            btnUseDiffPayment.setTitle("Use a different payment method", for: .normal)
            //            btnChatwithus.setTitle("Chat with us", for: .normal)
            //            setCloseViewHeight(isCloseView: true)
            lblSubTitle.text = "\(self.checkForCardDetails(isPrefixRequired: true, uppercasePrefixNeeded: true)) has expired.\n\nPlease pay this month's bill now to keep your account up to date."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
            screenTag = AutoPayFailureSpotlight.PAYMENT_FAILED_AUTOPAY_CARD_EXPIRED_AMOUNT_DUE.rawValue
        case .APNotValidCheckingAmountDue:
            /* CMAIOS-2115 */
            lblSubTitle.text = "Looks like the routing number for \(self.mopDetailsForOTPFailure(defaultNickName: "your checking account")) is not correct.\n\nPlease pay the bill now with a different payment method, or chat with us to fix the problem."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
        case .APExceedLimitCheckingAmountDue: // CMA-2337
            //CMAIOS-2112
            let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourChkAcc)
            lblSubTitle.text = "Your bank says \(nickName) doesn't have enough available funds or is no longer valid.\n\nPlease pay this month's bill now or contact your bank to resolve this issue."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
            screenTag = AutoPayFailureSpotlight.PAYMENT_FAILED_EXCEEDED_LIMIT_ACH_MAKE_A_PAYMENT.rawValue
        case .APExceedLimitCheckingNoAmountDue: // CMA-2381
            //CMAIOS-2104
            let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourChkAcc)
            lblSubTitle.text = "Your bank says \(nickName) doesn't have enough funds or is no longer valid."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: false)
        case .APTechnicalDifficultiesNoAmountDue:
            /* CMAIOS-2365 401 from .net and GENERIC ERROR from AMSS */
            lblSubTitle.text = "Due to technical difficulties, we couldn't process this month's Auto Pay."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
            self.trackGAEvent(isAmntDue: false) //CMAIOS-2465
        case .APTechnicalDifficultiesAmountDue:
            /* CMAIOS-2431 401 from .net and GENERIC ERROR from AMSS */
            lblSubTitle.text = "Due to technical difficulties, we couldn't process this month's Auto Pay\n\nPlease pay \(cardData?.amount ?? "") now to keep your account up to date."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
            self.trackGAEvent(isAmntDue: true) //CMAIOS-2465
        case .APExceedLimitCardAmountDue: // CMA-2336
            //CMAIOS-2111
            let nickName = self.checkForCardDetails(isPrefixRequired: true)
            lblSubTitle.text = "Your card provider says \(nickName) has reached its limit or is no longer valid.\n\nPlease pay this month's bill now or contact your card provider to resolve this issue."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
            screenTag = AutoPayFailureSpotlight.PAYMENT_FAILED_EXCEEDED_LIMIT_CARD_MAKE_A_PAYMENT.rawValue
        case .APExceedLimitCardNoAmountDue: // CMA-2380
            //CMAIOS-2367
            let nickName = self.checkForCardDetails(isPrefixRequired: true)
            lblSubTitle.text = "Your card provider says \(nickName) has reached your credit limit, or is no longer valid.\n\nPlease contact your card provider to resolve this issue."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            btnChatwithus.isHidden = true
            setCloseViewHeight(isCloseView: false)
        case .APFailCardExpiredNoAmountDue:
            /* CMAIOS-2428 */
            lblSubTitle.text = "\(self.checkForCardDetails()) has expired."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
            screenTag = AutoPayFailureSpotlight.PAYMENT_FAILED_AUTOPAY_CARD_EXPIRED_NO_AMOUNT_DUE.rawValue
        case .none:
            // CMAIOS-2663
            lblSubTitle.text = "Due to technical difficulties, we couldn't process this month's Auto Pay."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        default: break
        }
        if !screenTag.isEmpty {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
    }
    
    //CMAIOS-2465
    func trackGAEvent(isAmntDue: Bool){
        let screenTag = isAmntDue ?  AutoPayFailureDetails.AUTO_PAYMENT_FAILED_TECH_DIFFICULTY_AMOUNT_DUE.rawValue :  AutoPayFailureDetails.AUTO_PAYMENT_FAILED_TECH_DIFFICULTY_NO_AMOUNT_DUE.rawValue
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
    }
    
    
    func handleAutoPayPrimaryTap(type: AutoPayFailErrorType) {
        switch type {
        case .APNotValidCardAmountDue, .APNotValidCheckingAmountDue:
            navToChoosePayment(isAutoPayFlow: true) // CMAIOS-2110
        case.APNotValidCardNoAmountDue, .APExceedLimitCheckingNoAmountDue, .APTechnicalDifficultiesNoAmountDue, .APExceedLimitCardNoAmountDue, .APFailCardExpiredNoAmountDue, .none: // CMAIOS-2663
            navToHomeVC()
        case .APTechnicalDifficultiesAmountDue, .APExceedLimitCardAmountDue, .APExceedLimitCheckingAmountDue:
            self.moveToMakePaymentScreen(paymethod: self.payMethod)
        case .APFailCardExpiredAmountDue:
            self.checkCardExpiryAndMoveToMakePayment()
        default: break
        }
    }
    
    func handleAutoPaySecondaryTap(type: AutoPayFailErrorType) {
        switch type {
        case .APNotValidCardAmountDue, .APNotValidCheckingAmountDue:
            navToChatwithus()
        default:
            navToBillingHome()
        }
    }
    
    func checkCardExpiryAndMoveToMakePayment() {
        if let defaultPaymethod = QuickPayManager.shared.getDefaultPayMethod() {
            if QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: defaultPaymethod).1 == self.cardData?.payNickName,
               let isExpired = defaultPaymethod.creditCardPayMethod?.isCardExpired, isExpired {
                guard let viewcontroller = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.flow = .autoPaymentFailure
                viewcontroller.payMethod = defaultPaymethod
                viewcontroller.successHandler = { [weak self] payMethod in
                    self?.moveToMakePaymentScreen(paymethod: payMethod)
                }
                // CMAIOS-2099
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            } else {
                self.moveToMakePaymentScreen(paymethod: nil)
            }
        }
    }
    
}
