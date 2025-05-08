//
//  AnimationViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 07/12/23.
//

import UIKit
import Shift

class AnimationViewController: UIViewController {
    var shiftID: String = ""
    var delegate: DismissingChildViewcontroller?
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.shift.id = shiftID
        shift.baselineDuration = 0.2 //0.80
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let billPayment = UIStoryboard(name: "BillPay", bundle: Bundle.main).instantiateViewController(withIdentifier: "BillingPaymentViewController") as! BillingPaymentViewController
                let aNavigationController = UINavigationController(rootViewController: billPayment)
                aNavigationController.modalPresentationStyle = .fullScreen
                self.present(aNavigationController, animated: false, completion: nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if count == 0 {
            count += 1
        } else {
            delegate?.childViewcontrollerGettingDismissed()
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
