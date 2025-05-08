//
//  AvatarCell.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/11/22.
//

import UIKit
import Lottie

enum ScrollDirection {
    case left(offset: CGFloat)
    case right(offset: CGFloat)
    case none
    
    init(offset: CGFloat) {
        self = .none
        if offset < 0 {
            self = .left(offset: offset)
        } else if offset > 0 {
            self = .right(offset: offset)
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .none:
            return 0
        case .left:
            return 80
        case .right:
            return -80
        }
    }
}

class AvatarCell: UICollectionViewCell {
    
    enum Position {
        case left, center, right
        
        init(currentIndex: Int, centerIndex: Int) {
            self = .center
            if currentIndex > centerIndex {
                self = .right
            } else if currentIndex < centerIndex {
                self = .left
            }
        }
        
        var x: CGFloat {
            switch self {
            case .left: return 30
            case .center: return 0
            case .right: return -30
            }
        }
    }
    
    @IBOutlet var animationViewHeight: NSLayoutConstraint!
    @IBOutlet var selection: UIImageView!
    @IBOutlet var grayBackground: UIView!
    @IBOutlet var blueBackground: UIView!
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var selectionCenterX: NSLayoutConstraint!
    @IBOutlet var selectionCenterY: NSLayoutConstraint!
    
    let maxHeight: CGFloat = 220
    let minHeight: CGFloat = 120
    
    var heightPercentage: CGFloat {
        (maxHeight - animationViewHeight.constant) / 100
    }
    var position: Position = .left
    var isCentered: Bool {
        position == .center
    }
    
    func adjustSubviews(to position: Position, scrollDirection: ScrollDirection) {
        self.position = position
        animationViewHeight.constant = calculateAvatarHeight(position: position, scrollDirection: scrollDirection)
        animationView.layer.cornerRadius = animationViewHeight.constant / 2
        selection.alpha = 1 - heightPercentage
        blueBackground.alpha = 1 - heightPercentage
        blueBackground.layer.cornerRadius = (animationViewHeight.constant + 6) / 2
        grayBackground.layer.cornerRadius = (animationViewHeight.constant + 6) / 2
        selectionCenterX.constant = ((minHeight - 34) / 2) + 35 * (1 - heightPercentage)
        selectionCenterY.constant = ((minHeight - 34) / 2) + 35 * (1 - heightPercentage)
        updatePosition(scrollDirection: scrollDirection)
        animationView.currentFrame = (1 - heightPercentage) * 36
    }
    
    func updatePosition(scrollDirection: ScrollDirection) {
        let x: CGFloat
        switch scrollDirection {
        case .left where position == .left:
            x = heightPercentage * position.x
        case .left where position == .center:
            x = heightPercentage * position.x
        case .right where position == .right:
            x = heightPercentage * position.x
        default:
            x = position.x
        }
        selection.transform3D = CATransform3DMakeTranslation(x, 0, 0)
        animationView.transform3D = CATransform3DMakeTranslation(x, 0, 0)
        blueBackground.transform3D = CATransform3DMakeTranslation(x, 0, 0)
        grayBackground.transform3D = CATransform3DMakeTranslation(x, 0, 0)
    }
    
    private func calculateAvatarHeight(position: Position, scrollDirection: ScrollDirection) -> CGFloat {
        var newHeight = animationViewHeight.constant
        switch scrollDirection {
        case .left(let offset) where position == .center:
            newHeight = min(maxHeight, newHeight + abs(offset))
        case .left(let offset):
            newHeight = max(minHeight, newHeight - abs(offset))
            return newHeight
        case .right(let offset) where position == .center:
            newHeight = min(maxHeight, newHeight + abs(offset))
        case .right(let offset):
            newHeight = max(minHeight, newHeight - abs(offset))
            return newHeight
        default: return position == .center ? maxHeight : minHeight
        }
        return newHeight
    }
}

