//
//  CardPaymentRequest.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 07/02/23.
//

import Foundation

// Create Payment and One time payment
struct Card: Codable {
    let newNickname: String?
    let creditCardPayMethod: CreditCardPayMethod?
}

// Create Ach Payment
struct Ach: Codable {
    let newNickname: String?
    let bankEftPayMethod: BankEftPayMethod?
}

struct OneTimePaymentInfo: Codable {
    let payMethod: Card?
    let paymentAmount: AmountInfo?
}
struct CreateOneTimePayment: Codable {
    let payment: OneTimePaymentInfo?
}

struct SchedulePaymentWithNewCard: Codable {
    let payment: SchdulePaymentNewCardInfo?
}

struct SchedulePaymentWithNewAch: Codable {
    let payment: SchdulePaymentNewAchInfo?
}

// Create Immediate Paymethod
struct CreateImmediatePayment: Codable {
    let parent: String
    let payment: Payment
//    let isCreatePaymethod: Bool
}

// Create Schedule Paymethod With Existing Paymethod
struct CreateSchedulePayment: Codable {
    let parent: String?
    let payment: PaymentWithDate?
    let isCreatePaymethod: Bool?
}

// Update Schedule Payment
struct UpdateSchedulePayment: Codable {
    let parent: String?
    let payment: PaymentWithDate?
}

struct Payment: Codable {
    let payMethod: PayMethodInfo?
    let paymentAmount: AmountInfo?
    let isImmediate: Bool?
}

struct PaymentWithDate: Codable {
    let payMethod: PayMethodInfo?
    let paymentAmount: AmountInfo?
    let isImmediate: Bool?
    let paymentDate: String?
}

struct PayMethodInfo: Codable {
    let name: String?
}

// Create AutoPay
struct CreatAutoPay: Codable {
    let parent: String?
    let autoPay: AutoPay?
    
    struct AutoPay: Codable {
        let payMethod: PayMethodInfo?
    }
}

// Create AutoPay with initialPayAmount
struct CreatAutoPayWithInitialPayment: Codable {
    let parent: String?
    let autoPay: AutoPay?
    
    struct AutoPay: Codable {
        let payMethod: PayMethodInfo?
        let initialPayAmount: AmountInfo?
    }
}

struct SchdulePaymentNewCardInfo: Codable {
    let payMethod: Card?
    let paymentAmount: AmountInfo?
    let paymentDate: String?
}

// Create Payment and One time payment
struct BankAccout: Codable {
    let newNickname: String?
    let bankEftPayMethod: BankEftPayMethod?
}

struct SchdulePaymentNewAchInfo: Codable {
    let payMethod: Ach?
    let paymentAmount: AmountInfo?
    let paymentDate: String?
}
