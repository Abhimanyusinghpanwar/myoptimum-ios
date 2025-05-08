//
//  LiveTopologyResponseModel.swift
//  CustSupportApp
//
//  Created by sriram_rajagopalan01 on 09/09/22.
//

import Foundation

// MARK: - LightSpeed API Response
struct LightSpeedAPIResponse: Decodable {
    
    var extender_status: extender_status?
    var links: [Links]?
    var nodes: [Nodes]?
    var rec_disconn: [rec_disconn]?
    
    init(extender_status: extender_status?, links: [Links]?, nodes: [Nodes]?, rec_disconn: [rec_disconn]?) {
        self.extender_status = extender_status
        self.links = links
        self.nodes = nodes
        self.rec_disconn = rec_disconn
    }
    
   enum CodingKeys: String, CodingKey {
     case extender_status, links, nodes, rec_disconn
   }
    
    struct extender_status: Decodable {
        var on_account: Int?
        var online: Int?
        var nodes: [Nodes]?
        
        init(on_account: Int, online: Int, nodes: [Nodes]) {
            self.on_account = on_account
            self.online = online
            self.nodes = nodes
        }
        
        enum CodingKeys: String, CodingKey {
            case on_account, online, nodes
        }
        
        struct Nodes: Decodable {
            var device_mac: String?
            var found_on_account: String?
            var placement: String?
            var status: String?
            var friendly_name: String?
            var cma_display_name: String?
            var cma_equipment_type_display: String?
            var cma_equipment_type: String?
            var conn_type:String?
            var hostname: String?
            var cma_category: String?
            var band: String?
            
            init(device_mac: String?, found_on_account: String?, placement: String?, status: String?, friendly_name:String?, hostname:String?, cma_display_name:String?, cma_equipment_type_display:String?, cma_equipment_type:String?, conn_type:String?, cma_category: String?, band: String?) {
                self.device_mac = device_mac
                self.found_on_account = found_on_account
                self.placement = placement
                self.status = status
                self.friendly_name = friendly_name
                self.hostname = hostname
                self.cma_display_name = cma_display_name
                self.cma_equipment_type_display = cma_equipment_type_display
                self.cma_equipment_type = cma_equipment_type
                self.conn_type = conn_type
                self.cma_category = cma_category
                self.band = band
            }
            
            enum CodingKeys: String, CodingKey {
                case device_mac, found_on_account, placement, status, friendly_name, hostname, cma_display_name, cma_equipment_type_display, cma_equipment_type, conn_type, cma_category, band
            }
        }
    }
    
    struct Links: Decodable {
        var rssi_level: Double?
        var idle: String?
        var source: String?
        var target: String?
        var target_type: String?
        
        init(rssi_level: Double?, source: String?, target: String?, target_type: String?, idle: String?) {
            self.rssi_level = rssi_level
            self.source = source
            self.target = target
            self.target_type = target_type
            self.idle = idle
        }
        
        enum CodingKeys: String, CodingKey {
            case rssi_level, source, target, target_type, idle
        }
    }
    
    struct Nodes: Decodable {
        var band: String?
        var cca_2g: String?
        var cca_5g: String?
        var cma_category: String?
        var cma_dev_type: String?
        var color: String?
        var device_type: String?
        var friendly_name: String?
        var hostname: String?
        var ip: String?
        var isMaster: String?
        var location: String?
        var mac: String?
        var pid: Int?
        var profile: String?
        var serial: String?
        var status: String?
        var vendor: String?
        var conn_type: String?
        var dualBand: String?
        var interface: String?
//        var mimo: String?
        var cma_equipment_type: String?
        var cma_display_name: String?
        var cma_equipment_type_display: String?
        
