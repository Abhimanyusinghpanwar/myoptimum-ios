//
//  SpotLightCardsModel.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 10/04/24.
//

import Foundation
struct SpotLightCardsGetResponse: Decodable {
    
    var cards : [CardData]?
    let promoDismissalActive: Bool?
    var googleAdEligible: Bool
    
    struct CardData: Decodable {
        let id : String?
        let title : String?
        let body : String?
        let image : String?
        let button : ButtonInfo?
        let dismissible : Bool?
        var wasDismissed : Bool?
        var wasViewed : Bool?
        let template : String?
        let date : String?
        let name : String?
        let link : String?
        let tapTarget : String?
        let amount : String?
        var priorityKey : String?
        let payNickName : String?
        let GAkey : String?
        let errorCode : String?
        let moreInfo : MoreInfo?
//        var dismissalWindow: Int? //CMAIOS-2680
    }
    
    struct ButtonInfo: Decodable {
        let action : String?
        let label  : String?
        let template :String?
    }
    
    struct MoreInfo: Decodable {
        let image : String?
        let title  : String?
        let body :String?
        let buttons : [ButtonInfo]?
        let footer :String?
        let template :String?
        let etr: String?
        let servicesImpacted: [String]?//CMAIOS-2399, CMAIOS-2596
    }
}
