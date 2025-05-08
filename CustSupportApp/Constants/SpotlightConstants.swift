//
//  SpotlightConstants.swift
//  CustSupportApp
//
//  Created by Namarta on 31/10/22.
//

import Foundation

enum SpotLightCards: String, Comparable {
    static func < (lhs: SpotLightCards, rhs: SpotLightCards) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    ///TYPE #1 template
    case dead_zones = "4.3, typeOne"
    case stream_install = "4.2, typeOne"
    case network_down = "2.1, typeOne"
    case network_weak = "2.11, typeOne"
    // Template created for midnight blue template
    case offline_extender = "2.2, typeOne"
    case weak_extender = "2.3, typeOne"
    case readyToInstall_Extender5 = "4.1, typeOne"
    case readyToInstall_Extender6 = "4.11, typeOne" // To-Do: Static Data for now
    // Template created for Black and white template
    case thankYou = "6.0, typeOne"
    
    //Template from API for outages
    case outageAreaTemplateTypeOne = "1.1, outageBlue"
    case outageAreaTemplateTypeTwo = "1.1, outageWhite"
    case outageAreaSecondTemplateTypeOne = "1.2, outageBlue"
    case outageAreaSecondTemplateTypeTwo = "1.2, outageWhite"
    
    // Template from Response
    // Template created for Black and white template
    case billPayTemplateTypeOne = "3.1, typeThree"
    //
    case billPayTemplateTypeTwo = "3.1, typeTwo"
    // Template created for midnight blue template
    case billPayTemplateTypeThree = "3.1, typeFour"
    //
    // Template created for Black and white template
    case billPaySecondTemplateTypeOne = "3.2, typeThree"
    //
    case billPaySecondTemplateTypeTwo = "3.2, typeTwo"
    // Template created for midnight blue template
    case billPaySecondTemplateTypeThree = "3.2, typeFour"
    //

    ///TYPE #3 GoogleAd
    case adType = "5.0, typeAd"
    
    ///TYPE #4 None
    case none = ""
}

