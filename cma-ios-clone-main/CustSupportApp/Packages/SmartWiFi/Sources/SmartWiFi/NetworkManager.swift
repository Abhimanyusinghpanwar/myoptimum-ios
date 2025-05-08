//
//  NetworkManager.swift
//  
//
//  Created by vsamikeri on 6/29/22.
//

import Foundation

public enum APIError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
    case authorizationFailed(Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Request Failed"
        case .invalidStatusCode(_):
            return "UnExpected Response"
        case .authorizationFailed(_):
            return "Authorization Failed"
        }
    }
}

class NetworkManager {

    
    enum HttpMethod: String {
        case get
        case post
        
        var method: String {
            rawValue.uppercased()
        }
    }
    
    func request<T: Decodable> (fromURL url: URL, httpMethod: HttpMethod = .get, completion: @escaping (Result<T, Error>)->Void) {
        
        let completionOnMain: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.method
        
        if url.absoluteString.contains("logout.cmd") || url.absoluteString.contains("generateToken")  {
            deleteCookies()
        }
        if let sharedCookie = HTTPCookieStorage.shared.cookies
        {
            if url.absoluteString.contains("signal-qual") {
                request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: sharedCookie)
                if let xsrfTemp =  sharedCookie.first(where: {$0.name == "XSRF-TOKEN"}) {
                    request.addValue(xsrfTemp.value, forHTTPHeaderField: "X-XSRF-TOKEN")
                    print("XSRF Added")
                }
            }
        }
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForRequest = 60
        
        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completionOnMain(.failure(error))
                return
            }
            
            guard let urlResponse = response as? HTTPURLResponse else { return completionOnMain(.failure(APIError.invalidResponse)) }
            if !(200..<300).contains(urlResponse.statusCode) {
                if urlResponse.statusCode == 401 || urlResponse.statusCode == 302 {
                    return completionOnMain(.failure(APIError.authorizationFailed(urlResponse.statusCode)))
                }
                return completionOnMain(.failure(APIError.invalidStatusCode(urlResponse.statusCode)))
            }
            
            guard let data = data else { return }
            
            if url.absoluteString.contains("logout.cmd") { return }
            
            do {
                let query = try JSONDecoder().decode(T.self, from: data)
                completionOnMain(.success(query))
            } catch {
                debugPrint("Could not translate the data to the requested type. Reason: \(error.localizedDescription)")
                completionOnMain(.failure(error))
            }
        }
        
        // Start the request
        urlSession.resume()
    }
    
    func deleteCookies() {
        let shared = HTTPCookieStorage.shared
        for cookie in shared.cookies ?? [] {
            shared.deleteCookie(cookie)
            print("ALB-Session cookies deleted...")
        }
    }
}
