//
//  PauseTimerViewController.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 09/02/23.
//

import UIKit
import Lottie

protocol PauseTimerVCDelegate {
    func didUpdatePauseModel(model: PauseScheduleModel, isCancel: Bool)
}

class PauseTimerViewController: UIViewController {

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
//    var state: PauseScheduleViewController.State!
    var profileModel:ProfileModel?
    @IBOutlet weak var profileAnimationview: LottieAnimationView!
    @IBOutlet weak var vwContent: UIView!
    var tableDataSource: [Int :PauseScheduleModel] = [:]
    @IBOutlet weak var profileDescriptionLabel: UILabel!
    var delegate: PauseTimerVCDelegate?
    var titleDescription = "When do you want to pause Internet access for "

    var sampleAutomaticallyPauseData = [["title":"At bedtime","icon":"icon_bedtime"],
                                        ["title":"During the day","icon":"icon_timing"]]

    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    let cellAutomaticallyPause      = "AutomaticallyPauseInternetsTableViewCell"
    var avalilablePauseTimers: [PauseSchedule] = []
    var selectedPauseTimer: PauseSchedule?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = false
        pauseTableview.register(UINib.init(nibName: "AutomaticallyPauseInternetsTableViewCell", bundle: nil), forCellReuseIdentifier: "AutomaticallyPauseInternetsTableViewCell")
        pauseTableview.tableFooterView = UIView()
        self.pauseTableview.rowHeight = UITableView.automaticDimension;
        self.pauseTableview.separatorStyle = .none
        self.configureUI()

