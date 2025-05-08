//
//  HomeScreenViewController+ManageMauiApi.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 06/08/24.
//

import Foundation

extension HomeScreenViewController: MauiApisStatusDelegate {
    
    func checkMauiApiStateForRefresh(pullToRefresh: Bool = false) {
        //        QuickPayManager.shared.ismauiMainApiInProgress.isprogress = true
        
        switch (firstLaunch,
                QuickPayManager.shared.isMauiAccountListCompleted,
                QuickPayManager.shared.isGetAccountActivityCompleted,
                QuickPayManager.shared.isListBillsCompeletd,
                QuickPayManager.shared.isGetAccountBillCompleted) {
        case (true, true, true, true, true):
            if QuickPayManager.shared.isDeauthUser() { // CMAIOS-2462
                self.presentAccountBlockedScreen()
            } else {
                self.mauiBillAccountActivityApiRequest()
            }
        case (true, false, _, _, _):
            self.mauiAccoutsListRequest()
            self.performFailedSpotlightCardsRequest() // CMAIOS-2463
        case (false, false, _, _, _):
            if !pullToRefresh {
                DispatchQueue.main.async {
                    self.addLoader()
                    self.showODotAnimation()
                }
            }
            self.mauiAccoutsListRequest()
            self.performFailedSpotlightCardsRequest() // CMAIOS-2463
        case (true, true, false, _, _):
            self.mauiBillAccountActivityApiRequest()
            self.performFailedSpotlightCardsRequest() // CMAIOS-2463
        case (false, true, false, _, _):
            if !pullToRefresh {
                DispatchQueue.main.async {
                    self.addLoader()
                    self.showODotAnimation()
                }
            }
            self.mauiBillAccountActivityApiRequest()
            self.performFailedSpotlightCardsRequest() // CMAIOS-2463
        default:
            self.mauiBillAccountActivityApiRequest()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            SpotLightsManager.shared.configureSpotLightsForBillPay()
            self.reloadSpotlights()
        }
    }
    
