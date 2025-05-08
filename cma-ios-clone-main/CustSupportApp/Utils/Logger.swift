//
//  Logger.swift
//  CustSupportApp
//
//  Created by vsamikeri on 5/18/22.
//


/*!
 
 @desc      The Logger is used to log several levels and to give the ability to
            debug the logs more effectively.
 
 @usage     Logger.info("View is loaded")
            Logger.warning("Directory not found for the file")
            Logger.error("Command CodeSign failed with a nonzero exit code")
 */

import Foundation
import Firebase

enum Logger {
    
    struct Condition {
        let file: String
        let function: String
        let line: Int
        var description: String {
            return ("\((file as NSString).lastPathComponent):\(line) \(function)")
        }
    }
    enum logLevels {
        case info
        case warning
        case error
        
        fileprivate var prefix: String {
            switch self {
            case .info:
                return "INFO ℹ️"
            case .warning:
                return "Warning ⚠️"
            case .error:
                return "Alert ❌"
            }
        }
    }
    static func info(_ str: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line, sendLog: String = "") {
        let context = Condition(file: file, function: function, line: line)
        Logger.handleLog(level: .info, str: str.description, shouldLogContext: shouldLogContext, context: context, sendLog: sendLog)
    }
    
    static func warning(_ str: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Condition(file: file, function: function, line: line)
        Logger.handleLog(level: .warning, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func error(_ str: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Condition(file: file, function: function, line: line)
        Logger.handleLog(level: .error, str: str.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    
    fileprivate static func handleLog(level: logLevels, str: String, shouldLogContext: Bool, context: Condition, sendLog: String = "") {
        let logComponents = ["[\(level.prefix)] ", str]
        var logString = ""
        if shouldLogContext {
            logString = " ⇒ \(context.description) - " + logComponents.joined(separator: "")
        }
        let logTimeStamp = getTimeStamp()
    
        #if DEBUG
        print(logTimeStamp + logString)
#endif
        let sendData = !(sendLog.isEmpty) ? sendLog : str
        Crashlytics.crashlytics().log(sendData)
    }
    
    /// - Returns: A formatted string with the current time stamp.
    
    fileprivate static func getTimeStamp() -> String {
        
        let dateFormatter = DateFormatter()
        let en_US_POSIX:Locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.locale = en_US_POSIX
        let timeStamp = dateFormatter.string(from: Date())
        return timeStamp
    }
}
