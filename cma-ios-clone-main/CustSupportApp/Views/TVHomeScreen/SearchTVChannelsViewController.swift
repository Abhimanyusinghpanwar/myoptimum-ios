//
//  SearchTVChannelsViewController.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 27/11/23.
//

import UIKit

class SearchTVChannelsViewController: UIViewController {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var closeButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchIcon: UIButton!
    @IBOutlet weak var searchCloseButton: UIButton!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var channelListTableview: UITableView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.topViewHeightConstraint.constant = 134
        self.channelListTableview.delegate = self
        self.channelListTableview.dataSource = self
        channelListTableview.register(UINib.init(nibName: "TVChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "channelCell")
        self.closeView.addTopShadow()
        self.closeButtonBottomConstraint.constant = UIDevice.current.hasNotch ? 41:30
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_MY_CHANNELS.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.deviceNameLabel.isHidden = true
        self.searchTextField.isHidden = false
        self.searchView.backgroundColor = .white
        self.searchCloseButton.isHidden = false
        self.searchIcon.isHidden = true
        self.topViewHeightConstraint.constant = 170
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : TVStreamTroubleshooting.TV_SEARCH_CHANNEL.rawValue, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Video.rawValue,CUSTOM_PARAM_CSR_TSR:CSR_TSR.TSR.rawValue,CUSTOM_PARAM_INTENT:Intent.Troubleshooting.rawValue])
    }
    
    
    @IBAction func searchCloseButtonTapped(_ sender: Any) {
        self.searchTextField.isHidden = true
        self.deviceNameLabel.isHidden = false
        self.searchView.backgroundColor = energyBlueRGB
        self.searchCloseButton.isHidden = true
        self.searchIcon.isHidden = false
        self.topViewHeightConstraint.constant = 134
     }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
extension SearchTVChannelsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.channelListTableview.dequeueReusableCell(withIdentifier: "channelCell") as! TVChannelTableViewCell
        cell.channelTypeLabel.layer.cornerRadius = 2
        cell.channelTypeLabel.layer.masksToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}

