//
//  DeadZoneResponseModel.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 07/02/23.
//

import Foundation

struct DeadZoneAPIResponse: Decodable {
    var ap_utilization : [utilization]?
    var client_qoe : [utilization]?
    var home_qoe : [utilization]?
    
    init(ap_utilization: [utilization]?, client_qoe : [utilization]?, home_qoe : [utilization]?) {
        self.ap_utilization = ap_utilization
        self.client_qoe = client_qoe
        self.home_qoe = home_qoe
    }
    
    struct utilization: Decodable {
        var ap_mac: String?
        var avg_rssi2g: Double?
        var avg_rssi5g: Double?
        var mac: String?
        var max_rssi2g: Double?
        var max_rssi5g: Double?
        var min_rssi2g: Double?
        var min_rssi5g: Double?
        var n_id: String?
        var n_serialno: String?
        var percent_2g: Double?
        var percent_5g: Double?
        var qoe_score: Double?
        var rxmb_2g: Double?
        var rxmb_5g: Double?
        var rxmb_total: Double?
        var srv_mac: String?
        var time_2g: Double?
        var time_5g: Double?
        var timebr0: Double?
        var timebr1: Double?
        var timebr2: Double?
        var timebr3: Double?
        var txmb_2g: Double?
        var txmb_5g: Double?
        var txmb_total: Double?
        
        init(ap_mac: String?, avg_rssi2g: Double?, avg_rssi5g: Double?, mac: String?, max_rssi2g: Double?,  max_rssi5g: Double?,  min_rssi2g: Double?, min_rssi5g: Double?,  n_id: String?,  n_serialno: String?,  percent_2g: Double?,  percent_5g: Double?,  qoe_score: Double?,  rxmb_2g: Double?,  rxmb_5g: Double?,  rxmb_total: Double?, srv_mac: String?, time_2g: Double?,  time_5g: Double?,  timebr0: Double?, timebr1: Double?,  timebr2: Double?,  timebr3: Double?,  txmb_2g: Double?,  txmb_5g: Double?,  txmb_total: Double?) {
            self.ap_mac = ap_mac
            self.avg_rssi2g = avg_rssi2g
            self.avg_rssi5g = avg_rssi5g
            self.mac = mac
            self.max_rssi2g = max_rssi2g
            self.max_rssi5g = max_rssi5g
            self.min_rssi2g = min_rssi2g
            self.min_rssi5g = min_rssi5g
            self.n_id = n_id
            self.n_serialno = n_serialno
            self.percent_2g = percent_2g
            self.percent_5g = percent_5g
            self.qoe_score = qoe_score
            self.rxmb_2g = rxmb_2g
            self.rxmb_5g = rxmb_5g
            self.rxmb_total = rxmb_total
            self.srv_mac = srv_mac
            self.time_2g = time_2g
            self.time_5g = time_5g
            self.timebr0 = timebr0
            self.timebr1 = timebr1
            self.timebr2 = timebr2
            self.timebr3 = timebr3
            self.txmb_2g = txmb_2g
            self.txmb_5g = txmb_5g
            self.txmb_total = txmb_total
        }
    }
}