        init(band: String?, cca_2g: String?, cca_5g: String?, cma_category: String?, cma_dev_type: String?, color: String?, device_type: String?, friendly_name: String?, hostname: String?, ip: String?, isMaster: String?, location: String?, mac: String?, pid: Int?, profile: String?, serial: String?, status: String?, vendor: String?, conn_type: String?, dualBand: String?, interface: String?, cma_equipment_type:String?, cma_display_name:String?, cma_equipment_type_display:String?) {
            self.band = band
            self.cca_2g = cca_2g
            self.cca_5g = cca_5g
            self.cma_category = cma_category
            self.cma_dev_type = cma_dev_type
            self.color = color
            self.device_type = device_type
            self.friendly_name = friendly_name
            self.hostname = hostname
            self.ip = ip
            self.isMaster = isMaster
            self.location = location
            self.mac = mac
            self.pid = pid
            self.profile = profile
            self.serial = serial
            self.status = status
            self.vendor = vendor
            self.conn_type = conn_type
            self.dualBand = dualBand
            self.interface = interface
//            self.mimo = mimo
            self.cma_equipment_type = cma_equipment_type
            self.cma_display_name = cma_display_name
            self.cma_equipment_type_display = cma_equipment_type_display
        }
        
        enum CodingKeys: String, CodingKey {
            case band, cca_2g, cca_5g, cma_category, cma_dev_type, color, device_type, friendly_name, hostname, ip, isMaster, location, mac, pid, profile, serial, status, vendor, conn_type, dualBand, interface, cma_equipment_type, cma_display_name, cma_equipment_type_display
        }
    }
    
    struct rec_disconn: Decodable {
        var cma_display_name: String?
        var cma_category: String?
        var cma_dev_type: String?
        var color: String?
        var friendly_name: String?
        var hostname: String?
        var interface: String?
        var ip: String?
        var location: String?
        var mac: String?
        var pid: Int?
        var profile: String?
        var rec_disconn: String?
        var rec_disconn_time: String?
        var rtime: Int?
        var timestamp: Int?
        var visited: Bool?
        
        init(cma_category: String?, cma_dev_type: String?, color:String?, friendly_name:String?, hostname: String?, interface: String?, ip: String?, location: String?, mac: String?, pid: Int?, profile: String?, rec_disconn: String?, rtime: Int?, timestamp: Int?, visited: Bool?, cma_display_name:String?, rec_disconn_time: String?) {
            self.cma_category = cma_category
            self.cma_dev_type = cma_dev_type
            self.color = color
            self.friendly_name = friendly_name
            self.hostname = hostname
            self.interface = interface
            self.ip = ip
            self.location = location
            self.mac = mac
            self.pid = pid
            self.profile = profile
            self.rec_disconn = rec_disconn
            self.rtime = rtime
            self.timestamp = timestamp
            self.visited = visited
            self.cma_display_name = cma_display_name
            self.rec_disconn_time = rec_disconn_time
        }
        enum CodingKeys: String, CodingKey {
            case cma_category, cma_dev_type, color, friendly_name, hostname, interface, ip, location, mac, pid, profile, rec_disconn, rtime, timestamp, visited, cma_display_name, rec_disconn_time
        }
    }
}

struct SetWLanResponse: Decodable {
    
}
struct MapCPEInforResponse: Decodable {
    var macaddress: String?
    var serialnumber: String?
    
    init(macaddress:String?, serialnumber:String?) {
        self.macaddress = macaddress
        self.serialnumber = serialnumber
    }
    
    enum CodingKeys: String, CodingKey {
        case macaddress
        case serialnumber
    }
}
struct ClientUsageResponse: Decodable {
        
    var clients: [Client]?
    var desc:String?
    var error:Int?
    
    init(clients: [Client]?, desc:String?, error:Int?) {
        self.clients = clients
        self.desc = desc
        self.error = error
    }
    
    enum CodingKeys: String, CodingKey {
        case clients
        case desc
        case error
    }
    
    struct Client: Decodable {
        
        var connected_time: Int?
        var downlink_throughput_average: Int?
        var mac: String?
        var uplink_throughput_average: Int?
        
        init(connected_time: Int?,downlink_throughput_average: Int?,mac: String?,uplink_throughput_average: Int?) {
            self.connected_time = connected_time
            self.downlink_throughput_average = downlink_throughput_average
            self.mac = mac
            self.uplink_throughput_average = uplink_throughput_average
        }
        
        enum CodingKeys: String, CodingKey {
            case connected_time, downlink_throughput_average, mac, uplink_throughput_average
        }
    }
}
