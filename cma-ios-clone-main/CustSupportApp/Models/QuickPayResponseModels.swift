//
//  QuickPayAccountsResponseModel.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 21/12/22.
//

import Foundation


// MARK: - QuickPay Accounts API Response
struct QuickPayAccountsResponseModel: Decodable {
    let accounts: [Account]?
    let error: String?
    let error_description: String?

//    init(accounts: [Account]?) {
    init(accounts: [Account]?, error: String?, error_description: String?) {
        self.accounts = accounts
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case accounts
        case error, error_description
    }
    struct Account: Decodable {
        let name: String?
        let accountStatus: String?
        let serviceAddress: ServiceAddress?
        let legacy: Legacy?
        let dmca: Dmca?
        enum CodingKeys: String, CodingKey {
            case accountStatus
            case serviceAddress
            case name, legacy, dmca
        }
    }
    struct ServiceAddress: Decodable {
        let streetNumber: String?
        let streetName: String?
        let addressLine2: String?
        let city: String?
        let state: String?
        let zip: String?
        enum CodingKeys: String, CodingKey {
            case streetNumber
            case streetName
            case addressLine2
            case city
            case state
            case zip
        }
    }
    struct Dmca: Decodable {
        //TO-DO: Need to be updated once we get dmca values from reponse
    }
    struct Legacy: Decodable {
        let accountNumber: String?
        let displayAccountNumber: String?
        enum CodingKeys: String, CodingKey {
            case accountNumber
            case displayAccountNumber
        }
    }
}

// MARK: - QuickPay Pay Methods API Response
struct QuickPayMethodsResponseModel: Decodable {
    let paymethods: [PayMethod]?
    let defaultPaymethod: PayMethod?
    let defaultAutoPaymethod: PayMethod?
    let error: String?
    let error_description: String?

    init(paymethods: [PayMethod]?, defaultPaymethod: PayMethod?, defaultAutoPaymethod: PayMethod?, error: String?, error_description: String?) {
        self.paymethods = paymethods
        self.defaultPaymethod = defaultPaymethod
        self.defaultAutoPaymethod = defaultAutoPaymethod
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case paymethods
        case defaultPaymethod
        case defaultAutoPaymethod
        case error, error_description
    }
}

// MARK: - QuickPay List Bills API Response
struct QuickPayListBillsResponseModel: Decodable {
    let billSummaryList: [BillSummary]?

    init(billSummaryList: [BillSummary]?) {
        self.billSummaryList = billSummaryList
    }
    enum CodingKeys: String, CodingKey {
        case billSummaryList
    }
}

// MARK: - QuickPay Get Bill API Response
struct QuickPayGetBillResponseModel: Decodable {
    let bill: Bill?

