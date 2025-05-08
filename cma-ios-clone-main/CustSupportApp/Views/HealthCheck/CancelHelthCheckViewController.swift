//
//  CancelHelthCheckViewController.swift
//  CustSupportApp
//
//  Created by dhanesh.madala on 06/01/23.
//

import UIKit

class CancelHelthCheckViewController: UIViewController {

    var dismissCompletion:((Bool) -> Void)?
    var refreshDelegate: RefreshSignalProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    @IBAction func yesBtn(_ sender: Any) {
        //self.navigationController?.dismiss(animated: true)
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func noBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       //self.navigationController?.popToRootViewController(animated: true)
       
    }
}
