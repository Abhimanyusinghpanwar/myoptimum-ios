//
//  ProfileManager.swift
//  CustSupportApp
//
//  Created by Sai Pavan Neerukonda on 9/8/22.
//

import Alamofire

class ProfileManager {
    
    // For now make it as a shared instance. In bigger picture all managers
    // should be include into session manager which is created per session
    class var shared: ProfileManager {
        struct Singleton {
            static let instance = ProfileManager()
        }
        return Singleton.instance
    }
    
    var profiles: [Profile]?
    var isFirstUserExperience = false
    var isFirstUserCompleted = false
    var accessProfileData: AccessProfileGetResponse?
    var pausedProfileStatusCalled:Bool = false
    var profileManagerDelegate: ProfileManagerDelegate!
    
    func getAvatarIDFromPID(pid:Int) -> Int?{
        let avatarID = self.profiles?.filter { $0.pid == pid }.first?.avatar_id ?? 13
        return avatarID
    }
    
    func getProfiles(ignoreCache: Bool = true, completion: @escaping (Result<[Profile], Error>) -> Void) {
        if !ignoreCache, let profiles = profiles {
            completion(.success(profiles))
        }
        APIRequests.shared.performGetProfileRequest { success, value, error in
            if success {
                if MyWifiManager.shared.isGateWayWifi6() == true {
                    DispatchQueue.global(qos: .background).async {
                        self.getPausedProfiles()
                    }
                }
                completion(.success(value ?? []))
            } else {
                completion(.failure(error!))
            }
        }
        if MyWifiManager.shared.isGateWayWifi6() == true {
            DispatchQueue.global(qos: .background).async {
                self.getPausedDevices()
            }
        }
        DispatchQueue.global(qos: .background).async {
            DeviceManager.shared.performGetAllNodes()
        }
    }
    
    func setProfile(_ profile: Profile, completion: @escaping (Result<[Profile], Error>) -> Void) {
        // TODO: Need to remove Temporary logic added for testing purpose
        if enableFirstUserExperience {
            enableFirstUserExperience = false
            return completion(.success(profiles ?? []))
        }
        guard let params = profile.dictionary as? [String: AnyObject] else {
            return
        }
        APIRequests.shared.setProfile(jsonParams: params) { success, value, error in
            if success {
                guard let val = value else {
                    completion(.failure(error ?? NSError()))
                    return
                }
                self.getProfiles { _ in
                    completion(.success(val.data ?? []))
                }
            } else {
                completion(.failure(error!))
            }
        }
    }
    
    func sortProfilesBasedOnMaster(profiles:[ProfileModel]?) -> ([ProfileModel]) {
        guard var profilesExists = profiles else { return ([]) }
        //filter Master profiles
        guard let index = profilesExists.firstIndex(where: { $0.isMaster == true }) else { return  profilesExists }
        let sortedArray = profilesExists.sorted { $0.profile!.pid ?? 0 < $1.profile!.pid ?? 0 }
        return sortedArray
    }
    
    func masterProfileExists(profiles:[ProfileModel]? = nil, profileDetail: [Profile]? = nil) -> (Bool, [Any]?) {
        
        if let profilesExists = profiles {
            var isMasterProfilePresent = false
            let arrContainingMasterProfile = profilesExists.filter { obj in
                return obj.profile?.master_bit == true
            }
            if !arrContainingMasterProfile.isEmpty {
                isMasterProfilePresent = true
            }
            return (isMasterProfilePresent,arrContainingMasterProfile)
        } else {
            if let profilesExists = profileDetail {
                var isMasterProfilePresent = false
                let arrContainingMasterProfile = profilesExists.filter { obj in
                    return obj.master_bit == true
                }
                if !arrContainingMasterProfile.isEmpty {
                    isMasterProfilePresent = true
                }
                return (isMasterProfilePresent,arrContainingMasterProfile)
            }
        }
        return (false, nil)
    }
    // MARK: - Create Pause Type Request Params
    func schedulePauseForProfile(pid:Int, rules:[String: AnyObject]) -> [String: AnyObject]? {
        var params = [String: AnyObject]()
        params["entity"] = "Test CreateProfile With Restriction Rules Instantaneous Pause" as AnyObject?
        params["type"] = "group" as AnyObject?
        params["icon"] = "icon-kids" as AnyObject?
        params["pid"] = pid as AnyObject?
        params["restrictionRules"] = [rules] as AnyObject?
        
        return params
    }
    
    
    func createPauseScheduleForDevice(scheduleModel: PauseScheduleModel) -> [String: AnyObject]? {
        var data = [String: AnyObject]()
        var params = [String: AnyObject]()
        var rule = [String: AnyObject]()
        var ruleWeekEnd = [String: AnyObject]()
        rule["endTime"] = getTimeAndtimeTypefromDateForValidation(date: scheduleModel.timerModel.toDate ?? Date()).time as AnyObject?
        rule["startTime"] = getTimeAndtimeTypefromDateForValidation(date: scheduleModel.timerModel.fromDate ?? Date()).time as AnyObject?
        rule["days"] = ["mon", "tue", "wed", "thr", "fri"] as AnyObject?
        params["restrictionRules"] = [rule] as AnyObject?
        if scheduleModel.weekEndModel.isTimerSaved == true {
            ruleWeekEnd["endTime"] = getTimeAndtimeTypefromDateForValidation(date: scheduleModel.weekEndModel.toDate ?? Date()).time as AnyObject?
            ruleWeekEnd["startTime"] = getTimeAndtimeTypefromDateForValidation(date: scheduleModel.weekEndModel.fromDate ?? Date()).time as AnyObject?
            ruleWeekEnd["days"] = ["sat","sun"] as AnyObject?
            params["restrictionRules"] = [rule, ruleWeekEnd] as AnyObject?
        }
        data["data"] = params as AnyObject?
        return data
    }
    