    init(bill: Bill?) {
        self.bill = bill
    }
    enum CodingKeys: String, CodingKey {
        case bill
    }
//    struct Bill: Decodable {
//        let name: String?
//        let external_system_account_number: String?
//        let external_system_bill_version: String?
//        let customer_name: String?
//        let billing_address_line1: String?
//        let billing_address_line2: String?
//        let billing_period: BillingPeriod?
//        let due_date: DateTimestamp?
//        let amount_due: AmountDue?
//        let unpaid_balance: UnPaidBalance?
//        let total_amount_due: AmountInfo?
//        let payment: Payment?
//        let payment_description: String?
//        let savings_amount: SavingsAmount?
//        let bill_messages: [BillMessages]?
//        let bill_detailed_item: BillDetailedItem?
//        enum CodingKeys: String, CodingKey {
//            case name
//            case external_system_account_number
//            case external_system_bill_version
//            case customer_name
//            case billing_address_line1
//            case billing_address_line2
//            case billing_period
//            case due_date
//            case amount_due
//            case unpaid_balance
//            case total_amount_due
//            case payment
//            case payment_description
//            case savings_amount
//            case bill_messages
//            case bill_detailed_item
//        }
//    }
//    struct BillingPeriod: Decodable {
//        let start_time: DateTimestamp?
//        let end_time: DateTimestamp?
//        enum CodingKeys: String, CodingKey {
//            case start_time
//            case end_time
//        }
//    }
    struct AmountDue: Decodable {
        let currency_code: String?
        let amount: Double?
        enum CodingKeys: String, CodingKey {
            case currency_code
            case amount
        }
    }
    struct UnPaidBalance: Decodable {
        //TO-DO: Need to be updated once we get dmca values from reponse
    }
    struct Payment: Decodable {
        let currency_code: String?
        let amount: Double?
        enum CodingKeys: String, CodingKey {
            case currency_code
            case amount
        }
    }
    struct SavingsAmount: Decodable {
        //TO-DO: Need to be updated once we get dmca values from reponse
    }
    struct BillMessages: Decodable {
        let description: String?
        enum CodingKeys: String, CodingKey {
            case description
        }
    }
//    struct BillDetailedItem: Decodable {
//        let name: String?
//        let product: Product?
//        let quotes: [Quote]?
//        let item_count: Int?
//        let qty: Int?
//        let qty_min: Int?
//        let qty_max: Int?
//        let extended_price: UnitAndExtendedPrice?
//        enum CodingKeys: String, CodingKey {
//            case name
//            case product
//            case quotes
//            case item_count
//            case qty
//            case qty_min
//            case qty_max
//            case extended_price
//        }
//    }
    struct Quote: Decodable {
        let product: Product?
        let item_count: Int?
        let qty: Int?
        let extended_price: UnitAndExtendedPrice?
        let quotes: [SubQuote]?
        enum CodingKeys: String, CodingKey {
            case product
            case item_count
            case qty
            case extended_price
            case quotes
        }
    }
    struct SubQuote: Decodable {
        let product: Product?
        let item_count: Int?
        let qty: Int?
        let unit_price: UnitAndExtendedPrice?
        let extended_price: UnitAndExtendedPrice?
        enum CodingKeys: String, CodingKey {
            case product
            case item_count
            case qty
            case unit_price
            case extended_price
        }
    }
    struct Product: Decodable {
        let name: String?
        let title: String?
        let has_price: Bool?
        let effective_start_time: DateTimestamp?
        let effective_end_time: DateTimestamp?
        enum CodingKeys: String, CodingKey {
            case name
            case title
            case has_price
            case effective_start_time
            case effective_end_time
        }
    }
    struct UnitAndExtendedPrice: Decodable {
        let promoFrequencyMonthly: PromoFrequencyMonthly?
        enum CodingKeys: String, CodingKey {
            case promoFrequencyMonthly =  "PROMO_FREQUENCY_MONTHLY"
        }
    }
    struct PromoFrequencyMonthly: Decodable {
        let base_price: AmountInfo?
        let net_price: AmountInfo?
        let promo_savings: AmountInfo?
        enum CodingKeys: String, CodingKey {
            case base_price
            case net_price
            case promo_savings
        }
    }
}

// MARK: - QuickPay Get Account Bill API Response
struct QuickPayGetAccountBillResponseModel: Decodable {
    var billAccount: BillAccount?
    let error: String?
    let error_description: String?

    init(billAccount: BillAccount?, error: String?, error_description: String?) {
        self.billAccount = billAccount
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case billAccount
        case error, error_description
    }
    struct BillAccount: Decodable {
        let name: String?
        let classCodeIndicator, manualBlockIndicator: Bool?
        let externalSystemAccountNumber: String?
        var defaultPayMethod: PayMethod?
        var billCommunicationPreferences: BillCommunicationPreference?
        var payMethods: [PayMethod]?
        var autoPay: AutoPay?
        var discountEligible: Bool?
        var hasDiscount: Bool?
//        var isServiceAddress: Bool?
        enum CodingKeys: String, CodingKey {
            case name
            case externalSystemAccountNumber
            case defaultPayMethod
            case billCommunicationPreferences
            case autoPay
            case payMethods
            case classCodeIndicator, manualBlockIndicator
            case discountEligible, hasDiscount
        }
    }
    
//    struct AutoPay: Codable {
//        let name: String?
//        var payMethod: PayMethod?
//        var capAmount: AmountInfo?
//        var payDayOfMonth: String?
//        var emailAddress: String?
//        var termsConditions: Bool?
//        enum CodingKeys: String, CodingKey {
//           case name
//           case payMethod
//           case capAmount
//           case payDayOfMonth
//           case emailAddress
//           case termsConditions
//        }
//    }
    
    
    struct CapAndFixAmount: Decodable {
        let currency_code: String?
        let amount: Double?
        enum CodingKeys: String, CodingKey {
            case currency_code
            case amount
        }
    }
}

