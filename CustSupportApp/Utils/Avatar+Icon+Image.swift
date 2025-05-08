//
//  Avatar+Icon+Image.swift
//  CustSupportApp
//
//  Created by riyaz on 25/07/23.
//

import Foundation

struct AvatarIcon {
    let avatarID: Int?
    let profileName:String?
    
    func getAvatarName(isOnlinepause:Bool = false, isHomeOnlinepause:Bool = false, isHomeWithBg:Bool = false) -> String {
        var name = ""
        switch avatarID {
        case 1:
            name = "Bird"
        case 2:
            name = "Book"
        case 3:
            name = "Brush+Pallete"
        case 4:
            name = "Cat"
        case 5:
            name = "Chess"
        case 6:
            name = "Coffee"
        case 7:
            name = "Crown"
        case 8:
            name = "Dog"
        case 9:
            name = "Fox"
        case 10:
            name = "Guitar"
        case 11:
            name = "Lotus"
        case 12:
            name = "Owl"
        default :
            name = profileName?.prefix(1).capitalized ?? ""
        }
        return isOnlinepause ? "\(name)-Home-Online -Pause" : isHomeOnlinepause ? "\(name)-Profile-Online-Pause" : isHomeWithBg ? "\(name)-Home-Offline-Online-Bg" : ((name == "D") ? "\(name)-Profile-Online-Pause" :"\(name)-Profile-Pause-Online")
    }
}

struct AvatarImage {
    let id: Int
    let name: String
    
    var offline: String {
        "\(name)-Home-Offline-Online"
    }
    
    var offlinePause: String {
        "\(name)-Home-Offline-Pause"
    }
    
    var onlinePause: String {
        "\(name)-Home-Online -Pause"
    }
}

class Avatar {
    
    init() { }
    
    func getAvatarImage(for id: Int, name: String) -> AvatarImage {
        let avatarNames = ["Bird", "Book", "Brush+Pallete", "Cat", "Chess", "Coffee", "Crown", "Dog", "Fox", "Guitar", "Lotus", "Owl"]
        //guard let index = Int(id)  else { return AvatarImage(id: id, name: "Bird") }
        var avatar: AvatarImage!
        if id > 0 && id <= 12  {
            avatar = AvatarImage(id: id, name: avatarNames[id-1])
        } else {
            avatar = AvatarImage(id: id, name: name.first.map(String.init)?.capitalized ?? "")
        }
        return avatar
    }
    
    func checkAvatarType(avatarId:Int?)->ImageType {
        if let avatarID = avatarId {
            switch avatarID {
            case 1...12 :
                return .avatarIcon
            case 13... :
                return  .alphabet
            default:
                break
            }
        }
        return .none
    }

}
