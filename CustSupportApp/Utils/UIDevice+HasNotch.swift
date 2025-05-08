//
//  UIDevice+HasNotch.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 08/09/22.
//

import Foundation

extension UIDevice {
    //To handle UI of Devices having notch but height == 375 
    var hasNotch: Bool {
        if let instance = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first) {
            let bottom = instance.safeAreaInsets.bottom
            return bottom > 0
        }
        return false
    }
    
    var topInset: CGFloat {
        if let instance = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first) {
            let top = instance.safeAreaInsets.top
            return top
        }
        return 0
    }
}
