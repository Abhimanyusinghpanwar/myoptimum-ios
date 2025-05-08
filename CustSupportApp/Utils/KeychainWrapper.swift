//
//  KeychainWrapper.swift
//  CustSupportApp
//
//  Created by vsamikeri on 5/23/22.
//

/*!
 
 @desc      The KeychainWrapper is used to save sensitive data securely for now deviceID/Username.
 
 @usage     KeychainWrapper.store(forKey: "deviceID") - To save the new items.
            KeychainWrapper.read(forKey: "deviceID") - To retireve the saved items.
            KeychainWrapper.delete(forKey: "deviceID") - To delete and item from keychain.
 */

import Foundation

class KeychainWrapper {
    
    static func store(forKey service: String, _ value: String) throws {
        
        if value.isEmpty {
            try delete(forKey: service)
            return
        }
        
        guard let valueData = value.data(using: .utf8) else {
            Logger.info("Bad Data: Error in converting value to data")
            throw KeychainError(type: .badData)
        }
        
        let query: [String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
                                         kSecAttrService as String: service as AnyObject,
                                         kSecValueData as String: valueData as AnyObject]
        
        let currentStatus = SecItemAdd(query as CFDictionary, nil)
        
        switch currentStatus {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            try update(forKey: service, value)
            
        default:
            throw KeychainError(status: currentStatus, type: .servicesError)
        }
        Logger.info("Item saved in KeyChain")
    }
    
    static func read(forKey service: String) throws -> String? {
        
        let query: [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecMatchLimit as String: kSecMatchLimitOne,
                                   kSecReturnAttributes as String: true,
                                   kSecReturnData as String:true]
        
        var result: CFTypeRef?
        let currentStatus = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard currentStatus != errSecItemNotFound else {
            throw KeychainError(type: .itemNotFound)
        }
        
        guard currentStatus == errSecSuccess else {
            throw KeychainError(status: currentStatus, type: .servicesError)
        }
        
        guard let existingResult = result as? [String:Any],
              let valueData = existingResult[kSecValueData as String] as? Data,
              let value = String(data: valueData, encoding: .utf8) else {
            throw KeychainError(type: .unableToConvertToString)
        }
        
        return value
    }
    
    static func update(forKey service: String, _ value: String) throws {
        guard let valueData = value.data(using: .utf8) else {
            Logger.info("Error converting value to data.")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: valueData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw KeychainError(message: "Matching Item Not Found", type: .itemNotFound)
        }
        guard status == errSecSuccess else {
            throw KeychainError(status: status, type: .servicesError)
        }
    }
    
    static func delete(forKey service: String) throws {
        let query: [String:Any] = [ kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service]
        
        let currentStatus = SecItemDelete(query as CFDictionary)
        guard currentStatus == errSecSuccess || currentStatus == errSecItemNotFound else {
            throw KeychainError(status: currentStatus, type: .servicesError)
        }
    }
}

struct KeychainError: Error {
    var message: String?
    var type: KeychainErrorType
    
    enum KeychainErrorType {
        case badData
        case servicesError
        case itemNotFound
        case unableToConvertToString
    }
    
    init(status: OSStatus, type: KeychainErrorType) {
        self.type = type
        if let errorMessage = SecCopyErrorMessageString(status, nil) {
            self.message = String(errorMessage)
        } else {
            self.message = "Status Code: \(status)--"
        }
    }
    
    init(type: KeychainErrorType) {
        self.type = type
    }
    
    init(message: String, type: KeychainErrorType) {
        self.message = message
        self.type = type
    }
}
