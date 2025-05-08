//
//  HomeScreenViewController+CollectionView.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 11/10/22.
//

import Foundation
import UIKit
import Lottie
import SafariServices
import GoogleMobileAds

extension HomeScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == spotlightCollectionView {
            if CurrentDevice.forLargeSpotlights() {
                return CGSize(width: 350, height: 400)
            } else {
                //let cardWidth = (312/xibDesignWidth)*currentScreenWidth
               // if currentScreenWidth < xibDesignWidth {
                    return CGSize(width: 312, height: 200)
//                } else {
//                    return CGSize(width: cardWidth, height: 200)
//                }
            }
        } else {
            return CGSize(width: 100, height: 140)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if collectionView != spotlightCollectionView {
//            let dCell = cell as! DeviceCollectionViewCell
//            dCell.setStatus(status: dCell.profileModel.status)
//            dCell.animationView.play()
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == spotlightCollectionView {
            return SpotLightsManager.shared.arrSpotLights.count
        }
        return allProfiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == spotlightCollectionView {
            if CurrentDevice.forLargeSpotlights() { /// Large screen Template
                let type = SpotLightsManager.shared.getTemplateTypeAndPriority(card: SpotLightsManager.shared.arrSpotLights[indexPath.row]).templateType
                switch type {
                case .one:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightOneLarge", for: indexPath) as? SpotLightOneLarge else { return UICollectionViewCell() }
                    self.configureTypeOneCellLarge(cardOneType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .two:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightTwoLarge", for: indexPath) as? SpotLightTwoLarge else { return UICollectionViewCell() }
                    self.configureTypeTwoCellLarge(cardTwoType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .three:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightThreeLarge", for: indexPath) as? SpotLightThreeLarge else { return UICollectionViewCell() }
                    self.configureTypeThreeCellLarge(cardThreeType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .four:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightFourLarge", for: indexPath) as? SpotLightFourLarge else { return UICollectionViewCell() }
                    self.configureTypeFourCellLarge(cardFourType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .outageFound:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutageFoundCollectionViewCellLarge", for: indexPath) as? OutageFoundCollectionViewCellLarge else { return UICollectionViewCell() }
                    self.configureOutageFoundCellLarge(cardType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .outageClear:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutageDetectedCollectionViewCellLarge", for: indexPath) as? OutageDetectedCollectionViewCellLarge else { return UICollectionViewCell() }
                    self.configureOutageDetectedCellLarge(cardType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                }
                
            } else { /// Small screen Template
                let type = SpotLightsManager.shared.getTemplateTypeAndPriority(card: SpotLightsManager.shared.arrSpotLights[indexPath.row]).templateType
                switch type {
                case .one:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightOneSmall", for: indexPath) as? SpotLightOneSmall else { return UICollectionViewCell() }
                    self.configureTypeOneCellSmall(cardOneType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell:cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .two:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightTwoSmall", for: indexPath) as? SpotLightTwoSmall else { return UICollectionViewCell() }
                    self.configureTypeTwoCellSmall(cardTwoType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .three:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightThreeSmall", for: indexPath) as? SpotLightThreeSmall else { return UICollectionViewCell() }
                    self.configureTypeThreeCellSmall(cardThreeType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .four:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightFourSmall", for: indexPath) as? SpotLightFourSmall else { return UICollectionViewCell() }
                    self.configureTypeFourCellSmall(cardFourType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .outageFound:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutageFoundCollectionViewCellSmall", for: indexPath) as? OutageFoundCollectionViewCellSmall else { return UICollectionViewCell() }
                    self.configureOutageFoundCellSmall(cardType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                case .outageClear:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutageDetectedCollectionViewCellSmall", for: indexPath) as? OutageDetectedCollectionViewCellSmall else { return UICollectionViewCell() }
                    self.configureOutageDetectedCellSmall(cardType: SpotLightsManager.shared.arrSpotLights[indexPath.row], cell: cell)
                    cell.contentView.alpha = 1.0
                    cell.tag = indexPath.row
                    return cell
                }
                
            }
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCollectionViewCell", for: indexPath) as? DeviceCollectionViewCell else { return UICollectionViewCell() }
            cell.configureCell(profile: allProfiles[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != spotlightCollectionView  {
            movingOutOfHomeScreen()
            //need to start ScreenNavs rules if ten second rule is not completed and user is moving out of home screen
            QualtricsManager.shared.startWithScreenNavsRule()
            ProfileManager.shared.isFirstUserCompleted = true
            if  MyWifiManager.shared.isSmartWifi()  && !MyWifiManager.shared.isSplitSSID(){
                // Nav to Details
                isProfileTap = true
                let selectedCell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0))
                let profileModel = allProfiles[indexPath.row]
                if MyWifiManager.shared.getMyWifiStatus() == .backendFailure {
                    self.navigateToMyWifiViewScreen()
                } else {
                    //Animate ProfileAvatarIcon
                    addImageViewAsSubview(selectedView:selectedCell,profileModel: profileModel, animateFromVC: AnimateFrom.Home) { isStaticScreen  in
                        self.navigateToViewProfileScreen(currentSelectedIndex: indexPath.row)
                    }
                }
            } else {
                guard let profileVC = ProfileNameViewController.instantiate() else { return }
                guard let profileObj = allProfiles[indexPath.row].profile else { return }
                profileVC.state = .edit(profileObj)
                profileVC.profile = profileObj
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        } else {
            // CMAIOS-2093, CMAIOS-2090, CMAIOS-2077 Tapping the card should go to respective screens if tap target only present for those spotlights (B&W template)
            if SpotLightsManager.shared.arrSpotLights.isEmpty {
                return //To resolve the crash on Gad and thank you card suppression rules
            }
            let type = SpotLightsManager.shared.getTemplateTypeAndPriority(card: SpotLightsManager.shared.arrSpotLights[indexPath.row]).templateType
            if CurrentDevice.forLargeSpotlights() { /// Large screen Template
                switch type {
                case .one, .two, .four, .outageClear, .outageFound:
                    return
                case .three:
                    guard let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? SpotLightThreeLarge else { return }
                    if cell.buttonView.isHidden && !cell.tapTarget.isEmpty {
                        self.checkReAuthAndNavigate(!cell.crossImage.isHidden, spotlightId: cell.spotlightId, cardName: cell.accountName, tapTarget: cell.tapTarget, selectedRow: cell.tag)
                    }
                }
            } else { /// Small screen Template
                switch type {
                case .one, .two, .four, .outageClear, .outageFound:
                    return
                case .three:
                    guard let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? SpotLightThreeSmall else { return }
                    if cell.buttonView.isHidden && !cell.tapTarget.isEmpty {
                        self.checkReAuthAndNavigate(!cell.closeImage.isHidden, spotlightId: cell.spotlightId, cardName: cell.accountName, tapTarget: cell.tapTarget, selectedRow: cell.tag)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == spotlightCollectionView {
            return UIEdgeInsets(top: 0, left: self.getSpotLightCardsInsets(), bottom: 0, right: self.getSpotLightCardsInsets())
        }
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func fetchProfilesList() {
        DispatchQueue.main.async {
            ProfileModelHelper.shared.getAllAvailableProfiles { profiles in
                self.allProfiles = profiles ?? []
                DispatchQueue.main.async {
                    self.reloadCollectionView()
                }
            }
        }
    }
    
    func reloadCollectionView() {
        UIView.performWithoutAnimation {
//            DispatchQueue.main.async {
                self.collectionView.reloadData()
//            }
        }
    }
       
    func updateProfileErrorMessageView() {
        //Main thread
        DispatchQueue.main.async {
            if self.allProfiles.count == 0 {
                self.collectionView.isHidden = true
                self.profileErrorMessageView.isHidden = false
                CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : ErrorScreenDetails.ERROR_HOME_PROFILES_FAILED.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR_TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.General.rawValue ])
            } else {
                self.collectionView.isHidden = false
                self.profileErrorMessageView.isHidden = true
            }
        }
    }
    
    /* CMAIOS-1202 */
    func getSpotLightCardsInsets() -> CGFloat {
        var defaultInset = 20.0
        if CurrentDevice.forLargeSpotlights() {
            let getPadding = currentScreenWidth - 350
            switch (SpotLightsManager.shared.arrSpotLights.count > 1, SpotLightsManager.shared.arrSpotLights.count == 1) {
            case (true, _):
                if getPadding > 0 {
                    if getPadding <= 50 && getPadding >= 40 { // Buffer 10 pts
                        defaultInset = 15.0
                    }
                }
            case (_, true):
                if getPadding > 0 {
                    defaultInset = getPadding / 2
                }
            default: break
            }
        } else {
            let getPadding = currentScreenWidth - 312
            switch (SpotLightsManager.shared.arrSpotLights.count > 1, SpotLightsManager.shared.arrSpotLights.count == 1) {
            case (true, _):
                if getPadding > 0 {
                    defaultInset = 20.0
                }
            case (_, true):
                if getPadding > 0 {
                    defaultInset = getPadding / 2
                }
            default: break
            }
        }
        return defaultInset
    }
    
    //CMAIOS-1967 card dismiss animation
    func closeBtnOnSpotlightCardTapped(spotLightId: String, template: SpotLightTemplate, cellType: UICollectionViewCell, cardName: String) {
        var cell = cellType
        let yPosition = CurrentDevice.forLargeSpotlights() ? 600.0 : 400.0
        let yPositionForTopAnimation = CurrentDevice.forLargeSpotlights() ? (currentScreenWidth <= 393 ? -18.0 : -25.0) : -10.0
        //CMAIOS-1967 to perform spotlight animation in upword direction
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            cell.frame.origin.y = yPositionForTopAnimation
        }
        //CMAIOS-1967 to perform spotlight dismiss animation
        UIView.animate(withDuration: 1.0, delay: 0.4) {
            cell.transform = CGAffineTransform(translationX: cell.contentView.frame.origin.x, y: yPosition)
        }
    completion: { _ in
        if !SpotLightsManager.shared.arrSpotLights.isEmpty {
            var selectedItem = cell.tag
            cell.contentView.alpha = 0
            //CMAIOS-2458: Below code is for updating the cell tag of items that are present on the RHS when we dismiss a cell item
            var cellCount = 0
            //CMAIOS-2685, 2674 issue fix
            let remainingCellCount = (SpotLightsManager.shared.arrSpotLights.count) - 1
            for i in selectedItem..<remainingCellCount {
                if let cell = self.spotlightCollectionView.cellForItem(at: IndexPath(row: selectedItem + i, section: 0)) {
                    cell.tag = selectedItem + cellCount
                    cellCount += 1
                }
            }
            //
            self.spotlightCollectionView.performBatchUpdates({
                //CMAIOS-2458: remaining cell count will be zero if only two cells are present after cell item dismiss. Passing default value
                let removeItem = remainingCellCount == 0 ? 0 : selectedItem
                //
                SpotLightsManager.shared.arrSpotLights.remove(at: removeItem)
                self.arrAnimatedSpotlights.remove(at: removeItem)
                self.hideDismissedSpotlightcards(spotLightId: spotLightId, cardName: cardName)
                self.spotlightCollectionView.deleteItems(at: [IndexPath(row: selectedItem, section: 0)])
                //CMAIOS-1967 spotlight animation direction as per prototype
                if selectedItem != SpotLightsManager.shared.arrSpotLights.count {
                    self.spotlightCollectionView.moveItem(at: IndexPath(row: selectedItem + 1, section: 0) , to: IndexPath(row: selectedItem, section: 0))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    if SpotLightsManager.shared.arrSpotLights.isEmpty {
                        SpotLightsManager.shared.configureSpotLightsForThankYou()
                    }
                    self.spotlightCollectionView.reloadData()
                }
            })
        }
    }
    }
}

extension HomeScreenViewController {
    
    // MARK: - Navigate to ViewProfileDetailScreen(with or without devices)
    func navigateToViewProfileScreen(currentSelectedIndex: Int) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "ManageMyHousehold", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewProfileWithDeviceViewController") as! ViewProfileWithDeviceViewController
            vc.delegate = self
          //  ProfileModelHelper.shared.getAllAvailableProfiles(completion: { profiles in
            vc.arrProfiles = ProfileModelHelper.shared.profiles
                vc.currentSelectedIndex = currentSelectedIndex
                self.navigationController?.pushViewController(vc, animated: false)
         //   })
        }
    }
    
    func navigateToMyWifiViewScreen() {
        let viewController = UIStoryboard(name: "WiFiScreen", bundle: nil).instantiateViewController(identifier: "MyWiFiScreen") as MyWiFiViewController
//        viewController.shiftID = "MyWiFiScreen"
//        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - Spotlight Cells Data
extension HomeScreenViewController {
//    func configureTypeOneADCellLarge(cardOneType:SpotLightCards, cell:SpotLightOneLarge) {
//        cell.containerView.isHidden = true
//        cell.customAdView.isHidden = false
//        cell.customAdView.rootViewController = self
//        DispatchQueue.main.async {
//            cell.customAdView.load(GADRequest())
//        }
//    }

    func configureTypeOneCellLarge(cardOneType:SpotLightCards, cell:SpotLightOneLarge) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardOneType)
        cell.title.text = cardData.title
        cell.spotlightId = cardData.spotLightId
        if cardOneType == .adType && SpotLightsManager.shared.adLoadingComplete {
           // cell.adLoader = GADAdLoader(adUnitID: ConfigService.shared.ad_id, rootViewController: self, adTypes: [.customNative], options: nil)
            DispatchQueue.main.async {
                //cell.adLoader.load(GADRequest())
                cell.loadGoogleAdViews()
            }
            //cell.adLoader.delegate = cell
            cell.callToActionView.addTarget(self, action: #selector(adButtonClick(_:)), for: .touchUpInside)
            cell.containerView.isHidden = true
            //cell.customAdView.isHidden = false
            return
        } else {
            cell.containerView.isHidden = false
            cell.customAdView.isHidden = true
            //CMAIOS-2511 Added icon size fix
            if cardOneType == .stream_install {
                cell.iconImage.contentMode = .scaleAspectFit
                cell.imagetopConstraint.constant = 45
                cell.imageHeightConstraint.constant = 120
            } else {
                cell.iconImage.contentMode = .bottom
                cell.imagetopConstraint.constant = 30
                cell.imageHeightConstraint.constant = 133
            }
        }
        if cardData.subtitle.isEmpty {
            cell.subTitle.isHidden = true
        } else {
            cell.subTitle.isHidden = false
                //verify
//            if cardOneType == .scheduledOneTimePayment {
//                var subTitle = cardData.subtitle
//                subTitle = subTitle.replacingOccurrences(of: "\n", with: " ")
//                subTitle = subTitle.replacingOccurrences(of: "on", with: "\non")
//                cell.subTitle.text = subTitle
//            } else {
                cell.subTitle.text = cardData.subtitle
//            }
        }
        //verify
        if !cell.spotlightId.isEmpty {
            cell.titleStackViewLeadingConstraint.constant = 22.5
            cell.titleStackViewTrailingConstraint.constant = 22.5
        } else {
            cell.titleStackViewLeadingConstraint.constant = 25
            cell.titleStackViewTrailingConstraint.constant = 25
        }
        
        if cardData.imageName.isEmpty {
            cell.iconImage.isHidden = true
        } else {
            cell.iconImage.isHidden = false
            cell.iconImage.image = UIImage(named: cardData.imageName)
        }
        
        if cardData.button.isEmpty {
            cell.actionButton.isHidden = true
        } else {
            cell.actionButton.isHidden = false
            //CMAIOS-2356 remove target to disable re-usability
            cell.actionButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.actionButton.setTitle(cardData.button, for: .normal)
            if cardData.imageName.lowercased().contains("offline_extender") {
                cell.actionButton.addTarget(self, action: #selector(self.letsFixItOfflineExtender), for: .touchUpInside)
            } else if cardData.imageName.lowercased().contains("weak_extender") {
                cell.actionButton.addTarget(self, action: #selector(self.letsFixItWeakExtender), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("dead zones") {
                cell.actionButton.addTarget(self, action: #selector(self.getExtender), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("cleared") {
                cell.actionButton.addTarget(self, action: #selector(self.moreInfoBtnTapped), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("outage in your area") {
                cell.actionButton.addTarget(self, action: #selector(self.moreInfoBtnTapped), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("optimum stream") {//CMAIOS-2330
                cell.actionButton.addTarget(self, action: #selector(self.optimumStreamInstallNow), for: .touchUpInside)
            } else {
                cell.actionButton.addTarget(self, action: #selector(self.letsfixedAction(_:)), for: .touchUpInside)
            }
        }
        cell.containerView.backgroundColor = cardData.color
        if cardData.color != UIColor.white {
            cell.title.textColor = .white
            cell.subTitle.textColor = .white
        } else {
            cell.title.textColor = .black
            cell.subTitle.textColor = .black
        }
    }
    
//    func configureTypeOneADCellSmall(cardOneType:SpotLightCards, cell:SpotLightOneSmall) {
//        cell.containerView.isHidden = true
//        cell.customAdView.isHidden = false
//        cell.customAdView.backgroundColor = .clear
//        cell.customAdView.rootViewController = self
//        cell.customAdView.backgroundColor = .white
//        DispatchQueue.main.async {
//            cell.customAdView.load(GADRequest())
//        }
//    }
    
    func configureTypeOneCellSmall(cardOneType:SpotLightCards, cell:SpotLightOneSmall) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardOneType)
        cell.title.text = cardData.title
        cell.spotlightId = cardData.spotLightId
        if cardOneType == .adType && SpotLightsManager.shared.adLoadingComplete {
           // cell.adLoader = GADAdLoader(adUnitID: ConfigService.shared.ad_id, rootViewController: self, adTypes: [.customNative], options: nil)
            DispatchQueue.main.async {
                cell.loadGoogleAdViews()
            }
            //cell.adLoader.delegate = cell
            cell.containerView.isHidden = true
            cell.callToActionView.addTarget(self, action: #selector(adButtonClick(_:)), for: .touchUpInside)
         //   cell.customAdView.isHidden = false
        } else {
            cell.containerView.isHidden = false
            cell.customAdView.isHidden = true
            if cardOneType == .stream_install {
                cell.iconImage.contentMode = .scaleAspectFit
                cell.imageLeadingConstraint.constant = 10
                cell.imageHeightConstraint.constant = 100
                cell.imagetopConstraint.constant = 45
                cell.imageTrailingConstraint.constant = 20
            }
        }
        if cardData.subtitle.isEmpty {
            cell.subTitle.isHidden = true
        } else {
            cell.subTitle.isHidden = false
            cell.subTitle.text = cardData.subtitle
        }
        
        if cardData.imageName.isEmpty {
            cell.iconImage.isHidden = true
        } else {
            cell.iconImage.isHidden = false
            cell.iconImage.image = UIImage(named: cardData.imageName)
        }
        
        if cardData.button.isEmpty {
            cell.actionButton.isHidden = true
        } else {
            cell.actionButton.isHidden = false
            //CMAIOS-2356 remove target to disable re-usability
            cell.actionButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.actionButton.setTitle(cardData.button, for: .normal)
            if cardData.imageName.lowercased().contains("offline_extender") {
                cell.actionButton.addTarget(self, action: #selector(self.letsFixItOfflineExtender), for: .touchUpInside)
            } else if cardData.imageName.lowercased().contains("weak_extender") {
                cell.actionButton.addTarget(self, action: #selector(self.letsFixItWeakExtender), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("dead zones") {
                cell.actionButton.addTarget(self, action: #selector(self.getExtender), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("cleared") {
                cell.actionButton.addTarget(self, action: #selector(self.moreInfoBtnTapped), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("outage in your area") {
                cell.actionButton.addTarget(self, action: #selector(self.moreInfoBtnTapped), for: .touchUpInside)
            } else if cardData.title.lowercased().contains("optimum stream") { //CMAIOS-2330
                cell.actionButton.addTarget(self, action: #selector(self.optimumStreamInstallNow), for: .touchUpInside)
            } else {
                cell.actionButton.addTarget(self, action: #selector(self.letsfixedAction(_:)), for: .touchUpInside)
            }
        }
        cell.containerView.backgroundColor = cardData.color
        if cardData.color != UIColor.white {
            cell.title.textColor = .white
            cell.subTitle.textColor = .white
        } else {
            cell.title.textColor = .black
            cell.subTitle.textColor = .black
        }
    }
    func configureTypeTwoCellLarge(cardTwoType:SpotLightCards, cell:SpotLightTwoLarge) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardTwoType)
        //verify
//        if cardTwoType == .scheduledPaymentDidExpire ||  cardTwoType == .scheduledPaymentWillExpire {
//            cell.stackViewLeadingConstraint.constant = 25
//            cell.stackViewTrailingConstraint.constant = 25
//        }
        cell.title.text = cardData.title
        cell.spotlightId = cardData.spotLightId
        cell.tapTarget = cardData.tapTarget
        if cardData.subtitle.isEmpty {
            cell.subTitle.isHidden = true
           
        } else {
            cell.subTitle.isHidden = false
            cell.subTitle.text = cardData.subtitle
           }
        
        if cardData.imageName.isEmpty {
            cell.iconImage.isHidden = true
        } else {
            cell.iconImage.isHidden = false
            cell.iconImage.image = UIImage(named: cardData.imageName)
        }
        
        if cardData.button.isEmpty {
            cell.actionButton.isHidden = true
        } else {
            cell.actionButton.isHidden = false
            cell.actionButton.setTitle(cardData.button, for: .normal)
            cell.handler = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
        }
        
        if cardData.amount.isEmpty {
            cell.amountLabel.isHidden = true
            cell.btnActionTrailingConstraint.constant = (cell.frame.width - cell.actionButton.frame.width) / 2
        } else {
            cell.amountLabel.isHidden = false
            cell.amountLabel.text = cardData.amount
            cell.btnActionTrailingConstraint.constant = 30.0
        }
        
        cell.topView.backgroundColor = cardData.topColor
        cell.bottomView.backgroundColor = cardData.bottomColor
        cell.helperView.backgroundColor = cardData.bottomColor
    }
    func configureTypeTwoCellSmall(cardTwoType:SpotLightCards, cell:SpotLightTwoSmall) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardTwoType)
        cell.title.text = cardData.title
        cell.spotlightId = cardData.spotLightId
        cell.tapTarget = cardData.tapTarget
        if cardData.subtitle.isEmpty {
            cell.subTitle.isHidden = true
            //verify
//            if cardTwoType == .billPastDue{
//                cell.topStack.alignment = .center
//            } else {
               cell.topStack.alignment = .top
//            }
        } else {
            cell.subTitle.isHidden = false
            cell.subTitle.text = cardData.subtitle
            cell.topStack.alignment = .top
        }
        
        if cardData.imageName.isEmpty {
            cell.iconImage.isHidden = true
        } else {
            cell.iconImage.isHidden = false
            cell.iconImage.image = UIImage(named: cardData.imageName)
        }
        
        if cardData.button.isEmpty {
            cell.actionButton.isHidden = true
        } else {
            cell.actionButton.isHidden = false
            cell.actionButton.setTitle(cardData.button, for: .normal)
            cell.handler = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
        }
        
        if cardData.amount.isEmpty {
            cell.amountLabel.isHidden = false
            cell.amountLabel.text = ""
        } else {
            cell.amountLabel.text = cardData.amount
        }
        cell.headerView.backgroundColor = cardData.topColor
        cell.bottomView.backgroundColor = cardData.bottomColor
        cell.helperView.backgroundColor = cardData.bottomColor
    }
    
    func configureTypeThreeCellLarge(cardThreeType:SpotLightCards, cell:SpotLightThreeLarge) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardThreeType)
        cell.crossButton.isHidden = !cardData.dismissible
        cell.crossImage.isHidden = !cardData.dismissible
        cell.spotlightId = cardData.spotLightId
        cell.tapTarget = cardData.tapTarget
        cell.accountName = cardData.accountName
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        if cardData.tapTarget == "appbpromo" {
            APIRequests.shared.spotlightId = cardData.spotLightId
            cell.billView.isHidden = true
            cell.discountView.isHidden = false
            paragraphStyle.lineHeightMultiple = 1.2
            cell.billImageView.image = UIImage(named: cardData.imageName)
            if !cardData.title.isEmpty {
                cell.discountTitleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.discountTitleLabel.text = ""
            }
            if !cardData.subtitle.isEmpty {
                cell.discountSubTitleLabel.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.discountSubTitleLabel.isHidden = true
            }
            if cardData.button.isEmpty {
                cell.moreInfoBtnView.isHidden = true
            } else {
                cell.moreInfoBtnView.isHidden = false
                cell.btnMoreInfo.setTitle(cardData.button, for: .normal)
                cell.handler2 = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
            }
        } else {
            cell.billView.isHidden = false
            cell.discountView.isHidden = true
            if cardData.color == midnightBlueRGB {
                cell.backgroundColor = cardData.color
                cell.titleLabel.textColor = .white
                cell.subTitle.textColor = .white
            } else {
                cell.backgroundColor = .white
                cell.titleLabel.textColor = .black
                cell.subTitle.textColor = .black
            }
            if cardData.imageName.isEmpty {
                cell.billImageView.isHidden = true
            } else {
                cell.billImageView.isHidden = false
                cell.billImageView.image = UIImage(named: cardData.imageName)
            }
            if !cardData.title.isEmpty {
                paragraphStyle.lineHeightMultiple = 1.2
                cell.titleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.titleLabel.text = ""
            }
            if !cardData.subtitle.isEmpty {
                paragraphStyle.lineHeightMultiple = 1.2
                cell.subTitle.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.subTitle.isHidden = true
            }
            if cardData.button.isEmpty {
                cell.buttonView.isHidden = true
            } else {
                cell.buttonView.isHidden = false
                cell.actionButton.setTitle(cardData.button, for: .normal)
                cell.handler1 = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
            }
        }
        if cardData.dismissible {
            cell.handler = {self.closeBtnOnSpotlightCardTapped(spotLightId: cardData.spotLightId, template: .three, cellType: cell, cardName: cardData.accountName)}
        }
        cell.layoutIfNeeded()
    }
    
    func configureTypeThreeCellSmall(cardThreeType:SpotLightCards, cell:SpotLightThreeSmall) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardThreeType)
        cell.closeImage.isHidden = !cardData.dismissible
        cell.closeButton.isHidden = !cardData.dismissible
        cell.spotlightId = cardData.spotLightId
        cell.tapTarget = cardData.tapTarget
        cell.accountName = cardData.accountName
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
            paragraphStyle.lineHeightMultiple = 1.14
        if cardData.tapTarget == "appbpromo" {
            APIRequests.shared.spotlightId = cardData.spotLightId
            paragraphStyle.lineHeightMultiple = 1.2
            cell.billView.isHidden = true
            cell.discountView.isHidden = false
            cell.discountImageView.image = UIImage(named: cardData.imageName)
            if !cardData.title.isEmpty {
                cell.discountTitleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.discountTitleLabel.text = ""
            }
            if !cardData.subtitle.isEmpty {
                cell.discountSubTitleLabel.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.discountSubTitleLabel.text = ""
            }
            if cardData.button.isEmpty {
                cell.moreInfoBtnView.isHidden = true
            } else {
                cell.moreInfoBtnView.isHidden = false
                cell.btnMoreInfo.setTitle(cardData.button, for: .normal)
                cell.handler2 = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
            }
        } else {
            cell.billView.isHidden = false
            cell.discountView.isHidden = true
            if cardData.color == midnightBlueRGB {
                cell.backgroundColor = cardData.color
                cell.titleLabel.textColor = .white
                cell.subTitle.textColor = .white
                cell.topConstraint.constant = 40.0
            } else {
                cell.backgroundColor = .white
                cell.titleLabel.textColor = .black
                cell.subTitle.textColor = .black
                cell.topConstraint.constant = 50.0
            }
            if cardData.imageName.isEmpty {
                cell.billImageView.isHidden = true
            } else {
                cell.billImageView.isHidden = false
                cell.billImageView.image = UIImage(named: cardData.imageName)
            }
            if !cardData.title.isEmpty {
                cell.titleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.titleLabel.text = ""
            }
            if !cardData.subtitle.isEmpty {
                cell.subTitle.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            } else {
                cell.subTitle.text = ""
            }
            if cardData.button.isEmpty {
                cell.buttonView.isHidden = true
                cell.subTitleToSuperView.priority = UILayoutPriority(999)
                cell.subTitleToButtonView.priority = UILayoutPriority(200)
            } else {
                cell.buttonView.isHidden = false
                cell.subTitleToSuperView.priority = UILayoutPriority(200)
                cell.subTitleToButtonView.priority = UILayoutPriority(999)
                cell.crossViewLabel.text = cardData.button
                cell.handler1 = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
            }
        }
        if cardData.dismissible {
            cell.handler = {self.closeBtnOnSpotlightCardTapped(spotLightId: cardData.spotLightId, template: .three, cellType: cell, cardName: cardData.accountName)}
        }
        cell.layoutIfNeeded()
    }
    
    func configureTypeFourCellLarge(cardFourType:SpotLightCards, cell:SpotLightFourLarge) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardFourType)
        cell.titleLabel.text = cardData.title
        if !cardData.title.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            paragraphStyle.alignment = .center
            cell.titleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            cell.titleLabel.text = ""
        }
        cell.closeButton.isHidden = !cardData.dismissible
        cell.closeImage.isHidden = !cardData.dismissible
        cell.spotlightId = cardData.spotLightId
        cell.tapTarget = cardData.tapTarget
        if !cardData.imageName.isEmpty {
            cell.billImageView.isHidden = false
            cell.billImageView.image = UIImage(named: cardData.imageName)
        } else {
            cell.billImageView.isHidden = true
        }
        
        if !cardData.button.isEmpty {
            cell.actionButton.isHidden = false
            cell.actionButton.setTitle(cardData.button, for: .normal)
            cell.handler1 = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
        } else {
            cell.actionButton.isHidden = true
        }
        if cardData.dismissible {
            cell.handler = {self.closeBtnOnSpotlightCardTapped(spotLightId: cardData.spotLightId, template: .four, cellType: cell, cardName: cardData.accountName)}
        }
        cell.layoutIfNeeded()
    }
    
    func configureOutageFoundCellLarge(cardType:SpotLightCards, cell:OutageFoundCollectionViewCellLarge) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardType)
        cell.outageActionButton.layer.cornerRadius = 15
        cell.outageActionButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        cell.outageActionButton.layer.borderWidth = 1.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .center
        //CMAIOS-2698 Removed extra leading space before text
        cell.outageSubTitleLabel.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        cell.outageTitleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        cell.outageImageView.image = UIImage(named: cardData.imageName)
        if !cardData.button.isEmpty {
            cell.outageActionButton.isHidden = false
            cell.outageActionButton.setTitle(cardData.button, for: .normal)
            cell.handler = {self.navigateToOutageMoreInfo(cardData: cardData.spotlightCardData, selectedRow: cell.tag, accountName: cardData.accountName)}
        } else {
            cell.outageActionButton.isHidden = true
        }
        cell.layoutIfNeeded()
    }
    
    func configureTypeFourCellSmall(cardFourType:SpotLightCards, cell:SpotLightFourSmall) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardFourType)
        cell.titleLabel.text = cardData.title
        if !cardData.title.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.14
            //CMAIOS-2366 Fixed title text alignment issue
            paragraphStyle.alignment = .left
            cell.titleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            cell.titleLabel.text = ""
        }
        cell.closeButton.isHidden = !cardData.dismissible
        cell.closeImage.isHidden = !cardData.dismissible
        cell.spotlightId = cardData.spotLightId
        cell.tapTarget = cardData.tapTarget
        if !cardData.imageName.isEmpty {
            cell.billImageView.isHidden = false
            cell.billImageView.image = UIImage(named: cardData.imageName)
        } else {
            cell.billImageView.isHidden = true
        }
        cell.titleLabel.isHidden = false
        cell.topViewConstraint.constant = 50.0
        cell.imageTrailingConstraint.constant = 15.0
        cell.actionButton.isHidden = false
        if !cardData.button.isEmpty {
            cell.actionButton.isHidden = false
            cell.actionButton.setTitle(cardData.button, for: .normal)
            cell.handler1 = {self.checkReAuthAndNavigate(cardData.dismissible, spotlightId: cardData.spotLightId, cardName: cardData.accountName, tapTarget: cardData.tapTarget, selectedRow: cell.tag)}
        } else {
            cell.actionButton.isHidden = true
        }
        if cardData.dismissible {
            cell.handler = {self.closeBtnOnSpotlightCardTapped(spotLightId: cardData.spotLightId, template: .four, cellType: cell, cardName: cardData.accountName)}
        }
        cell.layoutIfNeeded()
    }
    
    func configureOutageFoundCellSmall(cardType:SpotLightCards, cell:OutageFoundCollectionViewCellSmall) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardType)
        cell.outageActionButton.layer.cornerRadius = 15
        cell.outageActionButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        cell.outageActionButton.layer.borderWidth = 1.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
        cell.outageSubTitleLabel.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        cell.outageTitleLabel.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        if !cardData.button.isEmpty {
            cell.outageActionButton.isHidden = false
            cell.outageActionButton.setTitle(cardData.button, for: .normal)
            cell.handler = {self.navigateToOutageMoreInfo(cardData: cardData.spotlightCardData, selectedRow: cell.tag, accountName: cardData.accountName)}
        } else {
            cell.outageActionButton.isHidden = true
        }
        cell.layoutIfNeeded()
        
    }
    
    func configureOutageDetectedCellSmall(cardType:SpotLightCards, cell:OutageDetectedCollectionViewCellSmall) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardType)
        cell.dismissView.isHidden = !cardData.dismissible
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
        if cardData.button.isEmpty {
            cell.outageDetectedView.isHidden = false
            cell.outageClearedView.isHidden = true
            cell.outageTitle.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            cell.outageSubTitle.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            cell.outageDetectedView.isHidden = true
            cell.outageClearedView.isHidden = false
            cell.outageClearedTitle.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            if !cardData.button.isEmpty {
                cell.btnMoreInfo.isHidden = false
                cell.btnMoreInfo.setTitle(cardData.button, for: .normal)
                cell.handler = {self.navigateToOutageMoreInfo(cardData: cardData.spotlightCardData, selectedRow: cell.tag, accountName: cardData.accountName)}
            } else {
                cell.btnMoreInfo.isHidden = true
            }
        }
        cell.outageImageView.image = UIImage(named: cardData.imageName)
        if cardData.dismissible {
            cell.handler1 = {self.closeBtnOnSpotlightCardTapped(spotLightId: cardData.spotLightId, template: .outageClear, cellType: cell, cardName: cardData.accountName)}
        }
        cell.layoutIfNeeded()
    }
    
    func configureOutageDetectedCellLarge(cardType:SpotLightCards, cell:OutageDetectedCollectionViewCellLarge) {
        let cardData = SpotlightMessages.getMessageT(cardType: cardType)
        cell.dismissView.isHidden = !cardData.dismissible
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .center
        
        if cardData.button.isEmpty {
            cell.outageDetectedView.isHidden = false
            cell.outageClearedView.isHidden = true
            cell.outageTitle.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            cell.outageSubTitle.attributedText = NSMutableAttributedString(string: cardData.subtitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        } else {
            cell.outageDetectedView.isHidden = true
            cell.outageClearedView.isHidden = false
            cell.outageClearedTitle.attributedText = NSMutableAttributedString(string: cardData.title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            if !cardData.button.isEmpty {
                cell.btnMoreInfo.isHidden = false
                cell.btnMoreInfo.setTitle(cardData.button, for: .normal)
                cell.handler = {self.navigateToOutageMoreInfo(cardData: cardData.spotlightCardData, selectedRow: cell.tag, accountName: cardData.accountName)}
            } else {
                cell.btnMoreInfo.isHidden = true
            }
        }
        cell.outageImageView.image = UIImage(named: cardData.imageName)
        if cardData.dismissible {
            cell.handler1 = {self.closeBtnOnSpotlightCardTapped(spotLightId: cardData.spotLightId, template: .outageClear, cellType: cell, cardName: cardData.accountName)}
        }
        cell.layoutIfNeeded()
    }
        
    
    func showQuickPay() {
        if QuickPayManager.shared.isReAuthenticationRequired() {
            print("Required")
        }
        let viewcontroller = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "BillingPaymentViewController") as BillingPaymentViewController
//        viewcontroller.modalPresentationStyle = .fullScreen
        /* CMAIOS-1861 */
        let aNavigationController = UINavigationController(rootViewController: viewcontroller)
        aNavigationController.navigationBar.isHidden = true
        aNavigationController.modalPresentationStyle = .fullScreen
        self.present(aNavigationController, animated: true)
        /* CMAIOS-1861 */
    }
    
    func showUpdateExpiration(flowType: ExpirationFlow) {
        guard let viewcontroller = CardExpirationViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.flow = flowType
        switch flowType {
        case .quickPay: break
        case .autoPay:
            viewcontroller.payMethod = QuickPayManager.shared.getDefaultAutoPaymentMethod()
        case .scheduledPayment:
            viewcontroller.isFromSpotLightCard = true
            viewcontroller.payMethod = QuickPayManager.shared.getDefaultScheduledPaymentMethod()
        case .onlyDefaultExpired: break
        case .none: break
        case .defaultExpiredWithMoreMOPs: break
        case .newCardDateExpired: break
        case .autoPaymentFailure: break
        }
        viewcontroller.modalPresentationStyle = .fullScreen
        viewcontroller.successHandler = { [weak self] payMethod in
            self?.dismiss(animated: true)
        }
        //CMAIOS-2459 issue fix
        let navigationController = UINavigationController(rootViewController: viewcontroller)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func navigateToBillPay() {
        isFromQuickPay = true
        switch tapTargetForSpotlight {
        case "appbpromo":
            guard let viewcontroller = SetUpAutoPayPaperlessBillingVC.instantiateWithIdentifier(from: .editPayments) else { return }
            viewcontroller.isFromSpotlight = true
            let navigationController = UINavigationController(rootViewController: viewcontroller)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        case "mybill" :
            showQuickPay()
        case "billingandpayment" :
            showBillingAndPayment()
        case "paymentfailure", "autopayfailure" : 
            // CMAIOS-2081: Error code updated in spotlight API
            if !spotLightCardId.isEmpty, let spotlightCards = SpotLightsManager.shared.spotLightCards, let cards = spotlightCards.cards, !cards.isEmpty {
                if let card = cards.filter({$0.id == spotLightCardId && $0.name == accountName}) as [SpotLightCardsGetResponse.CardData]?, !card.isEmpty, let errorCode = card[0].errorCode, !errorCode.isEmpty {
                    // pass card[0] as SpotLightCardsGetResponse.CardData for all the data
                    // use Errorcode to redirect to appropriate page
                    if tapTargetForSpotlight != "autopayfailure" {
                        //CMAIOS-2413
                        SPFSharedManager.shared.mapErrorCodeToSPTErrorType(errorCode: errorCode.lowercased(), cardData: card[0], presentingVC: self)
                    } else {
                        self.mapErrorCodeToSPTErrorType(errorCode: errorCode.lowercased(), cardData: card[0], isAutoPayFailure: (tapTargetForSpotlight == "autopayfailure")) // CMAIOS-2120
                    }
                } else if let card = cards.filter({$0.id == spotLightCardId }) as [SpotLightCardsGetResponse.CardData]?, !card.isEmpty, let errorCode = card[0].errorCode, !errorCode.isEmpty {
                    // pass card[0] as SpotLightCardsGetResponse.CardData for all the data
                    // use Errorcode to redirect to appropriate page
                    if tapTargetForSpotlight != "autopayfailure" {
                        //CMAIOS-2413
                        SPFSharedManager.shared.mapErrorCodeToSPTErrorType(errorCode: errorCode.lowercased(), cardData: card[0], presentingVC: self)
                    } else {
                        self.mapErrorCodeToSPTErrorType(errorCode: errorCode.lowercased(), cardData: card[0], isAutoPayFailure: (tapTargetForSpotlight == "autopayfailure")) // CMAIOS-2120
                    }
                }
            }
        case "updateexpiration" : return
            self.showUpdateExpiration(flowType: .scheduledPayment)
        case "editautopay":
            guard let viewcontroller = EditAutoPayViewController.instantiateWithIdentifier(from: .payments) else { return }
            if (QuickPayManager.shared.isLegacyAccount()) {
                navigateForExpireAutoPay()
            } else {
                viewcontroller.editScreenType = .nonGrandfatherEditAutoPay
            }
            viewcontroller.isFromSpotLightCard = true
            let navigationController = UINavigationController(rootViewController: viewcontroller)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        case "legacyautopay":
            guard let viewcontroller = AutoPaySettingsViewController.instantiateWithIdentifier(from: .payments) else { return }
            viewcontroller.isFromHomePageCard = true
            viewcontroller.fromCardExpirySpotlight = false
            let navigationController = UINavigationController(rootViewController: viewcontroller)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        default: return
            
        }
    }
    func navigateForExpireAutoPay() {
        guard let viewcontroller = AutoPaySettingsViewController.instantiateWithIdentifier(from: .payments) else { return }
        viewcontroller.isFromHomePageCard = true
        viewcontroller.fromCardExpirySpotlight = true
        var payNickName = ""
        var isExpiredCase = false
        
        if !spotLightCardId.isEmpty, let spotlightCards = SpotLightsManager.shared.spotLightCards, let cards = spotlightCards.cards, !cards.isEmpty {
            if let card = cards.filter({$0.id == spotLightCardId}) as [SpotLightCardsGetResponse.CardData]?, !card.isEmpty {
                payNickName = card[0].payNickName ?? ""
                if card[0].GAkey == "homepagecard_autopaycard_expired" {
                    isExpiredCase = true
                } else if card[0].GAkey == "homepagecard_autopaycard_about_to_expire" {
                    isExpiredCase = false
                }
            }
        }
        
        if isExpiredCase {
            viewcontroller.titleLabelText = "Your Auto Pay card \(payNickName) has expired"
        } else {
            viewcontroller.titleLabelText = "Your Auto Pay card \(payNickName) will expire soon"
        }
        viewcontroller.subtitleText = "Please update your Auto Pay settings on the Optimum website"
        let navigationController = UINavigationController(rootViewController: viewcontroller)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        return
    }
    
    func showBillingAndPayment() {
        let viewcontroller = UIStoryboard(name: "Billing", bundle: nil).instantiateViewController(identifier: "PaymentHistoryViewController") as PaymentHistoryViewController
        viewcontroller.isFromSpotlight = true
        let aNavigationController = UINavigationController(rootViewController: viewcontroller)
        aNavigationController.navigationBar.isHidden = true
        aNavigationController.modalPresentationStyle = .fullScreen
        self.present(aNavigationController, animated: true)
    }
    
    func checkReAuthAndNavigate(_ isCardDismissible: Bool, spotlightId: String, cardName: String, tapTarget: String, selectedRow: Int) {
        if !tapTarget.isEmpty {
            tapTargetForSpotlight = tapTarget.lowercased()
        }
        spotLightCardId = spotlightId
        accountName = cardName
        
        if isCardDismissible, !spotlightId.isEmpty {
            self.hideDismissedSpotlightcards(spotLightId: spotlightId, cardName: cardName, isReloadRequired: true)
        }
        self.movingOutOfHomeScreen()
//        spotlightCardType = cardType // Reference used after reauth flow
        if QuickPayManager.shared.isReAuthenticationRequired() {
            QuickPayManager.shared.reAuthOnTimeExpiry(category: .spotlightCard)
        } else {
            QualtricsManager.shared.startWithScreenNavsRule()
            self.navigateToBillPay()
        }
    }
    
    func navigateToOutageMoreInfo(cardData: SpotLightCardsGetResponse.CardData?, selectedRow: Int, accountName: String) {
        guard let outageDetails = OutageDetailsVC.instantiateWithIdentifier(from: .Outage) else { return }
        let navigationController = UINavigationController(rootViewController: outageDetails)
        if let spotlightCardData = cardData {
            if let moreInfo = spotlightCardData.moreInfo {
                outageDetails.screenDetails = moreInfo
            }
            //CMAIOS-2559 pass the Outage spotlight GA key
            outageDetails.outageCardGAkey = spotlightCardData.GAkey ?? ""
            if let dismissible = spotlightCardData.dismissible, dismissible {
                if let cardId = spotlightCardData.id, !cardId.isEmpty {
                    self.hideDismissedSpotlightcards(spotLightId: cardId, cardName: accountName, isReloadRequired: true)
                }
            }
        }
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func moreInfoBtnTapped(_sender: UIButton)
    {
        self.movingOutOfHomeScreen()
        guard let url = URL(string: "https://www.optimum.net/support/outage/#/PmModemsOnline") else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    @objc func optimumStreamInstallNow()
    {
        self.movingOutOfHomeScreen()
        DispatchQueue.main.async {
            APIRequests.shared.isReloadNotRequiredForMaui = true
            let viewController = UIStoryboard(name: "TVHomeScreen", bundle: nil).instantiateViewController(identifier: "StreamDeviceLandingScreen") as StreamDeviceLandingScreen
            let aNavigationController = UINavigationController(rootViewController: viewController)
            aNavigationController.modalPresentationStyle = .fullScreen
            aNavigationController.setNavigationBarHidden(false, animated: false)
            self.present(aNavigationController, animated: true, completion: nil)
        }
    }
    
    @objc func letsfixedAction(_ sender: UIButton){
        self.movingOutOfHomeScreen()
        //need to start ScreenNavs rules if ten second rule is not completed and user is moving out of home screen
        QualtricsManager.shared.startWithScreenNavsRule()
        DispatchQueue.main.async {
            let healthCheck = UIStoryboard(name: "HealthCheck", bundle: Bundle.main).instantiateViewController(withIdentifier: "ManualRebootViewController") as! ManualRebootViewController
            let aNavigationController = UINavigationController(rootViewController: healthCheck)
            aNavigationController.modalPresentationStyle = .fullScreen
            self.present(aNavigationController, animated: false, completion: nil)
        }
    }
    
    @objc func getExtender(_ sender: UIButton) {
        self.movingOutOfHomeScreen()
        guard let url = URL(string: EXTENDER_URL) else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        let savedDate = dateFormatter.string(from: Date())
        PreferenceHandler.saveValue(savedDate, forKey: "DeadZoneDate")
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion:nil)
    }
    
    @objc func letsFixItOfflineExtender(_ sender: UIButton){
        self.movingOutOfHomeScreen()
        //need to start ScreenNavs rules if ten second rule is not completed and user is moving out of home screen
        QualtricsManager.shared.startWithScreenNavsRule()
        ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
        ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
        ExtenderDataManager.shared.flowType = .offlineFlow
        ExtenderDataManager.shared.iTroubleshoot = .troubleshoot
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "TroubleshootingExtenders", bundle: nil)
            if let offlineExtenderFlowRootScreen = storyboard.instantiateViewController(withIdentifier: "extenderOfflineViewController") as? ExtenderOfflineViewController {
                offlineExtenderFlowRootScreen.modalPresentationStyle = .fullScreen
                let navVC = UINavigationController(rootViewController: offlineExtenderFlowRootScreen)
                navVC.modalPresentationStyle = .fullScreen
                navVC.setNavigationBarHidden(false, animated: true)
                self.present(navVC, animated: true)
            }
        }
    }
    
    @objc func letsFixItWeakExtender() {
        self.movingOutOfHomeScreen()
        //need to start ScreenNavs rules if ten second rule is not completed and user is moving out of home screen
        QualtricsManager.shared.startWithScreenNavsRule()
        ExtenderDataManager.shared.isExtenderTroubleshootFlow = true
        ExtenderDataManager.shared.extenderType = MyWifiManager.shared.isGateWayWifi5OrAbove()
        ExtenderDataManager.shared.flowType = .weakFlow
        ExtenderDataManager.shared.iTroubleshoot = .troubleshoot
        DispatchQueue.main.async {
            let healthCheck = UIStoryboard(name: "TroubleshootingExtenders", bundle: Bundle.main).instantiateViewController(withIdentifier: "goToExtenderOfflineViewController") as! GoToExtenderOfflineViewController
            let aNavigationController = UINavigationController(rootViewController: healthCheck)
            aNavigationController.modalPresentationStyle = .fullScreen
            aNavigationController.setNavigationBarHidden(false, animated: false)
            self.present(aNavigationController, animated: false, completion: nil)
        }
    }
    
    @objc func adButtonClick(_ button: UIButton) {
        Logger.info("Ad button click")
        
        // Web click event
        if let phoneURL = CustomGAdLoader.shared.phoneNumber, !phoneURL.isEmpty {
            // Phone click event
            if let url = URL(string: "tel://\(phoneURL)"), UIApplication.shared.canOpenURL(url) {
                CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
                    eventParam: [EVENT_LINK_TEXT : HomePageCards.Google_ad_spotlight_Event.rawValue,
                                EVENT_SCREEN_NAME: HomePageCards.Google_Ad_Spotlight_Click_to_call.rawValue,
                               EVENT_SCREEN_CLASS: self.classNameFromInstance]
                )
                UIApplication.shared.open(url)
            }
        } else {
            CMAAnalyticsManager.sharedInstance.trackButtonOnClickEvent(
                eventParam: [EVENT_LINK_TEXT : HomePageCards.Google_ad_spotlight_Event.rawValue,
                            EVENT_SCREEN_NAME: HomePageCards.Google_Ad_Spotlight_Click_to_web.rawValue,
                           EVENT_SCREEN_CLASS: self.classNameFromInstance]
            )
            if let action = CustomGAdLoader.shared.customAdObj?.string(forKey: "CalltoAction"), action.lowercased().contains("chat")  {
                self.clickToAdChat()
            } else {
                CustomGAdLoader.shared.customAdObj?.performClickOnAsset(withKey: "CalltoAction")
            }
        }
    }
}

// MARK: - SFSafariViewController Delegates
extension HomeScreenViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        SpotLightsManager.shared.removeSpotlightForDeadZone()
    }
}

extension UICollectionView {
    var visibleCurrentCellIndexPath: [Int] {
        var indexes: [IndexPath] = []
        for cell in self.visibleCells {
            if let index = self.indexPath(for: cell) {
                indexes.append(index)
            }
        }
        return indexes.compactMap { $0.row }
    }
}