        UIView.animate(withDuration: 0.5) {
            if self.secondaryButton.isHidden {
                self.updateUIButtons(hideSecond: false)
            }
        }
        self.pauseTableview.dataSource = self
        self.pauseTableview.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatevwContainerHeightWithAnimation(for: edit)
        self.avalilablePauseTimers = ProfileManager.shared.getPauseScheduleFor(pid: profileModel?.pid ?? 0) ?? []
    }
    
    func configureUI() {
        profileLabel.text = profileModel?.profile?.profile
        profileDescriptionLabel.text = "\(titleDescription) \(profileModel?.profile?.profile ?? "")?"
        profileAnimationview.createStaticImageForProfileAvatar(avatarID: profileModel?.profile?.avatar_id, profileName: profileModel?.profile?.profile)
        
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

    @IBAction func onTapAction(_ sender: UIButton) {
        guard sender == primaryButton else {
            self.updateTimerDataOnCancel()
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
//            vc.state = .add(state.profile)
            vc.isShowPauseSchedule = false
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = ProfileCompletionViewController.instantiateWithIdentifier(from: .profile) else { return }
//            vc.state = .add(state.profile)
            vc.isShowPauseSchedule = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func updateTimerDataOnCancel() {
        let index = tableDataSource.first?.key
        let pauseModel = PauseScheduleModel()
        pauseModel.cellIndex = index!
        pauseModel.timerModel.cellIndex = index!
        pauseModel.weekEndModel.cellIndex = index!
        tableDataSource[index!] = pauseModel
        self.delegate?.didUpdatePauseModel(model: tableDataSource.first!.value, isCancel: true)
        self.dismiss(animated: true)
        
//        for inde in 0...0 {
//            let model = tableDataSource[inde]
//            if model?.isTimer == true {
//                let index = tableDataSource.first?.key
//                tableDataSource[index!] = PauseScheduleModel()
//            }
//        }
//        self.delegate?.didUpdatePauseModel(model: tableDataSource.first!.value)
//        self.dismiss(animated: true)
    }

    func viewAnimationSetUp() {
        self.animationLoadingView.backgroundColor = .clear
        self.animationLoadingView.animation = LottieAnimation.named("OrangeHalfWidthButton")
        self.animationLoadingView.loopMode = .loop
        self.animationLoadingView.animationSpeed = 1.0
        self.animationLoadingView.play()
        self.animationLoadingView.play(toProgress: 0.6, completion:{_ in
            if self.saveInProgress {
                self.animationLoadingView.play(fromProgress: 0.2, toProgress: 0.6, loopMode: .autoReverse)
            }
        })
    }
    
    func updatevwContainerHeightWithAnimation(for value: CGFloat = 0.65) {
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveLinear, animations: {
            self.viewHeightConstraint.constant = UIScreen.main.bounds.height * value
            self.vwContent.layoutIfNeeded()
        }) { finished in
            // animation done
        }
    }

    func updateTimerDataOnSave() {
        var anyErrors: [Bool] = []
        for index in 0...0 {
            self.checkForTimerErrors(index: index)
            if let isTimer = tableDataSource.first?.value.isTimer, isTimer == true {
                guard let firstCell = self.pauseTableview.cellForRow(at: IndexPath(row: index, section: 0)) as? AutomaticallyPauseInternetsTableViewCell else { return }
                self.updatePauseScheduleDataModels(for: firstCell)
            }
            let model = tableDataSource.first?.value
            if model!.pauseTimeDates.displayErrorView || model!.pauseTimeDates.displayWErrorView {
                anyErrors.append(true)
            }
        }
        if anyErrors.count == 0 {
            callPauseSetApi()
//            stopAnimationAndDismiss()
//            updateUIButtons(title: "I’m done", hideSecond: true)
        } else {
            self.animationLoadingView.isHidden = true
            self.buttonStackView.isHidden = false
//            DispatchQueue.main.async {
                self.pauseTableview.reloadData()
            self.vwContent.layoutIfNeeded()

//            }
//            UIView.animate(withDuration: 0.5) {
//            }
        }
    }

    func updateUIButtons(title: String, hideSecond: Bool = true) {
        primaryButton.setTitle(hideSecond ? title : "I'll do this later", for: .normal)
        secondaryButton.isHidden = hideSecond
    }

    func stopAnimationAndDismiss() {
        self.saveInProgress = false
        DispatchQueue.main.async {
            self.animationLoadingView.pause()
            self.animationLoadingView.play(fromProgress: 0.6, toProgress: 1.0, loopMode: .playOnce) { _ in
                self.dismissAndUpdateTimerData()
            }
        }
    }
    
    func stopAnimationForFailure() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.buttonStackView.isHidden = false
            self.animationLoadingView.isHidden = true
        }
    }
    
    func dismissAndUpdateTimerData() {
        self.delegate?.didUpdatePauseModel(model: tableDataSource.first!.value, isCancel: false)
        self.dismiss(animated: true)
    }
    
    
    func updateDataForApiFailure() {
        tableDataSource.first?.value.isTimer = true
    }
    
    func callDeletePauseTimerApi() {
//        saveInProgress = true
//        buttonStackView.isHidden = true
//        animationLoadingView.isHidden = false
//        self.viewAnimationSetUp()
//        guard let id = selectedPauseTimer?.profileId else {
//            self.stopAnimationForFailure()
//            return
//        }
//        APIRequests.shared.initiateGetAccessProfileRequest(profileId: id) { success, response, error in
//            if success {
//                Logger.info("success")
//            } else if response == nil && error != nil {
//                self.stopAnimationForFailure()
//            }
//        }
    }
    
    func callPauseSetApi() {
            if tableDataSource.first?.value.timerModel.isTimerSaved == true {
//                let model = tableDataSource.first?.value
//                let isWeekEnabled = model?.weekEndModel.isTimerSaved
                triggerPauseDevice() { success in
                    if success {
                        self.stopAnimationAndDismiss()
//                        if isWeekEnabled == true {
//                            self.triggerPauseDevice(startTime: model?.weekEndModel.fromDate ?? Date(), endTime: model?.weekEndModel.toDate ?? Date()) { success in
//                                if success {
//                                    self.stopAnimationAndDismiss()
//                                } else {
//                                    self.updateDataForApiFailure()
//                                    self.stopAnimationForFailure()
//                                    // Handle api error / failure
//                                }
//                            }
//                        } else {
//                            self.stopAnimationAndDismiss()
//                        }
                    } else {
                        self.updateDataForApiFailure()
                        self.stopAnimationForFailure()
                        // Handle api error / failure
                    }
                }
            }
    }
    
    func triggerPauseDevice(completionHandler:@escaping (_ success:Bool) -> Void) {
//        let days = isWeekEnds == true ? ["sat", "sun"] : ["mon", "tue", "wed", "thu", "fri"]
//        guard let rules = ProfileManager.shared.createRestrictionRuleForProfile(enabled: true, endTime: endTime.getDateStringForAPIParam(), startTime: startTime.getDateStringForAPIParam(), days: days) else {
//            return
//        }
//        guard let params = ProfileManager.shared.schedulePauseForProfile(pid: profileModel?.pid ?? 0, rules: rules) else {
//            return
//        }
//        guard let pauseParams = ProfileManager.shared.createPauseTimerTempRules() else {
//            return
//        }
        /*guard let pauseParams = ProfileManager.shared.createPauseScheduleForDevice(scheduleModel: tableDataSource.first!.value) else { return }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: pauseParams, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        print(jsonString)
    
        APIRequests.shared.initiatePutAccessProfileRequest(pid:profileModel?.pid, macID: nil, enablePause: true, jsonParams: pauseParams) { success, response, error in
            if success {
                Logger.info("success")
                completionHandler(true)
            } else if response == nil && error != nil {
                completionHandler(false)
               // self.presentErrorMessageVC()
            }
        }*/
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
    
    func checkForTimerErrors(index: Int) {
        if let fromDate = tableDataSource.first?.value.timerModel.fromDate, let toDate = tableDataSource.first?.value.timerModel.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            tableDataSource.first?.value.pauseTimeDates.displayErrorView = true
            tableDataSource.first?.value.timerModel.displayErrorView = true
        } else {
            tableDataSource.first?.value.pauseTimeDates.displayErrorView = false
            tableDataSource.first?.value.timerModel.displayErrorView = false
        }
        
        if let fromDate = tableDataSource.first?.value.weekEndModel.fromDate, let toDate = tableDataSource.first?.value.weekEndModel.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            
            tableDataSource.first?.value.pauseTimeDates.displayWErrorView = true
            tableDataSource.first?.value.weekEndModel.displayErrorView = true
        } else {
            tableDataSource.first?.value.pauseTimeDates.displayWErrorView = false
            tableDataSource.first?.value.weekEndModel.displayErrorView = false
        }
    }
    
    func getTimeAndtimeTypefromDateForValidation(date: Date) -> (time: String, String) {
        var changedTimeString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        changedTimeString = formatter.string(from: date)
        return (time: changedTimeString , changedTimeString.components(separatedBy: " ").last ?? "")
    }

}