// MARK: - QuickPay Get Account Bill Activity API Response
struct QuickPayGetBillActivityResponseModel: Decodable {
    var billPayActivity: BillPayActivity?
    let error: String?
    let error_description: String?
    
    init(billPayActivity: BillPayActivity?, error: String?, error_description: String?) {
        self.billPayActivity = billPayActivity
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case billPayActivity
        case error, error_description
    }
    struct BillPayActivity: Decodable {
        let name: String?
        let recentPayments: [RecentPayment]?
        var nextPaymentDueInfo: NextPaymentDueInfo?
        let deauthStatus: DeauthStatus?
        let ppvInhibitStatus: PpvInhibitStatus?
        let nextPayCapFailure: Bool?
        let customerType: String?
        let currentStatementDate: String?
        let nextStatementDate: String?
        let statementBalance: AmountInfo?
        let billCycle: BillCycle?
        let isPastDue: Bool?
        let pastDueAmount: AmountInfo?
        let ledgerDate, loadDate: String?
        enum CodingKeys: String, CodingKey {
            case name
            case recentPayments
            case nextPaymentDueInfo
            case deauthStatus
            case ppvInhibitStatus
            case customerType
            case currentStatementDate, nextStatementDate
            case statementBalance
            case billCycle
            case isPastDue, nextPayCapFailure
            case pastDueAmount
            case ledgerDate, loadDate
        }
    }
    struct BillCycle: Decodable {
        let startTime, endTime: String?
        enum CodingKeys: String, CodingKey {
            case startTime, endTime
        }
    }
    struct DeauthStatus: Decodable {
        let deauthBalanceDue: AmountInfo?
        let deauthStartDate, deauthEndDate: String?
        let deauthState: String?
        enum CodingKeys: String, CodingKey {
            case deauthBalanceDue
            case deauthStartDate, deauthEndDate
            case deauthState
        }
    }
    struct NextPaymentDueInfo: Decodable {
        let name: String?
        let nextPaymentDate, nextPaymentDueDate: String?
        let nextPaymentDueDays: Double?
        let defaultPaymentNickname: String?
        let nextPaybillAmount: AmountInfo?
        var totalAmountDue: AmountInfo?
        enum CodingKeys: String, CodingKey {
            case name
            case nextPaymentDate, nextPaymentDueDate
            case nextPaymentDueDays
            case defaultPaymentNickname
            case nextPaybillAmount
            case totalAmountDue
        }
    }

    struct PpvInhibitStatus: Decodable {
        let ppvInhibitBalance, ppvInhibitPastBalanceDue: AmountInfo
        let ppvFirstInhibitedDate: String
        let ppvTotalBalance: AmountInfo
        enum CodingKeys: String, CodingKey {
            case ppvInhibitBalance, ppvInhibitPastBalanceDue
            case ppvFirstInhibitedDate
            case ppvTotalBalance
        }
    }
    struct RecentPayment: Decodable {
        let paymentAmount: AmountInfo
        let paymentDate: String
        let paymentStatus, paymentErrorCode: String
        enum CodingKeys: String, CodingKey {
            case paymentAmount
            case paymentDate
            case paymentStatus, paymentErrorCode
        }
    }
}

