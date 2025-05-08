//
//  DisconnectedDevicesListTableViewCell.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 12/12/22.
//

import UIKit

class DisconnectedDevicesListTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var bottomViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomview: UIView!
    var indexPathForCell =  IndexPath()
    var isLastDisconnectedDeviceCell = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if indexPathForCell.row == 1
//        {
//            drawDottedLine(start: CGPoint(x: bottomview.bounds.minX - 100, y: bottomview.bounds.minY), end: CGPoint(x: bottomview.bounds.maxX, y: bottomview.bounds.maxY), view: bottomview)
//        }
//        else
//        {
//            print(indexPathForCell.row)
//            drawDottedLine(start: CGPoint(x: bottomview.bounds.minX, y: bottomview.bounds.minY), end: CGPoint(x: bottomview.bounds.maxX, y: bottomview.bounds.maxY), view: bottomview)
//        }
//        }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if !isLastDisconnectedDeviceCell{
//            drawDottedLine(start: CGPoint(x: bottomview.bounds.minX, y: bottomview.bounds.minY), end: CGPoint(x: bottomview.bounds.maxX, y: bottomview.bounds.maxY), view: bottomview)
//            self.bottomview.isHidden = false
//        } else {
//            self.bottomview.isHidden = true
//        }
//    }
//    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
//        shapeLayer.lineWidth = 1
//        shapeLayer.lineDashPattern = [3, 3] // [dash line length, dash line gap]
//        let path = CGMutablePath()
//        path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: view.frame.width, y: 0)])
//        shapeLayer.path = path
//        view.layer.addSublayer(shapeLayer)
//    }
    
}
