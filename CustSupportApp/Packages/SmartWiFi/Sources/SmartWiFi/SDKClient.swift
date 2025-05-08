//
//  SDKClient.swift
//  
//
//  Created by vsamikeri on 6/29/22.
//

import Foundation
import CryptoKit

let apiKey: String = "6B67DDCA7E4CCE7B"
var deviceModel: String = ""

public class SDKClient {
    
    public static let sharedClient = SDKClient()
    let networkManger = NetworkManager()
    lazy var gatewayIPAddress = "192.168.1.1"
    lazy var clientIPAddress: String? = ""
    var baseURL: String = "http://192.168.1.1/"
    private var freqBand = [""]
    
    public func getIdentityCheck(completionResult: @escaping (Bool?, Error?) ->Void ) {
        
        guard let url = URL(string: baseURL + "ss-json/fgw.identity.check.json") else {fatalError("Invalid URL")}
        
        networkManger.request(fromURL: url) { (result: Result<IdentityCheck, Error>) in
            switch result {
            case .success(let query):
                let messageSec = self.processDataForSHAOperation(identityModel: query)
                deviceModel = query.eqModel ?? "NA"
                self.freqBand = query.wifiFreqSupported ?? [""]
                self.generateToken { tokenData, error in
                    
                    let hashToken =  self.generateHmac(token: tokenData?.tk ?? "", message: messageSec)
                    if error != nil {
                        completionResult(false,error)
                    }
                    self.validateToken(token: tokenData?.tk ?? "", hash: hashToken) { isSuccess in
                        
                        if isSuccess {
                            
                            completionResult(true, nil)
                        }
                        else {
                            completionResult(false, nil)
                        }
                    }
                }
                
            case .failure(let error):
                debugPrint("Request Failed trying to get the response. The error is: \(error.localizedDescription)")
                completionResult(false,error)
            }
        }
    }
    
    func generateToken(_ tokenResult : @escaping (GenerateToken?, Error?)->Void ) {
        guard let url = URL(string: baseURL + "authApp.cmd?action=generateToken") else {fatalError("Invalid URL")}
        
        networkManger.request(fromURL: url) { (result: Result<GenerateToken, Error>) in
            switch result {
            case .success(let query):
                tokenResult(query, nil)
                debugPrint("We got a successful result with Token....")
                
            case .failure(let error):
                debugPrint("Request Failed trying to get the Token. The error is: \(error.localizedDescription)")
                tokenResult(nil,error)
            }
        }
    }
    
    func validateToken(token : String , hash : String,completionResult: @escaping (Bool) ->Void) {
        guard let url = URL(string: baseURL + "authApp.cmd?action=validateToken&tk=\(token)&hash=\(hash)") else {fatalError("Invalid URL")}
        
        networkManger.request(fromURL: url) { (completion: Result<ValidateToken, Error>) in
            switch completion {
            case .success(let data):
                print(data)
                completionResult(true)
                
            case .failure(let error):
                debugPrint("Request Failed trying to validate the Token. The error is: \(error.localizedDescription)")
            }
        }
    }

    public func getSignalQuality(completionResult : @escaping (SignalQuality?, Error?) -> Void) {
        clientIPAddress = WiFiUtils.getLocalWiFiIpAddress()
        var param = ""
        if freqBand.count > 2 {
            param = "&bandType=triband"
        }
        guard let url = URL(string: baseURL + "locallmngt.cmd?request=household/local/clients/\(clientIPAddress ?? "")/signal-qual" + "\(param)") else {fatalError("Invalid URL")}
        networkManger.request(fromURL: url) { (completion: Result<SignalQuality, Error>) in
            switch completion {
            case .success(let signalQuality):
                debugPrint("Signal Quality is successful with Result: \(signalQuality).")
                completionResult(signalQuality, nil)
                
            case .failure(let error):
                debugPrint("Request Failed trying to get the Signal Quality. The error is: \(error.localizedDescription)")
                completionResult(nil, error)
            }
        }
    }
    
    public func logoutSession(completionResult: @escaping (Bool?, Error?) ->Void ) {
        guard let url = URL(string: baseURL + "logout.cmd") else {fatalError("Invalid URL")}
        
        networkManger.request(fromURL: url) { (completion: Result<Logout, Error>) in
            switch completion {
            case .success(let data):
                debugPrint("Logout is done. We got a successful result with \(data) bytes.")
                
            case .failure(let error):
                debugPrint("Logout operation failed. The error is: \(error.localizedDescription)")
            }
        }
    }
}

extension SDKClient {
    
    func processDataForSHAOperation(identityModel:IdentityCheck?) -> String {
        var message = ""
        if let serialNumber = identityModel?.serialNumber {
            message = message + serialNumber + apiKey
        } else {
            debugPrint("SHA operation failed")
        }
        message = message.sha256(data: message.data(using: .utf8)!)
        return message
    }
    
    func generateHmac(token: String, message: String) -> String {
        let hash = message.hmac(algorithm: CryptoAlgorithm.SHA256, key: token)
        return hash
    }
}
