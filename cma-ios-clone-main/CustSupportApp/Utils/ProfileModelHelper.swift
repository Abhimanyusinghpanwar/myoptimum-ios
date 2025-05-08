//
//  ProfileModelHelper.swift
//  CustSupportApp
//
//  Created by Riyaz_infy on 27/10/22.
//

import Foundation

class ProfileModelHelper{
    
    class var shared: ProfileModelHelper {
        struct Singleton {
            static let instance = ProfileModelHelper()
        }
        return Singleton.instance
    }
    var profiles: Profiles?
    var isLiveTopology: Bool = false
    var currentSelectedModel:Profile?

    func getAllAvailableProfiles(completion: @escaping (Profiles?) -> Void) {
        guard let profiles = ProfileManager.shared.profiles else { return completion(nil) }
        guard !profiles.isEmpty else {
            return completion(nil)
        }
        self.profiles = profiles.compactMap {
            ProfileModel(profile: $0, profileName: $0.profile ?? "", profileStatus: ProfileManager.shared.currentPauseStatus(pid: $0.pid ?? 0, isMaster: $0.master_bit ?? false), isMaster: $0.master_bit ?? false, avatarImage: Avatar().getAvatarImage(for: $0.avatar_id ?? 13, name: $0.profile ?? ""), pid: $0.pid)
        }
        self.profiles = ProfileManager.shared.sortProfilesBasedOnMaster(profiles: self.profiles)
        self.updateProfileWithNodes(profiles: self.profiles ?? []) { devices in
            self.profiles = devices
                self.updateProfileDeviceStatusUsingLTData { statusDevices in
                    self.profiles = statusDevices
                    if let usageData = MyWifiManager.shared.clientUsage {
                            self.updateProfileDeviceConnectedTime(onlineActivityData: usageData) { profiles in
                                self.profiles = profiles
                            }
                    }
                    completion(self.profiles)
                }
        }
    }
    
