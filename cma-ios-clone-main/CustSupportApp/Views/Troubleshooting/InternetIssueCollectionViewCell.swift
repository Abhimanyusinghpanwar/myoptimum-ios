//
//  InternetIssueCollectionViewCell.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 06/12/22.
//

import UIKit

class InternetIssueCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageText: UILabel!
    @IBOutlet weak var issueImage: UIImageView!
    @IBOutlet weak var backgroundCollectionView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       /* self.backgroundCollectionView.layer.borderColor = UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1).cgColor
        self.backgroundCollectionView.layer.borderWidth = 0.25*/
       
        self.backgroundCollectionView.layer.cornerRadius = 10
        self.backgroundCollectionView.layer.shadowColor = UIColor.black.cgColor
        self.backgroundCollectionView.layer.shadowOpacity = 0.15
        self.backgroundCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.backgroundCollectionView.layer.shadowRadius = 10
       }
    }
