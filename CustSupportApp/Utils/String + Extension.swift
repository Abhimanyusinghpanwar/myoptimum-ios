//
//  String+Validation.swift
//  CustSupportApp
//
//  Created by raju.ramalingam on 13/12/22.
//

import Foundation

extension String {
    var validateName: Bool {
        let pattern = "^[A-Za-z]*([\\s][A-Za-z]*)*$"
        let result = range(
            of: pattern,
            options: .regularExpression)
        return result != nil && !contains("  ")
    }
    
    var isNumbersOnly: Bool {
        let pattern = "^[0-9]*$"
        let result = range(
            of: pattern,
            options: .regularExpression)
        return result != nil
    }
    
    var isValidExpireDate: Bool {
        let pattern = "^(0[1-9]|1[0-2])[\\/]([0-9]{2})$"
        let result = range(
            of: pattern,
            options: .regularExpression)
        return result != nil
    }
    
    var isValidState: Bool {
        let pattern = "[A-Z][A-Z]?"
        let result = range(
            of: pattern,
            options: .regularExpression)
        return result != nil
    }
    
    var isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let result = range(
            of: pattern,
            options: .regularExpression)
        return result != nil
    }
    
    var lastPathComponent: String {
        return ((self as NSString).lastPathComponent)
    }

}

//Attributted Text Styles
extension String {
    func attributedString(with style: [NSAttributedString.Key: Any]? = nil,
                          and highlightedText: String,
                          with highlightedTextStyle: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString {
        
        let formattedString = NSMutableAttributedString(string: self, attributes: style)
        let highlightedTextRange: NSRange = (self as NSString).range(of: highlightedText as String)
        formattedString.setAttributes(highlightedTextStyle, range: highlightedTextRange)
        return formattedString
    }
    
    func getTrimmedString(isPrefix: Bool, length: Int) -> String {
        if isPrefix {
            return String(self.prefix(length)) // Trim from First
        }
        return String(self.suffix(length)) // Trim from Last
    }
    func getTruncatedString(first : Int = 10, last: Int = 10) -> String {
        let truncatedStringStart = String(self.prefix(first))
        let truncatedStringLast = String(self.suffix(last))
        return "\(truncatedStringStart)...\(truncatedStringLast)"
    }
    
    func replceCharecter(charcter: String) -> String {
        let replaced = self.replacingOccurrences(of: charcter, with: "")
        return replaced
    }
    
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
    
    var removeFormatSpaces: String {
        return self.self.replacingOccurrences(of: " ", with: "")
    }
    
    func addStrikeThrough(color: UIColor) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: self, attributes: [:])
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: 1,
                                     range: NSRange(location: 0,length: attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                             value: color,
                                             range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    //CMAIOS-2058 to handle apostrophe cases when snart punctuation off
    func replaceApostropheFromText() -> String {
       let modifiedText = self.replacingOccurrences(of: "\'", with: "\u{2019}")
       return modifiedText
    }
    
    func trimExtraWhiteLeadingTrailingSpaces()->String {
        let modifiedText = self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        return modifiedText
    }
}

extension String {
    func getDateFromDateString() -> Date {
        let date = CommonUtility.responseFormatter.date(from: self) ?? Date()
        return date
    }
    
    func getDateFromDateStringFormat1() -> Date {
        let date = CommonUtility.responseFormatterOne.date(from: self) ?? Date()
        return date
    }
    
    func getDateFromDateStringFormat2() -> Date {
        let cancelledDate = self.components(separatedBy: "T")
        let neutralDate = cancelledDate[0] + "T00:00:00Z"
        let date = CommonUtility.responseFormatterOne.date(from: neutralDate) ?? Date()
        return date
    }
    
    func filterFormat() -> Date {
        let date = CommonUtility.filterFormat.date(from: self) ?? Date()
        return date
    }
}

//CMAIOS-2225 get ascii value from string
extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}

//CMAIOS-2225 Validation for the input text
extension String{
    
    //CMAIOS-2225 check if the entered string is valid ASCII
    private func checkIfCharIsASCIIOrNot() -> Bool {
        if let isAscii = self.first?.isASCII, !isAscii{
            return false
        }
        return true
    }
    
    //CMAIOS-2225 get ASCII value of string
   private  func getASCIIValueOfString() -> UInt8{
        let asciiValue = self.asciiValues
        return asciiValue[0]
    }
    
    //CMAIOS-2225 check ASCII value is in between 32 and 126
    private func isASCIICharValid(ASCIIValue: UInt8)-> Bool{
        switch ASCIIValue {
        case 32...126:
            return true
        default:
            return false
        }
    }
    
    //CMAIOS-2225 check if string contains any smiley or any other icons
    private func isContainsEmoji() -> Bool{
        //CMAIOS-2241 Added one more condition to not treat (*, #) as Emoji and allow user to enter these to SSID pwd text field
        let isContainEmoji = self.unicodeScalars.filter({ $0.properties.isEmoji && $0.properties.isEmojiPresentation}).count > 0
        let numberCharacters = self.rangeOfCharacter(from: .decimalDigits)
        if (isContainEmoji && numberCharacters == nil) {
            return true
        }
        return false
    }
    
    //CMAIOS-2225 check if the string is falls in restricted char set
    private func isValidChar(restrictedChars: String)->Bool {
        let restrictedCharSet = CharacterSet(charactersIn: restrictedChars)
        if self.rangeOfCharacter(from: restrictedCharSet) !=  nil {
            return false
        }
        return true
    }
    
   //CMAIOS-2224 Combined all validation rules for SSID +  PWD input text
    private func validateAllInputRules(invalidChars: String)-> Bool{
        //CMAIOS-2224 check if entered string is valid ASCII char
        if self.checkIfCharIsASCIIOrNot() {
            //get ASCII value of character
            let asciiValue = self.getASCIIValueOfString()
            //check ASCII character falls in 32...126
            let isValidAsciiValue = self.isASCIICharValid(ASCIIValue: asciiValue)
            //check if the entered string contains any EMOJIs
            let isContainsEmoji = self.isContainsEmoji()
            //check if the entered string is from restricted set
            let isValidChar  = self.isValidChar(restrictedChars: invalidChars )
            if !isValidAsciiValue || isContainsEmoji || !isValidChar {
                return false
            }
            return true
        }
        return false
    }
    
    //CMAIOS-2224 Validate both SSID + Password Input Text
    func validateSSIDPasswordInputText(invalidChars: String) ->Bool{
        let isValidInput = self.validateAllInputRules(invalidChars: invalidChars)
        return isValidInput
    }
}
