//
//  TTTAttributedLabel+extension.swift
//  CustSupportApp
//
//  Created by riyaz on 13/04/23.
//

import Foundation

extension TTTAttributedLabel {
    func changeLinkColor(font: UIFont, color: UIColor = energyBlueRGB) {
        if let textString = self.text {
            let rangeFull = NSString(string: textString as! String).range(of: textString as! String, options: String.CompareOptions.caseInsensitive)
            let attributedString = NSMutableAttributedString(string: textString as! String)
            /// underline
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeFull)
            /// underline  color
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: rangeFull)
            /// underline text color
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: rangeFull)
            /// underline text font
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: rangeFull)
            attributedText = attributedString
        }
    }
    
    func changeLinkColorForLabel(font: UIFont, color: UIColor, range : NSRange, mainLabelRange:NSRange) {
        if let textString = self.text {
            let rangeFull = NSString(string: textString as! String).range(of: textString as! String, options: String.CompareOptions.caseInsensitive)
            let attributedString = NSMutableAttributedString(string: textString as! String)
            /// underline
           attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//            /// underline  color
            attributedString.addAttribute(NSAttributedString.Key.underlineColor, value:UIColor.clear, range: range)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
            /// underline text font
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: rangeFull)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0), range: mainLabelRange)
            attributedText = attributedString
        }
    }
    func setAttributedTextAndLink(firstFont : UIFont, secondFont: UIFont, thirdFont : UIFont, firstRange : NSRange, secondRange:NSRange, thirdRange : NSRange , mainLableRange : NSRange) {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString as! String)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: thirdRange)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: energyBlueRGB, range: thirdRange)
            attributedString.addAttribute(NSAttributedString.Key.font, value: thirdFont, range: thirdRange)
            attributedString.addAttribute(NSAttributedString.Key.font, value: secondFont, range: firstRange)
            attributedString.addAttribute(NSAttributedString.Key.font, value: firstFont, range: secondRange)
            let customFont = UIFont(name: "InLineIcon", size: 18) ?? UIFont.systemFont(ofSize: 18)
            let topMargin: CGFloat = -4.0 // You can adjust this value
            let imageIcon = NSAttributedString(string: "A", attributes: [
                NSAttributedString.Key.font: customFont,
                NSAttributedString.Key.foregroundColor: energyBlueRGB,
                NSAttributedString.Key.baselineOffset: topMargin
            ])
            attributedString.append(imageIcon)
            let fullStop = NSAttributedString(string: ".")
            attributedString.append(fullStop)
            attributedText = attributedString
        }
    }
}