extension PauseTimerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonUtility.getHeightForCellModel(model: tableDataSource.first!.value)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellAutomaticallyPause) as! AutomaticallyPauseInternetsTableViewCell
        cell.profileTimeLabel.text = "What time during the day do you want to pause <profile name>'s internet?"
        cell.delegate = self
        cell.tag = tableDataSource.first?.key ?? 0
        cell.tapGestureForTimerView.isEnabled = false
        cell.profileName = profileModel?.profile?.profile ?? ""
        cell.setUpDataInUI(data: sampleAutomaticallyPauseData, indexpath: indexPath)
        guard let scheduleModel = tableDataSource.first?.value else { return cell }
        cell.enableDeleteScheule(forSaved: !scheduleModel.timerModel.isApiModel)
        if scheduleModel.timerModel.isTimerSaved == true || scheduleModel.weekEndModel.isTimerSaved == true {
            if scheduleModel.isEdit || scheduleModel.isTimer {
                cell.pauseOnWeekEndsEnabled = scheduleModel.weekEndModel.isWeekendsEnabled
                cell.configCellForEditSaved(model: scheduleModel)
                cell.layoutIfNeeded()
                return cell
            }
        }

        if scheduleModel.isTimer {
            cell.addTimeControl.isHidden = true
            cell.timerView.isHidden = false
            cell.pauseOnWeekEndsEnabled = scheduleModel.weekEndModel.isWeekendsEnabled
            cell.configCellForTimer(title: profileModel?.profile?.profile ?? "", timerModel: scheduleModel.pauseTimeDates)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let pauseCell = cell as! AutomaticallyPauseInternetsTableViewCell
        pauseCell.profileTimeLabel.text = "What time during the day do you want to pause <profile name>'s internet?"
        pauseCell.delegate = self
        cell.tag = tableDataSource.first?.key ?? 0
        pauseCell.tapGestureForTimerView.isEnabled = false
        pauseCell.profileName = profileModel?.profile?.profile ?? ""
        pauseCell.setUpDataInUI(data: sampleAutomaticallyPauseData, indexpath: indexPath)
        guard let scheduleModel = tableDataSource.first?.value else { return }

        if scheduleModel.timerModel.isTimerSaved == true || scheduleModel.weekEndModel.isTimerSaved == true {
            if scheduleModel.isEdit || scheduleModel.isTimer {
                pauseCell.pauseOnWeekEndsEnabled = scheduleModel.weekEndModel.isWeekendsEnabled
                pauseCell.configCellForEditSaved(model: scheduleModel)
                pauseCell.layoutIfNeeded()
                return
            }
        }
        
        if scheduleModel.isTimer {
            pauseCell.addTimeControl.isHidden = true
            pauseCell.timerView.isHidden = false
            pauseCell.pauseOnWeekEndsEnabled = scheduleModel.isWeekendsEnabled
            pauseCell.configCellForTimer(title: profileModel?.profile?.profile ?? "", timerModel: scheduleModel.pauseTimeDates)
        }
        pauseCell.layoutIfNeeded()
    }
        
}

