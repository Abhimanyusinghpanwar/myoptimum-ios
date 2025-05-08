//
//  UIViewController+ASAP.swift
//  CustSupportApp
//
//  Created by riyaz on 31/10/23.
//

import UIKit
import ASAPPSDK
import IQKeyboardManagerSwift

extension ASAPPSDK.ASAPPViewController {
    
    public override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
//        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ASAPChatScreen.Chat_Landing_Page.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
}

extension ASAPPSDK.ComponentViewController {
    
    public override func viewWillAppear(_ animated: Bool) {
        let label:VerticalAlignLabel = VerticalAlignLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.font = UIFont(name: "Regular-Bold", size: 20)
        label.text = "Feedback Survey"
        label.textColor = UIColor.white
        self.navigationItem.titleView = label
    }
}
