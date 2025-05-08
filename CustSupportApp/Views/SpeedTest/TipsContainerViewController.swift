//
//  TipsContainerViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/24/22.
//

import UIKit

class TipsContainerViewController: UIViewController {
    enum ViewOption {
        case speedFactors
        case optimizeTips
    }
    @IBOutlet weak var crossButtonView: UIView!
    @IBOutlet weak var tableViewControllerView: UIView!
    var viewOption: ViewOption! = .speedFactors
    
    @IBAction func closeButtonAction(_ sender: Any) {
//        navigationController?.dismiss(animated: true)
        // CMAIOS:2506
        if let navigationControl = self.presentingViewController as? UINavigationController {
            if let moreOptions = navigationControl.viewControllers.filter({$0 is AdvancedSettingsUIViewController}).first as? AdvancedSettingsUIViewController {
                DispatchQueue.main.async {
                    navigationControl.dismiss(animated: false, completion: {
                        navigationControl.popToViewController(moreOptions, animated: true)
                    })
                }
            }
        } else {
            navigationController?.dismiss(animated: true)
        }
    }
    
    @IBOutlet weak var closeBottomViewConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        var vc: UIViewController?
        switch viewOption {
        case .speedFactors:
            vc = SpeedFactorsViewController.instantiateWithIdentifier(from: .speedTest)
        case .optimizeTips:
            vc = HelpMeOptimizeViewController.instantiateWithIdentifier(from: .speedTest)
        default: break
        }
        guard let vc = vc else { return }
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewControllerView.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            crossButtonView.topAnchor.constraint(equalTo: vc.view.bottomAnchor, constant:0)
        ])
       // closeBottomViewConstraint.constant = UIDevice.current.hasNotch ? 45 : 30
        addChild(vc)
        vc.didMove(toParent: self)
        self.crossButtonView.layer.shadowColor = UIColor.gray.cgColor
        self.crossButtonView.layer.shadowOpacity = 0.25
        self.crossButtonView.layer.shadowRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool){
        //For Firebase Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : SpeedTestScreenDetails.SPEEDTEST_FACTORS_INFLUENCING_YOUR_INTERNET_SPEED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.WiFi.rawValue ])
    }
}
