//
//  ManageMyHousehold + UITableView.swift
//  CustSupportApp
//
//  Created by vishali.goyal on 20/10/22.
//

import Foundation

// MARK: - UITableViewDataSource/Delagate
extension ManageMyHouseholdDevicesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.arrProfiles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return calculateHeaderHeight()
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.profileTableView.frame.width,
                                              height: calculateHeaderHeight()))
        headerView.backgroundColor = .white
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return calculateSectionFooter()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if(indexPath.row == 0) {
        //            let manageTextCell = tableView.dequeueReusableCell(withIdentifier: "ManageHouseholdTextTableViewCell") as! ManageHouseholdTextTableViewCell
        //            tableView.separatorColor = .clear
        //            return manageTextCell
        //        }
        //This condition is for loading the "Add a Person" cell
        //        else if (indexPath.row == (self.arrProfiles?.count ?? 2) + 1) {
        //            let addPersonCell = tableView.dequeueReusableCell(withIdentifier: "ManageHouseholdAddPersonCell") as! ManageHouseholdAddPersonCell
        //            addPersonCell.addPersonBtn.addTarget(self, action: #selector(addPersonBtnTapped(sender: )), for: .touchUpInside)
        //            addPersonCell.addPersonBtn.tag = indexPath.row-1
        //            tableView.separatorColor = .clear
        //            return addPersonCell
        //        }
        //        else {
        let householdCell = tableView.dequeueReusableCell(withIdentifier: "ManageMyHouseholdDeviceCell") as! ManageMyHouseholdDeviceCell
        let profileModel = self.arrProfiles?[indexPath.row]
        householdCell.setUpCellData(profileDetail: profileModel?.profile)
        householdCell.btnDeleteProfile.addTarget(self, action: #selector(deleteProfileAction(sender:)), for: .touchUpInside)
        householdCell.btnViewProfileDevice.addTarget(self, action: #selector(viewProfileAction(sender:)), for: .touchUpInside)
        householdCell.btnDeleteProfile.tag = indexPath.row
        householdCell.btnViewProfileDevice.tag = indexPath.row
        //For iPod
        if currentScreenHeight < xibDesignHeight {
            handleFontSizeForSmallerScreen(label: householdCell.lblProfileName,fontFamily: "Regular-Medium", fontSize: 20.0)
        }
        tableView.separatorColor = UIColor(cgColor: CGColor(red: 152.0, green: 150.0, blue: 150.0, alpha: 1))
        return householdCell
        //        }
    }
    
   
    /* CMAIOS-1191 */
    /// Check totalContentHeight = no of cells, addPerson button, title, titleBuffer heights to determine the top header space
    /// - Returns: Buffer height for tableview header
    private func calculateHeaderHeight() -> CGFloat {
        var headerHeight = ManageHouseConstants.defaultHeight
        var totalContentHeight = ManageHouseConstants.defaultHeight
        let profileTableViewHeight = self.profileTableView.frame.height
        if arrProfiles?.count ?? 0 > 0 {
            totalContentHeight = Double(arrProfiles?.count ?? 0) * ManageHouseConstants.cellRowHeight
            totalContentHeight += self.viewAddPersonFooter.frame.height
            totalContentHeight += ManageHouseConstants.titleHeightBuffer
            totalContentHeight += self.viewTitleHeader.frame.height
            
            switch (totalContentHeight >= profileTableViewHeight, totalContentHeight < profileTableViewHeight) {
            case (true, _): // Long List UI (Close button view shadow, Scrolling Add person section, Scrolling Title)
                headerHeight = ManageHouseConstants.defaultHeight
            case (_, true): // No Long List, Should be validated profileTableView - totalContentHeight
                let computedHeight = profileTableViewHeight - totalContentHeight
                if computedHeight > ManageHouseConstants.defaultHeight { // assign computedHeight to top section space
                    headerHeight = computedHeight
                }
            default: break
            }
        } else {
            return headerHeight
        }
        checkAndDisableScroll(headerHeight: headerHeight)
        return headerHeight
    }
    
    /* CMAIOS-1191 */
    private func calculateSectionFooter() -> CGFloat {
        return ManageHouseConstants.defaultHeight
    }
    
    /// Set scroll compatibility for tableview depending on List
    /// - Parameter headerHeight: Used to add shadow for close button view for long list
    private func checkAndDisableScroll(headerHeight: CGFloat) {
        if headerHeight <= ManageHouseConstants.defaultHeight { // Add top shadow for Long List
            self.shadowView.layer.shadowOpacity = 0.5
            self.profileTableView.alwaysBounceVertical = true
            self.profileTableView.isScrollEnabled = true
        } else { // Remove top shadow for Non Long List
            self.shadowView.layer.shadowOpacity = 0
            self.profileTableView.alwaysBounceVertical = false
            self.profileTableView.isScrollEnabled = false
        }
    }
}

struct ManageHouseConstants {
    static let cellRowHeight = 90.0
    static let titleHeightBuffer = 20.0
    static let defaultHeight = 0.0
}


extension UITableView {
    var visibleCurrentCellIndexPath: [Int] {
        var indexes: [IndexPath] = []
        for cell in self.visibleCells {
            if let index = self.indexPath(for: cell) {
                if index.row != 0 { // Not to check the first row as first row is not clickable, its just the header
                    let cellRect = self.rectForRow(at: index)
                    let isVisible = self.bounds.contains(cellRect)
                    if isVisible {
                        indexes.append(index)
                    }
                }
            }
        }
        return indexes.compactMap { $0.row }
    }
}
