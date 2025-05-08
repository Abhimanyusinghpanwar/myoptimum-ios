//
//  LoadViewExampleViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 10/17/16.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit
import FSCalendar

protocol UpdatePaymentDate {
    func updatePaymentDate(selectedDate: String)
}

class PaymentCalendarVC: UIViewController {
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var lblLateFee: UILabel!
    var paymentDateAfterEdit: String?
    var delegate:UpdatePaymentDate?
    var currentSelectedDueDate: Date?
    var selectedDueDate:String?
    var dueDateAfterEdit: Date?
    var payMethod: PayMethod?
    weak var makePaymentViewController: MakePaymentViewController?
    @IBOutlet weak var lblLateFeeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.hasNotch{
            lblLateFeeBottomConstraint.constant = 24
            if currentScreenWidth == 375 {
                calendarHeightConstraint.constant = 480
            } else {
                calendarHeightConstraint.constant = 520
            }
        } else {
            lblLateFeeBottomConstraint.constant = 15
            calendarHeightConstraint.constant = 410
            calendar.register(PaymentCalendarCell.self, forCellReuseIdentifier: "PaymentCalendarCell")
        }
        
        calendar.adjustsBoundingRectWhenChangingMonths = true
        calendar.scrollEnabled = false
        if let dueDate = currentSelectedDueDate {
            let dueDateString = dueDate.getDateStringFromDate()
            lblDueDate.text = "Due date is \(dueDateString)"
        } else {
            lblDueDate.isHidden = true
        }
        //Handle hide/show of previous/next month to the left/right of Calendar Header
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
        //Handle calendar date appearence
        self.calendar.appearance.titleFont = UIFont(name: "Regular-Regular", size: 15)
        
        //check if the payment due date is not today and also the user has not edited the existing due date
        if !self.checkIfDueDateIsToday() && !self.checkIfDueDateAfterEditExists().0 {
            if !UIDevice.current.hasNotch {
                self.calendar.select(Date(), scrollToDate: false)
            } else {
                calendar.appearance.todayColor = energyBlueRGB
                calendar.appearance.titleTodayColor = .white
                self.calendar.select(Date(), scrollToDate: false)
            }
        } else {
            //CMAIOS-2032
            /**
              show blue filled circle along with dueDate label if due date is today
             **/
            if !self.checkIfDueDateAfterEditExists().0 {
                if !UIDevice.current.hasNotch {
                    self.calendar.select(Date(), scrollToDate: false)
                } else {
                    calendar.appearance.todayColor = energyBlueRGB
                    calendar.appearance.titleTodayColor = .white
                }
            } else {
                calendar.appearance.todayColor = .white
                calendar.appearance.titleTodayColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
            }
        }
        calendar.placeholderType = .none
      
        //Handle calendar headerView Appearance
        calendar.appearance.headerTitleFont = UIFont(name: "Regular-Bold", size: 18)
        calendar.appearance.headerTitleColor = .black
        
        //Handle calendar WeekDayView Appearance
        calendar.appearance.weekdayFont = UIFont(name: "Regular-Regular", size: 15)
        calendar.appearance.weekdayTextColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        
        //Handle calendar WeekDayView Height
        calendar.weekdayHeight = 40.0
        
        self.btnPrevious.isHidden = true
        self.title = ""
        self.lblHeader.setDefaultLineHeight()
        self.lblDueDate.setDefaultLineHeight()
        self.lblLateFee.setDefaultLineHeight()
        
        //show weekDay initials as "Su, Mo, Tu, We.."
        self.showWeekDayInitials()
        
