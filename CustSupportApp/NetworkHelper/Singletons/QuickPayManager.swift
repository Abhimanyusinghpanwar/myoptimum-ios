//
//
//  QuickPayManager.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 12/7/22.
//

import Foundation
import Alamofire

protocol MauiApisStatusDelegate {
//    func sequenceApiStatus(isCompleted: Bool)
//    func apiRequestSuccess(type: ApiType)
//    func apiRequestFailure(type: ApiType)
      func handle500Error()
}

class QuickPayManager {
    
    enum EnrollType {
        case onlyAutoPay
        case both
        case onlyPaperless
        case none
    }

    enum InitialFlow: Equatable {
        case expireDateError
        case defaultDisclaimer
        case normal
        case dueCreditApplied
        case noDue
        case pastDue
        case manualBlock
        case autoPay
    }
    
    enum BillNotificationType {
        case normal
        case preDeAuth
        case includesPastDue
        case PastDue
        case autoPay
        case autoPayExpired
        case autoPayExpiresSoon
        case autoPayProblem
        case scheduledPayWillExpire
        case scheduledPayExpired
        case scheduledOneTimePayment
        case none
    }
    
    // good/past_due/manual_block/pre_de_auth/de_auth
    enum PaymentStateForAnalyics: String {
        case good = "good"
        case pastDue = "past_due"
        case manualBlock = "manual_block"
        case preDeAuth = "pre_de_auth"
        case deAuth = "de_auth"
        case none = "none"
    }
    
    class var shared: QuickPayManager {
        struct Singleton {
            static let instance = QuickPayManager()
        }
        return Singleton.instance
    }
    
    var enrolType: EnrollType = .both
    var homeNotificationType: BillNotificationType = .none
    var initialScreenFlow: InitialFlow = .normal
    var currentApiType: ApiType = .none
    var currentApiErrorCode: String = ""
    var currentMakepaymentAmount: String = ""
    var currentMakepaymentDate: String = ""
    var tempPaymethod: PayMethod?
    var loginTime: Date?
    var reAuthType: ReAuthType = .tokenExpiry
    var reAuthCategory: ReAuthCategory = .jumpLink
    var pdfDownloadType: PdfDownloadType = .bill
    var localSavedPaymethods: [LocalSavedPaymethod]?
    var cardDataDict: SpotLightCardsGetResponse.CardData?

    var delegate: MauiApisStatusDelegate?
    var modelAccountsList: QuickPayAccountsResponseModel?
    var modelQuickPayListBill: QuickPayListBillsResponseModel?
    var modelQuickPayGetBill: QuickPayGetBillResponseModel?
    var modelQuickPayGetAccountBill: QuickPayGetAccountBillResponseModel?
    var modelQuickPayGetBillActivity: QuickPayGetBillActivityResponseModel?
    var modelQuickPayNextPaymentDue: QuickPayNextPaymentDueResponseModel?
    var modelQuickGetPayBillPrefernce: QuickPayGetBillPrefernceResponseModel?
    var modelQuickPayUpdateBillPrefernce: QuickPayUpdateBillPrefernceResponseModel?
    var modelQuickPayCreatePayment: QuickPayCreatePaymentResponseModel?
    var modelQuickPaySetDefault: QuickPaySetDefaultResponseModel?
    var modelQuickPayGetAutoPay: QuickPayGetAutoPayResponseModel?
    var modelQuickPayImmediatePayment: QuickPayImmediatePaymentResponseModel?
    var modelQuickPayAccountRestriction: QuickPayAccountRestrictionResponseModel?
    var modelQuickPayOneTimePayment: QuickPayCreateOneTimePaymentResponseModel?
    var modelQuickPayeOutage: QuickPayOutageResponseModel?
    var modelListPayment: QuickPayListPaymentResponseModel?
    var modelConsolidatedDetail: ConsolidatedDetailsResponseModel?
    var modelSchedulePaymentNewCard: QuickPayCreateOneTimePaymentResponseModel?
    var modelRemoveSchedulePayment: RemoveScheduleResponseModel?
    var modelSchedulePaymentCreate: CreateScheduleResponseModel?
    var modelSchedulePaymentUpdate: UpdateSchedulePaymentModel?
    var modelCustomerTenure: CustomerTenure?
    var modelQuickPayCreateBankAccount: QuickPayCreatePaymentResponseModel?
    var modelAchOneTimePayment: QuickPayCreateOneTimePaymentResponseModel?

    var isGetAccountBillCompleted = false
    var isGetAccountActivityCompleted = false
    var isListBillsCompeletd = false
    var isGetAccountRestrictionCompleted = false
    var isRouterContainsLegacySettings = false
    var isFromAutoPaySettingsView = false
    var dataRefreshNeedOnMyAccountAfterChat = false
    var isMauiAccountListCompleted = false
    var ismauiMainApiInProgressLoader: (() -> Void)?
    var mauiAccountApiRetryCount: Int = 0
    var mauiGetBillActAccApiRetryCount: Int = 0
    var ismauiMainApiInProgress: (isprogress: Bool, iserror: Bool) = (isprogress: true, iserror: false) {
        didSet {
            self.ismauiMainApiInProgressLoader?()
        }
    }
    
