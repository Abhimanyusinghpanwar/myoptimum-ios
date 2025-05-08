//
//  GreetingSalutaionView.swift
//  CustSupportApp
//
//  Created by Namarta on 08/07/22.
//

import UIKit
import Lottie
protocol LoginViewDelegate {
    func salutationAnimationDidCompleted()
}

class GreetingSalutaionView: UIView {
    @IBOutlet weak var salutationLabel: UILabel!
    @IBOutlet weak var salutationLblWidth: NSLayoutConstraint!
    @IBOutlet weak var animationVerticalSpacing: NSLayoutConstraint!
    @IBOutlet weak var salutationAnimation: LottieAnimationView!
    var loginDelegate: LoginViewDelegate!
    var animationCompleted = false
    
    @IBOutlet weak var optimumLogoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : AuthenticationScreenDetails.GREETING_SCREEN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    class func instanceFromNib() -> GreetingSalutaionView {
        let view = (UINib(nibName: "GreetingSalutaionView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? GreetingSalutaionView)!
        return view
    }
    
    func showSalutationAnimation() {
        UIView.animate(withDuration: 1.0) {
            self.salutationLabel.isHidden = false
            self.salutationAnimation.isHidden = false
            self.salutationLabel.alpha = 1.0
            self.salutationAnimation.alpha = 1.0
            self.loadTextAndPlayLottie()
        }
    }
    
    private func loadTextAndPlayLottie() {
        let currentTime = App.checkCurrentTimeForSalutation()
        let fileName = currentTime.getLottieName()
        salutationLabel.text = currentTime.getGreetingText()
        salutationAnimation.animation = LottieAnimation.named(fileName)
        salutationAnimation.loopMode = .loop
        salutationAnimation.play { _ in
            self.loginDelegate.salutationAnimationDidCompleted()
            self.animationCompleted = true
        }
    }

}
