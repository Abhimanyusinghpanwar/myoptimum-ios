//
//  MyWifiDetailsTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 24/08/22.
//

import UIKit
import Lottie

enum SelectedNodeType{
    case Gateway
    case Extender
    case None
}

protocol ExtendersDelegate {
    func pushDeviceListDown()
    func pullDeviceListUp()
    func setSelectedExtenderTheme(theme:UIColor)
    func navigateToNetworkDetailsScreen(_ cell: MyWifiDetailsTableViewCell, selectedNodeType: SelectedNodeType)
    func animateCloseBtnViewDown()
    func animateCloseBtnViewTop()
}
class MyWifiDetailsTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var extenderViewHeightConst: NSLayoutConstraint!
    
    //Label Outlet Connections
    @IBOutlet weak var lblWifiContent: UILabel!
    @IBOutlet weak var lblWifiStatus: UILabel!
    @IBOutlet weak var lblWiFiName: UILabel!
    @IBOutlet weak var wifiViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblWiFiViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var wifiViewBottomConstraintFromSuperView: NSLayoutConstraint!
    @IBOutlet weak var editWifiViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var equipmentImageTopConstraintToSuperview: NSLayoutConstraint!
    @IBOutlet weak var btnEditGateway: UIButton!
    @IBOutlet weak var lblWiFiPassword: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var equipmentImage: UIImageView!
    //Animation Outlet Connections
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    
    //Button Outlet Connections
    @IBOutlet weak var editControl: UIControl!
    @IBOutlet weak var btnEdit: UIButton!
    var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
    //Extender Selection
    var extenderDelegate: ExtendersDelegate!
    var selectedExtenderView: ExtenderIconView?
    var selectedTag = -1
    var initialThemeColor:UIColor = .clear
    var selectedNodeType : SelectedNodeType = .None
    //Extender Data
    var arrExtenders:[Extender] = []
    var extenderDetails: Extender?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
        showCircleAnimation()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDefaultValues() {
        btnEdit.setTitle("", for: .normal)
        self.contentView.backgroundColor = .clear
        if UIDevice.current.hasNotch {
            self.lblWiFiViewTopConstraint.constant = self.lblWiFiViewTopConstraint.constant - 12
            wifiViewBottomConstraint.constant = 20.0
        } else {
            wifiViewBottomConstraint.constant = 10.0
        }
    }
    // MARK: - Main List Data setup
    func updateSSID(animation:Bool) {
        DispatchQueue.main.async {
            if let twoG = MyWifiManager.shared.twoGHome, twoG.allKeys.count > 0 {
                if let ssid = twoG.value(forKey: "SSID") as? String, !ssid.isEmpty,
                   let password = twoG.value(forKey: "password") as? String, !password.isEmpty {
                    self.lblWiFiName.text = ssid
                    self.lblWiFiPassword.text = password
                    self.showEditWifiNameView(animate:animation)
                }
            }
        }
    }
    func showEditWifiNameView(animate:Bool) {
        if self.viewAnimation.transform.ty == 0 {
            self.editControl.isHidden = false
            self.editControl.alpha = 0.0
            if animate {
                UIView.animate(withDuration: 0.5) {
                    self.editControl.alpha = 1.0
                }
            } else {
                self.editControl.alpha = 1.0
            }
        }
    }
    
    func updateGatewayName() {
        let gateway = MyWifiManager.shared.getMasterGatewayDetails()
        if !gateway.name.isEmpty {
            self.lblWifiContent.text = gateway.name
            self.lblWifiStatus.text = gateway.statusText
            self.imgStatus.backgroundColor = gateway.statusColor
            self.contentView.backgroundColor = gateway.bgColor
            self.equipmentImage.image = gateway.equipmentImage
        }
    }
    
    func addExtender(arrExtenders:[Extender], showFadeEffect:Bool, handlePullToRefresh: Bool) {
        vwContainer.subviews.forEach({ $0.removeFromSuperview() })
        self.arrExtenders = arrExtenders
        if arrExtenders.count <= 3 {
            let extenderRowView = getExtenderRowView(arrExtenders: arrExtenders, row: 1, isFromPulltopRefresh: handlePullToRefresh)
            self.vwContainer.addSubview(extenderRowView)
            extenderRowView.centerXAnchor.constraint(equalTo: self.vwContainer.centerXAnchor, constant: 0).isActive = true
            extenderRowView.centerYAnchor.constraint(equalTo: self.vwContainer.centerYAnchor, constant: 0).isActive = true
            self.extenderViewHeightConst.constant = 114
        } else {
            let extenderRowView1 = getExtenderRowView(arrExtenders: Array(arrExtenders[0...2]), row: 1, isFromPulltopRefresh: handlePullToRefresh)
            self.vwContainer.addSubview(extenderRowView1)
            extenderRowView1.centerXAnchor.constraint(equalTo: self.vwContainer.centerXAnchor, constant: 0).isActive = true
            extenderRowView1.topAnchor.constraint(equalTo: self.vwContainer.topAnchor, constant: 0).isActive = true
            
            let extenderRowView2 = getExtenderRowView(arrExtenders: Array(arrExtenders[3..<arrExtenders.count]), row: 2, isFromPulltopRefresh: handlePullToRefresh)
            self.vwContainer.addSubview(extenderRowView2)
            extenderRowView2.centerXAnchor.constraint(equalTo: self.vwContainer.centerXAnchor, constant: 0).isActive = true
           // extenderRowView2.centerYAnchor.constraint(equalTo: self.vwContainer.centerYAnchor, constant: 0).isActive = true
            extenderRowView2.topAnchor.constraint(equalTo: extenderRowView1.bottomAnchor, constant: 5).isActive = true
            self.extenderViewHeightConst.constant = 233
        }
        
        if showFadeEffect {
            fadeInEffectOnView(view: vwContainer)
        } else {
            vwContainer.isHidden = false
            vwContainer.alpha = 1.0
        }
    }
    
    func getExtenderRowView(arrExtenders:[Extender], row:Int, isFromPulltopRefresh: Bool) -> UIStackView {
        
        var viewArray: [ExtenderIconView] = []
        var tag = 0
        if row == 2 { tag = 3 }
        for extender in arrExtenders {
            if let contentViews =  Bundle.main.loadNibNamed("ExtenderIconView", owner: nil, options: nil), let view = contentViews.first as? ExtenderIconView {
                if currentScreenWidth > 375.0{
                    view.lblExtenderName.font = UIFont(name: "Regular-Medium", size: 18.0)
                } else {
                    view.lblExtenderName.font = UIFont(name: "Regular-Medium", size: 17.5)
                }
                view.lblExtenderName.text = extender.title
                view.imgVwExtender.contentMode = .scaleAspectFit
                view.imgVwExtender.image = extender.image
                view.viewLeadingConstraint.priority = .defaultHigh
                view.viewTrailingConstraint.priority = .defaultHigh
                view.btnEditWidthConstraint.constant = 0.0
                tag += 1
                view.btnExtender.tag = tag
                if !isFromPulltopRefresh {
                    view.btnExtender.addTarget(self, action: #selector(extenderSelected), for: .touchUpInside)
                }
                if extender.status == "Offline" {
                    view.lblStatus.text = extender.status
                    view.statusImage.backgroundColor = .StatusOffline
                } else {
                    let colorStatus = extender.getColor()
                    view.lblStatus.text = colorStatus.status
                    view.statusImage.backgroundColor = colorStatus.color
                }
                if arrExtenders.count == 1 {
                    view.viewLeadingConstraint.priority = .defaultLow
                    view.viewTrailingConstraint.priority = .defaultLow
                }
                viewArray.append(view)
                if selectedTag == view.btnExtender.tag {
                    selectedExtenderView = view
                }
            }
        }
        let stackView = UIStackView(arrangedSubviews: viewArray)
        
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5

        
        return stackView
    }
    
    // MARK: - Gateway Selection
    ///Method for ViewMyNetwork Page Call
    func setTapActionForAnimationView() {
        let viewMyNetworkTap = UITapGestureRecognizer(target: self, action: #selector(self.gatewaySelected(_:)))
        viewAnimation.addGestureRecognizer(viewMyNetworkTap)
    }
    
    @objc func gatewaySelected(_ sender: UITapGestureRecognizer? = nil) {
        cancelCurrentQualtricsWorkItem()
        selectedNodeType = .Gateway
        UIView.animate(withDuration: 0.5) {
            let yTransform = 79.0 // 85.0 for larger screens
            self.viewAnimation.transform = CGAffineTransform(translationX: 0, y: yTransform * -1)
            self.vwContainer.alpha = 0.0
            self.editControl.alpha = 0.0
            self.extenderDelegate.pushDeviceListDown()
            self.extenderDelegate.animateCloseBtnViewDown()
        } completion: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.extenderDelegate.navigateToNetworkDetailsScreen(self ?? MyWifiDetailsTableViewCell(), selectedNodeType: .Gateway)
            }
            
        }
    }
    
    func cancelCurrentQualtricsWorkItem(){
        guard let vc = parentViewController as? ViewMyNetworkViewController else{
            return
        }
        vc.qualtricsAction?.cancel()
    }
    
    func updateBackgroundTheme(themeColor: UIColor){
        self.contentView.backgroundColor = themeColor
    }
    
    // MARK: - Extender Selection
    @objc func extenderSelected(sender:UIButton) {
        cancelCurrentQualtricsWorkItem()
        selectedNodeType = .Extender
        self.selectedTag = sender.tag
        extenderDetails = arrExtenders[sender.tag - 1]
        self.selectedExtenderView = self.getSelectedExtenderView(selectedTag: sender.tag)
        //CMAIOS-2355 update theme color as per extender state(Weak, Offline, Online) and status color
        if let selectedExtender = extenderDetails, selectedExtender.status == "Offline" || selectedExtender.status == "Weak signal" || selectedExtender.colorName.isMatching("orange") {
            updateBackgroundTheme(themeColor: midnightBlueRGB)
        }
        self.extenderDelegate.setSelectedExtenderTheme(theme: extenderDetails?.getThemeColor() ?? energyBlueRGB)
        UIView.animate(withDuration: 0.5) {
           
            self.beginExtenderSelectionUIUpdate(selectedExtenderView: self.selectedExtenderView)
            //self.vwContainer.alpha = 0.0
            self.editControl.alpha = 0.0
            self.extenderDelegate.pushDeviceListDown()
            self.extenderDelegate.animateCloseBtnViewDown()
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.vwContainer.subviews.first?.subviews.forEach({ if $0 != self.selectedExtenderView {  $0.alpha = 0.0 } })
            } completion: { _ in
                self.extenderDelegate.navigateToNetworkDetailsScreen(self, selectedNodeType: .Extender)
            }
            
        }
    }
    
    func getSelectedExtenderView(selectedTag: Int) -> ExtenderIconView? {
        for stackView in self.vwContainer.subviews{
            for extender in stackView.subviews {
                if let selectedExtenderView = extender as? ExtenderIconView, selectedExtenderView.btnExtender.tag == selectedTag {
                    return selectedExtenderView
                }
            }
        }
        return nil
    }
    
    
    func beginExtenderSelectionUIUpdate(selectedExtenderView: ExtenderIconView?) {
        if let view = selectedExtenderView{
            let frame = self.contentView.convert(view.frame, from:view.superview)
            var xTransform = 0.0
            let xDestinationPoint = (currentScreenWidth/2 - 60.0)
            let yDestinationPoint = 15.0 //18.0//37.0
            
            if frame.origin.x > xDestinationPoint {
                xTransform = frame.origin.x - xDestinationPoint
                xTransform = -1 * xTransform
            } else {
                xTransform =  xDestinationPoint - frame.origin.x
            }
            
            let yTransform = (frame.origin.y - yDestinationPoint) * -1
                view.transform = CGAffineTransform(translationX: xTransform, y: yTransform)
                self.viewAnimation.transform = CGAffineTransform(translationX: 0, y: -500)
                self.vwContainer.subviews.first?.subviews.forEach({ if $0 != view {  $0.alpha = 0.5 } })
                self.editControl.alpha = 0.0
        }
    }
    
    // MARK: - Animation Helpers
    func showCircleAnimation() {
        viewAnimation.animation = LottieAnimation.named("WiFiCirclePulseDefault")
        viewAnimation.backgroundColor = .clear
        viewAnimation.loopMode = .loop
        viewAnimation.animationSpeed = 1.0
        viewAnimation.play()
    }
    
    func fadeEffectOnViewWithoutDuration(view:UIView){
          view.isHidden = false
          view.alpha = 1.0
    }
}

