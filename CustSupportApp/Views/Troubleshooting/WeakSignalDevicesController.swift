//
//  WeakSignalDevicesController.swift
//  CustSupportApp
//
//  Created by vishali Test on 09/02/23.
//

import UIKit
import Lottie

class WeakSignalDevicesController: UIViewController {
    let cellConnectedDeviceList         = "ConnectedDevicesListTableViewCell"
    let cellHeader = "SectionHeaderTableViewCell"
    //Table View Outlet Connections
    @IBOutlet weak var weakDevicesTblView: UITableView!
     var weakDevicesDetail:DeviceDetails?
    //add device icon at left bottom of the Screen
    var deviceIconFrame = CGRect(x: 36.0, y: currentScreenHeight - 130.0, width: 50.0, height: 50.0)
    @IBOutlet weak var bgView:UIView?
   // @IBOutlet weak var pullToRefreshAnimationView: UIView!
    @IBOutlet weak var pullToRefreshCircleView: UIView!
    @IBOutlet weak var pullToRefreshView: UIView!
    @IBOutlet weak var labelTopView: NSLayoutConstraint!
    var isPullToRefresh: Bool = false
    @IBOutlet weak var pullToanimateView: LottieAnimationView!
    @IBOutlet weak var pullTorefreshTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullToRefreshHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerLabel.text = "Here are the devices with a weak signal"
        self.headerLabel.setLineHeight(1.2)
        weakDevicesTblView.register(UINib.init(nibName: cellConnectedDeviceList, bundle: nil), forCellReuseIdentifier: cellConnectedDeviceList)
        weakDevicesTblView.register(UINib.init(nibName: cellHeader, bundle: nil), forCellReuseIdentifier: cellHeader)
        bgView?.layer.cornerRadius = 10
        bgView?.layer.masksToBounds = true
        bgView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.pullToRefreshView.isHidden = true
        pullToRefreshCircleView.isHidden = true
        self.pullTorefreshTopConstraint.constant = 0
        self.pullToRefreshCircleView.layer.cornerRadius = self.pullToRefreshCircleView.bounds.height / 2
        self.initiatePullToRefresh()
        self.shadowView.addTopShadow()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Refresh screen data
        if MyWifiManager.shared.refreshLTDataRequired {
            weakDevicesDetail = MyWifiManager.shared.populateConnectedDevices(filterWeakStatus: true, withSections: true)
            self.weakDevicesTblView.reloadData()
            MyWifiManager.shared.refreshLTDataRequired = false
        }
       self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
    }
    
    @IBAction func onClickHowToFixThisButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Troubleshooting", bundle: nil).instantiateViewController(identifier: "OneDeviceSlowViewController") as OneDeviceSlowViewController
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickMayBeLaterButton(_ sender: Any) {
        APIRequests.shared.isReloadNotRequiredForMaui = false
        self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    func initiatePullToRefresh() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer.direction = .down
        swipeDownGestureRecognizer.addTarget(self, action: #selector(pullToRefresh))
        self.view?.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    @objc func pullToRefresh(hideScreen hide:Bool, isComplete: Bool = false) {
        self.pullToRefreshView.isHidden = false
        self.pullToRefreshCircleView.isHidden = false
        self.pullToanimateView.isHidden = false
        self.pullToanimateView.animation = LottieAnimation.named("AutoLogin")
        self.pullToanimateView.backgroundColor = .clear
        self.pullToanimateView.loopMode = !isComplete ? .loop : .playOnce
        self.pullToanimateView.animationSpeed = 1.0
        if !hide {
            //self.removeButtonAction(isAllowed: false)
            UIView.animate(withDuration: 0.5) {
                self.isPullToRefresh = true
               // self.pullTorefreshTopConstraint.constant = currentScreenWidth > 390.0 ? 40 : 60
                self.pullTorefreshTopConstraint.constant = 60
                self.labelTopView.constant = 130
                self.buttonViewBottomConstraint.constant = -120
                self.pullToRefreshHeightConstraint.constant = 20
                self.pullToanimateView.play(fromProgress: 0, toProgress: 0.9, loopMode: .loop)
                self.view.isUserInteractionEnabled = false
                self.view.layoutIfNeeded()
                self.didPullToRefresh()
                
            }
        } else {
            self.pullToanimateView.play() { _ in
                UIView.animate(withDuration: 0.5) {
                    self.isPullToRefresh = false
                    self.pullToanimateView.stop()
                    self.pullToanimateView.isHidden = true
                    self.pullTorefreshTopConstraint.constant = -60
                    self.pullToRefreshHeightConstraint.constant = 0
                    self.labelTopView.constant = 40
                    self.buttonViewBottomConstraint.constant = 10
                    self.view.isUserInteractionEnabled = true
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func didPullToRefresh() {
       NotificationCenter.default.addObserver(self, selector: #selector(self.lightSpeedAPICallBackForWeakDevices), name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
        MyWifiManager.shared.triggerOperationalStatus()
        
    }
    
    @objc func lightSpeedAPICallBackForWeakDevices (){
        self.pullToRefresh(hideScreen: true, isComplete: true)
        weakDevicesDetail = MyWifiManager.shared.populateConnectedDevices(filterWeakStatus: true, withSections: true)
        self.weakDevicesTblView.reloadData()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LightSpeedAPI"), object: nil)
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


extension WeakSignalDevicesController: UITableViewDelegate, UITableViewDataSource{
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       guard let key =  weakDevicesDetail?.arrOfSections?[section] else { return 0 }
       let deviceList = weakDevicesDetail?.dictOfDevicesWithSections?[key]
       return deviceList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.weakDevicesTblView.dequeueReusableCell(withIdentifier: cellConnectedDeviceList) as! ConnectedDevicesListTableViewCell
        cell.deviceNameTopConstraint.constant = 20.0
        guard let key =  weakDevicesDetail?.arrOfSections?[indexPath.section] else { return UITableViewCell() }
        let deviceList = weakDevicesDetail?.dictOfDevicesWithSections?[key]
        let device = deviceList?[indexPath.row]
        cell.lblTitle.text = device?.title
        cell.imgViewType.image = device?.deviceImage_Gray
        cell.lblStatus.text = "Weak signal"
        cell.imgViewStatus.backgroundColor = UIColor.StatusWeak
        if indexPath.row == (deviceList?.count ?? 0) - 1 {
            cell.vwBottomLine.isHidden = true
        } else {
            cell.vwBottomLine.isHidden = false
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  weakDevicesDetail?.arrOfSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var string =  weakDevicesDetail?.arrOfSections?[section]
        if let headerName = string, !headerName.isEmpty {
            if headerName == "personal and computer" {
                string = "Personal and Computer" //For casing issues
            } else {
                string = headerName.firstCapitalized
            }
        }
        let headerView = UIView()
        if section == 0 {
            let headerLine = UILabel()
            headerLine.frame = CGRect(x: 23, y: 0, width: UIScreen.main.bounds.width - 50, height: 1)
            headerLine.backgroundColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0)
            headerView.addSubview(headerLine)
        }
        let headerLabel = UILabel()
        var y = 0
        if section == 0 { y = 26
        } else { y = 0 }
        headerLabel.frame = CGRect(x: 23, y: y, width: Int(UIScreen.main.bounds.width) - 23, height: 22)
        headerLabel.text = string
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "Regular-Medium", size: 20)
        headerView.addSubview(headerLabel)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 86.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = section == 0 ? 55.0 : 30.0
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let key =  weakDevicesDetail?.arrOfSections?[indexPath.section] else { return  }
        let deviceList = weakDevicesDetail?.dictOfDevicesWithSections?[key]
        let device = deviceList?[indexPath.row]
        self.addDeviceIconAsSubviewAndAnimate(frame: self.deviceIconFrame, iconImage: device?.deviceImage_White ?? DeviceManager.IconType.white.getDeviceImage(name: "unknown")) { isAnimationCompleted in
            self.navigateToConnectedWeakDeviceDetailScreen(deviceDetail:device)
        }
    }
}

//MARK: Navigation Methods
extension WeakSignalDevicesController{
    func navigateToConnectedWeakDeviceDetailScreen(deviceDetail:ConnectedDevice?) {
        let viewController = UIStoryboard(name: "ConnectedDeviceDetails", bundle: nil).instantiateViewController(identifier: "ConnectedDeviceDetailVC") as ConnectedDeviceDetailVC
            viewController.deviceDetails = deviceDetail
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
    }
}

//MARK: HandlingPopUpAnimation protocol methods
extension WeakSignalDevicesController : HandlingPopUpAnimation {
    
    func animatedVCGettingDismissed(with image: UIImage){
        //remove added bgView for deviceIcon animation
        let bgAnimationView = self.view.viewWithTag(1000)
        self.animateDeviceIconFromTopToBottom(image: image) { isAnimationCompleted in
            UIView.animate(withDuration: 0.5) {
                bgAnimationView?.alpha = 0.0
                self.setAlphaForUIElements(alpha: 1.0)
            } completion: { _ in
                bgAnimationView?.removeFromSuperview()
            }
        }
    }
}
