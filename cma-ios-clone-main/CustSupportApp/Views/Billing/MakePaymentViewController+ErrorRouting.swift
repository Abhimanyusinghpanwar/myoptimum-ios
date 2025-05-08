//
//  MakePaymentViewController+ErrorRouting.swift
//  CustSupportApp
//
//  Created by riyaz on 02/05/24.
//

import Foundation
import UIKit
import Lottie

extension MakePaymentViewController {
    
    func showOneTimePaymentFailureScreen(errorType: ErrorType = .none, paymentState: ThanksPaymentState = .paymentFailure, isAutoPay: Bool = false) {
        guard let viewcontroller = OneTimePaymentfailureVC.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.state = paymentState
        viewcontroller.isFromSpotlight = true //CMAIOS-2418
        viewcontroller.payMethod = payMethod
        viewcontroller.isMakePaymentFlow = true
        viewcontroller.isAutoPayFlow = isAutoPay
        viewcontroller.selectedAmount = Double(self.paymentAmount) ?? 0
        viewcontroller.errorType = errorType
        viewcontroller.dismissCallBack = { chatFlow in
            if chatFlow {
                self.dimissCallBack?(chatFlow)
            }
        }
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    func mapErrorCodeToOTPErrorType() -> OTPFailErrorType {
        //CMAIOS-2442
        let errorCodeString = QuickPayManager.shared.currentApiErrorCode.lowercased()
        let errorCode = payNowRetry ? "" : errorCodeString
        //CMAIOS-2439 Added numeric codes for OTP
        switch errorCode {
        case "invalid bank or finbr", "numeric value out of range for xml tag eftt_bacct", "xml tag eftt_bacct should be numeric", "307", "xml tag eftt_bacct should be numeric.":
            return .OTPFailNotValidCheckingRouting
        case "card is expired":
            return .OTPFailNotValidCardExpired // CMA2304, CMAIOS-2654
        case "invalid cc number","591", "602", "603", "invalid institution code":
            return .OTPFailNotValidCard // CMA2303
        case "generic error", "401":
            return payNowRetry ? .OTPFailTechnicalSecondTime : .OTPFailTechnical
        case "30170" : //CMAIOS-2068 and CMAIOS-2210
            let quickPayManager = QuickPayManager.shared
            if quickPayManager.currentApiType == .achOneTimePayment || quickPayManager.currentApiType == .immediatePaymentACH {
                return quickPayManager.initialScreenFlow == .noDue ? .OTPFailExceedCheckingNoAmountDue : .OTPCreditLimitFlow
            } else {
                return .OTPFailNotValidChecking
            }
        case "credit floor", "lost/stolen", "do not honor", "processor decline", "restraint", "pickup", "suspected fraud", "insufficient fund", "revocation of authorization" : //CMAIOS-2069
            return QuickPayManager.shared.initialScreenFlow == .noDue ? .OTPFailExceedCardNoAmountDue : .OTPCreditLimitCreditCard // CMAIOS-2069
        case "90001", "30168", "30167" : //CMAIOS-2066
            return .OTPFailDuplicatePayment
        default:
            return payNowRetry ? .OTPFailSecondDefaultMOP : .OTPFailDefaultMOP
        }
    }

    func handleMakePaymentErrorCodes(error: Any) {
        var errorType: ErrorType = .none
        if let otpError = error as? OTPFailErrorType {
            errorType = ErrorType.oneTime(otpError)
        }
        if let scheduleError = error as? SPTFailErrorType {
            errorType = ErrorType.schedule(scheduleError)
        }
        self.showOneTimePaymentFailureScreen(errorType: errorType)
    }

    
}
