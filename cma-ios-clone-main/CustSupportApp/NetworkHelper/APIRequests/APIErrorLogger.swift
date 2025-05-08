//
//  APIErrorLogger.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 17/05/23.
//

import Foundation
import Alamofire

/*
 {
   "screen": "Home", // Screen names needs to be defined. Will be used for GA reporting as well.
   "section": "Unknown", // Plan is to add later.
   "request": {
     "url": "https://dev.cma.alticeusa.com/api/example",
     "id": "ch4jp3gah6bd8lqtc960", // X-Request-Id header value
     "body": "", // Request body; For Maui request, do not send request body for security reasons.
     "timestamp": "2023-05-01T00:00:00Z"
   },
   "error": { // This will be updated if API fails or client parser fails with incorrect data type
     "timestamp": "2023-05-01T00:00:05Z",
     "code": "0", // Error code - Need to finalize the mapping
     "uimessage": "Try again." // This is the user-facing error message; only populate it if user saw the error message <<Error response received from API >>
   }
 }
 */

class APIErrorLogger {
    var failureParam = [String : AnyObject]()
    var xRequestId = ""
    var responseBody = ""
    // MARK: - Error Loggin Request
    func apiErrorLogginCall(requestTimeStamp:String, screen:String, body:String?, requestURL:String, uiMessage:String, response:HTTPURLResponse?, responseData: Data? ){
        // Error Logging
        if let response = response, let requestId = response.allHeaderFields["X-Request-Id"] as? String, !requestId.isEmpty {
            xRequestId = requestId
        }
        if let response = responseData, let body = String(data: response, encoding: .utf8), !body.isEmpty {
            responseBody = body
        }
        failureParam["screen"] = screen as AnyObject?
        failureParam["section"] = "Unknown" as AnyObject?
        
        var requestParam = [String : AnyObject]()
        requestParam["url"] = requestURL as AnyObject?
        requestParam["id"] = xRequestId as AnyObject?
        requestParam["body"] = body as AnyObject?
        requestParam["timestamp"] = requestTimeStamp as AnyObject?
        failureParam["request"] = requestParam as AnyObject?
        
        var errorParam = [String : AnyObject]()
        errorParam["timestamp"] = Date().getDateForErrorLog() as AnyObject?
        errorParam["code"] = "0" as AnyObject?
        errorParam["uimessage"] = uiMessage as AnyObject?
        errorParam["response"] = responseBody as AnyObject
        failureParam["error"] = errorParam as AnyObject?
        
        self.performErrorAPIRequest(completionHandler: { success, error in
        })
        }
    
    func performErrorAPIRequest(completionHandler:@escaping (_ success:Bool, _ error: AFError?) -> Void) {
        let queue = DispatchQueue(label: "ErrorLog-queue", attributes: DispatchQueue.Attributes.concurrent)//added the queue to keep it off the main queue
        
        let requestObj = RequestBuilder(url: (ERROR_LOGGING_API), method: .post,
                                        serviceKey: ServiceKey.errorLogging, jsonParams: failureParam,
                                        encoding: JSONEncoding() as ParameterEncoding ).buildNetworkRequest()
        requestObj.validate().responseDecodable(of: ErrorLoggingResponse.self, queue: queue, dataPreprocessor: PassthroughPreprocessor(), decoder: JSONDecoder(), emptyResponseCodes: [204, 205], emptyRequestMethods: [.head]) { (response) in
            
            switch response.result {
            case .success(_):
                self.clearData()
                completionHandler(true, nil)
            case .failure(_):
                Logger.info("failure")
                self.clearData()
                completionHandler(false, nil)
            }
        }
    }
    func clearData() {
        self.failureParam = [:]
        self.xRequestId = ""
        self.responseBody = ""
    }
}