    func mauiAccoutsListRequest() {
        QuickPayManager.shared.currentApiType = .accountList
        APIRequests.shared.mauiAccoutsListRequest(interceptor: QuickPayManager.shared.interceptor, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.isMauiAccountListCompleted = true
                    QuickPayManager.shared.modelAccountsList = value
                    self.mauiBillAccountActivityApiRequest()
                    self.checkForUpdateSpotlights()
                    Logger.info("MAUI Account List Response is \(String(describing: value))", sendLog: "MAUI Account List success")
                } else {
                    Logger.info("MAUI Account List Response is \(String(describing: error))")
                    QuickPayManager.shared.isMauiAccountListCompleted = false
                    self.performFailedSpotlightCardsRequest() // CMAIOS-2544
                    self.validateAndResetFlagsOnLogout()
                    QuickPayManager.shared.updateTheRetryFlags()
                }
            }
        })
    }
    
    private func mauiBillAccountActivityApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        QuickPayManager.shared.currentApiType = .getBillActivity
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetBillActivity = value
                    QuickPayManager.shared.isGetAccountActivityCompleted = true
                    Logger.info("Get Account Bill Activity: \(String(describing: value))", sendLog: "Get Account Bill Activity success")
                    if QuickPayManager.shared.isDeauthUser() { // CMAIOS-2462
                        self.presentAccountBlockedScreen()
                    } else {
                        //CMAIOS-2680
                        /*
                        if APIRequests.shared.isUpdateSpotlightCardRequests {
                            APIRequests.shared.isUpdateSpotlightCardRequests = false
                            self.hideDismissedSpotlightcards(spotLightId: APIRequests.shared.spotlightId)
                        } else {
                            self.performSpotlightRequests()
                        }
                         */
                        self.performSpotlightRequests() //CMAIOS-2680
                        self.mauiGetBillAccountApiRequest()
                    }
                } else {
                    QuickPayManager.shared.isGetAccountActivityCompleted = false
                    self.performFailedSpotlightCardsRequest() // CMAIOS-2544
                    self.validateAndResetFlagsOnLogout()
                    QuickPayManager.shared.updateTheRetryFlags()
                    Logger.info("Get Account Bill Activity failure: \(String(describing: error))")
                    // Error scenario
                }
            }
        })
    }
    
    private func mauiGetListPaymentApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = billSharedManager.getAccountName() as AnyObject?
        QuickPayManager.shared.currentApiType = .listBills
        APIRequests.shared.mauiListPaymentRequest(interceptor: billSharedManager.interceptor, jsonParams: params, makeDefault: false, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelListPayment = value
                    QuickPayManager.shared.isListBillsCompeletd = true
                    Logger.info("Maui List Payment Response is \(String(describing: value))",sendLog: "Maui List Payment success")
                    self.mauiRequestListBills()
//                    self.mauiOutageAlertApiRequest(reloadOutageCard: false)
                    self.removeLoaderView()
                    self.reloadSpotlights()
//                    QuickPayManager.shared.ismauiMainApiInProgress = (false, false)
                } else {
                    QuickPayManager.shared.isListBillsCompeletd = false
                    self.performFailedSpotlightCardsRequest() // CMAIOS-2544
                    self.validateAndResetFlagsOnLogout()
                    Logger.info("Maui List Payment Response is \(String(describing: error))")
                }
            }
        })
    }
        
    private func mauiGetBillAccountApiRequest() {
        var params = [String: AnyObject]()
        params["name"] = billSharedManager.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: billSharedManager.interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    QuickPayManager.shared.isGetAccountBillCompleted = true
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill success")
                    self.mauiGetListPaymentApiRequest()
                } else {
                    QuickPayManager.shared.isGetAccountBillCompleted = false
                    self.performFailedSpotlightCardsRequest() // CMAIOS-2544
                    self.validateAndResetFlagsOnLogout()
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
                }
            }
        })
    }
    
    func mauiRequestListBills() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiBillListRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayListBill = value
                    Logger.info("List Bill Response is \(String(describing: value))", sendLog: "List Bill Success")
                } else {
                    Logger.info("List Bill Response is \(String(describing: error))")
                }
            }
        })
    }
    
    // CMAIOS-2463
    func checkForUpdateSpotlights() {
        if let dismissArray = PreferenceHandler.getValuesForKey("dismissibleSpotlights") as? NSMutableArray, dismissArray.count > 0 {
            self.updateSpotlightCardsRequest(cards: dismissArray)
            PreferenceHandler.removeDataForKey("dismissibleSpotlights")
        } else {
            self.performSpotlightRequests()
        }
    }
    
    // CMAIOS-2463
    func updateSpotlightCardsRequest(cards: NSMutableArray) {
        var params = [String:AnyObject]()
        params["cards"] = cards as AnyObject
            APIRequests.shared.mauiUpdateSpotLightCards(params: params) { success, value, error in
                if success {
                    self.performSpotlightRequests()
                }
            }
    }
    
    // CMAIOS-2463
    func performFailedSpotlightCardsRequest() {
        APIRequests.shared.mauiGetFailureSpotLight() { success, value, error in
            if success {
                DispatchQueue.main.async {
                    self.checkBillPayDataForSpotlight()
                }
            }
        }
    }
    
    // CMAIOS-2462
    func presentAccountBlockedScreen() {
        self.removeLoaderView()
        DispatchQueue.main.async {
            let deAuthVewController = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(identifier: "QuickPayDeAuthViewController") as QuickPayDeAuthViewController
            deAuthVewController.modalPresentationStyle = .fullScreen
            deAuthVewController.deAuthFlow = .homeScreen
            deAuthVewController.dismissCallBack = {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: false)
                }
            }
            self.navigationController?.pushViewController(deAuthVewController, animated: false)
        }
    }
    
    // CMAIOS-2552
    func updateFlagForFailedMauiApiCall() {
        if QuickPayManager.shared.currentApiType == .accountList {
            QuickPayManager.shared.isMauiAccountListCompleted = false
        } else if QuickPayManager.shared.currentApiType == .getBillActivity {
            QuickPayManager.shared.isGetAccountActivityCompleted = false
        } else if QuickPayManager.shared.currentApiType == .getBillAccount {
            QuickPayManager.shared.isGetAccountBillCompleted = false
        } else if QuickPayManager.shared.currentApiType == .listBills {
            QuickPayManager.shared.isListBillsCompeletd = false
        }
    }
        
    // CMAIOS-2552
    // MauiApisStatusDelegate
    func handle500Error() {
        self.updateFlagForFailedMauiApiCall()
        self.handleErrorBillPayApis()
    }
    
}

