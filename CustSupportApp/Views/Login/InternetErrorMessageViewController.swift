//
//  InternetErrorMessageViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 07/08/23.
//

import UIKit

class InternetErrorMessageViewController: UIViewController {
    @IBOutlet weak var internetOfflineImageView: UIImageView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    @IBAction func clickTryAgain(_ sender: Any) {
        let isNetworkAvailable = ReachabilityManager.shared.isNetworkAvailable
        if isNetworkAvailable {
           ReachabilityManager.shared.dismissInternetErrorViewController()
        } else {
            return
        }
    }
}