extension PauseTimerViewController: PauseInternetCellDelegate {
    func deleteScheduleTimer() {
        self.callDeletePauseTimerApi()
    }
    
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
        self.tableDataSource.first?.value.pauseTimeDates = model
        
        self.tableDataSource.first?.value.timerModel.fromDate = model.fromDate
        self.tableDataSource.first?.value.timerModel.toDate = model.toDate
        
        self.tableDataSource.first?.value.weekEndModel.fromDate = model.fromWDate
        self.tableDataSource.first?.value.weekEndModel.toDate = model.toWDate
        
        self.tableDataSource.first?.value.pauseTimeDates.displayErrorView = model.displayErrorView
        self.tableDataSource.first?.value.pauseTimeDates.displayWErrorView = model.displayWErrorView
        
        self.tableDataSource.first?.value.overlapModel.overlapErrorView = model.overlapErrorView
        self.tableDataSource.first?.value.overlapModel.overlapWErrorView = model.overlapWErrorView
        
        DispatchQueue.main.async {
            self.pauseTableview.reloadData()
        }
    }
    
    func didTappedEdit(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseScheduleModel) {
//        self.tableDataSource[cell.tag]?.cellIndex = cell.tag
//        self.tableDataSource[cell.tag]?.isEdit = true
//        self.tableDataSource[cell.tag]?.isTimer = true
//        UIView.animate(withDuration: 0.5) {
//            self.pauseTableview.reloadData()
//            if self.secondaryButton.isHidden {
//                self.updateUIButtons(hideSecond: false)
//            }
//        }
    }
    
    func didTappedTimer(cell: AutomaticallyPauseInternetsTableViewCell, isWeekEnd: Bool) {
        self.tableDataSource.first?.value.isInitial = false
        self.tableDataSource.first?.value.isTimer = true
        self.tableDataSource.first?.value.weekEndModel = PauseTimeModel()
        self.tableDataSource.first?.value.isWeekendsEnabled = isWeekEnd
        self.tableDataSource.first?.value.pauseTimeDates.displayWErrorView = false
        self.tableDataSource.first?.value.weekEndModel.isWeekendsEnabled = isWeekEnd
        UIView.animate(withDuration: 0.5) {
            self.pauseTableview.reloadData()
            if self.secondaryButton.isHidden {
                self.updateUIButtons(hideSecond: false)
            }
        }
    }
    
}