    func getTimeAndtimeTypefromDateForValidation(date: Date) -> (time: String, String) {
        var changedTimeString = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        changedTimeString = formatter.string(from: date)
        return (time: changedTimeString , changedTimeString.components(separatedBy: " ").last ?? "")
    }
    
    func createPauseTimerTempRules(startTime: String = "2:00", endTime: String = "11:00", days:[String] = ["mon", "tue", "wed", "thu", "fri"]) -> [String: AnyObject]? {
        let rule = [String: AnyObject]()
        var params = [String: AnyObject]()
        var data = [String: AnyObject]()
        params["restrictionRules"] = [rule] as AnyObject?
        
        data["data"] = params as AnyObject?

//        params["data"] = { "restrictionRules" :
//            ["startTime":"2:00",
//             "endTime": "11:00",
//             "days": ["mon,tue,wed,thu,fri"]
//            ]
//        } as AnyObject?
        return data
    }

    func schedulePauseForDevice(macAddresses:[String], rules:[String: AnyObject]) -> [String: AnyObject]? {
        var params = [String: AnyObject]()
        params["entity"] = "Person" as AnyObject?
        params["type"] = "group" as AnyObject?
        params["icon"] = "icon-person" as AnyObject?
        params["clients"] = macAddresses as AnyObject?
        params["restrictionRules"] = [rules] as AnyObject?
        
        return params
    }
    
