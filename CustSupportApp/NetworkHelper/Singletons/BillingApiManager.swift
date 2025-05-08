//
//  BillingApiManager.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 05/08/24.
//

import Foundation

extension QuickPayManager {
    func retryRequiredForBlockerApisCount() -> Bool {
        var retryRequired = false
        switch self.currentApiType {
        case .getBillActivity:
            if self.mauiAccountApiRetryCount < 1 {
                self.mauiAccountApiRetryCount += 1
                retryRequired = true
            }
        case .accountList:
            if self.mauiGetBillActAccApiRetryCount < 1 {
                self.mauiGetBillActAccApiRetryCount += 1
                retryRequired = true
            }
        default: break
        }
        return retryRequired
    }
        
    func updateTheRetryFlags() {
        QuickPayManager.shared.mauiAccountApiRetryCount = 0
        QuickPayManager.shared.mauiGetBillActAccApiRetryCount = 0
    }
    
    func isDeauthUser() -> Bool {
        if QuickPayManager.shared.getDeAuthState() == "DE_AUTH_STATE_DEAUTH" {
            return true
        }
        return false
    }
    
    func getAccountDisplayNumber() -> String { // CMAIOS:-2468
        var displayAccountNumber = ""
        if let displayAccNum = QuickPayManager.shared.modelAccountsList?.accounts?.first?.legacy?.displayAccountNumber {
            displayAccountNumber = displayAccNum
        } else {
            displayAccountNumber = MyWifiManager.shared.displayAccountNumber
        }
        return displayAccountNumber
    }
}
