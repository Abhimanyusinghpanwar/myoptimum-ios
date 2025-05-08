//
//  XtendCheckLightsVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 9/30/22.
//  GA-extender5_check_lights_on_extender/extender6_check_lights_on_extender

import UIKit
import Lottie

class XtendCheckLightsVC: BaseViewController {
    
    @IBOutlet weak var checkLightsAnimation: LottieAnimationView!
    @IBOutlet weak var checkLightsPrimaryLbl: UILabel!
    @IBOutlet weak var checkLightsPrimaryBtn: RoundedButton!
    @IBOutlet weak var checkLightsSecondaryBtn: RoundedButton!
    @IBOutlet weak var xtendCheckLightsStacViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendCheckLightsStacViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var xtendCheckLightsSecBtnBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateCheckLightsUI()
        trackAnalyticsSIScreens()
    }
    func updateCheckLightsUI() {
        
        let extender = ExtenderDataManager.shared.extenderType
        if (CurrentDevice.isLargeScreenDevice() && !ExtenderDataManager.shared.isExtenderTroubleshootFlow) {
            checkLightsPrimaryLbl.font = UIFont(name: "Regular-Bold", size: 24)
            xtendCheckLightsStacViewLeadingConstraint.constant = 30.0
            xtendCheckLightsStacViewTrailingConstraint.constant = 30.0
            checkLightsPrimaryLbl.setLineHeight(1.21)
        } else {
            checkLightsPrimaryLbl.setLineHeight(1.15)
        }
        switch extender {
        case 5:
            self.checkLightsPrimaryLbl.text = ExtenderDataManager.shared.isExtenderTroubleshootFlow ? "Do you see the top two lights blinking green?" : "Wait a couple of minutes until the top two lights blink green on the front of Extender"
            self.checkLightsPrimaryBtn.setTitle("I see the lights blinking green", for: .normal)
            self.checkLightsSecondaryBtn.setTitle("I see something else", for: .normal)
            playSingleAnimation(in: checkLightsAnimation, str: "Xtend-5-Do-you-see-the-lights-powered-on")
        case 7:
            self.checkLightsPrimaryLbl.text = ExtenderDataManager.shared.isExtenderTroubleshootFlow ? "Do you see the WiFi lights blinking slowly?" : "Wait a few minutes until the WiFi lights blink slowly on the Extender"
            self.checkLightsAnimation.animation = LottieAnimation.named("Extender6E-WiFi-Lights-blinking-slowly-part1")
            playTwoAnimatioins(in: checkLightsAnimation, firstAnimation: "Extender6E-WiFi-Lights-blinking-slowly-part1", secondAnimation: "Extender6E-WiFi-Lights-blinking-slowly-part2", completion: {
                
            })
            self.checkLightsPrimaryBtn.setTitle("I see the WiFi lights blinking slowly", for: .normal)
            self.checkLightsSecondaryBtn.setTitle("I see something else", for: .normal)
            
        default:
            self.checkLightsPrimaryLbl.text = ExtenderDataManager.shared.isExtenderTroubleshootFlow ? "Do you see the WiFi symbol blinking slowly?" : "Wait a few minutes until the WiFi symbol blink slowly on the Extender"
            self.checkLightsPrimaryBtn.setTitle("I see the WiFi symbol blinking slowly", for: .normal)
            self.checkLightsSecondaryBtn.setTitle("I see something else", for: .normal)
            playSingleAnimation(in: checkLightsAnimation, str: "Xtend-6-WiFi-symbol-slowly-blinks")
        }
    }
    
    @IBAction func checkLightsPrimaryBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallLetsPairVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func checkLightsSecBtnAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        if checkLightsSecondaryBtn.isSelected || ExtenderDataManager.shared.extenderCheckLightsFirst == true {
            let vc = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(withIdentifier: "XtendSupportViewController")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            checkLightsSecondaryBtn.isSelected = true
            ExtenderDataManager.shared.extenderCheckLightsFirst = true
            let vc = storyboard.instantiateViewController(withIdentifier: "unableToSeeLightsFirstVC")
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func trackAnalyticsSIScreens() {
        var screenTag: String = ""
        if ExtenderDataManager.shared.isExtenderTroubleshootFlow {
            screenTag = ExtenderTroubleshooting.ExtenderTypeForTS.ts_extender5_check_lights.extenderTitleTS
        } else {
            screenTag = ExtenderInstallScreens.ExtenderType.extender5_check_lights_on_extender.extenderTitle
        }
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Extender.rawValue])
    }
    func playTwoAnimatioins(in animationView: LottieAnimationView, firstAnimation: String, secondAnimation: String, completion: @escaping () -> Void)  {
        animationView.animation = LottieAnimation.named(firstAnimation)
        animationView.loopMode = .playOnce
        animationView.play(completion: { (_) in
            animationView.animation = LottieAnimation.named(secondAnimation)
            animationView.loopMode = .loop
            animationView.play(completion: { (_) in
                completion()
            })
        })
    }
    func playSingleAnimation(in animationView: LottieAnimationView, str: String) {
        animationView.animation = LottieAnimation.named(str)
        self.checkLightsAnimation.backgroundColor = .clear
        self.checkLightsAnimation.loopMode = .playOnce
        self.checkLightsAnimation.animationSpeed = 1.0
        self.checkLightsAnimation.backgroundBehavior = .pauseAndRestore
        self.checkLightsAnimation.play()
    }
}
