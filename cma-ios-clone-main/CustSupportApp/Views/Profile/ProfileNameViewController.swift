//
//  AddNameViewController.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/7/22.
//

import UIKit

class ProfileNameViewController: BaseViewController, BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType) {
        if buttonType == .back {
            self.navigationController?.popViewController(animated: true)
        } else {
            onTapCancel()
        }
    }
    
    enum State {
        case add(isMaster: Bool, name: String? = nil)
        case edit(Profile)
        
        var isEdit: Bool {
            guard case .edit = self else { return false }
            return true
        }
        
        var isAdd: Bool {
            guard case .add = self else { return false }
            return true
        }

        
        var title: String {
            switch self {
            case let .add(isMaster, _) where isMaster:
                return "Hey, you're new here!"
            case .add:
                return "Add a person"
            case let .edit(profile) where profile.master_bit == true:
                return "Edit my profile"
            case .edit:
                return "Edit profile"
            }
        }
        
        var subTitle: String {
            guard !isMaster else {
                return "What should we call you?"
            }
            return "What's their name?"
        }
        
        var actionTitle: String {
            "Next"
        }
        
        var isMaster: Bool {
            switch self {
            case let .add(isMaster, _) where isMaster:
                return true
            case let .edit(profile) where profile.master_bit == true:
                return true
            default: return false
            }
        }
        
        var name: String? {
            switch self {
            case let .add(_, name):
                return name
            case let .edit(profile):
                return profile.profile
            }
        }
    }
    
    @IBOutlet var header: UILabel!
    @IBOutlet var subHeader: UILabel!
    @IBOutlet var errorTitle: UILabel!
    @IBOutlet var nameField: FloatLabelTextField!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var titleStack: UIStackView!
    var state: State = .add(isMaster: true)
    var profile:Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        buttonDelegate = self
        titleStack.layoutMargins = UIEdgeInsets(top: !state.isEdit && state.isMaster ? 67 : 27, left: 20, bottom: 20, right: 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = !state.isEdit && state.isMaster
        trackAnalytics()
    }
    
    func trackAnalytics() {
        var event = ""
        if ProfileManager.shared.isFirstUserExperience {
            event = ProfileEvent.Profiles_firstuse_masterprofile_nickname.rawValue
        } else {
            if self.state.isAdd {
                event = ProfileEvent.Profiles_addperson_nickname.rawValue
            } else if self.state.isEdit && self.state.isMaster {
                event = ProfileEvent.Profiles_edit_masterprofile_nickname.rawValue
            } else if self.state.isEdit {
                event = ProfileEvent.Profiles_edit_householdprofile_nickname.rawValue
            }
        }
        if event.isEmpty { return }
        //CMAIOS-2215 pass custom params to existing track action
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : event, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Profile.rawValue ])
    }
    
    func onTapCancel() {
        if state.isEdit {
            if nameField.text != self.profile?.profile {
                // discard changes
                self.nameField.text = self.profile?.profile
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            guard let vc = ConfirmationViewController.instantiateWithIdentifier(from: .profile) else { return }
            vc.configure(headerTitle: "Are you sure you want to cancel adding a person?", subHeaderTitle: nil, primaryButtonAction: {
                if let isExists = self.navigationController?.checkIfViewControllerExists(ofClass: ManageMyHouseholdDevicesVC.self), isExists {
                    self.navigationController?.popToViewController(ofClass: ManageMyHouseholdDevicesVC.self)
                } else {
                    if ProfileManager.shared.isFirstUserCompleted, let profiles = ProfileManager.shared.profiles, profiles.count > 1, let isExists = self.navigationController?.checkIfViewControllerExists(ofClass: NoDevicesInHouseholdVC.self), isExists {
                        let vc = UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(identifier: "ManageMyHouseholdDevicesVC") as ManageMyHouseholdDevicesVC
                        vc.modalPresentationStyle = .fullScreen
                        self.pushViewControllerWithLeftToRightAnimation(vc, from: self)
                    }
                    else {
                        self.navigationController?.dismiss(animated: true)
                    }
                }
            }, secondaryButtonAction: {
                self.navigationController?.popViewController(animated: false)
            })
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func configureUI() {
        nameField.setBorderColor(mode: BorderColor.deselcted_color)
        nameField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [.foregroundColor: UIColor.placeholderText])
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        updateUI()
    }
    
    func updateUI() {
        header.text = state.title// Use style to determine value
        subHeader.text = state.subTitle
        nameField.text = state.name
        actionButton.setTitle(state.actionTitle, for: .normal)
    }
    
    @IBAction func onTapActionButton(_ sender: UIButton) {
        guard nameField.text?.isEmpty == false else { return checkAndUpdateError(nameField.text, isEndValidation: true) }
        guard let name = nameField.text, errorTitle.isHidden else { return }
        guard let vc = ProfileAvatarViewController.instantiateWithIdentifier(from: .profile) else { return }
        if state.isEdit {
            guard var profileObj = self.profile else { return }
            profileObj.profile = name
            vc.state = .edit(profileObj)
        } else {
            let profile = Profile(master_bit: state.isMaster, profile: name)
            vc.state = .add(profile)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func validateInput(_ input: String?, checkForEmpty: Bool = false) -> String? {
        // Add more name validations
        guard input?.isEmpty == false || !checkForEmpty else {
            return "Please enter a name for your profile."
        }
        // Check if the first character is a special character or number
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]\"':;,./<>?\\|~`-=")
        let numberCharacterSet = CharacterSet(charactersIn: "1234567890")
        if let scalar = input?.first?.unicodeScalars.first {
            if specialCharacterSet.contains(scalar) {
                return "Your profile name can’t start with a special character."
            } else if numberCharacterSet.contains(scalar) {
                return "Your profile name can’t start with a number."
            }
        }
        guard input?.hasSuffix(" ") == true || input?.hasPrefix(" ") == true else { return nil }
        return "Your Profile name can’t start or end with a space."
    }
    
    func checkAndUpdateError(_ text: String?, isEndValidation: Bool = false) {
        let errorText = validateInput(text, checkForEmpty: isEndValidation)
        errorTitle.isHidden = errorText == nil
        errorTitle.text = errorText
        let color: BorderColor = isEndValidation ? .deselcted_color : .selected_color
        nameField.setBorderColor(mode: errorTitle.isHidden ? color : .error_color)
    }
}

extension ProfileNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        onTapActionButton(actionButton)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameField.setBorderColor(mode: errorTitle.isHidden ? .selected_color : .error_color)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkAndUpdateError(textField.text, isEndValidation: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString: NSString = ""
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            newString = updatedText as NSString
            if (newString.length > 0 && newString.length <= 12) || (newString.length == 0  && textField.text == " "){
                checkAndUpdateError(updatedText)
            }
        }
        if newString.length > 12 {
            if let lastChar = UnicodeScalar(newString.character(at: 11)), lastChar == " " {
                return false
            }else if let firstChar = UnicodeScalar(newString.character(at: 0)), firstChar == " ", let lastChar = UnicodeScalar(newString.character(at: 1)), lastChar == " " {
                return false
            }
        }
        return newString.length <= 12
    }
}
