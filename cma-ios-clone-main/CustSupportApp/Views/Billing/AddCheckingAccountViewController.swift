//
//  AddCheckingAccountViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 23/02/24.
//

import UIKit
import SafariServices
import Lottie

class AddCheckingAccountViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,BarButtonItemDelegate, routingFieldDelegate, accountNameFieldDelegate, nickNameFieldDelegate {
    
    @IBOutlet weak var achTableView: UITableView!
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueBtn: RoundedButton!
    @IBOutlet weak var continueAnimationView: LottieAnimationView!

    @IBOutlet weak var continueBtnBottomConstraint: NSLayoutConstraint!
    var rowHeightForRouting = 77.0
    var rowHeightForAccount = 77.0
    var rowHeightForAccountName = 148.0
    var rowHeightForNickName = 62.0
    var rowHeightForTerms = 103.0
    var rowHeightForAutoPay = 121.0
    var routingSelected = false
    var accountSelected = false
    var isWarningShownForRouting = false
    var isWarningShownForAccount = false
    var isSaveBtnTapped = true
    var isTermsTapped = false
    var isValidationSuccess = false
    var isAccountNameWarning = false
    var isNickNameWarning = false
    var isTermsWarning = false
    var accountName = ""
    var routingNumber = ""
    var accountNumber = ""
    var nickName = ""
    var isAutoPayCheckBoxTapped = false
    //CMA-2450
    //var bankImg = UIImage(named: "routingBorderImage")
    var isNickNameEdited = false
    var isFromMakePaymentFlow = false
    var flow: flowType = .addCard(navType: .home)
    var paymentCreationIsProgress = false
    var cardExpiryFlow: ExpirationFlow = .none
    var isTurnOnAutoPay: Bool = false
    var isAutoPaymentErrorFlow: Bool = false

