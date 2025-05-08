//
//  PauseScheduleViewController.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 26/11/22.
//

import UIKit
import Lottie

class PauseScheduleViewController: UIViewController {
    enum State {
        case add(Profile)
        var profile: Profile {
            switch self {
            case let .add(profile):
                return profile
            }
        }
    }
    
    let original = 0.64
    let edit = 0.75
    let full = 1.0
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var pauseTableview: UITableView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    var saveInProgress = false
    @IBOutlet weak var animationLoadingView: LottieAnimationView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var bottomView: UIView!
    var state: State!
    @IBOutlet weak var profileAnimationview: LottieAnimationView!
    
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var vwProportionalHeight: NSLayoutConstraint!
    var heightIndexes: [Int : CGFloat] = [:]
    
    var pauseScheduleModels: [PauseScheduleModel]? = []
    var pauseTimerModels: [Int : PauseTimerModel] = [:]
    
    var tableDataSource: [Int :PauseScheduleModel] = [:]
        
    let cellAutomaticallyPause      = "AutomaticallyPauseInternetsTableViewCell"
    
    @IBOutlet weak var profileDescriptionLabel: UILabel!
    var titleDescription = "When do you want to pause Internet access for "
    
    ///Sample data for automatically pause internet list UI
    var sampleAutomaticallyPauseData = [["title":"At bedtime","icon":"icon_bedtime"],
                                        ["title":"During the day","icon":"icon_timing"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.configureUI()
        self.configureUIData()
        pauseTableview.register(UINib.init(nibName: "AutomaticallyPauseInternetsTableViewCell", bundle: nil), forCellReuseIdentifier: "AutomaticallyPauseInternetsTableViewCell")
        pauseTableview.tableFooterView = UIView()
        self.pauseTableview.rowHeight = UITableView.automaticDimension;
        self.pauseTableview.separatorStyle = .none
        self.pauseTableview.dataSource = self
        self.pauseTableview.delegate = self
    }
    
    func configureUIData() {
        let model = PauseScheduleModel()
        let model1 = PauseScheduleModel()
        model.cellIndex = 0
        tableDataSource[0] = model
        model1.cellIndex = 1
        tableDataSource[1] = model1
    }
    
    func configureUI() {
        profileLabel.text = state.profile.profile
        profileDescriptionLabel.text = "\(titleDescription) \(state.profile.profile ?? "")?"
//        let avatar: String
//
//        if var avatarId = Int(state.profile.avatar_id ?? "") {
//            if avatarId >= 13 || avatarId == 0 {
//                avatarId = 13
//            }
//            var avatarNames = AvatarConstants.names
//            if let letter = state.profile.profile?.prefix(1).capitalized {
//                avatarNames.append(letter)
//            }
//            avatar = avatarNames[avatarId - 1]
//        } else {
//            avatar = state.profile.profile?.prefix(1).capitalized ?? ""
//        }
//        let name: String = "\(avatar)-Profile-Pause-Online"
        profileAnimationview.createStaticImageForProfileAvatar(avatarID: state.profile.avatar_id, profileName: state.profile.profile)
        
        profileLabel.font = UIFont(name: "Regular-Medium", size: 16.8)
        primaryButton.layer.backgroundColor = UIColor(red: 0.965, green: 0.4, blue: 0.031, alpha: 1).cgColor
        primaryButton.setTitle("I'll do this later", for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        
        secondaryButton.setTitle("Cancel", for: .normal)
        secondaryButton.setTitleColor(.black, for: .normal)
        secondaryButton.layer.borderWidth = 2
        secondaryButton.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        
        self.bottomView.addTopShadow()
    }
    
    func updateUIButtons(hideSecond: Bool = true) {
        primaryButton.setTitle(hideSecond ? "I'll do this later" : "Save", for: .normal)
        secondaryButton.isHidden = hideSecond
    }
    
    func viewAnimationSetUp() {
        self.animationLoadingView.backgroundColor = .clear
        self.animationLoadingView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.animationLoadingView.loopMode = .playOnce
        self.animationLoadingView.animationSpeed = 1.0
        self.animationLoadingView.play(toProgress: 0.6, completion:{_ in
            if self.saveInProgress {
                self.animationLoadingView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }

    func stopAnimationAndDismiss() {
        self.saveInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
//                self.dismiss(animated: true)
            }
        }
        
    }

    func updateUIButtons(title: String, hideSecond: Bool = true) {
        primaryButton.setTitle(hideSecond ? title : "I'll do this later", for: .normal)
        secondaryButton.isHidden = hideSecond
    }
    
    @IBAction func onTapAction(_ sender: UIButton) {
        guard sender == primaryButton else {
            self.updateTimerDataOnCancel()
            animateUpdateTableView(secondaryHide: true)
            return
        }
        
        saveInProgress = true
        buttonStackView.isHidden = true
        animationLoadingView.isHidden = false
        viewAnimationSetUp()
        let title = primaryButton.currentTitle
        if title == "Save" {
            self.updateTimerDataOnSave()
        } else if title == "I’m done" {
            guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
            vc.state = .add(state.profile)
            vc.isShowPauseSchedule = false
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
            vc.state = .add(state.profile)
            vc.isShowPauseSchedule = false
            navigationController?.pushViewController(vc, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.buttonStackView.isHidden = false
            self.animationLoadingView.isHidden = true
        }
    }
    
    func updateTimerDataOnSave() {
        var anyErrors: [Bool] = []
        for index in 0...1 {
            self.checkForTimerErrors(index: index)
            if let isTimer = tableDataSource[index]?.isTimer, isTimer == true {
                guard let firstCell = self.pauseTableview.cellForRow(at: IndexPath(row: index, section: 0)) as? AutomaticallyPauseInternetsTableViewCell else { return }
                self.updatePauseScheduleDataModels(for: firstCell)
            }
            let model = tableDataSource[index]
            if model!.pauseTimeDates.displayErrorView || model!.pauseTimeDates.displayWErrorView {
                anyErrors.append(true)
            }
        }
        if anyErrors.count == 0 {
            callPauseSetApi()
            updateUIButtons(title: "I’m done", hideSecond: true)
            stopAnimationAndDismiss()
        } else {
            self.animationLoadingView.isHidden = true
            self.buttonStackView.isHidden = false
        }
        UIView.animate(withDuration: 0.5) {
            DispatchQueue.main.async {
                self.pauseTableview.reloadData()
            }
        }
    }
    
    func checkForTimerErrors(index: Int) {
        if let fromDate = tableDataSource[index]?.timerModel.fromDate, let toDate = tableDataSource[index]?.timerModel.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            tableDataSource[index]?.pauseTimeDates.displayErrorView = true
            tableDataSource[index]?.timerModel.displayErrorView = true
        } else {
            tableDataSource[index]?.pauseTimeDates.displayErrorView = false
            tableDataSource[index]?.timerModel.displayErrorView = false
        }
        
        if let fromDate = tableDataSource[index]?.weekEndModel.fromDate, let toDate = tableDataSource[index]?.weekEndModel.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            tableDataSource[index]?.pauseTimeDates.displayWErrorView = true
            tableDataSource[index]?.weekEndModel.displayErrorView = true
        } else {
            tableDataSource[index]?.pauseTimeDates.displayWErrorView = false
            tableDataSource[index]?.weekEndModel.displayErrorView = false
        }
    }
    
    func getTimeAndtimeTypefromDateForValidation(date: Date) -> (time: String, String) {
        var changedTimeString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        changedTimeString = formatter.string(from: date)
        return (time: changedTimeString , changedTimeString.components(separatedBy: " ").last ?? "")
    }

    func updateTimerDataOnCancel() {
        self.pauseTableview.reloadData()
        for inde in 0...1 {
            let model = tableDataSource[inde]
            if model?.isTimer == true {
                                tableDataSource[inde] = PauseScheduleModel()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.pauseTableview.reloadData()
            }
        }
    }
        
    func updatePauseScheduleDataModels(for cell: AutomaticallyPauseInternetsTableViewCell, index: Int = 0) {
        tableDataSource[cell.tag]?.isInitial = false
        tableDataSource[cell.tag]?.isTimer = false

        tableDataSource[cell.tag]?.timerModel.cellIndex = cell.tag
        tableDataSource[cell.tag]?.weekEndModel.cellIndex = cell.tag
        if let isError = tableDataSource[cell.tag]?.timerModel.displayErrorView, isError == true || tableDataSource[cell.tag]!.weekEndModel.displayErrorView == true {
            tableDataSource[cell.tag]?.timerModel.isTimerSaved = false
            tableDataSource[cell.tag]?.isTimer = true
        } else {
            tableDataSource[cell.tag]?.timerModel.isTimerSaved = true
            tableDataSource[cell.tag]?.isEdit = false
        }
        if tableDataSource[cell.tag]!.timerModel.displayErrorView == false && cell.pauseOnWeekEndsEnabled == true {
            if let isError = tableDataSource[cell.tag]?.weekEndModel.displayErrorView, isError == true {
                tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = false
                tableDataSource[cell.tag]?.isTimer = true
            } else {
                tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = true
                tableDataSource[cell.tag]?.weekEndModel.isWeekendsEnabled = true
                tableDataSource[cell.tag]?.isEdit = false
            }
        } else {
            tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = false
            tableDataSource[cell.tag]?.weekEndModel.isWeekendsEnabled = false
            tableDataSource[cell.tag]?.weekEndModel.isTimerSaved = false
        }
    }
        
    func animateUpdateTableView(secondaryHide: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.updateUIButtons(hideSecond: secondaryHide)
        }
    }
        
}

extension PauseScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleAutomaticallyPauseData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonUtility.getHeightForCellModel(model: tableDataSource[indexPath.row]!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellAutomaticallyPause) as! AutomaticallyPauseInternetsTableViewCell
        cell.profileTimeLabel.text = "What time during the day do you want to pause <profile name>'s internet?"
        cell.delegate = self
        cell.tag = indexPath.row
        cell.tapGestureForTimerView.isEnabled = false
        cell.profileName = state.profile.profile ?? ""
        cell.setUpDataInUI(data: sampleAutomaticallyPauseData, indexpath: indexPath)
       // cell.showTimerGesture.isEnabled = false
        guard let scheduleModel = tableDataSource[indexPath.row] else { return cell }
        
