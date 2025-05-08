//
//  ReachabilityManager.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 07/08/23.
//

import Foundation
import Reachability

class ReachabilityManager {
    static let shared = ReachabilityManager()
    private let reachability = try! Reachability()
    private var internetErrorViewController: InternetErrorMessageViewController?
    
     var isNetworkAvailable: Bool = true {
        didSet {
            if isNetworkAvailable != oldValue {
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["status": isNetworkAvailable])
                
                if isNetworkAvailable {
                    dismissInternetErrorViewController()
                }
            }
        }
    }
    
    private init() {
        reachability.whenReachable = { [weak self] _ in
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["status": true])
            self?.isNetworkAvailable = true
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            self?.isNetworkAvailable = false
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["status": false])
            self?.presentInternetErrorViewController()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start network notifier")
        }
    }
    func presentInternetErrorViewController() {
        if let topViewController = UIApplication.topViewController() {
            if internetErrorViewController == nil {
                if let internetErrorMessageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "InternetErrorMessageVC") as? InternetErrorMessageViewController {
                    internetErrorMessageVC.modalPresentationStyle = .fullScreen
                    topViewController.present(internetErrorMessageVC, animated: true)
                    internetErrorViewController = internetErrorMessageVC
                }
            }
        }
    }
    
    func dismissInternetErrorViewController() {
        if let presentedViewController = internetErrorViewController {
            presentedViewController.dismiss(animated: true, completion: {
                self.internetErrorViewController = nil
            })
        }
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("NetworkStatusChanged")
}
