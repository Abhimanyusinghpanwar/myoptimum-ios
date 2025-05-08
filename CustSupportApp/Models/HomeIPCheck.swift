//
//  HomeIPCheck.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/16/22.
//

import Foundation

struct HomeIPCheck: Codable {
    let isInHome: Bool
    let homeIp: String
    let requestIp: String
}
