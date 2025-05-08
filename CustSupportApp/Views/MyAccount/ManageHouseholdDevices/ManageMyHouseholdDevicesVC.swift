//
//  ManageMyHouseholdDevicesVC.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 19/09/22.
//

import UIKit
import Lottie

class ManageMyHouseholdDevicesVC: UIViewController {
    @IBOutlet weak var closeIconImgView: UIImageView!
  //  @IBOutlet weak var viewAddPerson: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
 //   @IBOutlet weak var viewPlusIcon: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
 //   @IBOutlet weak var addPersonLabel: UILabel!
  //  @IBOutlet weak var viewAddPersonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
   // @IBOutlet weak var addIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var viewTitleHeader: UIView!
    @IBOutlet weak var viewAddPersonFooter: UIView!
    var isFromMyAccount: Bool = true
    
    var arrProfiles:[ProfileModel]?
    var hasDevice:(Bool, Bool) = (false, false)
    var currentSelectedIndex: Int = 0
    var qualtricsAction: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //This is For top two labels
//        self.profileTableView.register(UINib(nibName: "ManageHouseholdTextTableViewCell", bundle: nil), forCellReuseIdentifier: "ManageHouseholdTextTableViewCell")
        
        //This is for the profiles  view
        self.profileTableView.register(UINib(nibName: "ManageMyHouseholdDeviceCell", bundle: nil), forCellReuseIdentifier: "ManageMyHouseholdDeviceCell")
        
        //This is for bottom "Add a person" cell
//        self.profileTableView.register(UINib(nibName: "ManageHouseholdAddPersonCell", bundle: nil), forCellReuseIdentifier: "ManageHouseholdAddPersonCell")
        
        //Add border color for plus icon bg view
       // viewPlusIcon.layer.borderColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1).cgColor
        
        //For iPod
        if currentScreenHeight < xibDesignHeight {
            self.handleUIForSmallerScreen()
        }
        // For larger devices
//        if currentScreenWidth >= 390.0 || UIDevice.current.hasNotch {
//            self.tableViewTopConstraint.constant = UIDevice.current.topInset + 30
//        }
    }
    
    private func setupShadowForCloseButtonView() {
        let shadowPath = UIBezierPath(rect: CGRect(x: self.shadowView.bounds.origin.x, y: self.shadowView.bounds.origin.y, width: currentScreenWidth, height: self.shadowView.bounds.height))
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, -5.0)
        self.shadowView.layer.shadowOpacity = 0 // for shadow set 0.5 for shadow or set as 0
        self.shadowView.layer.shadowPath = shadowPath.cgPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideUnhideUIElements(isHidden: true)
        self.getAllHouseHoldProfiles()
        self.setupShadowForCloseButtonView()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackAnalytics()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qualtricsAction?.cancel()
    }
    
    func addQualtrics(screenType: String){
        self.qualtricsAction = self.checkQualtrics(screenName: screenType, dispatchBlock: &qualtricsAction)
    }
    
    func trackAnalytics() {
        if !isFromMyAccount {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ProfileEvent.Profiles_managemyhousehold_withhouseholdprofiles.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.Profile.rawValue])
            self.addQualtrics(screenType: ProfileEvent.Profiles_managemyhousehold_withhouseholdprofiles.rawValue)
        } else {
            //For Firebase Analytics. CMAIOS-2215 update for custome param
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : MyAccountScreenDetails.MY_ACCOUNT_MANAGE_MY_HOUSEHOLD_PROFILES.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,CUSTOM_PARAM_INTENT: Intent.General.rawValue])
            self.addQualtrics(screenType: MyAccountScreenDetails.MY_ACCOUNT_MANAGE_MY_HOUSEHOLD_PROFILES.rawValue)
        }
    }
    
    // MARK: - Dynamic UI Handling
