//
//  PairStreamRemoteVC.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 27/12/23.
//

import UIKit
import Lottie

class PairStreamRemoteVC: BaseViewController , BarButtonItemDelegate{
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            cancel()
        }
    }
    
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var screenSettingsLabel: UILabel!
    @IBOutlet weak var screenSubTitleLabel: UILabel!
    @IBOutlet weak var settingSlideoutAnimationView: LottieAnimationView!
    var isRemoteVoiceTSFlow: Bool = false
    var isAnimationPlaying:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buttonDelegate = self
        self.screenTitleLabel.attributedText = CommonUtility.setHighlightString(labelText: "From the Optimum Stream home screen, go to Settings.", highlightString: "Settings.")
        self.screenSettingsLabel.attributedText = CommonUtility.setHighlightString(labelText: "Select Devices & Remote Settings.", highlightString: "Devices & Remote Settings.")
        self.screenSubTitleLabel.attributedText = CommonUtility.setHighlightString(labelText: "Then, select Remote & Accessories.", highlightString: "Remote & Accessories.")
        self.screenTitleLabel.setLineHeight(1.2)
        self.screenSettingsLabel.setLineHeight(1.2)
        self.screenSubTitleLabel.setLineHeight(1.2)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        settingSlideoutAnimationView.addGestureRecognizer(tapGesture)
        settingSlideoutAnimationView.isUserInteractionEnabled = true
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupStreamTroubleshootingView()
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_PAIR_REMOTE_SETTINGS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.settingSlideoutAnimationView.stop()
    }
    
    func setupStreamTroubleshootingView() {
        self.isAnimationPlaying = true
        self.settingSlideoutAnimationView.animation = nil
        self.settingSlideoutAnimationView.animation = LottieAnimation.named("01-Settings-Page")
        self.settingSlideoutAnimationView.loopMode = .playOnce
        self.settingSlideoutAnimationView.animationSpeed = 1.0
        self.settingSlideoutAnimationView.backgroundBehavior = .forceFinish
        self.settingSlideoutAnimationView.play(toProgress: 0.05, completion:{_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.settingSlideoutAnimationView.play(fromProgress: self.settingSlideoutAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce,completion: {_ in
                    self.isAnimationPlaying = false
                })
            }
        })
    }
    
    func cancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            cancelVC.isComeTVTroubleshooting = true
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    @IBAction func primaryButtonAction(_ sender: UIButton) {
        guard let vc = StreamTroubleshootingViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
        vc.flowType = isRemoteVoiceTSFlow ? .voiceAddStreamRemote : .none
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if !isAnimationPlaying{
            self.setupStreamTroubleshootingView()
        }
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
