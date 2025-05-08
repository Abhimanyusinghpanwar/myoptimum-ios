//
//  AppRatingModel.swift
//  CustSupportApp
//
//  Created by Namarta on 12/10/23.
//

import Foundation
// MARK: - Constants
class InAppReviewConstants {
    class var firstQualifyingTimestamp_UserDef: String {
        return "firstQualifyingTimestamp"
    }
    class var lastVersionPromptedForReviewKey_UserDef: String {
        return "lastVersionPromptedForReview"
    }
    class var appEntryCount_UserDef: String {
        return "appEntryCount"
    }
    class var quickPaySuccessCount_UserDef: String {
        return "quickPaySuccessCount"
    }
}

enum QualifyingExpType {
    case selfInstall
    case troubleshooting
    case speedTest
    case quickPay
    case appEntry
}