//    func handleUIBasedOnAvailableData(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            let availableSpace = self.checkAvailableSpaceInDevice()
//            if availableSpace >= self.profileTableView.rowHeight {
//                let permissibleRows = availableSpace/self.profileTableView.rowHeight
//                // If input data is less than or equal to the available space
//                if let profileCount = self.arrProfiles?.count,
//                    Double(profileCount + 2) <= permissibleRows {
//                    self.profileTableView.isScrollEnabled = false
//                    self.tableViewHeightConstraint.constant = CGFloat(Double(profileCount) * self.profileTableView.rowHeight)
//                } else {
//                    // If input data is more than available space
//                    self.profileTableView.isScrollEnabled = true
//                    self.tableViewHeightConstraint.constant = CGFloat(Double(permissibleRows) * self.profileTableView.rowHeight) + self.profileTableView.rowHeight
//                }
//            } else {
//                // Handled delete scenario if tableview height is more than arrProfiles count
//                if let profileCount = self.arrProfiles?.count,
//                   Double(profileCount*90) < self.tableViewHeightConstraint.constant {
//                    self.tableViewHeightConstraint.constant = CGFloat(Double(profileCount) * self.profileTableView.rowHeight)
//                }
//            }
//            self.view.layoutIfNeeded()
//        }
//    }
    