// MARK: - QuickPay Next Payment Due API Response
struct QuickPayNextPaymentDueResponseModel: Decodable {
    let next_payment_info: NextPaymentInfo?
    let error: String?
    let error_description: String?
    
    init(next_payment_info: NextPaymentInfo?, error: String?, error_description: String?) {
        self.next_payment_info = next_payment_info
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case next_payment_info
        case error, error_description
    }
    struct NextPaymentInfo: Decodable {
        let name: String?
        let next_payment_date: DateTimestamp?
        let next_payment_due_date: DateTimestamp?
        let next_payment_due_days: Double?
        let next_payment_nickname: String?
        let default_payment_nickname: String?
        let next_paybill_amount: AmountInfo?
        let total_amount_due: AmountInfo?
        enum CodingKeys: String, CodingKey {
            case name
            case next_payment_date
            case next_payment_due_date
            case next_payment_due_days
            case next_payment_nickname
            case default_payment_nickname
            case next_paybill_amount
            case total_amount_due
        }
    }
}

// MARK: - QuickPay Get Bill Communication Preferences API Response
struct QuickPayGetBillPrefernceResponseModel: Decodable {
    var billCommunicationPreference: [BillCommunicationPreference?]
    let error: String?
    let error_description: String?
  
    init(billCommunicationPreference: [BillCommunicationPreference?], error: String?, error_description: String?) {
        self.billCommunicationPreference = billCommunicationPreference
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case billCommunicationPreference
        case error, error_description
    }
}

// MARK: - QuickPay update Bill Communication Preferences API Response
struct QuickPayUpdateBillPrefernceResponseModel: Decodable {
    let billCommunicationPreference: BillCommunicationPreference?
    let error: String?
    let error_description: String?
  
    init(billCommunicationPreference: BillCommunicationPreference?, error: String?, error_description: String?) {
        self.billCommunicationPreference = billCommunicationPreference
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case billCommunicationPreference
        case error, error_description
    }
}

// MARK: - QuickPay Create Payment Method API Response
struct QuickPayCreatePaymentResponseModel: Decodable {
    let responseInfo: ResponseInfo?
    let error: String?
    let error_description: String?

    init(responseInfo: ResponseInfo?, error: String?, error_description: String?) {
        self.responseInfo = responseInfo
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case responseInfo
        case error, error_description
    }
    struct ResponseInfo: Decodable {
        let statusCode: String?
        let statusDesc: String?
        let statusType: String?
        enum CodingKeys: String, CodingKey {
            case statusCode
            case statusDesc
            case statusType
        }
    }
}

// MARK: - QuickPay Set Default Payment API Response
struct QuickPaySetDefaultResponseModel: Decodable {
    let defaultPaymethod: PayMethod?

    init(defaultPaymethod: PayMethod?) {
        self.defaultPaymethod = defaultPaymethod
    }
    enum CodingKeys: String, CodingKey {
        case defaultPaymethod
    }
}

// MARK: - QuickPay Get Auto Pay API Response
struct QuickPayGetAutoPayResponseModel: Decodable {
    let autopayResponse: AutoPay?
    let error: String?
    let error_description: String?

    init(autopayResponse: AutoPay?, error: String?, error_description: String?) {
        self.autopayResponse = autopayResponse
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case autopayResponse
        case error, error_description
    }
}

// MARK: - QuickPay Get Auto Pay API Response
struct QuickPayCreateAutoPayResponseModel: Decodable {
    let autoPay: AutopayResponse?
    let error: String?
    let error_description: String?

    init(autoPay: AutopayResponse?, error: String?, error_description: String?) {
        self.autoPay = autoPay
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case autoPay
        case error, error_description
    }
    struct AutopayResponse: Decodable {
        let name: String?
        let payMethod: PayMethod?
        let acceptanceTime: String?
        let termsConditions: Bool?
        enum CodingKeys: String, CodingKey {
            case name
            case payMethod
            case acceptanceTime
            case termsConditions
        }
    }
}

