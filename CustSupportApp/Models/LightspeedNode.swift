//
//  LightspeedNode.swift
//  CustSupportApp
//
//  Created by Jason Melvin Ready on 8/18/22.
//

import Foundation
//MARK: - Set Node Response Codable
struct SetNodeResponse: Codable {
    let data: [LightspeedNode]?
    let desc: String?
    let error: Int
}
//MARK: - LightspeedNode Codable
struct LightspeedNode: Codable{
    let accno: String? // Get all node is not returning
    let mac: String?
    let gwid: String?
    var pid: Int?
    let friendlyName: String?
    let hostname: String?
    let location: String?
    let createdDate: String?
    let updatedDate: String?
    let nodeType: String?
    let category: String?
    let deviceType: String?
    let vendor: String?
    var profile: String?
    
    
    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case createdDate = "created_date"
        case updatedDate = "updated_date"
        case category = "cma_category"
        case deviceType = "cma_dev_type"
        case friendlyName = "friendlyname"
        case accno, mac, gwid, pid, hostname, location, profile, vendor
    }
    mutating func updatePid(newPid:Int) {
        self.pid = newPid
    }
    func toDictionary()-> [String:AnyObject]?{
        do{
            let data = try JSONEncoder().encode(self)
            let dict = try JSONDecoder().decode([String:String?].self, from: data)
            return dict as [String:AnyObject]
        }
        catch{
            return nil
        }
    }
    func asDictionary() throws -> [String: AnyObject]? {
        do {
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
              throw NSError()
            }
            return dictionary
        } catch{
            return nil
        }
      }
}
