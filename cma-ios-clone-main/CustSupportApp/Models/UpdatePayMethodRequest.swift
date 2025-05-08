//
//  UpdatePayMethodRequest.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 2/8/23.
//

import Foundation
//CMAIOS-2627, 2620
struct UpdatePayMethodRequest: Codable {
    let payMethod: PayMethod?
}

struct EditPayMethodRequest: Codable {
    let payMethod: EditPayMethod?
}

struct EditPayMethodResponse: Codable {
    let payMethod: EditPayMethod?
}

struct UpdatePayMethodResponse: Codable {
    let payMethod: PayMethod?
}

struct UpdateAutoPayResponse: Codable {
    let updateAutopay : AutoPay
}

struct RemoveAutoPayResponse: Codable {
    let removeAutopay: AutoPay
}