    func createRestrictionRuleForProfile(type:NSString = "scheduler", enabled:Bool, endTime:String, startTime:String, days:[String] = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]) -> [String: AnyObject]? {
        var rule = [String: AnyObject]()
        rule["type"] = type as AnyObject?
        rule["enabled"] = enabled as AnyObject?
        rule["endTime"] = endTime as AnyObject?
        rule["startTime"] = startTime as AnyObject?
        rule["description"] = "Schedule" as AnyObject?
        if !days.isEmpty {
            rule["description"] = "Week" as AnyObject?
            rule["days"] = days as AnyObject?
        }
        return rule
    }
    
    func createRestrictionRulesForDevice(enabled: Bool, startTime:Date, endTime:Date) -> [String: AnyObject]? {
        var rule = [String: AnyObject]()
       // rule["type"] = "pause" as AnyObject? // for instant pause
        rule["type"] = "scheduler" as AnyObject?
        rule["enabled"] = enabled as AnyObject?
        rule["endTime"] = endTime.getDateStringForAPIParam() as AnyObject?
        rule["startTime"] = startTime.getDateStringForAPIParam() as AnyObject?
        return rule
    }
    // MARK: - Pause Schedule Manager
    func getPausedDevices() {
        APIRequests.shared.initiateGetAccessProfileByClientRequest { success, response, error in
            if success {
                Logger.info("Get Access Profile API success")
                MyWifiManager.shared.pausedClientData = response
            } else {
                Logger.info("Get Access Profile API failure")
            }
        }
    }
    
    func getPausedProfiles() {
        if pausedProfileStatusCalled {
            return
        }
        guard let profileArray = self.profiles, !profileArray.isEmpty else {
            return
        }
        let group = DispatchGroup()
        var result: [Int]? = []
        for profile in profileArray {
            if profile.master_bit == false {
                // Wait for previous request to finish before trying again.
                group.enter()
                APIRequests.shared.initiateGetAccessProfileRequest(pid: profile.pid ?? 0) { success, response, error in
                    if success {
                        if let data = response, data.isProfilePaused ?? false {
                            //MyWifiManager.shared.pausedProfiles.append(response!)
                            result?.append(profile.pid!)
                        }
                    }
                    group.leave()
                }
                group.wait()
            }
        }
        pausedProfileStatusCalled = true
        guard result != nil && result?.isEmpty == false else {
            return
        }
        MyWifiManager.shared.pausedProfileIds = result!
        if self.profileManagerDelegate != nil {
            self.profileManagerDelegate.updateStatusForPausedProfiles()
        }
    }
    
    func getPauseScheduleFor(pid:Int) -> [PauseSchedule]? {
        guard let values = self.accessProfileData else {
            return nil
        }
        var pauseSchedules : [PauseSchedule]? = []
        guard let data = (values.data?.filter{$0.pid == pid}) else {
            return nil
        }
        _ = data.map { data in
            if let rules = data.restrictionRules?.filter({$0.enabled == true}), !rules.isEmpty {
                _ = rules.map { rule in
                    if let endTime = rule.endTime, let startTime = rule.startTime, !endTime.isEmpty, !startTime.isEmpty {
                        let endSchedule = CommonUtility.getDateFromResponseValue(strDate: endTime)
                        let startSchedule = CommonUtility.getDateFromResponseValue(strDate: startTime)
                        if endSchedule > Date() {
                            pauseSchedules?.append(PauseSchedule(startDate: startSchedule, endDate: endSchedule, profileId: rule.id))
                        }
                    }
                }
            }
        }
        return pauseSchedules
    }
    
    /*func getPauseScheduleFor(mac:String) -> [PauseSchedule]? {
        guard let values = MyWifiManager.shared.pausedClientData else {
            return nil
        }
        var pauseSchedules : [PauseSchedule]? = []
//        guard let data = values.data?.filter({$0.clients?.contains(mac) == true}) else {
//            return nil
//        }
//        _ = data.map { data in
//            if let rules = data.restrictionRules?.filter({$0.enabled == true}), !rules.isEmpty {
//                _ = rules.map { rule in
//                    if let endTime = rule.endTime, let startTime = rule.startTime, !endTime.isEmpty, !startTime.isEmpty {
//                        let endSchedule = CommonUtility.getDateFromResponseValue(strDate: endTime)
//                        let startSchedule = CommonUtility.getDateFromResponseValue(strDate: startTime)
//                        if endSchedule > Date() {
//                            pauseSchedules?.append(PauseSchedule(startDate: startSchedule, endDate: endSchedule))
//                        }
//                    }
//                }
//            }
//        }
        return pauseSchedules
    }*/
    
    func currentPauseStatus(pid:Int, isMaster:Bool) -> ProfileStatus? {
        if isMaster {
            return nil
        }
        if MyWifiManager.shared.pausedProfileIds.contains(pid) == true {
            return .paused
        }
        return nil
//        var status: ProfileStatus?
//        let group = DispatchGroup()
//        group.enter()
//        APIRequests.shared.initiateGetAccessProfileRequest(pid: pid) { success, response, error in
//            if success {
//                if let data = response, data.isProfilePaused == true {
//                    status = .paused
//                    MyWifiManager.shared.pausedProfileIds.append(pid)
//                    group.leave()
//                }
//            }
//        }
//        group.wait()
//        return status

//        return nil
//        guard let schedules = self.getPauseScheduleFor(pid: pid) else {
//            return nil
//        }
//        let currentlyActive = schedules.filter({Date().isBetween($0.startDate!, and: $0.endDate!) == true})
//        if !currentlyActive.isEmpty {
//            if currentlyActive.first?.endDate?.isMoreThanOneHour() == true {
//                return .pausedUntilTomorrow
//            } else {
//                return .paused
//            }
//        }
    }
    
//    func currentPauseStatus(mac:String) -> ProfileStatus? {
//        guard let schedules = self.getPauseScheduleFor(mac: mac) else {
//            return nil
//        }
//        let currentlyActive = schedules.filter({Date().isBetween($0.startDate!, and: $0.endDate!) == true})
//        if !currentlyActive.isEmpty {
//            if currentlyActive.first?.endDate?.isMoreThanOneHour() == true {
//                return .pausedUntilTomorrow
//            } else {
//                return .paused
//            }
//        }
//        return nil
//    }
    
    func isDeviceMacPaused(mac: String) -> Bool {
        guard let pausedDevices = MyWifiManager.shared.pausedClientData else {
            return false
        }
        if let devices = pausedDevices.data?.filter({$0.paused == true && ($0.mac?.isMatching(mac) == true)}), !devices.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: - Clear Data
    func clearDataOnLogout() {
        isFirstUserExperience = false
        pausedProfileStatusCalled = false
        accessProfileData = nil
        if let profile = profiles {
            if !profile.isEmpty {
                profiles?.removeAll()
            }
            profiles = nil
        }
        if let manager = ProfileModelHelper.shared as ProfileModelHelper?, let profile = manager.profiles {
            if !profile.isEmpty {
                ProfileModelHelper.shared.profiles?.removeAll()
            }
            ProfileModelHelper.shared.profiles = nil
        }
        if let deviceManager = DeviceManager.shared as DeviceManager?, let devices = deviceManager.devices {
            if !devices.isEmpty {
                DeviceManager.shared.devices?.removeAll()
            }
            DeviceManager.shared.devices = nil
        }
    }
}