    let interceptor = MauiRequestInterceptor()
    
    // MARK: - QUICK PAY API REQUESTS
    func accountsListRequest() {
        currentApiType = .accountList
        APIRequests.shared.mauiAccoutsListRequest(interceptor: interceptor, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    self.modelAccountsList = value
                    Logger.info("Accounts List Response is \(String(describing: value))", sendLog: "Accounts List Response success")
//                    self.delegate?.apiRequestSuccess(type: .accountList)
                } else {
                    Logger.info("Accounts List Response is \(String(describing: error))")
//                    self.delegate?.apiRequestFailure(type: .accountList)
                }
            }
        })
    }
    
    func mauiListBillsRequest() {
        var params = [String: AnyObject]()
        params["name"] = self.getAccountName() as AnyObject?
        APIRequests.shared.mauiBillListRequest(interceptor: interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayListBill = value
                    Logger.info("Bill List Response is \(String(describing: value))", sendLog: "Bill List Request success")
                } else {
                    Logger.info("Bill List Response is \(String(describing: error))")
                }
            }
        })
    }
    
    //MARK: - Download the bill or bill insert pdf
    func downloadBillPdf(name: String, fileName: String, isBillInsert: Bool, completionHandler: @escaping (_ success: Bool) -> Void) {
        QuickPayManager.shared.currentApiType = .pdfDownload
        QuickPayManager.shared.pdfDownloadType = isBillInsert ? .billInsert: .bill
        let queue = DispatchQueue(label: "billpdfdownload-queue", attributes: DispatchQueue.Attributes.concurrent)
        let destination: DownloadRequest.Destination = { _, _ in
//            let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).pdf")
            let formPath = "PDFList/" + fileName + ".pdf"
            let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(formPath)
            return (fileURL!, [.removePreviousFile, .createIntermediateDirectories])
        }
        let formattedName = isBillInsert ? name :name.replacingOccurrences(of: "bills", with: "billpdfs")
        let baseURL = isBillInsert ? MAUI_BILLINSERTPDF_PATH_URL: MAUI_BILLPDF_PATH_URL
        let formmatedURL = baseURL + "?" + "name=" + formattedName
        
        let requestObj: DownloadRequest = RequestBuilder(url: formmatedURL, method: .get, serviceKey: .mauiPdfDownload, jsonParams: nil, encoding: URLEncoding.default).buildDownloadRequest(interceptor: interceptor, destination: destination)
        requestObj.validate().responseData(queue: queue) { [weak self] response in
            guard let self = self, response.error == nil else {
                Logger.info("PDF download failed, PDF name:\(name)")
                QuickPayManager.shared.removePdfFile()
                completionHandler(false)
                return
            }
            Logger.info("PDF download successful, PDF name:\(name)")
            completionHandler(true)
        }
    }
    
    func mauiGetBillRequest() {
        var params = [String: AnyObject]()
        params["name"] = self.getBillNameFromBillList() as AnyObject?
        APIRequests.shared.mauiGetBillRequest(params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayGetBill = value
                    Logger.info("Get Bill Response is \(String(describing: value))", sendLog: "Get Bill Request success")
//                    self.delegate?.apiRequestSuccess(type: .getBill)
                } else {
//                    self.delegate?.apiRequestFailure(type: .getBill)
                    Logger.info("Get Bill Response is \(String(describing: error))")
                }
            }
        })
    }
    
    func mauiGetAccountBillRequest(completionHandler: ((Error?) -> Void)? = nil) {
        currentApiType = .getBillAccount
        var params = [String: AnyObject]()
        params["name"] = self.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayGetAccountBill = value
                    Logger.info("Get Account Bill Response is \(String(describing: value))", sendLog: "Get Account Bill request success")
//                    self.delegate?.apiRequestSuccess(type: .getBillAccount)
                    completionHandler?(nil)
                } else {
                    Logger.info("Get Account Bill Response is \(String(describing: error))")
//                    self.delegate?.apiRequestFailure(type: .getBillAccount)
                    completionHandler?(error)
                }
            }
        })
    }
    
    func mauiGetAccountActivityRequest() {
        currentApiType = .getBillActivity
        var params = [String: AnyObject]()
        params["name"] = self.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillActivityRequest(interceptor: interceptor, params: params, completionHandler: { success, value, error, code in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayGetBillActivity = value
//                    self.delegate?.apiRequestSuccess(type: .getBillActivity)
                    Logger.info("Get Account Activity Response is \(String(describing: value))", sendLog: "Get Account Activity success")
                } else {
                    Logger.info("Get Account Activity Response is \(String(describing: error))")
//                    self.delegate?.apiRequestFailure(type: .getBillActivity)
                }
            }
        })
    }
    
    func mauiUpdateBillCommunicationPreference(jsonParams: [String: AnyObject], completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: Error?) -> Void) {
        currentApiType = .updateCommunicationPreference
        var params = jsonParams
        params["name"] = QuickPayManager.shared.getAccountNam() as AnyObject?
        APIRequests.shared.mauiUpdateBillPreferencesRequest(interceptor: interceptor, jsonParam: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayUpdateBillPrefernce = value
                    Logger.info("Update Bill Communication Preference Response is \(String(describing: value))", sendLog: "Update Bill Communication Preference success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Update Bill Communication Preference Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func mauiCreatePayment(jsonParams: [String: AnyObject], isDefault: Bool, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .createPayment
        APIRequests.shared.mauiCreatePaymentRequest(interceptor: interceptor, jsonParam: jsonParams, isDefault: isDefault, paramName: getAccountName(), nickName: "", completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayCreatePayment = value
                    Logger.info("Create Payment Response is \(String(describing: value))", sendLog: "Create Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Create Payment Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func mauiGetAutoPay() {
        currentApiType = .getAutoPay
        let nameParam =  self.getAccountName() + "/autopay"
        var param = [String: AnyObject]()
        param["name"] = nameParam as AnyObject?
        APIRequests.shared.mauiGetAutoPayRequest(interceptor: interceptor, param: param, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayGetAutoPay = value
//                    self.delegate?.apiRequestSuccess(type: .getAutoPay)
                    Logger.info("Get Auto Pay Response is \(String(describing: value))", sendLog: "Get Auto Pay success")
                } else {
                    Logger.info("Get Auto Pay Response is \(String(describing: error))")
//                    self.delegate?.apiRequestFailure(type: .getAutoPay)
                }
            }
        })
    }
    
    func mauiAccountRestriction(name: String) {
        var params = [String: AnyObject]()
        params["name"] = name as AnyObject?
        APIRequests.shared.mauiGetAccountRestrictionRequest(param: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Account Restriction Response is \(String(describing: value))", sendLog: "Account Restriction success")
                    self.modelQuickPayAccountRestriction = value
                } else {
                    Logger.info("Account Restriction Response is \(String(describing: error))")
                }
                self.isGetAccountRestrictionCompleted = true
            }
        })
    }
    
    func mauiImmediatePayment(jsonParams: [String: AnyObject], makeDefault: Bool, payMethod: PayMethod? = nil, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .immediatePaymentCC
        if let payType = payMethod, payType.bankEftPayMethod != nil{
            currentApiType = .immediatePaymentACH
        }
        APIRequests.shared.mauiImmediatePaymentRequest(interceptor: interceptor, jsonParams: jsonParams, makeDefault: makeDefault, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayImmediatePayment = value
                    Logger.info("Immediate Payment Response is \(String(describing: value))", sendLog: "Immediate Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Immediate Payment Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func mauiOneTimePaymentRequest(jsonParams: [String: AnyObject], isDefault: Bool, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .oneTimePayment
        APIRequests.shared.mauiCreateOneTimePayment(interceptor: interceptor, jsonParam: jsonParams, isDefault: isDefault, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayOneTimePayment = value
                    if let code = value?.responseInfo?.statusCode, self.isErrorCodePresentOrNot(code: code.lowercased()){
                        self.handleErrorCode(code: code)
                        return
                    }
                    Logger.info("One Time Payment Response is \(String(describing: value))", sendLog: "One Time Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("One Time Payment Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func mauiAchOneTimePaymentRequest(jsonParams: [String: AnyObject], isDefault: Bool, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .achOneTimePayment
        APIRequests.shared.mauiCreateOneTimePayment(interceptor: interceptor, jsonParam: jsonParams, isDefault: isDefault, isAchFlow: true, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelAchOneTimePayment = value
                    if let code = value?.responseInfo?.statusCode, self.isErrorCodePresentOrNot(code: code.lowercased()){
                        self.handleErrorCode(code: code)
                        return
                    }
                    Logger.info("One Time Payment ACH Response is \(String(describing: value))", sendLog: "One Time Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("One Time Payment ACH Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func handleErrorCode(code: String) {
        QuickPayManager.shared.currentApiErrorCode = code
        QuickPayManager.shared.handleMakePaymentErrorCode()
    }
    
    func isErrorCodePresentOrNot(code: String) -> Bool {
        //CMAIOS-2323 //CMAIOS-2877 added missing error codes
        if code == "invalid bank or finbr" || code == "numeric value out of range for xml tag eftt_bacct" || code == "xml tag eftt_bacct should be numeric" || code == "xml tag eftt_bacct should be numeric." || code ==  "307" || code == "invalid cc number" ||  code == "card is expired" || code == "credit floor" || code == "lost/stolen" || code == "do not honor" || code == "processor decline" || code ==  "restraint" || code == "pickup" || code ==  "suspected fraud" || code ==  "insufficient fund" || code ==  "revocation of authorization" || code == "30170" || code == "90001" || code == "30168" || code == "30167" || code == "generic error" || code == "401" || code == "602" || code == "603" || code == "invalid institution code"{
            return true
        } else {
            return false
        }
    }
    
    func mauiUpdate(paymethod: PayMethod, expireDate: String, completionHandler: @escaping (Result<PayMethod?, Error>) -> Void) {
        currentApiType = .updatePayment
        let date = CommonUtility.convertExpireDateStringToResponseFormat(dateString: expireDate)
        let updateRequest = UpdatePayMethodRequest(payMethod: PayMethod(name: paymethod.name, creditCardPayMethod: CreditCardPayMethod(expiryDate: date)))
        APIRequests.shared.mauiUpdatePayMethod(interceptor: interceptor, accountName: getAccountName(), request: updateRequest, completionHandler: { result in
            switch result {
            case .success(let updatedResponse):
                completionHandler(.success(updatedResponse.payMethod))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        })
    }
    
    //CMAIOS-2627, 2620, 2624
    func mauiUpdate(paymethod: PayMethod,
                    newNickname: String?,
                    updatePaymethod: PayMethod?,
                    completionHandler: @escaping (Result<EditPayMethod?,
                                                  Error>) -> Void)
    {
        currentApiType = .updatePayment
        var editPayMethodRequest: EditPayMethodRequest?
        switch (updatePaymethod == nil, newNickname != nil) {
        case (true, _): //ACH Update
            editPayMethodRequest = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, newNickname: newNickname))
        case (_, true):  //Credit Card Update with Nickname update
            editPayMethodRequest = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, newNickname: newNickname, creditCardPayMethod: updatePaymethod?.creditCardPayMethod))
        case (_, false): //Credit Card Update without Nickname update
            editPayMethodRequest = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, creditCardPayMethod: updatePaymethod?.creditCardPayMethod))
        }
        
        /*
        if updatePaymethod == nil { // ACH Update
            editPayMethodRequest = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, newNickname: newNickname))
        } else { // Credit Card Update
            if newNickname != nil {
                editPayMethodRequest = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, newNickname: newNickname, creditCardPayMethod: updatePaymethod?.creditCardPayMethod))
            } else {
                editPayMethodRequest = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, creditCardPayMethod: updatePaymethod?.creditCardPayMethod))
            }
        }
         */
        
        guard let request = editPayMethodRequest else {
            completionHandler(.failure(Error.Type.self as! Error))
            return
        }
//        let editACHMethod = EditPayMethodRequest(payMethod: EditPayMethod(name: paymethod.name, newNickname: newNickname))
        APIRequests.shared.mauiUpdateACHPayMethodNickName(interceptor: interceptor, accountName: getAccountName(), request: request, completionHandler: { result in
            switch result {
            case .success(let updatedResponse):
                completionHandler(.success(updatedResponse.payMethod))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        })
    }
    
    func mauiUpdate(autoPay: AutoPay, completionHandler: @escaping (Result<AutoPay, Error>) -> Void) {
        guard let params = autoPay.dictionary as? [String: AnyObject] else { return }
        currentApiType = .updateAutoPay //CMAIOS-2858
        APIRequests.shared.mauiUpdateAutoPayMethod(interceptor: interceptor, params: ["autoPay": params as AnyObject]) { result in
            switch result {
            case .success(let updatedResponse):
                Logger.info("Updated Auto Pay \(updatedResponse)", sendLog: "Updated Auto Pay")
                completionHandler(.success(updatedResponse.updateAutopay))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func mauiRemoveAutoPay(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        currentApiType = .removeAutoPay
        APIRequests.shared.mauiRemoveAutoPayMethod(interceptor: interceptor, autoPayName: "\(getAccountName())/autoPay", completionHandler: { result in
            guard case .failure(let error) = result else { return completionHandler(.success(())) }
            completionHandler(.failure(error))
        })
    }
    
    func mauiSchedulePaymentWithNewCard(jsonParams: [String: AnyObject], isDefault: Bool, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .schedulePaymentNewCard
        APIRequests.shared.mauiCreateSchedulePaymentNewCardOrACH(interceptor: interceptor, jsonParam: jsonParams, isDefault: isDefault, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelSchedulePaymentNewCard = value
                    Logger.info("Create Schedule Payment With New Card, Response is \(String(describing: value))", sendLog: "Create Schedule Payment With New Card success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Create Schedule Payment With New Card, Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func mauiSchedulePaymentWithNewACH(jsonParams: [String: AnyObject], isDefault: Bool, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .schedulePaymentNewAch
        APIRequests.shared.mauiCreateSchedulePaymentNewCardOrACH(interceptor: interceptor, jsonParam: jsonParams, isDefault: isDefault, isAchFlow: true, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelSchedulePaymentNewCard = value
                    Logger.info("Create Schedule Payment With New ACH, Response is \(String(describing: value))", sendLog: "Create Schedule Payment With New Card success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Create Schedule Payment With New ACH, Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func mauiCancelScheduledPayment(jsonParams: [String: AnyObject], completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .schedulePaymentCancel
        APIRequests.shared.mauiCancelScheduledPayment(interceptor: interceptor, jsonParam: jsonParams, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelRemoveSchedulePayment = value
                    Logger.info("Cancel Schedule Payment \(String(describing: value))", sendLog: "Cancel Schedule Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Cancel Schedule Payment is \(String(describing: error))")
                    completionHanlder(success, nil, error)
                }
            }
        })
    }
    
    // ManagePaymentMethod - DeleteMOP CMAIOS-2578
    func mauiDeletePaymentMethod(payMethodName : String, completionHanlder: @escaping (_ success: Bool, _ value: DeleteMOPResponseModel?, _ error: AFError?) -> Void) {
        currentApiType = .deleteMOP
        APIRequests.shared.mauiDeleteMOP(payMethodName: payMethodName) { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Delete MOP \(String(describing: value))", sendLog: "Delete MOP success")
                    completionHanlder(success, value, nil)
                } else {
                    Logger.info("Delete MOP is \(String(describing: error))")
                    completionHanlder(success, nil, error)
                }
            }
        }
    }
    
    func mauiSchedulePaymentWithExistingCard(jsonParams: [String: AnyObject], completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .schedulePaymentExistingPaymenthod
        APIRequests.shared.mauiCreateSchedulePayment(interceptor: interceptor, jsonParam: jsonParams, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelSchedulePaymentCreate = value
                    Logger.info("Create Schedule Payment With Existing Card is \(String(describing: value))", sendLog: "Create Schedule Payment With Existing Card success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Create Schedule Payment With Existing Card is \(String(describing: error))")
                    completionHanlder(success, nil, error)
                }
            }
        })
    }
    
    func mauiUpdateSchedulePayment(jsonParams: [String: AnyObject], completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .schedulePaymentUpdate
        APIRequests.shared.mauiUpdateSchedulePayment(interceptor: interceptor, jsonParam: jsonParams, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelSchedulePaymentUpdate = value
                    Logger.info("Update Schedule Payment \(String(describing: value))", sendLog: "Update Schedule Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Update Schedule Payment is \(String(describing: error))")
                    completionHanlder(success, nil, error)
                }
            }
        })
    }
    
    func mauiCreateBankPaymethod(jsonParams: [String: AnyObject], isDefault: Bool, completionHanlder: @escaping (_ success: Bool, _ errorDescription : String?, _ error: AFError?) -> Void) {
        currentApiType = .createBankPaymethod
        APIRequests.shared.mauiCreateBankAccountPaymethodRequest(interceptor: interceptor, jsonParam: jsonParams, isDefault: isDefault, paramName: getAccountName(), nickName: "", completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    self.modelQuickPayCreateBankAccount = value
                    Logger.info("Create Payment Response is \(String(describing: value))", sendLog: "Create Payment success")
                    completionHanlder(success, nil, nil)
                } else {
                    Logger.info("Create Payment Response is \(String(describing: error))")
                    completionHanlder(success, value?.error_description, error)
                }
            }
        })
    }
    
    func handleMakePaymentErrorCode() {
        DispatchQueue.main.async {
            guard let topVisibleView = UIApplication.topViewController() else {
                return
            }
            if let makePaymentView = topVisibleView as? MakePaymentViewController {
                makePaymentView.signInFailedAnimation()
                makePaymentView.getCurrentAmountAndDate()
                makePaymentView.handleMakePaymentErrorCodes(error: makePaymentView.mapErrorCodeToOTPErrorType())
            }
        }
    }
    
    ///Reference confluence link: https://confluence.cablevision.com/pages/viewpage.action?pageId=149489413
    // MARK: - Handle 500 error code for Maui APIS
    func handleUnacceptableError() {
        guard let topVisibleView = UIApplication.topViewController() else {
            return
        }
        switch (topVisibleView.isKind(of: MakePaymentViewController.self),
                topVisibleView.isKind(of: ThanksAutoPayViewController.self),
                topVisibleView.isKind(of: FinishSetupViewController.self),
                topVisibleView.isKind(of: BillingPaymentViewController.self),
                topVisibleView.isKind(of: ManualCardEntryViewController.self),
                topVisibleView.isKind(of: CardExpirationViewController.self),
                topVisibleView.isKind(of: EditAutoPayViewController.self),
                topVisibleView.isKind(of: HomeScreenViewController.self),
                topVisibleView.isKind(of: QuickPayAlertViewController.self),
                topVisibleView.isKind(of: AutoPayScheduledcancelViewController.self),
                topVisibleView.isKind(of: MyAccountViewController.self),
                topVisibleView.isKind(of: ChoosePaymentViewController.self),
                topVisibleView.isKind(of: SetUpAutoPayPaperlessBillingVC.self),
                topVisibleView.isKind(of: EditACHDetailVC.self), //CMAIOS-2485, 2492 handle reauth
                topVisibleView.isKind(of: EditCCViewController.self),
                topVisibleView.isKind(of: AddCheckingAccountViewController.self))
        {
        case (true, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _):
            if let makePaymentView = topVisibleView as? MakePaymentViewController {
                makePaymentView.handleErrorImmediatePayment()
            }
        case (_, true, _, _, _, _, _, _, _, _, _, _, _, _, _, _):
            if let thankYouView = topVisibleView as? ThanksAutoPayViewController {
                thankYouView.handleErrorThaksAutoPayView()
            }
        case (_, _, true, _, _, _, _, _, _, _, _, _, _, _, _, _):
            if let finishSetupView = topVisibleView as? FinishSetupViewController {
                finishSetupView.handleErrorFinishSetupAutopay()
            }
        case (_, _, _, true, _, _, _, _, _, _, _, _, _, _, _, _):
            if let billingView = topVisibleView as? BillingPaymentViewController {
                billingView.handleErrorMyBillView()
            }
        case (_, _, _, _, true, _, _, _, _, _, _, _,_, _, _, _):
            if let quickPayView = topVisibleView as? ManualCardEntryViewController {
                quickPayView.handleErrorOTPAndCreatePayment()
            }
        case (_, _, _, _, _, true, _, _, _, _, _, _, _, _, _, _):
            if let cardExpiration = topVisibleView as? CardExpirationViewController {
                cardExpiration.handleErrorUpdateExpiration()
            }
        case (_, _, _, _, _, _, true, _, _, _, _, _, _, _, _, _):
            if let cardExpiration = topVisibleView as? EditAutoPayViewController {
                cardExpiration.handleErrorEditAutoPay(tokenExpiry: false)
            }
        case (_, _, _, _, _, _, _, true, _, _, _, _, _, _, _, _):
            if let homeview = topVisibleView as? HomeScreenViewController {
                homeview.handleErrorBillPayApis()
            }
        case (_, _, _, _, _, _, _, _, true,_, _, _, _, _, _, _):
            if let quickAlertView = topVisibleView as? QuickPayAlertViewController {
                quickAlertView.handleErrorQuickPayAlert()
            }
        case (_, _, _, _, _, _, _, _, _, true, _, _, _, _, _, _):
            if let cancelSchedulePayView = topVisibleView as? AutoPayScheduledcancelViewController {
                cancelSchedulePayView.handleApiErrorCode()
            }
        case (_, _, _, _, _, _, _, _, _, _, true, _, _, _, _, _):
            if let myAccountView = topVisibleView as? MyAccountViewController {
                myAccountView.handleApiErrorCode()
            }
        case (_, _, _, _, _, _, _, _, _, _, _, true, _, _, _, _):
            if let finishSetupView = topVisibleView as? ChoosePaymentViewController {
                finishSetupView.handleErrorFinishSetupAutopay()
            }
        case (_, _, _, _, _, _, _, _, _, _, _, _, true, _, _, _):
            if let finishSetupView = topVisibleView as? SetUpAutoPayPaperlessBillingVC {
                finishSetupView.handleErrorFinishSetupPaperlessBilling()
            }
        case (_, _, _, _, _, _, _, _, _, _, _, _, _,true, _, _):
            if let editACHDetailVC = topVisibleView as? EditACHDetailVC {
                editACHDetailVC.handleErrorUpdateNickname()
            }
        case (_, _, _, _, _, _, _, _, _, _, _, _, _,_, true, _):
            if let editCCViewController = topVisibleView as? EditCCViewController {
                editCCViewController.handleErrorUpdatePaymethod()
            }
        case (_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, true):
            if let addCheckingViewController = topVisibleView as? AddCheckingAccountViewController {
                addCheckingViewController.handleACH500Error()
            }
        default:
            delegate?.handle500Error()
        }
    }
    
     // MARK: - Manage De-Auth
     func showReAuthLogin() {
         guard let topVisibleView = UIApplication.topViewController() else {
             return
         }
         LoginPreferenceManager.sharedInstance.manualSignInActive = false // CMAIOS-1480
         // Only works in autologin flow, If loginview as top ViewController
         // Modify the Login UI for maui login flow
         if topVisibleView.isKind(of: LoginViewController.self) {
             DispatchQueue.main.async {
                 if let loginView = topVisibleView as? LoginViewController {
                     self.interceptor.ignoreReAuth = true
                     loginView.isMauiReAuth = true
                     loginView.isAutoLoginFlow = true
                     loginView.configureUI()
                     loginView.removeGreetingSalutationView()
                 }
             }
         } else { // Only works in non autologin flow, If loginview is not top ViewController
             if let loginViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                 loginViewController.isMauiReAuth = true
                 loginViewController.isAutoLoginFlow = false
                 self.interceptor.ignoreReAuth = true
                 let navigationController = UINavigationController.init(rootViewController: loginViewController)
                 navigationController.modalPresentationStyle = .fullScreen
                 DispatchQueue.main.async {
                     topVisibleView.present(navigationController, animated: true, completion: nil)
                 }
             }
         }
     }
     
     /// Refresh the current screen after the Re-Auth
     func showAppropriteScreenAfterReAuth() {
         interceptor.ignoreReAuth = false
         guard let topVisibleView = UIApplication.topViewController() else {
             return
         }
         switch (topVisibleView.isKind(of: EditAutoPayViewController.self),
                 topVisibleView.isKind(of: MyAccountViewController.self),
                 topVisibleView.isKind(of: HomeScreenViewController.self), topVisibleView.isKind(of: ChoosePaymentViewController.self),topVisibleView.isKind(of: SetUpAutoPayPaperlessBillingVC.self) //CMAIOS-2485, 2492 handle token expiry
                 
         ) {
         case (true, _, _,_,_):
             if let editAutoPay = topVisibleView as? EditAutoPayViewController {
                 DispatchQueue.main.async(execute: {
                     editAutoPay.handleErrorEditAutoPay(tokenExpiry: true)
                 })
             }
             Logger.info("BillingViewContrller")
         case (_, true, _,_,_):
             if let myAccountViewController = topVisibleView as? MyAccountViewController {
                 DispatchQueue.main.async(execute: {
                     myAccountViewController.refreshAfterReAuthOnTimeExpiry()
                 })
             }
             Logger.info("MyAccountViewController")
         case (_, _, true, _,_):
             if let homeViewController = topVisibleView as? HomeScreenViewController {
                 DispatchQueue.main.async(execute: {
                     homeViewController.refreshAfterReAuthOnTimeExpiry(category: self.reAuthCategory)
                 })
             }
             Logger.info("HomeScreenViewController")
         case (_, _, _, true,_):
             if let choosePaymentVC = topVisibleView as? ChoosePaymentViewController {
                 DispatchQueue.main.async(execute: {
                     choosePaymentVC.handleErrorFinishSetupAutopay(isShowErrorMessage: false)
                 })
             }
             Logger.info("ChoosePaymentViewController")
         case (_, _, _, _,true):
                 if let setUpAutoPayPaperlessBillingVC = topVisibleView as? SetUpAutoPayPaperlessBillingVC {
                     DispatchQueue.main.async(execute: {
                         setUpAutoPayPaperlessBillingVC.handleErrorFinishSetupPaperlessBilling(isShowErrorMessage: false)
                     })
                 }
                 Logger.info("SetUpAutoPayPaperlessBillingVC")
         default: break
         }
     }
    
    /// Re-Authenticate the session using the re_auth_duration_seconds from config API response
    /// Parameter category: Identify the reauth parent screen
    func reAuthOnTimeExpiry(category: ReAuthCategory) {
        reAuthCategory = category
        DispatchQueue.main.async {
            QuickPayManager.shared.reAuthType = .timeExpiry
            QuickPayManager.shared.showReAuthLogin()
        }
    }
    
    //CMAIOS-2496
    func setEnrolType() {
        let isAutoPayOn = QuickPayManager.shared.isAutoPayEnabled()
        let isPaperLessBillingOn = QuickPayManager.shared.isPaperLessBillingEnabled()
        switch (isAutoPayOn, isPaperLessBillingOn) {
        case (false, false):
            QuickPayManager.shared.enrolType = .both
        case (true, false):
            QuickPayManager.shared.enrolType = .onlyPaperless
        case (false, true):
            QuickPayManager.shared.enrolType  = .onlyAutoPay
        default:
            break
        }
    }
    
    //CMAIOS-2624 //CMAIOS-2782
    func isBillingAndServiceAddressAreSame(payMethod: PayMethod?) -> Bool {
        guard let isServiceAddress = payMethod?.creditCardPayMethod?.isServiceAddress,
              isServiceAddress == true else {
            return false
        }
        return isServiceAddress
    }
    
}

