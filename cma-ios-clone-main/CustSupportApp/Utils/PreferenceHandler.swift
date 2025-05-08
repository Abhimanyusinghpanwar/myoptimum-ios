//
//  PreferenceHandler.swift
//  LaBoxApp
//
//  Created by Cablevision on 29/09/16.
//  Copyright © 2016 Altice USA. All rights reserved.
//

import Foundation

open class PreferenceHandler {
/**
	Always use the class name as the file name and start the name with a capital letter.
	Changes Done : Changed the class name from userDefault to file name PreferenceHandler
*/
    class func saveValue(_ value: Any, forKey key: String){
        let userDefault = UserDefaults.standard
        userDefault.set(value, forKey: key)
         userDefault.synchronize()
    }
    
    class func getValuesForKey(_ key : String?) -> AnyObject? {
        let userDefault = UserDefaults.standard
        if key != nil  {
            if let value = userDefault.object(forKey: key!) {
                return value as AnyObject?
            }
           return nil
        }
        return nil
    }
    
    class func removeDataForKey(_ key: String?){
        let userDefault = UserDefaults.standard
        if key != nil{
          userDefault.removeObject(forKey: key!)
        }
    }
    
    // MARK: - Settings Whats New Specific Keys
    
    class func saveValueForWhatsNew(_ value: Any, forKey key: String){
        let userDefault = UserDefaults.standard
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false) {
           userDefault.set(encodedData, forKey: key)
           userDefault.synchronize()
        }
    }
    
    // MARK: - Removing Zip and folders as well of icons
    class func removeCacheZipIcons() {
        let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        do {
            if let documentPath = documentsPath {
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: "\(documentPath)")
                Logger.info("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    if (fileName.hasSuffix(".zip")){
                        let filePathName = "\(documentPath)/\(fileName)"
                        try FileManager.default.removeItem(atPath: filePathName)
                    }
                    if fileName == "white" || fileName == "gray" {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try FileManager.default.removeItem(atPath: filePathName)
                    }
                }
                let files = try FileManager.default.contentsOfDirectory(atPath: "\(documentPath)")
                Logger.info("all files in cache after deleting images: \(files)")
            }
        } catch {
            Logger.info("Could not clear temp folder: \(error)")
        }
    }
    
    class func checkAndDeleteAnyPNGIcons() {
         let destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("white")
         getAllImagesURL(destURL: destinationURL)
         func getAllImagesURL(destURL: URL?) {
             do {
                 let directoryContents = try FileManager.default.contentsOfDirectory(at: destURL!, includingPropertiesForKeys: nil, options: [])
                 let allImagesWhiteURL = directoryContents.filter{ $0.pathExtension == "png" }
                 if let firstImage = allImagesWhiteURL.first {
                     if firstImage.description.contains("png") {
                         PreferenceHandler.removeCacheZipIcons()
                         Logger.info("Deleted old png images")
                     }
                 }
             } catch {
                 Logger.info("No old png found to delete")
             }
         }
     }
    
    class func getWhatsNewValuesForKey(_ key : String?) -> AnyObject? {
        let userDefault = UserDefaults.standard
        if key != nil  {
            if let value = userDefault.object(forKey: key!), let decodedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData((value as? Data)!) {
                return decodedData as AnyObject?
            }
            return nil
        }
        return nil
    }
    
    // MARK: - Brand Specific Keys
//    class func saveBrandSpecificValue(_ value: AnyObject, forKey key: String){
//        let userDefault = UserDefaults.standard
//        let brandSpecificKey = key + App.getBrandInfo().capitalized
//        userDefault.set(value, forKey: brandSpecificKey)
//        userDefault.synchronize()
//    }
//
//    class func getBrandSpecificValueForKey(_ key : String?) -> AnyObject? {
//        let userDefault = UserDefaults.standard
//        if let keyString = key {
//            let brandSpecificKey = keyString + App.getBrandInfo().capitalized
//            if let value = userDefault.object(forKey: brandSpecificKey) {
//                return value as AnyObject?
//            }
//            return nil
//        }
//        return nil
//    }
//    class func removeBrandSpecificDataForKey(_ key: String?){
//        Logger.sharedInstance.dLog("")
//        let userDefault = UserDefaults.standard
//        if let keyString = key {
//            let brandSpecificKey = keyString + App.getBrandInfo().capitalized
//            userDefault.removeObject(forKey: brandSpecificKey)
//        }
//    }
    
    class func removeAllUserdefaultsData() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
//    class func removeUserdefaultsOnAppLaunch() {
//        PreferenceHandler.removeDataForKey("appBackgroundDate")
//        PreferenceHandler.removeDataForKey("pc_BackgroundDate")
//    }
}