        if scheduleModel.timerModel.isTimerSaved == true || scheduleModel.weekEndModel.isTimerSaved == true {
            if scheduleModel.isEdit || scheduleModel.isTimer {
                cell.pauseOnWeekEndsEnabled = scheduleModel.weekEndModel.isWeekendsEnabled
                cell.configCellForEditSaved(model: scheduleModel)
                cell.layoutIfNeeded()
                return cell
            }
            cell.configCellForSaved(model: scheduleModel)
            cell.layoutIfNeeded()
            return cell
        }

        if scheduleModel.isTimer {
            cell.addTimeControl.isHidden = true
            cell.timerView.isHidden = false
            cell.pauseOnWeekEndsEnabled = scheduleModel.weekEndModel.isWeekendsEnabled
            cell.configCellForTimer(title: state.profile.profile ?? "", timerModel: scheduleModel.pauseTimeDates)
        } else if !scheduleModel.isTimer && scheduleModel.isInitial {
            cell.addTimeControl.isHidden = false
            cell.timerView.isHidden = true
            cell.tapGestureForTimerView.isEnabled = true
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let pauseCell = cell as! AutomaticallyPauseInternetsTableViewCell
        pauseCell.profileTimeLabel.text = "What time during the day do you want to pause <profile name>'s internet?"
        pauseCell.delegate = self
        pauseCell.tag = indexPath.row
        pauseCell.tapGestureForTimerView.isEnabled = false
        pauseCell.profileName = state.profile.profile ?? ""
        pauseCell.setUpDataInUI(data: sampleAutomaticallyPauseData, indexpath: indexPath)
       // pauseCell.showTimerGesture.isEnabled = false
        guard let scheduleModel = tableDataSource[indexPath.row] else { return }

        if scheduleModel.timerModel.isTimerSaved == true || scheduleModel.weekEndModel.isTimerSaved == true {
            if scheduleModel.isEdit || scheduleModel.isTimer {
                pauseCell.pauseOnWeekEndsEnabled = scheduleModel.weekEndModel.isWeekendsEnabled
                pauseCell.configCellForEditSaved(model: scheduleModel)
                pauseCell.layoutIfNeeded()
                return
            }
            pauseCell.configCellForSaved(model: scheduleModel)
            pauseCell.layoutIfNeeded()
            return
        }
        
        if scheduleModel.isTimer {
            pauseCell.addTimeControl.isHidden = true
            pauseCell.timerView.isHidden = false
            pauseCell.pauseOnWeekEndsEnabled = scheduleModel.isWeekendsEnabled
            pauseCell.configCellForTimer(title: state.profile.profile ?? "", timerModel: scheduleModel.pauseTimeDates)
        } else if !scheduleModel.isTimer && scheduleModel.isInitial {
            pauseCell.addTimeControl.isHidden = false
            pauseCell.timerView.isHidden = true
            pauseCell.tapGestureForTimerView.isEnabled = true
        }
        pauseCell.layoutIfNeeded()
    }
    
