//
//  File.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 28/02/23.
//


enum State: Equatable {
    case expireDateError(isExpired: Bool)
    case defaultDisclaimer
    case normal
    case dueCreditApplied
    case noDue
    case pastDue
    case manualBlock
    case autoPay
}

enum PaymentEnabledType { //CMAIOS-1748 Needs to check which payment is enabled to show the SP or AP cards
    case autopay
    case scheduled
    case both // autopay And Scheduled
    case none
}

extension QuickPayManager {
    
    enum ViewBillScreenState : Equatable {
        case failedBillApi
        case noBillHistory
        case none
    }
    
    enum NextDuePayDayState {
        case today
        case yesterday
        case pastTwoDays
        case anyFutureDay
        case none
    }
    
    ///  Method used to get the basic account List and account deauth status
    func initialBasicQuickPayInfo() {
        self.accountsListRequest()
    }
    
    /// Set the screentype and it would be used in the QuickPay Landing screen to define the initial screen
    func initialScreenType() {
        let totalDue = Double(getCurrentAmount()) ?? 0.0 // If default is 0 = Not Due screen, value > 0 fallback other scenarios
        let isAutoPayEnabled = isAutoPayEnabled()
        let isAccountManualBlocked = isAccountManualBlocked()
        let isPastDueExist = isPastDueExist()
        
        switch (totalDue < 0, totalDue == 0, totalDue > 0, isAutoPayEnabled, isAccountManualBlocked, isPastDueExist) {
        case (_, _, true, _, true,_):
            initialScreenFlow = .manualBlock
        case (_, true, _, _, _, _), (true, _, _, _, _, _):
            initialScreenFlow = .noDue
        case (_, _, _, _, _, true):
            initialScreenFlow = .pastDue
        case (_, _, _, true,_,_):
            initialScreenFlow = .autoPay
        default:
            initialScreenFlow = .normal
        }
    }
    
    /// ScreenType without Manual Condition only for My bill screen
    func initialScreenTypeWithOutManualBlock() {
        let totalDue = Double(getCurrentAmount()) ?? 0.0 // If default is 0 = Not Due screen, value > 0 fallback other scenarios
        let isAutoPayEnabled = isAutoPayEnabled()
        let isPastDueExist = isPastDueExist()
        
        switch (totalDue < 0, totalDue == 0, totalDue > 0, isAutoPayEnabled, isPastDueExist) {
        case (_, true, _, _, _), (true, _, _, _, _):
            initialScreenFlow = .noDue
        case (_, _, _, _, true):
            initialScreenFlow = .pastDue
        case (_, _, _, true,_):
            initialScreenFlow = .autoPay
        default:
            initialScreenFlow = .normal
        }
    }
    
    func getInitialScreenFlowState() -> State {
        var state: State = .normal
        switch initialScreenFlow {
        case .normal:
            state = .normal
        case .noDue:
            state = .noDue
        case .defaultDisclaimer:
            state = .defaultDisclaimer
        case .dueCreditApplied:
            state = .dueCreditApplied
        case .pastDue:
            state = .pastDue
        case .expireDateError:
            state = .expireDateError(isExpired: true)
        case .manualBlock:
            state = .manualBlock
        case .autoPay:
            state = .autoPay
        }
        return state
    }
    
    /// Check whether the past due exist
    func isPastDueExist() -> Bool {
        if simulatePastDue {
            return true
        }
        var exist = false
        guard let pastDue = modelQuickPayGetBillActivity?.billPayActivity?.pastDueAmount?.amount else {
            return exist
        }
        if pastDue > 0 {
            exist = true
        }
        return exist
    }
    
    /// Check whether the auto pay is enabled or not
    func isAutoPayEnabled() -> Bool {
        var enabled = false
        if let payMethodType = modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod,
           payMethodType.bankEftPayMethod != nil || payMethodType.creditCardPayMethod != nil {
            enabled = true
        }
        return enabled
    }
    
    /// Check Account is manually blocked
    func isAccountManualBlocked() -> Bool {
        var restricted = false
        if let classCodeIndicator = modelQuickPayGetAccountBill?.billAccount?.classCodeIndicator,
           classCodeIndicator  {
            restricted = true
        }
        // CMA-186 bug fix
        else if let manualBlockIndicator = modelQuickPayGetAccountBill?.billAccount?.manualBlockIndicator, manualBlockIndicator {
            restricted = true
        }
        return restricted
    }
    
    /// Get the Account name and that would be used as unique id for APIs
    func getAccountName() -> String {
        guard let name = modelAccountsList?.accounts?.first?.name else {
            return ""
        }
        return name
    }
    
    /// Get the bill account name and that would be used as unique id for get bill API
    func getBillNameFromBillList() -> String {
        guard (modelQuickPayListBill?.billSummaryList?.count ?? 0) > 12,  let name = modelQuickPayListBill?.billSummaryList?[11].name else { // Added for mock data validation, should be replaced with the below condition
            //    guard let name = modelQuickPayListBill?.billSummaryList?.first?.name else {
            return ""
        }
        return name
    }
    
    /// Get the current due amount
    func getCurrentAmount() -> String {
        if enableDeAuth || enablePreDeAuth {
            return "20.55"
        }
        guard let currentAmount = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.totalAmountDue?.amount else {
            return ""
        }
        let amount = String(format: "%.2f", currentAmount)
        return amount
    }
    
    /// Get the statement balance amount
    func getStatementBalanceAmount() -> String {
        guard let amount = modelQuickPayGetBillActivity?.billPayActivity?.statementBalance?.amount else {
            return ""
        }
        let balanceAmount = String(format: "%.2f", amount) // CMAIOS-1488
        return "\(balanceAmount)"
    }
    
    /// Get the current due date
    func getDueDate(_ format: String = "MMM. d, YYYY") -> String {
        guard let nextDue = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate else {
            return ""
        }
        return CommonUtility.convertDateStringFormats(dateString: nextDue, dateFormat: format)
    }
    
    /// Get the current due date
    func getHistoryMonth(date: Date?, format: String) -> String? {
        var dateString: String?
        guard let dateFormat = date else {
            return dateString
        }
        dateString = CommonUtility.getDateStringDate(date: dateFormat, dateFormat: format)
        return dateString
    }
    