    let emptyCell                   = "EmptyCell"
    var emptyCellHeight = 0.0
    var totalContentHeight = 0.0
    var selectedAmount: Double = 0.0
    var updatedAutoPayMethodName = ""
    var payMethodCheckingInfo: BankEftPayMethod!
    var isDefaultAccount = false
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefault = UserDefaults.standard
        userDefault.set("NoVal", forKey: "bankCheckVal")
        userDefault.synchronize()
        buttonDelegate = self
        achTableView.register(UINib.init(nibName: "NameCheckTableViewCell", bundle: nil), forCellReuseIdentifier: "NameCheckTableViewCell")
        achTableView.register(UINib.init(nibName: "RoutingAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "RoutingAccountCell")
        achTableView.register(UINib.init(nibName: "SavePayToAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "SavePayToAccountTableViewCell")
        achTableView.register(UINib.init(nibName: "AddNicknameTableViewCell", bundle: nil), forCellReuseIdentifier: "AddNicknameTableViewCell")
        achTableView.register(UINib.init(nibName: "AddCheckSaveAndTermsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCheckSaveAndTermsTableViewCell")
        achTableView.register(UINib.init(nibName: "AddAcountContinueBtnTableViewCell", bundle: nil), forCellReuseIdentifier: "AddAcountContinueBtnTableViewCell")
        achTableView.register(UINib.init(nibName: "EnableAutoPayTableViewCell", bundle: nil), forCellReuseIdentifier: "EnableAutoPayTableViewCell")
        // Do any additional setup after loading the view.
        achTableView.register(EmptyCell.self, forCellReuseIdentifier: emptyCell)
        achTableView.showsVerticalScrollIndicator = false
        //CMAIOS-2860, CMAIOS-2149
        self.calculateEmptyCellHeight(isReloadNeeded: true,isMainThreadNeeded: true)
        //CMAIOS-2763, 2149: 30px bottom space fix
        self.tableViewBottomConstraint.constant = UIDevice.current.hasNotch ? 9 : 30
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueBtn.accessibilityIdentifier = "ACHContinue"
        if isFromMakePaymentFlow {
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: ACHPayments.Billing_ACH_Add_Checking_Account.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
            self.continueBtn.setTitle("Continue", for: .normal)
        } else {
            switch flow{ //CMAIOS-2712
            case .autopay, .autopayFromSP:
                self.continueBtn.setTitle("Finish setup", for: .normal)
//            case .appbNotEnrolled:
//                self.continueBtn.setTitle("Continue", for: .normal)
            default:
                CMAAnalyticsManager.sharedInstance.trackAction(
                    eventParam: [EVENT_SCREEN_NAME: ACHPayments.Billing_ACH_Add_Checking_Autopay.rawValue,
                                EVENT_SCREEN_CLASS: self.classNameFromInstance])
                self.continueBtn.setTitle("Save and continue", for: .normal)
            }
        }
    }
    //CMAIOS-2151 Calculation for empty cell height to align continue button and terms and condition lbl to bottom
    //CMAIOS-2149 This method is called to calculate the empty cell height to maintain continue button botton 30px in every scenario also term and condition lable align to continue button
    func calculateEmptyCellHeight(isReloadNeeded: Bool = false, isMainThreadNeeded: Bool = false){
        if isMainThreadNeeded {
            DispatchQueue.main.async {
                self.calculateRequiredPadding(isReloadNeeded: isReloadNeeded)
            }
        } else {
            self.calculateRequiredPadding(isReloadNeeded: isReloadNeeded)
        }
    }
    
    func calculateRequiredPadding(isReloadNeeded: Bool = false){
            self.view.layoutIfNeeded()
            if self.isFromMakePaymentFlow {
                self.totalContentHeight = self.rowHeightForAccountName + self.rowHeightForRouting + self.rowHeightForAccount + 36 + self.rowHeightForNickName + self.rowHeightForTerms //36 saveCheckBoxHeight row height
            } else {
                if self.flow == .managePayments(editAutoAutoPayFlow: false) && QuickPayManager.shared.isAutoPayEnabled() { //CMAIOS-2858
                   self.totalContentHeight = self.rowHeightForAccountName + self.rowHeightForRouting + self.rowHeightForAccount + self.rowHeightForNickName + self.rowHeightForAutoPay
                } else {
                   self.totalContentHeight = self.rowHeightForAccountName + self.rowHeightForRouting + self.rowHeightForAccount + 201 //201 is row height
                }
            }
            self.emptyCellHeight = self.achTableView.frame.size.height  - (self.totalContentHeight + self.continueView.frame.size.height)
            if isReloadNeeded {
                self.achTableView.reloadData()
            }
        }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromMakePaymentFlow {
            return 7
        } else {
            switch flow {
            case .managePayments(let editAutoAutoPayFlow):
                if !editAutoAutoPayFlow && (QuickPayManager.shared.isAutoPayEnabled() == true) { //CMAIOS-2841
                    return 6
                } else {
                    return self.returnDefaultNoOfSections()
                }
            default:
                return self.returnDefaultNoOfSections()
            }
            /*
             if flow == .managePayments && QuickPayManager.shared.isAutoPayEnabled() { //CMAIOS-2858
             if currentScreenHeight <= 667 {
             return 5
             } else {
             return 6
             }
             } else {
             if currentScreenHeight <= 667 {
             return 4
             } else {
             return 5
             }
             }
             */
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFromMakePaymentFlow {
                if indexPath.row == 0 {   //For Name view
                    return rowHeightForAccountName
                } else if indexPath.row == 1 {   //For Routing view
                    return rowHeightForRouting
                } else if indexPath.row == 2 {   //For Acc. Number view
                    return rowHeightForAccount
                }else if indexPath.row == 3 {    //For Save Pay Checkbox view
                    return 36
                } else if indexPath.row == 4 {   //For Nickname view
                    return rowHeightForNickName
                } else if indexPath.row == 5 {
                    if accountSelected || routingSelected { // for empty cell height
                        return 0
                    }
                    return self.emptyCellHeight >= 0 ? self.emptyCellHeight : 0
                } else {    //For Terms & Cond. view
                    return rowHeightForTerms
                }
        } else {
            switch flow {
            case .managePayments(let editAutoAutoPayFlow):
                if !editAutoAutoPayFlow && (QuickPayManager.shared.isAutoPayEnabled() == true) { //CMAIOS-2841
                        if indexPath.row == 0 {   //For Name view
                            return rowHeightForAccountName
                        } else if indexPath.row == 1 {   //For Routing view
                            return rowHeightForRouting
                        } else if indexPath.row == 2 {   //For Acc. Number view
                            return rowHeightForAccount
                        } else if indexPath.row == 3 {
                            return rowHeightForNickName                    //For Nickname view
                        } else if indexPath.row == 4 {
                            //CMAIOS-2860
                            if accountSelected || routingSelected { // for empty cell height
                                return 0
                            } else {
                                return self.emptyCellHeight >= 0 ? self.emptyCellHeight : 0
                            }
                        }
                        else {
                            return rowHeightForAutoPay                    //For AutoPayCheckBox view
                        }
                } else {
                    return self.returnDefaultRowHeightType(row: indexPath.row)
                }
                
                /*
                if currentScreenHeight <= 667 {
                    if indexPath.row == 0 {   //For Name view
                        return rowHeightForAccountName
                    } else if indexPath.row == 1 {   //For Routing view
                        return rowHeightForRouting
                    } else if indexPath.row == 2 {   //For Acc. Number view
                        return rowHeightForAccount
                    } else if indexPath.row == 3 {   //For Nickname view
                        return rowHeightForNickName
                    } else {
                        return rowHeightForAutoPay
                    }
                } else {
                    if indexPath.row == 0 {   //For Name view
                        return rowHeightForAccountName
                    } else if indexPath.row == 1 {   //For Routing view
                        return rowHeightForRouting
                    } else if indexPath.row == 2 {   //For Acc. Number view
                        return rowHeightForAccount
                    } else if indexPath.row == 3 {
                        return rowHeightForNickName                    //For Nickname view
                    } else if indexPath.row == 4 {
                        return rowHeightForAutoPay                    //For Nickname view
                    }
                    else {
                        if accountSelected || routingSelected { // for empty cell height
                            return 0
                        } else {
                            return self.emptyCellHeight >= 0 ? self.emptyCellHeight : 0
                        }
                    }
                }
                 */
            default:
                return self.returnDefaultRowHeightType(row: indexPath.row)
            }
            
            /*
            if flow == .managePayments(_) && QuickPayManager.shared.isAutoPayEnabled() { //CMAIOS-2858
                if currentScreenHeight <= 667 {
                    if indexPath.row == 0 {   //For Name view
                        return rowHeightForAccountName
                    } else if indexPath.row == 1 {   //For Routing view
                        return rowHeightForRouting
                    } else if indexPath.row == 2 {   //For Acc. Number view
                        return rowHeightForAccount
                    } else if indexPath.row == 3 {   //For Nickname view
                        return rowHeightForNickName
                    } else {
                        return rowHeightForAutoPay
                    }
                } else {
                    if indexPath.row == 0 {   //For Name view
                        return rowHeightForAccountName
                    } else if indexPath.row == 1 {   //For Routing view
                        return rowHeightForRouting
                    } else if indexPath.row == 2 {   //For Acc. Number view
                        return rowHeightForAccount
                    } else if indexPath.row == 3 {
                        return rowHeightForNickName                    //For Nickname view
                    } else if indexPath.row == 4 {
                        //CMAIOS-2860
                        if accountSelected || routingSelected { // for empty cell height
                            return 0
                        } else {
                            return self.emptyCellHeight >= 0 ? self.emptyCellHeight : 0
                        }
                    }
                    else {
                        return rowHeightForAutoPay //CMAIOS-2860
                    }
                }
            } else {
                if currentScreenHeight <= 667 {
                    if indexPath.row == 0 {   //For Name view
                        return rowHeightForAccountName
                    } else if indexPath.row == 1 {   //For Routing view
                        return rowHeightForRouting
                    } else if indexPath.row == 2 {   //For Acc. Number view
                        return rowHeightForAccount
                    } else {   //For Nickname view
                        return 201
                    }
                } else {
                    if indexPath.row == 0 {   //For Name view
                        return rowHeightForAccountName
                    } else if indexPath.row == 1 {   //For Routing view
                        return rowHeightForRouting
                    } else if indexPath.row == 2 {   //For Acc. Number view
                        return rowHeightForAccount
                    } else if indexPath.row == 3 {
                        return 201                    //For Nickname view
                    }
                    else {
                        if accountSelected || routingSelected { // for empty cell height
                            return 0
                        } else {
                            return self.emptyCellHeight >= 0 ? self.emptyCellHeight : 0
                        }
                    }
                }
            }
             */
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch isFromMakePaymentFlow {
        case true:
                if indexPath.row == 0 {
                    return accountNameCell()
                } else if indexPath.row == 1 {
                    return routingNumberCell(indexPath)
                } else if indexPath.row == 2 {
                    return accountNumberCell(indexPath)
                } else if indexPath.row == 3 {
                    return saveCheckboxCell()
                } else if indexPath.row == 4 {
                    return nickNameCell()
                } else if indexPath.row == 5 { // Added Empty cell to align continue and T&C lable to bottom
                    let cell = self.achTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                    return cell
                } else {
                    return termsAndConditionsCell()
                }
        default:
            switch flow {
            case .managePayments(let editAutoAutoPayFlow):
                if !editAutoAutoPayFlow && (QuickPayManager.shared.isAutoPayEnabled() == true) { //CMAIOS-2841
                        if indexPath.row == 0 {
                            return accountNameCell()
                        } else if indexPath.row == 1 {
                            return routingNumberCell(indexPath)
                        } else if indexPath.row == 2 {
                            return accountNumberCell(indexPath)
                        } else if indexPath.row == 3{
                            return nickNameCell()
                        } else if indexPath.row == 4 {
                            //CMAIOS-2860
                            let cell = self.achTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                            return cell
                        } else {  //CMAIOS-2860
                            return autoPayCell()
                        }
                } else {
                    return self.returnDefaultCellType(indexPath: indexPath)
                }
            default:
                return self.returnDefaultCellType(indexPath: indexPath)
            }
            
            /*
            if flow == .managePayments && QuickPayManager.shared.isAutoPayEnabled() { //CMAIOS-2858
                if currentScreenHeight <= 667 {
                    if indexPath.row == 0 {
                        return accountNameCell()
                    } else if indexPath.row == 1 {
                        return routingNumberCell(indexPath)
                    } else if indexPath.row == 2 {
                        return accountNumberCell(indexPath)
                    } else if indexPath.row == 3 {
                        return nickNameCell()
                    } else if indexPath.row == 4 {
                        return autoPayCell()
                    }
                } else {
                    if indexPath.row == 0 {
                        return accountNameCell()
                    } else if indexPath.row == 1 {
                        return routingNumberCell(indexPath)
                    } else if indexPath.row == 2 {
                        return accountNumberCell(indexPath)
                    } else if indexPath.row == 3{
                        return nickNameCell()
                    } else if indexPath.row == 4 {
                        let cell = self.achTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                        return cell
                    } else {
                        return autoPayCell()
                        
                    }
                }
            } else {
                if currentScreenHeight <= 667 {
                    if indexPath.row == 0 {
                        return accountNameCell()
                    } else if indexPath.row == 1 {
                        return routingNumberCell(indexPath)
                    } else if indexPath.row == 2 {
                        return accountNumberCell(indexPath)
                    } else if indexPath.row == 3 {
                        return nickNameCell()
                    }
                } else {
                    if indexPath.row == 0 {
                        return accountNameCell()
                    } else if indexPath.row == 1 {
                        return routingNumberCell(indexPath)
                    } else if indexPath.row == 2 {
                        return accountNumberCell(indexPath)
                    } else if indexPath.row == 3{
                        return nickNameCell()
                    } else {
                        let cell = self.achTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
                        return cell
                    }
                }
            }
             */
        }
    }
    
    func accountNameCell() -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "NameCheckTableViewCell") as! NameCheckTableViewCell
        cell.accountNameDelegate = self
        cell.nameCheckTxtFld.text = accountName
        if !isAccountNameWarning {
            cell.warningLabel.isHidden = true
            cell.nameCheckTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
        } else {
            cell.warningLabel.isHidden = false
            cell.nameCheckTxtFld.setBorderColor(mode: BorderColor.error_color)
        }
        return cell
    }
    
    func routingNumberCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "RoutingAccountCell") as! RoutingAccountTableViewCell
        cell.iconSelectionView.tag = indexPath.row
        cell.selectedRow = indexPath.row
        cell.routingDelegate = self
        cell.routingView.isHidden = false
        cell.routingNumberTextField.text = routingNumber
        cell.getBankingImageForNumber(number: routingNumber)
        //CMA-2450
        //cell.routBankImg.image = bankImg
        cell.routBankImg.image = UIImage(named: "routingBorderImage")
        if isWarningShownForRouting {
            cell.warningLabel.isHidden = false
            cell.warningLabel.text = "Routing number must be 9 digits"
            cell.routingNumberTextField.setBorderColor(mode: BorderColor.error_color)
            if routingSelected {
                cell.routerNumberHelpView.isHidden = false
                cell.topViewToTextfieldConstraint.constant = -20
                cell.iconImageView.image = UIImage(named: "iconInfoSelected") ?? UIImage()
                cell.routerNumberImageView.image = UIImage(named: "routingNumberIdentifier") ?? UIImage()
                cell.contentView.bringSubviewToFront(cell.warningLabel)
            } else {
                cell.routerNumberHelpView.isHidden = true
                cell.iconImageView.image = UIImage(named: "iconInfo") ?? UIImage()
            }
        } else {
            cell.warningLabel.isHidden = true
            cell.routingNumberTextField.setBorderColor(mode: BorderColor.deselcted_color)
            if routingSelected {
                cell.routerNumberHelpView.isHidden = false
                cell.topViewToTextfieldConstraint.constant = -27
                cell.iconImageView.image = UIImage(named: "iconInfoSelected") ?? UIImage()
                cell.routerNumberImageView.image = UIImage(named: "routingNumberIdentifier") ?? UIImage()
            } else {
                cell.routerNumberHelpView.isHidden = true
                cell.iconImageView.image = UIImage(named: "iconInfo") ?? UIImage()
            }
        }
        cell.leadingToRoutingViewConstraint.priority = UILayoutPriority(999)
        cell.leadingToSuperViewConstraint.priority = UILayoutPriority(200)
        cell.routingNumberTextField.attributedPlaceholder = NSAttributedString(string: "Routing number")
        cell.iconSelectionView.addTarget(self, action: #selector(iconSelectionAction(sender:)), for: .touchUpInside)
        return cell
    }
    
    func accountNumberCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "RoutingAccountCell") as! RoutingAccountTableViewCell
        cell.routingView.isHidden = true
        cell.iconSelectionView.tag = indexPath.row
        cell.selectedRow = indexPath.row
        cell.routingNumberTextField.text = accountNumber
        if isWarningShownForAccount {
            cell.warningLabel.isHidden = false
            cell.warningLabel.text = "Account number must be 4-17 digits"
            cell.routingNumberTextField.setBorderColor(mode: BorderColor.error_color)
            if accountSelected {
                cell.routerNumberHelpView.isHidden = false
                cell.topViewToTextfieldConstraint.constant = -20
                cell.iconImageView.image = UIImage(named: "iconInfoSelected") ?? UIImage()
                cell.routerNumberImageView.image = UIImage(named: "accountNumberIdentifier") ?? UIImage()
                cell.contentView.bringSubviewToFront(cell.warningLabel)
            } else {
                cell.routerNumberHelpView.isHidden = true
                cell.iconImageView.image = UIImage(named: "iconInfo") ?? UIImage()
            }
        } else {
            cell.warningLabel.isHidden = true
            cell.routingNumberTextField.setBorderColor(mode: BorderColor.deselcted_color)
            if accountSelected {
                cell.routerNumberHelpView.isHidden = false
                cell.topViewToTextfieldConstraint.constant = -27
                cell.iconImageView.image = UIImage(named: "iconInfoSelected") ?? UIImage()
                cell.routerNumberImageView.image = UIImage(named: "accountNumberIdentifier") ?? UIImage()
            } else {
                cell.routerNumberHelpView.isHidden = true
                cell.iconImageView.image = UIImage(named: "iconInfo") ?? UIImage()
            }
        }
        cell.routingDelegate = self
        cell.leadingToRoutingViewConstraint.priority = UILayoutPriority(200)
        cell.leadingToSuperViewConstraint.priority = UILayoutPriority(999)
        cell.routingNumberTextField.attributedPlaceholder = NSAttributedString(string: "Account number")
        cell.iconSelectionView.addTarget(self, action: #selector(iconSelectionAction(sender:)), for: .touchUpInside)
        return cell
    }
    
    func saveCheckboxCell() -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "SavePayToAccountTableViewCell") as! SavePayToAccountTableViewCell
        cell.btnSavePayChckBox.addTarget(self, action: #selector(saveCheckboxTapped(sender:)), for: .touchUpInside)
        return cell
    }
    