    func callPauseSetApi() {
        for index in 0...1 {
            if tableDataSource[index]?.timerModel.isTimerSaved == true {
                let model = tableDataSource[index]
                triggerPauseDevice(startTime: model?.timerModel.fromDate ?? Date(), endTime: model?.timerModel.fromDate ?? Date()) { success in
                    if success {
                        if model?.weekEndModel.isTimerSaved == true {
                            self.triggerPauseDevice(startTime: model?.weekEndModel.fromDate ?? Date(), endTime: model?.weekEndModel.toDate ?? Date()) { success in
                                if !success {
                                    // Handle api error / failure
                                }
                            }
                        }
                    } else {
                        // Handle api error / failure
                    }
                }
            }
        }
    }
    
    func triggerPauseDevice(startTime: Date, endTime: Date, isWeekEnds: Bool = false, completionHandler:@escaping (_ success:Bool) -> Void) {
        /*let days = isWeekEnds == true ? ["sat", "sun"] : ["mon", "tue", "wed", "thu", "fri"]
        guard let rules = ProfileManager.shared.createRestrictionRuleForProfile(enabled: true, endTime: endTime.getDateStringForAPIParam(), startTime: startTime.getDateStringForAPIParam(), days: days) else {
            return
        }
        guard let params = ProfileManager.shared.schedulePauseForProfile(pid: state.profile.pid ?? 0, rules: rules) else {
            return
        }
        APIRequests.shared.initiatePutAccessProfileRequest(pid:state.profile.pid, macID: nil, enablePause:true, jsonParams: params) { success, response, error in
            if success {
                Logger.info("success")
                completionHandler(true)
            } else if response == nil && error != nil {
                completionHandler(false)
               // self.presentErrorMessageVC()
            }
        }*/
    }
}

