//
//  File.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 17/06/24.
//

extension QuickPayManager {
    
    // Get last four digits for Bank or nickname
    func getLastFourDigitsOrNicknameForBank(payMethod: PayMethod?) -> (String, String) {
        var lastFourDigit = ""
        var nickName = ""
        if let maskedNumber = payMethod?.bankEftPayMethod?.maskedBankAccountNumber {
            lastFourDigit = String(maskedNumber.suffix(4))
        }
        if let name = payMethod?.name?.components(separatedBy: "/").last {
            nickName = name
        }
        return (lastFourDigit, nickName)
    }
    
    func getLastFourDigitsOfCCNickName(paymethod: PayMethod?) -> (String, String) {
        var lastFourDigit = ""
        var nickName = ""
        
        nickName = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: paymethod).1
        if let maskedCreditCardNumber = paymethod?.creditCardPayMethod?.maskedCreditCardNumber, !maskedCreditCardNumber.isEmpty {
            // If maskedBankAccountNumber is empty, check the credit card number
            lastFourDigit = maskedCreditCardNumber.count == 4 ? maskedCreditCardNumber : ""
        }
        return (nickName, lastFourDigit)
    }
    
    //CMAIOS-2413
    func getPaymentInfo(payMethod:PayMethod?)->(nickname:String, lastFourDigits : String, isMOPBank: Bool){
        guard let payMethodDetails = payMethod else {
            return ("", "", false)
        }
        var lastFourDigits = ""
        var nickname = ""
        var isMOPBank = false
        if payMethodDetails.bankEftPayMethod != nil {
            let bankDetails = QuickPayManager.shared.getLastFourDigitsOrNicknameForBank(payMethod: payMethod)
            if !bankDetails.0.isEmpty {
                lastFourDigits = bankDetails.0
            }
            nickname = bankDetails.1
            isMOPBank = true
        } else {
            if payMethodDetails.creditCardPayMethod != nil {
                let cardDetails = QuickPayManager.shared.getLastFourDigitsOfCCNickName(paymethod: payMethod)
                if !cardDetails.1.isEmpty {
                    lastFourDigits = cardDetails.1
                }
                nickname = cardDetails.0
            }
        }
        return (nickname, lastFourDigits, isMOPBank)
    }
    
    // CMAIOS:-2637
    func mopDetailsForFailure(defaultNickName: String, payMethod: PayMethod?) -> String {
        let payMethod = QuickPayManager.shared.getPaymentInfo(payMethod: payMethod)
        let nickNameMOP = payMethod.nickname
        var nickName = defaultNickName
        let lastFourDigits = payMethod.lastFourDigits
        if !nickNameMOP.isEmpty {
            nickName = nickNameMOP
        } else if !lastFourDigits.isEmpty {
            nickName = "\(defaultNickName) ending with \(lastFourDigits)"
        }
        return nickName
    }
}