// MARK: - QuickPay Remove Auto Pay API Response
struct QuickPayRemoveAutoPayResponseModel: Decodable {
    let removeAutopay: AutopayResponse?
    let error: String?
    let error_description: String?

    init(removeAutopay: AutopayResponse?, error: String?, error_description: String?) {
        self.removeAutopay = removeAutopay
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case removeAutopay
        case error, error_description
    }
    struct AutopayResponse: Decodable {
        let name: String?
        let payMethod: PayMethod?
        let capAmount: AmountInfo?
        let payDayOfMonth: String?
        let termsConditions: Bool?
        enum CodingKeys: String, CodingKey {
            case name
            case payMethod
            case capAmount
            case payDayOfMonth
            case termsConditions
        }
    }
}

// MARK: - QuickPay Update Auto Pay API Response
struct QuickPayUpdateAutoPayResponseModel: Decodable {
    let updateAutopay: AutopayResponse?
    let error: String?
    let error_description: String?

    init(updateAutopay: AutopayResponse?, error: String?, error_description: String?) {
        self.updateAutopay = updateAutopay
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case updateAutopay
        case error, error_description
    }
    struct AutopayResponse: Decodable {
        let name: String?
        let payMethod: PayMethod?
        let termsConditions: Bool?
        enum CodingKeys: String, CodingKey {
            case name
            case payMethod
            case termsConditions
        }
    }
}


// MARK: - QuickPay account restriction API Response
struct QuickPayAccountRestrictionResponseModel: Decodable {
    let account_restriction: AccountRestriction?
  
    init(account_restriction: AccountRestriction?) {
        self.account_restriction = account_restriction
    }
    enum CodingKeys: String, CodingKey {
        case account_restriction
    }
    struct AccountRestriction: Decodable {
        let name: String?
        let deauth_status: DeauthStatus?
        let ppv_inhibit_status: PpvInhibitStatus?
        enum CodingKeys: String, CodingKey {
            case name
            case deauth_status
            case ppv_inhibit_status
        }
    }
    struct PpvInhibitStatus: Decodable {
        let ppv_inhibit_balance: CountryCode?
        let ppv_inhibit_past_balance_due: CountryCode?
        let ppv_first_inhibited_date: DateTimestamp?
        let ppv_total_balance: CountryCode?
        enum CodingKeys: String, CodingKey {
            case ppv_inhibit_balance
            case ppv_inhibit_past_balance_due
            case ppv_first_inhibited_date
            case ppv_total_balance
        }
    }
    struct DeauthStatus: Decodable {
        let deauth_balance_due: CountryCode?
        let deauth_start_date: DateTimestamp?
        let deauth_end_date: DateTimestamp?
        enum CodingKeys: String, CodingKey {
            case deauth_balance_due
            case deauth_start_date
            case deauth_end_date
        }
    }
    struct CountryCode: Decodable {
        let currency_code: String?
        enum CodingKeys: String, CodingKey {
            case currency_code
        }
    }
}

// MARK: - QuickPay Create Payment Method API Response
struct QuickPayImmediatePaymentResponseModel: Decodable {
    let payment: PaymentImmediate?
    let confirmationNumber: String?
    let error: String?
    let error_description: String?

    init(payment: PaymentImmediate?, confirmationNumber: String?, error: String?, error_description: String?) {
        self.payment = payment
        self.confirmationNumber = confirmationNumber
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case payment
        case confirmationNumber
        case error, error_description
    }
    struct PaymentImmediate: Decodable {
        let payMethod: PayMethod?
        let paymentAmount: AmountInfo?
        let isImmediate: Bool?
        enum CodingKeys: String, CodingKey {
            case payMethod
            case paymentAmount
            case isImmediate
        }
    }
}

// MARK: - QuickPay Create One Time Payment Method API Response
struct QuickPayCreateOneTimePaymentResponseModel: Decodable {
    let responseInfo: ResponseInfo?
    let confirmNumber: String?
    let error: String?
    let error_description: String?
    
