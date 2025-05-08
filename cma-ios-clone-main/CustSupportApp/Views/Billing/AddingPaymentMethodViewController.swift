//
//  AddingPaymentMethodViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 16/02/24.
//

import UIKit

class AddingPaymentMethodViewController: BaseViewController, BarButtonItemDelegate {
    
    var flow: flowType = .addCard(navType: .home)
    var cardExpiryFlow: ExpirationFlow = .none
    var isMakePaymentFlow: Bool = false
    var schedulePaymentDate: String?
    var isTurnOnAutoPay: Bool = false
    var selectedAmount: Double?
    var isAutoPaymentErrorFlow = false
    
    @IBOutlet weak var label_SubTitle: UILabel!
    @IBOutlet weak var viewCloseButton: UIView!
    @IBOutlet weak var label_Title: UILabel!
    
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            if let billPreferenceVC = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billPreferenceVC, animated: true)
                }
            } else if let vc = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC { //CMAIOS-2882
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            } else if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                self.dismiss(animated: true)
            } else if let managedPayments = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController { //CMAIOS-2765
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(managedPayments, animated: true)
                }
            } else if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billingPayController, animated: true)
                }
            } else {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: ACHPayments.Billing_Add_Payment_Method.rawValue,
                        EVENT_SCREEN_CLASS: self.classNameFromInstance])
        
        self.updateUiForScreenType()
    }
    
    @IBAction func addCreditCardAction(_ sender: Any) {
        guard let addCardView = AddCardViewController.instantiateWithIdentifier(from: .payments) else { return }
        addCardView.isFromAddingPayment = true
        if isMakePaymentFlow {
            addCardView.flow = cardExpiryFlow == .onlyDefaultExpired ? .addCard(navType: .makePayment) : flow
        } else {
            addCardView.flow = flow
        }
        addCardView.selectedAmount = selectedAmount ?? 0
        addCardView.cardExpiryFlow = cardExpiryFlow
        addCardView.isMakePaymentFlow = isMakePaymentFlow
        addCardView.schedulePaymentDate = schedulePaymentDate
        addCardView.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.pushViewController(addCardView, animated: true)
    }
    
    @IBAction func addCheckingAccountAction(_ sender: Any) {
        guard let achViewcontroller = AddCheckingAccountViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        self.navigationController?.navigationBar.isHidden = false
        achViewcontroller.selectedAmount = selectedAmount ?? 0
        achViewcontroller.isFromMakePaymentFlow = isMakePaymentFlow
        achViewcontroller.isTurnOnAutoPay = isTurnOnAutoPay // CMAIOS:-2178 // With Muliple MOPs
        if isMakePaymentFlow {
            achViewcontroller.flow = cardExpiryFlow == .onlyDefaultExpired ? .addCard(navType: .makePayment) : flow
        } else {
            achViewcontroller.flow = flow
        }
        achViewcontroller.cardExpiryFlow = cardExpiryFlow
        achViewcontroller.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        if self.isAutoPaymentErrorFlow {
            achViewcontroller.isFromMakePaymentFlow = true // CMAIOS: 2110, To show save check box
        }
        switch flow {
        case .managePayments(let editAutoAutoPayFlow):
            achViewcontroller.isFromMakePaymentFlow = false
        case .editAutoPay:
            achViewcontroller.isFromMakePaymentFlow = false
        default: break
        }
//        if flow == .managePayments(editAutoAutoPayFlow: ) || flow == .editAutoPay {
//            achViewcontroller.isFromMakePaymentFlow = false
//        }
        self.navigationController?.pushViewController(achViewcontroller, animated: true)
    }
        
    private func updateUiForScreenType() {
            switch (flow, QuickPayManager.shared.getAllPayMethodMop().isEmpty) {
            case (.managePayments, true):
                self.label_Title.text = "You don’t have any saved payment methods"
                self.label_SubTitle.isHidden = false
                self.viewCloseButton.isHidden = false
                self.navigationController?.navigationBar.isHidden = true
            default:
                self.label_Title.text = "What payment method would you like to add?"
                self.label_SubTitle.isHidden = true
                self.viewCloseButton.isHidden = true
                self.navigationController?.navigationBar.isHidden = false
            }
        }
    
    @IBAction func actionClose(_ sender: Any) {
        if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
           DispatchQueue.main.async {
               self.navigationController?.popToViewController(billingPayController, animated: true)
           }
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
