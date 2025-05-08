//
//  XtendInstallRenameVC.swift
//  CustSupportApp
//
//  Created by vsamikeri on 11/30/22.
//

import UIKit

protocol XtendInstallRenameVCDelegate
{
    func didClickDone()
}

class XtendInstallRenameVC: UIViewController, XtendInstallRenameVCDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRenameXtendView()
    }
    
    func configureRenameXtendView() {
        let storyboard = UIStoryboard(name: "WiFiScreen", bundle: nil)
        if let renameViewController = storyboard.instantiateViewController(withIdentifier: "NetworkPointRename") as? NetworkPointRenameViewController {
            
            let extenderArray = MyWifiManager.shared.getExtendersFromNodes()
            if let firstExtender = extenderArray.filter({$0.device_type == "Extender"}).first
            {
                
                renameViewController.extender = Extender.init(title: "", colorName: "", status: firstExtender.status ?? "", device_type: firstExtender.cma_equipment_type_display ?? firstExtender.device_type ?? "", conn_type: firstExtender.conn_type ?? "", macAddress: firstExtender.mac ?? "", ipAddress: firstExtender.ip ?? "", band: firstExtender.band ?? "", image: DeviceManager.IconType.white.getExtenderImage(name: firstExtender.cma_display_name), hostname: firstExtender.hostname ?? "", category: firstExtender.cma_category ?? "")
            }
            renameViewController.modalPresentationStyle = .fullScreen
            
            self.addChild(renameViewController)
            view.addSubview(renameViewController.view)
            renameViewController.xtendDelegate = self
            renameViewController.reloadTableViewForRenameXtend()
            renameViewController.didMove(toParent: self)
            renameViewController.renameNetworkPointTableView.backgroundColor = .clear
            renameViewController.cancelButton.removeFromSuperview()
            renameViewController.saveButton.setTitle("Done", for: .normal)
        }
    }
    
    func didClickDone() {
        let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "xtendInstallSuccessVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