//    func checkAvailableSpaceInDevice() -> CGFloat {
//  //      let basePosition = viewAddPerson.frame.origin.y + viewAddPerson.frame.size.height
//        return closeButton.frame.origin.y - basePosition
//    }
    
    func handleUIForSmallerScreen() {
     //   viewAddPersonHeightConstraint.constant = 60.0
//        tableViewTopConstraint.constant = 35.0
   //     addIconTopConstraint.constant = 20.0
        //set font
        handleFontSizeForSmallerScreen(label: subTitleLabel,fontFamily: "Regular-Regular", fontSize: 16.0)
        handleFontSizeForSmallerScreen(label: titleLabel,fontFamily: "Regular-Bold", fontSize: 24.0)
  //      handleFontSizeForSmallerScreen(label: addPersonLabel,fontFamily: "Regular-Bold", fontSize: 18.0)
    }
    
    // MARK: - Buttton Actions
    @IBAction func closeBtnAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.dismiss(animated: true)
    }
    
    @IBAction func actionAddPerson(_ sender: Any) {
        self.qualtricsAction?.cancel()
        self.navigationController?.removeViewControllerIfExists(ofClass: ProfileNameViewController.self)
        //add person Action
        guard let vc = ProfileNameViewController.instantiate() else { return }
        vc.state = .add(isMaster: false, name: "")
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Edit Button Action
    @objc func editProfileAction() {
        //edit profile
    }
    
    //Delete Button Action
    @objc func deleteProfileAction(sender: UIButton) {
        self.qualtricsAction?.cancel()
        //delete profile
        let deleteVC = UIStoryboard(name: "ManageMyHousehold", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeleteHouseholdProfileVC") as! DeleteHouseholdProfileVC
        deleteVC.modalPresentationStyle = .fullScreen
        deleteVC.profileDetail = self.getSelectedProfileModel(selectedIndex: sender.tag)
        self.present(deleteVC, animated: true, completion: nil)
    }
    
    @objc func viewProfileAction(sender:UIButton){
        self.qualtricsAction?.cancel()
        let selectedCell = getCellForRow(rowNumber: sender.tag)
        let profileObj = self.getSelectedProfileModel(selectedIndex: sender.tag)
        //Animate ProfileAvatarIcon
        addImageViewAsSubview(selectedView:selectedCell, profileModel:profileObj) { isStaticScreen in
            self.navigateToViewProfileScreen(currentSelectedIndex: sender.tag)
        }
    }
    
    @objc func addPersonBtnTapped(sender: UIButton){
        self.qualtricsAction?.cancel()
        self.navigationController?.removeViewControllerIfExists(ofClass: ProfileNameViewController.self)
        //add person Action
        guard let vc = ProfileNameViewController.instantiate() else { return }
        vc.state = .add(isMaster: false, name: "")
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Helper Methods
    func getCellForRow(rowNumber:Int) -> ManageMyHouseholdDeviceCell {
        //This method is used to get selected cell on tap
        let indexPath = IndexPath(row: rowNumber, section: 0)
        if let cell = self.profileTableView.cellForRow(at: indexPath) as? ManageMyHouseholdDeviceCell {
            return cell
        }
        return ManageMyHouseholdDeviceCell()
    }
    
    func getSelectedProfileModel(selectedIndex:Int) -> ProfileModel? {
        //This method is to return ProfileDetail Instance on tap
        let profileDetail  = self.arrProfiles?[selectedIndex]
        return profileDetail
    }
    
    func hideUnhideUIElements(isHidden:Bool){
        self.closeButton.isHidden = isHidden
     //   self.addPersonLabel.isHidden = isHidden
     //   self.viewPlusIcon.isHidden = isHidden
    }
}

extension ManageMyHouseholdDevicesVC : HandleAnimationInParentView {
    func updateAvatarIconAfterProfileEdit(profileDetail: Profile?, completionHanlder: @escaping (Bool) -> Void) {
        self.updateAvatarAfterEditForBackwardAnimation(updatedProfileDetail: profileDetail){
            isAnimationCompleted in
            completionHanlder(true)
        }
    }

    func childViewcontrollerGettingDismissed(profileDetail : Profile, index: Int?, fromView: ProfileDetailsTableViewCell?) {
        if profileTableView.visibleCurrentCellIndexPath.contains(index!) {
            if profileTableView.visibleCurrentCellIndexPath.last == index {
                profileTableView.scrollToRow(at: IndexPath(item: index!, section: 0), at: .top, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.animateForDismissedProfile(profileDetail: profileDetail, index: index)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.animateForDismissedProfile(profileDetail: profileDetail, index: index)
                }
            }
        } else {
            if let cellIndex = index {
                profileTableView.scrollToRow(at: IndexPath(item: cellIndex, section: 0), at: .top, animated: false)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.animateForDismissedProfile(profileDetail: profileDetail, index: index)
            }
        }
    }
    
    func animateForDismissedProfile(profileDetail : Profile, index: Int?) {
        var currentCell:ManageMyHouseholdDeviceCell!
        if let profileIndex = index, let collectionCell = self.profileTableView.cellForRow(at: IndexPath(row: profileIndex, section: 0)) as? ManageMyHouseholdDeviceCell {
            currentCell = collectionCell
        } else {
            let collectionCell = self.profileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ManageMyHouseholdDeviceCell
            currentCell = collectionCell
        }
        let animationIconView = self.view.viewWithTag(101)
        let alphabetView = self.view.viewWithTag(102)
        let bgAnimationView = self.view.viewWithTag(1000)
        self.animateProfileAvatarIconFromTopToBottom(toView: currentCell, profileDetail: profileDetail, color: energyBlueRGB) { isAnimationCompleted, imageType in
            if imageType == .avatarIcon {
               alphabetView?.removeFromSuperview()
            } else if imageType == .alphabet {
               animationIconView?.removeFromSuperview()
            } else {
                alphabetView?.removeFromSuperview()
                animationIconView?.removeFromSuperview()
            }
             UIView.animate(withDuration: 0.4) {
                 bgAnimationView?.alpha = 0.0
                 self.setAlphaForUIElements(alpha: 1.0)
             } completion: { _ in
                 bgAnimationView?.removeFromSuperview()
                 animationIconView?.removeFromSuperview()
                 alphabetView?.removeFromSuperview()
             }
        }
    }
}

extension ManageMyHouseholdDevicesVC {
    func getAllHouseHoldProfiles() {
        ProfileModelHelper.shared.getAllAvailableProfiles { profiles in
            if profiles != nil {
                DispatchQueue.main.async {
                    let profilesCount = self.arrProfiles?.count ?? 0
                    self.arrProfiles = profiles
//                    if profilesCount != profiles?.count {
//                        self.handleUIBasedOnAvailableData()
//                    }
                    self.profileTableView.reloadData()
                    self.hideUnhideUIElements(isHidden: false)
                }
            } else {
                DispatchQueue.main.async {
                    self.hideUnhideUIElements(isHidden: false)
                }
            }
        }
    }
}
