//
//  AddCardViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 12/2/22.
//

import Foundation
import AVFoundation

class AddCardViewController: BaseViewController {
    @IBOutlet weak var labelCardTitle: UILabel!
    
    var alreadyNavigated = false
    var flow: flowType = .addCard(navType: .home)
    var isMakePaymentFlow: Bool = false
    var isFromAddingPayment: Bool = false
    var schedulePaymentDate: String?
    var cardExpiryFlow: ExpirationFlow = .none
    var selectedAmount: Double = 0.0
    var isAutoPaymentErrorFlow = false

    @IBAction func onTapScanAction() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            DispatchQueue.main.async {
                self.moveToScannerView()
            }
        } else {
            // Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ADDCARD_SCAN_POP_PERMISSION.rawValue,
                           CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    // Google Analytics
                    CMAAnalyticsManager.sharedInstance.trackAction(
                        eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ADDCARD_SCAN_ALLOW_ACCESS.rawValue,
                                   CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
                    DispatchQueue.main.async {
                        self.moveToScannerView()
                    }
                }
                else {
                    Logger.info("Camera access not granted for scanning the card")
                }
            })
        }
        
//        scanner.completionHandler = { cardNumber, expirationDate in
//            if let cardType = CreditCardValidator.cardType(cardNumber: cardNumber) {
//                let cardName = cardType.cardName
//                let image = cardType.cardImage
//                let cardInfo = CardInfo(cardNumber: cardNumber, cardImage: image, cardName: cardName, expirationDate: expirationDate)
//                Logger.info(cardName)
//                DispatchQueue.main.async {
//                    if !self.alreadyNavigated {
//                        self.showManualCardEntryWithScannedInfo(cardInfo: cardInfo)
//                    }
//                }
//            }
//        }
    }
    
    func moveToScannerView() {
        guard let scanner = CreditCardScanner.instantiateWithIdentifier(from: .payments) else { return }
        scanner.modalPresentationStyle = .fullScreen
        scanner.flow = flow
        scanner.isMakePaymentFlow = isMakePaymentFlow
        scanner.schedulePaymentDate = schedulePaymentDate
        scanner.selectedAmount = selectedAmount
        scanner.selectedAmount = selectedAmount
        scanner.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.pushViewController(scanner, animated: true)
    }
    
    @IBAction func onTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    func showManualCardEntryWithScannedInfo(cardInfo: CardInfo?) {
        alreadyNavigated = true
        guard let viewcontroller = ManualCardEntryViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.cardInfo = cardInfo
        viewcontroller.cardExpiryFlow = self.cardExpiryFlow
        viewcontroller.flow = flow
        viewcontroller.isMakePaymentFlow = isMakePaymentFlow
        viewcontroller.schedulePaymentDate = schedulePaymentDate
        viewcontroller.selectedAmount = selectedAmount
        viewcontroller.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @IBAction func actionManualCardEntry(_ sender: Any) {
        self.showManualCardEntryWithScannedInfo(cardInfo: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        setupInitialUI()
        // Google Analytics
        CMAAnalyticsManager.sharedInstance.trackAction(
            eventParam: [EVENT_SCREEN_NAME: BillPayEvents.QUICKPAY_ADDCARD.rawValue, CUSTOM_PARAM_FIXED : Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Billing.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alreadyNavigated = false
        self.navigationController?.navigationBar.isHidden = false // CMAIOS-2764
    }
    
    // CMA-173
    private func setupInitialUI() {
//        if QuickPayManager.shared.getAllPayMethodMop().isEmpty && flow == .addCard {
//            labelCardTitle.text = "Pay with a credit card or debit card"
//        }
    }
}

struct CardInfo {
    let cardNumber: String?
    let cardImage: String?
    let cardName: String?
    let expirationDate: String?
    
    init(cardNumber: String?, cardImage: String?, cardName: String?, expirationDate: String?) {
        self.cardNumber = cardNumber
        self.cardImage = cardImage
        self.cardName = cardName
        self.expirationDate = expirationDate
    }
}

extension AddCardViewController: BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        switch buttonType {
        case .back:
            // CMAIOS-2099
            self.navigationController?.popViewController(animated: true)
        case .cancel:
            // Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.CANCEL_ADDING_CARD_SCREEN.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
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
            } else if let managedPaymentController = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController { //CMAIOS-2765
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(managedPaymentController, animated: true)
                }
            }  else if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billingPayController, animated: true)
                }
            }  else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
