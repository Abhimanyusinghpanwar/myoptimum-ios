//
//  PausedDevicesListViewController.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 22/01/23.
//

import UIKit

class PausedDevicesListViewController: BaseViewController, BarButtonItemDelegate, UITableViewDelegate, UITableViewDataSource {
        func didTapBarbuttonItem(buttonType: BarButtonType) {
            if buttonType == .back {
                self.navigationController?.popViewController(animated: true)
            } else {
                onTapCancel()
            }
        }
    @IBOutlet weak var pausedDevicesTableView: UITableView!
    @IBOutlet weak var fixedProblemButton: UIButton!
    @IBOutlet weak var notFixedProblemButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var noPauseDevicesLabel: UILabel!
    var deviceWithSectionsArray : DeviceDetails?

    @IBAction func fixedMyProblemButton(_ sender: UIButton) {
        IntentsManager.sharedInstance.screenFlow = .none
        self.dismiss(animated: true)
    }
    
    @IBAction func notFixedMyProblemButton(_ sender: UIButton) {
        if isFromNoInternetCell {
            guard let vc = OneDeviceSlowViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = RestartMyGateWayViewController.instantiateWithIdentifier(from: .Troubleshooting) else { return }
            MyWifiManager.shared.isFromSpeedTest = false
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    var isFromNoInternetCell: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDelegate = self
        noPauseDevicesLabel.isHidden = true
        notFixedProblemButton.layer.borderColor = UIColor(red: 152/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        notFixedProblemButton.layer.borderWidth = 2.0
        self.pausedDevicesTableView.register(UINib(nibName: "PausedDeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "PausedDevice")
        self.pausedDevicesTableView.register(UINib(nibName: "PausedDeviceHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "PausedDeviceHeader")
        self.pausedDevicesTableView.register(UINib(nibName: "LineSeparationTableViewCell", bundle: nil), forCellReuseIdentifier: "LineSeparation")
        self.pausedDevicesTableView.separatorStyle = .none

        self.buttonView.layer.shadowColor = UIColor.gray.cgColor
        self.buttonView.layer.shadowOpacity = 0.5
        self.buttonView.layer.shadowRadius = 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return deviceWithSectionsArray?.arrOfSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let key =  deviceWithSectionsArray?.arrOfSections?[section] else { return 0 }
        let deviceList = deviceWithSectionsArray?.dictOfDevicesWithSections?[key]
        return (deviceList?.count ?? 0) + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let key =  deviceWithSectionsArray?.arrOfSections?[indexPath.section] else { return 0 }
        let deviceList = deviceWithSectionsArray?.dictOfDevicesWithSections?[key]
        if indexPath.row == (deviceList?.count ?? 0) + 1 {
            return 15
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let key =  deviceWithSectionsArray?.arrOfSections?[indexPath.section] else { return 0 }
        let deviceList = deviceWithSectionsArray?.dictOfDevicesWithSections?[key]
        if indexPath.row == (deviceList?.count ?? 0) + 1 {
            return 15
        } else {
            return 78
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.pausedDevicesTableView.dequeueReusableCell(withIdentifier: "PausedDeviceHeader") as! PausedDeviceHeaderTableViewCell
            cell.lineSeparationView.isHidden = true
            cell.headerLabel.isHidden = false
            cell.headerLabel.text = deviceWithSectionsArray?.arrOfSections?[indexPath.section]
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = self.pausedDevicesTableView.dequeueReusableCell(withIdentifier: "PausedDevice") as! PausedDeviceTableViewCell
            guard let key =  deviceWithSectionsArray?.arrOfSections?[indexPath.section] else { return UITableViewCell() }
            let deviceList = deviceWithSectionsArray?.dictOfDevicesWithSections?[key]
            cell.selectionStyle = .none
            cell.indexPath = indexPath as NSIndexPath
            cell.checkView.isHidden = true
            cell.lineSeparationView.isHidden = false
            cell.deviceDetailView.isHidden = false
            cell.deviceImageView.isHidden = false
            cell.unpauseView.isHidden = false
            cell.pausedDelegate = self
            if indexPath.row <= deviceList!.count  {
                let device = deviceList?[indexPath.row - 1]
                cell.deviceNameLabel.text = device?.title
                cell.deviceImageView.image = device?.deviceImage_Gray
                if indexPath.row == deviceList!.count {
                    cell.lineSeparationView.isHidden = true
                } else {
                    cell.lineSeparationView.isHidden = false
                }
            } else {
                let cell = self.pausedDevicesTableView.dequeueReusableCell(withIdentifier: "LineSeparation") as! LineSeparationTableViewCell
                return cell
            }
            return cell
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
    
    func presentErrorMessageVC() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Errors", bundle: nil).instantiateViewController(identifier: "ErrorMessageVC") as ErrorMessageViewController
            vc.isComingFromProfileCreationScreen = false
            vc.modalPresentationStyle = .fullScreen
            vc.errorMessageString = GeneralAPIFailureMessages.getAPIFailureMessage(forKey: .set_pause_internet_failure)
            self.present(vc, animated: true)
        }
    }
    
    func onTapCancel() {
        let storyboard = UIStoryboard(name: "Troubleshooting", bundle: nil)
        if let cancelVC = storyboard.instantiateViewController(withIdentifier: "CancelTrubleShootingViewController") as? CancelTroubleShootingViewController {
            cancelVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(cancelVC, animated: true)
        }
    }

}

extension PausedDevicesListViewController: pausedDeviceDelegate {
    func reloadUnpauseRow(_ indexPath: NSIndexPath) {
        self.pausedDevicesTableView.isUserInteractionEnabled = false
        let indexpath = indexPath as IndexPath
        let key =  self.deviceWithSectionsArray?.arrOfSections?[indexPath.section]
        let deviceList = self.deviceWithSectionsArray?.dictOfDevicesWithSections?[key ?? ""]
        if let device = deviceList?[indexPath.row - 1] {
            let macAddress = device.macAddress
            APIRequests.shared.initiatePutAccessProfileRequest(pid:(device.pid > 0) ? device.pid : nil, macID:macAddress, enablePause:false, pausedBy: (device.pid > 0) ? APIRequests.PausedBy.clientWithPid : APIRequests.PausedBy.client) { success, response, error in
                if success {
                    Logger.info("success")
                    ProfileManager.shared.getPausedDevices()
                    DispatchQueue.main.async {
                        guard let selectedCell = self.pausedDevicesTableView.cellForRow(at: IndexPath(row: indexpath.row, section: indexPath.section)) as? PausedDeviceTableViewCell else { return }
                        selectedCell.checkIconImageView.isHidden = false
                        selectedCell.deviceUnpausedLabel.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                            self.deviceWithSectionsArray?.dictOfDevicesWithSections?[key ?? ""]?.remove(at: indexpath.row - 1)
                            if let deviceArray = self.deviceWithSectionsArray, let deviceSection = deviceArray.dictOfDevicesWithSections, let arrKeys =  deviceSection[key ?? ""], arrKeys.isEmpty {
                                self.deviceWithSectionsArray!.arrOfSections!.remove(at: indexPath.section)
                            }
                            self.pausedDevicesTableView.reloadData()
                            self.pausedDevicesTableView.isUserInteractionEnabled = true
                            if self.deviceWithSectionsArray!.arrOfSections!.isEmpty {
                                self.noPauseDevicesLabel.isHidden = false
                                self.pausedDevicesTableView.isHidden = true
                            }
                        }
                    }
                } else if response == nil && error != nil {
                    self.presentErrorMessageVC()
                }
            }
        }
    }
}
