//
//  InternetSlowViewController.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 08/12/22.
//

import UIKit

class InternetSlowViewController: BaseViewController, BarButtonItemDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
        func didTapBarbuttonItem(buttonType: BarButtonType) {
            if buttonType == .back {
                IntentsManager.sharedInstance.screenFlow = .none
                self.navigationController?.popViewController(animated: true)
            } else if buttonType == .cancel{
                onTapCancel()
            }
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: (158/xibDesignWidth)*currentScreenWidth, height: (158/xibDesignHeight)*currentScreenHeight)
        return CGSize(width: (currentScreenWidth/2) - 30, height: 158)
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
        cell.imageWidthConstraint.constant = 32
        cell.imageHeightConstraint.constant = 32
        cell.imageTopSpaceConstraint.constant = 35
        cell.issueImage.image = UIImage(named: internetSlowImages[indexPath.row])
        cell.issueImage.contentMode = .center
        cell.imageText.font = UIFont(name: "Regular-Regular", size: 16)
        cell.imageText.text = internetSlowDetails[indexPath.row]
        cell.imageText.setLineHeight(1.25)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            if !isFromNoInternetCell {
                guard let vc = OneDeviceSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                if isDevicesPaused {
                    guard let vc = PausedDevicesListViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                    vc.isFromNoInternetCell = isFromNoInternetCell
                    vc.deviceWithSectionsArray = deviceWithSectionsArray
                    self.navigationController?.navigationBar.isHidden = false
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    guard let vc = OneDeviceSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                    self.navigationController?.navigationBar.isHidden = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            if !isFromNoInternetCell {
                guard let vc = RunHealthCheckViewController.instantiateWithIdentifier(from: .HealthCheck) else { return }
                IntentsManager.sharedInstance.screenFlow = .myInternetIsSlow
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = RestartMyGateWayViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
                IntentsManager.sharedInstance.screenFlow = .noInternetAtAll
                MyWifiManager.shared.isFromSpeedTest = false
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    var internetSlowImages = ["one","twoPlus"]
    var internetSlowDetails = [String]()
    var isFromNoInternetCell : Bool!
    var isDevicesPaused : Bool!
    @IBOutlet weak var internetSlowCollectionView: UICollectionView!
    @IBOutlet weak var internetSlowImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lcImgHeight: NSLayoutConstraint!
    var deviceWithSectionsArray : DeviceDetails?
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        internetSlowCollectionView.register(UINib(nibName: "InternetIssueCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InternetIssueCollectionViewCell")
        if !isFromNoInternetCell {
            headerLabel.text = "Okay. Is your internet slow on most devices or only one?"
            internetSlowDetails = ["It’s only slow on one device","It’s slow on most devices"]
            internetSlowImageView.image = UIImage(named: "internetSlowWithBottomLine")
        } else {
            headerLabel.text = "Okay. Is your internet not working on all devices or only one?"
            internetSlowDetails = ["I have no Internet on one device","I have no Internet on all devices"]
            internetSlowImageView.image = UIImage(named: "TroubleshootingHero")
            if (UIScreen.main.bounds.size.height == 568)
            {
                self.internetSlowImageView.contentMode = .scaleAspectFill
            }
        }
        self.headerLabel.setLineHeight(1.15)
        internetSlowCollectionView.isScrollEnabled = false
        internetSlowCollectionView.delegate = self
        internetSlowCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromNoInternetCell {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_INTERNET_SLOW.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue ])
        } else {
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : Troubleshooting.TS_NO_INTERNET.rawValue, CUSTOM_PARAM_FIXED : Fixed.Data.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue, CUSTOM_PARAM_INTENT: Intent.Troubleshooting.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
        }
        if (UIScreen.main.bounds.size.height == 568)
        {
           
            self.lcImgHeight.constant = 150
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
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
             cancelVC.modalPresentationStyle = .fullScreen
             self.navigationController?.pushViewController(cancelVC, animated: true)
         }

    }
}
