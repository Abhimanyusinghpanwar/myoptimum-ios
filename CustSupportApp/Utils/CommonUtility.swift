//
//  CommonUtility.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 20/12/22.
//

import Foundation

class CommonUtility {
    static let responseFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    
    static let responseFormatterOne: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()
    
    static let expirationResponse: ISO8601DateFormatter = ISO8601DateFormatter()
    
    static let utcFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = UtilityConstants.utcFormat
        return dateFormatter
    }()
    
    static let utcFormatterWithOutTimeZone: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    static let expireDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
    
    public static func isAppAuthTokenExpired() -> Bool {
        var tokenExpired = false
//        let expiry = 1671749312000
        guard let loginData = PreferenceHandler.getValuesForKey("loginAuthenticationData") as? [String : AnyObject],
              let accessToken = loginData["access_token"] as? String, !accessToken.isEmpty else {
            return tokenExpired
        }
        guard let expires_in = loginData["expires_in"] as? Int64 else { return tokenExpired }
        //if expirationDate > Now
        if Date(timeIntervalSince1970: Double(expires_in)) < Date() {
            tokenExpired = true
        }
        return tokenExpired
    }
    
    public static func dateFromTimestamp(dateString: String) -> Date {
        guard let actualDateFormat = utcFormatter.date(from: dateString) else {
            return Date()
        }
        return actualDateFormat
    }
    
    public static func dateFromTimestampWOTimeZone(dateString: String) -> Date {
        guard let actualDateFormat = utcFormatterWithOutTimeZone.date(from: dateString) else {
            return Date()
        }
        return actualDateFormat
    }
    
    public static func getCurrentDateString() -> String {
        let dateString = utcFormatter.string(from: Date())
        return dateString
    }
    
    public static func convertExpireDateStringToResponseFormat(dateString: String) -> String? {
        guard let date = expireDateFormatter.date(from: dateString) else { return nil }
        return expirationResponse.string(from: date)
    }
    
    public static func convertDateStringFormats(dateString: String, dateFormat: String) -> String {
        guard let actualDateFormat = utcFormatter.date(from: dateString) else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = dateFormat // required Format
//        let dateString = dateFormatter.string(from: actualDateFormat)
        var dateString = dateFormatter.string(from: actualDateFormat)
        if dateFormat == "MMM. d, YYYY" || dateFormat == "MMM. d" || dateFormat == "MMM. d, yyyy" { // CMAIOS-1211, CMAIOS-1963
            let modifyString = dateString
            if modifyString.uppercased().contains("MAY") {
                dateString = dateString.replacingOccurrences(of: ".", with: "")
            }
        }
        return dateString
    }
    
    public static func convertDateStringFormatToPlainStyle(dateString: String, dateFormat: String) -> String {
        guard let actualDateFormat = utcFormatterWithOutTimeZone.date(from: dateString) else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat // required Format
//        let dateString = dateFormatter.string(from: actualDateFormat)
        var dateString = dateFormatter.string(from: actualDateFormat)
        //CMAIOS-2397 use short abbreviation for year in DateFormatter
        if dateFormat == "MMM. d, yyyy" { // CMAIOS-1211
            let modifyString = dateString
            if modifyString.uppercased().contains("MAY") {
                dateString = dateString.replacingOccurrences(of: ".", with: "")
            }
        }
        return dateString
    }
    
    public static func convertToDesiredDateFormat(dateString: String?, dateFormat: String) -> Date {
        guard let dateStr = dateString,
              let actualDateFormat = utcFormatter.date(from: dateStr) else {
            return Date.now
        }
        var dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = dateFormat // required Format
//        let dateString = dateFormatter.string(from: actualDateFormat)
        var dateString = dateFormatter.string(from: actualDateFormat)
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: dateString)
        return date ?? Date()
    }
    
    
    public static func dateStringToTimeStamp(dateString: String, dateFormat: String) -> String {
        guard let date = expireDateFormatter.date(from: dateString), let enteredDate = Calendar.current.date(byAdding: .month, value: 0, to: date) else { return "" }
        let dateString = utcFormatter.string(from: enteredDate)
        return dateString
    }
    
    public static func getDateFromDueDateString(dueDateString: String, dateFormat: String) -> Date {
        let date = utcFormatter.date(from: dueDateString) ?? Date()
        return date
    }
    
    public static func getDateFromDateStringWOTimeZone(dueDateString: String, dateFormat: String) -> Date {
        let date = utcFormatterWithOutTimeZone.date(from: dueDateString) ?? Date()
        return date
    }
    
    public static func getDateStringDate(date: Date?) -> String? {
        let date = utcFormatter.string(from: date ?? Date())
        return date
    }
    
    public static func getDateFromStringDate(dateString: String?) -> Date? {
        guard let stringDate = dateString else { return Date()}
        let date = utcFormatter.date(from: stringDate)
        return date
    }
    
    public static func getDateStringDate(date: Date?, dateFormat: String) -> String? {
        var dateString: String?
        guard let dateformat = date else {
            return dateString
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = dateFormat // required Format
        dateString = dateFormatter.string(from: dateformat)
        return dateString
    }
    
    // CMAIOS-2140 & 2141
    public static func getOnlyMonthYearDate(paymentDate: String) -> Date {
        let formattedScheduleDate = paymentDate.components(separatedBy: "T")
        let calenderSelectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedScheduleDate[0])
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        let newFormart = formatter.string(from: calenderSelectedDate)
        
        let finalFormat = CommonUtility.convertExpireDateStringToResponseFormat(dateString: newFormart)
        let formattedfinalDate = finalFormat?.components(separatedBy: "T")
        let requiredDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedfinalDate?[0] ?? "")
        return requiredDate
    }
    
    // Added here for reference.
    // let initial = 200
    //    430 + - 60
    // 580  + - 60
    
    // Saved
    // 245
    // 300
    
    public static func getHeightForCellModel(model: PauseScheduleModel) -> CGFloat {
        var height = 200
        if model.isInitial {
            // For Cancel also
            height = 200
        } else if model.weekEndModel.isTimerSaved && model.isWeekendsEnabled && !model.isTimer {
            height = 300
        } else if model.timerModel.isTimerSaved && !model.isWeekendsEnabled && !model.isTimer {
            height = 245
        } else if model.isTimer && !model.pauseTimeDates.displayErrorView && !model.pauseTimeDates.overlapErrorView && !model.isWeekendsEnabled {
            height = 430
        } else if model.isTimer && (model.pauseTimeDates.displayErrorView || model.pauseTimeDates.overlapErrorView) && !model.isWeekendsEnabled {
            height = 490
        }
        else if model.isTimer && model.isWeekendsEnabled && !model.pauseTimeDates.displayWErrorView && !model.pauseTimeDates.displayErrorView {
            height = 560
        } else if (model.isTimer && model.isWeekendsEnabled && !model.pauseTimeDates.displayWErrorView && model.pauseTimeDates.displayErrorView) {
            height = 620
        } else if (model.isTimer && model.isWeekendsEnabled) && model.pauseTimeDates.displayWErrorView && !model.pauseTimeDates.displayErrorView {
            height = 620
        } else if model.isTimer && model.isWeekendsEnabled && model.pauseTimeDates.displayErrorView && model.pauseTimeDates.displayWErrorView {
            height = 680
        }
        return CGFloat(height)
    }
    public static func getDateFromResponseValue(strDate: String?) -> Date {
        guard let dateString = strDate, !dateString.isEmpty else {
            return Date()
        }
        return responseFormatter.date(from: dateString) ?? Date()
    }
    
    // Encode the json string to get required [String: AnyObject] json parameter
    public static func getEncodedJsonParam(jsonData: Data) -> [String: AnyObject] {
        var jsonParams = [String: AnyObject]()
        let jsonString = String(data: jsonData, encoding: .utf8)!
        Logger.info("jsonString\(jsonString)", sendLog: "Encoded Json Param")
        if let data = jsonString.data(using: .utf8) {
            do {
                jsonParams = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] ?? [:]
            } catch {
                Logger.info("\(String(describing: error.localizedDescription))")
            }
        }
        return jsonParams
    }
    
    public static func deviceHasPhoneCallFeature(phoneNumber: String) -> Bool {
        var isAvailable = false
        guard let phoneNumber = URL(string: UtilityConstants.telePhoneURL + phoneNumber) else { return isAvailable }
        if UIApplication.shared.canOpenURL(phoneNumber) {
            isAvailable = true
        }
        return isAvailable
    }
    
    public static func doPhoneCall(phoneNumber: String) {
        guard let phoneNumber = URL(string: UtilityConstants.telePhoneURL + phoneNumber) else { return }
        if UIApplication.shared.canOpenURL(phoneNumber) {
            UIApplication.shared.open(phoneNumber)
        }
    }
    
    public static func openWebPageInNativeBrowser(webPageUrl: String) {
        guard let pageUrl = URL(string: webPageUrl) else { return }
        if UIApplication.shared.canOpenURL(pageUrl) {
            UIApplication.shared.open(pageUrl)
        }
    }
    
    public static func validateOverflowingText(labelText: NSString) -> String {
        if labelText.length > 20 {
            let range1 = NSMakeRange(0, 9)
            let text1 = NSMutableString(string: labelText.substring(with: range1))
            let lastCharsLength = labelText.length - 8
            let range2 = NSMakeRange(lastCharsLength, 8)
            let text2 = NSMutableString(string: labelText.substring(with: range2))
            return String(text1) + "..." + String(text2)
        }
        return String(labelText)
    }
    
    public static func jsonToString(json: AnyObject?) -> String {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json as Any)
            if let convertedString = String(data: data1, encoding: .utf8) {
                return convertedString
            }// the data will be converted to the string
        } catch _ {
            return ""
        }
        return ""
    }
    
    static let filterFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter
    }()
    
    public static func isValidPdf(pdfUrl: URL) -> Bool {
        var isPDF: Bool = false
        let fileManager = FileManager()
        //        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //        let rootDirectory = "\(documentsPath)/\(caption!)/"
        //        let imageURL = URL(fileURLWithPath: rootDirectory).appendingPathComponent("0")
        let pdfData = NSData(contentsOf: pdfUrl)
        if fileManager.fileExists(atPath: pdfUrl.path) {
            return isPDF
        }
        if (pdfData?.length)! >= 1024 //only check if bigger
        {
            var pdfBytes = [UInt8]()
            pdfBytes = [ 0x25, 0x50, 0x44, 0x46]
            let pdfHeader = NSData(bytes: pdfBytes, length: 4)
            let range = pdfData?.range(of: pdfHeader as Data, options: .anchored, in: NSMakeRange(0, 1024))
            if (range?.length)! > 0
            {
                isPDF = true
            }
            else
            {
                isPDF = false
            }
        }
        return isPDF
    }
    
    public static func decodeJWT(token:String?) -> [String: Any]? {
        if let jwt = token, !jwt.isEmpty {
            let parts = jwt.components(separatedBy: ".")

            if parts.count != 3 {
               // fatalError("jwt is not valid!")
                Logger.info("jwt is not valid!")
                return nil
            }

          //  let header = parts[0]
            let payload = parts[1]
          //  let signature = parts[2]
            let json = decodeJWTPart(payload: payload)
           // print(json ?? "could not converted to json!")
            return json
        }
        return nil
    }
    
    public static func decodeJWTPart(payload: String) -> [String: Any]? {
        let payloadPaddingString = base64StringWithPadding(encodedString: payload)
        guard let payloadData = Data(base64Encoded: payloadPaddingString) else {
           // fatalError("payload could not converted to data")
            Logger.info("payload could not converted to data")
            return nil
        }
            return try? JSONSerialization.jsonObject(
            with: payloadData,
            options: []) as? [String: Any]
    }
    public static func base64StringWithPadding(encodedString: String) -> String {
        var stringTobeEncoded = encodedString.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingCount = encodedString.count % 4
        for _ in 0..<paddingCount {
            stringTobeEncoded += "="
        }
        return stringTobeEncoded
    }
    
    public static func setHighlightString(labelText: String, highlightString: String) -> NSMutableAttributedString {
        let attributedLabelText = NSMutableAttributedString(string: labelText)
        let labelRange = (labelText as NSString).range(of: highlightString)
        attributedLabelText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Regular-Bold", size: 18) as Any, range: labelRange)
        return attributedLabelText
    }
    
    public static func convertDateToSpecifiedUTCStringFormat(_ date : Date) -> String
    {
        UtilityConstants.dateFormatter.dateFormat = UtilityConstants.utcTimeFormat
        UtilityConstants.dateFormatter.timeZone = UtilityConstants.timeZone
        UtilityConstants.dateFormatter.locale = UtilityConstants.en_US_POSIX
        return UtilityConstants.dateFormatter.string(from: date)
    }
    
    /// Gives the current UTC time in String "Type"
    ///
    /// - returns: Returns a String of UTCDate
    public static func getCurrentDateTimeInUTCFormat() -> String
    {
        UtilityConstants.dateFormatter.dateFormat = UtilityConstants.utcTimeFormat
        UtilityConstants.dateFormatter.timeZone = UtilityConstants.timeZone
        UtilityConstants.dateFormatter.locale = UtilityConstants.en_US_POSIX
        return UtilityConstants.dateFormatter.string(from: Date())
    }
    
    public static func getCurrentDateTImeUTCFormatAsDateType() -> Date
    {
        return UtilityConstants.dateFormatter.date(from: getCurrentDateTimeInUTCFormat())!
    }
    
    public static func convertStringToSpecifiedUTCDateFormat(_ date : String) -> Date
    {
        let utcTimeFormat = "yyyyMMdd'T'HHmmss'Z'"
        let timeZone = TimeZone(identifier: "UTC")
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = utcTimeFormat
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = en_US_POSIX
        
        return dateFormatter.date(from: date)!
    }
    
    public static func checkRemainingTime() -> Int {
        guard let restorationWindow =  Int(ConfigService.shared.service_restoration_window) else {
            return 0
        }
        if let dateString = PreferenceHandler.getValuesForKey("DEAUTH_PAYMENT_MADE_TIMESTAMP") as? String, let interval = NSInteger(CommonUtility.getCurrentDateTImeUTCFormatAsDateType().timeIntervalSince((CommonUtility.convertStringToSpecifiedUTCDateFormat(dateString)))) as Int? {
            return restorationWindow - interval
        }
        return 0
    }
}

struct UtilityConstants {
    static let utcFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    static let telePhoneURL = "tel://"
    static let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
    static let utcTimeFormat = "yyyyMMdd'T'HHmmss'Z'"
    static let timeZone = TimeZone(identifier: "UTC")
    static let dateFormatter = DateFormatter()
}

extension UIView {
    func viewBorderAttributes(_ color: CGColor, _ width: CGFloat, _ radius: CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
        self.layer.cornerRadius = radius
    }
    /*
    func addBorder(toEdges edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
        func addBorder(toEdge edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
            let border = CALayer()
            border.backgroundColor = color.cgColor
            
            switch edges {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            default:
                break
            }
            
            layer.addSublayer(border)
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(toEdge: .top, color: color, thickness: thickness)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(toEdge: .bottom, color: color, thickness: thickness)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(toEdge: .left, color: color, thickness: thickness)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(toEdge: .right, color: color, thickness: thickness)
        }
    }
     */
}

extension UInt {
    var toInt: Int { return Int(self) }
}
