//
//  PixelPerfectUIHelper.swift
//  CustSupportApp
//
//  Created by Namarta on 27/06/22.
//

import Foundation

let xibDesignWidth:CGFloat = 375.0
let xibDesignHeight:CGFloat = 667.0

class TouchToResign: UIView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}

class CornerRoundButton: UIButton {
    @IBInspectable var isRoundEdges:Bool = false { didSet {
            if isRoundEdges == true { self.layer.cornerRadius = self.frame.size.height/2 }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if  isRoundEdges == true {
            self.layer.cornerRadius = self.frame.size.height/2
        }
    }
}
