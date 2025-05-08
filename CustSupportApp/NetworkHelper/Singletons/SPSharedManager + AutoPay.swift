//
//  SPSharedManager + AutoPay.swift
//  CustSupportApp
//
//  Created by Vishali on 23/07/24.
//

import Foundation

extension SPFSharedManager {
    
    func mapErrorCodeToAutoPayErrorType(errorCode: String, historyInfo: HistoryInfo? = nil, presentingVC: UIViewController, isFromSpotlight: Bool) {
        let errorString = errorCode.lowercased()
        var errorType: AutoPayFailErrorTypeBPH = .none
        switch errorString {
        case "generic error", "401":
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .APTechnicalDifficultiesNoAmountDue : .APTechnicalDifficultiesAmountDue//CMAIOS-2080, 2086
        case "credit floor", "lost/stolen", "do not honor", "processor decline", "restraint", "pickup", "suspected fraud", "insufficient fund", "revocation of authorization","302","502","534","303","806","501","596","521","571","572" :
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .APExceedLimitCardNoAmountDue : .APExceedLimitCardAmountDue//CMAIOS-2379, CMAIOS-2381
        case "card is expired","522":
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .APCardExpiredNoAmountDue : .APCardExpiredAmountDue//CMAIOS-2383, 2382
        case "30170", "509", "510":
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .APExceedLimitCheckingNoAmountDue : .APExceedLimitCheckingAmountDue // CMAIOS-2663
        case "invalid cc number", "invalid institution code","201","591","602","603": //CMA-2364 // CMAIOS-2663,
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? . APNotValidCardNoAmountDue : .APNotValidCardAmountDue // CMAIOS-2663
        case "invalid bank or finbr", "numeric value out of range for xml tag eftt_bacct", "xml tag eftt_bacct should be numeric", "307", "xml tag eftt_bacct should be numeric.","750", "751":
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .APNotValidCheckingNoAmountDue : .APNotValidCheckingAmountDue
        default:
            errorType = .none
        }
        self.handleMakePaymentErrorCodes(error: errorType, presentingVC: presentingVC, historyInfo: historyInfo, isFromSpotlight: isFromSpotlight)
    }
}
