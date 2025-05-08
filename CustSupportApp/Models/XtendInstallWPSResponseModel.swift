//
//  XtendInstallWPSResponseModel.swift
//  CustSupportApp
//
//  Created by vsamikeri on 10/31/22.
//

import Foundation

struct XtendInstallWPSResponseModel: Codable {
    let desc: String?
    let error: Int?
    let phstatus: Phstatus?
    enum CodingKeys: String, CodingKey {
        case desc
        case error
        case phstatus
    }
    init(desc: String?, error: Int?, phstatus: Phstatus?) {
        self.desc = desc
        self.error = error
        self.phstatus = phstatus
    }
}

// MARK: - Phstatus
struct Phstatus: Codable {
    let code: Int?
    let message, messageCode: String?
    enum CodingKeys: String, CodingKey {
           case code, message
           case messageCode
       }
    init(code: Int?, message: String?, messageCode: String?) {
        self.code = code
        self.message = message
        self.messageCode = messageCode
    }
}

