//
//  AdvancedSettingsUIViewController.swift
//  CustSupportApp
//
//  Created by Jason Melvin Ready on 7/19/22.
//

import Foundation

class AdvancedSettingsUIViewController: UIViewController{
    
    let headerTextColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    let descriptionTextColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    let headerColor = UIColor.init(red: 39.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    let dividerColor = UIColor.init(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 0.5)
    let headerFontSize = 18.0
    let descriptionFontSize = 15.0
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkInternetSpeedView: UIView!
    @IBOutlet weak var internetSpeedHeaderLabel: UILabel!
    @IBOutlet weak var internetSpeedDescriptionLabel: UILabel!
    @IBOutlet weak var internetSpeedButton: UIButton!
    @IBOutlet weak var manageMyHouseholdView: UIView!
    @IBOutlet weak var manageMyHouseholdHeaderLabel: UILabel!
    @IBOutlet weak var manageMyHouseholdDescriptionLabel: UILabel!
    @IBOutlet weak var manageMyHouseholdButton: UIButton!
    @IBOutlet weak var manageRouterSettingsView: UIView!
    @IBOutlet weak var manageRouterSettingsHeaderLabel: UILabel!
    @IBOutlet weak var manageRouterSettingsDescriptionLabel: UILabel!
    @IBOutlet weak var manageRouterSettingsButton: UIButton!
    @IBOutlet weak var closePageButton: UIButton!
    
    override func viewDidLoad() {
        setFontAndBackground()
        createDividers()
    }
    private func setFontAndBackground(){
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .white
        topView.backgroundColor = headerColor
        
        for headerLabel in [internetSpeedHeaderLabel, manageMyHouseholdHeaderLabel, manageRouterSettingsHeaderLabel]{
            headerLabel!.font = .boldSystemFont(ofSize: headerFontSize)
            headerLabel!.textColor = headerTextColor
        }
        for descriptionLabel in [internetSpeedDescriptionLabel, manageMyHouseholdDescriptionLabel, manageRouterSettingsDescriptionLabel]{
            descriptionLabel!.font = .boldSystemFont(ofSize: descriptionFontSize)
            descriptionLabel!.textColor = descriptionTextColor
        }
        internetSpeedHeaderLabel.font = .boldSystemFont(ofSize: 18)
        internetSpeedHeaderLabel.textColor = headerTextColor
        internetSpeedDescriptionLabel.font = .boldSystemFont(ofSize: 15)
        internetSpeedDescriptionLabel.textColor = descriptionTextColor
        
        closePageButton.titleLabel?.text = ""
    }
    private func createDividers(){
        for currentView in [checkInternetSpeedView, manageMyHouseholdView, manageRouterSettingsView]{
            let lineLayer = CALayer()
            lineLayer.frame = CGRect(x: 0, y: currentView!.frame.height - 1.0, width: currentView!.frame.width, height: 1.0)
            lineLayer.backgroundColor = dividerColor.cgColor
            currentView!.layer.addSublayer(lineLayer)
        }
    }
    
    @IBAction func internetSpeedButtonClicked(_ sender: Any) {
    }
    @IBAction func manageMyHouseholdButtonClicked(_ sender: Any) {
    }
    @IBAction func manageRouterSettingsButtonClicked(_ sender: Any) {
    }
    @IBAction func closePageButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