enum SpotLightTemplate: String {
    case one // My Wifi Cards, Thank you and Google AD
    case two //billPay
    case three //Dismissible & not dismissible spotlight cards that has B&W template
    case four // Dismissible & not dismissible spotlight cards that has Midnight Blue template - schedule payment error handling
    case outageFound //Used for all midnight blue templates associated with outage information cards
    case outageClear // used for both outage detected and outage clear cards
//    case adType
}
struct SpotlightMessages {
    static func getMessageT(cardType: SpotLightCards) -> (
        title: String,
        subtitle: String,
        button: String,
        imageName: String,
        accountName: String,
        color: UIColor,
        topColor: UIColor,
        bottomColor:UIColor,
        amount:String,
        dismissible:Bool,
        tapTarget:String,
        spotLightId:String,
        outageMoreInfoColor:UIColor?,
        spotlightCardPriority: String,
        spotlightCardData: SpotLightCardsGetResponse.CardData?
    )
    {
        var title = ""
        var subtitle = ""
        var button = ""
        var imageName = ""
        var tapTarget = ""
        var color = UIColor.white
        var amount = ""
        var accountName = ""
        var topColor = UIColor.white
        var bottomColor = UIColor.white
        var dismissible = false
        var spotLightId = ""
        var outageMoreInfoColor : UIColor?
        var spotlightCardData: SpotLightCardsGetResponse.CardData?
        var spotlightCardPriority = ""
        switch cardType {
        case .stream_install:
            title = "Optimum Stream"
            subtitle = "Ready to set up your new Stream?"
            button = "Set up now"
            if CurrentDevice.forLargeSpotlights() {
                imageName = "stream_install_large"
            } else {
                imageName = "optimum_stream_install"
            }//"dead_zones"
        case .dead_zones:
            title = "Looks like you've got dead zones"
            subtitle = "You may need an Extender"
            button = "Check now"
            if CurrentDevice.forLargeSpotlights() {
                imageName = "DeadZones_new"
            } else {
                imageName = "dead_zones"
            }//"dead_zones"
            color = midnightBlueRGB
        case .network_down:
            let titleDetails = self.forWifiDown()
            title = titleDetails.title
            subtitle = titleDetails.subtitleText
            button = "Let’s fix it"
            color = midnightBlueRGB
            if CurrentDevice.forLargeSpotlights() {
                imageName = "NetworkDownforlarge"
            } else {
                imageName = "network_down"
            }
        case .network_weak:
            title = " network is weak"
            subtitle = ""
            button = "Let’s fix it"
            //imageName = "network_down"
            if CurrentDevice.forLargeSpotlights() {
                imageName = "NetworkDownforlarge"
            } else {
                imageName = "network_down"
            }
            color = midnightBlueRGB
        case .offline_extender:
            title = SpotLightsManager.shared.getMessageForOfflineExtender()
            subtitle = ""
            button = "Let’s fix it"
            imageName = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? "offline_extender_6E" : "offline_extender"
            color = midnightBlueRGB
        case .weak_extender:
            title = SpotLightsManager.shared.getMessageForWeakExtender()
            subtitle = ""
            button = "Let’s fix it"
            imageName = MyWifiManager.shared.getExtenderImageForOfflineWeakStatus() ? "weak_extender_6E" : "weak_extender"
            color = midnightBlueRGB
        case .readyToInstall_Extender5:
            title = "Ready to set up your Optimum Extender 5?"
            subtitle = ""
            button = "Let’s go!"
            imageName = "readyToInstall_Extender5"
        case .readyToInstall_Extender6:
            title = "Ready to set up your Optimum Extender 6?"
            subtitle = ""
            button = "Let’s go!"
            imageName = "readyToInstall_Extender6"
        case .thankYou, .adType:
            title = "Thank you for being a customer"
            subtitle = "We wouldn’t be here without you!"
            imageName = "thankyou"
        case .none: break
        case .billPayTemplateTypeOne, .billPayTemplateTypeTwo, .billPaySecondTemplateTypeOne, .billPaySecondTemplateTypeTwo, .billPayTemplateTypeThree, .billPaySecondTemplateTypeThree, .outageAreaTemplateTypeOne, .outageAreaTemplateTypeTwo, .outageAreaSecondTemplateTypeOne, .outageAreaSecondTemplateTypeTwo:
            let priority = SpotLightsManager.shared.getTemplateTypeAndPriority(card: cardType).priority
            spotlightCardPriority = priority
            if let spotLightCards = SpotLightsManager.shared.spotLightCards, let cards = spotLightCards.cards, !cards.isEmpty {
                if let cardData = cards.filter({ $0.priorityKey == priority }) as [SpotLightCardsGetResponse.CardData]?, !cardData.isEmpty {
                    spotlightCardData = cardData[0]
                    title = cardData[0].title ?? ""
                    subtitle = cardData[0].body ?? ""
                    accountName = cardData[0].name ?? ""
                    //CMAIOS-2715
                    if let buttonInfo = cardData[0].button?.label, !buttonInfo.isEmpty {
                        button = cardData[0].button?.label ?? ""
                        if let moreInfoTemplate = cardData[0].button?.template {
                            if moreInfoTemplate == "orange"{
                                outageMoreInfoColor = btnBgOrangeColorRGB
                            } else if moreInfoTemplate == "midnightblue"{
                                outageMoreInfoColor = midnightBlueRGB
                            }
                        } else {
                            outageMoreInfoColor = midnightBlueRGB
                        }
                       
                    } else {
                        button = cardData[0].link ?? ""
                    }
                    imageName = SpotLightsManager.shared.mapSpotlightImage(cardData[0].image ?? "")
                    amount = cardData[0].amount ?? ""
                    dismissible = cardData[0].dismissible ?? false
                    tapTarget = cardData[0].tapTarget ?? ""
                    spotLightId = cardData[0].id ?? ""
                    if let cardColor = cardData[0].template {
                        if cardColor == "blackandwhite" {
                            color = .white
                        } else if cardColor == "midnightblue"{
                            color = midnightBlueRGB
                        } else if cardColor == "midnightblue_energyblue" {
                            topColor = midnightBlueRGB
                            bottomColor = energyBlueRGB
                        } else if cardColor == "energyblue_midnightblue" {
                            topColor = energyBlueRGB
                            bottomColor = midnightBlueRGB
                        } else if cardColor == "midnightblue_billing_unavailable" {
                            color = midnightBlueRGB
                        }
                    }
                }
            }
        }
        return(title: title, subtitle: subtitle, button: button, imageName: imageName, accountName: accountName, color: color,topColor: topColor, bottomColor: bottomColor, amount: amount, dismissible: dismissible, tapTarget: tapTarget, spotLightId: spotLightId, outageMoreInfoColor: outageMoreInfoColor, spotlightCardPriority: spotlightCardPriority, spotlightCardData: spotlightCardData)
    }
    
    static func forWifiDown() -> (title: String, subtitleText: String) {
        var title = ""
        var subtitle = ""
        //        if MyWifiManager.shared.wifiDisplayType == .Other {
        //            title = MyWifiManager.shared.getWifiType() == "Modem" ? "" : "My Internet"
        //            subtitle = MyInternetConstants.internet_down
        //        } else {
        //            title = SpotLightsManager.shared.getMessageForNetworkDown()
        //            subtitle = ""
        //        }
        // return(title: title, subtitleText: subtitle)
        if MyWifiManager.shared.getWifiType() == "Modem"{
            title = MyInternetConstants.internet_down
            subtitle = ""
        } else {
            title = SpotLightsManager.shared.getMessageForNetworkDown()
            subtitle = ""
        }
        return(title: title, subtitleText: subtitle)
    }
}

