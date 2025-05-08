//
//  CustomeCollectionView.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 15/12/22.
//

import UIKit

class CustomeCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {

    super.layoutSubviews()
      
    if bounds.size != intrinsicContentSize {

    self.invalidateIntrinsicContentSize()
        
    }
}
    override var intrinsicContentSize: CGSize {

    return collectionViewLayout.collectionViewContentSize
}

    


}
