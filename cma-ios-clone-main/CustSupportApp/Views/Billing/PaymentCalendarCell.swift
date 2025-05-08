//
//  PaymentCalendarCell.swift
//  CustSupportApp
//
//  Created by vishali Test on 10/01/24.
//

import UIKit
import FSCalendar

class PaymentCalendarCell: FSCalendarCell {
    
    weak var selectionLayer: CAShapeLayer!
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let selectionLayer = CAShapeLayer()
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        self.selectionLayer.isHidden = true
        self.shapeLayer.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionLayer.frame = self.contentView.bounds
        if self.isSelected {
            selectionLayer.fillColor = self.shapeLayer.fillColor
            selectionLayer.strokeColor = self.shapeLayer.strokeColor
            self.selectionLayer.isHidden = false
            //for calendar height 370
            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - 15, y: self.contentView.frame.height / 2 - 21 , width: 30, height: 30)).cgPath
        } else {
            self.selectionLayer.isHidden = true
        }
    }
}
