//
//  ProfileModel.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 11/10/22.
//

enum ProfileStatus: String {
    case online = "Online"
    case offline = "Offline"
    case paused = "Paused"
}
enum DeviceStatus: String {
    case online = "Online"
    case weak = "Weak"
    case offline = "Offline"
    case paused = "Paused"
    case notFoundInLT = "notFoundInLT"
}

import Foundation

typealias Profiles = [ProfileModel]

struct ProfileModel {
    
    var profile: Profile? = nil
    var profileImag: String = ""
    var profileName: String = ""
    var profileStatus: ProfileStatus? = nil
    var isMaster: Bool = false
    var avatarImage: AvatarImage
    var pid:Int?
    var macId: String?
    var devices: [DeviceNode] = []

}

struct DeviceNode {
    var status: DeviceStatus? = nil
    var LTStatus: DeviceStatus? = nil
    var device: LightspeedNode? = nil
    var connectedTime : Int = 0
}
