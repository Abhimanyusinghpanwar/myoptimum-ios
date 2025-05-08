//
//  OneTimePaymentFailure + AutoPay.swift
//  CustSupportApp
//
//  Created by Vishali on 23/07/24.
//

import Foundation

extension OneTimePaymentfailureVC {
    
    func updateForAutoPayBPH(type: AutoPayFailErrorTypeBPH) {
        let genericConstant = "Due to technical difficulties, we couldn't process this month's Auto Pay."
        //CMAIOS-2379, CMAIOS-2381
        let nickName = self.isMOPNickNameAvailable(defaultNickName: "your " + strYourCC)
        //CMAIOS-2383, CMAIOS-2382
        let newNickName =  nickName.contains(strYourCC) ? nickName.firstCapitalized : nickName
        let amnt = String(format: "$%.2f", self.historyInfo?.amount?.amount ?? "")
        switch type {
        case .APTechnicalDifficultiesNoAmountDue:
            /* CMAIOS-2378 401 from .net and GENERIC ERROR from AMSS */
            lblSubTitle.text = genericConstant
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APTechnicalDifficultiesAmountDue:
            /* CMAIOS-2380 401 from .net and GENERIC ERROR from AMSS */
            lblSubTitle.text = "\(genericConstant)\n\nPlease pay \(amnt) now to keep your account up to date."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
        case .none:
            // CMAIOS-2663
            lblSubTitle.text = genericConstant
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APExceedLimitCardNoAmountDue://CMAIOS-2379
            lblSubTitle.text = "Your card provider says that \(nickName) has reached your credit limit, or the provider is saying the card is no longer valid.\n\nPlease contact the card provider to resolve the issue."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APExceedLimitCardAmountDue:
            lblSubTitle.text = "Your card provider says that \(nickName) has reached its credit limit, or the provider is saying the card is no longer valid.\n\nPlease pay this month's bill now or contact your card provider to resolve this issue."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
        case .APCardExpiredNoAmountDue:
            //CMAIOS-2383
            lblSubTitle.text = "\(newNickName) has expired."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APCardExpiredAmountDue:
            //CMAIOS-2382
            lblSubTitle.text = "\(newNickName) has expired.\n\nPlease pay this month's bill now to keep your account up to date."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
        case .APExceedLimitCheckingNoAmountDue: //CMAIOS-2663
//            lblSubTitle.text = "Your bank says \(nickName) has reached its limit or is no longer valid.\n\nPlease contact your bank to resolve this issue."
            lblSubTitle.text = "Your bank says \(nickName) doesn't have enough available funds or is no longer valid.\n\nPlease contact your bank to resolve this issue."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APExceedLimitCheckingAmountDue: //CMAIOS-2663
            lblSubTitle.text = "Your bank says \(nickName) doesn't have enough funds, or the bank is saying the account is no longer valid.\n\nPlease pay now with a different payment method or contact your bank to resolve this issue."
            btnUseDiffPayment.setTitle("Make a payment", for: .normal)
            setCloseViewHeight(isCloseView: true)
            btnChatwithus.isHidden = true
        case .APNotValidCardAmountDue:
            /*
            //CMAIOS-2663
            lblSubTitle.text = "Looks like the card number for \(self.mopDetailsForOTPFailure(defaultNickName: "your credit/debit card")) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your card."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
            */
            if let errorCode = historyInfo?.errorCode, (errorCode == "201" || errorCode == "591") {
                lblSubTitle.text = "Looks like the card number for \(self.mopDetailsForOTPFailure(defaultNickName: "your credit/debit card")) is not correct."
                btnUseDiffPayment.setTitle("Make a payment", for: .normal)
                setCloseViewHeight(isCloseView: true)
                btnChatwithus.isHidden = true
            } else {
                //CMAIOS-2663
                lblSubTitle.text = "Looks like the card number for \(self.mopDetailsForOTPFailure(defaultNickName: "your credit/debit card")) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your card."
                btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
                btnChatwithus.setTitle(chatBtnTitle, for: .normal)
                setCloseViewHeight(isCloseView: true)
            }
        case .APNotValidCardNoAmountDue:
            lblSubTitle.text = "Looks like the card number for \(self.mopDetailsForOTPFailure(defaultNickName: "your credit/debit card")) is not correct."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        case .APNotValidCheckingAmountDue:
            /*
            lblSubTitle.text = "Looks like the routing number for \(self.mopDetailsForOTPFailure(defaultNickName: "your checking account")) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your checking account."
            btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
            btnChatwithus.setTitle(chatBtnTitle, for: .normal)
            setCloseViewHeight(isCloseView: true)
             */
            if let errorCode = historyInfo?.errorCode, (errorCode == "751" || errorCode == "750") {
                lblSubTitle.text = "Looks like the routing number for \(self.mopDetailsForOTPFailure(defaultNickName: "your checking account")) is not correct."
                btnUseDiffPayment.setTitle("Make a payment", for: .normal)
                setCloseViewHeight(isCloseView: true)
                btnChatwithus.isHidden = true
            } else {
                lblSubTitle.text = "Looks like the routing number for \(self.mopDetailsForOTPFailure(defaultNickName: "your checking account")) is not correct.\n\nPlease pay now with a different payment method, or chat with us to update your checking account."
                btnUseDiffPayment.setTitle(diffMOPBtnTitle, for: .normal)
                btnChatwithus.setTitle(chatBtnTitle, for: .normal)
                setCloseViewHeight(isCloseView: true)
            }
        case .APNotValidCheckingNoAmountDue:
            lblSubTitle.text = "Looks like the routing number for \(self.mopDetailsForOTPFailure(defaultNickName: "your checking account")) is not correct."
            btnUseDiffPayment.setTitle("Okay", for: .normal)
            setCloseViewHeight(isCloseView: false)
            btnChatwithus.isHidden = true
        }
    }
    
    func handleAutoPayPrimaryTapBPH(type: AutoPayFailErrorTypeBPH) {
        switch type {
        case .APTechnicalDifficultiesNoAmountDue, .APExceedLimitCardNoAmountDue, .APCardExpiredNoAmountDue, .APExceedLimitCheckingNoAmountDue, .APNotValidCardNoAmountDue, .APNotValidCheckingNoAmountDue, .none: // CMAIOS-2663
            navToBillingAndPaymentHistory()
        case .APTechnicalDifficultiesAmountDue, .APExceedLimitCardAmountDue, .APCardExpiredAmountDue, .APExceedLimitCheckingAmountDue:
            moveToMakePaymentScreen(paymethod: self.historyInfo?.paymethod)
        case .APNotValidCardAmountDue, .APNotValidCheckingAmountDue:
//            navToChoosePayment()
            self.verifyErrorCodeForAutoPay()
        }
    }
    
    func handleAutoPaySecondaryTapBPH(type: AutoPayFailErrorTypeBPH) {
        switch type {
        case .APNotValidCardAmountDue, .APNotValidCheckingAmountDue:
            navToChatwithus()
        default:
            break
        }
    }
    
    // CMAIOS-2797
    private func verifyErrorCodeForAutoPay() {
        if let errorCode = historyInfo?.errorCode, (errorCode == "201" || errorCode == "591" || errorCode == "751" || errorCode == "750") {
            self.moveToMakePaymentScreen(paymethod: self.historyInfo?.paymethod)
        } else {
            navToChoosePayment()
        }
    }
    
}
