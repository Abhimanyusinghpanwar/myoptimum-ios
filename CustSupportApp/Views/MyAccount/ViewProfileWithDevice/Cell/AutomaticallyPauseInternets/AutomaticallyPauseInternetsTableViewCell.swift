//
//  AutomaticallyPauseInternetsTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 03/10/22.
//

protocol PauseInternetCellDelegate {
    func didTappedTimer(cell: AutomaticallyPauseInternetsTableViewCell, isWeekEnd: Bool)
    func didTappedEdit(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseScheduleModel)
    func updateTimerData(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseTimerModel)
    func removeTimerError(cell: AutomaticallyPauseInternetsTableViewCell, model: PauseTimerModel)
    func deleteScheduleTimer()
}

public enum ArrowSelection {
    case Up
    case Down
    case None
}

import UIKit

class AutomaticallyPauseInternetsTableViewCell: UITableViewCell {
    
    typealias ChangedDateTime = (time: String, String, date: Date)

    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwBorderView: UIView!
    //ImageView Outlet Connections
    @IBOutlet weak var imgViewType: UIImageView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var addTimeControl: UIControl!
    
    @IBOutlet weak var fromUpButton: UIButton!
    @IBOutlet weak var fromDownButton: UIButton!
    @IBOutlet weak var toUpButton: UIButton!
    @IBOutlet weak var toDownButton: UIButton!
    
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var fromPmLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var toPMLabel: UILabel!
    
    // w - weekends
    @IBOutlet weak var wfromUpButton: UIButton!
    @IBOutlet weak var wfromDownButton: UIButton!
    @IBOutlet weak var wtoUpButton: UIButton!
    @IBOutlet weak var wtoDownButton: UIButton!
    
    var tapGesture:UITapGestureRecognizer!
    @IBOutlet weak var pauseOnWeekEndsLabel: UILabel!
    
    @IBOutlet weak var profileTimeLabel: UILabel!
    @IBOutlet weak var dayTimelineLabel: UILabel!
    
    var cellTimerModel: PauseTimerModel?
    var  previousTimeOnLabel = ""
    var  previousWeekendTimeOnLabel = ""
    // For Selected Timer Outlets
    // s - selected
    
    var pauseModel: PauseScheduleModel?
    var shouldSavePreviousTime = false
    var shouldSavePreviousWeekendTime = false
    @IBOutlet weak var sImageView: UIImageView!
    
    @IBOutlet weak var sTitleLabel: UILabel!
    @IBOutlet weak var editTimerButton: UIButton!
    @IBOutlet weak var timerSelectedView: UIView!
    @IBOutlet weak var dottedSeperatorView: UIView!
        
    @IBOutlet weak var sWeeknightsLabel: UILabel!
    @IBOutlet weak var sWeekenightsTimeLabel: UILabel!
    @IBOutlet weak var selectedTimerWeekEndsView: UIView!
    @IBOutlet weak var sWeekendsLabel: UILabel!
    @IBOutlet weak var sWeekendsTimeLabel: UILabel!
    var timeArray = ["12:00","12:30","1:00","1:30","2:00","2:30","3:00","3:30","4:00","4:30","5:00",
                     "5:30","6:00","6:30","7:00","7:30","8:00","8:30","9:00","9:30","10:00","10:30",
                     "11:00","11:30"]
    
    var profileTitle = ["When is profile's bedtime?", "What time during the day do you want to pause profile's internet?"]
    var profileTime = ["On weeknights", "On weekdays"]

    var profileName: String = ""
    var pauseOnWeekEndsEnabled: Bool = false
    var isTimerOptionsEnabled: Bool = false
    
    
    @IBOutlet weak var fromWTimeLabel: UILabel!
    @IBOutlet weak var fromWPmLabel: UILabel!
    @IBOutlet weak var toWTimeLabel: UILabel!
    @IBOutlet weak var toWPmLabel: UILabel!
    
