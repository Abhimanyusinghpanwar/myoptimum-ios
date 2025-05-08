//
//  UIDate+Extension.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 10/02/23.
//

import Foundation

extension Date {
    
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970)
    }
    func getDateStringForAPIParam() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: self)
    }
    
    // CMAIOS-2185
    func getDateStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. d, YYYY"
        var dateStirngVal = dateFormatter.string(from: self)
        let modifyString = dateStirngVal
        if modifyString.uppercased().contains("MAY") {
            dateStirngVal = modifyString.replacingOccurrences(of: ".", with: "")
        }
        return dateStirngVal
    }
    
    func getLateFeeDateStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, d."
        return dateFormatter.string(from: self)
    }
    
    func getDateStringForDueDate() -> String {
        let dateFormatter = DateFormatter()
        //CMAIOS-2397 use short abbreviation for year in DateFormatter
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: self)
    }
    
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        return startDate <= self && self < endDate
    }
    func isMoreThanOneHour() -> Bool {
        return self > Date(timeIntervalSinceNow: 3600)
    }
    
    func weekday(using calendar: Calendar = .current) -> Int {
        calendar.component(.weekday, from: self)
    }
    
    func getDays(toDate date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
    
    func roundOffDate() -> Date?
    {
        var calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.minute = 0
        components.second = 0
        components.hour = 0
        return calendar.date(from: components)
    }
    
    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
    
    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }
    
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
    
    func getModifiedCurrentDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date11 = dateFormatter.string(from: self)
        let date11Formated = dateFormatter.date(from: date11)
        guard let roundOffDate = date11Formated?.roundOffDate() else { return Date() }
        return roundOffDate
    }
    
    func getDateForErrorLog() -> String {
        let dateFormatter = DateFormatter()
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.locale = en_US_POSIX
        return dateFormatter.string(from: self)
    }
    
    func getDateCurrentDateHmac() -> String {
        let dateFormatter = DateFormatter()
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = en_US_POSIX
        return dateFormatter.string(from: self)
    }
    
    func getTimeSecondsBetweenDates(date: Date) -> Double {
        return self.timeIntervalSince(date)
    }
    
    func isSameYearAndMonth(date2: Date) -> Bool {
        let calendar = Calendar.current
        let date1Components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        let date2Components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date2)
        let isSameYear = date1Components.year == date2Components.year
        let isSameMonth = date1Components.month == date2Components.month
        return isSameYear && isSameMonth
    }
    
    // CMAIOS-2094
    func isSameYearAndMonthFormat1(date2: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let date1Components = calendar.dateComponents([.year, .month], from: self)
        let date2Components = calendar.dateComponents([.year, .month], from: date2)
        let isSameYear = date1Components.year == date2Components.year
        let isSameMonth = date1Components.month == date2Components.month
        return isSameYear && isSameMonth
    }
    
    func isSameYearMonthAndDate(date2: Date) -> Bool {
        let calendar = Calendar.current
        let date1Components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        let date2Components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date2)
        let isSameYear = date1Components.year == date2Components.year
        let isSameMonth = date1Components.month == date2Components.month
        let isSameDay = date1Components.day == date2Components.day
        return isSameYear && isSameMonth && isSameDay
    }
    
    func checkIfDateIsSelectedAfterDueDate(selectedDueDate: Date, checkIsSameRequired: Bool = true) -> Bool {
        let calendar = Calendar.current
        let date1Components = calendar.dateComponents([.year, .month, .day], from: self)
        let date2Components = calendar.dateComponents([.year, .month, .day], from: selectedDueDate)
        
        let lhsDate = calendar.date(from: date1Components)
        let rhsDate = calendar.date(from: date2Components) ?? Date()
        let isOrderedAscending = lhsDate?.compare(rhsDate) == .orderedAscending
        let isOrderedSame = lhsDate?.compare(rhsDate) == .orderedSame
        let comparisonResult = checkIsSameRequired ? isOrderedAscending || isOrderedSame : isOrderedAscending
        return comparisonResult
    }
    
    func checkIfDateIsSelectedBefore48Hours(selectedDueDate: Date) -> Bool {
        /*
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.hour], from: selectedDueDate, to: self).hour ?? 0
        return difference >= 0 && difference < 48
        */
        let calendar = Calendar.current
        let currentDate = Date() // Get the current date
        let difference = calendar.dateComponents([.day], from: selectedDueDate, to: self).day ?? 0
        return difference >= 0 && difference <= 2 // Check if the difference is within 2 days
    }
    
    func checkIfDateIsSelectedAfter48Hours(selectedDueDate: Date) -> Bool {
        /*
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.hour], from: self, to: selectedDueDate).hour ?? 0
        return difference >= 48
        */
        let calendar = Calendar.current
        let currentDate = Date()
        guard let dueDatePlusTwoDays = calendar.date(byAdding: .day, value: 2, to: self) else {
            return false
        }
        return selectedDueDate > dueDatePlusTwoDays
    }
    
    func getDateAfterSixMonthsFromCurrentDate()-> Date {
        let calendar = Calendar.current
        if let dateAfterSixMonths = calendar.date(byAdding: .month, value: 6, to: self) {
            return dateAfterSixMonths
        }
        return Date()
    }
    
    // CMAIOS-2034
    func getDatebefore30Days()-> Date {
        let calendar = Calendar.current
        if let dateAfter30Days = calendar.date(byAdding: .day, value: -31, to: self) {
            return dateAfter30Days
        }
        return Date()
    }

    func checkIfPaymentDateIsSelectedAfterCardExpirationDate(cardExpirationDate:Date?) -> Bool{
        guard let expiredDate = cardExpirationDate else{
            return false
        }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let date1Components = calendar.dateComponents([.year, .month, .day], from: self)
        let date2Components = calendar.dateComponents([.year, .month, .day], from: expiredDate)
        let lhsDate = calendar.date(from: date1Components)
        let rhsDate = calendar.date(from: date2Components) ?? Date()
        return lhsDate?.compare(rhsDate) == .orderedDescending
    }
}
