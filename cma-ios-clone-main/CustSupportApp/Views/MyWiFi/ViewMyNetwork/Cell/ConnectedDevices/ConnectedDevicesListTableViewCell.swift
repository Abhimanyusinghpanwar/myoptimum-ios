//
//  ConnectedDevicesListTableViewCell.swift
//  CustSupportApp
//
//  Created by chandru.mahalingam on 24/08/22.
//

import UIKit

class ConnectedDevicesListTableViewCell: UITableViewCell {
    
    //View Outlet Connections
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwBottomLine: UIView!
    @IBOutlet weak var vwSolidLine: UIView!
    //Label Outlet Connections
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    //ImageView Outlet Connections
    @IBOutlet weak var imgViewType: UIImageView!
    @IBOutlet weak var imgViewStatus: UIImageView!
    @IBOutlet weak var imgViewArrow: UIImageView!
    @IBOutlet weak var deviceNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var vwSolidLineTopConstraint: NSLayoutConstraint!
    var isLastCell = false
    var hideSeparator = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDefaultValues()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setDefaultValues() {
        lblTitle.text = ""
        lblStatus.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hideSeparator {
            if !isLastCell{
                drawDottedLine(start: CGPoint(x: vwBottomLine.bounds.minX, y: vwBottomLine.bounds.minY), end: CGPoint(x: vwBottomLine.bounds.maxX, y: vwBottomLine.bounds.maxY), view: vwBottomLine)
            } else {
                vwBottomLine.isHidden = true
                vwSolidLine.isHidden = false
                vwSolidLineTopConstraint.constant = 51.0
            }
        } else {
            vwBottomLine.isHidden = true
            vwSolidLine.isHidden = true
        }
    }
    
    //MARK: Dotted line
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [3, 3] // [dash line length, dash line gap]
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if vwBottomLine.layer.sublayers != nil {
            vwBottomLine.layer.sublayers?.removeAll()
        }
    }
}
