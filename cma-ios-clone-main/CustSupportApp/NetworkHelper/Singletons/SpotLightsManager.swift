//
//  SpotlightHandler.swift
//  CustSupportApp
//
//  Created by Namarta on 10/11/22.
//

import Foundation
class SpotLightsManager {
    // var arrSpotLights:[SpotLightTemplate] = []
    // Static Data for now
    var spotLightCards: SpotLightCardsGetResponse!
    var gAdCardEligible = false
    var dismissibleCardsArray = [SpotLightCardsGetResponse.CardData]()
   // var GACardRemoved = false
    var adLoadingComplete = false
    @Published var arrSpotLights: [SpotLightCards] = []// (ConfigService.shared.ad_enabled == "true") ? [.adType] : [.thankYou]
    class var shared: SpotLightsManager {
        struct Singleton {
            static let instance = SpotLightsManager()
        }
        return Singleton.instance
    }
    
    // MARK: - Priority #2
    func configureSpotLightsForMyWifi() {
        removeAllWifiRelatedCards()
        if MyWifiManager.shared.outageTitle == "OUTAGE_ON_ACCOUNT" {return}//CMAIOS-1701
        let wifiStatus = MyWifiManager.shared.getMyWifiStatus()
        if wifiStatus == .wifiDown {
            self.addCard(card: SpotLightCards.network_down)
        } else if wifiStatus == .runningSmoothly {
            // should just work with removing all wifi cards
        } else {
            let offlineExtends = MyWifiManager.shared.getOfflineExtenders()
            if !offlineExtends.isEmpty {
                self.addCard(card: SpotLightCards.offline_extender)
            } else {
                let weakExtends = MyWifiManager.shared.getWeakExtenders()
                if !weakExtends.isEmpty {
                    self.addCard(card: SpotLightCards.weak_extender)
                }
            }
        }
    }
    
