//
//  StreamTroubleshootingViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 01/01/24.
//

import UIKit
import Lottie

enum TroubleshootingScreenType{
    case addStreamRemote
    case pairAddedStreamRemote
    case selectStreamRemote
    case remoteProgrammed
    case voiceAddStreamRemote
    case voiceRemoteProgrammed
    case none
}

class StreamTroubleshootingViewController: BaseViewController, BarButtonItemDelegate {
    
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            cancel()
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if !isAnimationPlaying{
            self.viewAnimationSetUp(animationName: self.animationName)
        }
    }
    
    @IBAction func primaryButtonAction(_ sender: UIButton) {
        guard let vc = StreamTroubleshootingViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
        
        switch flowType {
        case .none:
            vc.flowType = .selectStreamRemote
        case .addStreamRemote:
            vc.flowType = .pairAddedStreamRemote
            self.trackOnClickEvent()
        case .pairAddedStreamRemote:
            vc.flowType = .selectStreamRemote
        case .selectStreamRemote:
              vc.flowType = .remoteProgrammed
        case .voiceAddStreamRemote:
            vc.flowType = .voiceRemoteProgrammed
            self.trackOnClickEvent()
        case .remoteProgrammed :
               self.trackOnClickEvent()
            APIRequests.shared.isReloadNotRequiredForMaui = false
               self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
                     })
        case .voiceRemoteProgrammed :
               self.trackOnClickEvent()
            APIRequests.shared.isReloadNotRequiredForMaui = false
               self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
                     })
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func trackOnClickEvent(){
        CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
            eventParam: [EVENT_LINK_TEXT : self.getAnalyticsScreenName().1,
                        EVENT_SCREEN_NAME: self.getAnalyticsScreenName().0,
                       EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue]
        )
    }
    
    func getAnalyticsScreenName()-> (String, String){
        var screenName = ""
        var onClickEventName = ""
        switch flowType {
        case .none:
            screenName = TVStreamTroubleshooting.TV_PAIR_REMOTE.rawValue
        case .addStreamRemote:
            screenName = TVStreamTroubleshooting.TV_ADD_REMOTE.rawValue
            onClickEventName = TVStreamTroubleshooting.PAIRED_MY_REMOTE_BUTTON_CLICK.rawValue
        case .pairAddedStreamRemote:
            screenName = TVStreamTroubleshooting.TV_PROGRAM_REMOTE.rawValue
        case .selectStreamRemote :
            screenName = TVStreamTroubleshooting.TV_SEE_REMOTE.rawValue
         case .remoteProgrammed:
            screenName = TVStreamTroubleshooting.TV_REMOTE_TROUBLESHOOT_END.rawValue
            onClickEventName = TVStreamTroubleshooting.REMOTE_CONTROLS_TV_BUTTON_CLICK.rawValue
        case .voiceAddStreamRemote:
            screenName = TVStreamTroubleshooting.TV_REMOTE_ADDSTREAMREMOTE.rawValue
            onClickEventName = TVStreamTroubleshooting.PAIRED_MY_REMOTE_BUTTON_CLICK.rawValue
        case .voiceRemoteProgrammed:
            screenName = TVStreamTroubleshooting.TV_REMOTE_VOICE_TROUBLESHOOT_END.rawValue
            onClickEventName = TVStreamTroubleshooting.REMOTE_WORKS_NOW_BUTTON_CLICK.rawValue
        }
        return (screenName, onClickEventName)
    }
    
    @IBAction func secondaryButtonAction(_ sender: UIButton) {
        guard let vc = StreamTroubleshootingViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
        switch flowType {
        case .none:
              vc.flowType = .addStreamRemote
              self.navigationController?.navigationBar.isHidden = false
              self.navigationController?.pushViewController(vc, animated: true)
        case .pairAddedStreamRemote:
            guard let vc = PrepareRemoteViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
            vc.streamRemoteTryAgain = true
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        case .addStreamRemote:
            self.navigateToChatUsScreen()
        case .selectStreamRemote:
             self.navigateToChatUsScreen()
        case .remoteProgrammed:
            self.navigateToChatUsScreen()
        case .voiceAddStreamRemote:
            self.navigateToChatUsScreen()
        case.voiceRemoteProgrammed:
            self.navigateToChatUsScreen()
        default:
            break
        }
    }
    @IBOutlet weak var streamingAnimationView: LottieAnimationView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    
    var flowType:TroubleshootingScreenType = .none
    var animationName:String = ""
    var isAnimationPlaying:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        self.secondaryButton.layer.borderWidth = 2.0
        self.secondaryButton.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1.0).cgColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        streamingAnimationView.addGestureRecognizer(tapGesture)
        streamingAnimationView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayTextForScreenType(screenType: self.flowType)
        self.trackCurrentScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.streamingAnimationView.stop()
    }
    
    func viewAnimationSetUp(animationName: String) {
        self.isAnimationPlaying = true
        self.animationName = animationName
        self.streamingAnimationView.backgroundColor = .clear
        self.streamingAnimationView.animation = LottieAnimation.named(animationName)
        self.streamingAnimationView.animationSpeed = 1.0
        self.streamingAnimationView.backgroundBehavior = .forceFinish
        self.streamingAnimationView.play(toProgress: 0.05, completion:{_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.streamingAnimationView.play(fromProgress: self.streamingAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce,completion: {_ in
                    self.isAnimationPlaying = false
                })
            }
        })
    }
    
    func displayTextForScreenType(screenType: TroubleshootingScreenType) {
        let config: (animationName: String, title: String, subTitle: NSAttributedString, description: NSAttributedString?, primaryButtonTitle: String, secondaryButtonTitle: String)
        
        switch screenType {
        case .none:
            config = ("02-Stream-Remote-Highlight", "Great", CommonUtility.setHighlightString(labelText: "Do you see your Stream Remote listed there?", highlightString: "Stream Remote"), nil, "Yes, I see the Stream remote", "No, I don't see the remote")
        case .addStreamRemote:
                    config = ("03a-Add-Stream-remote-Instructions", "Okay, we need to pair your remote first", CommonUtility.setHighlightString(labelText: "Select Add Stream Remote", highlightString: "Add Stream Remote"),CommonUtility.setHighlightString(labelText: "Then follow the on-screen instructions to pair your remote, then return here to continue.", highlightString: "") , "I paired my remote", "I need more help")
        case .pairAddedStreamRemote:
            config = ("02-Stream-Remote-Highlight", "Great, now let's program your remote", CommonUtility.setHighlightString(labelText: "On the Remote & Accessories screen, do you see the Stream Remote?", highlightString: "Stream Remote?"), nil , "Yes, I see Stream Remote", "No, I don't see the remote")
        case .selectStreamRemote :
            config = ("03-Stream-Remote-Instructions", "Awesome!", CommonUtility.setHighlightString(labelText: "Select Stream Remote", highlightString: "Stream Remote"), CommonUtility.setHighlightString(labelText: "Then select Change TV Set Up and follow the on-screen instructions", highlightString: "Change TV Set Up"), "I programmed the remote", "I need more help")
         case .remoteProgrammed:
            config = ("04-Stream-Remote-works-now", "Your remote should control the TV power and volume now", CommonUtility.setHighlightString(labelText: "Did that fix your problem?", highlightString: ""), nil, "Yes, my remote controls the TV now", "No, I'm still experiencing an issue")
        case .voiceAddStreamRemote:
            config = ("03a-Add-Stream-remote-Instructions", "Good", CommonUtility.setHighlightString(labelText: "Select Add Stream Remote", highlightString: "Add Stream Remote"),CommonUtility.setHighlightString(labelText: "Then follow the on-screen instructions to pair your remote and return here to continue", highlightString: "") , "I paired my remote", "I need more help")
        case .voiceRemoteProgrammed:
           config = ("04-Stream-Remote-works-now", "Your remote should work now", CommonUtility.setHighlightString(labelText: " Did that fix your problem?", highlightString: ""), nil, "Yes, my remote works now", "No, I'm still experiencing an issue")
        }
        
        self.viewAnimationSetUp(animationName: config.animationName)
        self.titleLabel.text = config.title
        self.subTitleLabel.attributedText = config.subTitle
        self.descriptionLabel.attributedText = config.description
        self.primaryButton.setTitle(config.primaryButtonTitle, for: .normal)
        self.secondaryButton.setTitle(config.secondaryButtonTitle, for: .normal)
        self.titleLabel.setLineHeight(1.2)
        self.subTitleLabel.setLineHeight(1.2)
        self.descriptionLabel.setLineHeight(1.2)
    }
    
    func trackCurrentScreen(){
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : self.getAnalyticsScreenName().0, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    func cancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            cancelVC.isComeTVTroubleshooting = true
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    func navigateToChatUsScreen() {
        guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
        vc.isFromTV = true //CMAIOS-2886
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
