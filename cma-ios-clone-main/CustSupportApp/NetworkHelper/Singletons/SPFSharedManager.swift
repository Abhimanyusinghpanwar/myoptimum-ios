//
//  SPFSharedManager.swift
//  CustSupportApp
//
//  Created by vishali on 04/07/24.
//

import Foundation

class SPFSharedManager {
    class var shared: SPFSharedManager {
        struct Singleton {
            static let instance = SPFSharedManager()
        }
        return Singleton.instance
    }
    
    func showOneTimePaymentFailureScreen(errorType: ErrorType = .none, presentingVC: UIViewController, historyInfo: HistoryInfo? = nil, cardData: SpotLightCardsGetResponse.CardData? = nil, isFromSpotlight: Bool = true) {
        guard let viewcontroller = OneTimePaymentfailureVC.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.errorType = errorType
        viewcontroller.historyInfo = historyInfo
        viewcontroller.cardData = cardData
        viewcontroller.isFromSpotlight = isFromSpotlight
        //CMAIOS-2413 push SPF VC from more info for B&PH flow
        if !presentingVC.isKind(of: HomeScreenViewController.classForCoder()) {
            presentingVC.navigationController?.pushViewController(viewcontroller, animated: true)
        } else {
            //present SPF VC from more info for Spotlight flow
            let aNavigationController = UINavigationController(rootViewController: viewcontroller)
            aNavigationController.navigationBar.isHidden = true
            aNavigationController.modalPresentationStyle = .fullScreen
            presentingVC.present(aNavigationController, animated: true)
        }
    }
    
    func mapErrorCodeToSPTErrorType(errorCode: String, historyInfo: HistoryInfo? = nil, cardData: SpotLightCardsGetResponse.CardData? = nil, presentingVC: UIViewController, isFromSpotlight: Bool = true) {
        let errorString = errorCode.lowercased()
        var errorType: SPTFailErrorType = .none
        //CMAIOS-2439 Updated numeric error codes for SPF
        switch errorString {
        case "invalid bank or finbr", "numeric value out of range for xml tag eftt_bacct", "xml tag eftt_bacct should be numeric", "307", "xml tag eftt_bacct should be numeric.","750", "751": //CMA-2319 Addressed updated error codes
            //CMAIOS-2415 // CMAIOS-2638
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFNotValidCheckingNoAmountDue  : .SPFNotValidCheckingAmountDue
        case "card is expired", "522": //CMAIOS-2413
            errorType = .SPFFailCardExpired
            //CMAIOS-2415
             if isFromSpotlight {
                errorType = .SPFFailCardExpired
             } else {
                 //CMAIOS-2638
                 errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFFailCardExpiredNoAmountDue : .SPFFailCardExpired
             }
//        case "invalid cc number","591","201":
        case "invalid cc number", "invalid institution code","201","591","602","603": // CMAIOS-2663
            // CMAIOS-2638
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFNotValidCardNoAmountDue : .SPFNotValidCardAmountDue
        case "generic error", "401":
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFTechnicalNoAmountDue : .SPFTechnicalAmountDue//CMAIOS-2080, 2086
        case "30170", "509", "510" :
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFExceedLimitCheckingNoAmountDue : .SPFExceedLimitCheckingAmountDue
        case "credit floor", "lost/stolen", "do not honor", "processor decline", "restraint", "pickup", "suspected fraud", "insufficient fund", "revocation of authorization","302","502","534","303","806","501","596","521","571","572" :
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFExceedLimitCardNoAmountDue : .SPFExceedLimitCardAmountDue
        case "90001", "30168", "30167" :
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFDuplicateNoAmountDue : .SPFDuplicateAmountDue
        default:
            //errorType = .SPFFailDefaultMOP
            errorType = QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFTechnicalNoAmountDue : .SPFTechnicalAmountDue //CMAIOS-2338
        }
        self.handleMakePaymentErrorCodes(error: errorType, presentingVC: presentingVC, historyInfo: historyInfo, cardData: cardData, isFromSpotlight: isFromSpotlight)
    }
    
    func handleMakePaymentErrorCodes(error: Any, presentingVC: UIViewController, historyInfo: HistoryInfo? = nil, cardData: SpotLightCardsGetResponse.CardData? = nil, isFromSpotlight: Bool = true) {
        var errorType: ErrorType = .none
        if let scheduleError = error as? SPTFailErrorType {
            errorType = ErrorType.schedule(scheduleError)
        }
        //CMAIOS-2378, 2380
        if let autoPayError = error as? AutoPayFailErrorTypeBPH {
            errorType = ErrorType.autoPayBPH(autoPayError)
        }
        self.showOneTimePaymentFailureScreen(errorType: errorType, presentingVC: presentingVC, historyInfo: historyInfo, cardData: cardData, isFromSpotlight: isFromSpotlight)
    }
    
}