    @IBOutlet weak var pauseWeekendsButton: UIButton!
    var delegate: PauseInternetCellDelegate?
    @IBOutlet weak var weekendStackView: UIStackView!
    
    @IBOutlet weak var timerErrorView: UIView!
    @IBOutlet weak var timerErrorImageView: UIImageView!
    @IBOutlet weak var errorDescriptionLabel: UILabel!
    
    // WeekEndErrorView
    @IBOutlet weak var weekTimerErrorView: UIView!
    @IBOutlet weak var weekTimerErrorImageVew: UIImageView!
    @IBOutlet weak var weekTimerErrorDescLabel: UILabel!
    var tapGestureForTimerView : UITapGestureRecognizer!
    
    @IBOutlet weak var vwContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deleteScheduleButton: UIButton!
    let lineTextColor = UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00)
    var showTimerGesture: UITapGestureRecognizer!
    let time3 = 6
    let time6 = 12
    let time7 = 14
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tapGestureForTimerView = UITapGestureRecognizer(target: self, action: #selector(self.showTimersView))
        vwContainer.addGestureRecognizer(tapGestureForTimerView)
        self.configCell()
        setUpUIAttributes()
    }
    
    override func prepareForReuse() {
        self.configCell()
        setUpUIAttributes()
        cellTimerModel = nil
    }
    
    func configCell() {
        self.imgViewType.isHidden = false
        timerSelectedView.isHidden = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.pauseOnWeekendsTapped))
        self.pauseOnWeekEndsLabel.addGestureRecognizer(tapGesture)
        fromUpButton.setTitle("", for: .normal)
        fromDownButton.setTitle("", for: .normal)
        toUpButton.setTitle("", for: .normal)
        toDownButton.setTitle("", for: .normal)
        pauseWeekendsButton.setTitle("", for: .normal)
        wfromUpButton.setTitle("", for: .normal)
        wfromDownButton.setTitle("", for: .normal)
        wtoUpButton.setTitle("", for: .normal)
        wtoDownButton.setTitle("", for: .normal)
        editTimerButton.setTitle("", for: .normal)
        pauseWeekendsButton.setImage(UIImage(named: "unCheck"), for: .normal)
        dottedSeperatorView.addDashedBorder(color: UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1))
        self.profileTimeLabel.text = "What time during the day do you want to pause <profile name>'s internet?"
        timerErrorView.isHidden = true
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.systemRed,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributeString = NSMutableAttributedString(
            string: "Delete schedule",
            attributes: underlineAttributes
        )
        deleteScheduleButton.setAttributedTitle(attributeString, for: .normal)
        deleteScheduleButton.isHidden = true

        timerErrorView.layer.cornerRadius = 20
        timerErrorView.layer.borderWidth = 1
        timerErrorView.layer.borderColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1).cgColor
        
        weekTimerErrorView.isHidden = true
        weekTimerErrorView.layer.cornerRadius = 20
        weekTimerErrorView.layer.borderWidth = 1
        weekTimerErrorView.layer.borderColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func enableDeleteScheule(forSaved: Bool = false) {
        deleteScheduleButton.isHidden = forSaved
    }
    
    func updateTimersForSaved(model: PauseScheduleModel) {
        
        let fromTimeDate = (self.getTimeAndtimeTypefromDate(date: model.timerModel.fromDate ?? Date()))
        let toTimeDate = (self.getTimeAndtimeTypefromDate(date: model.timerModel.toDate ?? Date()))
        fromTimeLabel.text = fromTimeDate.time
        fromPmLabel.text = fromTimeDate.1
        toTimeLabel.text = toTimeDate.time
        toPMLabel.text = toTimeDate.1
        updateWeekendsEnabled(enabled: model.weekEndModel.isWeekendsEnabled)
        if model.weekEndModel.isWeekendsEnabled {
            guard let fromTime = model.weekEndModel.fromDate, let toTime = model.weekEndModel.toDate else {
                fromWTimeLabel.text = self.getWeekEndFromTimeForSaved().time
                fromWPmLabel.text = self.getWeekEndFromTimeForSaved().1
                toWTimeLabel.text = self.getWeekEndToTimeForSaved().time
                toWPmLabel.text = self.getWeekEndToTimeForSaved().1
                updateTimerDates()
                return
            }
            let fromTimeDate = (self.getTimeAndtimeTypefromDate(date: fromTime))
            let toTimeDate = (self.getTimeAndtimeTypefromDate(date: toTime))
            fromWTimeLabel.text = fromTimeDate.time
            fromWPmLabel.text = fromTimeDate.1
            toWTimeLabel.text = toTimeDate.time
            toWPmLabel.text = toTimeDate.1
        }
    }
    
    func getWeekEndFromTimeForSaved() -> (time: String, String) {
        if self.tag == 0 {
            return ("9:00", "PM")
        } else {
            return ("3:00", "PM")
        }
    }
    
    func getWeekEndToTimeForSaved() -> (time: String, String) {
        if self.tag == 0 {
            return ("7:00", "AM")
        } else {
            return ("6:00", "PM")
        }
    }

    private func updateTimerDates() {
        self.cellTimerModel = PauseTimerModel()
        self.cellTimerModel?.isWeekendsEnabled = self.pauseOnWeekEndsEnabled
        cellTimerModel?.cellIndex = self.tag
        cellTimerModel?.fromDate = self.getTimeForSelection(for: fromTimeLabel.text!, arrow: .None, timeType: fromPmLabel.text!).date
        cellTimerModel?.toDate = self.getTimeForSelection(for: toTimeLabel.text!, arrow: .None, timeType: toPMLabel.text!).date
        if !self.weekendStackView.isHidden {
            cellTimerModel?.fromWDate = self.getTimeForSelection(for: fromWTimeLabel.text!, arrow: .None, timeType: fromWPmLabel.text!).date
            cellTimerModel?.toWDate = self.getTimeForSelection(for: toWTimeLabel.text!, arrow: .None, timeType: toWPmLabel.text!).date
        }
        delegate?.updateTimerData(cell: self, model: cellTimerModel!)
    }
    
    func updateWeekendTimerDates() {
        cellTimerModel?.fromWDate = self.getTimeForSelection(for: fromWTimeLabel.text!, arrow: .None, timeType: fromWPmLabel.text!).date
        cellTimerModel?.toWDate = self.getTimeForSelection(for: toWTimeLabel.text!, arrow: .None, timeType: toWPmLabel.text!).date
    }
    
    func configCellForEditSaved(model: PauseScheduleModel) {
        self.profileTimeLabel.text = profileTitle[self.tag].replacingOccurrences(of: "profile", with: self.profileName)
        self.dayTimelineLabel.text = profileTime[self.tag]
        self.imgViewType.isHidden = false
        self.pauseModel = model
        timerView.isHidden = false
        addTimeControl.isHidden = true
        timerSelectedView.isHidden = true
        imgViewType.image = UIImage(named: self.tag == 0 ? "icon_bedtime" : "icon_timing")
        self.updateTimersForSaved(model: model)
    }
    
    func configCellForSaved(model: PauseScheduleModel) {
        self.imgViewType.isHidden = true
        addTimeControl.isHidden = true
        timerView.isHidden = true
        self.pauseModel = model
        imgViewType.image = UIImage(named: self.tag == 0 ? "icon_bedtime" : "icon_timing")

        // un hide UI
        timerSelectedView.isHidden = false
        self.sImageView.image = self.imgViewType.image
        self.sTitleLabel.text = self.lblTitle.text
        self.sWeeknightsLabel.text = (self.tag == 0) ? "Weeknights" : "Weekdays"
        let fromTimeDate = (self.getTimeAndtimeTypefromDate(date: model.timerModel.fromDate ?? Date()))
        let toTimeDate = (self.getTimeAndtimeTypefromDate(date: model.timerModel.toDate ?? Date()))
        if shouldSavePreviousTime{
            if self.previousTimeOnLabel == "" {
                self.sWeekenightsTimeLabel.text = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
                self.previousTimeOnLabel = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)" } else {
                    self.sWeekenightsTimeLabel.text = self.previousTimeOnLabel
                } } else {
                    self.sWeekenightsTimeLabel.text = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
                    self.previousTimeOnLabel = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
        }
        if model.weekEndModel.isTimerSaved {
            self.selectedTimerWeekEndsView.isHidden = false
            let fromTimeDate = (self.getTimeAndtimeTypefromDate(date: model.weekEndModel.fromDate ?? Date()))
            let toTimeDate = (self.getTimeAndtimeTypefromDate(date: model.weekEndModel.toDate ?? Date()))
           // sWeekendsTimeLabel.text = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
            if shouldSavePreviousWeekendTime {
                if self.previousWeekendTimeOnLabel == ""{
                    sWeekendsTimeLabel.text = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
                    self.previousWeekendTimeOnLabel = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"} else {
                    sWeekendsTimeLabel.text = self.previousWeekendTimeOnLabel } } else {
                sWeekendsTimeLabel.text = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
                self.previousWeekendTimeOnLabel = "\(fromTimeDate.time) \(fromTimeDate.1) - \(toTimeDate.time) \(toTimeDate.1)"
            } } else {
            self.selectedTimerWeekEndsView.isHidden = true
        }
    }
        
    func configCellForTimer(title: String, timerModel: PauseTimerModel? = nil) {
        self.imgViewType.isHidden = false
        self.timerSelectedView.isHidden = true
        self.timerErrorView.isHidden = true
        self.weekTimerErrorView.isHidden = true
        self.cellTimerModel = timerModel
        imgViewType.image = UIImage(named: self.tag == 0 ? "icon_bedtime" : "icon_timing")

        // 8:00 PM
        fromTimeLabel.text = timeArray[self.tag == 0 ? 16 : time3]
//        fromTimeLabel.tag = self.tag == 0 ? 16 : time3
        // 6:00 AM
        toTimeLabel.text = timeArray[time6]
        toTimeLabel.tag = time6
        
        // 8:00 PM
        fromWTimeLabel.text = timeArray[self.tag == 0 ? 18 : time3]
//        fromWTimeLabel.tag = self.tag == 0 ? 18 : time3
        // 6:00 AM
        toWTimeLabel.text = timeArray[self.tag == 0 ? time7 : time6]
//        toWTimeLabel.tag = self.tag == 0 ? time7 : time6
        self.errorDescriptionLabel.text = "Start time cannot be same as end time"
        self.profileName = title
        self.profileTimeLabel.text = profileTitle[self.tag].replacingOccurrences(of: "profile", with: self.profileName)
        toPMLabel.text = self.tag == 1 ? "PM" : "AM"
        toWPmLabel.text = self.tag == 1 ? "PM" : "AM"
        self.dayTimelineLabel.text = profileTime[self.tag]
        updateWeekendsEnabled(enabled: pauseOnWeekEndsEnabled)
        self.layoutIfNeeded()
        guard let timerData = timerModel else {
            self.updateTimerDates()
            return }
        self.updateTimerData(for: timerData)
    }
    
    func updateTimerData(for model: PauseTimerModel) {
        if model.displayErrorView {
            timerErrorView.isHidden = false
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ShowErrorView"),object: nil))
        }
        
        if model.overlapErrorView {
            timerErrorView.isHidden = false
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ShowErrorView"),object: nil))
            self.errorDescriptionLabel.text = "\(self.profileName) bedtime is from \(pauseModel?.overlapModel.fromDate) to \(pauseModel?.overlapModel.toDate)"
        }
        
        if model.displayWErrorView {
            self.weekTimerErrorView.isHidden = false
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ShowErrorView"),object: nil))
        }
        self.layoutIfNeeded()
        guard (model.fromDate != nil) && (model.toDate != nil) else {
            self.updateTimerDates()
            return
        }
        
        fromTimeLabel.text = self.getTimeAndtimeTypefromDate(date: model.fromDate!).time
        fromPmLabel.text = self.getTimeAndtimeTypefromDate(date: model.fromDate!).1
        
        toTimeLabel.text = self.getTimeAndtimeTypefromDate(date: model.toDate!).time
        toPMLabel.text = self.getTimeAndtimeTypefromDate(date: model.toDate!).1
        
        if pauseOnWeekEndsEnabled {
            guard model.fromWDate != nil && model.toWDate != nil else { return }
            fromWTimeLabel.text = self.getTimeAndtimeTypefromDate(date: model.fromWDate!).time
            fromWPmLabel.text = self.getTimeAndtimeTypefromDate(date: model.fromWDate!).1
            
            toWTimeLabel.text = self.getTimeAndtimeTypefromDate(date: model.toWDate!).time
            toWPmLabel.text = self.getTimeAndtimeTypefromDate(date: model.toWDate!).1
        }
    }
    
    func updateWeekendsEnabled(enabled: Bool) {
        self.pauseOnWeekEndsEnabled = enabled
        if !enabled {
            pauseWeekendsButton.setImage(UIImage(named: "unCheck"), for: .normal)
            self.weekendStackView.isHidden = true
        } else {
            pauseWeekendsButton.setImage(UIImage(named: "check"), for: .normal)
            self.weekendStackView.isHidden = false
        }
    }
    
    ///Method for handling UI attributes.
    func setUpUIAttributes() {
        lblTitle.font = UIFont(name: "Regular-Bold", size: 18)
        vwBorderView.layer.cornerRadius = 10
        vwBorderView.layer.borderWidth = 1
        vwBorderView.layer.borderColor = lineTextColor.cgColor
    }
    ///Method for handling UI.
    func setUpDataInUI(data: [[String:String]], indexpath: IndexPath) {
        lblTitle.text = data[indexpath.row]["title"]
        imgViewType.image = UIImage(named: data[indexpath.row]["icon"] ?? "icon_bedtime")
        if data.count == indexpath.row + 1 {
            self.layer.cornerRadius = 10
            self.layer.masksToBounds = true
            self.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        }
        }
    
    @objc fileprivate func showTimersView() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "HideShowSaveCancelBottomView"),object: nil))
        guard (delegate != nil) && timerView.isHidden else {
            return
        }
        isTimerOptionsEnabled = timerView.isHidden
        delegate?.didTappedTimer(cell: self, isWeekEnd: false)
        cellTimerModel?.isWeekendsEnabled = isTimerOptionsEnabled
        guard let model = cellTimerModel else { return }
        self.delegate?.updateTimerData(cell: self, model: model)
    }
    
    ///Method for edit page action
    @IBAction func showAddUI(_ sender: Any) {
        self.showTimersView()
    }
    
    @IBAction func pauseOnWeekendsTapped(_ sender: Any) {
        if weekendStackView.isHidden {
            pauseOnWeekEndsEnabled = true
            pauseWeekendsButton.setImage(UIImage(named: "check"), for: .normal)
            self.weekendStackView.isHidden = false
            self.updateWeekendTimerDates()
            delegate?.didTappedTimer(cell: self, isWeekEnd: true)
        } else {
            pauseOnWeekEndsEnabled = false
            pauseWeekendsButton.setImage(UIImage(named: "unCheck"), for: .normal)
            self.weekendStackView.isHidden = true
            delegate?.didTappedTimer(cell: self, isWeekEnd: false)
        }
        pauseModel?.isWeekendsEnabled = pauseOnWeekEndsEnabled
        guard let model = cellTimerModel else { return }
        self.delegate?.updateTimerData(cell: self, model: model)
    }
    
    @IBAction func editTimerTapped(_ sender: Any) {
        self.pauseModel?.isEdit = true
        delegate?.didTappedEdit(cell: self, model: self.pauseModel!)
    }
    
    
    // From 2 ++ && 4 --   // To 12 ++ && 14 --
    //WeekEnd      // From 6 ++ && 8 --   // To 16 ++ && 18 --

    @IBAction func changeTimeTapped(_ sender: UIButton) {
        var timeAndTimeType: ChangedDateTime
        if sender.tag < 10 {
            fromTimeLabel.fadeTransition(0.4)
            if sender.tag < 3 {
                timeAndTimeType = getTimeForSelection(for: fromTimeLabel.text!, arrow: .Up, timeType: fromPmLabel.text!)
            } else {
                timeAndTimeType = getTimeForSelection(for: fromTimeLabel.text!, arrow: .Down, timeType: fromPmLabel.text!)
            }
            fromTimeLabel.text = timeAndTimeType.0
            if fromPmLabel.text != timeAndTimeType.1 {
                fromPmLabel.fadeTransition(0.4)
            }
            fromPmLabel.text = timeAndTimeType.1
            cellTimerModel?.fromDate = timeAndTimeType.date
        } else if sender.tag > 10 {
            toTimeLabel.fadeTransition(0.4)
            if sender.tag < 13 {
                timeAndTimeType = getTimeForSelection(for: toTimeLabel.text!, arrow: .Up, timeType: toPMLabel.text!)
            } else {
                timeAndTimeType = getTimeForSelection(for: toTimeLabel.text!, arrow: .Down, timeType: toPMLabel.text!)
            }
            toTimeLabel.text = timeAndTimeType.0
            if toPMLabel.text != timeAndTimeType.1 {
                toPMLabel.fadeTransition(0.4)
            }
            toPMLabel.text = timeAndTimeType.1
            cellTimerModel?.toDate = timeAndTimeType.date
        }
        if !self.timerErrorView.isHidden {
            self.checkForTimerErrors()
        }
        self.checkForOverlapTimerErrors()
        guard let model = cellTimerModel else {
            updateTimerDates()
            return
        }
        self.delegate?.updateTimerData(cell: self, model: model)
    }
    
    
    @IBAction func changeWeekendTimeTapped(_ sender: UIButton) {
        var timeAndTimeType: ChangedDateTime
        if sender.tag < 10 {
            fromWTimeLabel.fadeTransition(0.4)
            if sender.tag < 7 {
                timeAndTimeType = getTimeForSelection(for: fromWTimeLabel.text!, arrow: .Up, timeType: fromWPmLabel.text!)
            } else {
                timeAndTimeType = getTimeForSelection(for: fromWTimeLabel.text!, arrow: .Down, timeType: fromWPmLabel.text!)
            }
            fromWTimeLabel.text = timeAndTimeType.0
            if fromWPmLabel.text != timeAndTimeType.1 {
                fromWPmLabel.fadeTransition(0.4)
            }
            fromWPmLabel.text = timeAndTimeType.1
            cellTimerModel?.fromWDate = timeAndTimeType.date
        } else if sender.tag > 10 {
            toWTimeLabel.fadeTransition(0.4)
            if sender.tag < 17 {
                timeAndTimeType = getTimeForSelection(for: toWTimeLabel.text!, arrow: .Up, timeType: toWPmLabel.text!)
            } else {
                timeAndTimeType = getTimeForSelection(for: toWTimeLabel.text!, arrow: .Down, timeType: toWPmLabel.text!)
            }
            toWTimeLabel.text = timeAndTimeType.0
            if toWPmLabel.text != timeAndTimeType.1 {
                toWPmLabel.fadeTransition(0.4)
            }
            toWPmLabel.text = timeAndTimeType.1
            cellTimerModel?.toWDate = timeAndTimeType.date
        }
        if !self.weekTimerErrorView.isHidden {
            self.checkForTimerErrors()
        }
        self.checkForOverlapTimerErrors()
        guard let model = cellTimerModel else {
            updateTimerDates()
            return
        }
        self.delegate?.updateTimerData(cell: self, model: model)
    }
    
    @IBAction func deleteScheduleAction(_ sender: Any) {
        self.delegate?.deleteScheduleTimer()
    }
    
}