    init(responseInfo: ResponseInfo?, confirmNumber: String?, error: String?, error_description: String?) {
        self.responseInfo = responseInfo
        self.confirmNumber = confirmNumber
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case responseInfo
        case confirmNumber
        case error, error_description
    }
    struct ResponseInfo: Decodable {
        let statusCode: String?
        let statusDesc: String?
        let statusType: String?
        let message: Message?
        let ancillaryMessage: String?
        let ancillaryStatusCode: String?
        enum CodingKeys: String, CodingKey {
            case statusCode
            case statusDesc
            case statusType
            case message
            case ancillaryMessage
            case ancillaryStatusCode
        }
    }
    struct Message: Decodable {
        let mainmsg: String?
        let additionalInfo: String?
        let additionalInfoMsg: String?
        let note: String?
        let linkText: String?
        let linkURL: String?
        let intro: String?
        let outro: String?
        enum CodingKeys: String, CodingKey {
            case mainmsg
            case additionalInfo
            case additionalInfoMsg
            case note
            case linkText
            case linkURL
            case intro
            case outro
        }
    }
}

/// MARK: - QuickPay outage API Response
struct QuickPayOutageResponseModel: Decodable {
    let alerts: [Alert]?
    let error: String?
    let error_description: String?
    
    init(alerts: [Alert]?, error: String?, error_description: String?) {
        self.alerts = alerts
        self.error = error
        self.error_description = error_description
    }
    enum CodingKeys: String, CodingKey {
        case alerts
        case error, error_description
    }
    struct Alert: Decodable {
        let name, title, description, priorityLevel: String?
        let effectiveTimePeriod: EffectiveTimePeriod?
        let actionLink: String?
        let actionLabel: String?
        let isPublished: Bool?
        let accessLevel: String?
        let corp: Corp?
        let alertType: String?
        let metadata: Metadata?
        enum CodingKeys: String, CodingKey {
            case name, title, description, priorityLevel
            case effectiveTimePeriod
            case actionLink
            case actionLabel
            case isPublished
            case accessLevel
            case corp
            case alertType
            case metadata
        }
    }
    struct Corp: Decodable {
    }
    struct Metadata: Decodable {
    }
    struct EffectiveTimePeriod: Decodable {
    }
}

/// MARK: - Common Structs
public struct PayMethod: Codable {
    let name: String?
    let creditCardPayMethod: CreditCardPayMethod?
    let bankEftPayMethod: BankEftPayMethod?
    enum CodingKeys: String, CodingKey {
        case name
        case creditCardPayMethod
        case bankEftPayMethod
    }
    init(name: String? = nil, creditCardPayMethod: CreditCardPayMethod? = nil, bankEftPayMethod: BankEftPayMethod? = nil) {
        self.name = name
        self.creditCardPayMethod = creditCardPayMethod
        self.bankEftPayMethod = bankEftPayMethod
    }
}

