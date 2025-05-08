//
//  QuickPayPresentationController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 12/7/22.
//

import Shift
import UIKit


class QuickPayTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return MyWifiPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Updating corner especifically for MyWiFiViewController
        if dismissed is MyWiFiViewController {
            dismissed.view.layer.cornerRadius = 80
        }
        return ModalTransitionDismissing()
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionPresenting()
    }
}

class QuickPayPresentationController: UIPresentationController {
    let width = CGFloat(275)
    let height = CGFloat(263)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            x: 0,
            y: 0,
            width: containerView.frame.width,//width,
            height: containerView.frame.height
        )
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: width, height: height)
    }
}
