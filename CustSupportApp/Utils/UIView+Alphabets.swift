//
//  UIView+Alphabets.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 25/10/22.
//

import Foundation

let SHADOW_IMAGE_NAME = "ShadowView"

extension UIView {
    
    func createViewForAlphabets(letter:String, animateFromVC: AnimateFrom = .ProfileDevices, frame: CGPoint) -> UIView {
        let size = animateFromVC == .ProfileDevices ? 70.0 : 90.0
        let frame1 = CGRect(x:frame.x,y:frame.y,width:size, height: size)
        let alphabetView = UIView.init(frame: frame1)
        let imageView = UIImageView.init(frame: CGRect(x:0,y:0,width:size, height: size))
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.init(named: SHADOW_IMAGE_NAME)
        imageView.tag = 1003
        alphabetView.addSubview(imageView)
        let originX = animateFromVC == .ProfileDevices ? 0.0 : 2.0
        let originY = animateFromVC == .ProfileDevices ? 10.0 : 5.0
        let height = animateFromVC == .ProfileDevices ? size - 10 : size
        let label:UILabel = UILabel.init(frame: CGRect(x: originX ,y: originY ,width:size, height: height))
        label.text = letter
        label.tag = 1002
        label.textAlignment = .center
        label.font = UIFont.init(name: "Regular-Regular", size:  animateFromVC == .ProfileDevices ? 45.0 : 67.0)
        label.textColor = energyBlueRGB
        alphabetView.addSubview(label)
        return alphabetView
    }
    
    var parentViewController: UIViewController? {
           var parentResponder: UIResponder? = self
           while parentResponder != nil {
               parentResponder = parentResponder!.next
               if let viewController = parentResponder as? UIViewController {
                   return viewController
               }
           }
           return nil
       }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    func addTopShadow(forView height: CGFloat = 4, topLight: Bool = false) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height : -3.0)
        self.layer.shadowOpacity = topLight ? 0.3 : 0.6
        self.layer.shadowRadius = topLight ? 2 : 10
    }

    // CMAIOS-2157
    func setBorderUIForBankMOP(paymethod: PayMethod? = nil, payACHMethod: Ach? = nil) {
        if paymethod?.bankEftPayMethod != nil || payACHMethod?.bankEftPayMethod != nil {
            self.layer.cornerRadius = 5.0
            self.layer.borderWidth = 2.0
            self.layer.borderColor =  UIColor(red: 240/255, green: 240/255, blue: 243/255, alpha: 1.0).cgColor
        }
    }
    
    // CMAIOS-2100
    func fadeInEffectOnView(view:UIView, pullToRefresh: Bool = false) {
        if !pullToRefresh {
            view.alpha = 0.2
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05, execute: {
                UIView.animate(withDuration: 0.2) {
                    view.isHidden = false
                    view.alpha = 1.0
                }
            })
        }
    }
}
