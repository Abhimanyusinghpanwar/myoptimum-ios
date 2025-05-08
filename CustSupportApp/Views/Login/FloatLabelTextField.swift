//
//  FloatLabelTextField.swift
//  CustSupportApp
//
//  Created by Namarta on 18/05/22.
//

import UIKit
enum BorderColor {
    case deselcted_color
    case selected_color
    case error_color
    case `default`
}
@IBDesignable class FloatLabelTextField: UITextField {
	let animationDuration = 0.3
    var title = UILabel()
    lazy var errorColor = {
        return UIColor.init(red: 234/255, green: 0/255, blue: 42/255, alpha: 1.0).cgColor
    }
    lazy var deselectedColor = {
        return UIColor.init(red: 0.941, green: 0.941, blue: 0.953, alpha: 1).cgColor
    }
    lazy var selectedColor = {
        return UIColor.init(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0).cgColor
    }
	// MARK:- Properties
	override var accessibilityLabel:String? {
		get {
			if let txt = text , txt.isEmpty {
				return title.text
			} else {
				return text
			}
		}
		set {
			self.accessibilityLabel = newValue
		}
	}
	
//	override var placeholder:String? {
//		didSet {
//			title.text = placeholder
//			title.sizeToFit()
//		}
//	}
	
	override var attributedPlaceholder:NSAttributedString? {
		didSet {
			title.text = attributedPlaceholder?.string
			title.sizeToFit()
		}
	}
	
    var titleFont:UIFont = UIFont(name: "Regular-Medium", size: 12) ?? UIFont.systemFont(ofSize: 10.0) {
		didSet {
			title.font = titleFont
			title.sizeToFit()
		}
	}
	
	@IBInspectable var hintYPadding:CGFloat = 0.0

	@IBInspectable var titleYPadding:CGFloat = 0.0 {
		didSet {
			var r = title.frame
			r.origin.y = titleYPadding
			title.frame = r
		}
	}
	
	@IBInspectable var titleTextColour:UIColor = UIColor.gray {
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
	@IBInspectable var titleActiveTextColour:UIColor! {
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
		
	// MARK:- Init
	required init?(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)
		setup()
        //NSNotification.init(name: NSNotification.Name.u, object: )
	}
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
    
    deinit {
        
    }
    
	
	// MARK:- Overrides
	override func layoutSubviews() {
		super.layoutSubviews()
		setTitlePositionForTextAlignment()
		let isResp = isFirstResponder
		if let txt = text , !txt.isEmpty && isResp {
			title.textColor = titleActiveTextColour
		} else {
			title.textColor = titleTextColour
		}
		// Should we show or hide the title label?
        if self.isFirstResponder {
            showTitle(isResp)
            placeholder = ""
//            if #available(iOS 15.0, *) {
//                superview?.layer.borderColor = UIColor.init(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0).cgColor
//            } else {
//                // Fallback on earlier versions
//            }
        } else if text?.isEmpty == false {
            showTitle(isResp)
            placeholder = ""
            //superview?.layer.borderColor = UIColor(red: 0.941, green: 0.941, blue: 0.953, alpha: 1).cgColor
        } else {
            hideTitle(isResp)
            placeholder = title.text
          //  superview?.layer.borderColor = UIColor(red: 0.941, green: 0.941, blue: 0.953, alpha: 1).cgColor
        }
        
//		if let txt = text , txt.isEmpty {
//			// Hide
//			hideTitle(isResp)
//		} else {
//			// Show
//			showTitle(isResp)
//		}
	}
	
	override func textRect(forBounds bounds:CGRect) -> CGRect {
        let isResp = isFirstResponder
		var r = super.textRect(forBounds: bounds)
        let tfText = self.text ?? ""
        if isResp || (!isResp && !tfText.isEmpty) {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
            r = r.inset(by: UIEdgeInsets.init(top: top, left: 0.0, bottom: 0.0, right: 0.0))
		}
		return r.integral
	}
	
	override func editingRect(forBounds bounds:CGRect) -> CGRect {
        let isResp = isFirstResponder
		var r = super.editingRect(forBounds: bounds)
        if isResp {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
            r = r.inset(by: UIEdgeInsets.init(top: top, left: 0.0, bottom: 0.0, right: 0.0))
			//r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
		}
		return r.integral
	}
	
    func setBorderColor(mode: BorderColor) {
        switch mode {
        case .deselcted_color:
            superview?.layer.borderColor = deselectedColor()
        case .selected_color:
            superview?.layer.borderColor = selectedColor()
        case .error_color:
            superview?.layer.borderColor = errorColor()
        case .default:
            superview?.layer.borderColor = deselectedColor()
        }
    }
    
    func getBorderColor() -> BorderColor {
        if superview?.layer.borderColor == selectedColor() {
            return .selected_color
        }
        else if superview?.layer.borderColor == deselectedColor() {
            return .deselcted_color
        }
        else if superview?.layer.borderColor == errorColor() {
            return .error_color
        }
        return .default
    }
    
//	override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
//		var r = super.clearButtonRect(forBounds: bounds)
//		if let txt = text , !txt.isEmpty {
//			var top = ceil(title.font.lineHeight + hintYPadding)
//			top = min(top, maxTopInset())
//			r = CGRect(x:r.origin.x, y:r.origin.y + (top * 0.5), width:r.size.width, height:r.size.height)
//		}
//		return r.integral
//	}
	
	// MARK:- Public Methods
	
	// MARK:- Private Methods
	fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
		titleActiveTextColour = UIColor.init(red: 39/255, green: 96/255, blue: 240/255, alpha: 1.0)

		// Set up title label
        title.font = titleFont
        title.awakeFromNib()
		title.alpha = 0.0
		title.textColor = titleTextColour
		if let str = placeholder , !str.isEmpty {
			title.text = str
			title.sizeToFit()
		}
		self.addSubview(title)
	}

	fileprivate func maxTopInset()->CGFloat {
		if let fnt = font {
			return max(0, floor(bounds.size.height - fnt.lineHeight - 4.0))
		}
		return 0
	}
	
	fileprivate func setTitlePositionForTextAlignment() {
		let r = textRect(forBounds: bounds)
		var x = r.origin.x
		if textAlignment == NSTextAlignment.center {
			x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
		} else if textAlignment == NSTextAlignment.right {
			x = r.origin.x + r.size.width - title.frame.size.width
		}
		title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width, height:title.frame.size.height)
	}
	
	fileprivate func showTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
            // Animation
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding
            self.title.frame = r
        }, completion:nil)
	}
	
	fileprivate func hideTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
		UIView.animate(withDuration: dur, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
			// Animation
			self.title.alpha = 0.0
			var r = self.title.frame
			r.origin.y = self.title.font.lineHeight + self.hintYPadding
			self.title.frame = r
			}, completion:nil)
	}
}
