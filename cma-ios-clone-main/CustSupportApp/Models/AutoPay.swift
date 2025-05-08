//
//  AutoPay.swift
//  CustSupportApp
//
//  Created by Chandrakala Neerukonda on 3/8/23.
//

import Foundation

struct AutoPay: Codable {
    let name: String?
    var payMethod: PayMethod?
    let payDayOfMonth: String?
    let payDaysInAdvanced: String?
    let capAmount: AmountInfo?
    let fixAmount: AmountInfo?
    let scheduledAutoAmount: AmountInfo?
    let termsConditions: Bool?
    let initialPayAmount: AmountInfo?
    enum CodingKeys: String, CodingKey {
        case name
        case payMethod
        case payDayOfMonth
        case payDaysInAdvanced
        case capAmount
        case fixAmount
        case termsConditions
        case scheduledAutoAmount
        case initialPayAmount
    }
}


extension AutoPay {
    mutating func update(payMethod: PayMethod) {
        self.payMethod = payMethod
    }
}

extension BillCommunicationPreference {
    mutating func update(email: String?) {
        self.email = email
    }
}
