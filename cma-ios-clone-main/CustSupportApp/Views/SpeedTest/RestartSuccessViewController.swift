//
//  RestartSuccessViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 10/20/22.
//

import Lottie
import UIKit

class RestartSuccessViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }

    @IBOutlet var header: UILabel!
    @IBOutlet var instructions: UILabel!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryAction.layer.borderWidth = 1
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        buttonDelegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func onTapPrimaryAction(_ sender: UIButton) {
        let vc = self.presentingViewController
        navigationController?.dismiss(animated: true) {
            guard let nav = UIViewController.instantiate(from: .speedTest) as? UINavigationController else { return }
            (nav.topViewController as? CheckInternetSpeedViewController)?.isRestartHappend = true
            nav.modalPresentationStyle = .fullScreen
            vc?.present(nav, animated: true)
        }
    }
    
    @IBAction func onTapSecondaryAction(_ sender: UIButton) {
        navigationController?.dismiss(animated: true)
    }
    
    func onTapCancel() {
        navigationController?.dismiss(animated: true)
    }
}