enum ApiType {
    case none
    case accountList
    case paymethodList
    case listBills
    case getBill
    case getBillActivity
    case getBillAccount
    case getAutoPay
    case getCommunicationPreference
    case updateCommunicationPreference
    case createPayment
    case setDefaultPayment
    case nextPaymentDue
    case immediatePaymentCC
    case immediatePaymentACH
    case oneTimePayment
    case updatePayment
    case removeAutoPay
    case pdfDownload
    case schedulePaymentNewCard
    case schedulePaymentCancel
    case schedulePaymentExistingPaymenthod
    case schedulePaymentUpdate
    case createBankPaymethod
    case achOneTimePayment
    case schedulePaymentNewAch
    case deleteMOP
    case updateAutoPay
    case createAutoPay
}

enum ReAuthType {
    case timeExpiry
    case tokenExpiry
}

enum ReAuthCategory {
    case billingMenu
    case jumpLink
    case spotlightCard
}

enum PdfDownloadType {
    case bill
    case billInsert
}

/// RequestInterceptor delegate to get the error code to Re-Auth login screen
class MauiRequestInterceptor: RequestInterceptor {
    // Property used to not show reAuth flow if reAuth is in progress
    var ignoreReAuth: Bool = false
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        switch statusCode {
        case 200...299:
            if QuickPayManager.shared.retryRequiredForBlockerApisCount() { // CMAIOS:2480
                completion(.retry)
            } else {
                completion(.doNotRetry)
            }
//            completion(.doNotRetry)
        case 401 where !ignoreReAuth:
            if QuickPayManager.shared.currentApiType == .pdfDownload {
                DispatchQueue.main.async {
                    QuickPayManager.shared.reAuthType = .tokenExpiry
                     QuickPayManager.shared.removePdfFile()
                     QuickPayManager.shared.showReAuthLogin()
                }
                return
            }
            guard let responseData = (request as? DataRequest)?.data else {
                completion(.doNotRetry)
                return
            }
            let jsonErrorResponse = getErrorReponseJson(responseData: responseData)
            if needReAuthLogin(json: jsonErrorResponse) {
                DispatchQueue.main.async {
                    QuickPayManager.shared.reAuthType = .tokenExpiry // CMAIOS-1480
                    QuickPayManager.shared.showReAuthLogin()
                }
                return // CMA:-2926
            } else if let code = jsonErrorResponse["code"] as? String, !code.isEmpty && isOTPOrSchedulePaymentRelatedAPI() {
                QuickPayManager.shared.currentApiErrorCode = code
                QuickPayManager.shared.handleMakePaymentErrorCode()
                return
            }
            if isOTPOrSchedulePaymentRelatedAPI() {
                QuickPayManager.shared.currentApiErrorCode = statusCode.description
                QuickPayManager.shared.handleMakePaymentErrorCode()
                return
            } else { completion(.doNotRetry) }
        case 500:
            if QuickPayManager.shared.retryRequiredForBlockerApisCount() { // CMAIOS:2480
                completion(.retry)
                return
            }
            if let responseData = (request as? DataRequest)?.data {
                let jsonErrorResponse = getErrorReponseJson(responseData: responseData)
                QuickPayManager.shared.currentApiErrorCode = jsonErrorResponse["code"] as? String ?? ""
                Logger.info("Billing API Error 500 - \(jsonErrorResponse)")
                if let code = jsonErrorResponse["code"] as? String, !code.isEmpty && isOTPOrSchedulePaymentRelatedAPI() {
                    QuickPayManager.shared.currentApiErrorCode = code
                    QuickPayManager.shared.handleMakePaymentErrorCode()
                    return
                }
            }
            DispatchQueue.main.async {
                guard let topVisibleView = UIApplication.topViewController() else {
                    completion(.doNotRetry)
                    return
                }
                if !topVisibleView.isKind(of: LoginViewController.self) {
                    QuickPayManager.shared.handleUnacceptableError()
                    self.updateCurrentApiStatus()
                } else {
                    completion(.doNotRetry)
                }
            }
        default:
            // Create Custom error object from json and pass it downstream
            completion(.doNotRetryWithError(error))
        }
    }
    
    // CMAIOS-2067
    func isOTPOrSchedulePaymentRelatedAPI() -> Bool {
        QuickPayManager.shared.clearModelAfterChatRefresh() //CMAIOS-2633
        if QuickPayManager.shared.currentApiType == .immediatePaymentCC || QuickPayManager.shared.currentApiType == .immediatePaymentACH || QuickPayManager.shared.currentApiType == .oneTimePayment || QuickPayManager.shared.currentApiType == .achOneTimePayment || QuickPayManager.shared.currentApiType == .schedulePaymentNewAch || QuickPayManager.shared.currentApiType == .schedulePaymentNewCard || QuickPayManager.shared.currentApiType == .schedulePaymentNewCard {
            return true
        } else {
            return false
        }
    }
    
    /// validates the whether the error is invalid_jwt for ReAuth Login
    /// - Parameter json: error response json
    /// - Returns: Re-login needed or not
    func needReAuthLogin(json: [String : Any]) -> Bool {
        var isNeeded = false
        if let errorDesc = json["error_description"] as? String, errorDesc == "invalid_jwt", !ignoreReAuth {
                isNeeded = true
        }
        return isNeeded
    }
    
    /// Validate response Data
    /// - Parameter responseData: Data should be Serialized
    /// - Returns: error reponse JSON
    func getErrorReponseJson(responseData: Data) -> [String : Any] {
        var jsonErrorResponse: [String : Any] = [:]
        do {
            jsonErrorResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any] ?? [:]
        }
        catch { Logger.info("Prasing error: JsonErrorResponse") }
        return  jsonErrorResponse
    }
    
    func updateCurrentApiStatus() {
        switch QuickPayManager.shared.currentApiType {
        case .getBillAccount:
            APIRequests.shared.isGetAccountBillApiFailed = true
        default: break
        }
    }
}