    func removeAllWifiRelatedCards() {
        if self.arrSpotLights.contains(SpotLightCards.network_down) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.network_down) {
                self.arrSpotLights.remove(at: index)
            }
        }
        if self.arrSpotLights.contains(SpotLightCards.network_weak) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.network_weak) {
                self.arrSpotLights.remove(at: index)
            }
        }
        //CMAIOS-Troubleshooting-Extenders-Remove-Cards-when-Newtork is running smoothly and extenders are derived to be online.
        if self.arrSpotLights.contains(SpotLightCards.offline_extender){
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.offline_extender) {
                self.arrSpotLights.remove(at: index)
            }
        }
        if self.arrSpotLights.contains(SpotLightCards.weak_extender){
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.weak_extender) {
                self.arrSpotLights.remove(at: index)
            }
        }
    }
    
    // MARK: - Priority #3.2
    func configureSpotLightsForSelfInstall() {
        if self.arrSpotLights.contains(SpotLightCards.stream_install) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.stream_install) {
                self.arrSpotLights.remove(at: index)
            }
        }
        self.addCard(card: SpotLightCards.stream_install)
    }
    
    // MARK: - Priority #3.3
    func configureSpotlightsForDeadZone() {
        if self.arrSpotLights.contains(SpotLightCards.dead_zones) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.dead_zones) {
                self.arrSpotLights.remove(at: index)
            }
        }
        self.addCard(card: SpotLightCards.dead_zones)
    }
    
    func removeSpotlightForDeadZone() {
        if self.arrSpotLights.contains(SpotLightCards.dead_zones) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.dead_zones) {
                self.arrSpotLights.remove(at: index)
            }
        }
    }
    
    // MARK: - Priority #4
    // MidnightBlue & Energy Blue, Energy Blue & Midnight Blue - typeTwo bill pay spotlight cards
    // Dismissible, Non dismissible B&W spotlight cards - typeThree spotlight cards
    // Dismissible, Non dismissible MidnightBlue spotlight cards - typeFour spotlight cards
    func configureSpotLightsForBillPay() {
        //CMAIOS-2591
        self.arrSpotLights.removeAll { $0.rawValue.contains("3.") || $0.rawValue.contains("1.")}
        if let spotlights = self.spotLightCards, let cards = spotlights.cards, !cards.isEmpty {
            for i in 0..<(cards.count) {
                if cards[i].GAkey == "homepagecard_pastdue" || cards[i].GAkey == "homepagecard_predeauth"
                    || cards[i].GAkey == "homepagecard_autopay_amount_due_higher_than_maxamount" {
                    suppressGAdCard()
                }
                if let dismissible = cards[i].dismissible {
                    if !dismissible {
                        if let priority = cards[i].priorityKey, let cardDetails = arrSpotLights.filter({$0.rawValue.contains(priority)}) as [SpotLightCards]?, cardDetails.isEmpty {
                            var cardTypeForSpotlight = "typeThree"
                            if let cardType = cards[i].template {
                                if priority.contains("1.") {
                                    if cardType == "blackandwhite" {
                                        cardTypeForSpotlight = "outageWhite"
                                    } else {
                                        cardTypeForSpotlight = "outageBlue"
                                    }
                                } else if cardType == "midnightblue_billing_unavailable" {
                                    cardTypeForSpotlight = "typeThree"
                                } else {
                                    cardTypeForSpotlight = (cardType == "midnightblue_energyblue" || cardType == "energyblue_midnightblue") ? "typeTwo" : (cardType == "midnightblue" ? "typeFour" : "typeThree")
                                }
                            }
                            self.addCard(card: SpotLightCards.init(rawValue: "\(priority), \(cardTypeForSpotlight)") ?? .none)
                        }
                    } else {
                        if let wasViewed = cards[i].wasViewed, let wasDismissed = cards[i].wasDismissed, !wasViewed, !wasDismissed {
                            if let priority = cards[i].priorityKey, let cardDetails = arrSpotLights.filter({$0.rawValue.contains(priority)}) as [SpotLightCards]?, cardDetails.isEmpty {
                                var cardTypeForSpotlight = "typeThree"
                                if let cardType = cards[i].template {
                                    if priority.contains("1.") {
                                        if cardType == "blackandwhite" {
                                            cardTypeForSpotlight = "outageWhite"
                                        } else {
                                            cardTypeForSpotlight = "outageBlue"
                                        }
                                    } else {
                                        cardTypeForSpotlight = (cardType == "midnightblue_energyblue" || cardType == "energyblue_midnightblue") ? "typeTwo" : (cardType == "midnightblue" ? "typeFour" : "typeThree")
                                    }
                                }
                                self.addCard(card: SpotLightCards(rawValue: "\(priority), \(cardTypeForSpotlight)") ?? .none)
                            }
                        }
                    }
                }
            }
        } 
        if SpotLightsManager.shared.arrSpotLights.isEmpty {
            self.configureSpotLightsForThankYou()
        }
    }
    
    // MARK: - Priority #5
    /// This method is not getting called explicitly. As google Ad is added in arrSpotlights by default
    func configureSpotLightsForGoogleAd() {
        if self.arrSpotLights.contains(SpotLightCards.thankYou) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.thankYou) {
                self.arrSpotLights.remove(at: index)
            }
        }
        if self.arrSpotLights.contains(SpotLightCards.adType) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.adType) {
                self.arrSpotLights.remove(at: index)
            }
        }
        self.addCard(card: SpotLightCards.adType)
        //        if self.arrSpotLights.contains(SpotLightCards.adType) {
        //            self.arrSpotLights.removeLast()
        //            self.arrSpotLights = arrSpotLights.sorted { getTemplateTypeAndPriority(card: $0).priority < getTemplateTypeAndPriority(card: $1).priority }
        //        }
    }
    // MARK: - Priority #6
    func configureSpotLightsForThankYou() {
        if self.arrSpotLights.contains(SpotLightCards.thankYou) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.thankYou) {
                self.arrSpotLights.remove(at: index)
            }
        }
        if self.arrSpotLights.contains(SpotLightCards.adType) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.adType) {
                self.arrSpotLights.remove(at: index)
            }
        }
        if self.arrSpotLights.isEmpty {
            self.addCard(card: SpotLightCards.thankYou)
        }
        
        //        if self.arrSpotLights.contains(SpotLightCards.adType) {
        //            self.arrSpotLights.removeLast()
        //            self.arrSpotLights = arrSpotLights.sorted { getTemplateTypeAndPriority(card: $0).priority < getTemplateTypeAndPriority(card: $1).priority }
        //        }
    }
    
    // MARK: - Get Type and priority
    func getTemplateTypeAndPriority(card: SpotLightCards) -> (templateType: SpotLightTemplate, priority: String) {
        let arr = card.rawValue.components(separatedBy: ",")
        let cardPriority: String = arr[0]
        let cardType = arr[1].trimmingCharacters(in: .whitespaces)
        if cardType == "typeOne" {
            return(templateType: SpotLightTemplate.one, priority: cardPriority)
        } else if cardType == "typeTwo" {
            return(templateType: SpotLightTemplate.two, priority: cardPriority)
        } else if cardType == "typeThree" {
            return(templateType: SpotLightTemplate.three, priority: cardPriority)
        } else if cardType == "typeFour" {
            return(templateType: SpotLightTemplate.four, priority: cardPriority)
        } else if cardType == "outageBlue" {
            return(templateType: SpotLightTemplate.outageFound, priority: cardPriority)
        } else if cardType == "outageWhite" {
            return(templateType: SpotLightTemplate.outageClear, priority: cardPriority)
        }else {
            return(templateType: SpotLightTemplate.one, priority: cardPriority)
        }
    }
    
    // MARK: - Configure Messages
    func getMessageForOfflineExtender() -> String {
        let offlineExtends = MyWifiManager.shared.getOfflineExtenders()
        if offlineExtends.count == 1 {
            let name = WifiConfigValues.getExtenderName(offlineExtNode: offlineExtends.first, onlineExtNode: nil)
            return "Your \(CommonUtility.validateOverflowingText(labelText: NSString(string: name))) Extender is offline"
        } else if offlineExtends.count > 1 {
            return "\(offlineExtends.count) of your Extenders are offline"
        } else {
            return "Your Extender is offline"
        }
    }
    
    func getMessageForWeakExtender() -> String {
        let weakExtends = MyWifiManager.shared.getWeakExtenders()
        if weakExtends.count == 1 {
            let name = WifiConfigValues.getExtenderName(offlineExtNode: weakExtends.first, onlineExtNode: nil)
            return "Your \((CommonUtility.validateOverflowingText(labelText: NSString(string: name)))) Extender has a weak signal"
        } else if weakExtends.count > 1 {
            return "\(weakExtends.count) of your Extenders have a weak signal"
        } else {
            return "Your Extender has a weak signal"
        }
    }
    
    func saveDismissibleCards() {
        if let spCards = spotLightCards, let cards = spCards.cards, !cards.isEmpty {
            let dismissibleCards = cards.filter{$0.dismissible == true && $0.wasViewed == false && $0.wasDismissed == false}
            if !dismissibleCards.isEmpty {
                dismissibleCardsArray = dismissibleCards
            }
        }
    }
    
    //CMAIOS-2591 save LastETR Value of Outage card
    func saveLastETRValueIfExists(){
        if let spCards = spotLightCards, let cards = spCards.cards, !cards.isEmpty {
            let outageCardsWithETR = cards.filter{ ($0.priorityKey == "1.1" || $0.priorityKey == "1.2") && $0.moreInfo?.etr != nil}
            if !outageCardsWithETR.isEmpty ,let moreInfo = outageCardsWithETR[0].moreInfo, let etr = moreInfo.etr, !etr.isEmpty {
                PreferenceHandler.saveValue(etr, forKey: "lastETR")
            }
        }
    }
    
    func removeDismissedCards(_ spotLightId: String) {
        var dismissedIndex = -1
        if !dismissibleCardsArray.isEmpty, !spotLightId.isEmpty {
            for card in dismissibleCardsArray {
                if card.id == spotLightId {
                    dismissedIndex += 1
                    break
                } else {
                    dismissedIndex += 1
                    continue
                }
            }
            dismissibleCardsArray.remove(at: dismissedIndex)
        }
    }
    
    //CMAIOS-2297: Mapping event from Spotlight API
    func getEventName(card: SpotLightCards) -> String {
        var event = ""
        if let cardPriority = self.getTemplateTypeAndPriority(card: card).priority as String?, !cardPriority.isEmpty {
            if let slCards = self.spotLightCards, let cards = slCards.cards, !cards.isEmpty {
                let filteredCard = cards.filter {$0.priorityKey == cardPriority}
                if !filteredCard.isEmpty {
                    event = filteredCard[0].GAkey ?? ""
                }
            }
        }
        return event
    }
    
    func addParams(cards: [SpotLightCardsGetResponse.CardData], isViewed: Bool) -> NSMutableArray {
        let updatedCards = NSMutableArray()
        for card in cards {
            var params1 = [String: AnyObject]()
            params1["id"] = (card.id ?? "") as AnyObject
            params1["wasDismissed"] = (card.wasDismissed ?? false) as AnyObject
            params1["wasViewed"] = !isViewed ? (card.wasViewed ?? false) as AnyObject : true as AnyObject
            params1["name"] = (card.name ?? "") as AnyObject
            updatedCards.add(params1)
            self.removeDismissedCards(card.id ?? "")
        }
        return updatedCards
    }
    
    func getMessageForNetworkDown() -> String {
        if MyWifiManager.shared.getMyWifiStatus() == .wifiDown {
            //CMAIOS-1427
            return MyWifiManager.shared.networkName == "" ? "Your network is down" : CommonUtility.validateOverflowingText(labelText: NSString(string: MyWifiManager.shared.networkName)) + " network is down"
        } else {
            return "Your network is down"
        }
    }
    // MARK: - Add card
    func addCard(card: SpotLightCards) {
        if self.arrSpotLights.contains(SpotLightCards.thankYou) { //CMAIOS-2642
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.thankYou) {
                self.arrSpotLights.remove(at: index)
            }
            if card == .thankYou { // Do not add thank you card if once suppressed
                return
            }
        }
        
        var spotlights = self.arrSpotLights
        spotlights.append(card)
        arrSpotLights = spotlights.sorted { getTemplateTypeAndPriority(card: $0).priority.compare(getTemplateTypeAndPriority(card: $1).priority) == .orderedAscending }
        if ConfigService.shared.ad_enabled.lowercased() == "true" {
            checkGAdSuppressionRules()
        }
        checkOutageSuppressionRules() //CMAIOS-2867, 2868
        
    }
    
    func suppressOfflineExtenderCard() {
        if self.arrSpotLights.contains(SpotLightCards.offline_extender){
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.offline_extender) {
                self.arrSpotLights.remove(at: index)
            }
        }
    }
    
    func checkOutageSuppressionRules() {
            if self.arrSpotLights.contains(SpotLightCards.outageAreaTemplateTypeOne)
                || self.arrSpotLights.contains(SpotLightCards.outageAreaTemplateTypeTwo) ||
                self.arrSpotLights.contains(SpotLightCards.outageAreaSecondTemplateTypeOne) || self.arrSpotLights.contains(SpotLightCards.outageAreaSecondTemplateTypeOne) {
                    self.removeAllWifiRelatedCards()
                    self.suppressGAdCard()
            }
    }
    
    func checkGAdSuppressionRules() {
//        if GACardRemoved {
//            return
//        }
        // CMA-2817 If only card and GAd card fails.(Do not show thank you card)
        if self.arrSpotLights.contains(SpotLightCards.thankYou) && self.arrSpotLights.count > 1 {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.thankYou) {
                self.arrSpotLights.remove(at: index)
            }
        }
        // CMA-2812 suppression rules for GAd Card
        if self.arrSpotLights.contains(SpotLightCards.offline_extender)
            || self.arrSpotLights.contains(SpotLightCards.network_down) ||
            self.arrSpotLights.contains(SpotLightCards.dead_zones) {
            suppressGAdCard()
        }
    }
    
    func suppressGAdCard() {
        if ConfigService.shared.ad_enabled.lowercased() != "true" {
            return
        }
//        if GACardRemoved {
//            return
//        }
        if self.arrSpotLights.contains(SpotLightCards.adType) {
            if let index = arrSpotLights.firstIndex(of: SpotLightCards.adType) {
                self.arrSpotLights.remove(at: index)
              //  self.GACardRemoved = true
           //     NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "GACardRemoved"),object: nil, userInfo: nil))
            }
        }
    }
    
    //return all OutageCardData based upon service impacted
    func checkIfOutageCardExists(isFromWiFiJumpLink: Bool = true)-> (Bool,SpotLightCardsGetResponse.CardData?)  {
        let serviceKeyImpacted = isFromWiFiJumpLink ? "Internet" : "TV"
        
        //Check if there is any Outage SP card
        if let arrOutageCards = MyWifiManager.shared.checkForOutagesWithSpotLight(serviceKeyImpacted){
            return (true,arrOutageCards)
        }
        return (false, nil)
    }
    
    // MARK: - Clear Data
    func clearData() {
        arrSpotLights = []//(ConfigService.shared.ad_enabled == "true") ? [.adType] : [.thankYou]
        if let spCards = spotLightCards, let cards = spCards.cards, !cards.isEmpty {
            spotLightCards.cards!.removeAll()
        }
        if !dismissibleCardsArray.isEmpty {
            dismissibleCardsArray.removeAll()
        }
      //  self.GACardRemoved = false
    }
    
    func mapSpotlightImage(_ responseImage: String) -> String {
        var imageName = ""
        switch responseImage {
        case "payment_paid":
            imageName = "Bill-Paid"
        case "payment_schedule":
            imageName = "Bill-Schedule"
        case "alert_white":
            if CurrentDevice.forLargeSpotlights() {
                imageName = "SpotLightErrorWhiteForLarge"
            } else {
                imageName = "SpotLightErrorWhiteForSmall"
            }
        case "bill_ready":
            imageName = "Bill"
        case "bill_ready_enrolled_autopay":
            imageName = "Bill-Autopay"
        case "None":
            imageName = ""
        case "auto_pay_set":
            if CurrentDevice.forLargeSpotlights() {
                imageName = "AutoPayforLarge"
            } else {
                imageName = "AutoPay"
            }
        case "alert_red":
            if CurrentDevice.forLargeSpotlights() {
                imageName = "SpotLightErrorRedForLarge"
            } else {
                imageName = "SpotLightErrorRedForSmall"
            }
        case "billing_unavailable":
            imageName = "billingdownspt"
        case "map_with_pin": //CMAIOS-2591
            imageName = "outageInfo"
        case "map_with_tick":
            imageName = "OutageSuccess"
        case "billing_piggy_discount":
            imageName = "BillingPiggyDiscount"
        default:
            break
        }
        return imageName
    }
    
    //CMAIOS-2680
    func updateDismissStatus() {
        let updatedCards = NSMutableArray()
        if let spCards = SpotLightsManager.shared.spotLightCards, let cards = spCards.cards, !cards.isEmpty {
            if let filteredCards = SpotLightsManager.shared.spotLightCards.cards?.filter({$0.id?.contains("billingDiscount") ?? false}) {
                for card in filteredCards {
                    if let index = SpotLightsManager.shared.spotLightCards.cards?.firstIndex(where: {$0.id == card.id
                        && $0.wasDismissed == false}) {
                        SpotLightsManager.shared.spotLightCards.cards?[index].wasDismissed = true
                        if let indexedCard = SpotLightsManager.shared.spotLightCards.cards?[index] {
                            updatedCards.add(SpotLightsManager.shared.addParams(cards: [indexedCard], isViewed: false))
                        }
                    }
                }
            }
        }
        if updatedCards.count > 0 {
            self.updateDimissStatusToRemote(cards: updatedCards)
        }
    }
    
    //CMAIOS-2680
    func updateDimissStatusToRemote(cards: NSMutableArray) {
        var params = [String: AnyObject]()
        params["cards"] = cards as AnyObject
        APIRequests.shared.mauiUpdateSpotLightCards(params: params) { success, value, error in
            if success {
                //CMAIOS-2680
                APIRequests.shared.mauiGetSpotLightCards(completionHandler: { success, value, error in
                })
            }
        }
    }
    
}
