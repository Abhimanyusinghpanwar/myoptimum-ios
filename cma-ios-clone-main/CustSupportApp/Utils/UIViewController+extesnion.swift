//
//  UIViewController+extesnion.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/12/22.
//

import Combine
import UIKit
extension UIViewController {
    /// Instantiate a ViewController from Storyboard
    /// - parameter storyboard: Storyboard containing the ViewController
    /// - parameter identifier: Identifier of ViewController or `nil` for InitialViewController
    static func instantiate(from storyboard: Storyboard = .profile, identifier: String? = nil) -> Self? {
        return storyboard.instanceOf(viewController: self, identifier: identifier)
    }
    
    static func instantiateWithIdentifier(from storyboard: Storyboard) -> Self? {
        return storyboard.instanceOf(viewController: self, identifier: identifier)
    }
    
    static var identifier: String {
        String(describing: self)
    }

    func checkQualtrics(screenName: String, dispatchBlock: inout DispatchWorkItem?) -> DispatchWorkItem? {
        if QualtricsManager.shared.qualtricsPromptDisabled == true {
            return nil
        }
        let qualtricsWorkItem = DispatchWorkItem(block: {
            if QualtricsManager.shared.qualtricsPromptDisabled == false {
                QualtricsManager.shared.invokeQualtrics(screen: screenName)
            }
        })
        dispatchBlock = qualtricsWorkItem
        if QualtricsManager.shared.eligibilityCheckDone == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: dispatchBlock ?? qualtricsWorkItem)
        }
        return dispatchBlock ?? qualtricsWorkItem
    }
    
    func checkQualtricsOnLaunchOfHomeScreen(screenName: String, dispatchBlock: inout DispatchWorkItem?) -> DispatchWorkItem? {
        if QualtricsManager.shared.qualtricsPromptDisabled == true {
            return nil
        }
        let qualtricsWorkItem = DispatchWorkItem(block: {
            if QualtricsManager.shared.qualtricsPromptDisabled == false {
                QualtricsManager.shared.invokeQualtrics(screen: screenName)
            }
        })
        dispatchBlock = qualtricsWorkItem
        if QualtricsManager.shared.eligibilityCheckDone == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: dispatchBlock ?? qualtricsWorkItem)
        } else { // wait for 10 seconds on homescreen since it is the first screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: dispatchBlock ?? qualtricsWorkItem)
        }
        return dispatchBlock ?? qualtricsWorkItem
    }
}

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
    func pushViewControllerWithLeftToRightAnimation(_ viewController: UIViewController, from sourceViewController: UIViewController) {
        CATransaction.begin()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        
        sourceViewController.navigationController?.view.layer.add(transition, forKey: kCATransition)
        sourceViewController.navigationController?.pushViewController(viewController, animated: false)
        
        CATransaction.commit()
    }
    
    func embedNavControllerAndPresent(viewController: UIViewController, withAnimation:Bool = true)
      {
         let navVC = self.embedNavigationControllerToExistingVC(instanceVC: viewController)
          self.present(navVC, animated: true, completion: nil)
      }
      
      func embedNavigationControllerToExistingVC(instanceVC : UIViewController) -> UINavigationController {
          let navVC = UINavigationController(rootViewController: instanceVC)
          navVC.modalPresentationStyle = .fullScreen
          navVC.setNavigationBarHidden(true, animated: false)
          return navVC
      }
    
    var previousViewController: UIViewController? {
          guard let navigationController = navigationController else { return nil }
          let count = navigationController.viewControllers.count
          return count < 2 ? nil : navigationController.viewControllers[count - 2]
    }
}
