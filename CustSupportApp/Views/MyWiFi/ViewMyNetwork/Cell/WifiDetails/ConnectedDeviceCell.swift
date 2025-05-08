//
//  ConnectedDeviceCell.swift
//  CustSupportApp
//
//  Created by Namarta on 01/09/22.
//

import Foundation

class ConnectedDeviceCell: UITableViewCell {
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    var isMasterProfile: Bool = false
    var arrCurrentConnectedDevices:[ConnectedDevice] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.layer.cornerRadius = 0
    }
    
    override func prepareForReuse() {
        self.layer.cornerRadius = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getConnectedDeviceRowView(arrConnectedDevices:[ConnectedDevice], row:Int) -> UIStackView {
        var viewArray: [ExtenderIconView] = []
        var tag = 0
        tag = (row - 1 ) * 3
        
        for device in arrConnectedDevices {
            if let contentViews =  Bundle.main.loadNibNamed("ExtenderIconView", owner: nil, options: nil), let view = contentViews.first as? ExtenderIconView {
                view.vwContainerHeight.constant = 114
                view.imageTopConstraint.constant = 30
                view.imageHeightConstraint.constant = 40
                view.imageWidthConstraint.constant = 40
                view.lblExtenderName.text = device.title
                view.lblExtenderName.font = UIFont(name: "Regular-Medium", size: 16)
                view.imgVwExtender.tag = tag + 5000
                tag += 1
                view.btnExtender.tag = tag
                view.btnExtender.addTarget(self, action: #selector(showSelectedDeviceDetails), for: .touchUpInside)
                vwContainer.backgroundColor = .white
                view.lblStatus.textColor = .black
                view.lblExtenderName.textColor = .black
                view.imgVwExtender.image = device.deviceImage_Gray
                view.btnExtender.tag = tag
                if ProfileManager.shared.isDeviceMacPaused(mac: device.macAddress ) {
                    view.lblStatus.text = "Paused"
                    view.lblStatus.isHidden = false
                    view.statusImage.isHidden = false
                    view.statusImage.backgroundColor = UIColor.StatusPause
                } else {
                    if !device.colorName.isEmpty {
                        view.lblStatus.isHidden = false
                        view.statusImage.isHidden = false
                        view.lblStatus.text = device.getColor().status
                        view.statusImage.backgroundColor = device.getColor().color
                    } else {
                        view.lblStatus.isHidden = true
                        view.statusImage.isHidden = true
                    }
                }
                viewArray.append(view)
            }
        }
        let stackView = UIStackView(arrangedSubviews: viewArray)
        stackView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }
    
    func addDevicesBasedOnArray(arrConnectedDevices:[ConnectedDevice]) {
        self.arrCurrentConnectedDevices = arrConnectedDevices
        vwContainer.subviews.forEach({ $0.removeFromSuperview() })
        let stackDetails = getNumberOfRows(devices: arrConnectedDevices)
        var extenderRowView = UIStackView()
        var numberOfStacks = stackDetails.0
        let itemsInLastStack = stackDetails.1
        var incrementFactor = 0
        var constantValue = 0
        var arraySlice = [ConnectedDevice]()
        var row = 1
        if itemsInLastStack != 0 {
            // Create a new array
             arraySlice = arrConnectedDevices.suffix(itemsInLastStack)
        }
        repeat {
            if numberOfStacks != 1 {
                extenderRowView = getConnectedDeviceRowView(arrConnectedDevices: Array(arrConnectedDevices[incrementFactor..<incrementFactor+3]), row: row)
            } else {
                // For single stack
                if numberOfStacks == 1 && itemsInLastStack == 0 && arrConnectedDevices.count < 4 {
                    extenderRowView = getConnectedDeviceRowView(arrConnectedDevices: Array(arrConnectedDevices[0..<arrConnectedDevices.count]), row: row)
                } else {
                    if itemsInLastStack != 0 {
                        // For last stack
                        extenderRowView = getConnectedDeviceRowView(arrConnectedDevices: arraySlice, row: row)
                    } else {
                        extenderRowView = getConnectedDeviceRowView(arrConnectedDevices: Array(arrConnectedDevices[incrementFactor..<incrementFactor+3]), row: row)
                    }
                }
            }
            self.vwContainer.addSubview(extenderRowView)
            extenderRowView.centerXAnchor.constraint(equalTo: self.vwContainer.centerXAnchor, constant: 0).isActive = true
            extenderRowView.topAnchor.constraint(equalTo: self.vwContainer.topAnchor, constant: CGFloat(constantValue)).isActive = true
            extenderRowView.heightAnchor.constraint(equalToConstant: 114).isActive = true
            numberOfStacks = numberOfStacks - 1
            row = row + 1
            constantValue = constantValue + 126
            incrementFactor = incrementFactor + 3
        } while numberOfStacks != 0

    }
    
    func getNumberOfRows(devices:[ConnectedDevice]) -> (Int, Int) {
        var (quotient, remainder) = devices.count.quotientAndRemainder(dividingBy:3)
        if remainder == 1 || remainder == 2 {
            quotient = quotient + 1
        }
        return (quotient, remainder)
    }
    
    //set top constraint on basis of height
    func getDynamicHeight(devices:[Extender])-> Int {
        var (quotient, remainder) = devices.count.quotientAndRemainder(dividingBy:3)
        if remainder == 1 || remainder == 2 {
            quotient = quotient + 1
        }
        return quotient * 120
    }
    
    func cancelCurrentQualtricsWorkItem(){
        guard let vc = parentViewController as? ViewProfileWithDeviceViewController else{
            return
        }
        vc.qualtricsAction?.cancel()
    }

    // MARK: - Extender Selection
    @objc func showSelectedDeviceDetails(sender:UIButton) {
        cancelCurrentQualtricsWorkItem()
        let deviceDetails = self.arrCurrentConnectedDevices[sender.tag - 1]
        guard let vc = parentViewController as? ViewProfileWithDeviceViewController else{ return}
        let frame = getFrameOfSelectedDevice(selectedIndex: sender.tag, fromVC : vc)
        vc.updateCurrentSelectedDeviceIndex(selectedIndex: sender.tag - 1, deviceMac: deviceDetails.macAddress)
        vc.addDeviceIconAsSubviewAndAnimate(frame: frame, iconImage: deviceDetails.deviceImage_White) { isAnimationCompleted in
            vc.navigateToConnectedDeviceDetailScreen(deviceDetail:deviceDetails)
        }
    }
    
    
    func getFrameOfSelectedDevice(selectedIndex: Int, fromVC : UIViewController)-> CGRect{
        var frame = CGRectZero
        for stackView in self.vwContainer.subviews {
            for extenderIconView in stackView.subviews {
                let selectedDeviceImgView = extenderIconView.viewWithTag(selectedIndex + 4999)
                if let selectedDeviceView = selectedDeviceImgView as? UIImageView {
                    frame = extenderIconView.convert(selectedDeviceView.frame, to: fromVC.view)
                    break
                }
            }
       }
        return frame
    }
}
