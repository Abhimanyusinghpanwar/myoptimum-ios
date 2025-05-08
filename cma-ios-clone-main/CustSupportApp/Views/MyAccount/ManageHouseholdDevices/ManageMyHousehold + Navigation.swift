//
//  ManageMyHousehold + Navigation.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 20/10/22.
//

import Foundation
import Lottie

extension ManageMyHouseholdDevicesVC{
    
    // MARK: - Navigate to ViewProfileDetailScreen(with or without devices)
    func navigateToViewProfileScreen(currentSelectedIndex: Int) {
        let storyboard = UIStoryboard(name: "ManageMyHousehold", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewProfileWithDeviceViewController") as! ViewProfileWithDeviceViewController
        vc.arrProfiles = self.arrProfiles
        vc.delegate = self
        vc.currentSelectedIndex = currentSelectedIndex
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
