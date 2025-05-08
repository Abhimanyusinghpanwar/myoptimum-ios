//
//  File.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 19/01/23.
//

import Foundation
import Alamofire

// MARK: - MAUI API REQUESTS
extension APIRequests {
    // Quick Pay - List Accounts
    func mauiAccoutsListRequest(interceptor: RequestInterceptor?, completionHandler: @escaping (_ success: Bool, _ value: QuickPayAccountsResponseModel?, _ error: AFError?, _ statusCode: Int) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_ACCOUNTS_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiAccounts, jsonParams: nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayAccountsResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Accounts List Request Succeded")
                completionHandler(true, value, nil, response.response?.statusCode ?? 0)
            case .failure(let value):
                Logger.info("Quick Pay Accounts List Request Failed")
                completionHandler(false, nil, value, response.response?.statusCode ?? 0)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: urlPath, uiMessage: "We are experiencing technical difficulties, and cannot access your account at this time.  Please check back later.", response: response.response, responseData: response.data)
            }
        })
    }
    
    // Quick Pay - Outage Alert
    func mauiOutageAlertRequest(interceptor: RequestInterceptor?, completionHandler: @escaping (_ success: Bool, _ value: QuickPayOutageResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_ALERT_OUTAGE_URL + "?filter=ALERT_TYPE_OUTAGE&name=\(QuickPayManager.shared.getAccountName())"
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiOutageAlert, jsonParams: nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayOutageResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Outage Alert Request Succeded")
                if let outageInfo = value.alerts, !outageInfo.isEmpty, let outageData = outageInfo.first, let outageName = outageData.name, !outageName.isEmpty, outageName == "NO_OUTAGE" {
                    completionHandler(true, nil, nil)
                } else {
                    completionHandler(true, value, nil)
                }
            case .failure(let value):
                Logger.info("Outage Alert Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Home", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Pay Method List
    func mauiPayMethodListRequest(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayMethodsResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_PAYMETHODS_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiPayMethods, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayMethodsResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Method List Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Method List Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - List Bills
    func mauiBillListRequest(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayListBillsResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_LISTBILLS_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiListBills, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayListBillsResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay List Bills Request Succeded")
                QuickPayManager.shared.isListBillsCompeletd = true
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay List Bills Request Failed")
                QuickPayManager.shared.isListBillsCompeletd = false
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Get Bill
    func mauiGetBillRequest(params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayGetBillResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETBILL_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiGetBill, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: QuickPayGetBillResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Get Bill Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Get Bill Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Get Account Bill
    func mauiGetAccountBillRequest(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayGetAccountBillResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        QuickPayManager.shared.currentApiType = .getBillAccount
        let urlPath = MAUI_GETACCOUNTBILL_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiGetAccountBill, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayGetAccountBillResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Get Account Bill Request Succeded")
                QuickPayManager.shared.checkForLegacySettings(value)
                self.isGetAccountBillApiFailed = false
                completionHandler(true, value, nil)
            case .failure(let value):
                self.isGetAccountBillApiFailed = true
                Logger.info("Quick Pay Get Account Bill Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Billing", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Get Bill Account Activity
    func mauiGetAccountBillActivityRequest(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayGetBillActivityResponseModel?, _ error: AFError?, _ statusCode: Int) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETACCOUNTACTIVITY_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiBillAccountActivity, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayGetBillActivityResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Bill Account Activity Request Succeded")
                completionHandler(true, value, nil, response.response?.statusCode ?? 0)
            case .failure(let error):
                Logger.info("Quick Pay Bill Account Activity Request Failed")
                completionHandler(false, nil, error, response.response?.statusCode ?? 0)
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
            }
        })
    }
    
    // Quick Pay - Next Payment Due Activity
    func mauiNextPaymentDueRequest(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayNextPaymentDueResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_NEXTPAYMENTDUE_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiNextPaymentDue, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayNextPaymentDueResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Next Payment Due Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Next Payment Due Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Get Bill Communication Preferences Activity
    func mauiBillPreferencesRequest(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayGetBillPrefernceResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETBIllPREFERENCES_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiBillPreferences, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayGetBillPrefernceResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Bill Communication Preferences Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Bill Communication Preferences Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Update Bill Communication Preferences Activity
    func mauiUpdateBillPreferencesRequest(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayUpdateBillPrefernceResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_UPDATEBILLPREFERENCES_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiUpdateBillPreferences, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayUpdateBillPrefernceResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Quick Pay Update Bill Communication Preferences Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Update Bill Communication Preferences Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Create Payment
    func mauiCreatePaymentRequest(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], isDefault: Bool, paramName: String, nickName: String, completionHandler: @escaping (_ success: Bool, _ value: QuickPayCreatePaymentResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let nameParam = "?name=\(paramName)"
        //        let paramNickName = "&payment_nickname=\(nickName)"
        //        let urlPath = MAUI_CREATEPAYMENT_PATH_URL + nameParam + paramNickName
        var urlPath = MAUI_CREATEPAYMENT_PATH_URL + nameParam
        if isDefault {
            urlPath = MAUI_CREATEPAYMENT_PATH_URL + nameParam + "&default=true"
        }
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreatePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayCreatePaymentResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Create Payment Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick PayCreate Payment Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    //CMAIOS-2627, 2620
    //Quick Pay - Update ACH Pay Method Nickname
    func mauiUpdateACHPayMethodNickName(interceptor: RequestInterceptor?, accountName: String, request: EditPayMethodRequest, completionHandler: @escaping (Result<EditPayMethodResponse, Error>) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let paramName = "?name=\(accountName)"
        let urlPath = MAUI_UPDATEPAYMETHOD_PATH_URL + paramName
        let apiRequest = RequestBuilder(url: urlPath, method: .put, serviceKey: .mauiSetDefaultPayMethod, jsonParams: request.dictionary as? [String: AnyObject], encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        apiRequest.validate().responseDecodable(of: EditPayMethodResponse.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Quick Pay Update Pay Method Request Succeded")
                completionHandler(.success(value))
            case .failure(let value):
                Logger.info("Quick Pay Update Pay Method Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(.failure(value))
            }
        })
    }
    
    // Quick Pay - Update Pay Method
    func mauiUpdatePayMethod(interceptor: RequestInterceptor?, accountName: String, request: UpdatePayMethodRequest, completionHandler: @escaping (Result<UpdatePayMethodResponse, Error>) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let paramName = "?name=\(accountName)"
        let urlPath = MAUI_UPDATEPAYMETHOD_PATH_URL + paramName
        let apiRequest = RequestBuilder(url: urlPath, method: .put, serviceKey: .mauiSetDefaultPayMethod, jsonParams: request.dictionary as? [String: AnyObject], encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        apiRequest.validate().responseDecodable(of: UpdatePayMethodResponse.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Quick Pay Update Pay Method Request Succeded")
                completionHandler(.success(value))
            case .failure(let value):
                Logger.info("Quick Pay Update Pay Method Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(.failure(value))
            }
        })
    }
    
    // Quick Pay - Default Pay Method
    func mauiSetDefaultPayMethodRequest(paramName: String, completionHandler: @escaping (_ success: Bool, _ value: QuickPaySetDefaultResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let paramName = "?name=\(paramName)"
        let urlPath = MAUI_SETDEFAULTPAYMETHOD_PATH_URL + paramName
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiSetDefaultPayMethod, jsonParams: nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: QuickPaySetDefaultResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Default Pay Method Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Default Pay Method Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Get Auto Pay
    func mauiGetAutoPayRequest(interceptor: RequestInterceptor?, param: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayGetAutoPayResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETAUTOPAY_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiGetAutoPay, jsonParams: param, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayGetAutoPayResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Get Auto Pay Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Get Auto Pay Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Creat Auto Pay
    func mauiCreateAutoPayRequest(interceptor: RequestInterceptor?, param: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayGetAutoPayResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETAUTOPAY_PATH_URL
        QuickPayManager.shared.currentApiType = .createAutoPay
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreateAutoPay, jsonParams: param, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayGetAutoPayResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Create Auto Pay Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Create Auto Pay Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "FinishSetup", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Update Auto Pay Method
    func mauiUpdateAutoPayMethod(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (Result<UpdateAutoPayResponse, Error>) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETAUTOPAY_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .put, serviceKey: .mauiSetDefaultPayMethod, jsonParams: params, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: UpdateAutoPayResponse.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Quick Pay Update Pay Method Request Succeded")
                completionHandler(.success(value))
            case .failure(let value):
                Logger.info("Quick Pay Update Pay Method Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(.failure(value))
            }
        })
    }
    
    // Quick Pay - Remove Auto Pay Method
    func mauiRemoveAutoPayMethod(interceptor: RequestInterceptor?, autoPayName: String, completionHandler: @escaping (Result<RemoveAutoPayResponse, Error>) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_REMOVEAUTOPAY_PATH_URL
        let params: [String: AnyObject] = ["name": autoPayName as AnyObject]
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiSetDefaultPayMethod, jsonParams: params, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: RemoveAutoPayResponse.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info(response.debugDescription, sendLog: "Quick Pay Remove Auto Pay Method Request Succeded")
                completionHandler(.success(value))
            case .failure(let value):
                Logger.info("Quick Pay Remove Auto Pay Method Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(.failure(value))
            }
        })
    }
    
    // Quick Pay - Account restriction
    func mauiGetAccountRestrictionRequest(param: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: QuickPayAccountRestrictionResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_GETACCOUNTRESTRICTION_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiAccountRestriction, jsonParams: param, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: QuickPayAccountRestrictionResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Account restriction Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Account restriction Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Create Immediate Payment
    func mauiImmediatePaymentRequest(interceptor: RequestInterceptor?, jsonParams: [String: AnyObject], makeDefault: Bool, completionHandler: @escaping (_ success: Bool, _ value: QuickPayImmediatePaymentResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        var urlPath = MAUI_IMMEDIATEPAYMEN_PATH_URL
        if makeDefault {
            urlPath = MAUI_IMMEDIATEPAYMEN_PATH_URL + "?default=true"
        }
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiImmediatePayment, jsonParams: jsonParams, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayImmediatePaymentResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay Create Immediate Payment Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Create Immediate Payment Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Create One Time Payment for /* NEW CARD or NEW ACH */
    func mauiCreateOneTimePayment(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], isDefault: Bool, isAchFlow: Bool = false, completionHandler: @escaping (_ success: Bool, _ value: QuickPayCreateOneTimePaymentResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        var getUrlPathType = (isAchFlow == true) ? MAUI_ACH_ONETIMEPAYMENT_PATH_URL: MAUI_ONETIMEPAYMENT_PATH_URL
        var urlPath = getUrlPathType + "?name=\(QuickPayManager.shared.getAccountNam())"
        if isDefault { // ?save=true&default=true
            urlPath = urlPath + "&save=\(isDefault)" + "&default=\(isDefault)"
        }
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreateOneTimePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayCreateOneTimePaymentResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick One Time Paymethod Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick One Time Paymethod Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    func mauiListPaymentRequest(interceptor: RequestInterceptor?, jsonParams: [String: AnyObject], makeDefault: Bool, completionHandler: @escaping (_ success: Bool, _ value: QuickPayListPaymentResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        var urlPath = MAUI_LISTPAYMENT_PATH_URL
        if makeDefault {
            urlPath = MAUI_LISTPAYMENT_PATH_URL + "?default=true"
        }
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiListPayment, jsonParams: jsonParams, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayListPaymentResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Quick Pay List Payment Request Succeded")
//                self.isListPaymentsApiFailed = false // CMAIOS-2480
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Quick Pay Create List Payment Request Failed")
//                self.isListPaymentsApiFailed = true
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Home", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Billing history - Consolidated Details
    func mauiGetConsolidatedDetails(interceptor: RequestInterceptor?, params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: ConsolidatedDetailsResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_CONSOLIDATED_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiConsolidatedDetails, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: ConsolidatedDetailsResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Consolidated Details Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Consolidated Details Request Failed")
                let errorLogger = APIErrorLogger()
                let urlWithQuery = (urlPath + "?name=" + (params["name"] as! String))
                errorLogger.apiErrorLogginCall(
                    requestTimeStamp: requestTimeStamp,
                    screen: "Billing & Payment History",
                    body: "",
                    requestURL: urlWithQuery,
                    uiMessage: "",
                    response: response.response,
                    responseData: response.data
                )
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Schedule payment with /* NEW CARD or NEW ACH */
    // Same QuickPayCreateOneTimePaymentResponseModel can be used for Schedule payment model
    // We can use same .mauiCreateOneTimePayment as servicekey
    func mauiCreateSchedulePaymentNewCardOrACH(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], isDefault: Bool, isAchFlow: Bool = false, completionHandler: @escaping (_ success: Bool, _ value: QuickPayCreateOneTimePaymentResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        var getUrlPathType = (isAchFlow == true) ? MAUI_ACH_ONETIMEPAYMENT_PATH_URL: MAUI_ONETIMEPAYMENT_PATH_URL
        var urlPath =  getUrlPathType + "?name=\(QuickPayManager.shared.getAccountNam())"
        if isDefault { // ?save=true&default=true
            urlPath = urlPath + "&save=\(isDefault)" + "&default=\(isDefault)"
        }
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreateOneTimePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayCreateOneTimePaymentResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Schedule payment with new Paymethod Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Schedule payment with new Paymethod Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Schedule payment with existing paymethod
    func mauiCreateSchedulePayment(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: CreateScheduleResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_IMMEDIATEPAYMEN_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreateOneTimePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: CreateScheduleResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Create Schedule payment Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Create Schedule payment Payment Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Schedule Payment Update
    // We can use same .mauiCreateOneTimePayment as servicekey
    func mauiUpdateSchedulePayment(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: UpdateSchedulePaymentModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_IMMEDIATEPAYMEN_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreateOneTimePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: UpdateSchedulePaymentModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Update Schedule Payment Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Update Schedule Payment Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Remove Payment / Delete Payment / Cancel Payment
    // We can use same .mauiCreateOneTimePayment as servicekey
    func mauiCancelScheduledPayment(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: RemoveScheduleResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let urlPath = MAUI_IMMEDIATEPAYMEN_PATH_URL + "/" + "remove"
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreateOneTimePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: RemoveScheduleResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Schedule Payment Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Schedule Payment Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    func mauiGetCustomerTenure(completionHandler:@escaping (_ success: Bool, _ response: CustomerTenure?, _ error: AFError?) -> Void) {
        var params = [String: AnyObject]()
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        let urlPath = MAUI_CUSTOMER_PATH_URL
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiCustomer, jsonParams: params, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: CustomerTenure.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                completionHandler(true, value, nil)
            case .failure(let value):
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    // ManagePaymentMethod - DeleteMOP CMAIOS-2578
    func mauiDeleteMOP(payMethodName: String, completionHandler: @escaping (_ success: Bool, _ value: DeleteMOPResponseModel?, _ error: AFError?) -> Void) {
        let getUrlPathType = MAUI_DELETE_MOP_PATH_URL
        let encodedPaymentName =  payMethodName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let urlPath = getUrlPathType + "?name=\(encodedPaymentName)"
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiDeleteMOP, jsonParams: nil, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: DeleteMOPResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Delete MOP Request Succeeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Delete MOP Request Failed")
                completionHandler(false, nil, value)
            }
        })
    }

    // Quick Pay - Get Spotlight Cards
    func mauiGetSpotLightCards(flowType: (outageFlow: Bool, gatewayActive: Bool) = (false, false), completionHandler: @escaping (_ success: Bool, _ value: SpotLightCardsGetResponse?, _ error: AFError?) -> Void) {
//        var requestTimeStamp = ""
//        requestTimeStamp = Date().getDateForErrorLog()
        let getUrlPathType = MAUI_SPOTLIGHT_CARD_PATH_URL
        var urlPath = getUrlPathType + "?name=\(QuickPayManager.shared.getAccountNam())"
        let lastETR = PreferenceHandler.getValuesForKey("lastETR") != nil ? PreferenceHandler.getValuesForKey("lastETR") as! String : ""
        
//        switch (flowType.outageFlow, flowType.gatewayActive) { // CMAIOS:-2505
//        case (true, true): // If outage is detected and gateway is active
//            urlPath = urlPath + "&lastETR=\(lastETR)"
//        case (true, false): // If outage is detected and gateway is down
//            urlPath = urlPath + "&lastETR=\(lastETR)" + "&isGatewayActive=\(false)"
//        default:
//            urlPath = urlPath + "&lastETR=\(lastETR)" + "&isGatewayActive=\(MyWifiManager.shared.isOperationalStatusOnline)"
//        }
        if MyWifiManager.shared.isOperationalStatusOnline {
            urlPath = urlPath + "&lastETR=\(lastETR)" + "&isGatewayActive=\(true)"
        } else {
            urlPath = urlPath + "&lastETR=\(lastETR)"
        }
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiSpotLightCards, jsonParams: nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: SpotLightCardsGetResponse.self, completionHandler: { response in
            /**Uncomment Below to simulate Failure Spotlight Card and comment the switch block**/
            /*let cardData: SpotLightCardsGetResponse.CardData = SpotLightCardsGetResponse.CardData.init(id: "billing_unavailable", title: "Sorry, Billing is not available right now.", body: "You can still access the rest of the app.", image: "billing_unavailable", dismissible: false, wasDismissed: false, wasViewed: false, template: "midnightblue_billing_unavailable", date: "2024-08-05T14:43:39.080712168-04:00", name: "", link: "", tapTarget: "mybill", amount: "", priorityKey: "4.1", payNickName: "", GAkey: "", errorCode: "homepagecard_billing_not_available_right_now")
            
            let res = SpotLightCardsGetResponse.init(cards: [cardData])
            SpotLightsManager.shared.spotLightCards = res
            SpotLightsManager.shared.saveDismissibleCards()
            completionHandler(true, res, nil)*/
            switch response.result {
            case .success(let value):
                Logger.info("SpotlightCard Request Succeded")
                SpotLightsManager.shared.spotLightCards = value
                /**Temporary Code to check the changed priority of billing cards. As middleware changes are not deployed on prod**/
                for i in (0 ..< SpotLightsManager.shared.spotLightCards.cards!.count) {
                    if SpotLightsManager.shared.spotLightCards.cards![i]
                        .priorityKey == "4.1" {
                        SpotLightsManager.shared.spotLightCards.cards![i]
                            .priorityKey = "3.1"
                    } else if SpotLightsManager.shared.spotLightCards.cards![i]
                        .priorityKey == "4.2" {
                        SpotLightsManager.shared.spotLightCards.cards![i]
                            .priorityKey = "3.2"
                    }
                }
                SpotLightsManager.shared.saveDismissibleCards()
                SpotLightsManager.shared.saveLastETRValueIfExists() //CMAIOS-2591
                SpotLightsManager.shared.gAdCardEligible = value.googleAdEligible
                if ConfigService.shared.ad_enabled.lowercased() == "true" && value.googleAdEligible {
                    CustomGAdLoader.shared.loadGoogleAd()
                }
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("SpotlightCard Request Failed")
//                let errorLogger = APIErrorLogger()
//                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Home", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                SpotLightsManager.shared.configureSpotLightsForThankYou()
                completionHandler(false, nil, value)
            }
        })
    }
    
    func mauiGetFailureSpotLight(completionHandler: @escaping (_ success: Bool, _ value: SpotLightCardsGetResponse?, _ error: AFError?) -> Void) {
        var urlPath = MAUI_SPOTLIGHT_CARD_PATH_URL
        //CMAIOS-2591
        let lastETR = PreferenceHandler.getValuesForKey("lastETR") != nil ? PreferenceHandler.getValuesForKey("lastETR") as! String : ""
//        urlPath = urlPath + "&lastETR=\(lastETR)" + "&isGatewayActive=\(MyWifiManager.shared.isOperationalStatusOnline)"
        if MyWifiManager.shared.isOperationalStatusOnline {
            urlPath = urlPath + "?lastETR=\(lastETR)" + "&isGatewayActive=\(true)"
        } else {
            urlPath = urlPath + "?lastETR=\(lastETR)"
        }
        let request = RequestBuilder(url: urlPath, method: .get, serviceKey: .mauiSpotLightCards, jsonParams: nil, encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: SpotLightCardsGetResponse.self, completionHandler: { response in
            /**Uncomment Below to simulate Failure Spotlight Card and comment the switch block**/
            /*let cardData: SpotLightCardsGetResponse.CardData = SpotLightCardsGetResponse.CardData.init(id: "billing_unavailable", title: "Sorry, Billing is not available right now.", body: "You can still access the rest of the app.", image: "billing_unavailable", dismissible: false, wasDismissed: false, wasViewed: false, template: "midnightblue_billing_unavailable", date: "2024-08-05T14:43:39.080712168-04:00", name: "", link: "", tapTarget: "mybill", amount: "", priorityKey: "4.1", payNickName: "", GAkey: "", errorCode: "homepagecard_billing_not_available_right_now")
            
            let res = SpotLightCardsGetResponse.init(cards: [cardData])
            SpotLightsManager.shared.spotLightCards = res
            SpotLightsManager.shared.saveDismissibleCards()
            completionHandler(true, res, nil)*/
            switch response.result {
            case .success(let value):
                Logger.info("SpotlightCard Request Succeded")
                SpotLightsManager.shared.spotLightCards = value
                /**Temporary Code to check the changed priority of billing cards. As middleware changes are not deployed on prod**/
                for i in (0 ..< SpotLightsManager.shared.spotLightCards.cards!.count) {
                    if SpotLightsManager.shared.spotLightCards.cards![i]
                        .priorityKey == "4.1" {
                        SpotLightsManager.shared.spotLightCards.cards![i]
                            .priorityKey = "3.1"
                    } else if SpotLightsManager.shared.spotLightCards.cards![i]
                        .priorityKey == "4.2" {
                        SpotLightsManager.shared.spotLightCards.cards![i]
                            .priorityKey = "3.2"
                    }
                }
                SpotLightsManager.shared.saveDismissibleCards()
                SpotLightsManager.shared.saveLastETRValueIfExists() //CMAIOS-2591
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("SpotlightCard Request Failed")
                completionHandler(false, nil, value)
            }
        })
    }
    
    // Quick Pay - Update Spotlight Cards
    func mauiUpdateSpotLightCards(params: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ value: SpotLightCardsGetResponse?, _ error: AFError?) -> Void) {
//        var requestTimeStamp = ""
//        requestTimeStamp = Date().getDateForErrorLog()
        let getUrlPathType = MAUI_SPOTLIGHT_CARD_PATH_URL
        let urlPath = getUrlPathType + "?name=\(QuickPayManager.shared.getAccountNam())"
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiUpdateSpotlightCards, jsonParams: params, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: SpotLightCardsGetResponse.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Update SpotlightCard Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Update SpotlightCard Request Failed")
//                let errorLogger = APIErrorLogger()
//                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Home", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
}