        //check if the user has edited the existing due date then select that date in the calendar
        if self.checkIfDueDateAfterEditExists().0 {
            self.calendar.allowsMultipleSelection = false
            self.calendar.select(self.checkIfDueDateAfterEditExists().1, scrollToDate: false)
            self.showHideLateFeeText(selectedDate: self.checkIfDueDateAfterEditExists().1)
        }
        self.checkDueDateExceededCurrentDate()
        trackEvents()
        checkIfEditedDateAvailable()
    }
    
    // if user edited date then directly go to that Date
    func checkIfEditedDateAvailable() {
        if let editedDate = self.paymentDateAfterEdit {
            let formattedDate = editedDate.components(separatedBy: "T")
            self.calendar.setCurrentPage(CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDate[0]), animated: false)
            showHideNextAndPreviousButtons()
        }
    }
    
    // Enable Next and Previous button for edited date.
    func showHideNextAndPreviousButtons() {
        showHidePreviousButton(currentDate: calendar.currentPage)
        showHideNextButton(currentDate: calendar.currentPage)
    }

    //check if there is any payment due date
    func checkIfDueDateExists() -> Bool{
        return currentSelectedDueDate != nil ? true : false
    }
    
    //method for setting late fee text
    func setLateFeeText(dueDate: Date){
        if let dueDate = currentSelectedDueDate {
            let lateFeeString = dueDate.getLateFeeDateStringFromDate()
            self.lblLateFee.text = "You may be charged late fees if your payment is not\nreceived by \(lateFeeString)"
        }
    }
    
    // method for checking if the payment due date is today
    func checkIfDueDateIsToday() -> Bool {
        let currentDate = Date()
        if let duedate =  self.currentSelectedDueDate,  duedate.isSameYearMonthAndDate(date2: currentDate) {
            return true
        }
        return false
    }

    //set calendar weekDay initials as "Su, Mo, Tu, We.."
    func showWeekDayInitials(){
        let weekdayEnumerator = calendar.calendarWeekdayView.weekdayLabels
        weekdayEnumerator.forEach { (cell) in
        let weekDayCell = cell
        let weekDayText = weekDayCell.text ?? " " //"Sun"
            weekDayCell.text = String(weekDayText.dropLast()) // "Su", "Mo"
        }
    }
    
    // MARK: - Cancel and Continue button action
    @IBAction func continueBtnAction(_ sender: Any) {
        if (payMethod?.creditCardPayMethod) != nil {
            guard let expiryDateString = payMethod?.creditCardPayMethod?.expiryDate, !expiryDateString.isEmpty else {
                return
            }
            //CMAIOS-2439 Added fix for continue button freeze if user has not selected any date from the calendar
            /* Scenario
             You have default OTP failue and tap on make a payment and then select any date from the calendar ->Go back to Make a payment -> Again edit date ->show calendar -> do not select any date
             */
            if self.paymentDateAfterEdit != nil && self.selectedDueDate == nil {
                self.selectedDueDate = self.paymentDateAfterEdit
            }
            // CMAIOS-2140
            guard let selectedPaymentDate = self.selectedDueDate else {
                self.updatePaymentDateAndDismiss() //CMAIOS-2496 Added fix for continue button freeze if user has not selected any date from the calendar
                return
            }
            let formattedDueDate = expiryDateString.components(separatedBy: "T")
            let newCardDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: formattedDueDate[0])
            let calenderSelectedDate = CommonUtility.getOnlyMonthYearDate(paymentDate: selectedPaymentDate)
            if calenderSelectedDate.checkIfPaymentDateIsSelectedAfterCardExpirationDate(cardExpirationDate: newCardDate) {
                if let index = selectedPaymentDate.firstIndex(of: "T") {
                    handleCardExpiredNotification(String(selectedPaymentDate.prefix(upTo: index)))
                }
            } else {
                updatePaymentDateAndDismiss()
            }
            
            /*
            let cardExpireDate = CommonUtility.dateFromTimestamp(dateString: expiryDateString)
            guard var selectedPaymentDate = self.selectedDueDate else {
                return
            }
            if let index = selectedPaymentDate.firstIndex(of: "T") {
                selectedPaymentDate = String(selectedPaymentDate.prefix(upTo: index))
            }
            let calenderSelectedDate = CommonUtility.dateFromTimestampWOTimeZone(dateString: String(selectedPaymentDate ))
            if calenderSelectedDate.checkIfPaymentDateIsSelectedAfterCardExpirationDate(cardExpirationDate: cardExpireDate) {
                handleCardExpiredNotification(String(selectedPaymentDate ))
            } else {
                updatePaymentDateAndDismiss()
            }
            */
        } else {
            updatePaymentDateAndDismiss()
        }
    }
    
    // Show card expired Screen
    private func handleCardExpiredNotification(_ selectedDueDate: String) {
        guard let presentingViewController = self.presentingViewController else { return }
        // Dismiss the current view controller
        let cardExpiredVC = UIStoryboard(name: "BillPay", bundle: nil).instantiateViewController(identifier: "CardExpiredNotifyVC") as CardExpiredNotifyVC
        cardExpiredVC.payMethod = self.payMethod
        cardExpiredVC.paymentDate = selectedDueDate
        cardExpiredVC.makePaymentViewController = self.makePaymentViewController
        // CMAIOS-2099
        self.navigationController?.pushViewController(cardExpiredVC, animated: true)
    }
    
    // Update payment date and dismiss view
    private func updatePaymentDateAndDismiss() {
        if let selectedDate = self.selectedDueDate {
            self.delegate?.updatePaymentDate(selectedDate: selectedDate)
        }
        // CMAIOS-2099
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        // CMAIOS-2099
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Next and Previous button action
    @IBAction func nextBtnAction(_ sender: Any) {
        self.btnPrevious.isHidden = false
        let nextDate = getNextMonth(date: calendar.currentPage)
        calendar.setCurrentPage(nextDate, animated: true)
        showHideNextButton(currentDate: nextDate)
        // Month and Year visible when moving forward
        calendar.calendarHeaderView.reloadData()
    }
    
    @IBAction func previousBtnAction(_ sender: Any) {
        btnNext.isHidden = false
        calendar.setCurrentPage(getPreviousMonth(date: calendar.currentPage), animated: true)
        showHidePreviousButton(currentDate: calendar.currentPage)
        // Month and Year visible when moving back
        calendar.calendarHeaderView.reloadData()
    }
    
    // method for getting next month on tap of next button
    func getNextMonth(date:Date)->Date {
        let nextDate = Calendar.current.date(byAdding: .month, value: 1, to:date)!
        if checkIfNextMonthIsApplicable(nextDate: nextDate) {
            return nextDate
        }
        return calendar.currentPage
    }
    
    // method for getting previous month on tap of previous button
    func getPreviousMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: -1, to:date)!
    }
    
    //Check if the next month of calendar is allowed to display
    func checkIfNextMonthIsApplicable(nextDate : Date)->Bool {
        //get six months date from currentDate
        let sixMonthsDate = Date().getDateAfterSixMonthsFromCurrentDate()
        //check if the sixMonthDate is smaller or same to the scrolled month
        if nextDate.compare(sixMonthsDate) == .orderedAscending ||  nextDate.isSameYearMonthAndDate(date2: sixMonthsDate){
            return true
        }
        return false
    }
    
    // method for show/hide next button
    func showHideNextButton(currentDate: Date){
        let upcomingDate = getNextMonth(date: currentDate)
        if upcomingDate.compare(calendar.currentPage) == .orderedSame {
            //Hide the next btn if the user has scrolled upto the last month(sixth month after the current month)
            btnNext.isHidden = true
        } else {
            btnNext.isHidden = false
        }
    }
    
    // method for show/hide previous button
    func showHidePreviousButton(currentDate: Date){
        let currentPageDate = calendar.currentPage
        if Date().isSameYearAndMonth(date2: currentPageDate) {
            //Hide the previous btn if the user is on the today's date.
            btnPrevious.isHidden = true
        } else {
            btnPrevious.isHidden = false
        }
    }
    
    func showHideLateFeeText(selectedDate: Date) {
        let todayDate = Date().getModifiedCurrentDate()
        if let currentDueDate = self.currentSelectedDueDate,  currentDueDate.checkIfDateIsSelectedAfterDueDate(selectedDueDate: selectedDate, checkIsSameRequired: false) {
            self.lblLateFee.isHidden = (todayDate > currentDueDate) ? true : false
            self.setLateFeeText(dueDate: currentDueDate)
        } else {
            self.lblLateFee.isHidden = true
        }
    }
    
    //Add due date text underneath the payment date
    func addDueDateSubtitle(cell: FSCalendarCell,  date: Date){
        if self.checkIfDueDateExists() && date.isSameYearMonthAndDate(date2: self.currentSelectedDueDate ?? Date()) {
            let label = UILabel()
            if  UIDevice.current.hasNotch {
                if currentScreenWidth <= 414 {
                    label.font = UIFont(name: "Regular-Regular", size: 13)
                } else {
                    label.font = UIFont(name: "Regular-Regular", size: 14.5)
                }
                label.frame = CGRect(x: 0, y: cell.frame.height-13, width: cell.bounds.width, height: 13)
            } else {
                label.font = UIFont(name: "Regular-Regular", size: 13)
                label.frame = CGRect(x: 0, y: cell.frame.height-13, width:  cell.bounds.width, height: 10)
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.13
            // Line height: 18 pt
            label.textAlignment = .center
            label.attributedText = NSMutableAttributedString(string: "Due date", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            //If due date is after the current date then show it in black color else grey color
            if Date().checkIfDateIsSelectedAfterDueDate(selectedDueDate: self.currentSelectedDueDate ?? Date()){
                label.textColor = UIColor.black
            } else {
                label.textColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
            }
            label.tag = 999
            cell.isUserInteractionEnabled = true
            cell.addSubview(label)
        }
    }
    
    //set date color for the displayed month
    func setDateColorBasedUponPermissibleDate(cell: FSCalendarCell, date:Date) {
        //check if the next month is one of permissible six months
        if self.checkIfNextMonthIsApplicable(nextDate: date)  && date.compare(Date()) == .orderedDescending{
            //check if the user has edited the existing due date
            if checkIfDueDateAfterEditMatches(date: date) || checkIfSelectedTemporaryDateMatches(date: date) {
                //then show white color for the selected date
                cell.titleLabel.textColor = .white
                cell.preferredTitleSelectionColor = .white
            } else {
                //else show soft black color for the other dates
                cell.titleLabel.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
                cell.preferredTitleDefaultColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
            }
            //allow user to select the permissible date
            cell.isUserInteractionEnabled = true
        } else {
            if !(date.isSameYearMonthAndDate(date2: Date())) {
                //show medium gray color for the non permissible dates
                cell.titleLabel.textColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
                cell.preferredTitleDefaultColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
                //disable user interaction for the dates other than permissible dates
                cell.isUserInteractionEnabled = false
            }
        }
    }
    
    //method for checking whether user has edited the existing payment date
    func checkIfDueDateAfterEditExists() -> (Bool, Date) {
        if let editedDueDate = self.dueDateAfterEdit {
            return (true, editedDueDate)
        }
        return (false, Date())
    }
    
    //method for getting which date matches with edited date
    func checkIfDueDateAfterEditMatches(date: Date)->(Bool) {
        //Need to show edited date in the calendar upon launching calendar from MPS
        let (dueDateAfterEditExists, dueDateAfterEdit) =  self.checkIfDueDateAfterEditExists()
        if dueDateAfterEditExists, dueDateAfterEdit.isSameYearMonthAndDate(date2: date), self.calendar.selectedDates.contains(dueDateAfterEdit) {
            return true
        }
        return false
    }
    
    func checkIfSelectedTemporaryDateMatches(date:Date)->Bool{
        //Need to check if the user selected date without pressing continue button exists and matches with the calendar cell date
        if let selectedDate = self.calendar.selectedDates.first, selectedDate.isSameYearMonthAndDate(date2: date) {
            return true
        }
        return false
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        // Configure selection layer
        if position == .current {
            if calendar.selectedDates.contains(date){
                cell.shapeLayer.fillColor = energyBlueRGB.cgColor
                cell.shapeLayer.strokeColor = UIColor.clear.cgColor
                cell.isSelected = true
            } else {
                if date.isSameYearMonthAndDate(date2: Date()) {
                    cell.titleLabel.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
                    cell.preferredTitleDefaultColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
                }
                cell.isSelected = false
            }
            
            guard let selectedDate = currentSelectedDueDate else {
                return
            }
            
            switch (checkIfDueDateExists(), !calendar.selectedDates.contains(selectedDate), Date().checkIfDateIsSelectedAfterDueDate(selectedDueDate: selectedDate), date.isSameYearMonthAndDate(date2: selectedDate)) {
            case (true, true, true, true):
                cell.shapeLayer.strokeColor = energyBlueRGB.cgColor
                cell.shapeLayer.fillColor = UIColor.clear.cgColor
                cell.isSelected = true
            case (true, true, false, true):
                cell.isSelected = true
                cell.shapeLayer.strokeColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
                cell.shapeLayer.fillColor = UIColor.clear.cgColor
                cell.isSelected = true
            case (true, false, true, true):
                cell.shapeLayer.strokeColor = UIColor.clear.cgColor
                cell.shapeLayer.fillColor = energyBlueRGB.cgColor
                cell.isSelected = true
            default:
                break
            }
        }
    }
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func trackEvents() {
        let screenTag = checkIfDueDateExists() ? PaymentScreens.MYBILL_MAKEAPAYMENT_CHOOSE_PAYMENT_DATE.rawValue : PaymentScreens.MYBILL_MAKEAPAYMENT_CHOOSE_PAYMENT_DATE_UNKNOWN_DUE_DATE.rawValue
        CMAAnalyticsManager.sharedInstance.trackAction(eventParam:[EVENT_SCREEN_NAME : screenTag, EVENT_SCREEN_CLASS: self.classNameFromInstance,CUSTOM_PARAM_FIXED: Fixed.Billing.rawValue, CUSTOM_PARAM_CSR_TSR:CSR_TSR.CSR.rawValue,  CUSTOM_PARAM_INTENT: Intent.Billing.rawValue ])
    }
    
    private func checkDueDateExceededCurrentDate() { // CMAIOS-1985
        if self.dueDateAfterEdit != nil {
            self.showHideLateFeeText(selectedDate: self.dueDateAfterEdit ?? Date())
        } else {
            if let dateValue = self.currentSelectedDueDate {
                self.showHideLateFeeText(selectedDate: Date())
            }
        }
    }
}

// MARK: - FSCalendarDelegate Appearance
extension PaymentCalendarVC : FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        return 1.0
    }
    
    // For border color
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        if (self.checkIfDueDateExists() && date.isSameYearMonthAndDate(date2: self.currentSelectedDueDate ?? Date())) {
             if Date().checkIfDateIsSelectedAfterDueDate(selectedDueDate: self.currentSelectedDueDate ?? Date()) {
                return energyBlueRGB
            } else {
                return UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
            }
        }
        return appearance.borderDefaultColor
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        if checkIfNextMonthIsApplicable(nextDate: date) {
            return energyBlueRGB
        } else{
            return .clear
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        if checkIfNextMonthIsApplicable(nextDate: date) {
            return .white
        } else{
            return UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1)
        }
    }
}