    func autoPayCell() -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "EnableAutoPayTableViewCell") as! EnableAutoPayTableViewCell
        cell.btnAutoPayCheckBox.addTarget(self, action: #selector(autoPayCheckBoxTapped(sender:)), for: .touchUpInside)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.2
        cell.lbltitle.attributedText = NSMutableAttributedString(string: "Use this payment method for Auto Pay", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        cell.lblSubtitle.attributedText = NSMutableAttributedString(string: "We will use this payment method for Auto Pay starting with your next bill.", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return cell
    }
    
    func nickNameCell() -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "AddNicknameTableViewCell") as! AddNicknameTableViewCell
        cell.nicknameTxtFld.text = nickName
        if self.isFromMakePaymentFlow {
            if !isSaveBtnTapped {
                cell.nicknameView.isHidden = true
                cell.nicknameErrLbl.isHidden = true
                cell.nicknameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            } else {
                cell.nicknameView.isHidden = false
                cell.isSaveBtnTapped = true
                if !isNickNameWarning {
                    cell.nicknameErrLbl.isHidden = true
                    cell.nicknameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
                } else {
                    cell.nicknameErrLbl.isHidden = false
                    cell.nicknameTxtFld.setBorderColor(mode: BorderColor.error_color)
                }
            }
        } else {
            cell.nicknameView.isHidden = false
            cell.isSaveBtnTapped = true
            if !isNickNameWarning {
                cell.nicknameErrLbl.isHidden = true
                cell.nicknameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            } else {
                cell.nicknameErrLbl.isHidden = false
                cell.nicknameTxtFld.setBorderColor(mode: BorderColor.error_color)
            }
        }
        cell.nickNameDelegate = self
        return cell
    }
    
    func termsAndConditionsCell() -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "AddCheckSaveAndTermsTableViewCell") as! AddCheckSaveAndTermsTableViewCell
        if isTermsWarning {
            cell.lblErrorMsg.isHidden = false
        } else {
            cell.lblErrorMsg.isHidden = true
        }
        cell.btnTermsConditionCheckBox.addTarget(self, action: #selector(termsAndCondCheckBoxTapped(sender:)), for: .touchUpInside)
        
        let text = "I have read and agree to the Pay Bill Terms and Conditions"
        let tappableText = "Pay Bill Terms and Conditions"
        let linkText = NSMutableAttributedString(string: text, attributes: [.font: UIFont(name: "Regular-Bold", size: 18)!])
        let moreInfo = (text as NSString).range(of: tappableText)
        linkText.addAttribute(.foregroundColor, value: UIColor(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0), range: moreInfo)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        linkText.addAttributes([.paragraphStyle: paragraphStyle], range: ((linkText.string) as NSString).range(of: linkText.string))
        cell.lblTermsAndCond.attributedText = linkText
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnText(_:)))
        tapgesture.numberOfTapsRequired = 1
        cell.lblTermsAndCond.addGestureRecognizer(tapgesture)
        
        return cell
    }
    
    /*
    func continueButtonCell() -> UITableViewCell {
        let cell = self.achTableView.dequeueReusableCell(withIdentifier: "AddAcountContinueBtnTableViewCell") as! AddAcountContinueBtnTableViewCell
        if isFromMakePaymentFlow {
            cell.continueBtn.setTitle("Continue", for: .normal)
        }else {
            cell.continueBtn.setTitle("Save and continue", for: .normal)
        }
        cell.continueBtn.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        return cell
    }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc func tappedOnText(_ gesture: UITapGestureRecognizer) {
        let TandCLabelIndex = self.indexSelection()
        guard let termsCell = self.achTableView.cellForRow(at: IndexPath(row: TandCLabelIndex, section: 0)) as? AddCheckSaveAndTermsTableViewCell else {
            return
        }
        guard gesture.didTapTermsAndConditions(label: termsCell.lblTermsAndCond, targetText: "Pay Bill Terms and Conditions"), let url = URL(string: TOS_URL) else {
            return
        }
        DispatchQueue.main.async {
            let safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .overFullScreen
            self.present(safari, animated: true, completion: nil)
        }
    }
    
    func reloadRoutingTableCell(_ selectedRow: Int, isWarningShown: Bool) {
        guard let cell = self.achTableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? RoutingAccountTableViewCell else {
            return
        }
        if selectedRow == 1 {
            isWarningShownForRouting = isWarningShown
            if isWarningShown {
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    if routingSelected {
                        cell.topViewToTextfieldConstraint.constant = -20
                    } else {
                        rowHeightForRouting = 98.0
                        self.calculateEmptyCellHeight()
                    }
                    self.achTableView.endUpdates()
                }
            } else {
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    if routingSelected {
                        cell.topViewToTextfieldConstraint.constant = -27
                    } else {
                        rowHeightForRouting = 78.0
                        self.calculateEmptyCellHeight()
                    }
                    self.achTableView.endUpdates()
                }
            }
        } else if selectedRow == 2 {
            isWarningShownForAccount = isWarningShown
            if isWarningShown {
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    if accountSelected {
                        cell.topViewToTextfieldConstraint.constant = -20
                    } else {
                        rowHeightForAccount = 98.0
                        self.calculateEmptyCellHeight()
                    }
                    self.achTableView.endUpdates()
                }
            } else {
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    if accountSelected {
                        cell.topViewToTextfieldConstraint.constant = -27
                    } else {
                        rowHeightForAccount = 78.0
                        self.calculateEmptyCellHeight()
                    }
                    self.achTableView.endUpdates()
                }
            }
        }
    }
    
    func reloadAccountNameTableCell(isWarningShown: Bool) {
        isAccountNameWarning = isWarningShown
        if isWarningShown {
            UIView.performWithoutAnimation {
                self.achTableView.beginUpdates()
                rowHeightForAccountName =  168.0
                self.calculateEmptyCellHeight()
                self.achTableView.endUpdates()
            }
        } else {
            UIView.performWithoutAnimation {
                self.achTableView.beginUpdates()
                rowHeightForAccountName = 148.0
                self.calculateEmptyCellHeight()
                self.achTableView.endUpdates()
            }
        }
    }
    
    func nickNameTableCell(isWarningShown: Bool) {
        isNickNameWarning = isWarningShown
        if isWarningShown {
            UIView.performWithoutAnimation {
                self.achTableView.beginUpdates()
                rowHeightForNickName = 100
                self.calculateEmptyCellHeight()
                self.achTableView.endUpdates()
            }
        } else {
            UIView.performWithoutAnimation {
                self.achTableView.beginUpdates()
                rowHeightForNickName = 62.0
                self.calculateEmptyCellHeight()
                self.achTableView.endUpdates()
            }
        }
    }
    
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: "bankCheckVal")
        if(buttonType == BarButtonType.back) {
            self.navigationController?.popViewController(animated: false)
        } else {
            if let presentingVC = self.presentingViewController, presentingVC.children.contains(where: { $0 is HomeScreenViewController }) {
                if let setupAutoPayViewController = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC { //CMAIOS-2882
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(setupAutoPayViewController, animated: true)
                    }
                } else {
                    self.dismiss(animated: true)
                }
                /*
                self.dismiss(animated: true)
                 */
            } else if let managedPayments = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController { //CMAIOS-2765
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(managedPayments, animated: true)
                }
            } else if let billPreferenceVC = self.navigationController?.viewControllers.filter({$0 is BillingPreferencesViewController}).first as? BillingPreferencesViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billPreferenceVC, animated: true)
                }
            } else if let setupView = self.navigationController?.viewControllers.filter({$0 is SetUpAutoPayPaperlessBillingVC}).first as? SetUpAutoPayPaperlessBillingVC { //CMAIOS-2765
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(setupView, animated: true)
                }
            } else if let billingPayController = self.navigationController?.viewControllers.filter({$0 is BillingPaymentViewController}).first as? BillingPaymentViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(billingPayController, animated: true)
                }
            } else {
                self.navigationController?.dismiss(animated: false)
            }
        }
    }
    
    func saveRoutingCellValue(_ selectedRow: Int, value: String) {
        if selectedRow == 1 {
            routingNumber = value
        } else if selectedRow == 2 {
            accountNumber = value
        }
    }
    
    //CMA-2450
    /*func saveBankImgFieldData(_ value: UIImage) {
       bankImg = value
    }*/
    
    func checkNicknameValidation(_ value: String) {
        if (isFromMakePaymentFlow && !(isNickNameEdited)) {
            guard let nicknameCell = self.achTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? AddNicknameTableViewCell else {
                return
            }
            if QuickPayManager.shared.checkingNameExists(newName: self.nickName) {
                nicknameCell.nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)        }
        } else {
            guard let nicknameCell = self.achTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? AddNicknameTableViewCell else {
                return
            }
            if QuickPayManager.shared.checkingNameExists(newName: self.nickName) {
                nicknameCell.nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)        }
        }
    }
    
    func saveNickNameFieldData(_ value: String) {
        isNickNameWarning = false
        if (isFromMakePaymentFlow && !(isNickNameEdited)) {
            guard let nicknameCell = self.achTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? AddNicknameTableViewCell else {
                return
            }
            if ((!(value.count == 0) && (accountNumber.count > 3)) && !(value.contains("-"))){
                nicknameCell.nicknameTxtFld.text = value.prefix(8) + "-" + accountNumber.suffix(4)
            } else { //CMAIOS-2171
                nicknameCell.nicknameTxtFld.text = value
            }
            nicknameCell.nicknameErrLbl.isHidden = true
            nicknameCell.nicknameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            saveNickNameValue(nicknameCell.nicknameTxtFld.text ?? "", isNickNameEdit: false)
            if QuickPayManager.shared.checkingNameExists(newName: nicknameCell.nicknameTxtFld.text ?? "") {
                nicknameCell.nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)
            }
        } else if !(isNickNameEdited) { //CMAIOS-2171
            guard let nicknameCell = self.achTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? AddNicknameTableViewCell else {
                return
            }
            if ((!(value.count == 0) && (accountNumber.count > 3)) && !(value.contains("-"))){
                nicknameCell.nicknameTxtFld.text = value.prefix(8) + "-" + accountNumber.suffix(4)
            }else {
                nicknameCell.nicknameTxtFld.text = value
            }
            nicknameCell.nicknameErrLbl.isHidden = true
            nicknameCell.nicknameTxtFld.setBorderColor(mode: BorderColor.deselcted_color)
            saveNickNameValue(nicknameCell.nicknameTxtFld.text ?? "", isNickNameEdit: false)
            var calculatedRowHeight = 62.0
            if QuickPayManager.shared.checkingNameExists(newName: nicknameCell.nicknameTxtFld.text ?? "") {
                nicknameCell.nickNameDisplay(errMsg: "One of your payment methods is already using this nickname.", needToHide: false)
                calculatedRowHeight = 100.0
            }
            UIView.performWithoutAnimation {
                self.achTableView.beginUpdates()
                rowHeightForNickName = calculatedRowHeight
                self.calculateEmptyCellHeight()
                self.achTableView.endUpdates()
            }
        }
    }
    
    func saveAccountNameValue(_ value: String) {
        accountName = value
    }
    
    func saveNickNameValue(_ value: String, isNickNameEdit: Bool) {
        nickName = value
        isNickNameEdited = isNickNameEdit
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        //Account Name
        self.view.endEditing(true)
        DispatchQueue.main.async {
            //Account Name
            if self.accountName.isEmpty {
                self.isValidationSuccess = false
                self.isAccountNameWarning = true
                self.rowHeightForAccountName = 168.0
            } else {
                self.isValidationSuccess = true
                self.isAccountNameWarning = false
                self.rowHeightForAccountName = 148.0
            }
            
            //Routing Number
            if self.routingNumber.count < 9 {
                self.isValidationSuccess = false
                self.isWarningShownForRouting = true
                if !self.routingSelected {
                    self.rowHeightForRouting = 98.0
                } else {
                    self.rowHeightForRouting = 368.0
                }
            } else {
                self.isValidationSuccess = self.isValidationSuccess ? true : false
                self.isWarningShownForRouting = false
                if !self.routingSelected {
                    self.rowHeightForRouting = 77.0
                } else {
                    self.rowHeightForRouting = 368.0
                }
            }
            
            //Account Number
            if self.accountNumber.count < 4 {
                self.isWarningShownForAccount = true
                self.isValidationSuccess = false
                if !self.accountSelected {
                    self.rowHeightForAccount = 98.0
                } else {
                    self.rowHeightForAccount = 368.0
                }
            } else {
                self.isWarningShownForAccount = false
                self.isValidationSuccess = self.isValidationSuccess ? true : false
                if !self.accountSelected {
                    self.rowHeightForAccount = 77.0
                } else {
                    self.rowHeightForAccount = 368.0
                }
            }
            
            //Nickname
            if self.isFromMakePaymentFlow {
                if self.isSaveBtnTapped {
                    if ((self.nickName.removeFormatSpaces.isEmpty) || (self.nickName.hasSuffix(" ") == true || self.nickName.hasPrefix(" ") == true)) { //CMAIOS-2176, when we tapped on continue err msg should display accordingly.
                        self.isValidationSuccess = false
                        self.isNickNameWarning = true
                        self.rowHeightForNickName = 82.0
                    } else if QuickPayManager.shared.checkingNameExists(newName: self.nickName) {
                        self.isValidationSuccess = false
                        self.isNickNameWarning = true
                        self.rowHeightForNickName = 100.0
                    } else {
                        self.isValidationSuccess = self.isValidationSuccess ? true : false
                        self.isNickNameWarning = false
                        self.rowHeightForNickName = 62.0
                    }
                } else {
                    self.isValidationSuccess = self.isValidationSuccess ? true : false
                }
                
                if !self.isTermsTapped {
                    self.isValidationSuccess = false
                    self.isTermsWarning = true
                    self.rowHeightForTerms = 140.0
                } else {
                    self.isTermsWarning = false
                    self.isValidationSuccess = self.isValidationSuccess ? true : false
                    self.rowHeightForTerms = 103.0
                }
            } else {
                if ((self.nickName.removeFormatSpaces.isEmpty) || (self.nickName.hasSuffix(" ") == true || self.nickName.hasPrefix(" ") == true)) { //CMAIOS-2176, when we tapped on continue err msg should display accordingly.
                    self.isValidationSuccess = false
                    self.isNickNameWarning = true
                    self.rowHeightForNickName = 82.0
                    self.rowHeightForTerms = 82
                } else if QuickPayManager.shared.checkingNameExists(newName: self.nickName) {
                    self.isValidationSuccess = false
                    self.isNickNameWarning = true
                    self.rowHeightForNickName = 100.0
                    self.rowHeightForTerms = 82
                } else {
                    self.isValidationSuccess = self.isValidationSuccess ? true : false
                    self.isNickNameWarning = false
                    self.rowHeightForNickName = 62.0
                    self.rowHeightForTerms = 82
                }
            }
            self.calculateEmptyCellHeight(isReloadNeeded: true)
            if self.isValidationSuccess {
                self.addCheckingAccount()
                let userDefault = UserDefaults.standard
                userDefault.removeObject(forKey: "bankCheckVal")
            }
        }
    }
    
    @objc func saveCheckboxTapped(sender: UIControl) {
        guard let nicknameCell = self.achTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? AddNicknameTableViewCell else {
            return
        }
        guard let saveCell = self.achTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SavePayToAccountTableViewCell else {
            return
        }
        if isSaveBtnTapped {
            isSaveBtnTapped = false
            nicknameCell.isSaveBtnTapped = isSaveBtnTapped
            nicknameCell.nicknameView.isHidden = true
            nicknameCell.nicknameTxtFld.setBorderColor(mode: .deselcted_color)
            nicknameCell.nicknameErrLbl.isHidden = true
            UIView.performWithoutAnimation {
                self.achTableView.beginUpdates()
                rowHeightForNickName = 62.0
                self.achTableView.endUpdates()
            }
            saveCell.btnSavePayChckBox.setImage(UIImage(named: "unselected-check"), for: .normal)
            
        } else {
            isSaveBtnTapped = true
            nicknameCell.isSaveBtnTapped = isSaveBtnTapped
            nicknameCell.nicknameTxtFld.setBorderColor(mode: .deselcted_color)
            nicknameCell.nicknameErrLbl.isHidden = true
            nicknameCell.nicknameView.isHidden = false
            saveCell.btnSavePayChckBox.setImage(UIImage(named: "selected-check"), for: .normal)
        }
    }
    // for index selection depending on screen size
    func indexSelection() -> Int {
        var index = 0
        if isFromMakePaymentFlow {
           index = 6
        } else {
           //CMAIOS-2860 Updated the index for LFF and SFF devices //CMAIOS-2858
            switch flow {
            case .managePayments(let editAutoAutoPayFlow):
                if !editAutoAutoPayFlow && (QuickPayManager.shared.isAutoPayEnabled() == true) { //CMAIOS-2841
                    index =  5
                } else {
                    index =  5
                }
            default:
                index =  5
            }
        }
        return index
    }
    
    @objc func termsAndCondCheckBoxTapped(sender: UIControl) {
        let selectedIndex = self.indexSelection()
        guard let termsCell = self.achTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? AddCheckSaveAndTermsTableViewCell else {
            return
        }
        if isTermsTapped {
            isTermsWarning = true
            isTermsTapped = false
            termsCell.btnTermsConditionCheckBox.setImage(UIImage(named: "unselected-check"), for: .normal)
        } else {
            isTermsWarning = false
            isTermsTapped = true
            if !termsCell.lblErrorMsg.isHidden {
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    termsCell.lblErrorMsg.isHidden = true
                    rowHeightForTerms = 103.0
                    self.calculateEmptyCellHeight()
                    self.achTableView.endUpdates()
                }
            }
            termsCell.btnTermsConditionCheckBox.setImage(UIImage(named: "selected-check"), for: .normal)
        }
    }
    
    @objc func autoPayCheckBoxTapped(sender: UIButton) {
        let selectedIndex = self.indexSelection()
        guard let autoPayCell = self.achTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? EnableAutoPayTableViewCell else {
            return
        }
        if isAutoPayCheckBoxTapped {
            isAutoPayCheckBoxTapped = false
            autoPayCell.btnAutoPayCheckBox.setImage(UIImage(named: "unselected-check"), for: .normal)
        } else {
            isAutoPayCheckBoxTapped = true
            autoPayCell.btnAutoPayCheckBox.setImage(UIImage(named: "selected-check"), for: .normal)
        }
    }
    
    @objc func iconSelectionAction(sender: UIControl) {
        guard let cell = self.achTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? RoutingAccountTableViewCell else {
            return
        }
        if sender.tag == 1 {
            if !routingSelected {
                routingSelected = true
                cell.routerNumberHelpView.isHidden = false
                cell.routerNumberImageView.image = UIImage(named: "routingNumberIdentifier") ?? UIImage()
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    rowHeightForRouting = 368.0
                    self.calculateEmptyCellHeight()
                    if isWarningShownForRouting {
                        cell.topViewToTextfieldConstraint.constant = -20
                    } else {
                        cell.topViewToTextfieldConstraint.constant = -27
                    }
                    cell.iconImageView.image = UIImage(named: "iconInfoSelected") ?? UIImage()
                    cell.contentView.bringSubviewToFront(cell.warningLabel)
                    self.achTableView.endUpdates()
                }
               // routingSelected = true
            } else {
                cell.routerNumberHelpView.isHidden = true
                routingSelected = false
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    if isWarningShownForRouting {
                        rowHeightForRouting = 98.0
                    } else {
                        rowHeightForRouting = 78.0
                    }
                    self.calculateEmptyCellHeight()
                    cell.iconImageView.image = UIImage(named: "iconInfo") ?? UIImage()
                    self.achTableView.endUpdates()
                }
                //routingSelected = false
            }
        } else if sender.tag == 2 {
            if !accountSelected {
                accountSelected = true
                cell.routerNumberHelpView.isHidden = false
                cell.routerNumberImageView.image = UIImage(named: "accountNumberIdentifier") ?? UIImage()
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    rowHeightForAccount = 368.0
                    self.calculateEmptyCellHeight()
                    if isWarningShownForAccount {
                        cell.topViewToTextfieldConstraint.constant = -20
                    } else {
                        cell.topViewToTextfieldConstraint.constant = -27
                    }
                    cell.iconImageView.image = UIImage(named: "iconInfoSelected") ?? UIImage()
                    cell.contentView.bringSubviewToFront(cell.warningLabel)
                    self.achTableView.endUpdates()
                }
                //accountSelected = true
            } else {
                cell.routerNumberHelpView.isHidden = true
                accountSelected = false
                UIView.performWithoutAnimation {
                    self.achTableView.beginUpdates()
                    if isWarningShownForAccount {
                        rowHeightForAccount = 98.0
                    } else {
                        rowHeightForAccount = 78.0
                    }
                    self.calculateEmptyCellHeight()
                    cell.iconImageView.image = UIImage(named: "iconInfo") ?? UIImage()
                    self.achTableView.endUpdates()
                }
                //accountSelected = false
            }
        }
    }
}

