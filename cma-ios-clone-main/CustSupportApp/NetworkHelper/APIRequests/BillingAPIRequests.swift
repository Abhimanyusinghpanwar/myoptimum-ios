//
//  BillingAPIRequests.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 07/02/24.
//

import Foundation
import Alamofire

// MARK: - Billing API REQUESTS
extension APIRequests {
    
    func mauiCreateBankAccountPaymethodRequest(interceptor: RequestInterceptor?, jsonParam: [String: AnyObject], isDefault: Bool, paramName: String, nickName: String, completionHandler: @escaping (_ success: Bool, _ value: QuickPayCreatePaymentResponseModel?, _ error: AFError?) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let nameParam = "?name=\(paramName)"
        var urlPath = MAUI_CREATE_BANKACCOUNTPAYMETHOD_URL + nameParam
        if isDefault {
            urlPath = MAUI_CREATE_BANKACCOUNTPAYMETHOD_URL + nameParam + "&default=true"
        }
        let request = RequestBuilder(url: urlPath, method: .post, serviceKey: .mauiCreatePayment, jsonParams: jsonParam, encoding: JSONEncoding() as ParameterEncoding).buildNetworkRequestWithInterceptor(interceptor: interceptor)
        request.validate().responseDecodable(of: QuickPayCreatePaymentResponseModel.self, completionHandler: { response in
            switch response.result {
            case .success(let value):
                Logger.info("Create Bank Paymethod Request Succeded")
                completionHandler(true, value, nil)
            case .failure(let value):
                Logger.info("Create Bank Paymethod Request Failed")
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "QuickPay", body: "", requestURL: urlPath, uiMessage: "", response: response.response, responseData: response.data)
                completionHandler(false, nil, value)
            }
        })
    }
    
    
}
