//
//  SettingsResponseModel.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 09/10/23.
//

import Foundation

struct SettingsAPIResponse : Decodable {
    var whatsnew_last_seen_set : String?
    init(whatsnew_last_seen_set: String?) {
        self.whatsnew_last_seen_set = whatsnew_last_seen_set
    }
}