extension AddCheckingAccountViewController {
    /// Generate json parameter to create bank account paymethod
    /// - Returns: updated json paramerters
    private func generateJsonParam() -> (jsonParm: [String: AnyObject], bankAccPayMethod: BankEftPayMethod) {
//        let maskedAccountNumber = PGPCryptoUtility.cardEncryption(cardNumber: "test123")
        var jsonParams = [String: AnyObject]()
        let bankAccDict = BankEftPayMethod(nameOnAccount: self.accountName,
                                           maskedBankAccountNumber: self.accountNumber,
                                           routingNumber: self.routingNumber,
                                           accountType: "BANK_ACCOUNT_TYPE_CHECKING")
        let bankAccountInfo = BankAccout(newNickname: self.nickName, bankEftPayMethod: bankAccDict)
        do {
            let jsonData = try JSONEncoder().encode(bankAccountInfo)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))")}
        return (jsonParams, bankAccDict)
    }
    
    // Bank Checking account pay method creation test method, should be move to respective screen once the new UI has been designed
    /// Creating new Bank Checking Pay Method
    private func createCheckingAccountPaymethod(isDefault: Bool = false) {
        let parms = generateJsonParam()
        let jsonParams = parms.0
        if jsonParams.isEmpty {
            return
        }
        DispatchQueue.main.async {
            self.continueButtonAnimation()
        }
        self.paymentCreationIsProgress = true
        QuickPayManager.shared.mauiCreateBankPaymethod(jsonParams: jsonParams, isDefault: isDefault) { isSuccess, errorDesc, error in
            if isSuccess {
                if QuickPayManager.shared.modelQuickPayCreateBankAccount?.responseInfo?.statusCode == "00000" {
                    self.processCreatePaymentReponse(checkingInfo: parms.1, isDefault: isDefault)
                } else {
                    self.paymethodCreationFailedAnimation()
                    self.showErrorMsgOnPaymentFailure()
                }
            } else {
                self.paymethodCreationFailedAnimation()
                self.showErrorMsgOnPaymentFailure()
            }
        }
    }
    
    //CMAIOS-2712
    private func mauiCreateAutoPay() {
        guard let jsonParam = generateParamAsPerFlow(), !jsonParam.isEmpty else {
            self.paymethodCreationFailedAnimation()
            self.showErrorMsgOnPaymentFailure()
            return
        }
        APIRequests.shared.mauiCreateAutoPayRequest(interceptor: QuickPayManager.shared.interceptor, param: jsonParam, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Create AutoPay is \(String(describing: value))", sendLog: "Create AutoPay success")
                    self.refreshGetAccountBill()
                } else {
                    self.paymethodCreationFailedAnimation()
                    Logger.info("Create AutoPay is \(String(describing: error))")
                    self.showErrorMsgOnPaymentFailure()
                }
            }
        })
    }
    
    /// refresh  mauiGetAccountBillRequest to get paymethods list
    private func refreshGetAccountBill() {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: QuickPayManager.shared.interceptor, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    Logger.info("Refresh Get Account Bill is \(String(describing: value))", sendLog: "Refresh Get Account Bill success")
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                }
                self.paymentCreationIsProgress = false
                self.continueAnimationView.pause()
                self.continueAnimationView.play(fromProgress: self.continueAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                    self.paymethodCreationFailedAnimation()
                    self.navigateToAllSet() // Uncomment the above lines for actual flow, this line for mock validation
                }
            }
        })
    }
    
    private func navigateToAllSet() {
        guard let viewcontroller = AutoPayAllSetViewController.instantiateWithIdentifier(from: .payments) else { return }
        // CMAIOS:- 2549
//        viewcontroller.allSetType = isAutoPay ? (isAutoPayTurnOnFlow() ? .turnOnAutoPay:  .newAutoPay) : .paperlessBilling
        viewcontroller.allSetType = .turnOnAutoPaySP
        
        if let autoPayMethod = QuickPayManager.shared.getDefaultAutoPaymentMethod() {
            viewcontroller.payMethod = autoPayMethod
        }
        guard let navigationControl =  self.navigationController else {
            viewcontroller.modalPresentationStyle = .fullScreen
            viewcontroller.navigationController?.navigationBar.isHidden = false
            self.present(viewcontroller, animated: true)
            return
        }
        navigationControl.navigationBar.isHidden = true
        navigationControl.pushViewController(viewcontroller, animated: true)
    }
    
    private func generateJsonParamForAutoPay() -> [String: AnyObject]? {
        var jsonParams: [String: AnyObject]?
        guard let paymethodName = self.getPaymethodNameForAutoPay() else {
            return jsonParams
        }
        let payMethod = PayMethodInfo(name: paymethodName)
        let autopay = CreatAutoPay.AutoPay(payMethod: payMethod)
        let createAutoPay = CreatAutoPay(parent: QuickPayManager.shared.getAccountName(), autoPay: autopay)
        do {
            let jsonData = try JSONEncoder().encode(createAutoPay)
            jsonParams = CommonUtility.getEncodedJsonParam(jsonData: jsonData)
        } catch { Logger.info("\(String(describing: error))") }
        return jsonParams
    }
    
    private func generateParamAsPerFlow() -> [String: AnyObject]? {
        return generateJsonParamForAutoPay()
    }
    
    private func getPaymethodNameForAutoPay() -> String? {
        if let paymethodName = QuickPayManager.shared.getPaymethodNameForAutoPaySetup() {
            return paymethodName
        }
        return nil
    }
    
    private func addCheckingAccount() {
        switch self.flow {
        case .noPayments:
            if isSaveBtnTapped {
                createCheckingAccountPaymethod(isDefault: true)
            } else {
                self.moveToMakePayment()
            }
        case .addCard:
            if isFromMakePaymentFlow {
                if isSaveBtnTapped {
                    createCheckingAccountPaymethod(isDefault: cardExpiryFlow == .onlyDefaultExpired ? true : false)
                } else {
//                    self.updatePayMethodToLocalDict() //CMAIOS-2161 & CMAIOS-2162
                    if cardExpiryFlow == .onlyDefaultExpired {
                        self.moveToMakePaymentForExpiryFlow()
                    } else
                    {
                        self.updatePayMethodToLocalDict() //CMAIOS-2161 & CMAIOS-2162
                        self.moveToHomeViewController()
                    }
                }
            } else {
                createCheckingAccountPaymethod(isDefault: false)
            }
        case .paymentFailure: break
//            self.moveToMakePayment()
        case .autopay, .autopayFromSP, .appbNotEnrolled:
            createCheckingAccountPaymethod(isDefault: true)
        case .managePayments:
            if isSaveBtnTapped {
                createCheckingAccountPaymethod(isDefault: true)
            } else {
                createCheckingAccountPaymethod(isDefault: false)
            }
        case .editAutoPay:
            if isSaveBtnTapped {
                createCheckingAccountPaymethod(isDefault: true)
            } else {
                createCheckingAccountPaymethod(isDefault: false)
            }
//            createCheckingAccountPaymethod(isDefault: false)
        case .autoPayFromLetsDoIt, .none:
            break
        }
    }
    
    private func moveToMakePayment() {
        // CMAIOS-2164 && CMAIOS-2179
        // self.selectedAmount > 0, denotes that the enterpayment screen is already been visited
        switch (QuickPayManager.shared.getCurrentAmount() == "", self.selectedAmount > 0) {
        case (true, false):
            if !isSaveBtnTapped {
                self.updatePayMethodToLocalDict()
            }
            self.enterAmountScreen()
        default:
            self.makePaymentNavigation()
        }
        
        /*
         if QuickPayManager.shared.getCurrentAmount() == "" { // CMAIOS-2164
         if !isSaveBtnTapped {
         self.updatePayMethodToLocalDict()
         }
         self.enterAmountScreen()
         return
         }
         
         let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
         if !isSaveBtnTapped { //CMAIOS-2161 & CMAIOS-2162
         self.updatePayMethodToLocalDict()
         makePayVC.firstTimeCardFlow = true
         makePayVC.tempPaymethod = self.generatePaymethod()
         }
         self.navigationController?.navigationBar.isHidden = true
         self.navigationController?.pushViewController(makePayVC, animated: true)
         */
    }
    
    private func makePaymentNavigation() {
        // CMAIOS:-2179
        // Pop to Make payment screen if it's available in navigation stack else fallback to other case
        if let navigationCtrl = self.presentingViewController as? UINavigationController
        {
            if let makePayVC = navigationCtrl.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first as? MakePaymentViewController {
                self.updateMakePaymentModel(makePaymentVc: makePayVC)
                navigationCtrl.dismiss(animated: true)
                return
            }
        }
        
        // Push to Make payment screen if it's not available in navigation stack
        let makePayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "MakePaymentViewController") as MakePaymentViewController
        if !isSaveBtnTapped { //CMAIOS-2161 & CMAIOS-2162
            self.updatePayMethodToLocalDict()
            makePayVC.firstTimeCardFlow = true
            makePayVC.tempPaymethod = self.generatePaymethod()
        }
        if self.selectedAmount > 0 { // If already entered amount in enterpayment screen
            makePayVC.noDueFlow = true
            makePayVC.noDueAmountValue = String(self.selectedAmount)
        }
        makePayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(makePayVC, animated: true)
    }
    
    // CMAIOS:-2179
    private func updateMakePaymentModel(makePaymentVc: MakePaymentViewController) {
        if !isSaveBtnTapped { //CMAIOS-2161 & CMAIOS-2162
            self.updatePayMethodToLocalDict()
        }
        makePaymentVc.firstTimeCardFlow = true
        makePaymentVc.tempPaymethod = self.generatePaymethod()
        if self.selectedAmount > 0 { // If already entered amount in enterpayment screen
            makePaymentVc.noDueFlow = true
            makePaymentVc.noDueAmountValue = String(self.selectedAmount)
        }
    }
    
    private func enterAmountScreen() {
        let enterPayVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "EnterPaymentViewController") as EnterPaymentViewController
        enterPayVC.payMethod = self.generatePaymethod()
        enterPayVC.flowType = flow // CMAIOS-2230
        enterPayVC.isAutoPaymentErrorFlow = self.isAutoPaymentErrorFlow
        self.navigationController?.pushViewController(enterPayVC, animated: true)
    }
    
    /*
    /// Refresh Get Account bill
    private func refreshGetAccountBill(isOneTimePayment: Bool, cardInfo: CreditCardPayMethod) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                }
                let payMethod = PayMethod(name: QuickPayManager.shared.getAccountName() + "/paymethods/" + (self.nickName), creditCardPayMethod: cardInfo, bankEftPayMethod: nil)
//                self.signInIsProgress = false
//                self.payAnimationView.pause()
//                self.payAnimationView.play(fromProgress: self.payAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
//                    self.signInFailedAnimation()
//                }
            }
        })
    }
     */
    
    func showErrorMsgOnPaymentFailure(isAutoPayFailure: Bool = false, payMethodName: String = "") {
        let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
        vc.isComingFromProfileCreationScreen = false
        vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .billing_notification_API_failure)
        
        switch flow {
        case .managePayments(_) where QuickPayManager.shared.isAutoPayEnabled():
            if isAutoPayFailure { // CMAIOS-2623
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .autoPay_setup_API_failure_after_MOP, subTitleMessage: updatedAutoPayMethodName)
            }
            vc.isComingFromFinishSetup = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_AUTOPAY_ENROLLMENT_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        default:
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_ADDING_MOP_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            if continueBtn.currentTitle == "Save" {
                vc.isComingFromCardInfoPage = true
                vc.isComingFromBillingMenu = false
            } else {
                vc.isComingFromBillingMenu = true
                vc.isComingFromCardInfoPage = false
            }
            self.determineAndUpdateGAReport()
        }
        
        /*
        if flow == .managePayments && QuickPayManager.shared.isAutoPayEnabled() { //CMAIOS-2858
            if isAutoPayFailure { // CMAIOS-2623
                vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .autoPay_setup_API_failure_after_MOP, subTitleMessage: payMethodName)
            }
            vc.isComingFromFinishSetup = true
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_AUTOPAY_ENROLLMENT_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_BILLING_ADDING_MOP_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
            if continueBtn.currentTitle == "Save" {
                vc.isComingFromCardInfoPage = true
                vc.isComingFromBillingMenu = false
            } else {
                vc.isComingFromBillingMenu = true
                vc.isComingFromCardInfoPage = false
            }
            self.determineAndUpdateGAReport()
        }
         */
        //CMAIOS-2099
        self.navigationController?.pushViewController(vc, animated: true)
        //
    }
    
    /// Only capture the create payment error
    private func determineAndUpdateGAReport() {
        switch (QuickPayManager.shared.getAllPayMethodMop().isEmpty && (flow == .autopay || flow == .noPayments || flow == .paymentFailure || flow == .autopayFromSP),
                QuickPayManager.shared.getAllPayMethodMop().isEmpty) {
        case (true, _), (_,false):
            //For Google Analytics
            CMAAnalyticsManager.sharedInstance.trackAction(
                eventParam: [EVENT_SCREEN_NAME: BillPayEvents.ERROR_ON_SAVE_MOP_SCREEN.rawValue,
                            EVENT_SCREEN_CLASS: self.classNameFromInstance])
        default: break
        }
    }
    
    private func moveToHomeViewController(payMethod: PayMethod? = nil) {
        
        // Pop to Make payment screen if it's available in navigation stack else fallback to other case
        if let makePayVC = self.navigationController?.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first as? MakePaymentViewController {
            self.updateMakePaymentModel(makePaymentVc: makePayVC)
            self.navigationController?.popToViewController(makePayVC, animated: true)
            return
        }
        
        // Pop to Make payment screen if it's available in navigation stack else fallback to other case
        if let navigationCtrl = self.presentingViewController as? UINavigationController
        {
            if let makePayVC = navigationCtrl.viewControllers.filter({$0.isKind(of: MakePaymentViewController.classForCoder())}).first as? MakePaymentViewController {
                self.updateMakePaymentModel(makePaymentVc: makePayVC)
                navigationCtrl.dismiss(animated: true)
                return
            }
        }
        
        // Pop to EditAutoPayViewController screen with updated Paymethod if it's available in navigation stack
        if let editAutoPay = self.navigationController?.viewControllers.filter({$0.isKind(of: EditAutoPayViewController.classForCoder())}).first as? EditAutoPayViewController {
            editAutoPay.updatePaymethod(payMethod: payMethod)
            self.navigationController?.popToViewController(editAutoPay, animated: true)
            return
        }
        
        // Default card expired when muliple MOPs available
        if let navigationCtrl = self.presentingViewController as? UINavigationController
        {
            if let _ = navigationCtrl.viewControllers.filter({$0.isKind(of: CardExpiredNotifyVC.classForCoder())}).first as? CardExpiredNotifyVC {
                self.moveToMakePayment()
                return
            }
        }
        
        // Default card expired when muliple MOPs available
        if let _ = self.navigationController?.viewControllers.filter({$0.isKind(of: CardExpiredNotifyVC.classForCoder())}).first as? CardExpiredNotifyVC {
            self.moveToMakePayment()
            return
        }
        
        if let chooseVc = navigationController?.viewControllers.filter({$0.isKind(of: ChoosePaymentViewController.classForCoder())}).first {
            self.navigationController?.popToViewController(chooseVc, animated: true)
        }
        /*
        if (self.presentingViewController?.isKind(of: ChoosePaymentViewController.self)) != nil {
            if let chooseViewController = self.presentingViewController as? ChoosePaymentViewController
            {
                if let navigationController = self.presentingViewController?.presentedViewController as? UINavigationController {
                    if let addCardView = navigationController.viewControllers.filter({$0.isKind(of: AddCardViewController.classForCoder())}).first {
                        addCardView.dismiss(animated: true) {
                            chooseViewController.fetchPaymethods()
                        }
                        return
                    }
                }
            }
        }
        
        if let childNavigationControl = self.presentingViewController as? UINavigationController
        {
            if childNavigationControl.viewControllers.contains(where: { $0.isKind(of: AddingPaymentMethodViewController.classForCoder()) }) {
                if let choosePaymentView = childNavigationControl.viewControllers.filter({$0.isKind(of: ChoosePaymentViewController.classForCoder())}).first as? ChoosePaymentViewController {
                    choosePaymentView.fetchPaymethods()
                    childNavigationControl.popToRootViewController(animated: true)
                }
            }
        }
        
        if let childNavigationControl = self.presentingViewController as? UINavigationController
        {
            if let choosePaymentView = childNavigationControl.viewControllers.filter({$0.isKind(of: ChoosePaymentViewController.classForCoder())}).first as? ChoosePaymentViewController {
                self.presentingViewController?.dismiss(animated: true) {
                    choosePaymentView.fetchPaymethods()
                    childNavigationControl.popToViewController(choosePaymentView, animated: true)
                }
                return
            }
        }
        
        if let viewController = self.presentingViewController?.presentingViewController as? UINavigationController {
            DispatchQueue.main.async {
                viewController.dismiss(animated: true)
                return
            }
        }
        if let viewController = self.presentingViewController?.presentingViewController?.presentingViewController as? UINavigationController {
            DispatchQueue.main.async {
                viewController.dismiss(animated: true)
                return
            }
        }
        
        if let navigationController = self.presentingViewController as? UINavigationController {
            if let chooseVc = navigationController.viewControllers.filter({$0.isKind(of: ChoosePaymentViewController.classForCoder())}).first {
                if let destinaionVc = chooseVc as? ChoosePaymentViewController {
                    navigationController.dismiss(animated: true) {
                        destinaionVc.fetchPaymethods()
                        return
                    }
                }
            }
        }
         */
    }
    
    private func moveToMakePaymentForExpiryFlow() {
        self.moveToMakePayment()
    }

    private func updatePayMethodToLocalDict() {
        if QuickPayManager.shared.localSavedPaymethods == nil {
            QuickPayManager.shared.localSavedPaymethods = []
        }
        let tempPaymethod = LocalSavedPaymethod(payMethod: self.generatePaymethod(), save: self.isSaveBtnTapped)
//        QuickPayManager.shared.localSavedPaymethods?.append(tempPaymethod)
        // CMAIOS-2207
        if let paymethodVal = QuickPayManager.shared.localSavedPaymethods?.filter({ $0.payMethod?.name == self.generatePaymethod().name }), paymethodVal.count == 0 {
            QuickPayManager.shared.localSavedPaymethods?.append(tempPaymethod)
        }
    }
    
    private func generatePaymethod() -> PayMethod {
        let paymethodName = QuickPayManager.shared.getAccountName() + "/paymethods/" + self.getNickName()
        let paymethod = PayMethod(name: paymethodName, creditCardPayMethod: nil, bankEftPayMethod: self.generateJsonParam().bankAccPayMethod)
        return paymethod
    }
    
    private func getNickName() -> String {
        var nickNameValue = self.nickName
        if self.nickName == "" {
            nickNameValue = "Checking-" + self.accountNumber.getTrimmedString(isPrefix: false, length: 4)
        }
        return nickNameValue
    }
    
    // Segregate the Create payment reponse (first time or not)
    /// - Parameters:
    ///   - cardInfo: Payment would be updated to model
    ///   - isDefault: (save + default) or only save
    private func processCreatePaymentReponse(checkingInfo: BankEftPayMethod, isDefault: Bool) {
//        let cardDict = updateMaskedNumber(cardInfo: cardInfo)
        switch flow {
        case .noPayments:
            self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
        case .addCard:
            self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
        case .paymentFailure: break
        case .autopay, .autopayFromSP, .appbNotEnrolled:
            self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
        case .editAutoPay:
            self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
            //CMAIOS-2858
            /*
            if self.isAutoPayCheckBoxTapped {
                let paymethod = PayMethod(name: QuickPayManager.shared.getAccountName() + "/paymethods/" + (self.nickName), creditCardPayMethod: nil, bankEftPayMethod: checkingInfo)
                self.makeUpdateAutoPayAPI(payMethod: paymethod, checkingInfo: checkingInfo, isDefault: isDefault)
            } else {
                self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
            }
             */
        case .managePayments: //CMAIOS-2858
            if self.isAutoPayCheckBoxTapped {
                let paymethod = PayMethod(name: QuickPayManager.shared.getAccountName() + "/paymethods/" + (self.nickName), creditCardPayMethod: nil, bankEftPayMethod: checkingInfo)
                self.makeUpdateAutoPayAPI(payMethod: paymethod, checkingInfo: checkingInfo, isDefault: isDefault)
            } else {
                self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
            }
            /*
            self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
             */
        case .autoPayFromLetsDoIt, .none:
            break
        }
    }
        
        // CMAIOS-2841
        private func moveToEditAutoPay(_ paymethod: PayMethod? = nil) {
            if let editAutoPay = self.navigationController?.viewControllers.filter({$0 is EditAutoPayViewController}).first as? EditAutoPayViewController {
                DispatchQueue.main.async {
                    editAutoPay.payMethod = paymethod
                }
                self.navigationController?.popToViewController(editAutoPay, animated: true)
            } else  if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(managePayment, animated: true)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    private func navigateAfterPaymenthodCreation(checkingInfo: BankEftPayMethod, isDefault: Bool, isFromFailure: Bool = false) {
        var params = [String: AnyObject]()
        params["name"] = QuickPayManager.shared.getAccountName() as AnyObject?
        APIRequests.shared.mauiGetAccountBillRequest(interceptor: nil, params: params, completionHandler: { success, value, error in
            DispatchQueue.main.async {
                let paymethod = PayMethod(name: QuickPayManager.shared.getAccountName() + "/paymethods/" + (self.nickName), creditCardPayMethod: nil, bankEftPayMethod: checkingInfo)
                if success {
                    QuickPayManager.shared.modelQuickPayGetAccountBill = value
                    if !isDefault {
                        if let paymethodVal = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.filter({ $0.name == paymethod.name }), paymethodVal.count == 0 {
                            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                            }
                            QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
                        }
                    }
                    self.updatePaymethodForNoCardFlow(payMethod: paymethod) // CMAIOS-1953 & CMAIOS-2177
                }
                if isFromFailure, !self.updatedAutoPayMethodName.isEmpty {
                    self.paymethodCreationFailedAnimation()
                    self.showErrorMsgOnPaymentFailure(isAutoPayFailure: true)
                    return
                }
                //CMAIOS-2712
                switch self.flow {
                case .autopay, .autopayFromSP:
                    self.mauiCreateAutoPay()
                default:
                    self.paymentCreationIsProgress = false
                    self.continueAnimationView.pause()
                    self.continueAnimationView.play(fromProgress: self.continueAnimationView.currentProgress, toProgress: 1.0, loopMode: .playOnce) { _ in
                        self.paymethodCreationFailedAnimation()
                        self.navigateToSuccessScreen(payMethod: paymethod)
                    }
                }
                
            }
        })
    }
    
    func makeUpdateAutoPayAPI(payMethod: PayMethod, checkingInfo: BankEftPayMethod, isDefault: Bool) {
        guard let oldAutoPay = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay else { return }
        var autoPay = oldAutoPay
        autoPay.update(payMethod: PayMethod(name: payMethod.name))
        updatedAutoPayMethodName = payMethod.name?.lastPathComponent ?? ""
        payMethodCheckingInfo = checkingInfo
        isDefaultAccount = isDefault
        QuickPayManager.shared.mauiUpdate(autoPay: autoPay) { result in
            switch result {
            case .success(let autoPay):
                if let index = QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.firstIndex(where: {$0.name == payMethod.name}), payMethod.name != QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name {
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.remove(at: index)
               }
                if oldAutoPay.payMethod?.name != QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name, let paymethod = oldAutoPay.payMethod {
                    if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods == nil {
                        QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods = []
                    }
                    QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.payMethods?.append(paymethod)
                }
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.autoPay = autoPay
                self.navigateAfterPaymenthodCreation(checkingInfo: checkingInfo, isDefault: isDefault)
            case let .failure(error):
                Logger.info("Expiration Update failed \(error.localizedDescription)")
                self.paymethodCreationFailedAnimation()
                self.showErrorMsgOnPaymentFailure(isAutoPayFailure: true, payMethodName: payMethod.name?.lastPathComponent ?? "")
            }
            
        }
    }
    
    private func navigateToSuccessScreen(payMethod: PayMethod?) {
        switch flow {
        case .noPayments:
            self.moveToMakePayment()
        case .addCard(let type):
            if isTurnOnAutoPay { // CMAIOS:-2178 // With Muliple MOPs // Turn on autoplay -> Choose payment -> Adding new paymenthod
//                self.navigateToFinishSetup(paymethod: payMethod)
                self.navigateToFinishSetup(screenType: (flow == .autopay) ? .turnOnAutoPay : .turnOnAutoPayFromSpotlight, paymethod: payMethod)
            } else {
                handleAddCheckingNavigation(type: type, paymethod: payMethod)
            }
        case .paymentFailure: break
        case .autopay, .autopayFromSP:// With no MOP
//            self.navigateToFinishSetup()
            self.navigateToFinishSetup(screenType: (flow == .autopay) ? .turnOnAutoPay : .turnOnAutoPayFromSpotlight)
        case .appbNotEnrolled:
            self.navigateToFinishSetup(screenType: (flow == .autopay) ? .turnOnAutoPay : .turnOnAutoPayFromSpotlight, paymethod: payMethod)
        case .managePayments(let editAutoAutoPayFlow): //CMAIOS-2858 //CMAIOS-2841
            if editAutoAutoPayFlow {
                self.moveToEditAutoPay(payMethod)
            } else {
                DispatchQueue.main.async { //CMAIOS-2841
                    self.moveManagePayments()
                }
                /*
                if !self.isAutoPayCheckBoxTapped {
                    if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                        DispatchQueue.main.async {
                            self.moveManagePayments()
                        }
                    } else {
                        handleAddCheckingNavigation(type: .home, paymethod: payMethod)
                    }
                } else {
                    self.moveManagePayments()
                }
                 */
            }
            /*
            if !self.isAutoPayCheckBoxTapped {
                if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                    DispatchQueue.main.async {
                        self.moveManagePayments()
                    }
                } else {
                    handleAddCheckingNavigation(type: .home, paymethod: payMethod)
                }
            } else {
                self.moveManagePayments()
            }
             */
        case .editAutoPay:
            if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                DispatchQueue.main.async {
                    self.moveManagePayments()
                }
            } else {
                handleAddCheckingNavigation(type: .home, paymethod: payMethod)
            }
            //CMAIOS-2858
            /*
            if !self.isAutoPayCheckBoxTapped {
                if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
                    DispatchQueue.main.async {
                        self.moveManagePayments()
                    }
                } else {
                    handleAddCheckingNavigation(type: .home, paymethod: payMethod)
                }
            } 
            else {
                self.moveManagePayments()
            }
             */
        case .autoPayFromLetsDoIt, .none:
            break
        }
    }
    
    func handleAddCheckingNavigation(type: NavScreenType, paymethod: PayMethod?) {
        switch type {
        case .makePayment:
            self.moveToMakePayment()
        default:
            self.moveToHomeViewController(payMethod: paymethod)
            /*
             self.moveToHomeViewController()
             */
        }
    }

    private func updatePaymethodForNoCardFlow(payMethod: PayMethod?) {
        guard let payMethodRef = payMethod else {
            return
        }
        switch (self.flow == .noPayments, self.isSaveBtnTapped, self.flow == .autopay, self.flow == .autopayFromSP, self.flow == .appbNotEnrolled) {
        case (_, _, true, _, _), (true, true, _, _, _), (_, _, _, true, _), (_, _, _, _, true):
            if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == nil {
                QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = payMethodRef
            }
        default: break
        }
        /*
         if self.flow == .noPayments && self.isSaveBtnTapped {
         if QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod?.name == nil {
         QuickPayManager.shared.modelQuickPayGetAccountBill?.billAccount?.defaultPayMethod = payMethodRef
         }
         }
         */
    }
    
    private func navigateToFinishSetup(screenType: FinishSetupType, paymethod: PayMethod? = nil) {
        guard let viewcontroller = FinishSetupViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.screenType = screenType
        viewcontroller.payMethod = paymethod
        if flow == .appbNotEnrolled {
            viewcontroller.flowType = .appbNotEnrolled
        }
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    // CMAIOS-2305
    private func moveManagePayments() {
        if let managePayment = self.navigationController?.viewControllers.filter({$0 is ManagePaymentsViewController}).first as? ManagePaymentsViewController {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(managePayment, animated: true)
            }
        } else {
            guard let vc = ManagePaymentsViewController.instantiateWithIdentifier(from: .billing) else { return }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Continue Button Animations
    func continueButtonAnimation() {
        //self.signInAnimView.alpha = 0.0
        self.continueAnimationView.isHidden = true
        self.continueBtn.isHidden = true
        UIView.animate(withDuration: 1.0) {
            //self.signInAnimView.alpha = 1.0
            self.continueAnimationView.isHidden = false
        }
        self.continueAnimationView.backgroundColor = .clear
        self.continueAnimationView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.continueAnimationView.loopMode = .playOnce
        self.continueAnimationView.animationSpeed = 1.0
       // self.signInAnimView.currentProgress = 0.4
        self.continueAnimationView.play(toProgress: 0.6, completion:{_ in
            if self.paymentCreationIsProgress {
                self.continueAnimationView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func paymethodCreationFailedAnimation() {
        self.paymentCreationIsProgress = false
        self.continueAnimationView.currentProgress = 3.0
        self.continueAnimationView.stop()
        self.continueAnimationView.isHidden = true
        self.continueBtn.alpha = 0.0
        self.continueBtn.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.continueBtn.alpha = 1.0
        }
    }
}


extension AddCheckingAccountViewController {
    //CMAIOS-2841
    func returnDefaultNoOfSections() -> Int {
        return 5
    }
    
    //CMAIOS-2841
    func returnDefaultRowHeightType(row: Int) -> Double {
        if row == 0 {   //For Name view
            return rowHeightForAccountName
        } else if row == 1 {   //For Routing view
            return rowHeightForRouting
        } else if row == 2 {   //For Acc. Number view
            return rowHeightForAccount
        } else if row == 3 {
            return 201                    //For Nickname view
        }
        else {
            if accountSelected || routingSelected { // for empty cell height
                return 0
            } else {
                return self.emptyCellHeight >= 0 ? self.emptyCellHeight : 0
            }
        }
    }
    
    //CMAIOS-2841
    func returnDefaultCellType(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return accountNameCell()
        } else if indexPath.row == 1 {
            return routingNumberCell(indexPath)
        } else if indexPath.row == 2 {
            return accountNumberCell(indexPath)
        } else if indexPath.row == 3{
            return nickNameCell()
        } else {
            let cell = self.achTableView.dequeueReusableCell(withIdentifier: emptyCell) as! EmptyCell
            return cell
        }
    }
    
}


extension AddCheckingAccountViewController {
    /// handle Api errorcode 500
    /// CMAIOS-2858
    func handleACH500Error() {
        switch QuickPayManager.shared.currentApiType {
        case .updateAutoPay:
            self.navigateAfterPaymenthodCreation(checkingInfo: payMethodCheckingInfo, isDefault: isDefaultAccount)
        case .createAutoPay: /// CMAIOS-2841
            self.paymethodCreationFailedAnimation()
            self.showErrorMsgOnPaymentFailure(isAutoPayFailure: false)
        default: break
        }
    }
}