// MARK: - Clear the Bill pay shared data and flags on logout
extension QuickPayManager {
    func clearSharedData() {
        self.resetModels()
        self.resetFlags()
        self.resetTypes()
    }
    func resetTypes() {
        homeNotificationType = .none
        initialScreenFlow = .normal
        currentApiType = .none
        tempPaymethod = nil
        cardDataDict = nil
        PreferenceHandler.removeDataForKey("loginTime")
    }
    func resetModels() {
        modelQuickPayGetAccountBill = nil
        modelQuickPayGetBillActivity = nil
        modelQuickPayUpdateBillPrefernce = nil
        modelQuickPayCreatePayment = nil
        modelQuickPayImmediatePayment = nil
        modelQuickPayOneTimePayment = nil
        modelQuickPayeOutage = nil
        modelListPayment = nil
        modelConsolidatedDetail = nil
        modelCustomerTenure = nil
        modelQuickPayCreateBankAccount = nil
    }
    func resetFlags() {
        isGetAccountBillCompleted = false
        isMauiAccountListCompleted = false
        isGetAccountActivityCompleted = false
        isRouterContainsLegacySettings = false
        isFromAutoPaySettingsView = false
        isListBillsCompeletd = false
        APIRequests.shared.isGetAccountBillApiFailed = true
        APIRequests.shared.isListPaymentsApiFailed = true
        self.ismauiMainApiInProgress.iserror = false
        self.ismauiMainApiInProgress.isprogress = true
        dataRefreshNeedOnMyAccountAfterChat = false
    }
}

struct LocalSavedPaymethod {
    let payMethod: PayMethod?
    let save: Bool?
}
