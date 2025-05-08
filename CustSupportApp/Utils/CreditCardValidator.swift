//
//  CreditCardValidator.swift
//  CustSupportApp
//
//  Created by Jason Melvin Ready on 6/17/22.
//

import Foundation

enum CreditCardType: String, CaseIterable{
    case Visa       = "^4"
    case Mastercard = "^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)"
    case Amex       = "^3[47]"
    case Discover   = "^6(?:011|5[0-9]{2})"
//    case DinersClub = "^3(?:0[0-5]|[68][0-9])"
//    case JCB        = "^(?:2131|1800|35[0-9]{3})"
//    case Maestro    = "^(?:5[0678][0-9][0-9]|6304|6390|67[0-9][0-9])"
//    case UnionPay   = "^62[0-5]"
//    case Mir        = "^2"
    
    public var cardImage: String {
        switch self {
        case .Visa:
            return "Visa"
        case .Mastercard:
            return "MasterCard"
        case .Amex:
            return "Amex"
        case .Discover:
            return "Discover"
//        case .DinersClub:
//            return "DinersClub"
//        case .JCB:
//            return "JCB"
//        case .Maestro:
//            return "Maestro"
//        case .UnionPay:
//            return "UnionPay"
//        case .Mir:
//            return "Mir"
        }
    }
    
    public var cardName: String {
        switch self {
        case .Visa:
            return "Visa"
        case .Mastercard:
            return "MasterCard"
        case .Amex:
            return "Amex"
        case .Discover:
            return "Discover"
//        case .DinersClub:
//            return "DinersClub"
//        case .JCB:
//            return "JCB"
//        case .Maestro:
//            return "Maestro"
//        case .UnionPay:
//            return "UnionPay"
//        case .Mir:
//            return "Mir"
        }
    }
    
    
    public var minimumLength: Int {
        switch self {
        case .Visa:
            return 13
        case .Amex:
            return 15
//        case .Maestro:
//            return 8
//        case .UnionPay:
//            return 13
//        case .Mir:
//            return 6
        default:
            return 16
        }
    }
    
    public var totalValidation: String {
        switch self {
        case .Visa:
            return rawValue + "[0-9]{12}(?:[0-9]{3})?$"
        case .Mastercard:
            return rawValue + "[0-9]{12}$"
        case .Amex:
            return rawValue + "[0-9]{13}$"
        case .Discover:
            return rawValue + "[0-9]{12}$"
//        case .DinersClub:
//            return rawValue + "[0-9]{11}$"
//        case .JCB:
//            return rawValue + "[0-9]{11}$"
//        case .Maestro:
//            return rawValue + "[0-9]{8,15}$"
//        case .UnionPay:
//            return rawValue + "[0-9]{13,16}$"
//        case .Mir:
//            return rawValue + "[0-9]{6,}$"
        }
    }
}

class CreditCardValidator{
    public static func cardType(cardNumber: String) -> CreditCardType? {
            for testType in CreditCardType.allCases {
                if cardNumber.range(of: testType.rawValue, options: .regularExpression, range: nil, locale: nil) != nil{
                    return testType
                }
            }
        return nil
    }
    
    public static func isValidNumber(cardNumber: String, includeRegexValidation: Bool = false) -> Bool {
        let isValidChecksum = performLuhnAlgorithmValidation(cardNumber: cardNumber)
        guard includeRegexValidation, isValidChecksum else {
            return isValidChecksum
        }
        for testType in CreditCardType.allCases {
            if cardNumber.range(of: testType.totalValidation, options: .regularExpression, range: nil, locale: nil) != nil {
                return true
            }
        }
        return false
    }
    
    private static func performLuhnAlgorithmValidation(cardNumber: String) -> Bool {
        //perform the Luhn Algorithm
        if cardNumber.count == 0 {
            return false
        }
        let doubleEvenDigits = cardNumber.count % 2 == 0
        var currentSum:Int = 0
        for i in 0...(cardNumber.count - 1) {
            if let currentDigit:Int = cardNumber[String.Index(utf16Offset: i, in: cardNumber)].wholeNumberValue{
                if ((i % 2 == 0) && doubleEvenDigits) || ((i % 2 == 1) && !doubleEvenDigits){
                    let doubleDigit = currentDigit * 2
                    currentSum += doubleDigit % 10
                    if doubleDigit > 9 {
                        currentSum += doubleDigit / 10
                    }
                }
                else{
                    currentSum += currentDigit
                }
            }
            else{
                //card number contains characters outside of [0-9]
                return false
            }
        }
        return currentSum % 10 == 0
    }
    
    public static func isValidNumberFor(cardType:CreditCardType, cardNumber:String) -> Bool{
        return CreditCardValidator.cardType(cardNumber: cardNumber) == cardType && CreditCardValidator.isValidNumber(cardNumber: cardNumber, includeRegexValidation: true)
    }
}

public enum CardType: String, CaseIterable, Identifiable {
    case masterCard = "MasterCard"
    case visa = "Visa"
    case amex = "Amex"
    case discover = "Discover"
    case dinersClubOrCarteBlanche = "Diner's Club/Carte Blanche"
    case unknown
    
    public init(number: String?) {
        guard let count = number?.count, count >= 14 else {
            self = .unknown
            return
        }
        switch number?.first {
        case "3":
            if count == 15 {
                self = .amex
            } else if count == 14 {
                self = .dinersClubOrCarteBlanche
            } else {
                self = .unknown
            }
        case "4": self = (count == 13 || count == 16) ? .visa : .unknown
        case "5": self = count == 16 ? .masterCard : .unknown
        case "6": self = count == 16 ? .discover : .unknown
        default: self = .unknown
        }
    }
    
    public var id: Int { hashValue }
    
//    public var image: Image? {
//        switch self {
//        case .masterCard: return Image("mastercard-\(Color.isDarkInterfaceStyle ? "white" : "dark")-bg", bundle: .module)
//        case .visa: return Image("visa", bundle: .module)
//        case .amex: return Image("amex", bundle: .module)
//        case .discover: return Image("discover", bundle: .module)
//        case .dinersClubOrCarteBlanche: return Image("dinersclub", bundle: .module)
//        case .unknown: return nil
//        }
//    }
}
