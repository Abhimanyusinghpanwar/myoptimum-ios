//
//  TVTroubleshootStreamRemote.swift
//  CustSupportApp
//
//  Created by riyaz on 26/12/23.
//

import UIKit

class TVTroubleshootStreamRemoteViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: (158/xibDesignWidth)*currentScreenWidth, height: (158/xibDesignHeight)*currentScreenHeight)
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
        cell.issueImage.image = UIImage(named: Images[indexPath.row])
        cell.imageText.setLineHeight(1.2)
        cell.imageText.font = UIFont(name: "Regular-Regular", size: 16)
        cell.imageText.text = Details[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigateToPrepareRemoteVC()
        case 1,2:
            navigateToPrepareRemoteVC(for:true)
            break
        case 3:
            navigateToChatUsScreen()
        default: break
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.closeBtnTopConstraint.constant = 100
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    var Images = ["cantControlTVRemote", "siriIcon", "remotePointDirect", "remoteDoesntWork"]
    var Details = ["I can’t control my TV with the remote", "I can’t use voice control on the remote", "Remote does not work, unless I point it at the Stream box", "My remote doesn’t work at all"]
    var isFromNoInternetCell : Bool!
    var isDevicesPaused : Bool!
    @IBOutlet weak var internetSlowCollectionView: UICollectionView!
    @IBOutlet weak var internetSlowImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lcImgHeight: NSLayoutConstraint!
    var deviceWithSectionsArray : DeviceDetails?
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var closeBtnTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.setLineHeight(1.2)
        titleLabel.font = UIFont(name: "Regular-Bold", size: 20)

        internetSlowCollectionView.register(UINib(nibName: "InternetIssueCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InternetIssueCollectionViewCell")
        internetSlowCollectionView.isScrollEnabled = false
        internetSlowCollectionView.delegate = self
        internetSlowCollectionView.dataSource = self
        self.closeBtnTopConstraint.constant = 80
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if (UIScreen.main.bounds.size.height == 568)
        {
            self.lcImgHeight.constant = 150
        }
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_REMOTE_TROUBLESHOOT.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
        }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4) {
            self.closeBtnTopConstraint.constant = 10
            self.view.layoutIfNeeded()
        }
    }
    
    func onTapCancel() {
        
    }
    
    func navigateToPrepareRemoteVC(for remoteVoiceFlow: Bool = false) {
        guard let vc = PrepareRemoteViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
        vc.isRemoteVoiceTSFlow = remoteVoiceFlow
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToChatUsScreen() {
        guard let vc = TroubleshootContactSupportViewController.instantiateWithIdentifier(from: .TroubleshootInternet) else { return }
        vc.isFromTV = true //CMAIOS-2886
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
