//
//  UINavigationController+extension.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 24/11/22.
//

import Foundation

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }

    func removeViewControllerIfExists(ofClass: AnyClass) {
        if let vc = viewControllers.first(where: { $0.isKind(of: ofClass)}), let index = viewControllers.firstIndex(of: vc) {
            viewControllers.remove(at: index)
      }
    }
    
    func checkIfViewControllerExists(ofClass: AnyClass) -> Bool {
        if let vc = viewControllers.first(where: { $0.isKind(of: ofClass)}), let index = viewControllers.firstIndex(of: vc) {
           return true
        } else {
            return false
        }
    }
    
}
