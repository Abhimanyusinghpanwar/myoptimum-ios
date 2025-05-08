//
//  HelpMeOptimizeWithExtenderTableViewCell.swift
//  CustSupportApp
//
//  Created by priyanka.bodkhe on 25/05/23.
//

import UIKit
protocol TappbaleLabelForExtenderLink {
    func checkTappableLabelForExtenderLink(label : UILabel , text : String, sender : UITapGestureRecognizer)
}

class HelpMeOptimizeWithExtenderTableViewCell: UITableViewCell {

    @IBOutlet weak var optimizeExtenderImage: UIImageView!
    
    @IBOutlet weak var optimizeOptionLink: UILabel!
    @IBOutlet weak var optimizeExtenderDetail: UILabel!
    @IBOutlet weak var extenderTitle: UILabel!
    var tappbleDelegateforExtenderLink: TappbaleLabelForExtenderLink?
    let tappableText = "Check to see if you need an Extender"
    var tapExtenderKink = UITapGestureRecognizer()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        tapExtenderKink = UITapGestureRecognizer(target: self, action: #selector(tapLabelFunction))
        optimizeOptionLink.addGestureRecognizer(tapExtenderKink)
    }
    
    @objc func tapLabelFunction(sender:UITapGestureRecognizer) {
        tappbleDelegateforExtenderLink?.checkTappableLabelForExtenderLink(label: optimizeOptionLink, text: tappableText, sender: tapExtenderKink)
    }
    
}
