//
//  InsertButton.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 25/09/23.
//

import Foundation

public let buttonOrangeColor = UIColor(red: 246/255.0, green: 102/255.0, blue: 8/255.0, alpha: 1.0)
public let buttonWhiteColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
public let buttonBorderGrayColor = UIColor(red: 152/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1.0)
public let textSoftBlackColor = UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)

class InsertButton: RoundedButton {
    
    var indexpath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setupStyle(withBorder: Bool = false) {
        switch withBorder {
        case true: // gray border button
            self.borderColor = buttonBorderGrayColor
            self.borderWidth = 2.0
            self.cornerRadius = 10.0
            self.backgroundColor = buttonWhiteColor
            self.titleLabel?.font = UIFont(name: "Regular-SemiBold", size: 16)
            self.setTitleColor(textSoftBlackColor, for: .normal)
        case false: // full orange button
            self.borderWidth = 0.0
            self.cornerRadius = 10.0
            self.backgroundColor = buttonOrangeColor
            self.titleLabel?.font = UIFont(name: "Regular-Bold", size: 16)
            self.setTitleColor(buttonWhiteColor, for: .normal)
        }
    }
    
    func setCorderRadiues() {
        self.cornerRadius = self.frame.height / 2.0
    }
}
