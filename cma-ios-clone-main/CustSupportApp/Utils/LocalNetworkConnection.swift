//
//  LocalNetworkConnection.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/21/22.
//

import Foundation
import Network

var sharedConnection: LocalNetworkConnection?

protocol LocalNetworkConnectionDelegate: AnyObject {
    func localConnection(isAvailable: Bool, error: NWError?)
}

class LocalNetworkConnection {
    
    weak var delegate: LocalNetworkConnectionDelegate?
    var localConnection: NWConnection?
    let connectionStarted: Bool
    
    init(delegate: LocalNetworkConnectionDelegate, localConnection: NWConnection, connectionStarted: Bool) {
        self.delegate = delegate
        self.localConnection = localConnection
        self.connectionStarted = true
        startConnection()
    }
    
    func startConnection() {
        guard let localConnection = localConnection else {
            return
        }
        
        localConnection.pathUpdateHandler = { [weak self] path in
            
            switch path.status {
            case .satisfied:
                if let delegate = self?.delegate {
                    delegate.localConnection(isAvailable: true, error: nil)
                }
                Logger.info("\(String(describing: path.status))", sendLog: "Local Connection status")
            case .unsatisfied:
                if #available(iOS 14.2, *) {
                    if case .localNetworkDenied = localConnection.currentPath?.unsatisfiedReason {
                        Logger.info("\(localConnection.currentPath?.unsatisfiedReason as Any)", sendLog: "Unsatisfied reason")
                        if let delegate = self?.delegate {
                            delegate.localConnection(isAvailable: false, error: nil)
                        }
                    } else {
                        Logger.info("No Local Network Route")
                        if let delegate = self?.delegate {
                            delegate.localConnection(isAvailable: false, error: NWError.posix(.ENETDOWN))
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
                Logger.info("\(String(describing: path.status))", sendLog: "Local Connection status")
            case .requiresConnection:
                Logger.info("\(String(describing: path.status))", sendLog: "Local Connection status")
                
            @unknown default:
                Logger.info("\(String(describing: path.status))", sendLog: "Local Connection status")
            }
        }
        localConnection.start(queue: .main)
    }
    
    func cancel() {
        if let localConnection = self.localConnection {
            localConnection.cancel()
            self.localConnection = nil
        }
    }
}