    /// Get the Auto pay ScheduleDate date
    func getAutoPayScheduleDate() -> String {
        guard let payment = modelListPayment?.payments?.first(where: { $0.name?.contains(self.getAccountNam() + "/payments/ScheduledAutoPayment") ?? false }),
              payment.paymentStatus == "PAYMENT_STATUS_SCHEDULED", payment.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT"  else {
            return ""
        }
        if let nextPayDue = payment.paymentDate {
            return CommonUtility.convertDateStringFormats(dateString: nextPayDue, dateFormat: "MMM. d, YYYY")
        }
        return ""
    }
    
    // CMAIOS-1868
    /// Get the Auto pay ScheduleDate date string
    func getAutoPayScheduleDateString() -> String {
        guard let payment = modelListPayment?.payments?.first(where: { $0.name?.contains(self.getAccountNam() + "/payments/ScheduledAutoPayment") ?? false }),
              payment.paymentStatus == "PAYMENT_STATUS_SCHEDULED",
              payment.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT",
              let paymentDate = payment.paymentDate else {
            return ""
        }
        return paymentDate
    }
    
    /// Validate and get the initial  default Pay Method
    func getPayMethodMop() -> (Bool, String, String) {
        guard let paymethod = getDefaultPayMethod() else {
            return (false, "", "")
        }
        return getPayMethodDispalyInfo(payMethod: paymethod) // (bank or Card, card or bank acc number, image name)
    }
    
    func getDefaultPayMethod() -> PayMethod? {
        guard hasDefaultPaymentMethod() else {
            guard isAutoPayEnabled() else {
                return modelQuickPayGetAccountBill?.billAccount?.payMethods?.first
            }
            return getDefaultAutoPaymentMethod()
        }
        return modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod
    }
    
    /// Get default Auto Paymethod
    func getAutoPayMethodMop() -> (Bool, String, String) {
        var paymethodInfo = (false, "", "") // (bank or Card, card or bank acc number, image name)
        if let paymethod = modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
            paymethodInfo = getPayMethodDispalyInfo(payMethod: paymethod)
        }
        return paymethodInfo
    }
    
    /// Get Paymethod for Autopay Setup
    func getPaymethodNameForAutoPaySetup() -> String? {
        if let name = tempPaymethod?.name {
            return name
        }
        return self.getDefaultPayMethod()?.name
    }
    
    /// Get All Pay Methods
    //    func getAllPayMethodMop() -> [PayMethod] {
    //        var paymethodList: [PayMethod] = []
    //        if let defaultPaymethod = modelQuickPayMethods?.defaultPaymethod {
    //            paymethodList.append(defaultPaymethod)
    //        }
    //        if let paymethods = modelQuickPayMethods?.paymethods {
    //            paymethodList.append(contentsOf: paymethods)
    //        }
    //        return paymethodList
    //    }
    
    /// Get All Pay Methods
    func getAllPayMethodMop() -> [PayMethod] {
        var paymethodList: [PayMethod] = []
        let defaultPaymethod = modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod
//        if let defaultPaymethod = defaultPaymethod, defaultPaymethod.name != nil {
//            paymethodList.append(defaultPaymethod)
//        }
        if let autoPay = modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod, autoPay.name != defaultPaymethod?.name {
            paymethodList.append(autoPay)
        }
        if let defaultPaymethod = defaultPaymethod, defaultPaymethod.name != nil {
            paymethodList.append(defaultPaymethod)
        }
        if let paymethods = modelQuickPayGetAccountBill?.billAccount?.payMethods {
            paymethodList.append(contentsOf: paymethods)
        }
        return paymethodList
    }
    
    /// Is Paymethods Available
    func isPaymethodsAvailable() -> Bool {
        var isAvailable = true
        if modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
            isAvailable = false
        }
        return isAvailable
    }
    
    func checkingNameExists(newName:String) -> Bool {
        let payMethods = self.getAllPayMethodMop()
        let exists = payMethods.contains { $0.name?.components(separatedBy: "/").last ?? "" == newName }
        return exists
    }
    
    /// Is  Accout Activity Available
    func isAccoutActivityAvailable() -> Bool {
        var isAvailable = true
        if modelQuickPayGetBillActivity?.billPayActivity == nil {
            isAvailable = false
        }
        return isAvailable
    }
    
    /// Is  Get autopay available
    func isGetAutoPayAvailable() -> Bool {
        var isAvailable = true
        if modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod == nil {
            isAvailable = false
        }
        return isAvailable
    }
    
    /// Validates the available paymethod (card or bank)
    /// - Parameter payMethod: will be processed to get the paymethod (card or bank)
    /// - Returns: (Bool, String, String) -> (card or bank, payment display name, image name)
    func getPayMethodDispalyInfo(payMethod: PayMethod?) -> (Bool, String, String) {
        var paymethodInfo = (false, "", "")
        if let carPayemnthod = payMethod?.creditCardPayMethod, let carType = carPayemnthod.cardType {
            let nickName = payMethod?.name?.components(separatedBy: "/").last ?? ""
            paymethodInfo = (true, nickName, self.getCardType(cardType: carType))
        }
        if payMethod?.bankEftPayMethod?.maskedBankAccountNumber != nil {
            if let name = payMethod?.name {
                let nickName = name.components(separatedBy: "/").last ?? ""
                //CMAIOS-2157
                paymethodInfo = (false, nickName, "routingBorderImage") // This will be update with dynamic bank image in future
            }
        }
        return paymethodInfo
    }
    
    /// Check Pay Method has DefaultPayment
    func hasDefaultPaymentMethod() -> Bool {
        var enabled = false
        if modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name != nil {
            enabled = true
        }
        return enabled
    }
    
    /// Get  Default Auto Payment
    func getDefaultAutoPaymentMethod() -> PayMethod? {
        var payMethod: PayMethod?
        if let defaultAutoPay = modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod {
            payMethod = defaultAutoPay
        }
        return payMethod
    }
    
    func getDefaultScheduledPaymentMethod() -> PayMethod? {
        var payMethod: PayMethod?
        QuickPayManager.shared.isOneTimePaymentScheduled(onCompletion: { paymentInfo, paymentScheduled in
            if let defaultPayMethod = paymentInfo?.payMethod {
                payMethod = defaultPayMethod
            }
        })
        return payMethod
    }
    
    func getScheduledPaymentAmount() -> Double {
        var totalAmount: Double = 0.0
        QuickPayManager.shared.getAllOneTimePaymentSchedules(onCompletion: { paymentsList, paymentScheduled in
            if paymentScheduled {
                totalAmount = paymentsList?.compactMap { $0.paymentAmount?.amount as? Double }.reduce(0, +) ?? 0.0
            }
        })
        return totalAmount
    }
    
    // CMAIOS-2002
    func getScheduledPaymentAmountsTillDueDate() -> Double {
        var totalAmount: Double = 0.0
        QuickPayManager.shared.getAllOneTimePaymentSchedulesTillDueDate(onCompletion: { paymentsList, paymentScheduled in
            if paymentScheduled {
                totalAmount = paymentsList?.compactMap { $0.paymentAmount?.amount as? Double }.reduce(0, +) ?? 0.0
            }
        })
        return totalAmount
    }
    
    //CMAIOS-2478
    func getSchduledPaymentsForSpecificMOP(selectedMOPInfo: PayMethod?)-> (isPaymentScheduled: Bool, totalSPs:Int){
        var isPaymentScheduled: Bool = false
        var totalSPs:Int = 0
        QuickPayManager.shared.getAllOneTimePaymentSchedules { paymentsList, paymentScheduled in
            if paymentScheduled {
                let arrOfSPs = paymentsList?.filter({
                    $0.payMethod?.name?.isMatching(selectedMOPInfo?.name) ?? false
                })
                if let arrOfSPsExists = arrOfSPs, arrOfSPsExists.count > 0 {
                    let arrTotalSPs  = NSMutableOrderedSet(array: arrOfSPsExists).array as! [ListPayment]? //remove duplicate objects
                    Logger.info("Total no of schedulePayments with selectedMOP for delete \(String(describing: arrTotalSPs?.count))")
                    totalSPs = arrTotalSPs?.count ?? 0
                    isPaymentScheduled = true
                } else {
                    totalSPs = 0
                    isPaymentScheduled = false
                }
            }
        }
        return (isPaymentScheduled, totalSPs)
    }
    
    
    /// Get Card type name
    func getCardType(cardType: String) -> String {
        var cardTypeName = "bankCard" // CMAIOS-2098
        switch cardType {
        case "CREDIT_CARD_TYPE_VISA":
            cardTypeName = "Visa"
        case "CREDIT_CARD_TYPE_MASTERCARD":
            cardTypeName = "MasterCard"
        case "CREDIT_CARD_TYPE_AMERICAN_EXPRESS":
            cardTypeName = "Amex"
        case "CREDIT_CARD_TYPE_DISCOVER":
            cardTypeName = "Discover"
        default: break
        }
        return cardTypeName
    }
    
    /// Get Card type int value
    func getCardName(cardName: String) -> String {
        var cardType = "Visa"
        switch cardName {
        case "Visa":
            cardType = "CREDIT_CARD_TYPE_VISA"
        case "MasterCard":
            cardType = "CREDIT_CARD_TYPE_MASTERCARD"
        case "Amex":
            cardType = "CREDIT_CARD_TYPE_AMERICAN_EXPRESS"
        case "Discover":
            cardType = "CREDIT_CARD_TYPE_DISCOVER"
        default: break
        }
        return cardType
    }
    
    /// Get Account name
    func getAccountNam() -> String {
        guard let accountName = modelAccountsList?.accounts?.first?.name else {
            return ""
        }
        return accountName
    }
    
    /// Get Default PayMethod
    func getImmediatePayMethod(isAutoPay: Bool) -> PayMethod? {
        if let paymethod = modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod {
            return paymethod
        }
        return nil
    }
    
    /// Get PayMethod Info
    func payMethodInfo(payMethod: PayMethod?) -> (String, String, String, String) {
        var paymethodInfo = ("", "", "", "")
        var routNumber = ""
        if let carPayemnthod = payMethod?.creditCardPayMethod,
           let carType = carPayemnthod.cardType, let expiryDate = carPayemnthod.expiryDate {
            let nickName = payMethod?.name?.components(separatedBy: "/").last ?? ""
            paymethodInfo = (nickName, QuickPayManager.shared.getCardType(cardType: carType), CommonUtility.convertDateStringFormats(dateString: expiryDate, dateFormat: "MM/yy"), routNumber)
        }
        if payMethod?.bankEftPayMethod?.routingNumber != nil {
            routNumber = payMethod?.bankEftPayMethod?.routingNumber ?? ""
        }
        if payMethod?.bankEftPayMethod?.maskedBankAccountNumber != nil {
            if let name = payMethod?.name {
                let nickName = name.components(separatedBy: "/").last ?? ""
                //CMAIOS-2157
                paymethodInfo = (nickName, "CheckingImage", "Checking account", routNumber) // This will be update with dynamic bank image in future
            }
        }
        return paymethodInfo
    }
    
    /// Get PaperLess Billing state
    ///  If paperlessbilling is enabled, "paperBillIndicator" would be nil and true for disabled mode
    func isPaperLessBillingEnabled() -> Bool {
        var isEnabled = false
        if self.modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences?.paperBillIndicator == nil {
            isEnabled = true
        }
        return isEnabled
    }
    
    /// Get Bill communication prefernce email
    func getBillCommunicationEmail() -> String {
        var emailId = ""
        if let email = modelQuickPayGetAccountBill?.billAccount?.billCommunicationPreferences?.email {
            emailId = email
        }
        return emailId
    }
    
    /// Get Past Due Amount
    func getPastDueAmount() -> String {
        if simulatePastDue {
            return "20.55"
        }
        guard let pastDueAmount = modelQuickPayGetBillActivity?.billPayActivity?.pastDueAmount?.amount else {
            return ""
        }
        let dueAmount = String(format: "%.2f", pastDueAmount)
        return "\(dueAmount)"
    }
    
    /// Get De-Auth state
    func getDeAuthState() -> String {
        if enableDeAuth {
            return "DE_AUTH_STATE_DEAUTH"
        } else if enablePreDeAuth {
            return "DE_AUTH_STATE_PREDEAUTH"
        }
        guard let deAuthState = modelQuickPayGetBillActivity?.billPayActivity?.deauthStatus?.deauthState else {
            return ""
        }
        return deAuthState
    }
    
    /// Get Days from next due date
    func getDaysForNextDue() -> String {
        guard let nextDue = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate else {
            return ""
        }
        //        let date = CommonUtility.getDateFromDueDateString(dueDateString: nextDue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        //        let days = Date().getDays(toDate: date)
        //        return  "\(String(describing: days))"
        
        let currentDate = Date().getModifiedCurrentDate()
        let expireDate = CommonUtility.dateFromTimestamp(dateString: nextDue)
        let difference = currentDate.distance(from: expireDate, only: .day)
        var daysCount = 0
        switch (difference == 1, difference <= 0) {
        case (true, _):
            daysCount = 0
        case (_, true):
            var finalDays = 0
            if difference == 0 {
                finalDays = 0
            } else {
                finalDays = abs(difference)
            }
            daysCount = finalDays + 1
        default: break
        }
        return "\(String(describing: daysCount))"
    }
    
    /// Check whether the next payment day state (today, yesterday, past two days, Any future days)
    func nextPaymentDayState() -> NextDuePayDayState { // CMAIOS-1197
        var state: NextDuePayDayState = .none
        guard let dueDays = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDays else {
            /*
            if self.getDaysForNextDue() == "0" {
                state = .today
            }
             */
            state = .today
            return state
        }
        switch (dueDays, dueDays > 0, dueDays < -1) {
        case (0, _, _):
            state = .today
        case (-1, _, _):
            state = .yesterday
        case (_, _, true):
            state = .pastTwoDays
        case (_, true, _):
            state = .anyFutureDay
        default: break
        }
        return state
        
        /*
         var state: NextDuePayDayState = .none
         guard let nextDue = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate else {
         return .none
         }
         //        let date = CommonUtility.getDateFromDueDateString(dueDateString: nextDue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
         //        return Date() > date
         
         let currentDate = Date().getModifiedCurrentDate()
         let expireDate = CommonUtility.dateFromTimestamp(dateString: nextDue)
         let difference = currentDate.distance(from: expireDate, only: .day)
         
         //        If  difference == 1 same day
         //        If  difference <= 0 Future day
         //        If  difference > 1  passeds days
         
         switch (difference == 1, difference <= 0, difference > 1) {
         case (true, _, _):
         state = .today
         case (_, true, _):
         state = .anyFutureDay
         case (_, _, true) where (difference == 2):
         state = .yesterday
         case (_, _, true) where (difference > 2):
         state = .pastTwoDays
         default:
         state = .none
         }
         return state
         */
    }
    
    /*
     /// Next payment date state from nextPaymentDueDate
     /// - Returns: (today, yesterday, past two days, Any future days)
     private func nextPaymentDayStateFromDueDate() -> NextDuePayDayState {
     var state: NextDuePayDayState = .none
     guard let nextDue = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate else {
     return .none
     }
     //        let date = CommonUtility.getDateFromDueDateString(dueDateString: nextDue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
     //        return Date() > date
     
     let currentDate = Date().getModifiedCurrentDate()
     let expireDate = CommonUtility.dateFromTimestamp(dateString: nextDue)
     let difference = currentDate.distance(from: expireDate, only: .day)
     
     //        If  difference == 1 same day
     //        If  difference <= 0 Future day
     //        If  difference > 1  passeds days
     
     switch (difference == 1, difference <= 0, difference > 1) {
     case (true, _, _):
     state = .today
     case (_, true, _):
     state = .anyFutureDay
     case (_, _, true) where (difference == 2):
     state = .yesterday
     case (_, _, true) where (difference > 2):
     state = .pastTwoDays
     default:
     state = .none
     }
     return state
     }
     */
    
    /// Get PaperLess Billing state
    func isAutoPayScheduled() -> Bool {
        guard let payment = modelListPayment?.payments?.first(where: { $0.name?.contains(self.getAccountNam() + "/payments/ScheduledAutoPayment") ?? false }),
              payment.paymentStatus == "PAYMENT_STATUS_SCHEDULED",
              payment.paymentPosted == "PAYMENT_POSTED_AUTO_PAYMENT" else {
            return false
        }
        return true
    }
    
    /// Checks Scheduled one time payments
    /// - Parameter onCompletion: (ListPayment?, Bool) = List payment which happens sooner, sheduled payment available or not
    func isOneTimePaymentScheduled(onCompletion: (ListPayment?, Bool) -> Void) {
        let payments = modelListPayment?.payments?.filter({ $0.name?.contains(self.getAccountNam() + "/payments") ?? false })
        let accountSpecificPayments = payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_SCHEDULED" && $0.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT" })
        let sortedPayments = accountSpecificPayments?.filter({ $0.paymentDate?.getDateFromDateString() ?? Date() > Date().getModifiedCurrentDate() })
        let oneTimePayments = sortedPayments?.sorted(by: { $0.paymentDate?.getDateFromDateString().compare($1.paymentDate?.getDateFromDateString() ?? Date()) == .orderedDescending })
        
        if oneTimePayments?.count ?? 0 > 0 {
            /*
            let currentDate = Date().getModifiedCurrentDate()
            let modifiedPaymentDate = CommonUtility.getDateFromDueDateString(dueDateString: oneTimePayments?[0].paymentDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            let difference = currentDate.distance(from: modifiedPaymentDate, only: .day)
            //        If  difference == 1 same day
            //        If  difference <= 0 Future day
            //        If  difference > 1  passeds days
            if difference.magnitude.toInt < 30 { // Schedule payments should be limited for 30 days in future from current date
                onCompletion(oneTimePayments?[0], true)
            } else {
                onCompletion(nil, false)
            }
             */
            let currentDate = Date().getModifiedCurrentDate()
            let modifiedPaymentDate = CommonUtility.getDateFromDueDateString(dueDateString: oneTimePayments?[0].paymentDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            let components = Calendar.current.dateComponents([.day], from: currentDate, to: modifiedPaymentDate)
            if let days = components.day, days < 31 { // Schedule payments should be limited for 30 days in future from current date
                onCompletion(oneTimePayments?[0], true)
            } else {
                onCompletion(nil, false)
            }
        } else {
            onCompletion(nil, false)
        }
    }
    
    /// Checks Scheduled one time payments
    /// - Parameter onCompletion: ([ListPayment]?, Bool) = All Payments, sheduled payment available or not
    func getAllOneTimePaymentSchedules(onCompletion: ([ListPayment]?, Bool) -> Void) {
        let payments = modelListPayment?.payments?.filter({ $0.name?.contains(self.getAccountNam() + "/payments") ?? false })
        let accountSpecificPayments = payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_SCHEDULED" && $0.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT" })
        let sortedPayments = accountSpecificPayments?.filter({ $0.paymentDate?.getDateFromDateString() ?? Date() > Date().getModifiedCurrentDate() })
        let oneTimePayments = sortedPayments?.sorted(by: { $0.paymentDate?.getDateFromDateString().compare($1.paymentDate?.getDateFromDateString() ?? Date()) == .orderedDescending })
        
        if oneTimePayments?.count ?? 0 > 0 {
            let currentDate = Date().getModifiedCurrentDate()
            let modifiedPaymentDate = CommonUtility.getDateFromDueDateString(dueDateString: oneTimePayments?[0].paymentDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            let difference = currentDate.distance(from: modifiedPaymentDate, only: .day)
            //        If  difference == 1 same day
            //        If  difference <= 0 Future day
            //        If  difference > 1  passeds days
            if difference.magnitude.toInt < 30 { // Schedule payments should be limited for 30 days in future from current date
                onCompletion(oneTimePayments, true)
            } else {
                onCompletion(nil, false)
            }
        } else {
            onCompletion(nil, false)
        }
    }
    
    // CMAIOS-2002
    /// Get Scheduled one time payments Till Due Date
    /// - Parameter onCompletion: ([ListPayment]?, Bool) = All Payments, sheduled payment available or not
    func getAllOneTimePaymentSchedulesTillDueDate(onCompletion: ([ListPayment]?, Bool) -> Void) {
        let payments = modelListPayment?.payments?.filter({ $0.name?.contains(self.getAccountNam() + "/payments") ?? false })
        let accountSpecificPayments = payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_SCHEDULED" && $0.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT" })
        let sortedPayments = accountSpecificPayments?.filter({ $0.paymentDate?.getDateFromDateStringFormat1() ?? Date() > Date().getModifiedCurrentDate() })
        let oneTimePayments = sortedPayments?.sorted(by: { $0.paymentDate?.getDateFromDateStringFormat1().compare($1.paymentDate?.getDateFromDateStringFormat1() ?? Date()) == .orderedDescending })
        
        if let nextDue = QuickPayManager.shared.modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate
        {
            let formattedDueDate = CommonUtility.dateFromTimestamp(dateString: nextDue)
            let sortedPayments = oneTimePayments?.filter({ $0.paymentDate?.getDateFromDateStringFormat1() ?? Date() <= formattedDueDate })
            if sortedPayments?.count ?? 0 > 0 {
                onCompletion(sortedPayments, true)
            } else {
                onCompletion(nil, false)
            }
        } else {
            onCompletion(nil, false)
        }
    }
    
    func isShowScheduledPaymentSpotlight(onCompletion: (ListPayment?, Bool) -> Void) {
        let payments = modelListPayment?.payments?.filter({ $0.name?.contains(self.getAccountNam() + "/payments") ?? false })
        let accountSpecificPayments = payments?.filter({ $0.paymentStatus == "PAYMENT_STATUS_SCHEDULED" && $0.paymentPosted == "PAYMENT_POSTED_ONETIME_PAYMENT" })
        let sortedPayments = accountSpecificPayments?.filter({ $0.paymentDate?.getDateFromDateString() ?? Date() > Date().getModifiedCurrentDate() })
        let oneTimePayments = sortedPayments?.sorted(by: { $0.paymentDate?.getDateFromDateString().compare($1.paymentDate?.getDateFromDateString() ?? Date()) == .orderedDescending })
        
        // CMAIOS-2018
        if oneTimePayments?.count ?? 0 > 0 {
            if let currentAmount = Double(getCurrentAmount()) {
                let fullAmountScheduled = oneTimePayments?.filter({ $0.paymentAmount?.amount ?? 0 >= currentAmount })
                if fullAmountScheduled?.count ?? 0 > 0 {
                    onCompletion(fullAmountScheduled?[0], true)
                } else {
                    onCompletion(nil, false)
                }
            } else {
                onCompletion(nil, false)
            }
        }
        // CMAIOS-2018
        
        /*
        if oneTimePayments?.count ?? 0 == 1 {
            let currentAmount = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.totalAmountDue?.amount ?? 0
            if let oneTimePayment = oneTimePayments?[0], let paymentAmount = oneTimePayment.paymentAmount, let amount = paymentAmount.amount, currentAmount == amount {
                onCompletion(oneTimePayments?[0], true)
            } else {
                onCompletion(nil, false)
            }
        }
         */
    }
    
    func isDueDateTimeReached() -> Bool {
        let dateFormatter = DateFormatter()
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = en_US_POSIX
        guard let nextDue = modelQuickPayGetBillActivity?.billPayActivity?.nextPaymentDueInfo?.nextPaymentDueDate else {
            return false
        }
        let dueDate1 = dateFormatter.date(from: nextDue)!
        let currentDate = dateFormatter.date(from: Date().getDateCurrentDateHmac())
        let remainingDate = Calendar.current.date(byAdding: .hour, value: -72, to: dueDate1)
        if currentDate!.compare(remainingDate!) == .orderedDescending {
            return true
        }
        return false
    }
    
    /// Get the Cap amount
    func getCapAmount() -> String {
        guard let currentAmount = modelQuickPayGetAccountBill?.billAccount?.autoPay?.capAmount?.amount else {
            return ""
        }
        return "\(currentAmount)"
    }
    
    /// Get the scheduled Auto amount
    func getScheduledAutoAmount() -> String {
        guard let scheduledAutoAmount = modelQuickPayGetAccountBill?.billAccount?.autoPay?.scheduledAutoAmount?.amount else {
            return ""
        }
        return "\(scheduledAutoAmount)"
    }
    
    /// If any of these keys (payDayOfMonth, payDayOfMonth, capAmount, fixAmount) available. Then its termed as legacy account
    func isLegacyAccount() -> Bool {
        var isLegacy = false
        if isAutoPayEnabled() {
            if let autoPay = self.modelQuickPayGetAccountBill?.billAccount?.autoPay {
                if autoPay.payDayOfMonth != nil {
                    isLegacy = true
                } else if autoPay.payDaysInAdvanced != nil {
                    isLegacy = true
                } else if autoPay.capAmount != nil {
                    isLegacy = true
                } else if autoPay.fixAmount != nil {
                    isLegacy = true
                } else {
                    isLegacy = false
                }
            } else {
                isLegacy = false
            }
        }
        return isLegacy
    }
    
    /// legacyAutoPayHasProblem
    /// if nextPayCapFailure is true, the auto pay has some pronlem
    /// If total amount due is greater than CapAmount, then its confirmed "AutoPay Problem"
    func legacyAutoPayHasProblem() -> Bool {
        var hasProblem = false
        if isLegacyAccount() {
            //            if let capFailure = self.modelQuickPayGetBillActivity?.billPayActivity?.nextPayCapFailure, capFailure { // CMAIOS-1415
            guard getScheduledAutoAmount() != "", getCapAmount() != "" else {
                return hasProblem
            }
            guard let scheduledAutoAmount = Double(getScheduledAutoAmount()), let capAmount = Double(getCapAmount()) else {
                return hasProblem
            }
            switch (scheduledAutoAmount > 0, capAmount  > 0) {
            case (true, true):
                if scheduledAutoAmount > capAmount {
                    hasProblem = true
                }
            default:
                hasProblem = false
            }
            //            }
        }
        return hasProblem
    }
    
    /// Get the  maskedCardNumer
    func getMaskedCardNumer(payMethod: PayMethod?) -> String {
        guard let cardNumber = payMethod?.creditCardPayMethod?.maskedCreditCardNumber else {
            return ""
        }
        return cardNumber
    }
    
    /// Get the nickName Eg. Master-1111
    func getAutoPayNickName() -> String {
        guard let nickName = modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod?.name?.components(separatedBy: "/").last else {
            return ""
        }
        return nickName
    }
    
    
    func getScheduledPayNickName() -> String {
        var nickName = ""
        QuickPayManager.shared.isOneTimePaymentScheduled(onCompletion: { paymentInfo, paymentScheduled in
            if paymentScheduled {
                guard let cardName = paymentInfo?.payMethod?.name?.components(separatedBy: "/").last else {
                    return
                }
                nickName = cardName
            }
        })
        return nickName
    }
    
    // CMAIOS-2110
    func getOnlyNickName(paymethod: PayMethod?) -> String {
        guard let nickName = paymethod?.name?.components(separatedBy: "/").last else {
            return ""
        }
        return nickName
    }

    func getFirstScheduledDateOfMonth() -> String{
        var currentScheduledDate = ""
        QuickPayManager.shared.isOneTimePaymentScheduled(onCompletion: { paymentInfo, paymentScheduled in
            if paymentScheduled, let scheduledDate = paymentInfo?.paymentDate {
                 currentScheduledDate = scheduledDate
              }
        })
        return currentScheduledDate
    }
    
    func isScheduledPaymentEnabled() -> Bool{
        var isPaymentScheduled = false
        QuickPayManager.shared.isOneTimePaymentScheduled(onCompletion: { paymentInfo, paymentScheduled in
            if paymentScheduled{
                isPaymentScheduled = paymentScheduled
              }
        })
        return isPaymentScheduled
    }
    
    func isAutoPayScheduledSoonerThanScheduledPayment() -> Bool {
        var isAutoPayHappeningSooner = false
        let autoPayDateString = self.getAutoPayScheduleDateString()
        var autoPayDate : Date?
        if !autoPayDateString.isEmpty {
            autoPayDate = autoPayDateString.getDateFromDateStringFormat1() // CMAIOS-1868
        }
        let scheduledDateString = self.getFirstScheduledDateOfMonth()
        var scheduledDate : Date?
        if !scheduledDateString.isEmpty {
            scheduledDate = scheduledDateString.getDateFromDateStringFormat1() // CMAIOS-1868
        }
        let autoPayCardName = getAutoPayNickName()
        let scheduledPayCardName = getScheduledPayNickName()
        ///**Rule for showing autoPayCard:** Check If autoPayDate is smaller than scheduledDate or if both the dates and payMethods are same then show the autoPay spotlightCard otherwise validate SchedulePayment flow and show SP respective cards
        if let scheduledTime = scheduledDate, let autoPayTime = autoPayDate, autoPayTime.compare(scheduledTime) == .orderedAscending ||  (autoPayTime.compare(scheduledTime) == .orderedSame && autoPayCardName.isMatching(scheduledPayCardName)){
            isAutoPayHappeningSooner = true
        }
        return isAutoPayHappeningSooner
    }
    
    func checkAutopayAndScheduledPaymentAreEnabled() -> PaymentEnabledType{
        let isAutoPayEnabled = isAutoPayEnabled()
        let isScheduledPaymentEnabled = isScheduledPaymentEnabled()
        switch (isAutoPayEnabled, isScheduledPaymentEnabled) {
        case (true, false) :
            return .autopay // if only AP is enabled then validate the AutoPay flow only
        case (false, true) :
            return .scheduled // if only SP is enabled then validate the ScheduledPayment flow only
        case (true, true):
            return .both // if both SP + AP is enabled then validate which payment is happening sooner and validate SP or AP flow accordingly to show the respective spotlight cards
        case (false, false):
            return .none
        }
    }
    
    /// Get the Bill pay Notification type
    func setNotificationType() {
        guard MyWifiManager.shared.hasBillPay() else { // Proceed if Bill pay entitlement is enabled, hasBillPay == true
            homeNotificationType = .none
            return
        }
        guard mandatoryDataAvailable() else { // Proceed if all mandatory bill pay api data available for to determine the card
            homeNotificationType = .none
            return
        }
        
        let totalDue = Double(getCurrentAmount()) ?? 0.0 // If default is 0 = Not Due screen, value > 0 fallback other scenarios
        let paymentTypeEnabled = checkAutopayAndScheduledPaymentAreEnabled() // proceed accordingly after checking which payment type is enabled
        let pastDueAmount = Double(getPastDueAmount()) ?? 0
        let isAutoScheduled = isAutoPayScheduled()
        let autoPayMethod = getDefaultAutoPaymentMethod()
        let autoPayHasProblem = legacyAutoPayHasProblem()
        var oneTimeScheduledPayment = false
        self.isShowScheduledPaymentSpotlight { paymentInfo, oneTimePayment in
            oneTimeScheduledPayment = oneTimePayment
        }
        switch (totalDue > 0, totalDue <= 0, paymentTypeEnabled, pastDueAmount > 0, self.getDeAuthState()) {
        case (_, true, _, _, "DE_AUTH_STATE_NONE"):
            homeNotificationType = .none
            validateFlowAsPerPaymentTypeEnabled(paymentTypeEnabled, totalDue, autoPayHasProblem, isAutoScheduled, autoPayMethod)
        case (_, _, _, _, "DE_AUTH_STATE_PREDEAUTH"):
            if pastDueAmount > 0 {
                if oneTimeScheduledPayment { // CMAIOS-1753
                    homeNotificationType = .scheduledOneTimePayment
                } else {
                    homeNotificationType = .includesPastDue
                }
            }
            else {
                homeNotificationType = .preDeAuth
            }
        case (_, _, _, true, "DE_AUTH_STATE_NONE"):
            if oneTimeScheduledPayment {
                homeNotificationType = .scheduledOneTimePayment
            } else {
                homeNotificationType = .PastDue //CMA-183
            }
        case (true, _, .none, _, "DE_AUTH_STATE_NONE"):
            homeNotificationType = .normal
        case (_, _, .autopay, _, _):
            verifyAutoPayFlow(paymentTypeEnabled, totalDue, autoPayHasProblem, isAutoScheduled, autoPayMethod)
        case (_, _, .scheduled, _, _):
            verifyScheduledPaymentFlow(paymentTypeEnabled, totalDue, autoPayHasProblem, autoPayMethod)
        case (_, _, .both, _, _):
            validateFlowAsPerPaymentTypeEnabled(.both, totalDue, autoPayHasProblem, isAutoScheduled, autoPayMethod)
        default:
            homeNotificationType = .none
        }
    }
    
    func verifyAutoPayFlow(_ paymentType: PaymentEnabledType, _ totalDue: Double, _ autoPayHasProblem: Bool, _ isAutoScheduled: Bool, _ autoPayMethod: PayMethod?) {
        let expired = autoPayMethod?.creditCardPayMethod?.isCardExpired ?? false
        let expireSoon = autoPayMethod?.creditCardPayMethod?.isCardExpiresSoon ?? false
        switch (expired, expireSoon, autoPayHasProblem, isAutoScheduled) {
        case (true, _, _, _):
            homeNotificationType = .autoPayExpired
        case (_, true, _, _):
            homeNotificationType = .autoPayExpiresSoon
        case (_, _, true, _):
            homeNotificationType = .autoPayProblem
        case (_, _, _, true):
            if paymentType == .both {
                self.scheduleExpireFlowAfterClearingExpireAutoPayments(totalDue, isAutoScheduled)
            } else {
                if totalDue > 0 {
                    homeNotificationType = .autoPay
                }
                else {
                    homeNotificationType = .none
                }
            }
        default :
            if paymentType == .both {
                self.scheduleExpireFlowAfterClearingExpireAutoPayments(totalDue, isAutoScheduled)
            } else {
                if totalDue > 0 {
                    homeNotificationType = .normal
                }
                else {
                    homeNotificationType = .none
                }
            }
        }
    }
        
    func validateFlowAsPerPaymentTypeEnabled(_ paymentType: PaymentEnabledType, _ totalDue: Double, _ autoPayHasProblem: Bool, _ isAutoScheduled: Bool, _ autoPayMethod: PayMethod?){
        switch paymentType {
        case .autopay:
            verifyAutoPayFlow(paymentType, totalDue, autoPayHasProblem, isAutoScheduled, autoPayMethod) // Need to validate Auto Pay flows even for totalDue <= 0
        case .scheduled:
            verifyScheduledPaymentFlow(paymentType, totalDue, autoPayHasProblem, autoPayMethod)
        case .both:
            if isAutoPayScheduledSoonerThanScheduledPayment() {
                verifyAutoPayFlow(paymentType, totalDue, autoPayHasProblem, isAutoScheduled, autoPayMethod)
            } else {
                verifyScheduledPaymentFlow(paymentType, totalDue, autoPayHasProblem, autoPayMethod)
            }
        case .none:
            break
        }
    }
    
    func verifyScheduledPaymentFlow(_ paymentType: PaymentEnabledType, _ totalDue: Double, _ autoPayHasProblem: Bool, _ autoPayMethod: PayMethod?) {
        let scheduledPayMethod = getDefaultScheduledPaymentMethod()
        let payMethodFromGetBill = self.getSchedulePaymethodFromGetBillAccount(scheduledPayMethod: scheduledPayMethod)
        let expired = payMethodFromGetBill?.creditCardPayMethod?.isCardExpired ?? false
        let expireSoon = payMethodFromGetBill?.creditCardPayMethod?.isCardExpiresSoon ?? false
        var oneTimeScheduledPayment = false
        self.isShowScheduledPaymentSpotlight { paymentInfo, oneTimePayment in
            oneTimeScheduledPayment = oneTimePayment
        }
        switch (expired, expireSoon) {
        case (true, _):
            if self.isSavedCard(schedulePayMethod: scheduledPayMethod) { // CMAIOS-1902
                homeNotificationType = .scheduledPayExpired
            } else {
                homeNotificationType = .none
            }
        case (_, true):
            if self.isSavedCard(schedulePayMethod: scheduledPayMethod) { // CMAIOS-1902
                homeNotificationType = .scheduledPayWillExpire
            } else {
                homeNotificationType = .none
            }
        default :
            if paymentType == .both {
                self.autoPayExpireFlowAfterClearingExpireSchedulePayments(totalDue, autoPayHasProblem, autoPayMethod)
            } else {
                if totalDue > 0 {
                    if oneTimeScheduledPayment {
                        homeNotificationType = .scheduledOneTimePayment
                    } else {
                        homeNotificationType = .normal
                    }
                }
                else {
                    homeNotificationType = .none
                }
            }
        }
    }
    
    /* CMAIOS-2037 */
    /// Check whether the autopay paymethod is expired, expires soon and autoPayHasProblem as per the high priorities 4.5.2, 4.5.1, 4.4
    /// - Parameters:
    ///   - totalDue: total due amount
    ///   - autoPayHasProblem: account has problem in autopay
    ///   - autoPayMethod: Paymenthod for autopay
    private func autoPayExpireFlowAfterClearingExpireSchedulePayments( _ totalDue: Double, _ autoPayHasProblem: Bool, _ autoPayMethod: PayMethod?) {
        let expired = autoPayMethod?.creditCardPayMethod?.isCardExpired ?? false
        let expireSoon = autoPayMethod?.creditCardPayMethod?.isCardExpiresSoon ?? false
        var oneTimeScheduledPayment = false
        self.isShowScheduledPaymentSpotlight { paymentInfo, oneTimePayment in
            oneTimeScheduledPayment = oneTimePayment
        }
        switch (expired, expireSoon, autoPayHasProblem) {
        case (true, _, _):
            homeNotificationType = .autoPayExpired
        case (_, true, _):
            homeNotificationType = .autoPayExpiresSoon
        case (_, _, true):
            homeNotificationType = .autoPayProblem
        default:
            // Fallback to schedule payment flows, since these are low priority cards
            if totalDue > 0 {
                if oneTimeScheduledPayment {
                    homeNotificationType = .scheduledOneTimePayment
                } else {
                    homeNotificationType = .normal
                }
            }
            else {
                homeNotificationType = .none
            }
        }
    }
    
    /* CMAIOS-2037 */
    /// Check whether the scheduled paymethod is expired, expires soon as per the high priorities 4.5.2, 4.5.1
    /// - Parameters:
    ///   - totalDue: total amount due
    ///   - isAutoScheduled: auto pay scheduled or not
    private func scheduleExpireFlowAfterClearingExpireAutoPayments(_ totalDue: Double, _ isAutoScheduled: Bool) {
        let scheduledPayMethod = getDefaultScheduledPaymentMethod()
        let payMethodFromGetBill = self.getSchedulePaymethodFromGetBillAccount(scheduledPayMethod: scheduledPayMethod)
        let expired = payMethodFromGetBill?.creditCardPayMethod?.isCardExpired ?? false
        let expireSoon = payMethodFromGetBill?.creditCardPayMethod?.isCardExpiresSoon ?? false
        let savedCard = self.isSavedCard(schedulePayMethod: scheduledPayMethod) // CMAIOS-1902
        switch (expired, expireSoon, savedCard, isAutoScheduled) {
        case (true, _, true, _):
            homeNotificationType = .scheduledPayExpired
        case (_, true, true, _):
            homeNotificationType = .scheduledPayWillExpire
        case (_, _, _, true):
            //  Fallback to autopay flows, since these are low priority cards
            if totalDue > 0 {
                homeNotificationType = .autoPay
            }
            else {
                homeNotificationType = .none
            }
        default:
            //  Fallback to autopay flows, since these are low priority cards
            if totalDue > 0 {
                homeNotificationType = .normal
            }
            else {
                homeNotificationType = .none
            }
        }
    }
    
    
    // CMAIOS-1937
    private func getSchedulePaymethodFromGetBillAccount(scheduledPayMethod: PayMethod?) -> PayMethod? {
        if let paymethod = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.filter({ $0.name == scheduledPayMethod?.name }), paymethod.count > 0 {
            return paymethod.first
        } else if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == scheduledPayMethod?.name {
            return QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod
        } else if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod?.name == scheduledPayMethod?.name {
            return QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod
        }
        return nil
    }
    
    // CMAIOS-1902
    private func isSavedCard(schedulePayMethod: PayMethod?) -> Bool {
        var savedCard = false
        if let paymethodVal = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.filter({ $0.name == schedulePayMethod?.name }), paymethodVal.count > 0 {
            savedCard = true
        } else if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == schedulePayMethod?.name {
            savedCard = true
        } else if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay?.payMethod?.name == schedulePayMethod?.name {
            savedCard = true
        }
        return savedCard
    }
    
    func checkForLegacySettings(_ value: QuickPayGetAccountBillResponseModel?) {
        if let responseModel = value {
            if let billAccount = responseModel.billAccount {
                if let autoPay = billAccount.autoPay {
                    if autoPay.payDayOfMonth != nil {
                        isRouterContainsLegacySettings = true
                    } else if autoPay.payDaysInAdvanced != nil {
                        isRouterContainsLegacySettings = true
                    } else if autoPay.capAmount != nil {
                        isRouterContainsLegacySettings = true
                    } else if autoPay.fixAmount != nil {
                        isRouterContainsLegacySettings = true
                    } else {
                        isRouterContainsLegacySettings = false
                    }
                } else {
                    isRouterContainsLegacySettings = false
                }
            } else {
                isRouterContainsLegacySettings = false
            }
        }
    }
    
    // good/past_due/manual_block/pre_de_auth/de_auth
    func getPaymentStateForAnalytics() -> PaymentStateForAnalyics {
        var paymentState: PaymentStateForAnalyics = .none
        switch (MyWifiManager.shared.hasBillPay(), self.getDeAuthState(), mandatoryDataAvailable()) {
        case (_, "DE_AUTH_STATE_DEAUTH", _):
            paymentState = .deAuth
        case (false, _, _):
            paymentState = .none
        case (_, _, false):
            paymentState = .none
        default :
            paymentState = determinePaymentState()
        }
        return paymentState
    }
    
    private func determinePaymentState() -> PaymentStateForAnalyics {
        var paymentState: PaymentStateForAnalyics = .none
        /*
         self.initialScreenType()
         switch self.initialScreenFlow {
         case .manualBlock:
         paymentState = .manualBlock
         case .pastDue:
         if self.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
         paymentState = .preDeAuth
         } else {
         paymentState = .pastDue
         }
         case .noDue, .autoPay:
         paymentState = .good
         default: break
         }
         return paymentState
         */
        let totalDue = Double(getCurrentAmount()) ?? 0.0 // If default is 0 = Not Due screen, value > 0 fallback other scenarios
        let isAutoPayEnabled = isAutoPayEnabled()
        let isAccountManualBlocked = isAccountManualBlocked()
        let isPastDueExist = isPastDueExist()
        
        switch (totalDue < 0, totalDue == 0, totalDue > 0, isAutoPayEnabled, isAccountManualBlocked, isPastDueExist) {
        case (_, _, true, _, true,_):
            paymentState = .manualBlock
        case (_, _, _, _, _, true):
            if self.getDeAuthState() == "DE_AUTH_STATE_PREDEAUTH" {
                paymentState = .preDeAuth
            } else {
                paymentState = .pastDue
            }
        default:
            paymentState = .good
        }
        return paymentState
    }
    
    func mandatoryDataAvailable() -> Bool {
        var available = true
        if modelQuickPayGetAccountBill?.billAccount?.name == nil {
            available = false
        }
        return available
    }
    
    /// Calculate the login time and current time to determine the Re-Auth requirement using re_auth_duration_seconds
    /// Difference = current time - login time
    /// Reauthentication required If (Difference >= re_auth_duration_seconds)
    /// - Returns: Re-Auth required or not
    func isReAuthenticationRequired() -> Bool {
        var isRequired = false
        guard let seconds = Double(ConfigService.shared.reAuthDurationSeconds) else {
            return isRequired
        }
        guard let loginDate = PreferenceHandler.getValuesForKey("loginTime") as? Date else {
            return isRequired
        }
        if Date.now.getTimeSecondsBetweenDates(date: loginDate) >= seconds {
            isRequired = true
        }
        return isRequired
    }
    
    // CMAIOS - 1514
    //If list bill API response is empty, AND (nextStatementDate is present in GetBillAccountActivity AND totalAmountDue is null or 0):
    //Show "Your first bill isn't quite ready yet. Check back on [dynamic date: Ex: Month abreviation. DD, YYYY] to view it."
    //If list bill API response is empty, AND (nextStatementDate is null/empty OR totalAmountDue > 0):
    //Show "Your first bill isn't quite ready yet. Check back later to view it."
    func isNoBillHistoryWithNextPayDate() -> Bool {
        var isAvailable = false
        switch (QuickPayManager.shared.isListBillsCompeletd, modelQuickPayListBill?.billSummaryList?.count ?? 0 > 0, Double(getCurrentAmount()) ?? 0 > 0, modelQuickPayGetBillActivity?.billPayActivity?.nextStatementDate?.isEmpty) {
        case (true, false, false, false):
            isAvailable = true
        case (true, false, _, true), (true, false, true, _):
            isAvailable = false
        default: break
        }
        return isAvailable
    }
    
    /// Get Next Statement Date
    func getNextStatementDate() -> String {
        guard let nextDue = modelQuickPayGetBillActivity?.billPayActivity?.nextStatementDate else {
            return ""
        }
        return CommonUtility.convertDateStringFormats(dateString: nextDue, dateFormat: "MMM. d, YYYY")
    }
    
    /// - Returns: (String?, String?) - Get bill name for download and file name used for savind the file
    func getFilename() -> (String?, String?) {
        var fileNames: (String?, String?)
        if let dict = QuickPayManager.shared.modelQuickPayListBill?.billSummaryList?.last,
           let name = dict.name,
           let dueDate = dict.billDueDate {
            let modifiedFielName = "Optimum Bill " + CommonUtility.convertDateStringFormats(dateString: dueDate, dateFormat: "MMM yyyy")
            fileNames = (name, modifiedFielName)
        }
        return fileNames
    }
    
    func isPdfFileAvailable(fileName: String) -> Bool {
        var isFileAvailable = false
        if let pdfPath = self.getPdfFileUrl(fileName: fileName),
           let urlPath = URL(string: pdfPath),
           FileManager.default.fileExists(atPath: urlPath.path)
        {
            isFileAvailable = true
        }
        return isFileAvailable
    }
    
    func getPdfFileUrl(fileName: String?) -> String? {
        var urlStringFormat: String?
        guard let name = fileName else {
            return urlStringFormat
        }
//        guard var pathComponenetName = fileName, let billDate = pathComponenetName.components(separatedBy: "T").first else {
//            return urlStringFormat
//        }
//        pathComponenetName = billDate + ".pdf"
        let pathComponenetName = "PDFList/" + name + ".pdf"
        if let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first as? NSURL {
            if let documentsPath = documentsUrl.appendingPathComponent(pathComponenetName), FileManager.default.fileExists(atPath: documentsPath.path) {
                urlStringFormat = documentsPath.absoluteString
            }
        }
        return urlStringFormat
    }
    
    func removePdfFile() {
        /*
        guard isPdfFileAvailable(fileName: getFilename().1 ?? "") else {
            return
        }
        if let downloadedPDFURL = QuickPayManager.shared.getPdfFileUrl(fileName: QuickPayManager.shared.getFilename().1), let urlPath = URL(string: downloadedPDFURL) {
            do {
                try FileManager.default.removeItem(at: urlPath)
                Logger.info("Downloaded PDF deleted")
            } catch {
                Logger.info("Error deleting downloaded PDF: \(error.localizedDescription)")
            }
        }
        */
        ViewBillManager.shared.removePdfFiles()
    }
    
    func isConsolidateDataAvailable() -> Bool {
        guard self.modelConsolidatedDetail?.billDetails?.billSummaryList == nil,
              self.modelConsolidatedDetail?.billDetails?.payments == nil else {
            return true
        }
        return false
        /*
        guard self.modelConsolidatedDetail?.billDetails?.billSummaryList != nil,
              self.modelConsolidatedDetail?.billDetails?.bill != nil,
              self.modelConsolidatedDetail?.billDetails?.payments != nil else {
            return false
        }
         */
    }
    
    func getViewBillScreenState() -> ViewBillScreenState {
        var viewBillState : ViewBillScreenState = .none
        switch (QuickPayManager.shared.isListBillsCompeletd, QuickPayManager.shared.modelQuickPayListBill?.billSummaryList == nil,
                (QuickPayManager.shared.modelQuickPayListBill?.billSummaryList?.count ?? 0 > 0)) {
        case (false, true, _): //CMAIOS-1502
            viewBillState = .failedBillApi
        case (true, _, false): //CMAIOS-1514
            viewBillState = .noBillHistory
        default:
            viewBillState = .none
        }
        return viewBillState
    }
    
    func dataAvailableToSkipLoader() -> Bool {
        var available = false
        if mandatoryDataAvailable() && !APIRequests.shared.isListPaymentsApiFailed {
            available = true
        }
        return available
    }
    
    func clearModelAfterChatRefresh() {
        self.modelConsolidatedDetail = nil
    }
    
    func getCustomerTenure() -> String {
        guard let tenureDate = modelCustomerTenure?.customer.individual.tenureDate else {
            return ""
        }
        let formatter = ISO8601DateFormatter()
        var tenure = ""
        if let customerTenure = formatter.date(from: tenureDate) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: customerTenure, to: Date())
            if let days = components.day, days > 0 {
                switch days {
                case 0...30:
                    tenure = "0-1 month"
                case 31...90:
                    tenure = "2-3 months"
                case 91...150:
                    tenure = "4-5 months"
                case 151...360:
                    tenure = "6-12 months"
                case 361...720:
                    tenure = "13-24 months"
                case 721...1440:
                    tenure = "25-48 months"
                case 1441...1800:
                    tenure = "48-60 months"
                default:
                    tenure = "61+ months"
                }
            }
        }
        return tenure
    }
    
    func getNickNameOrAccNo(payMethod: PayMethod?) -> String {
        // Get the nickname from the payMethod display info
        let nickname = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod).1
        var nicknameOrAccNo: String = ""
        if !nickname.isEmpty {
            nicknameOrAccNo = nickname
        } else if let maskedBankAccountNumber = payMethod?.bankEftPayMethod?.maskedBankAccountNumber, !maskedBankAccountNumber.isEmpty {
            // If nickname is empty, check the bank account number
            nicknameOrAccNo = String(maskedBankAccountNumber.suffix(4))
        } else if let maskedCreditCardNumber = payMethod?.creditCardPayMethod?.maskedCreditCardNumber, !maskedCreditCardNumber.isEmpty {
            // If both nickname and bank account number are empty, check the credit card number
            nicknameOrAccNo = maskedCreditCardNumber
        }
        return nicknameOrAccNo
    }
    
    func isDiscountPresent() -> Bool {
        var isDiscount = false
        if let accountBill = modelQuickPayGetAccountBill, let billAccount = accountBill.billAccount, let discountEligible = billAccount.discountEligible {
            isDiscount = discountEligible
        }
        return isDiscount
    }
    
    func isDiscountEligible() -> Bool {
        var isDiscountEligible = false
        isDiscountEligible = isDiscountPresent()
        if isDiscountEligible, isAutoPayEnabled(), isPaperLessBillingEnabled() {
            isDiscountEligible = true
        } else {
            isDiscountEligible = false
        }
        return isDiscountEligible
    }
    
    // CMAIOS-2560
    func isUserRecievingDiscount() -> Bool {
        var isDiscountAvaialble = false
        if let hasDiscount = modelQuickPayGetAccountBill?.billAccount?.hasDiscount {
            isDiscountAvaialble = hasDiscount
        }
        return isDiscountAvaialble
    }
    
    func isDiscountBannerEligible() -> Bool {
        if QuickPayManager.shared.isDiscountPresent() && QuickPayManager.shared.isAutoPayEnabled() &&
            QuickPayManager.shared.isPaperLessBillingEnabled() &&
            QuickPayManager.shared.isUserRecievingDiscount() {
            return true
        }
        return false
    }

}
