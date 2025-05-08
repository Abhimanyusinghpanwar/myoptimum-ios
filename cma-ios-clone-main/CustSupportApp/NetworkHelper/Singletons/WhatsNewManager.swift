//
//  WhatsNewManager.swift
//  CustSupportApp
//
//  Created by Sriram_rajagopalan01 on 05/10/23.
//

import Foundation
import Alamofire

class WhatsNewManager {
    var whatsNewImageJsonName:String = ""
    class var shared: WhatsNewManager {
        struct Singleton {
            static let instance = WhatsNewManager()
        }
        return Singleton.instance
    }
    
    func getSetNumber() -> String {
        if let whatsNew = ConfigService.shared.whats_new as String?, !whatsNew.isEmpty, let whatsNewData = whatsNew.data(using: String.Encoding.utf8), !whatsNewData.isEmpty, let whatsNewDict =  try? JSONSerialization.jsonObject(with: whatsNewData) as? NSDictionary, !whatsNewDict.allKeys.isEmpty, let setNumber = whatsNewDict.value(forKey: "set") as? String, !setNumber.isEmpty {
            return setNumber
        }
        return ""
    }
    
    func getFeaturesArray() -> NSMutableArray {
        let featureDataArray = NSMutableArray()
        if let whatsNew = ConfigService.shared.whats_new as String?, !whatsNew.isEmpty, let whatsNewData = whatsNew.data(using: String.Encoding.utf8), !whatsNewData.isEmpty, let whatsNewDict =  try? JSONSerialization.jsonObject(with: whatsNewData) as? NSDictionary, !whatsNewDict.allKeys.isEmpty, let features = whatsNewDict.value(forKey: "features") as? NSArray, features.count > 0 {
            featureDataArray.addObjects(from: features as! [Any])
        }
        return featureDataArray
    }
    
    func getFeatureIDs() -> NSMutableArray {
        let featureArray = getFeaturesArray()
        let contentArray = NSMutableArray()
        for index in 0..<featureArray.count {
            if let feature = featureArray[index] as? NSDictionary {
                if let content = feature.value(forKey: "id") as? Int {
                    contentArray.add(content)
                    if index == featureArray.count - 1 {
                        break
                    }
                } else {
                    continue
                }
            } else {
                continue
            }
        }
        return contentArray
    }
    
    func getFeatureImageData(_ featureId: Int) -> String {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let content = (featureArray.first as! NSDictionary).value(forKey: "image") as! String
            return content
        }
        return ""
    }
    
    func getFeatureContentData(_ featureId: Int) -> String {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let content = (featureArray.first as! NSDictionary).value(forKey: "content") as! String
            return content
        }
        return ""
    }
    
    func getFeatureHeadlineData(_ featureId: Int) -> String {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let content = (featureArray.first as! NSDictionary).value(forKey: "headline") as! String
            return content
        }
        return ""
    }

    func getFeatureIntroData(_ featureId: Int) -> String {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let content = (featureArray.first as! NSDictionary).value(forKey: "intro") as! String
            return content
        }
        return ""
    }
    
    func getLoopAnimation(_ featureId: Int) -> Bool {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let value = (featureArray.first as! NSDictionary).value(forKey: "loopAnimation") as! Bool
            return value
        }
        return false
    }

    func getFeatureBulletsData(_ featureId: Int) -> [String] {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let content = (featureArray.first as! NSDictionary).value(forKey: "bullets") as! [String]
            return content
        }
        return [""]
    }

    func getFeatureOutroData(_ featureId: Int) -> String {
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let content = (featureArray.first as! NSDictionary).value(forKey: "outro") as! String
            return content
        }
        return ""
    }
    
    func getFeatureButtons(_ featureId: Int) -> NSMutableArray {
        let buttonArray = NSMutableArray()
        let featureArray = getFeaturesArray().filter {(($0 as! NSDictionary).value(forKey: "id") as! Int) == featureId }
        if featureArray.count > 0 {
            let buttons = (featureArray.first as! NSDictionary).value(forKey: "buttons") as! NSArray
                buttonArray.addObjects(from: buttons as! [Any])
            return buttonArray
        }
        return NSMutableArray()
    }
    
    func getFeatureContent(_ featureKey: String) -> NSMutableArray {
        let featureArray = getFeaturesArray()
        let contentArray = NSMutableArray()
        for index in 0..<featureArray.count {
            if let feature = featureArray[index] as? NSDictionary {
                if let content = feature.value(forKey: featureKey) as? String {
                    contentArray.add(content)
                    if index == featureArray.count - 1 {
                        break
                    }
                } else {
                    continue
                }
            } else {
                continue
            }
        }
        return contentArray
    }
    
    func getWhatsNewButtons() -> NSMutableArray {
        let buttonArray = NSMutableArray()
        let featureArray = getFeaturesArray()
        for index in 0..<featureArray.count {
            if let feature = featureArray[index] as? NSDictionary {
                if let buttons = feature.value(forKey: "buttons") as? NSArray, buttons.count > 0 {
                    buttonArray.addObjects(from: buttons as! [Any])
                    if index == featureArray.count - 1 {
                        break
                    }
                } else {
                    continue
                }
            } else {
                continue
            }
        }
        return buttonArray
    }
    
    // MARK: - Download JSON and SVG Image for Whats New Screen
    func downloadJsonwhatsNew(completionHandler: @escaping (_ success: Bool, _ error: AFError?) -> Void) {
        if let featureID = getFeatureIDs().firstObject as? Int, let urlString = getFeatureImageData(featureID) as String? {
            if let url = URL(string: urlString) {
                let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let fileName = url.lastPathComponent
                whatsNewImageJsonName = fileName
                let fileURL = cacheDirectory.appendingPathComponent(fileName)
                let destination: DownloadRequest.Destination = { _, _ in
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                
                AF.download(url, to: destination)
                    .response { response in
                        switch response.result {
                        case .success:
                            // JSON download and storage succeeded
                            if let data = try? Data(contentsOf: fileURL), (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) != nil {
                                // Process the JSON data here
                            }
                            completionHandler(true, nil)
                        case .failure(let error):
                            completionHandler(false, error)
                        }
                    }
            } else {
                completionHandler(false, nil)
                Logger.info("Invalid URL:  \(urlString)")
            }
        } else{
            completionHandler(false, nil)
        }
    }
    
    func getJsonAndSvgPathWhatsNewScreen(fileName: String) -> String {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let jsonFileURL = cacheDirectory.appendingPathComponent(fileName)
        return jsonFileURL.path
    }
}
