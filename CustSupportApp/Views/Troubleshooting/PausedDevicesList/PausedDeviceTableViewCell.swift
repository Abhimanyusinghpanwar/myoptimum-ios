//
//  PausedDeviceTableViewCell.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 22/01/23.
//

import UIKit

protocol pausedDeviceDelegate: AnyObject {
    func reloadUnpauseRow(_ indexPath: NSIndexPath)
}

class PausedDeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceDetailView: UIView!
    @IBOutlet weak var unpauseView: UIControl!
    @IBOutlet weak var lineSeparationView: UIImageView!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var deviceUnpausedLabel: UILabel!
    @IBOutlet weak var checkIconImageView: UIImageView!
    var indexPath : NSIndexPath!
    var pausedDelegate: pausedDeviceDelegate!

    @IBAction func selectUnpause(_ sender: UIControl) {
        self.lineSeparationView.isHidden = true
        self.deviceDetailView.isHidden = true
        self.deviceImageView.isHidden = true
        self.unpauseView.isHidden = true
        self.checkView.isHidden = false
        let newFrame = CGRectMake(0, 0, 0, 75)
        self.checkView.frame = newFrame
        self.checkIconImageView.isHidden = true
        self.deviceUnpausedLabel.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.setUnpause()
        }, completion: { finished in
            self.pausedDelegate.reloadUnpauseRow(self.indexPath!)
        })
    }
    
    func setUnpause() {
        self.checkView.backgroundColor = UIColor.init(red: 39.0/255.0, green: 96.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        var newFrame = self.checkView.frame
        newFrame.size.width = self.frame.size.width
        self.checkView.frame = newFrame
        self.checkView.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unpauseView.layer.borderColor = UIColor(red: 152/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        unpauseView.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
