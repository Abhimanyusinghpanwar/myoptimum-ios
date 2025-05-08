//
//  TVTroubleshootingDiagnoseViewController.swift
//  CustSupportApp
//
//  Created by riyaz on 26/12/23.
//

import UIKit

class TVTroubleshootingDiagnoseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: (currentScreenWidth/2) - 30, height: 145)
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InternetIssueCollectionViewCell", for: indexPath) as? InternetIssueCollectionViewCell else { return UICollectionViewCell() }
        cell.imageWidthConstraint.constant = 40
        cell.imageHeightConstraint.constant = 40
        cell.imageTopSpaceConstraint.constant = 15
        cell.issueImage.image = UIImage(named: troubleShootImages[indexPath.row])
        cell.imageText.setLineHeight(1.2)
        cell.imageText.font = UIFont(name: "Regular-Regular", size: 16)
        cell.imageText.text = troubleShootDetails[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            IntentsManager.sharedInstance.screenFlow = .remoteTroubleshoot
            guard let vc = TVTroubleshootStreamRemoteViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 1 {
            IntentsManager.sharedInstance.screenFlow = .streamTroubleshoot
            navigateToChatUsScreen()
        }
    }
    
    @IBOutlet weak var problemButton: RoundedButton!
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.closeTopConstraint.constant = 100
            self.troubleshootCollectionView.alpha = 0.0
            self.problemButton.alpha = 0.0
            self.titleLabel.alpha = 0.0
            self.view.layoutIfNeeded()
        } completion: { _ in
            APIRequests.shared.isReloadNotRequiredForMaui = false
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func problemButtonAction(_ sender: UIButton) {
        IntentsManager.sharedInstance.screenFlow = .streamTroubleshoot
        navigateToChatUsScreen()
    }
    
    @IBOutlet weak var troubleshootCollectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!

    @IBOutlet weak var closeTopConstraint: NSLayoutConstraint!
    
    var troubleShootImages = ["streamRemoteTvsmall","streamTvSmall"]
    var troubleShootDetails = ["I have a problem with my Stream remote", "I have a problem with the Optimum TV app"]
    var isDevicesPaused = false
    var deviceWithSectionsArray : DeviceDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        problemButton.layer.borderColor = UIColor(red: 152/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        problemButton.layer.borderWidth = 2.0
        self.navigationItem.hidesBackButton = true
        initialUIConstants()
        titleLabel.setLineHeight(1.2)
        titleLabel.font = UIFont(name: "Regular-Bold", size: 20)

        troubleshootCollectionView.register(UINib(nibName: "InternetIssueCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InternetIssueCollectionViewCell")
        troubleshootCollectionView.isScrollEnabled = false
        troubleshootCollectionView.delegate = self
        troubleshootCollectionView.dataSource = self
        if MyWifiManager.shared.isGateWayWifi6() {
            let pausedDeviceList = MyWifiManager.shared.pausedClientData?.data?.filter{$0.paused == true}
            if let pausedData = pausedDeviceList, !pausedData.isEmpty {
                self.isDevicesPaused = true
            } else {
                self.isDevicesPaused = false
            }
            self.getPausedDevices()
        } else {
            self.isDevicesPaused = false
        }
        // Do any additional setup after loading the view.
    }
    
    
    func initialUIConstants() {
        self.closeTopConstraint.constant = 100
        self.troubleshootCollectionView.alpha = 0.0
        titleLabel.alpha = 0.0
        headerImage.alpha = 0.0
        self.problemButton.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_TROUBLESHOOT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4) {
            self.closeTopConstraint.constant = 10
            self.troubleshootCollectionView.alpha = 1.0
            self.problemButton.alpha = 1.0
            self.titleLabel.alpha = 1.0
            self.headerImage.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }

    func getPausedDevices() {
        var deviceData = [LightSpeedAPIResponse.Nodes]()
        let pausedDeviceList = MyWifiManager.shared.pausedClientData?.data?.filter{$0.paused == true}
        if let pausedData = pausedDeviceList, !pausedData.isEmpty {
            for deviceMac in pausedData {
                if let device = MyWifiManager.shared.getDeviceDetailsForMAC(deviceMac.mac ?? "") {
                    deviceData.append(device)
                }
            }
        }
        if !deviceData.isEmpty {
            deviceWithSectionsArray = MyWifiManager.shared.segregateSectionForDevices(deviceData, groupingOfSections: true)
        }
    }
    
    func showCancelVC() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }
    
    func navigateToChatUsScreen() {
        guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
        vc.isFromTV = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
