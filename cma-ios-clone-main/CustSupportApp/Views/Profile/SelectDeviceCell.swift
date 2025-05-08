//
//  SelectDeviceCell.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/21/22.
//

import UIKit

extension UICollectionViewCell {
    static var identifier: String {
        String(describing: self)
    }
}

class SelectDeviceCell: UICollectionViewCell {
    @IBOutlet var leftImage: UIImageView!
    @IBOutlet var rightImage: UIImageView!
    @IBOutlet var title: UILabel!
    
    /*override var isSelected: Bool {
        didSet {
            rightImage.isHidden = !isSelected
            if isSelected {
                layer.borderColor = UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1).cgColor
            } else {
                layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
            }
        }
    }*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        layer.cornerRadius = 10
        rightImage.frame = CGRect(origin: rightImage.frame.origin, size: CGSize(width: 22.0, height: 22.0))
    }
    
    func showSelectedUI() {
        layer.borderWidth = 2
        self.layer.borderColor = energyBlueRGB.cgColor//UIColor(red: 0.153, green: 0.376, blue: 0.941, alpha: 1).cgColor
        self.layer.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1).cgColor
        self.rightImage.isHidden = false
    }
    func showDeSelectedUI() {
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        self.rightImage.isHidden = true
    }
}
