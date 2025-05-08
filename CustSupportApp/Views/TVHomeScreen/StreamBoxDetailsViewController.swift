//
//  StreamBoxDetailsViewController.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 05/01/24.
//

import UIKit

class StreamBoxDetailsViewController: UIViewController {

    @IBOutlet weak var detailsTableview: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var streamDeviceArray : [DeviceDetail] = []
    var delegate : HandlingPopUpAnimation?
    var streamBox : TVStreamBox?
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var streamIcon: UIImageView!
    var qualtricsAction : DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.statusLabel.layer.masksToBounds = true
        self.statusLabel.layer.cornerRadius = 7
        self.setUpData()
        self.detailsTableview.register(UINib(nibName: "StreamDeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "streamDeviceCell")
        detailsTableview.delegate = self
        detailsTableview.dataSource = self
        self.streamIcon.alpha = 1.0
        self.statusLabel.alpha = 0.0
        self.detailsTableview.alpha = 0.0
        self.nameLabel.alpha = 0.0
        self.editBtn.alpha = 0.0
    }
    
    func setUpData() {
        self.streamDeviceArray = []
        self.nameLabel.text = streamBox?.friendlyname.isEmpty == true ||
        streamBox?.friendlyname == streamBox?.macAddress ? "Optimum Stream" : self.streamBox?.friendlyname 
        streamDeviceArray.append(DeviceDetail(title: "Equipment Type", value: "Optimum Stream"))
        streamDeviceArray.append(DeviceDetail(title: "Serial Number", value: self.streamBox?.serial.uppercased() ?? ""))
        streamDeviceArray.append(DeviceDetail(title: "MAC Address", value: WifiConfigValues.checkMACFormat(mac: self.streamBox?.macAddress.uppercased() ?? "")))
        self.streamIcon.image = self.streamBox?.image
        //CMAIOS-2143 Handled 32 char stream box name
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.5
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2 ) {
            self.streamIcon.alpha = 1.0
            self.statusLabel.alpha = 0.0
            self.detailsTableview.alpha = 1.0
            self.nameLabel.alpha = 1.0
            self.editBtn.alpha = 1.0
        }
        if MyWifiManager.shared.refreshLTDataRequired {
            MyWifiManager.shared.refreshLTDataRequired = false
            updateExterderData()
        }
        qualtricsAction = self.checkQualtrics(screenName: TVStreamTroubleshooting.TV_DEVICE_DETAILS.rawValue, dispatchBlock: &qualtricsAction)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_DEVICE_DETAILS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    func updateExterderData() {
        let arrayOfSTB = MyWifiManager.shared.getTvStreamDevices()
        let stbNode = arrayOfSTB.filter {WifiConfigValues.checkMACFormat(mac: $0.macAddress).isMatching(WifiConfigValues.checkMACFormat(mac: self.streamBox?.macAddress ?? ""))}.first
        let deviceImageValue = streamBox?.deviceType
        self.streamBox = TVStreamBox.init(friendlyname: stbNode?.friendlyname ?? "", macAddress: stbNode?.macAddress ?? "", image: DeviceManager.IconType.white.getStreamImage(name: deviceImageValue?.lowercased() == "unknown" ? "" : deviceImageValue), deviceType: stbNode?.deviceType ?? "", serial: stbNode?.serial ?? "")
        self.setUpData()
        self.detailsTableview.reloadData()
    }
        
    func getSTBSerial() -> String {
        var serialNumber = ""
        let stbDetails = MyWifiManager.shared.getSTBs()
        let stbDetail = stbDetails.filter{(streamBox?.macAddress.replacingOccurrences(of: ":", with: "").isMatching($0.device_mac) ?? false)}
        if stbDetail.count > 0 {
            serialNumber = stbDetail[0].device_serial ?? ""
        }
        return serialNumber
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
        UIView.animate(withDuration: 0.4) { [self] in
            self.delegate?.animateStreamboxToBack?(with: self.streamIcon.image!, frame: self.streamIcon.frame)
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func renameStreamBoxTapped(_ sender: Any) {
        self.qualtricsAction?.cancel()
        let networkPointRename = UIStoryboard(name: "WiFiScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "NetworkPointRename") as! NetworkPointRenameViewController
        networkPointRename.modalPresentationStyle = .fullScreen
        networkPointRename.isFromTVFlow = true
        let arrayOfSTB = MyWifiManager.shared.getTvStreamDevices()
        let stbNode = arrayOfSTB.filter { WifiConfigValues.checkMACFormat(mac: $0.macAddress ).isMatching(WifiConfigValues.checkMACFormat(mac: self.streamBox?.macAddress ?? "")) }.first
        let deviceImageValue = streamBox?.deviceType
        let name = streamBox?.friendlyname.isEmpty == true ||
        streamBox?.friendlyname == streamBox?.macAddress ? "Optimum Stream" : self.streamBox?.friendlyname
        networkPointRename.extender = Extender(title: name ?? "", colorName: "", status: "", device_type: stbNode?.deviceType ?? "", conn_type: "", macAddress: stbNode?.macAddress ?? "", ipAddress: "", band: "", image: DeviceManager.IconType.white.getStreamImage(name: deviceImageValue?.lowercased() == "unknown" ? "" : deviceImageValue), hostname: "", category: "other")
        self.present(networkPointRename, animated: false, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qualtricsAction?.cancel()
    }
}
// Mark: - Tableview Delegate and Datasource

extension StreamBoxDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streamDeviceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.detailsTableview.dequeueReusableCell(withIdentifier: "streamDeviceCell") as? StreamDeviceTableViewCell else { return UITableViewCell() }
        cell.propertyTypeLabel.text = streamDeviceArray[indexPath.row].title
        cell.propertyDetailsLabel.text = streamDeviceArray[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34.0
    }
}