    func updateProfileDeviceStatusUsingLTData(completion: @escaping (Profiles?) -> Void) {
        guard let tempProfiles = self.profiles else { return completion(self.profiles) }
        if self.checkIfLTNodesExists() {
            var currentProfiles = tempProfiles
                for (index, profile) in tempProfiles.enumerated() {
                    for (nIndex, node) in profile.devices.enumerated() {
                        if ProfileManager.shared.isDeviceMacPaused(mac: node.device?.mac ?? "")  {
                            currentProfiles[index].devices[nIndex].status = .paused
                            currentProfiles[index].devices[nIndex].LTStatus = checkDeviceStatusFromLT(mac:currentProfiles[index].devices[nIndex].device?.mac ?? "" )
                        } else {
                            if  let nodes = MyWifiManager.shared.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes] {
                                let nodeLT = nodes.filter { $0.mac?.isMatching(node.device?.mac ?? "") == true }
                                let state = MyWifiManager.shared.getNodeStatus(status: nodeLT.first?.status ?? "", colorName: nodeLT.first?.color ?? "")
                                if state == nil {
                                    //set default status to offline if there is no device status
                                    currentProfiles[index].devices[nIndex].status = .offline
                                    currentProfiles[index].devices[nIndex].LTStatus = .notFoundInLT
                                } else {
                                    currentProfiles[index].devices[nIndex].status = state
                                    currentProfiles[index].devices[nIndex].LTStatus = state
                                }
                            }
                        }
                        if let usageData = MyWifiManager.shared.clientUsage {
                            for client in usageData {
                                let formattedMacValue = WifiConfigValues.getFormattedMACAddress(client.mac ?? "")
                                if node.device?.mac?.isMatching(formattedMacValue ) == true{
                                    currentProfiles[index].devices[nIndex].connectedTime = client.connected_time ?? 0
                                }
                            }
                        }
                    }
                }
                for (index, profile) in currentProfiles.enumerated() {
                /** Profile pause status is only based on GET profile pause API**/
                let arrPausedPids = MyWifiManager.shared.pausedProfileIds
                    if !arrPausedPids.isEmpty, arrPausedPids.contains(profile.pid ?? 0) {
                        currentProfiles[index].profileStatus = .paused
                    } else {
                        if profile.devices.count > 0 {
                            
                            if profile.devices.contains(where: {$0.LTStatus == .online || $0.LTStatus == .weak}) {
                                currentProfiles[index].profileStatus = .online
                            } else {
                                currentProfiles[index].profileStatus = .offline
                            }
                        } else {
                            //Handle profile status when profile contains no devices
                            currentProfiles[index].profileStatus = nil
                        }
                    }
    /** This code is for, where the profile pause status depends on client devices**/
    /*
    if !arrPausedPids.isEmpty, arrPausedPids.contains(profile.pid ?? 0) {
        currentProfiles[index].status = .paused
    } else {
        if profile.devices.count > 0 {
            if profile.devices.allSatisfy( { $0.status == .paused }){
                currentProfiles[index].status = .paused
            } else if profile.devices.contains(where: { node in node.status == .paused}) {
                currentProfiles[index].status = .paused
            } else if profile.devices.contains(where: { node in node.status == .online}) ||  profile.devices.contains(where: { node in node.status == .weak}) {
                currentProfiles[index].status = .online
            } else if profile.devices.allSatisfy( { $0.status == nil }) || profile.devices.allSatisfy( { $0.status == .offline }) {
                currentProfiles[index].status = .offline
            }
        } else {
            //Handle profile status when profile contains no devices
            currentProfiles[index].status = nil
        }
    }
    */
        }
            ProfileModelHelper.shared.profiles = currentProfiles
            completion(currentProfiles)
        } else {
            completion(tempProfiles)
        }
    }
    
    func updateProfileAndDeviceStatusWithoutLTData(completion: @escaping (Profiles?) -> Void){
        //Reset the profileStatus to nil if we are not getting LT required data
        if  var currentProfiles = ProfileModelHelper.shared.profiles {
            let allProfiles = currentProfiles
            for (index, profile) in allProfiles.enumerated() {
                for (nIndex, _) in profile.devices.enumerated() {
                    currentProfiles[index].devices[nIndex].status = nil
                    currentProfiles[index].devices[nIndex].LTStatus = nil
                }
                currentProfiles[index].profileStatus = nil
            }
            ProfileModelHelper.shared.profiles = currentProfiles
            self.profiles = currentProfiles
            completion(currentProfiles)
        }
    }
    
    func checkIfLTNodesExists() -> Bool {
        if MyWifiManager.shared.getMyWifiStatus() != .backendFailure,
            MyWifiManager.shared.getMyWifiStatus() != .waitToRefresh,
            let nodes = MyWifiManager.shared.lightSpeedData?[LT_nodes] as? [LightSpeedAPIResponse.Nodes],
           !nodes.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func getProfileDeviceStatusBasedOnLTResponse(completion: @escaping (Profiles?) -> Void){
        if self.checkIfLTNodesExists() {
            self.updateProfileDeviceStatusUsingLTData { profiles in
                completion(profiles)
            }
        } else {
            self.updateProfileAndDeviceStatusWithoutLTData { profiles in
                completion(profiles)
            }
        }
    }
    
    func checkDeviceStatusFromLT(mac:String) -> DeviceStatus {
        guard let nodeDetails = MyWifiManager.shared.getDeviceDetailsForMAC(mac) else {
            return .notFoundInLT
        }
        return MyWifiManager.shared.getNodeStatus(status: nodeDetails.status ?? "", colorName: nodeDetails.color ?? "") ?? .notFoundInLT
    }
    
    
    func updateProfileDeviceConnectedTime(onlineActivityData:[ClientUsageResponse.Client], completion: @escaping (Profiles?) -> Void) {
         guard var profiles = self.profiles else {
               return completion(self.profiles)
         }
        for client in onlineActivityData {
            let formattedMacValue = WifiConfigValues.getFormattedMACAddress(client.mac ?? "")
            for (index, profile) in profiles.enumerated() {
                for (nIndex, node) in profile.devices.enumerated() {
                    if node.device?.mac?.isMatching(formattedMacValue ) == true{
                        profiles[index].devices[nIndex].connectedTime = client.connected_time ?? 0
                    }
                }
            }
        }
        return completion(profiles)
    }
    
    func updateNodeDataForProfile(deviceMac:String, selectedProfilePid:Int, updatedDeviceDetails:LightspeedNode? = nil){
        var deviceDetails : LightspeedNode?
        if let getAllNode_deviceDetails = DeviceManager.shared.getDeviceDetailsForMac(mac: deviceMac) {
            deviceDetails = getAllNode_deviceDetails
        } else if let lightSpeedNode_Details = updatedDeviceDetails {
            deviceDetails = lightSpeedNode_Details
        } else {
            return
        }
        let updatedPid = deviceDetails?.pid
        if updatedPid != nil, updatedPid != 0, selectedProfilePid == updatedPid {
            //device details are updated
            self.updateDeviceDetailsForProfileAfterEdit(updatedPid: updatedPid ?? 0, deviceDetails: deviceDetails, deviceMac: deviceMac)
        } else if updatedPid == 0, updatedPid != selectedProfilePid {
            //device is removed for selected profile
            self.removeDeviceFromAssignedProfile(selectedPid:selectedProfilePid, deviceMac: deviceMac, isAssignedToNewProfile:false, updatedPid:updatedPid ?? 0, deviceDetails:deviceDetails)
        } else {
            /* two scenarios
             device is removed for selected profile
             Same device is assigned to another profile
             */
            self.removeDeviceFromAssignedProfile(selectedPid:selectedProfilePid, deviceMac: deviceMac, isAssignedToNewProfile: true,updatedPid: updatedPid ?? 0, deviceDetails:deviceDetails)
        }
        
    }
    
    private func removeDeviceFromAssignedProfile(selectedPid:Int, deviceMac:String, isAssignedToNewProfile:Bool,updatedPid:Int, deviceDetails:LightspeedNode?){
        if var profile = self.profiles?.filter({ $0.pid == selectedPid}).first{
            if let indexOfRemovedDevice  = profile.devices.firstIndex(where:{ $0.device?.mac?.lowercased() == deviceMac.lowercased() }) {
                if isAssignedToNewProfile {
                    let device = profile.devices[indexOfRemovedDevice]
                    self.assignDeviceToNewProfile(updatedPid: updatedPid, deviceDetails: deviceDetails, deviceStatus: device.status ?? .notFoundInLT , deviceLTStatus: device.LTStatus ?? .notFoundInLT, deviceConnectedTime: device.connectedTime)
                }
                profile.devices.remove(at: indexOfRemovedDevice)
                if profile.devices.isEmpty {
                    profile.profileStatus = nil
                } else {
                    if profile.devices.contains(where: {$0.LTStatus == .online || $0.LTStatus == .weak}) {
                        profile.profileStatus = .online
                    } else {
                        profile.profileStatus = .offline
                    }
                }
                if let profileIndex = self.profiles?.firstIndex(where: {$0.pid == selectedPid}) {
                    self.profiles?[profileIndex] = profile
                }
            }
        }
    }
    
    private func updateDeviceDetailsForProfileAfterEdit(updatedPid:Int, deviceDetails:LightspeedNode?, deviceMac : String) {
        if var profile = self.profiles?.filter({ $0.pid == updatedPid }).first{
            if var deviceNode  = profile.devices.filter({ $0.device?.mac?.lowercased() == deviceMac.lowercased()}).first{
                deviceNode.device = deviceDetails
                if let deviceIndex =  profile.devices.firstIndex(where: {$0.device?.mac?.lowercased() == deviceMac.lowercased()}) {
                    profile.devices[deviceIndex] = deviceNode
                }
                if let profileIndex = self.profiles?.firstIndex(where: {$0.pid == updatedPid}) {
                    self.profiles?[profileIndex] = profile
                }
            }
        }
    }
    
    private func assignDeviceToNewProfile(updatedPid:Int, deviceDetails:LightspeedNode?,deviceStatus:DeviceStatus, deviceLTStatus: DeviceStatus, deviceConnectedTime:Int) {
        if var profile = self.profiles?.filter({ $0.pid == updatedPid }).first{
            profile.devices.append(DeviceNode(status:deviceStatus, LTStatus:deviceLTStatus, device: deviceDetails, connectedTime: deviceConnectedTime))
            if profile.devices.contains(where: {$0.LTStatus == .online || $0.LTStatus == .weak}) {
                profile.profileStatus = .online
            } else {
                profile.profileStatus = .offline
            }
            if let profileIndex = self.profiles?.firstIndex(where: {$0.pid == updatedPid}) {
                self.profiles?[profileIndex] = profile
            }
        }
    }
    
    func updateProfileWithNodes(profiles: Profiles, completion: @escaping (Profiles) -> Void) {
        var currentProfiles = profiles
        if let devices = DeviceManager.shared.devices, !devices.isEmpty {
            for (index, device) in profiles.enumerated() {
                let node = devices.filter { $0.pid == device.pid ?? 0 }.compactMap {
                    DeviceNode(status: nil, device: $0)
                }
                currentProfiles[index].devices = node
            }
            completion(currentProfiles)
        } else {
            DispatchQueue.global(qos: .background).async {
                APIRequests.shared.getAllNodes { result in
                    guard case let .success(nodes) = result else {
                        return completion(currentProfiles)
                    }
                    for (index, device) in currentProfiles.enumerated() {
                        let node = nodes.filter { $0.pid == device.pid ?? 0 }.compactMap {
                            DeviceNode(status: nil, device: $0)
                        }
                        currentProfiles[index].devices = node
                    }
                    completion(currentProfiles)
                }
                completion(currentProfiles)
            }
        }
    }
    
    func getAllProfilesWithDevices(profiles:Profiles?)-> Profiles? {
        let profilesWithDevices = profiles?.filter { $0.devices.count > 0 }
        return profilesWithDevices
    }
    
    func getAllProfilesWithoutDevices(profiles:Profiles?)-> Profiles? {
        let profilesWithoutDevices = profiles?.filter { $0.devices.count == 0 }
        return profilesWithoutDevices
    }
        
    func getTimeForPauseInternet (isPauseForAnHour:Bool)->String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "hh:mm a"
//        var hourString = ""
//        if isPauseForAnHour {
//            hourString = formatter.string(from: Date() + 3600)
//            hourString = "Paused until " + hourString
//        } else {
//            //handle for pauseUntilTomorrow
//            hourString = "Paused until 6am tomorrow"
//        }
        return "Paused"
    }
}
struct PauseSchedule {
    var startDate: Date?
    var endDate: Date?
    var profileId: String?
}
