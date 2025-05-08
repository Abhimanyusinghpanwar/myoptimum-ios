//
//  UITapGesture.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/24/22.
//

import UIKit

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, targetText: String) -> Bool {
        guard let attributedString = label.attributedText, let lblText = label.text else { return false }
        let targetRange = (lblText as NSString).range(of: targetText)
        //IMPORTANT label correct font for NSTextStorage needed
        let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttribString.addAttributes(
            [.font: label.font ?? UIFont.smallSystemFontSize],
            range: NSRange(location: 0, length: attributedString.length)
        )
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: mutableAttribString)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: (locationOfTouchInLabel.x - textContainerOffset.x),
                                                     y: 0 );
        // Adjust for multiple lines of text
        let lineModifier = Int(ceil(locationOfTouchInLabel.y / label.font.lineHeight)) - 1
        let rightMostFirstLinePoint = CGPoint(x: labelSize.width, y: 0)
        let charsPerLine = layoutManager.characterIndex(for: rightMostFirstLinePoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let adjustedRange = indexOfCharacter + (lineModifier * charsPerLine)
        
        return NSLocationInRange(adjustedRange, targetRange)
    }
    
    func didTapTermsAndConditions(label: UILabel, targetText: String) -> Bool {
        guard let _ = label.attributedText, let lblText = label.text else {
            return false
        }
        let range = (lblText as NSString).range(of: targetText)
        let tapLocation = self.location(in: label)
        let index = label.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        if index > range.location && index < range.location + range.length {
            return true
        }
        return false
    }
    
}
extension UILabel {
        ///Find the index of character (in the attributedText) at point
        func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
            assert(self.attributedText != nil, "This method is developed for attributed string")
            let textStorage = NSTextStorage(attributedString: self.attributedText!)
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer(size: self.frame.size)
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = self.numberOfLines
            textContainer.lineBreakMode = self.lineBreakMode
            layoutManager.addTextContainer(textContainer)

            let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            return index
        }
    }
