//
//  CommonNavigationVC.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 18/10/22.
//

import UIKit

class CommonNavigationVC: UIViewController {

    //MARK: Handle navigation
    func navigateToManageMyHousehold(householdProfilesExists:Bool, isFromMyAccount: Bool = true) {
        if let instanceVC = getViewControllerInstance(profilesExists: householdProfilesExists, isFromMyAccount: isFromMyAccount) {
            let navVC = UINavigationController(rootViewController: householdProfilesExists ? instanceVC as! ManageMyHouseholdDevicesVC : instanceVC as! NoDevicesInHouseholdVC)
            navVC.modalPresentationStyle = .fullScreen
            navVC.navigationBar.isHidden = true
            self.present(navVC, animated: true)
        }
    }
    
    func getViewControllerInstance(profilesExists:Bool, isFromMyAccount: Bool = true) -> AnyObject? {
        
        /**This methods is used to return ManageMyHouseholdDevicesVC or NoDevicesInHouseholdVC instance based upon profilesExists
         @param: profilesExists - determine if there is MasterProfile + one household Profile in GetProfile API response
         **/

        if profilesExists {
            let manageVC = UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(withIdentifier: "ManageMyHouseholdDevicesVC") as? ManageMyHouseholdDevicesVC
            manageVC?.isFromMyAccount = isFromMyAccount
            return manageVC
        } else {
            return (UIStoryboard(name: "ManageMyHousehold", bundle: nil).instantiateViewController(withIdentifier: "NoDevicesInHouseholdVC") as? NoDevicesInHouseholdVC)
        }
    }
    
    //Check whether GetProfiles API Response has MasterProfile and one Household profile
    func checkHasHouseHoldProfiles() -> Bool {
       var hasHouseHoldProfiles = false
       if let houseHoldProfiles = ProfileManager.shared.profiles,  ProfileManager.shared.masterProfileExists(profileDetail: houseHoldProfiles).0,
           houseHoldProfiles.count >= 2 {
           hasHouseHoldProfiles = true
       } else {
           hasHouseHoldProfiles = false
       }
        return hasHouseHoldProfiles
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
