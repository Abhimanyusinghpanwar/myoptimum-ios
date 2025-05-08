//
//  ExtenderInstallBaseViewController.swift
//  CustSupportApp
//
//  Created by vsamikeri on 2/24/23.
//

import UIKit

enum BarButtonType {
    case cancel
    case back
}
protocol BarButtonItemDelegate {
    func didTapBarbuttonItem(buttonType: BarButtonType)
}

class BaseViewController: UIViewController {
    
    var buttonDelegate: BarButtonItemDelegate?
    let extenderType = ExtenderDataManager.shared.extenderType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        configureNavigationBarItems()
    }
    
    
    func configureNavigationBarItems() {
        setupLeftBarItem()
        setupRightBarItem()
    }
    
    func hideLeftBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
    }
    
    func hideRightBarItem() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func setupLeftBarItem() {
        let left =  UIBarButtonItem(
            image: UIImage(named: "carat_left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTap)
        )
        left.imageInsets = UIEdgeInsets(top: 11, left: 4, bottom: 0, right: 0)
        left.tintColor = UIColor(named: "mediumGray")
        self.navigationItem.leftBarButtonItem = left
    }
    func setupRightBarItem() {
        let barButtonTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor:(textSoftBlackColor),
            .font: UIFont(name: "Regular-Medium", size: 18)!
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        let cancelBtn = UIButton(type: .custom)
        let myNormalAttributedTitle = NSAttributedString(string: "Cancel",
            attributes: barButtonTextAttributes)
        cancelBtn.setAttributedTitle(myNormalAttributedTitle, for: .normal)
        cancelBtn.addTarget(self, action: #selector(onTapCancelItem), for: .touchUpInside)
        cancelBtn.frame = CGRect(x: 44, y: 0, width: 54, height: 40)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 45))
        view.bounds = view.bounds.offsetBy(dx: 0, dy: -13)
        view.addSubview(cancelBtn)
        let right = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItem = right
    }
    func hideNavigationBar(hiddenFlag: Bool) {
        self.navigationController?.setNavigationBarHidden(hiddenFlag, animated: true)
    }
    
    @objc func backButtonTap(sender: UIBarButtonItem) {
        if let delegate = buttonDelegate {
            delegate.didTapBarbuttonItem(buttonType: .back)
        }else {
            self.navigationController?.popViewController(animated: true)
            }
    }
    @objc func onTapCancelItem(sender:UIBarButtonItem){
        if let delegate = buttonDelegate {
            delegate.didTapBarbuttonItem(buttonType: .cancel)
        }else {
            let storyboard = UIStoryboard(name: "MyAccount", bundle: nil)
            if let cancelVC = storyboard.instantiateViewController(withIdentifier: "cancelVC") as? CancelVC {
                cancelVC.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(cancelVC, animated: true)
            }
        }
    }
}
