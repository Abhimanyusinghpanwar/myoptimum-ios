//
//  UIViewController+extension.swift
//  CustSupportApp
//
//  Created by vishali Test on 22/06/23.
//

import Foundation

extension NSObject {

    static var classNameFromType: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }

    var classNameFromInstance: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? ""
    }
}
