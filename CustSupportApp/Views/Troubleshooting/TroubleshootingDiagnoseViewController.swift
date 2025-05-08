//
//  TroubleshootingDiagnoseViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 06/12/22.
//

import UIKit

class TroubleshootingDiagnoseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: (currentScreenWidth/2) - 30, height: 145)
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
        cell.imageText.font = UIFont(name: "Regular-Regular", size: 16)
        cell.issueImage.image = UIImage(named: troubleShootImages[indexPath.row])
        cell.imageText.text = troubleShootDetails[indexPath.row]
        cell.imageText.setLineHeight(1.25)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            guard let vc = InternetSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            vc.isFromNoInternetCell = true
            vc.isDevicesPaused = self.isDevicesPaused
            vc.deviceWithSectionsArray = deviceWithSectionsArray
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 1 {
            guard let vc = InternetSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            vc.isFromNoInternetCell = false
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 2 {
            guard let vc = OneDeviceSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 3 {
            IntentsManager.sharedInstance.screenFlow = .wiFiCannotLoadAnything
            if isDevicesPaused {
                guard let vc = PausedDevicesListViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                vc.isFromNoInternetCell = false
                vc.deviceWithSectionsArray = deviceWithSectionsArray
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = RestartMyGateWayViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                MyWifiManager.shared.isFromSpeedTest = false
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBOutlet weak var lcCrossBtnToDown: NSLayoutConstraint!
    @IBOutlet weak var lcTextToCrossBtn: NSLayoutConstraint!
    @IBOutlet weak var headerQuestionLabel: UILabel!
    @IBOutlet weak var problemButton: RoundedButton!
    @IBAction func closeButtonAction(_ sender: UIControl) {
        //self.dismiss(animated: true)
        showCancelVC()
    }
    
    @IBAction func problemButtonAction(_ sender: UIButton) {
        IntentsManager.sharedInstance.screenFlow = ContactUsScreenFlowTypes.iHaveADifferentProblem
        guard let vc = RunHealthCheckViewController.instantiateWithIdentifier(from: .HealthCheck) else { return }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBOutlet weak var troubleshootCollectionView: UICollectionView!
    var troubleShootImages = ["NoInternet","internetSlow","TV-no_WiFi","noConnection"]
    var troubleShootDetails = ["I have no Internet at all","My Internet is slow","I have a device that can’t connect to WiFi","I’m connected to WiFi, but can’t load anything"]
    var isDevicesPaused = false
    var deviceWithSectionsArray : DeviceDetails?
    override func viewDidLoad() {
        super.viewDidLoad()
//        if (UIScreen.main.bounds.size.height == 568)
//        {
//            self.lcTextToCrossBtn.constant = 20
//            self.lcCrossBtnToDown.constant = 20
//            
//        }
        problemButton.layer.borderColor = UIColor(red: 152/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        problemButton.layer.borderWidth = 2.0
        self.navigationItem.hidesBackButton = true
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
        self.headerQuestionLabel.setLineHeight(1.2)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_SELECT_INTERNET_ISSUE.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
