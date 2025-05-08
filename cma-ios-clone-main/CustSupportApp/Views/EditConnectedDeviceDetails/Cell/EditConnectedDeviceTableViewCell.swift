//
//  EditConnectedDeviceTableViewCell.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 10/11/22.
//

import UIKit
protocol UpdateDeviceDetails: AnyObject {
    func sendDataFromCollectionview(deviceName : String, categoryName : String, sendIndex : Int,differentIndex : IndexPath)
}
class EditConnectedDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionviewHeight: NSLayoutConstraint!
    @IBOutlet weak var sectionName: UILabel!
    @IBOutlet weak var collectionview: CustomeCollectionView!
   // @IBOutlet weak var collectionview:
   // UICollectionView!
    weak var delegate: UpdateDeviceDetails?
    var devices = ["iphone", "ipad", "laptop", "desktop", "Watch"]
    var deviceCount:Int = 0
    var devicesFrom = [String]()
    var selectedIndex : IndexPath? = nil
    var isSelection = false
    var sendIndex = 0
    var selectedName = ""
    var categoryName = ""
    var anotherIndex : IndexPath? = nil
    @IBOutlet weak var cellSaperatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        registerCells()
        sectionName.textColor = UIColor(red: 0.153, green: 0.153, blue: 0.153, alpha: 1)

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 20.0
        collectionview.collectionViewLayout = layout
        collectionview.register(UINib(nibName: "ConnectedDeviceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ConnectedDeviceCollectionViewCell")
        collectionview.isScrollEnabled = false
        collectionview.delegate = self
        collectionview.dataSource = self
    }
    
    //Register All UITableViewCells
    func registerCells() {
        collectionview.register(UINib(nibName: "ConnectedDeviceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ConnectedDeviceCollectionViewCell")
    }
}

extension EditConnectedDeviceTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIScreen.main.bounds.height >= 852.0 {
            return CGSize(width: 98, height: 115)
        } else {
            return CGSize(width: 88, height: 105)
        }
}

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devicesFrom.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectedDeviceCollectionViewCell", for: indexPath) as? ConnectedDeviceCollectionViewCell else { return UICollectionViewCell() }
        cell.deviceName.text = devicesFrom[indexPath.item].firstCapitalized
        let iconName = devicesFrom[indexPath.row]
        cell.deviceImage.image = DeviceManager.IconType.gray.getDeviceImage(name: iconName).aspectFitImage(inRect: cell.deviceImage.frame)
        cell.deviceImage.contentMode = .bottom
        cell.checkBox.isHidden = (indexPath != selectedIndex)
        guard  selectedIndex == indexPath else
        {
        cell.backgroundContentView.layer.borderColor = UIColor(red: 0.596, green: 0.588, blue: 0.588, alpha: 1).cgColor
        cell.backgroundContentView.layer.borderWidth = 1
            return cell}
        cell.backgroundContentView.layer.borderColor = energyBlueRGB.cgColor
        cell.backgroundContentView.layer.borderWidth = 2
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectedDeviceCollectionViewCell", for: indexPath) as! ConnectedDeviceCollectionViewCell
        self.selectedIndex = indexPath
        self.selectedName = devicesFrom[indexPath.item]
        delegate?.sendDataFromCollectionview(deviceName: self.selectedName, categoryName: self.categoryName,sendIndex : self.collectionview.tag, differentIndex: indexPath)
        cell.isSelected = true
        guard (selectedIndex?.item != nil) else { return }
        self.collectionview.reloadData()
    }
    
}
