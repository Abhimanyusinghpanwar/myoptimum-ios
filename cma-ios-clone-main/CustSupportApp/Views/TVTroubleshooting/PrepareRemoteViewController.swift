//
//  CannotControlMyTVViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 26/12/23.
//

import UIKit

class PrepareRemoteViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            cancel()
        }
    }
    
    @IBOutlet weak var lableMessage: UILabel!
    
    let remoteVoiceMessage = "Let's pair your remote so you can use voice commands and control the box when it is placed out of sight."
    let streamRemoteTryAgainMessage = "Okay, let's try pairing your remote again"
    var isRemoteVoiceTSFlow: Bool = false
    var streamRemoteTryAgain: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : getScreenName() , EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    func getScreenName() -> String{
        var screenName = ""
        switch (isRemoteVoiceTSFlow, streamRemoteTryAgain) {
        case (true, false):
            screenName = TVStreamTroubleshooting.TV_CANT_USE_VOICE.rawValue
        case (false, true):
            screenName = TVStreamTroubleshooting.TV_PROGRAM_REMOTE_RETRY.rawValue
        default:
            screenName = TVStreamTroubleshooting.TV_PROGRAM_REMOTE_START.rawValue
        }
        return screenName
    }
    
    func setUpUI() {
        lableMessage.setLineHeight(1.2)
        lableMessage.font = UIFont(name: "Regular-Bold", size: 28)
        if isRemoteVoiceTSFlow {
            lableMessage.text = remoteVoiceMessage
        }
        if streamRemoteTryAgain {
            lableMessage.text = streamRemoteTryAgainMessage
        }
    }
    
    @IBAction func letsDoItButtonTapped(_ sender: Any) {
        guard let vc = PairStreamRemoteVC.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
        vc.isRemoteVoiceTSFlow = self.isRemoteVoiceTSFlow
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            cancelVC.isComeTVTroubleshooting = true
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
}
