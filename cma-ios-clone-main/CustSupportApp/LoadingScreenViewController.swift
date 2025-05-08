//
//  LoadingScreenViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 17/06/22.
//

import UIKit
import Lottie
class LoadingScreenViewController: UIViewController {
    @IBOutlet weak var optimumLogo: UIImageView!
    @IBOutlet weak var greetingText: UIImageView!
    @IBOutlet weak var greetingLogo: LottieAnimationView!
    @IBOutlet weak var animationLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var animationTrailing: NSLayoutConstraint!
    let lottieLogoImagView = UIImageView()
    let loadingView = GreetingSalutaionView.instanceFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = midnightBlueRGB
        self.viewAnimationSetUp()
        
        self.loadSalutationView()
    }
    
   private func loadSalutationView() {
       self.view.addSubview(loadingView)
       self.loadingView.isHidden = true
       loadingView.translatesAutoresizingMaskIntoConstraints = false
       loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
       loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
       loadingView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
       loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
       self.view.layoutIfNeeded()
       
       
       let greetingLot = (currentScreenHeight/2 - 30)
       self.lottieLogoImagView.frame = CGRect(x: 52, y: greetingLot, width: currentScreenWidth - 104, height: 60)
       self.lottieLogoImagView.image = UIImage(named: "logo_white")
       self.view.addSubview(lottieLogoImagView)
       self.lottieLogoImagView.isHidden = true

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func viewAnimationSetUp() {
        self.greetingLogo.backgroundColor = .clear
        self.greetingLogo.animation = LottieAnimation.named("AppSplash")
        self.greetingLogo.loopMode = .playOnce
        self.greetingLogo.animationSpeed = 1.0
        self.greetingLogo.play() { [weak self] _ in
            //Taken exact multiplier values for showing translation consistency on every iPhone screen
            self?.lottieLogoImagView.isHidden = false
            self?.greetingLogo.isHidden = true

            UIView.animate(withDuration: 0.7) {
                self?.lottieLogoImagView.frame = self?.loadingView.optimumLogoImageView.frame ?? CGRect.zero
            }
        }
    }
}
