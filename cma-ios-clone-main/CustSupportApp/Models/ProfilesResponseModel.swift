//
//  LightSpeedProfile.swift
//  CustSupportApp
//
//  Created by Jason Melvin Ready on 8/16/22.
//

import Foundation

struct Profile: Codable,Equatable {
    var avatar_id:Int?
    var created_date:String?
    var master_bit:Bool?
    var pid:Int?
    var profile:String?
    var updated_date:String?
}

struct SetProfileResponseModel:Decodable{
    var data: [Profile]?
    var desc: String?
    var error: Int?
    
    init(data: [Profile]?, desc:String?, error:Int?) {
        self.data = data
        self.desc = desc
        self.error = error
    }
    enum CodingKeys: String, CodingKey {
      case data, desc, error
    }
}
struct DeleteProfileResponseModel:Decodable{
    var data: String?
    var desc: String?
    var request_id: String?
    var error: Int?
}
