//
//  TVHomePageViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 27/11/23.
//

import UIKit
import Shift

struct TVStreamBox {
    let friendlyname: String
    let macAddress: String
    let image: UIImage
    let deviceType: String
    let serial: String
    
}

class TVHomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //View Outlet Connections
    @IBOutlet weak var vwFullBackground: UIView!
    @IBOutlet weak var btn_ViewChannels: UIButton!
    @IBOutlet weak var img_TVIcon: UIImageView!
    @IBOutlet weak var lable_Title: UILabel!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwClossBtn: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tvDeviceListCollView: UICollectionView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var closeBtnImgY: NSLayoutConstraint!
    @IBOutlet weak var vwClossBottom: NSLayoutConstraint!
    @IBOutlet weak var technicalDifficultiesView: UIView!
    @IBOutlet weak var technicalDifficultiesLabel: UILabel!
    @IBOutlet weak var technicalDifficultiesButton: UIButton!
    
    @IBOutlet weak var tsMyTvBtnBottomConstraint: NSLayoutConstraint!

    var delegate:DismissingChildViewcontroller?
    let transition = TVHomePageTransitionDelegate()
    var homeScreenWillAppear = false
    var shiftID:String = ""
    var arrayStb : [TVStreamBox] = []
    var qualtricsAction : DispatchWorkItem?
    var status = ""
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTransition()
    }
    
    func setupTransition() {
        transitioningDelegate = transition
        modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if MyWifiManager.shared.lightSpeedAPIState == .none, !MyWifiManager.shared.isOperationalStatusOnline {
            status = "wifidown"
        } else if MyWifiManager.shared.lightSpeedAPIState == .completed, MyWifiManager.shared.getMyWifiStatus() == .wifiDown {
            status = "wifidown"
        } else {
            status = "runningsmoothly"
        }
        viewShiftAnimationSetUp()
        setupTransition()
        self.btn_ViewChannels.isHidden = true
        self.lable_Title.text = MyWifiManager.shared.getTVPackageName()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialUIConstants()
        switch status {
        case "wifidown":
            break
        default:
            self.populateAllSTBs()
            self.tvDeviceListCollView.reloadData()
            qualtricsAction = self.checkQualtrics(screenName: TVStreamTroubleshooting.TV_LANDING_SCREEN.rawValue, dispatchBlock: &qualtricsAction)
            CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_LANDING_SCREEN.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
        }
    }
    
    func populateAllSTBs() {
       // arrayStb = MyWifiManager.shared.getTvStreamDevices()
        //CMAIOS-2437
        arrayStb.removeAll()
        let arrayOfSTB = MyWifiManager.shared.getTvStreamDevices()
        for stbData in arrayOfSTB {
            if !stbData.macAddress.isEmpty {
                arrayStb.append(stbData)
            }
        }
 //      lazy var arrayOfSTB = MyWifiManager.shared.getTvStreamDevices()
//        arrayStb = arrayOfSTB.map {nodes -> TVStreamBox in
//            let deviceImageValue = nodes.deviceType ?? ""
//            var name = nodes.friendlyName ?? ""
//            if name.isEmpty {
//                name = nodes.mac ?? ""
//            }
//            return TVStreamBox.init(friendlyname: name, macAddress: nodes.mac ?? "", image: DeviceManager.IconType.white.getStreamImage(name: deviceImageValue.lowercased() == "unknown" ? "" : deviceImageValue), deviceType: nodes.deviceType ?? "")
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch status {
        case "wifidown":
            UIView.animate(withDuration: 0.4) {
                self.vwClossBottom.constant = 0
                self.technicalDifficultiesView.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        default:
            UIView.animate(withDuration: 0.4) {
                self.vwClossBottom.constant = 0
                self.vwContainer.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func viewShiftAnimationSetUp() {
        view.shift.id = shiftID
        shift.baselineDuration = 0.2 //0.80
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
        //show fadeIn effect on HomeVC when the user dismiss TVPageVC
        if homeScreenWillAppear {
            delegate?.childViewcontrollerGettingDismissed()
        }
    }
    
    func initialUIConstants() {
        self.vwClossBottom.constant = 100
        self.closeBtnImgY.constant = CurrentDevice.forLargeSpotlights() ? 22 : -10
        self.tsMyTvBtnBottomConstraint.constant = CurrentDevice.forLargeSpotlights() ? -8 : 15
        switch status {
        case "wifidown":
            self.vwFullBackground.backgroundColor = midnightBlueRGB
            self.vwContainer.isHidden = true
            self.technicalDifficultiesView.isHidden = false
            self.technicalDifficultiesView.alpha = 0.0
            self.vwClossBtn.backgroundColor = midnightBlueRGB
            self.technicalDifficultiesButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.13
            // Line height: 18 pt
            paragraphStyle.alignment = .center
            self.technicalDifficultiesLabel.attributedText = NSMutableAttributedString(string: "We are experiencing technical difficulties and can't communicate with your TV equipment.\n\nWe need to fix your WiFi network first!", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            self.technicalDifficultiesButton.layer.borderWidth = 1.0
            self.technicalDifficultiesButton.layer.cornerRadius = 15.0
            break
        default:
            // Collection view layout
            self.vwFullBackground.backgroundColor = energyBlueRGB
            self.technicalDifficultiesView.isHidden = true
            self.vwClossBtn.backgroundColor = energyBlueRGB
            self.vwContainer.isHidden = false
            self.vwContainer.alpha = 0.0
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        layout.minimumLineSpacing = 0;
        self.tvDeviceListCollView.collectionViewLayout = layout
        // Register cell nib and set up collection view
        self.tvDeviceListCollView.register(UINib(nibName: "TvDeviceListViewCell", bundle: nil), forCellWithReuseIdentifier: "TvDeviceListViewCell")
        if !self.btn_ViewChannels.isHidden {
            addBottomBorder(to: btn_ViewChannels)
        }
    }
    
    // Add bottom white border to the button
    func addBottomBorder(to button: UIButton) {
        let border = CALayer()
        border.backgroundColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: button.frame.size.height - 1, width: button.frame.size.width, height: 1)
        button.layer.addSublayer(border)
    }
    
    // Function to check if any macAddress in the array is empty
   /* func isMacAddressEmpty(in array: [TVStreamBox]) -> Bool {
        for stbData in array {
            if stbData.macAddress.isEmpty {
                return true
            }
        }
        return false
    } */
    
    func optimumStreamInstallNow()
    {
        DispatchQueue.main.async {
            let viewController = UIStoryboard(name: "TVHomeScreen", bundle: nil).instantiateViewController(identifier: "StreamDeviceLandingScreen") as StreamDeviceLandingScreen
            let aNavigationController = UINavigationController(rootViewController: viewController)
            aNavigationController.modalPresentationStyle = .fullScreen
            aNavigationController.setNavigationBarHidden(false, animated: false)
            self.present(aNavigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func ViewmychannelsBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        let viewController = UIStoryboard(name: "TVHomeScreen", bundle: nil).instantiateViewController(identifier: "SearchChannelsVC") as SearchTVChannelsViewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func letsFixIt(_ sender: Any) {
        let healthCheck = UIStoryboard(name: "HealthCheck", bundle: Bundle.main).instantiateViewController(withIdentifier: "ManualRebootViewController") as! ManualRebootViewController
        let aNavigationController = UINavigationController(rootViewController: healthCheck)
        aNavigationController.modalPresentationStyle = .fullScreen
        UIView.animate(withDuration: 0.4) {
            self.technicalDifficultiesView.alpha = 0.0
        } completion: { complete in
            self.present(aNavigationController, animated: false, completion: nil)
        }
        UIView.animate(withDuration: 0.3) {
            self.vwClossBottom.constant = 100
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func troubleshootmyTVserviceBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        UIView.animate(withDuration: 0.4) {
            self.vwClossBottom.constant = 100
            self.vwContainer.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            APIRequests.shared.isReloadNotRequiredForMaui = true
            guard let vc = TVTroubleshootingDiagnoseViewController.instantiateWithIdentifier(from: .TVTroubleshooting) else { return }
            let navigationController = UINavigationController.init(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func installOptimumStreamAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        UIView.animate(withDuration: 0.4) {
            self.vwClossBottom.constant = 100
            self.vwContainer.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            APIRequests.shared.isReloadNotRequiredForMaui = true
            let viewController = UIStoryboard(name: "TVHomeScreen", bundle: nil).instantiateViewController(identifier: "InitiateStreamDeviceSetUpVC") as InitiateStreamDeviceSetUpVC
            let navigationController = UINavigationController.init(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: false, completion: nil)
        }
    }
    
    @IBAction func closeBtnTapAction(_ sender: Any) {
        self.qualtricsAction?.cancel()
        switch status {
        case "wifidown":
            self.vwContainer.isHidden = true
        default:
            self.vwContainer.isHidden = false
        }
        self.homeScreenWillAppear = true
        //Dismiss AccountVC with fadeOut effect
        UIView.animate(withDuration: 0.4) {
            switch self.status {
            case "wifidown":
                self.technicalDifficultiesView.alpha = 0.0
            default:
                self.vwContainer.alpha = 0.0
            }
        } completion: { complete in
            self.dismiss(animated: true)
        }
        UIView.animate(withDuration: 0.3) {
            self.vwClossBottom.constant = 100
            self.view.layoutIfNeeded()
        }
    }

    //MARK: Device List Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayStb.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TvDeviceListViewCell", for: indexPath) as? TvDeviceListViewCell else { return UICollectionViewCell() }
        let stbData = arrayStb[indexPath.item]
        cell.streamIcon.image = stbData.image
        cell.lblDeviceName.text = self.getTruncatedStreamName(streamName: stbData.friendlyname.isEmpty || stbData.friendlyname == stbData.macAddress ? "Optimum Stream": stbData.friendlyname)//stbData.friendlyname.isEmpty || stbData.friendlyname == stbData.macAddress ? "Optimum Stream": stbData.friendlyname
        cell.lblStream.text = "Stream"
        cell.lblDeviceStatus.isHidden = true
        return cell
    }
    func getTruncatedStreamName(streamName:String) -> String {
        if streamName.count > 20 {
            let trimmedStreamName = streamName.getTruncatedString()
            return trimmedStreamName
        }
        return streamName
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let macAddress = self.arrayStb[indexPath.row].macAddress
        if macAddress.isEmpty {
            //CMA-2549
            optimumStreamInstallNow()
            return
        }
        self.qualtricsAction?.cancel()
        let selectedCell = self.tvDeviceListCollView.cellForItem(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! TvDeviceListViewCell
        UIView.animate(withDuration: 0.2,  animations: {
            },completion: { finished in
                let deviceIconFrame = self.getFrameOfSelectedAvatarIcon(selectedView: selectedCell, animateFromVC: .None)
                let screenImageFrame = self.img_TVIcon.frame
                let screenLabelFrame = self.lable_Title.frame
                let viewFrame = self.topBackgroundView.frame
                self.streamBoxToTop(frame: deviceIconFrame, topImageFrame: screenImageFrame, topLabelFrame: screenLabelFrame, iconImage: selectedCell.streamIcon.image!, topImage1: self.img_TVIcon.image!, labelText: self.lable_Title.text!, firstViewFrame: viewFrame) { isAnimationCompleted in
                    let viewController = UIStoryboard(name: "TVHomeScreen", bundle: nil).instantiateViewController(identifier: "streamBox") as StreamBoxDetailsViewController
                    viewController.streamBox = self.arrayStb[indexPath.item]
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: false)
                }
        } )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //CMAIOS-2143  Updated cell height
            return CGSize(width: 100, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if (arrayStb.count == 1){
            let cellSt = (Int(currentScreenWidth)/2 - (arrayStb.count * 50))
            return UIEdgeInsets(top: 0, left: CGFloat(cellSt), bottom: 0, right: 10)
        }else if (arrayStb.count == 2){
            let cellSt = (Int(currentScreenWidth)/2 - (arrayStb.count * 50))
            return UIEdgeInsets(top: 0, left: CGFloat(cellSt), bottom: 0, right: 10)
        }else if (arrayStb.count == 3){
            let cellSt = (Int(currentScreenWidth)/2 - (arrayStb.count * 50))
            return UIEdgeInsets(top: 0, left: CGFloat(cellSt), bottom: 0, right: 10)
        }else
        {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
}
//MARK: Animation Extension
class TVHomePageTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return MyAccountPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionDismissing()
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionPresenting()
    }
}

class TVScreenPagePresentationController: UIPresentationController {
    let width = CGFloat(275)
    let height = CGFloat(263)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            x: 0,
            y: 0,
            width: containerView.frame.width,//width,
            height: containerView.frame.height
        )
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: width, height: height)
    }
}
extension TVHomePageViewController : HandlingPopUpAnimation {
    func animatedVCGettingDismissed(with image: UIImage){
        //remove added bgView for deviceIcon animation
    }
    func animateStreamboxToBack(with image: UIImage, frame: CGRect) {
        let bgAnimationView = self.view.viewWithTag(1000)
        self.streamBoxBackAnimation(image: image) { isAnimationCompleted in
            UIView.animate(withDuration: 0.4) {
                bgAnimationView?.alpha = 0.0
                self.setAlphaForUIElements(alpha: 1.0)
            } completion: { _ in
                bgAnimationView?.removeFromSuperview()
                UIView.performWithoutAnimation {
                    self.tvDeviceListCollView.reloadData()
                }
            }
        }
    }
}
