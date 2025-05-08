//
//  HomeScreenViewController+ErrorRouting.swift
//  CustSupportApp
//
//  Created by riyaz on 29/05/24.
//

import Foundation
import UIKit
import Lottie

extension HomeScreenViewController {
    
    func showOneTimePaymentFailureScreen(errorType: ErrorType = .none, cardData: SpotLightCardsGetResponse.CardData, isAutoPayFailure: Bool) {
        guard let viewcontroller = OneTimePaymentfailureVC.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.errorType = errorType
        viewcontroller.cardData = cardData
        viewcontroller.isAutoPaymentErrorFlow = isAutoPayFailure // CMAIOS-2119
        if isAutoPayFailure == true { // CMAIOS-2119
            QuickPayManager.shared.cardDataDict = cardData
        }
        viewcontroller.isFromSpotlight = true //Crash fix
        let aNavigationController = UINavigationController(rootViewController: viewcontroller)
        aNavigationController.navigationBar.isHidden = true
        aNavigationController.modalPresentationStyle = .fullScreen
        self.present(aNavigationController, animated: true)
    }
    
    func mapErrorCodeToSPTErrorType(errorCode: String, cardData: SpotLightCardsGetResponse.CardData, isAutoPayFailure: Bool = false) {
        let errorString = errorCode.lowercased()
//        var errorType: SPTFailErrorType = .none
        var errorType: Any
        switch errorString {
        case "invalid bank or finbr", "numeric value out of range for xml tag eftt_bacct", "xml tag eftt_bacct should be numeric", "307", "xml tag eftt_bacct should be numeric.","750", "751":
            if isAutoPayFailure {
                /*errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .APNotValidCheckingNoAmountDue  : .APNotValidCheckingAmountDue) as AutoPayFailErrorType*/
                errorType = .APNotValidCheckingAmountDue as AutoPayFailErrorType
            } else {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFNotValidCheckingNoAmountDue  : .SPFNotValidCheckingAmountDue) as SPTFailErrorType
            }
        case "card is expired","522":
            if isAutoPayFailure {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .APFailCardExpiredNoAmountDue  : .APFailCardExpiredAmountDue) as AutoPayFailErrorType
            } else {
                errorType = .SPFFailCardExpired as SPTFailErrorType
            }
        case "invalid cc number","591","201","invalid institution code","602","603"://CMAIOS-2877
            if isAutoPayFailure {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .APNotValidCardNoAmountDue : .APNotValidCardAmountDue) as AutoPayFailErrorType
            } else {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFNotValidCardNoAmountDue : .SPFNotValidCardAmountDue) as SPTFailErrorType
            }
        case "generic error", "401":
            if isAutoPayFailure {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .APTechnicalDifficultiesNoAmountDue : .APTechnicalDifficultiesAmountDue) as AutoPayFailErrorType//CMAIOS-2365, 2431
            } else {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFTechnicalNoAmountDue : .SPFTechnicalAmountDue) as SPTFailErrorType//CMAIOS-2080, 2086
            }
        case "30170" :
            //CMAIOS-2112, 2104
            if isAutoPayFailure {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .APExceedLimitCheckingNoAmountDue :  .APExceedLimitCheckingAmountDue) as AutoPayFailErrorType
            } else {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFExceedLimitCheckingNoAmountDue : .SPFExceedLimitCheckingAmountDue) as SPTFailErrorType
            }
        case "credit floor", "lost/stolen", "do not honor", "processor decline", "restraint", "pickup", "suspected fraud", "insufficient fund", "revocation of authorization","302","502","534","303","806","501","596","521","571","572" :
            //CMAIOS-2111, 2367
            if isAutoPayFailure {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .APExceedLimitCardNoAmountDue :  .APExceedLimitCardAmountDue) as AutoPayFailErrorType
            } else {
                errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFExceedLimitCardNoAmountDue : .SPFExceedLimitCardAmountDue) as SPTFailErrorType
            }
        case "90001", "30168", "30167" :
            errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFDuplicateNoAmountDue : .SPFDuplicateAmountDue) as SPTFailErrorType
        default:
            //errorType = .SPFFailDefaultMOP
            errorType = (QuickPayManager.shared.initialScreenFlow == .noDue ? .SPFTechnicalNoAmountDue : .SPFTechnicalAmountDue) as SPTFailErrorType //CMAIOS-2338
        }
        // CMAIOS-2119: isAutoPayFailure param
        self.handleMakePaymentErrorCodes(error: errorType, selectedCardData: cardData, isAutoPayFailure: isAutoPayFailure)
    }
    
    func handleMakePaymentErrorCodes(error: Any,  selectedCardData: SpotLightCardsGetResponse.CardData, isAutoPayFailure: Bool) {
        var errorType: ErrorType = .none
        if let scheduleError = error as? SPTFailErrorType {
            errorType = ErrorType.schedule(scheduleError)
        } else if let autoPayError = error as? AutoPayFailErrorType { // CMAIOS-2120
            errorType = ErrorType.autoPay(autoPayError)
        }
        // CMAIOS-2119: isAutoPayFailure param
        self.showOneTimePaymentFailureScreen(errorType: errorType, cardData: selectedCardData, isAutoPayFailure: isAutoPayFailure)
    }
    
}