extension PauseScheduleViewController: PauseInternetCellDelegate {
    
    func deleteScheduleTimer() { }
    func removeTimerError(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseTimerModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                DispatchQueue.main.async {
                    self.pauseTableview.reloadData()
                }
            }
        }
    }
    
    func updateTimerData(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseTimerModel) {
        self.pauseTimerModels[cell.tag] = model
        self.tableDataSource[cell.tag]?.pauseTimeDates = model
        
        self.tableDataSource[cell.tag]?.timerModel.fromDate = model.fromDate
        self.tableDataSource[cell.tag]?.timerModel.toDate = model.toDate
        
        self.tableDataSource[cell.tag]?.weekEndModel.fromDate = model.fromWDate
        self.tableDataSource[cell.tag]?.weekEndModel.toDate = model.toWDate
        
    }
    
    func didTappedEdit(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseScheduleModel) {
        
        self.tableDataSource[cell.tag]?.isEdit = true
        self.tableDataSource[cell.tag]?.isTimer = true
        self.tableDataSource[cell.tag]?.isWeekendsEnabled = cell.pauseOnWeekEndsEnabled
        UIView.animate(withDuration: 0.5) {
            self.pauseTableview.reloadData()
            if self.secondaryButton.isHidden {
                self.updateUIButtons(hideSecond: false)
            }
        }
    }
    
    func didTappedTimer(cell: AutomaticallyPauseInternetsTableViewCell, isWeekEnd: Bool) {
        self.tableDataSource[cell.tag]?.isInitial = false
        self.tableDataSource[cell.tag]?.isTimer = true
        self.tableDataSource[cell.tag]?.weekEndModel = PauseTimeModel()
        self.tableDataSource[cell.tag]?.isWeekendsEnabled = isWeekEnd
        self.tableDataSource[cell.tag]?.weekEndModel.isWeekendsEnabled = isWeekEnd
        self.tableDataSource[cell.tag]?.pauseTimeDates.displayWErrorView = false
        UIView.animate(withDuration: 0.5) {
            self.pauseTableview.reloadData()
            if self.secondaryButton.isHidden {
                self.updateUIButtons(hideSecond: false)
            }
        }
    }
    
}

class PauseScheduleModel: Identifiable {
    var isInitial = true
    var isTimer = false
    var isSavedItem: Bool = false
    var cellIndex: Int = 0
    var fromTime: String = ""
    var toTime: String = ""
    var displayErrorView = false
    var isWeekendsEnabled: Bool = false
    var fromWTime: String = ""
    var toWTime: String = ""
    var displayWErrorView = false
    var isEdit: Bool = false
    var pauseTimeDates: PauseTimerModel = PauseTimerModel()
    var timerModel: PauseTimeModel = PauseTimeModel()
    var weekEndModel: PauseTimeModel = PauseTimeModel()
    var overlapModel: PauseOverlapModel = PauseOverlapModel()
    static func == (lhs: PauseScheduleModel, rhs: PauseScheduleModel) -> Bool {
        lhs.cellIndex == rhs.cellIndex
    }
}

class PauseTimerModel {
    var cellIndex: Int = 6
    var fromDate: Date?
    var toDate: Date?
    var fromWDate: Date?
    var isWeekendsEnabled: Bool = false
    var displayErrorView = false
    var displayWErrorView = false
    var overlapErrorView = false
    var overlapWErrorView = false
    var toWDate: Date?
}

class PauseTimeModel {
    var cellIndex: Int = 6
    var fromDate: Date?
    var toDate: Date?
    var isTimerSaved: Bool = false
    var displayErrorView = false
    var isWeekendsEnabled: Bool = false
    var isApiModel = false
}

class PauseOverlapModel {
    var fromDate: String = ""
    var toDate: String = ""
    var fromWDate: String = ""
    var toWDate: String = ""
    var overlapErrorView = false
    var overlapWErrorView = false
}