struct EditPayMethod: Codable { //CMAIOS-2627, 2620,
    let name: String?
    let newNickname: String?
    let bankEftPayMethod: BankEftPayMethod?
    let creditCardPayMethod: CreditCardPayMethod?
    enum CodingKeys: String, CodingKey {
        case name
        case newNickname
        case bankEftPayMethod
        case creditCardPayMethod
    }
    init(name: String? = nil, newNickname: String? = nil, creditCardPayMethod: CreditCardPayMethod? = nil, bankEftPayMethod: BankEftPayMethod? = nil) {
        self.name = name
        self.newNickname = newNickname
        self.creditCardPayMethod = creditCardPayMethod
        self.bankEftPayMethod = bankEftPayMethod
    }
}

 struct CreditCardPayMethod: Codable {
    let nameOnCard: String?
    let maskedCreditCardNumber: String?
    let cardType: String?
    let methodType: String?
    let expiryDate: String?
    let addressLine1: String?
    let addressLine2: String?
    let city: String?
    let state: String?
    let zip: String?
    let isServiceAddress: Bool? //CMAIOS-2782
    enum CodingKeys: String, CodingKey {
        case zip, city, state
        case nameOnCard
        case maskedCreditCardNumber
        case cardType
        case methodType
        case expiryDate
        case addressLine1
        case addressLine2
        case isServiceAddress //CMAIOS-2782
    }
     init(nameOnCard: String? = nil, maskedCreditCardNumber: String? = nil, cardType: String? = nil, methodType: String? = nil, expiryDate: String? = nil, addressLine1: String? = nil, addressLine2: String? = nil, city: String? = nil, state: String? = nil, zip: String? = nil, isServiceAddress: Bool? = nil ) {
         self.nameOnCard = nameOnCard
         self.maskedCreditCardNumber = maskedCreditCardNumber
         self.cardType = cardType
         self.methodType = methodType
         self.expiryDate = expiryDate
         self.addressLine1 = addressLine1
         self.addressLine2 = addressLine2
         self.city = city
         self.state = state
         self.zip = zip
         self.isServiceAddress = isServiceAddress //CMAIOS-2782
     }
}
struct BankEftPayMethod: Codable {
    let nameOnAccount: String?
    let maskedBankAccountNumber: String?
    let routingNumber: String?
    let accountType: String?
    enum CodingKeys: String, CodingKey {
        case nameOnAccount
        case maskedBankAccountNumber
        case routingNumber
        case accountType
    }
}
struct DateTimestamp: Decodable {
    let seconds: Double?
    enum CodingKeys: String, CodingKey {
        case seconds
    }
}
struct AmountInfo: Codable {
    let currencyCode: String?
    var amount: Double?
    enum CodingKeys: String, CodingKey {
        case currencyCode
        case amount
    }
}

struct BillCommunicationPreference: Codable {
    var name: String?
    var email: String?
    var termsConditions, mailNotifyIndicator, paperBillIndicator: Bool?
    enum CodingKeys: String, CodingKey {
        case name, email
        case termsConditions, mailNotifyIndicator, paperBillIndicator
    }
}
struct QuickPayListPaymentResponseModel: Codable {
    let payments: [ListPayment]?
}

struct ListPayment: Codable {
    let name: String?
    let payMethod: PayMethod?
    let paymentAmount: AmountInfo?
    let paymentDate: String?
    var paymentStatus, paymentPosted: String?
    let paymentConfirmationNumber: String?
    let paymentUpdateDate: String?
    let paymentCreationDate: String?
    let isImmediate: Bool?
    let paymentErrorCode: String?
}

struct BillSummary: Decodable {
    let name: String?
    let billDueDate: String?
    let billAmountDue: AmountInfo?
    let statementDate: String?
    let billInserts: [BillInsert]?
    enum CodingKeys: String, CodingKey {
        case name
        case billDueDate
        case billAmountDue
        case statementDate
        case billInserts
    }
}

struct Bill: Decodable {
    let name: String?
    let external_system_account_number: String?
    let external_system_bill_version: String?
    let customer_name: String?
    let billing_address_line1: String?
    let billing_address_line2: String?
    let billing_period: BillingPeriod?
    let due_date: DateTimestamp?
    let amount_due: AmountInfo?
    let unpaid_balance: AmountInfo?
    let total_amount_due: AmountInfo?
    let payment: Payment?
    let payment_description: String?
    let savings_amount: AmountInfo?
    let bill_messages: [BillMessages]?
    let bill_detailed_item: BillDetailedItem?
    enum CodingKeys: String, CodingKey {
        case name
        case external_system_account_number
        case external_system_bill_version
        case customer_name
        case billing_address_line1
        case billing_address_line2
        case billing_period
        case due_date
        case amount_due
        case unpaid_balance
        case total_amount_due
        case payment
        case payment_description
        case savings_amount
        case bill_messages
        case bill_detailed_item
    }
}

