//
//  WhatsNewBillViewController.swift
//  CustSupportApp
//
//  Created by Vishal Kamalakar Deore on 05/10/23.
//

import UIKit
import Lottie
import SVGKit
import SafariServices
class WhatsNewViewController: UIViewController {
    
    @IBOutlet weak var lableHeader: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var svgImageview: UIImageView!
    @IBOutlet weak var tableViewDescription: UITableView!
    @IBOutlet weak var primaryButton: RoundedButton!
    @IBOutlet weak var secondaryButton: RoundedButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    var localFeatureIDsArray = NSMutableArray()
    var primaryButtonDeepLink: String?
    var secondaryButtonDeepLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func handleUI() {
        localFeatureIDsArray =  WhatsNewManager.shared.getFeatureIDs()
        self.viewBottomConstraint.constant = UIDevice.current.hasNotch ? 15:1
        self.loadJsonAnimationAndImage()
        // register TableViewCells
        self.tableViewDescription.register(UINib(nibName: "WhatsNewCell", bundle: nil), forCellReuseIdentifier: "WhatsNewCell")
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam: [EVENT_SCREEN_NAME: WhatsNewScreenDetails.WHATS_NEW_PAGE.rawValue, CUSTOM_PARAM_FIXED : Fixed.General.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue, CUSTOM_PARAM_INTENT: Intent.General.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance])
    }
    
    func updateShadowIfScrolling() {
        bottomView.layoutIfNeeded()
        tableViewDescription.isScrollEnabled = false
        let bottomY = bottomView.frame.minY
        let tblY = self.tableViewDescription.frame.minY
        var cellHght: CGFloat = 0
        for obj in tableViewDescription.visibleCells {
            if let cell = obj as? WhatsNewCell {
                cellHght = CGFloat(CGRectGetHeight( cell.bounds ))
            }
        }
        if tblY+cellHght > bottomY {
            bottomView.addTopShadow(topLight: true)
            tableViewDescription.isScrollEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShadowIfScrolling()
    }
    
    @IBAction func primaryButtonAction(_ sender: Any) {
        self.handleButtonAction(primaryButtonDeepLink)
    }
    
    @IBAction func secondaryButtonAction(_ sender: Any){
        self.handleButtonAction(secondaryButtonDeepLink)
    }
    
    private func handleButtonAction(_ deepLink: String?) {
        let link = deepLink?.isEmpty == true ? nil : deepLink
        if let link = link {
            handleDeeplinkValue(link: link)
        } else {
            self.dismissWhatsNewAndMoveToNextScreen()
        }
    }
    
    func handleDeeplinkValue(link: String) {
        if link == "mybill" {
            self.dismissWhatsNewAndMoveToNextScreen(autoLaunchBilling: true)
        } else {
            self.navigateToInAppBrowser(link, title: "")
        }
    }
    
    func dismissWhatsNewAndMoveToNextScreen(autoLaunchBilling: Bool = false) {
        DispatchQueue.main.async {
            if self.navigationController?.visibleViewController?.classNameFromInstance == HomeScreenViewController.classNameFromType {
                return // Return if home screen is already navigated once.
            }
            let homeVC = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(identifier: "HomeScreen") as HomeScreenViewController
            homeVC.autoLaunchBilling = autoLaunchBilling
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        APIRequests.shared.settingsAPIRequest(WhatsNewManager.shared.getSetNumber()) { success, response, error in
        }
    }
    
    func setUpButtons(buttonsData: NSMutableArray) {
        guard let buttonDataArray = buttonsData as? [[String: Any]] else { return }
        
        func setupButton(button: UIButton, withData data: [String: Any]) {
            button.setTitle(data["text"] as? String, for: .normal)
            button.isHidden = false
            
            let isPrimary = data["isPrimary"] as? Bool ?? false
            let backgroundColor: UIColor = isPrimary ? buttonOrangeColor : UIColor.white
            let titleColor: UIColor = isPrimary ? .white : textSoftBlackColor
            let borderColor: UIColor = isPrimary ? UIColor.white : buttonBorderGrayColor
            
            button.backgroundColor = backgroundColor
            button.setTitleColor(titleColor, for: .normal)
            button.viewBorderAttributes(borderColor.cgColor, 2, 30)
        }
        
        // Find the button data with displayOrder 1
        if let primaryButtonData = buttonDataArray.first(where: { ($0["displayOrder"] as? Int) == 1 }) {
            primaryButtonDeepLink = primaryButtonData["deeplink"] as? String
            setupButton(button: primaryButton, withData: primaryButtonData)
        } else {
            primaryButton.isHidden = true
        }
        
        // Find the button data with displayOrder 2
        if let secondaryButtonData = buttonDataArray.first(where: { ($0["displayOrder"] as? Int) == 2 }) {
            secondaryButtonDeepLink = secondaryButtonData["deeplink"] as? String
            setupButton(button: secondaryButton, withData: secondaryButtonData)
        } else {
            secondaryButton.isHidden = true
        }
    }
    
    func loadJsonAnimationAndImage() {
        if let featureID = localFeatureIDsArray.firstObject as? Int {
            let imageString = WhatsNewManager.shared.getFeatureImageData(featureID)
            if imageString.contains(".json") {
                let enableLoopAnim = WhatsNewManager.shared.getLoopAnimation(featureID)
                self.setupLottieAnimationViewWithJson(enableLoopAnim:enableLoopAnim)
                self.svgImageview.isHidden = true
            } else {
                self.setupImageView(from: imageString)
                self.svgImageview.isHidden = false
            }
        }
    }
    
    func setupLottieAnimationViewWithJson(enableLoopAnim:Bool) {
        let animation = LottieAnimation.filepath(WhatsNewManager.shared.getJsonAndSvgPathWhatsNewScreen(fileName: WhatsNewManager.shared.whatsNewImageJsonName))
        self.animationView.animation = animation
        self.animationView.contentMode = .scaleToFill
        if enableLoopAnim {
            self.animationView.loopMode = .loop
        } else {
            self.animationView.loopMode = .playOnce
        }
        
        self.animationView.animationSpeed = 1.0
        self.animationView.play()
        
    }
    
    func setupImageView(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if let svgImage = SVGKImage(contentsOf: url) {
            self.svgImageview.image = svgImage.uiImage
        }
    }
}

//MARK: UITableView Delegate/DataSource
extension WhatsNewViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WhatsNewCell") as? WhatsNewCell {
            if let featureID = localFeatureIDsArray[indexPath.row] as? Int {
                lableHeader.text = WhatsNewManager.shared.getFeatureHeadlineData(featureID) as String?
                self.setUpButtons(buttonsData: WhatsNewManager.shared.getFeatureButtons(featureID))
                var introTxt = ""
                var outroTxt = ""
                var bulletPoints: [String] = []
                if let introtxt = WhatsNewManager.shared.getFeatureIntroData(featureID) as String? {
                    introTxt = introtxt
                }
                if let outrotxt = WhatsNewManager.shared.getFeatureOutroData(featureID) as String? {
                    outroTxt = outrotxt
                }
                if let bulletpoints = WhatsNewManager.shared.getFeatureBulletsData(featureID) as [String]? {
                    bulletPoints = bulletpoints
                }
                cell.updateStackView(intro: introTxt,
                                     bulletPoints: bulletPoints, outro: outroTxt)
            }
            return cell
        }
        // Return a default cell if something went wrong
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localFeatureIDsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - SFSafariViewController Delegates
extension WhatsNewViewController: SFSafariViewControllerDelegate {
    func navigateToInAppBrowser(_ URLString : String, title : String) {
        let safariVC = SFSafariViewController(url: URL(string: URLString)!)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion:nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dismissWhatsNewAndMoveToNextScreen()
    }
}
