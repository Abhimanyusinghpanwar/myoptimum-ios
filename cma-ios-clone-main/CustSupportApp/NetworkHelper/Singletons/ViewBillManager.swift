//
//  File.swift
//  CustSupportApp
//
//  Created by Raju Ramalingam on 29/09/23.
//

import Foundation

class ViewBillManager {
    class var shared: ViewBillManager {
        struct Singleton {
            static let instance = ViewBillManager()
        }
        return Singleton.instance
    }
    
    func removePdfFiles() {
        let pathComponenetName = "PDFList"
        if let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first as? NSURL {
            if let documentsPath = documentsUrl.appendingPathComponent(pathComponenetName),
               FileManager.default.fileExists(atPath: documentsPath.path) {
                do {
                    try? FileManager.default.removeItem(at: documentsPath)
                    Logger.info("PDF folder deleted")
                } catch {
                    Logger.info("Error deleting downloaded PDF: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func removePdfFileAtPath(pathComponent: String, isBillInsert: Bool) {
        if let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first as? NSURL {
            if let documentsPath = documentsUrl.appendingPathComponent(pathComponent),
               FileManager.default.fileExists(atPath: documentsPath.path) {
                do {
                    try? FileManager.default.removeItem(at: documentsPath)
                    Logger.info("PDF folder deleted")
                } catch {
                    Logger.info("Error deleting downloaded PDF: \(error.localizedDescription)")
                }
            }
        }
    }
}





