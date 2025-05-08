//
//  UIFont+CustomFontExtension.swift
//  CustSupportApp
//
//  Created by Vishnu on 12/15/23.
//

import UIKit

enum CustomFont: String {
    case regular = "Regular-Regular"
    case medium = "Regular-Medium"
    case semiBold = "Regular-Semibold"
    case bold = "Regular-Bold"
}

extension UIFont {
    static func customFont(_ type: CustomFont, size: CGFloat) -> UIFont {
        UIFont(name: type.rawValue, size: size) ??  UIFont.systemFont(ofSize: size)
    }
}
