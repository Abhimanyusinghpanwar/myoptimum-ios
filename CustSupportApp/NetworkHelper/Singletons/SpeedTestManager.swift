//
//  SpeedTestManager.swift
//  CustSupportApp
//
///  Created by Sai Pavan Neerukonda on 9/8/22.
//

import Alamofire

class SpeedTestManager {
    class var shared: SpeedTestManager {
        struct Singleton {
            static let instance = SpeedTestManager()
        }
        return Singleton.instance
    }
    
    func startSpeedTest(completion: @escaping (Result<SpeepTestResponse, Error>) -> Void) {
        var requestTimeStamp = ""
        requestTimeStamp = Date().getDateForErrorLog()
        let deviceMac = (MyWifiManager.shared.deviceMAC ?? "") + "?sessionid=\(MyWifiManager.shared.sessionID)"
        let speedTestURL = SPEEDTEST_PATH_URL + "/\(deviceMac)"
        let request = RequestBuilder(url: speedTestURL, method: .get, serviceKey: .speedTest, jsonParams: buildRequest().dictionary as? [String: AnyObject], encoding: URLEncoding() as ParameterEncoding).buildNetworkRequest()
        request.validate().responseDecodable(of: SpeepTestResponse.self, completionHandler: { response in
            
            switch response.result {
            case let .success(value):
                Logger.info(response.value.debugDescription, sendLog: "Speed Test success")
                completion(.success(value))
            case let .failure(error):
                Logger.info(error.localizedDescription, sendLog: "Speed Test failure")
                completion(.failure(error))
                let errorLogger = APIErrorLogger()
                errorLogger.apiErrorLogginCall(requestTimeStamp: requestTimeStamp, screen: "Login", body:(MyWifiManager.shared.deviceType != nil) ? CommonUtility.jsonToString(json: self.buildRequest().dictionary as AnyObject?) : "", requestURL: speedTestURL, uiMessage: "Sorry, we ran into a problem and can’t run a speed test right now.", response: response.response, responseData: response.data)
            }
        })
    }
    
    func buildRequest() -> SpeedTestRequest {
        guard let deviceType = MyWifiManager.shared.deviceType else {
            fatalError("deviceType, deviceMac & deviceIP values are required")
        }
        let deviceIP = MyWifiManager.shared.deviceIP
        let fiberOperational = MyWifiManager.shared.fiberOperationalStatus?["OperationalStatusAPIResponseFiber"] as? OperationalStatusAPIResponseFiber
        let oltip: String? = fiberOperational?.oltip
        let oltName: String? = fiberOperational?.oltname
        var onu: String?
        if let oltCardId = fiberOperational?.oltcardid,
           let oltponportid = fiberOperational?.oltponportid,
           let oltonuid = fiberOperational?.oltonuid {
            onu = "\(oltCardId)/\(oltponportid)/\(oltonuid)"
        }
        let region = MyWifiManager.shared.getRegion()
        let request = SpeedTestRequest(accessTech: (MyWifiManager.shared.getWifiType() == "Modem") ? "docsis" :  MyWifiManager.shared.accessTech, gwip: deviceIP, olt: oltName, onu: onu, bw: nil, region: region, deviceType: deviceType, oltIP: oltip, bwUp: MyWifiManager.shared.bwUp, bwDown: MyWifiManager.shared.bwDown)
        
        return request
    }
}
