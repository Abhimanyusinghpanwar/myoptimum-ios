//
//  AutomaticallyPauseInternetsTableViewCell+Date.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 13/12/22.
//

import Foundation

extension AutomaticallyPauseInternetsTableViewCell {
    
    func getTimeAndtimeTypefromDate(date: Date) -> (time: String, String) {
        var changedTimeString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        changedTimeString = formatter.string(from: date)
        return (time: changedTimeString.components(separatedBy: " ").first ?? "", changedTimeString.components(separatedBy: " ").last ?? "")
    }

    func getTimeAndtimeTypefromDateForValidation(date: Date) -> (time: String, String) {
        var changedTimeString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        changedTimeString = formatter.string(from: date)
        return (time: changedTimeString , changedTimeString.components(separatedBy: " ").last ?? "")
    }

    func getTimeForSelection(for time: String, arrow: ArrowSelection, timeType: String = "PM") -> ChangedDateTime {
        let temp = "\(time) \(timeType)"
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let dateString = formatter1.string(from: today)
        let combinedDateString = "\(dateString) \(temp)"
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "MM/dd/yy h:mm a"
        
        // Convert String to Date
        let combinedDate = dateFormatter.date(from: combinedDateString)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Date()
        var changedTimeString = ""
        var changedDate:Date!
        
        if arrow == .None {
            changedTimeString = formatter.string(from: combinedDate ?? date)
            changedDate = combinedDate
        } else if arrow == .Up {
            let addingMinutes = Calendar.current.date(byAdding: .minute, value: 30, to: combinedDate ?? date)!
            changedTimeString = formatter.string(from: addingMinutes)
            changedDate = addingMinutes
//            Logger.info(formatter.string(from: addingMinutes))
        } else {
            let subtractingMinutes = Calendar.current.date(byAdding: .minute, value: -30, to: combinedDate ?? date)!
            changedTimeString = formatter.string(from: subtractingMinutes)
            changedDate = subtractingMinutes
//            Logger.info(formatter.string(from: subtractingMinutes))
        }
        return (time: changedTimeString.components(separatedBy: " ").first ?? "", changedTimeString.components(separatedBy: " ").last ?? "", date: changedDate)
    }
    
    func checkForOverlapTimerErrors() {
        guard let model = cellTimerModel else { return }
        if let fromDate = model.fromDate, let toDate = model.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == pauseModel?.overlapModel.fromDate && self.getTimeAndtimeTypefromDateForValidation(date: toDate).time == pauseModel?.overlapModel.toDate {
            cellTimerModel?.overlapErrorView = true
        } else {
            cellTimerModel?.overlapErrorView = false
            guard let model = cellTimerModel else { return }
            if !self.timerErrorView.isHidden {
                self.delegate?.removeTimerError(cell: self, model: model)
            }
        }
    }
    
    func checkForTimerErrors() {
        guard let model = cellTimerModel else { return }
//        let oldModel = model
        if let fromDate = model.fromDate, let toDate = model.toDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            cellTimerModel?.displayErrorView = true
        } else {
            cellTimerModel?.displayErrorView = false
            guard let model = cellTimerModel else { return }
            if !self.timerErrorView.isHidden {
                self.delegate?.removeTimerError(cell: self, model: model)
            }
//            if oldModel.displayErrorView {
//                self.delegate?.removeTimerError(cell: self, model: model)
//            }
        }
        
        if let fromDate = model.fromWDate, let toDate = model.toWDate, self.getTimeAndtimeTypefromDateForValidation(date: fromDate).time == self.getTimeAndtimeTypefromDateForValidation(date: toDate).time {
            cellTimerModel?.displayWErrorView = true
        } else {
            cellTimerModel?.displayWErrorView = false
            guard let model = cellTimerModel else { return }
            if !self.weekTimerErrorView.isHidden {
                self.delegate?.removeTimerError(cell: self, model: model)
            }
//            if oldModel.displayWErrorView {
//                self.delegate?.removeTimerError(cell: self, model: model)
//            }
        }
    }

}
