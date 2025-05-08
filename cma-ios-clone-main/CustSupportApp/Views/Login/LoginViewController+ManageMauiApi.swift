//
//  LoginViewController+ManageMauiApi.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 02/08/24.
//

import Foundation

extension LoginViewController {
    
    func mauiAccoutsListRequest(_ dispatchGroup: DispatchGroup) {
        self.dispatchGroupQueue = dispatchGroup
        QuickPayManager.shared.currentApiType = .accountList
        APIRequests.shared.mauiAccoutsListRequest(interceptor: QuickPayManager.shared.interceptor, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.isMauiAccountListCompleted = true
                    QuickPayManager.shared.modelAccountsList = value
                    self.mauiGetAccountActivityRequest(dispatchGroup)
                    self.checkForUpdateSpotlights(dispatchGroup)
                    Logger.info("MAUI Account List Response is \(String(describing: value))", sendLog: "MAUI Account List success")
                } else {
                    Logger.info("MAUI Account List Response is \(String(describing: error))")
                    QuickPayManager.shared.isMauiAccountListCompleted = false
//                    self.validateFailureCodeToUpdateErrrMsg(code: code)
                    self.mauiAPISuccess = true
                    QuickPayManager.shared.updateTheRetryFlags()
                    dispatchGroup.leave()
                }
            }
        })
    }
    
    func mauiGetAccountActivityRequest(_ dispatchGroup: DispatchGroup) {
        var params = [String: AnyObject]()
        params["name"] = paymentSharedManager.getAccountNam() as AnyObject?
        self.dispatchGroupQueue = dispatchGroup
        QuickPayManager.shared.currentApiType = .getBillActivity
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.isGetAccountActivityCompleted = true
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    Logger.info("Get Account Bill Activity Response is \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    self.mauiAPISuccess = true
                    self.mauiRequestGetAccountBill()
                    self.mauiGetCustomerInfo()
                    QuickPayManager.shared.updateTheRetryFlags()
                    dispatchGroup.leave()
                } else {
                    Logger.info("Get Account Bill Activity Response is \(String(describing: error))")
                    QuickPayManager.shared.isGetAccountActivityCompleted = false
//                    self.validateFailureCodeToUpdateErrrMsg(code: code)
                    self.mauiAPISuccess = true
                    dispatchGroup.leave()
                }
            }
        })
    }
    
    func mauiRequestGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = paymentSharedManager.getAccountNam() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.isGetAccountBillCompleted = true
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.mauiRequestListBills()
                } else {
                    QuickPayManager.shared.isGetAccountBillCompleted = false
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                }
            }
        })
    }
    
    func mauiRequestListBills() {
        var params = [String: AnyObject]()
        params["name"] = paymentSharedManager.getAccountNam() as AnyObject?
        APIRequests.shared.mauiBillListRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.isListBillsCompeletd = true
                    QuickPayManager.shared.modelQuickPayListBill = value
                    Logger.info("List Bill Response is \(String(describing: value))", sendLog: "List Bill Success")
                } else {
                    QuickPayManager.shared.isListBillsCompeletd = false
                    Logger.info("List Bill Response is \(String(describing: error))")
                }
            }
        })
    }
        
}
