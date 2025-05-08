//
//  CardExpiredNotifyVC.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 12/02/24.
//

import UIKit

protocol CardExpiredNotifyDelegate: AnyObject {
    func didDismissCardExpiredNotify(withPaymentMethod method: PayMethod?)
}

class CardExpiredNotifyVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var buttonUpdateExpiration: RoundedButton!
    @IBOutlet weak var buttonUpdatePaymethod: RoundedButton!
    
    var payMethod: PayMethod?
    var paymentDate: String = ""
    var isComeChoosePayment: Bool = false
    var selectionHandler: ((PayMethod) -> Void)?
    weak var delegate: CardExpiredNotifyDelegate?
    weak var makePaymentViewController: MakePaymentViewController?
    var cardExpiryFlow: ExpirationFlow = .scheduledPayment
    var schedulePaymentDate: String?
    var refPaymentDate: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.refPaymentDate = self.paymentDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true // CMAIOS-2174
    }
    
    func setupUI()
    {
        switch self.cardExpiryFlow {
        case .onlyDefaultExpired, .defaultExpiredWithMoreMOPs:
            let info = QuickPayManager.shared.payMethodInfo(payMethod: payMethod)
            lblTitle.text = "\(info.0) has expired"
            if self.cardExpiryFlow == .defaultExpiredWithMoreMOPs {
                lblTitle.text = "Your default payment method \(info.0) has expired"
            }
            lblSubTitle.text = "Please update your payment method."
        case .newCardDateExpired:
            let info = QuickPayManager.shared.payMethodInfo(payMethod: payMethod)
            var dateValue = ""
            if let scheduleDate = self.schedulePaymentDate {
                let formattedScheduleDate = scheduleDate.components(separatedBy: "T")
                let modifiedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedScheduleDate[0])
                dateValue = modifiedDate.getDateStringFromDate()
            }
            lblTitle.text = "Your \(info.0) expires before \(dateValue)"
            lblSubTitle.text = "Please use a different payment method."
            self.buttonUpdateExpiration.isHidden = true
            self.buttonUpdatePaymethod.borderWidth = 0.0
            self.buttonUpdatePaymethod.backgroundColor = UIColor(named: "CommonButtonColor")
            self.buttonUpdatePaymethod.setTitleColor(.white, for: .normal)
            self.buttonUpdatePaymethod.titleLabel?.font = UIFont(name: "Regular-SemiBold", size: 18)
        default:
            let info = QuickPayManager.shared.payMethodInfo(payMethod: payMethod)
            //CMAIOS-2397 use short abbreviation for year in DateFormatter
            let dateValue = CommonUtility.convertDateStringFormatToPlainStyle(dateString: paymentDate, dateFormat: "MMM. d, yyyy")
            lblTitle.text = "\(info.0) expires before \(dateValue)"
            //CMAIOS-2173-Fix
            var isDefaultMethod = false
            if let defaultPayMethod = QuickPayManager.shared.getDefaultPayMethod(), let name = defaultPayMethod.name, !name.isEmpty, let payMethod = payMethod, let paymentName = payMethod.name, !paymentName.isEmpty, name == paymentName {
                isDefaultMethod = true
            }
            //
            lblSubTitle.text = (!isDefaultMethod) ? "Please update the expiration date or use a different payment method." : "Please update your payment method or go back and choose a different date."
        }
    }
    
    func convertDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: dateString).map { dateFormatter.dateFormat = "yyyy-MM-dd"; return dateFormatter.string(from: $0) }
    }
    @IBAction func updateExpirationAction(_ sender: Any) {
        
        switch self.cardExpiryFlow {
        case .onlyDefaultExpired, .defaultExpiredWithMoreMOPs:
            guard let viewcontroller = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
                viewcontroller.flow = self.cardExpiryFlow
                viewcontroller.payMethod = self.payMethod
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        default:
            self.showCardExpirationScreen()
        }
    }
    
    private func showCardExpirationScreen() {
        guard let viewcontroller = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
            viewcontroller.flow = self.cardExpiryFlow
            viewcontroller.payMethod = self.payMethod
            viewcontroller.successHandler = { [weak self] payMethod in
                self?.updateMakePaymentWithNewExpiry(paymethod: payMethod)
            }
        // CMAIOS-2099
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @IBAction func usePaymentMethodAction(_ sender: Any) {
        if(isComeChoosePayment) {
            DispatchQueue.main.async {
                self.delegate?.didDismissCardExpiredNotify(withPaymentMethod: self.payMethod)
            }
            // CMAIOS-2099
            self.navigationController?.popViewController(animated: true)
        } else {
            switch self.cardExpiryFlow {
            case .newCardDateExpired:
                //CMAIOS-2385
                if let chooseVc = navigationController?.viewControllers.filter({$0.isKind(of: ChoosePaymentViewController.classForCoder())}).first {
                    self.navigationController?.popToViewController(chooseVc, animated: true)
                }
                //
            case .onlyDefaultExpired:
                navToAddPaymentMethodVC()
            default:
                guard let vc = ChoosePaymentViewController.instantiateWithIdentifier(from: .BillPay) else { return }
                //CMAIOS-2454: updated title and removed the expired method from list
                if payMethod != nil {
                    vc.payMethod = payMethod
                    vc.selectedPayMethods = self.payMethod
                }
                vc.titleHeader = "Choose a different payment method"
                vc.isFromOtpOrSPF = true
                //
                vc.paymentDate = self.paymentDate
                //CMAIOS-2148 - Scheduled date not passed
                vc.schedulePaymentDate = self.paymentDate
                //
                vc.isMakePaymentFlow = true
                vc.makePaymentViewController = makePaymentViewController
                vc.selectionHandler = { [weak self] payMethod in
                    switch self?.cardExpiryFlow {
                    case .onlyDefaultExpired, .defaultExpiredWithMoreMOPs:
                        // CMAIOS-2099
                        self?.navigationController?.popViewController(animated: false)
                        DispatchQueue.main.async {
                            self?.onlyDefaultCardExpiredFlow(paymethod: payMethod)
                        }
                    default:
                        self?.updateMakePaymentWithNewExpiry(paymethod: payMethod)
                    }
                }
                // CMAIOS-2099
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func navToAddPaymentMethodVC() {
        guard let viewcontroller = AddingPaymentMethodViewController.instantiateWithIdentifier(from: .BillPay) else { return }
        viewcontroller.isMakePaymentFlow = true
        viewcontroller.cardExpiryFlow = cardExpiryFlow
        viewcontroller.schedulePaymentDate = schedulePaymentDate
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @IBAction func closeBtnTapAction(_ sender: Any) {
        if self.navigationController?.viewControllers.last(where: { $0.isKind(of: BillingPaymentViewController.self) }) != nil || self.navigationController?.viewControllers.last(where: { $0.isKind(of: ManualCardEntryViewController.self) }) != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func onlyDefaultCardExpiredFlow(paymethod: PayMethod?) { // CMAIOS-2009 & CMAIOS-2012
//        if QuickPayManager.shared.getCurrentAmount() == "" {
//            self.enterAmountScreen(paymethod: paymethod)
//        } else {
//            self.moveToMakePaymentScreen(paymethod: paymethod)
//        }
        
        switch (QuickPayManager.shared.getCurrentAmount() == "",
                QuickPayManager.shared.getScheduledPaymentAmount() > 0) {
        case (true, _), (_, true):
            self.enterAmountScreen(paymethod: paymethod)
        default:
            self.moveToMakePaymentScreen(paymethod: paymethod)
        }
    }
    
    /// Whenever card expiry date or schedule date are updated, We need to update the same in make payment screen
    /// // CMAIOS-2140 & CMAIOS-2141 Navigation updates
    /// - Parameter paymethod: Updated paymethod with new expiry date
    private func updateMakePaymentWithNewExpiry(paymethod: PayMethod?) {
        if let makePayment = self.navigationController?.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first as? MakePaymentViewController {
            makePayment.refPaymentDate = self.paymentDate
            makePayment.updateAfterExpirationFlow(paymethod: paymethod)
            self.navigationController?.popToViewController(makePayment, animated: true)
        }
    }
        
    private func enterAmountScreen(paymethod: PayMethod?) {
        DispatchQueue.main.async {
            // CMAIOS-2099
            let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
            enterPayVC.amountStr = ""
            enterPayVC.balanceStateText = "No payment due at this time"
            enterPayVC.payMethod = paymethod
//            enterPayVC.updatedPaymentMethod = paymethod // CMAIOS-2144
            self.navigationController?.pushViewController(enterPayVC, animated: true)
        }
    }
    
    private func moveToMakePaymentScreen(paymethod: PayMethod?) {
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        QuickPayManager.shared.initialScreenTypeWithOutManualBlock()
        makePayVC.state = QuickPayManager.shared.getInitialScreenFlowState()
        makePayVC.updatedPayMethod = paymethod
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
}
