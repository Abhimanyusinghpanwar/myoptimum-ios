//
//  BillPaymentResponseModels.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 09/12/23.
//

import Foundation

struct ConsolidatedDetailsResponseModel: Decodable {
    let billDetails: BillDetails?
    init(billDetails: BillDetails) {
        self.billDetails = billDetails
    }
    enum CodingKeys: String, CodingKey {
        case billDetails
    }
}

struct BillDetails: Decodable {
    let bill: [Bill]?
    let payments: [ListPayment]?
    let billSummaryList: [BillSummary]?
    enum CodingKeys: String, CodingKey {
        case bill
        case payments
        case billSummaryList
    }
}