struct BillingPeriod: Decodable {
    let start_time: DateTimestamp?
    let end_time: DateTimestamp?
    enum CodingKeys: String, CodingKey {
        case start_time
        case end_time
    }
}

struct BillMessages: Decodable {
    let description: String?
    enum CodingKeys: String, CodingKey {
        case description
    }
}

struct BillDetailedItem: Decodable {
}

struct BillInsert: Decodable {
    let name: String?
    let alertText: String?
    let expiryDate: String?
    let description: String?
    enum CodingKeys: String, CodingKey {
        case name
        case alertText
        case expiryDate
        case description
    }
}

struct SchedulePayment: Codable {
   let parent: String?
   let payment: PayMethod?
   let paymentAmount: AmountInfo?
   let isImmediate: Bool?
   let isCreatePaymethod: Bool?
   enum CodingKeys: String, CodingKey {
       case parent
       case payment
       case paymentAmount
       case isImmediate
       case isCreatePaymethod
   }
    init(parent: String? = nil, payment: PayMethod? = nil, paymentAmount: AmountInfo? = nil, isImmediate: Bool? = nil, isCreatePaymethod: Bool? = nil) {
        self.parent = parent
        self.payment = payment
        self.paymentAmount = paymentAmount
        self.isImmediate = isImmediate
        self.isCreatePaymethod = isCreatePaymethod
    }
}

struct UpdateSchedulePaymentModel: Codable {
   let payment: PaymentSchedule?
   enum CodingKeys: String, CodingKey {
       case payment
   }
    init(payment: PaymentSchedule? = nil) {
        self.payment = payment
    }
}

struct PaymentSchedule: Codable {
   let name: String?
   let payMethod: PayMethod?
   let paymentAmount: AmountInfo?
   let paymentDate: String?
   let isImmediate: Bool?
   let paymentStatus: String?
   enum CodingKeys: String, CodingKey {
       case name
       case payMethod
       case paymentAmount
       case paymentDate
       case isImmediate
       case paymentStatus
   }
    init(name: String? = nil, payMethod: PayMethod? = nil, paymentAmount: AmountInfo? = nil, paymentDate: String? = nil, isImmediate: Bool? = nil, paymentStatus: String? = nil) {
        self.name = name
        self.payMethod = payMethod
        self.paymentAmount = paymentAmount
        self.paymentDate = paymentDate
        self.isImmediate = isImmediate
        self.paymentStatus = paymentStatus
    }
}

struct RemoveScheduleResponseModel: Codable {
   let deletedPayment: PaymentSchedule?
   enum CodingKeys: String, CodingKey {
       case deletedPayment
   }
    init(deletedPayment: PaymentSchedule? = nil) {
        self.deletedPayment = deletedPayment
    }
}

struct DeleteMOPResponseModel: Codable { //CMAIOS-2578
   let payMethod: PayMethod?
   enum CodingKeys: String, CodingKey {
       case payMethod
   }
    init(payMethod: PayMethod? = nil) {
        self.payMethod = payMethod
    }
}

struct CreateScheduleResponseModel: Codable {
    let confirmationNumber: String?
    let payment: PaymentSchedule?
    enum CodingKeys: String, CodingKey {
        case confirmationNumber
        case payment
    }
    init(confirmationNumber: String? = nil, payment: PaymentSchedule?) {
        self.confirmationNumber = confirmationNumber
        self.payment = payment
    }
}

// MARK: - Get Bank Image from Routing Number API Response
struct bankImageRoutingNumberModel: Decodable {
    let bankName: String?
    let bankImage: String?
    
    init(bankName: String?, bankImage: String?) {
        self.bankName = bankName
        self.bankImage = bankImage
    }
    enum CodingKeys: String, CodingKey {
        case bankName
        case bankImage
    }
}

// MARK: - Customer Tenure API response
struct CustomerTenure: Decodable {
    let customer: Customer
}
struct Customer: Decodable {
    let individual: Individual
}
struct Individual: Decodable {
    let tenureDate: String?
}
