//
//  UIApplication+extension.swift
//  CustSupportApp
//
//  Created by vsamikeri on 12/21/22.
//

import Foundation

extension UIApplication {
//'windows' was deprecated in iOS 15.0: updated changes,
    class func topViewController(
        _ baseViewController: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
    ) -> UIViewController? {
        if let navController = baseViewController as? UINavigationController {
            return topViewController(navController.visibleViewController)
        }
        if let tabController = baseViewController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presentedController = baseViewController?.presentedViewController {
            return topViewController(presentedController)
        }
        return baseViewController
    }
}