// MARK: - FSCalendar DataSource and Delegate
extension PaymentCalendarVC : FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        //Dequeue custom calendar cell for devices without notch
        if !UIDevice.current.hasNotch {
            let cell = calendar.dequeueReusableCell(withIdentifier: "PaymentCalendarCell", for: date, at: position)
            return cell
        }
        //use default FSCalendar cell for devices with notch
        return calendar.dequeueReusableCell(withIdentifier: FSCalendarDefaultCellReuseIdentifier, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        for (_, view) in cell.subviews.enumerated() {
            if(view.tag == 999){
                view.removeFromSuperview()
            }
        }
        
        //set font for respective dates
        cell.titleLabel.font = UIFont(name: "Regular-Regular", size: 15.0)
        
        if !UIDevice.current.hasNotch {
            self.configure(cell: cell, for: date, at: monthPosition)
        }
        //set date color as per permissible date i.e. date should be less than or equat to sixMonthsDate
        self.setDateColorBasedUponPermissibleDate(cell: cell, date: date)
        //Add due date text underneath the payment date
        self.addDueDateSubtitle(cell: cell, date: date)
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if checkIfNextMonthIsApplicable(nextDate: date){
            showHideLateFeeText(selectedDate: date)
            let dateString = date.getDateStringForDueDate().components(separatedBy: "+")
            let requiredFormattedDateString = dateString[0] + "Z"
            self.selectedDueDate = requiredFormattedDateString
           
            if !UIDevice.current.hasNotch {
                //Handle UI for smaller screen(devices without notch)
                self.configureVisibleCells()
            } else {
                self.calendar.appearance.todayColor = .white
                self.calendar.appearance.titleTodayColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
                //show weekDay initials as "Su, Mo, Tu, We.."
                self.showWeekDayInitials()
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
    
    //Set Minimum Date
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}
