//
//  CreditCardPayMethod + Extension.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 2/5/23.
//

import Foundation

extension CreditCardPayMethod {
    var isCardExpired: Bool {
        guard let expirySeconds = expiryDate else {
            return true
        }
        let expireDate = CommonUtility.dateFromTimestamp(dateString: expirySeconds)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        guard let enteredDate = calendar.date(byAdding: .month, value: 1, to: expireDate) else { return false }
        return enteredDate <= Date()
    }
    
    var isCardExpiresSoon: Bool {
        guard let expirySeconds = expiryDate else {
            return true
        }
        let expireDate = CommonUtility.dateFromTimestamp(dateString: expirySeconds)
        // 90 days check
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        guard let currentExpDate = calendar.date(byAdding: .month, value: 1, to: expireDate), currentExpDate > Date() else { return false }
        guard let enteredDate = calendar.date(byAdding: .month, value: -2, to: expireDate) else { return false }
        return enteredDate <= Date()
    }
}
