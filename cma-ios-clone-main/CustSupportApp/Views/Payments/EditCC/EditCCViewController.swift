//
//  EditCCViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 06/12/24.
//

import UIKit
import Lottie

class EditCCViewController: UIViewController {
    
    @IBOutlet weak var editCCTableView: UITableView!
    @IBOutlet var primaryAction: UIButton!
    @IBOutlet var secondaryAction: UIButton!
    @IBOutlet var saveAndCancelView: UIView!
    @IBOutlet var saveCancelViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var viewBottomConstraint: NSLayoutConstraint! //CMAIOS-2763, 2149
    var addressButtonSelected = true
    var rowHeightForDetails = 421.0
    var updateRowHeightForError = 0.0
    var diminishRowHeightForError = 0.0
    var isErrorObservedInEdit = false
    var payMethod: PayMethod?
    var isShowAutoPay = false
    @IBOutlet weak var primaryButtonAnimationView: LottieAnimationView!
    var signInIsProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editCCTableView.register(UINib(nibName: "EditCCHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "EditCCHeaderTableViewCell")
        self.editCCTableView.register(UINib(nibName: "EditCCCardDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "EditCCCardDetailsTableViewCell")
        self.editCCTableView.register(UINib(nibName: "EditCCDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "EditCCDetailsTableViewCell")
        secondaryAction.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        // Do any additional setup after loading the view.
        self.saveCancelViewBottomConstraint.constant = UIDevice().hasNotch ? -35 : 0
        //CMAIOS-2763, 2149: Bottom space(30 px) fix
        self.viewBottomConstraint.constant = UIDevice().hasNotch ? 44 : 30
        isShowAutoPay = self.setCardData().2
        //CMAIOS-2624
        self.addressButtonSelected = !QuickPayManager.shared.isBillingAndServiceAddressAreSame(payMethod: payMethod)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.editCCTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showShadowForButtonView()
    }
    
    func showShadowForButtonView() {
        if !addressButtonSelected {
            if let cell = self.editCCTableView.cellForRow(at: NSIndexPath(row: 2, section: 0) as IndexPath), let height = (cell.frame.origin.y + editCCTableView.frame.minY + 321.0) as CGFloat?, height > self.saveAndCancelView.frame.origin.y {
                self.editCCTableView.isScrollEnabled = true
                self.saveAndCancelView.addTopShadow()
            } else {
                self.editCCTableView.isScrollEnabled = false
                self.saveAndCancelView.layer.shadowOpacity = 0
            }
        } else {
            self.editCCTableView.isScrollEnabled = true
            self.saveAndCancelView.addTopShadow()
        }
        if addressButtonSelected {
            rowHeightForDetails = 781.0
        } else {
            rowHeightForDetails = 421.0
        }
    }
    
    @IBAction func onTapSecondaryAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapPrimaryAction(_ sender: UIButton) {
        guard let cell = self.editCCTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditCCDetailsTableViewCell else {
            return
        }
        self.editCCTableView.beginUpdates()
        if let errorMessage = cell.checkErrorForCardNameTxtfield(cell.cardNameTxtFld, fieldName: "Name on Card") as String? {
            self.showHideWarningForCard(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
            isErrorObservedInEdit = errorMessage.isEmpty ? false : true
        }
        if let errorMessage = cell.checkErrorExpiryDateTxtfield(cell.expiryDateTxtFld, fieldName: "Expiration date") as String? {
            self.showHideWarningForDate(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
            if !isErrorObservedInEdit {
                isErrorObservedInEdit = errorMessage.isEmpty ? false : true
            }
        }
        if let errorMessage = cell.checkErrorNickNameTxtfield(cell.nickNameTxtFld, fieldName: "Nickname") as String? {
            self.showHideWarningForNickName(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
            if !isErrorObservedInEdit {
                isErrorObservedInEdit = errorMessage.isEmpty ? false : true
            }
        }
        if addressButtonSelected {
            if let errorMessage = cell.checkErrorAddressLine1Txtfield(cell.addressLine1TxtFld, fieldName: "Address") as String? {
                self.showHideWarningForAddress(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
                if !isErrorObservedInEdit {
                    isErrorObservedInEdit = errorMessage.isEmpty ? false : true
                    if isErrorObservedInEdit {
                        cell.addressLine1TxtFld.becomeFirstResponder()
                    }
                }
            }
            if let errorMessage = cell.checkErrorCityTxtfield(cell.cityTxtFld, fieldName: "City") as String? {
                self.showHideWarningForCity(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
                if !isErrorObservedInEdit {
                    isErrorObservedInEdit = errorMessage.isEmpty ? false : true
                    if isErrorObservedInEdit {
                        cell.cityTxtFld.becomeFirstResponder()
                        self.editCCTableView.contentInset = UIEdgeInsets(top: self.editCCTableView.contentInset.top, left: self.editCCTableView.contentInset.left, bottom: self.editCCTableView.contentInset.bottom + 40.0, right: self.editCCTableView.contentInset.right)
                    }
                }
            }
            if let errorMessage = cell.checkErrorStateTxtfield(cell.stateTxtFld, fieldName: "State") as String? {
                self.showHideWarningForState(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
                if !isErrorObservedInEdit {
                    isErrorObservedInEdit = errorMessage.isEmpty ? false : true
                    if isErrorObservedInEdit {
                        cell.stateTxtFld.becomeFirstResponder()
                    }
                }
            }
            if let errorMessage = cell.checkErrorZipCodeTxtfield(cell.zipCodeTxtFld, fieldName: "Zip code") as String? {
                self.showHideWarningForZipCode(cell, isWarningShown: errorMessage.isEmpty ? false : true, errorMessage: errorMessage)
                if !isErrorObservedInEdit {
                    isErrorObservedInEdit = errorMessage.isEmpty ? false : true
                    if isErrorObservedInEdit {
                        cell.zipCodeTxtFld.becomeFirstResponder()
                    }
                }
            }
        }
        self.editCCTableView.endUpdates()
        if !isErrorObservedInEdit {
            if self.isAnyCardDetailsUpdated(editCell: cell) {
                self.view.isUserInteractionEnabled = false
                self.createEditedDataForUpdate(editCell: cell)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            print("Error Observed")
        }
    }
    
    func createEditedDataForUpdate(editCell: EditCCDetailsTableViewCell) {
        let expiryDate = CommonUtility.dateStringToTimeStamp(dateString: editCell.expiryDateTxtFld.text ?? "", dateFormat: "MM/yy")
        let cardName = editCell.cardNameTxtFld.text?.trimExtraWhiteLeadingTrailingSpaces()
        let nickName = editCell.nickNameTxtFld.text?.trimExtraWhiteLeadingTrailingSpaces()
        
        let serviceAddress = self.getServiceAddress() // (addressLine1, addressLine2, city, state, zipCode)
        let cardDict = CreditCardPayMethod(nameOnCard: cardName,
                                           expiryDate: expiryDate,
                                           addressLine1: addressButtonSelected ? editCell.addressLine1TxtFld.text: serviceAddress.0 ,
                                           addressLine2: addressButtonSelected ? editCell.addressLine2TxtFld.text: serviceAddress.1,
                                           city: addressButtonSelected ? editCell.cityTxtFld.text: serviceAddress.2,
                                           state: addressButtonSelected ? editCell.stateTxtFld.text: serviceAddress.3,
                                           zip: addressButtonSelected ? editCell.zipCodeTxtFld.text: serviceAddress.4)
        let updatedPayMethod = PayMethod(name: cardName, creditCardPayMethod: cardDict)
        if nickName != payMethod?.name?.lastPathComponent {
            self.updateEditedPaymethodToRemote(updatedPayMethod: updatedPayMethod, nickName: nickName)
        } else {
            self.updateEditedPaymethodToRemote(updatedPayMethod: updatedPayMethod)
        }
    }
    
    // (addressLine1, addressLine2, city, state, zipCode)
    private func getServiceAddress() -> (String, String, String, String, String) {
        let streetNumber = QuickPayManager.shared.modelAccountsList?.accounts?.first?.serviceAddress?.streetNumber ?? ""
        let streetName = QuickPayManager.shared.modelAccountsList?.accounts?.first?.serviceAddress?.streetName ?? ""
        let addressLine2 = QuickPayManager.shared.modelAccountsList?.accounts?.first?.serviceAddress?.addressLine2 ?? ""
        let city = QuickPayManager.shared.modelAccountsList?.accounts?.first?.serviceAddress?.city ?? ""
        let state = QuickPayManager.shared.modelAccountsList?.accounts?.first?.serviceAddress?.state ?? ""
        let zipCode = QuickPayManager.shared.modelAccountsList?.accounts?.first?.serviceAddress?.zip ?? ""
        
        let addressLine1 = streetNumber + " " + streetName
        return (addressLine1, addressLine2, city, state, zipCode)
    }
    
    func isAnyCardDetailsUpdated(editCell: EditCCDetailsTableViewCell) -> Bool {
        let expiryDate = editCell.expiryDateTxtFld.text ?? ""
        let cardName = editCell.cardNameTxtFld.text?.trimExtraWhiteLeadingTrailingSpaces()
        let nickName = editCell.nickNameTxtFld.text?.trimExtraWhiteLeadingTrailingSpaces()
        let address1 = (editCell.addressLine1TxtFld.text ?? "").trimExtraWhiteLeadingTrailingSpaces()
        let address2 = (editCell.addressLine2TxtFld.text ?? "").trimExtraWhiteLeadingTrailingSpaces()
        let city = (editCell.cityTxtFld.text ?? "").trimExtraWhiteLeadingTrailingSpaces()
        let state = (editCell.stateTxtFld.text ?? "").trimExtraWhiteLeadingTrailingSpaces()
        let zip = (editCell.zipCodeTxtFld.text ?? "").trimExtraWhiteLeadingTrailingSpaces()
        
        guard let oldPayMethod = payMethod else {
            return true
        }
        if cardName != oldPayMethod.creditCardPayMethod?.nameOnCard ||
            nickName != oldPayMethod.name?.lastPathComponent ||
            expiryDate != QuickPayManager.shared.payMethodInfo(payMethod: oldPayMethod).2 {
            return true
        }
        if addressButtonSelected {
            if address1 != (oldPayMethod.creditCardPayMethod?.addressLine1 ?? "") ||
                address2 != (oldPayMethod.creditCardPayMethod?.addressLine2 ?? "") ||
                city != (oldPayMethod.creditCardPayMethod?.city ?? "") ||
                state != (oldPayMethod.creditCardPayMethod?.state ?? "") ||
                zip != (oldPayMethod.creditCardPayMethod?.zip ?? "") {
                return true
            }
        }
        
        // Update billing address state //CMAIOS-2782
        if QuickPayManager.shared.isBillingAndServiceAddressAreSame(payMethod: payMethod) == addressButtonSelected {
            return true
        }
        
        return false
    }
    
    func updateEditedPaymethodToRemote(updatedPayMethod: PayMethod?, nickName: String? = nil) {
        guard let oldPayMethod = payMethod else {
            return
        }
        DispatchQueue.main.async {
            self.signInButtonAnimation()
        }
        self.signInIsProgress = true
        QuickPayManager.shared.mauiUpdate(paymethod: oldPayMethod, newNickname: nickName, updatePaymethod: updatedPayMethod, completionHandler: { [weak self] result in
            switch result {
            case let .success(payMethod):
                guard payMethod != nil else { return  Logger.info("Paymethod returned nil") }
                QuickPayManager.shared.mauiGetAccountBillRequest() { error in
                    self?.signInIsProgress = false
                    self?.primaryButtonAnimationView.pause()
                    self?.primaryButtonAnimationView.play(fromProgress: self?.primaryButtonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(_):
                self?.signInFailedAnimation()
                self?.showErrorMsgOnUpdateFailure()
            }
        })
    }
    
    func handleErrorUpdatePaymethod() {
        self.signInFailedAnimation()
        self.showErrorMsgOnUpdateFailure()
    }
        
    // CMAIOS-2734
    func showErrorMsgOnUpdateFailure() {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        vc.isComingFromCardInfoPage = true
        vc.isComingFromBillingMenu = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addressButtonAction(_ selectedRow: Int) {
        guard let cell = self.editCCTableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? EditCCDetailsTableViewCell else {
            return
        }
        self.editCCTableView.beginUpdates()
        if !addressButtonSelected {
            addressButtonSelected = true
            rowHeightForDetails = 781.0
            cell.addressButton.setImage(UIImage(named: "selected-check"), for: .normal)
            cell.addressLabelBottomConstraintToAddressView.priority = UILayoutPriority(999)
            cell.addressLabelBottomConstraintToSuperView.priority = UILayoutPriority(200)
            cell.addressView.isHidden = false
        } else {
            addressButtonSelected = false
            cell.addressView.endEditing(true)
            rowHeightForDetails = 421.0
            cell.addressView.isHidden = true
            cell.addressButton.setImage(UIImage(named: "unselected-check"), for: .normal)
            cell.addressLabelBottomConstraintToAddressView.priority = UILayoutPriority(200)
            cell.addressLabelBottomConstraintToSuperView.priority = UILayoutPriority(999)
        }
//        cell.addressLine1TxtFld.text = ""
//        cell.addressLine2TxtFld.text = ""
//        cell.cityTxtFld.text = ""
//        cell.stateTxtFld.text = ""
//        cell.zipCodeTxtFld.text = ""
        cell.addressLine1ErrorLabel.isHidden = true
        cell.cityErrorLabel.isHidden = true
        cell.stateErrorLabel.isHidden = true
        cell.zipCodeErrorLabel.isHidden = true
        cell.addressLine1TxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        cell.addressLine2TxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        cell.cityTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        cell.stateTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        cell.zipCodeTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        self.editCCTableView.endUpdates()
        showShadowForButtonView()
    }
    
    func showHideWarningForCard(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        if isWarningShown, cell.cardNameErrorLabel.isHidden {
            rowHeightForDetails += 21.0
        } else if !isWarningShown, !cell.cardNameErrorLabel.isHidden {
            rowHeightForDetails -= 21.0
        }
        cell.cardNameErrorLabel.isHidden = !isWarningShown
        cell.cardNameBottomConstraintToExpiryDate.constant = isWarningShown ? 36.0 : 15.0
        cell.cardNameErrorLabel.text = errorMessage
        cell.cardNameTxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func showHideWarningForDate(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        if isWarningShown, cell.expiryDateErrorLabel.isHidden {
            rowHeightForDetails += 21.0
        } else if !isWarningShown, !cell.expiryDateErrorLabel.isHidden {
            rowHeightForDetails -= 21.0
        }
        cell.expiryDateErrorLabel.isHidden = !isWarningShown
        cell.expiryDateBottomConstraintToNickname.constant = isWarningShown ? 36.0 : 15.0
        cell.expiryDateErrorLabel.text = errorMessage
        cell.expiryDateTxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func showHideWarningForNickName(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        var rowHeight = (errorMessage == "One of your payment methods is already using this nickname.") ? 42.0 : 21.0
        var numberOfLines = (errorMessage == "One of your payment methods is already using this nickname.") ? 2 : 1
        if isWarningShown, cell.nickNameErrorLabel.isHidden {
            rowHeightForDetails += rowHeight
        } else if !isWarningShown, !cell.nickNameErrorLabel.isHidden {
            rowHeightForDetails -= rowHeight
        }
        cell.nickNameErrorLabel.isHidden = !isWarningShown
        cell.nickNameBottomConstraintToAddressView.constant = isWarningShown ? 51.0 : 30.0
        cell.nickNameErrorLabel.text = errorMessage
        cell.nickNameErrorLabel.numberOfLines = numberOfLines
        cell.nickNameTxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func showHideWarningForAddress(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        if isWarningShown, cell.addressLine1ErrorLabel.isHidden {
            rowHeightForDetails += 21.0
        } else if !isWarningShown, !cell.addressLine1ErrorLabel.isHidden {
            rowHeightForDetails -= 21.0
        }
        cell.addressLine1ErrorLabel.isHidden = !isWarningShown
        cell.addressLine1BottomConstraintToAddressLine2.constant = isWarningShown ? 36.0 : 15.0
        cell.addressLine1ErrorLabel.text = errorMessage
        cell.addressLine1TxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func showHideWarningForCity(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        if isWarningShown, cell.cityErrorLabel.isHidden {
            rowHeightForDetails += 21.0
        } else if !isWarningShown, !cell.cityErrorLabel.isHidden {
            rowHeightForDetails -= 21.0
        }
        cell.cityErrorLabel.isHidden = !isWarningShown
        cell.cityBottomConstraintToState.constant = isWarningShown ? 36.0 : 15.0
        cell.cityErrorLabel.text = errorMessage
        cell.cityTxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func showHideWarningForState(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        if isWarningShown, cell.stateErrorLabel.isHidden {
            rowHeightForDetails += 21.0
        } else if !isWarningShown, !cell.stateErrorLabel.isHidden {
            rowHeightForDetails -= 21.0
        }
        cell.stateErrorLabel.isHidden = !isWarningShown
        cell.stateBottomConstraintToZipcode.constant = isWarningShown ? 36.0 : 15.0
        cell.stateErrorLabel.text = errorMessage
        cell.stateTxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func showHideWarningForZipCode(_ cell: EditCCDetailsTableViewCell, isWarningShown : Bool, errorMessage: String) {
        if isWarningShown, cell.zipCodeErrorLabel.isHidden {
            rowHeightForDetails += 21.0
        } else if !isWarningShown, !cell.zipCodeErrorLabel.isHidden {
            rowHeightForDetails -= 21.0
        }
        cell.zipCodeErrorLabel.isHidden = !isWarningShown
        cell.zipCodeErrorLabel.text = errorMessage
        cell.zipCodeTxtFld.setBorderColor(mode: !isWarningShown ? BorderColor.deselcted_color : BorderColor.error_color )
    }
    
    func getLastFourDigits() -> String {
        var stringLastFourDigit = ""
        if let maskedBankAccountNumber = payMethod?.bankEftPayMethod?.maskedBankAccountNumber, !maskedBankAccountNumber.isEmpty {
            // If maskedBankAccountNumber is not empty, get the last four digits
            stringLastFourDigit = String(maskedBankAccountNumber.suffix(4))
        } else if let maskedCreditCardNumber = payMethod?.creditCardPayMethod?.maskedCreditCardNumber, !maskedCreditCardNumber.isEmpty {
            // If maskedBankAccountNumber is empty, check the credit card number
            stringLastFourDigit = maskedCreditCardNumber.count == 4 ? maskedCreditCardNumber : ""
        }
        return stringLastFourDigit
    }
    
    func setCardData() -> (NSMutableAttributedString, String, Bool) {
        var imageData = ""
        var isShowAutoPay = false
        let attributedText = NSMutableAttributedString(string: "•••• ")
        let lastFourDigit = getLastFourDigits()
        attributedText.append(NSAttributedString(string: lastFourDigit))
        
        if let carPayemnthod = payMethod?.creditCardPayMethod, let carType = carPayemnthod.cardType, let imageName = QuickPayManager.shared.getCardType(cardType: carType) as String?, !imageName.isEmpty {
            imageData = imageName
        }
        
        if let paymentName = QuickPayManager.shared.getDefaultAutoPaymentMethod(), paymentName.name == payMethod?.name {
            isShowAutoPay = true
        } else {
            isShowAutoPay = false
        }
        return (attributedText, imageData, isShowAutoPay)
    }
    
    func getCardDetails() -> (String, String, String) {
        var nameOnCard = ""
        var cardExpiry = ""
        let nickName = QuickPayManager.shared.getPayMethodDispalyInfo(payMethod: payMethod).1
        if let carPayemnthod = payMethod?.creditCardPayMethod, let name = carPayemnthod.nameOnCard, !name.isEmpty {
            nameOnCard = name
        }
        if let carPayemnthod = payMethod?.creditCardPayMethod, let expiryDate = carPayemnthod.expiryDate, !expiryDate.isEmpty, let expiryFormat = CommonUtility.convertDateStringFormats(dateString: expiryDate, dateFormat: "MM/yy") as String?, !expiryFormat.isEmpty {
            cardExpiry = expiryFormat
        }
        return(nameOnCard, cardExpiry, nickName)
    }
    
    func getAddressValues() -> AddressFields {
        return AddressFields(address1: payMethod?.creditCardPayMethod?.addressLine1 ?? "", address2: payMethod?.creditCardPayMethod?.addressLine2 ?? "", city: payMethod?.creditCardPayMethod?.city ?? "", state: payMethod?.creditCardPayMethod?.state ?? "", zip: payMethod?.creditCardPayMethod?.zip ?? "")
    }
    
    // MARK: - Edic card Save Button Animations
    func signInButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.primaryButtonAnimationView.isHidden = true
        self.primaryAction.isHidden = true
        self.secondaryAction.isHidden = true
        UIView.animate(withDuration: 1.0) {
            self.primaryButtonAnimationView.isHidden = false
        }
        self.primaryButtonAnimationView.backgroundColor = .clear
        self.primaryButtonAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.primaryButtonAnimationView.loopMode = .playOnce
        self.primaryButtonAnimationView.animationSpeed = 1.0
        self.primaryButtonAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.signInIsProgress {
                self.primaryButtonAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func signInFailedAnimation() {
        self.signInIsProgress = false
        self.primaryButtonAnimationView.currentProgress = 3.0
        self.primaryButtonAnimationView.stop()
        self.primaryButtonAnimationView.isHidden = true
        self.primaryAction.alpha = 0.0
        self.secondaryAction.alpha = 0.0
        self.primaryAction.isHidden = false
        self.secondaryAction.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.primaryAction.alpha = 1.0
            self.secondaryAction.alpha = 1.0
        }
    }
    
    private func valdiateCardUpdateResponse() {
        self.signInIsProgress = false
        self.primaryButtonAnimationView.pause()
        self.primaryButtonAnimationView.play(fromProgress: self.primaryButtonAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
            // Add code for navigation
        }
    }
}

extension EditCCViewController: editCCFieldDelegate {
    
    func reloadDetailsTableCell(_ selectedRow: Int, isWarningShown: Bool, textFieldName: String, errorMessage: String) {
        guard let cell = self.editCCTableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? EditCCDetailsTableViewCell else {
            return
        }
        self.editCCTableView.beginUpdates()
        switch textFieldName {
        case "Name on Card":
            showHideWarningForCard(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        case "Expiration date":
            showHideWarningForDate(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        case "Nickname":
            showHideWarningForNickName(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        case "Address":
            showHideWarningForAddress(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        case "City":
            showHideWarningForCity(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        case "State":
            showHideWarningForState(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        case "Zip code":
            showHideWarningForZipCode(cell, isWarningShown: isWarningShown, errorMessage: errorMessage)
        default: break
        }
        self.editCCTableView.endUpdates()
    }
    
    private func getSubViewType() -> String {
        let isExpired = isDefaultAutoPaymentMethodExpired()
        let expiresSoon = isDefaultAutoPaymentMethodExpiresSoon()
        switch (isExpired, expiresSoon) {
        case (true,false):
            return "Expired"
        case (false,true):
            return "ExpireSoon"
        default:
            return ""
        }
    }
    private func isDefaultAutoPaymentMethodExpired() -> Bool {
        payMethod?.creditCardPayMethod?.isCardExpired ?? false
    }
    private func isDefaultAutoPaymentMethodExpiresSoon() -> Bool {
        payMethod?.creditCardPayMethod?.isCardExpiresSoon ?? false
    }
}

extension EditCCViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if getSubViewType() == "Expired" || getSubViewType() == "ExpireSoon" {
                return 104
            }
            return 52
        } else if indexPath.row == 1 {
            return (isShowAutoPay) ? 153.0 : 135.0
        } else {
            return rowHeightForDetails + 125.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.editCCTableView.dequeueReusableCell(withIdentifier: "EditCCHeaderTableViewCell") as! EditCCHeaderTableViewCell
            cell.headerLabelBottomConstraintToSuperView.priority = UILayoutPriority(200.0)
            cell.headerLabelBottomConstraintToCardExpiry.priority = UILayoutPriority(999.0)
            cell.cardExpiryView.isHidden = false
            cell.cardExpiryView.layer.cornerRadius = 8
            cell.cardExpiryView.layer.borderWidth = 1
            switch getSubViewType() {
            case "Expired":
                cell.cardExpiryImage.image = UIImage(named: "error_icon")
                cell.cardExpiryText.text = "Card has expired"
                cell.cardExpiryView.layer.borderColor = UIColor(red: 0.954, green: 0.208, blue: 0.342, alpha: 1).cgColor
            case "ExpireSoon":
                cell.cardExpiryImage.image = UIImage(named: "AlertIcon")
                cell.cardExpiryText.text = "Card expires soon"
                cell.cardExpiryView.layer.borderColor = UIColor(red: 1, green: 0.808, blue: 0, alpha: 1).cgColor
            default:
                cell.headerLabelBottomConstraintToSuperView.priority = UILayoutPriority(999.0)
                cell.headerLabelBottomConstraintToCardExpiry.priority = UILayoutPriority(200.0)
                cell.cardExpiryView.isHidden = true
            }
            if let nickName = getCardDetails().2 as String?, !nickName.isEmpty {
                cell.headerText.text = "Edit \(nickName)"
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = self.editCCTableView.dequeueReusableCell(withIdentifier: "EditCCCardDetailsTableViewCell") as! EditCCCardDetailsTableViewCell
            (cell.cardDetailsLabel.attributedText, cell.cardImageView.image) = (self.setCardData().0, UIImage(named: self.setCardData().1))
            cell.autopayStackView.isHidden = !isShowAutoPay
            return cell
        } else {
            let cell = self.editCCTableView.dequeueReusableCell(withIdentifier: "EditCCDetailsTableViewCell") as! EditCCDetailsTableViewCell
            cell.selectedRow = indexPath.row
            cell.editCCDelegate = self
            cell.cardNameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            cell.expiryDateTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            cell.nickNameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            if let name = getCardDetails().0 as String?, !name.isEmpty {
                cell.cardNameTxtFld.text = name
            }
            if let expiryDate = getCardDetails().1 as String?, !expiryDate.isEmpty {
                cell.expiryDateTxtFld.text = expiryDate
            }
            if let nickName = getCardDetails().2 as String?, !nickName.isEmpty {
                cell.existingNickName = nickName
                cell.nickNameTxtFld.text = nickName
            }
            
            /* CMAIOS-2624 */
            let addressFields = self.getAddressValues()
            
            cell.addressLine1TxtFld.text = addressFields.address1
            cell.addressLine2TxtFld.text = addressFields.address2
            cell.cityTxtFld.text = addressFields.city
            cell.stateTxtFld.text = addressFields.state
            cell.zipCodeTxtFld.text = addressFields.zip
            
            if addressButtonSelected {
                cell.addressButton.setImage(UIImage(named: "selected-check"), for: .normal)
                cell.addressLine1TxtFld.setBorderColor(mode: BorderColor.deselcted_color)
                cell.addressLine2TxtFld.setBorderColor(mode: BorderColor.deselcted_color)
                cell.cityTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
                cell.stateTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
                cell.zipCodeTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
                /*
                let addressFields = self.getAddressValues()
                
                cell.addressLine1TxtFld.text = addressFields.address1
                cell.addressLine2TxtFld.text = addressFields.address2
                cell.cityTxtFld.text = addressFields.city
                cell.stateTxtFld.text = addressFields.state
                cell.zipCodeTxtFld.text = addressFields.zip
                 */
            }  else {
                cell.addressButton.setImage(UIImage(named: "unselected-check"), for: .normal)
            }
            cell.addressView.isHidden = !addressButtonSelected
            cell.expiryDateErrorLabel.isHidden = true
            cell.cardNameErrorLabel.isHidden = true
            cell.nickNameErrorLabel.isHidden = true
            cell.addressLine1ErrorLabel.isHidden = true
            cell.cityErrorLabel.isHidden = true
            cell.stateErrorLabel.isHidden = true
            cell.zipCodeErrorLabel.isHidden = true
            cell.handler = {self.addressButtonAction(indexPath.row)}
            return cell
        }
    }
}

public struct AddressFields {
    let address1: String?
    let address2: String?
    let city: String?
    let state: String?
    let zip: String?
}
