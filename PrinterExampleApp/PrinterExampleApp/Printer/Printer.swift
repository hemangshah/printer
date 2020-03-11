//
//  Printer.swift
//
//
//  Created by Hemang Shah on 4/26/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import Foundation
import UIKit.UIApplication

public let notificationPrinterLogAdded = "notificationPrinterLogAdded"

//MARK:  Enumurations
///Different log cases available for print. You can use it with LogType.success or .success
public enum LogType {
    case success
    case error
    case warning
    case information
    case alert
    case plain
}

//MARK:  TraceInfo
public final class TraceInfo {
    
    fileprivate(set) public var fileName: String
    fileprivate(set) public var functionName: String
    fileprivate(set) public var lineNumber: Int
    
    fileprivate init(file fileName: String, function functionName: String, line lineNumber: Int) {
        self.fileName = fileName
        self.functionName = functionName
        self.lineNumber = lineNumber
    }
}

//MARK:  PLog
public final class PLog {
    
    public var id: String
    public var details: String
    public var logType: LogType
    public var time: String
    public var traceInfo: TraceInfo
    
    fileprivate(set) public var printableLog: String //This will store the final log.
    fileprivate(set) public var printableTrace: String //This will store the final trace log.
    
    fileprivate init(id: String, details: String, time: String, logType lType: LogType, file fileName: String, function functionName: String, line lineNumber: Int) {
        self.id = id
        self.details = details
        self.time = time
        self.logType = lType
        self.traceInfo = TraceInfo.init(file:  fileName, function:  functionName, line:  lineNumber)
        self.printableLog = ""
        self.printableTrace = ""
    }
}

//MARK:  Printer
public final class Printer {

    //You can always change the Emojis here but it's not suggestible.
    //So if you want to change Emojis or everything please use the respective properties.
    fileprivate enum Emojis: String {
        case success = "✅"
        case error = "❌"
        case warning = "🚧"
        case information = "📣"
        case alert = "🚨"
        case watch = "⌚"
        case id = "🆔"
    }
    
    //You can always change the Symbols here but it's not suggestible.
    //So if you want to change Symbols or everything please use the respective properties.
    fileprivate enum Symbols: String {
        case arrow = "➞"
        case star = "✹"
    }
    
    //You can always change the Titles here but it's not suggestible.
    //So if you want to change Titles or everything please use the respective properties.
    fileprivate enum Titles: String {
        case success = "Success"
        case error = "Error"
        case warning = "Warning"
        case information = "Information"
        case alert = "Alert"
    }
    
    //MARK:  Singleton
    ///Always use a Singleton to use the Printer globally with the defined settings/properties.
    public static let log = Printer()
    
    //Please always use the single ton method to use this class.
    fileprivate init() {}
    
    //MARK:  Properties
    ///Don't like emojis and formation? Set this to 'true' and it will print the plain text. DEFAULT:  false
    ///You can also use show with log type:  .plain to print a plain log. This is helpful when you only want to print few plain logs.
    public var plainLog: Bool = false
    ///To add a line after each logs. DEFAULT:  false
    public var addLineAfterEachPrint: Bool = false
    ///Capitalize the titles. DEFAULT:  false
    public var capitalizeTitles: Bool = false
    ///Capitalize the Details. DEFAULT:  false
    public var capitalizeDetails: Bool = false
    ///To print logs only when app is in development. DEFAULT:  true
    public var printOnlyIfDebugMode: Bool = true
    ///To hide time from the logs. DEFAULT:   false
    public var hideLogsTime:  Bool = false
    ///To disable all the logs. You can set this anywhere and it should not print logs from where it sets. DEFAULT:   false
    public var disable:  Bool = false
    ///To keep track of all the logs. To print all the logs later. This will be ignore if 'disable' is set to 'true'.
    public var keepTracking:  Bool = false
    ///To keep tracing with all the logs. No need to call trace() separately if this is set to 'true'. DEFAULT:   true
    public var keepAutoTracing:  Bool = true
    ///To get a completion block for the Printer.
    ///This will call even if any filters applied so you will always notified about the log events.
    public var onLogCompletion: ((_ printLog: String,_ fileName: String,_ functionName: String,_ lineNumber: Int) -> ())? = nil
    
    //This is to store skipped files.
    fileprivate var filterFiles: Array = Array<String>()
    //This is to store all the logs for later use.
    fileprivate var arrayLogs = Array<PLog>()
    //This is to store keepAutoTracing value. For Enable/Disable tracing for sometime.
    fileprivate var tKeepAutoTracing: Bool?
    
    //MARK:  Helpers to set custom date format for each logs
    ///By default, we will use the below date format to show with each logs. You can always customize it with it's property.
    fileprivate var _logDateFormat: String = "MM-dd-yyyy HH: mm: ss"
    public var logDateFormat: String {
        get {
            return _logDateFormat
        }
        set (newValue) {
            if !newValue.isEmpty {
                _logDateFormat = newValue
            }
        }
    }
    
    //MARK:  Block Completion
    //This is an internal function to notify a user with completion block.
    fileprivate func printerCompletion(printLog: String, fileName: String, functionName:  String, lineNumber: Int) -> Void {
        let isPrivateLog = (fileName == #file)
        if !isPrivateLog {
            onLogCompletion?(printLog, getFileName(name:  fileName), functionName, lineNumber)
        }
    }
    
    //MARK:  Filter for Logs. [Files]
    ///This will add current file to Skip list. And you will not able to print a log from that file until you call `addFile()`.
    public func skipFile(filename: String = #file) -> Void {
        if !self.checkIfFileFilterExist(file:  filename) {
            self.filterFiles.append(filename)
        }
    }
    
    ///This will remove current file from Skip list. And you will able to print a log from the current file.
    public func addFile(filename: String = #file) -> Void {
        if self.checkIfFileFilterExist(file:  filename) {
            if let index = self.filterFiles.firstIndex(of:  filename) {
                self.filterFiles.remove(at:  index)
            }
        }
    }
    
    //This is to check whether File filter is applied or not.
    fileprivate func isFileFilterApplied() -> Bool {
        return !self.filterFiles.isEmpty
    }
    
    //This is to check whether a File filter is already applied or not.
    fileprivate func checkIfFileFilterExist(file: String) -> Bool {
        guard self.filterFiles.contains(file) else {
            return false
        }
        return true
    }
    
    //MARK:  Filter for Logs. [LogType]
    fileprivate var _filterLogs: Array = Array<LogType>()
    ///To logs only specific type. Please return an Array<LogType>.
    ///Printer.log.filterLogs = [.success, .alert]
    public var filterLogs: Array<LogType> {
        get {
            return _filterLogs
        }
        set (newArray) {
            _filterLogs.removeAll()
            _filterLogs.append(contentsOf:  newArray)
        }
    }
    
    //This is to check whether Log filter is applied or not.
    fileprivate func isLogTypeFilterApplied() -> Bool {
        return !self.filterLogs.isEmpty
    }
    
    //This is to check whether a Log filter is already applied or not.
    fileprivate func checkIfFilterExist(logType: LogType) -> Bool {
        if self.filterLogs.contains(logType) {
            return true
        }
        return false
    }
    
    //MARK:  Handling of Log Files
    ///This is to save the log file. Need to pass Array having PLog objects.
    public func saveLogsToFile(logs arrayLog: Array<PLog>) -> Void {
        
        if arrayLog.isEmpty {
            self.privateprinter(message:  "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.", logType:  .information)
            return
        }
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            
            //Create a directory:  Printer - to save all the logs inside that folder.
            let logsPath = documentDirectories.appending("/Printer")
            do {
                try FileManager.default.createDirectory(atPath:  logsPath, withIntermediateDirectories:  true, attributes:  nil)
            } catch let error as NSError {
                self.privateprinter(message:  "Unable to create directory \(error.debugDescription)", logType:  .alert)
            }
            
            //Generate a randome file name.
            let documentsFilePath = logsPath + "/" + randomFileName(length:  10) + ".txt"
            
            //Create a String.
            var logString: String = ""
            arrayLog.forEach({ (log) in
                logString += log.printableLog
                if keepTracking {
                    logString += "\n"
                    logString += log.printableTrace
                }
                logString += "\n"
            })
            
            //Additional Info.
            logString += "________________________________________________________________________________________"
            logString += "\n"
            logString += "The log file is generated using Printer • https: //github.com/hemangshah/printer"
            logString += "\n"
            logString += "Time: \(getLogDateForFormat())"
            logString += "\n"
            logString += "________________________________________________________________________________________"
            
            //Save log file.
            do {
                try logString.write(to:  URL.init(fileURLWithPath:  documentsFilePath), atomically:  false, encoding:  String.Encoding.utf8)
                self.privateprinter(message:  "Log file has been saved at following path: \n\t \(documentsFilePath)", logType:  .success)
            } catch {
                self.privateprinter(message:  "Error while saving log file.\(error)", logType:  .alert)
            }
        }
    }
    
    ///This is to delete all the logs created with Printer.
    public func deleteLogFiles() -> Void {
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let logsPath = documentDirectories.appending("/Printer")
            do {
                try FileManager.default.removeItem(atPath:  logsPath)
            } catch let error as NSError {
                self.privateprinter(message:  "Unable to delete directory \(error.debugDescription)", logType:  .alert)
            }
        }
    }
    
    //MARK:  Flush All
    ///To free up things which is created with Printer. Caution:  All logs and log files will be deleted.
    public func flush() -> Void {
        self.arrayLogs.removeAll()
        self.deleteLogFiles()
    }
    
    //MARK:  Handling Background/Foreground Log Events
    public func addAppEventsHandler() -> Void {
        
        self.removeAppEventsHandler()
        
        NotificationCenter.default.addObserver(self, selector:  #selector(appDidEnterBackground), name:  UIApplication.didEnterBackgroundNotification, object:  nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(appWillEnterForeground), name:  UIApplication.willEnterForegroundNotification, object:  nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(appDidBecomeActive), name:  UIApplication.didBecomeActiveNotification, object:  nil)
    }
    
    public func removeAppEventsHandler() -> Void {
        NotificationCenter.default.removeObserver(self, name:  UIApplication.didEnterBackgroundNotification, object:  nil)
        NotificationCenter.default.removeObserver(self, name:  UIApplication.willEnterForegroundNotification, object:  nil)
        NotificationCenter.default.removeObserver(self, name:  UIApplication.didBecomeActiveNotification, object:  nil)
    }
    
    @objc fileprivate func appDidEnterBackground() -> Void {
        self.privateprinter(message:  "App went to Background.", logType:  .information)
    }
    
    @objc fileprivate func appWillEnterForeground() -> Void {
        self.privateprinter(message:  "App will be coming to foreground.", logType:  .information)
    }
    
    @objc fileprivate func appDidBecomeActive() -> Void {
        self.privateprinter(message:  "App is in foreground now.", logType:  .information)
    }
    
    //MARK:  Enable/Disable AutoTracing
    fileprivate func onOffAutoTracing(reverse: Bool) -> Void {
        if reverse {
            self.keepAutoTracing = tKeepAutoTracing!
        } else {
            tKeepAutoTracing = self.keepAutoTracing
            self.keepAutoTracing = false
        }
    }
    
    //MARK:  Private Printer :  to print messages from the Printer class.
    fileprivate func privateprinter(message: String, logType lType: LogType) -> Void {
        self.show(details:  message, logType:  lType)
    }
    
    //To generate random string for file name.
    fileprivate func randomFileName(length:  Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy:  randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    //MARK:  Tracking of logs
    fileprivate func addLogForTracking(log: PLog) -> Void {
        if self.keepTracking {
            self.arrayLogs.append(log)
        }
    }
    
    ///To get all the PLog objects.
    public func getAllLogs() -> Array<PLog> {
        guard self.arrayLogs.count > 0 else {
            self.privateprinter(message:  "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.", logType:  .information)
            return []
        }
        let allLogs = self.arrayLogs
        return allLogs
    }
    
    ///To get all the PLog objects with filter.
    public func getAllLogs(filterLogTypes: Array<LogType>) -> Array<PLog> {
        guard self.arrayLogs.count > 0 else {
            self.privateprinter(message:  "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.", logType:  .information)
            return []
        }
        
        let filteredArray: Array<PLog> = self.arrayLogs.filter() {
            if let type = ($0 as PLog).logType as LogType? {
                return (filterLogTypes.contains(type))
            } else {
                return false
            }
        }
        
        guard filteredArray.count > 0 else {
            self.privateprinter(message:  "No tracked logs for filter. Total tracked logs:  #\(arrayLogs.count)", logType:  .information)
            return []
        }
        
        return filteredArray
    }
    
    ///To print all the tracked logs. 'keepTracking' should be set to 'true' before logging.
    public func all(showTrace: Bool) -> Void {
        guard self.arrayLogs.count > 0 else {
            self.privateprinter(message:  "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.", logType:  .information)
            return
        }
        for log: PLog in self.arrayLogs {
            if log.logType != .plain {
                print("[All Logs] [\(relativeValueForLogType(lType:  log.logType))] [\(log.time)] Id: \(log.id) Details: \(log.details)")
            } else {
                print("[All Logs] [\(log.time)] Id: \(log.id) Details: \(log.details)")
            }
            
            if showTrace {
                let trace = log.traceInfo
                print("[Trace] \(arrowSymbol) \(trace.fileName) \(arrowSymbol) \(trace.functionName) #\(trace.lineNumber)")
            }
        }
        self.addLineWithPrint()
    }
    
    ///To print the tracked logs based on the filter values. 'keepTracking' should be set to 'true' before logging.
    public func all(filterLogTypes: Array<LogType>, showTrace: Bool) -> Void {
        guard self.arrayLogs.count > 0 else {
            self.privateprinter(message:  "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.", logType:  .information)
            return
        }
        
        let filteredArray: Array<PLog> = self.arrayLogs.filter() {
            if let type = ($0 as PLog).logType as LogType? {
                return (filterLogTypes.contains(type))
            } else {
                return false
            }
        }
        
        guard filteredArray.count > 0 else {
            self.privateprinter(message:  "No tracked logs for filter. Total tracked logs:  #\(arrayLogs.count)", logType:  .information)
            return
        }
        
        for log: PLog in filteredArray {
            
            if log.logType != .plain {
                print("[All Logs.filtered] [\(relativeValueForLogType(lType:  log.logType))] [\(log.time)] Id: \(log.id) Details: \(log.details)")
            } else {
                print("[All Logs.filtered] [\(log.time)] Id: \(log.id) Details: \(log.details)")
            }

            if showTrace {
                let trace = log.traceInfo
                print("[Trace] \(arrowSymbol) \(trace.fileName) \(arrowSymbol) \(trace.functionName) #\(trace.lineNumber)")
            }
        }
        self.addLineWithPrint()
    }
    
    //Code Reducing to get a log title.
    fileprivate func relativeValueForLogType(lType: LogType) -> String {
        var logTypeTitle: String = ""
        switch lType {
        case .success:
            logTypeTitle = self.successLogTitle
        case .error:
            logTypeTitle = self.errorLogTitle
        case .warning:
            logTypeTitle = self.warningLogTitle
        case .information:
            logTypeTitle = self.infoLogTitle
        case .alert:
            logTypeTitle = self.alertLogTitle
        case .plain:
            logTypeTitle = ""
        }
        return logTypeTitle
    }
    
    //MARK:  Main function to logs
    
    /**
    **show(id: details: logType)** is the main function to print logs on console. It has various options to print logs when requires. Different available cases includes **Success**, **Error**, **Warning**, **Information** and **Alert**.
     
    - Parameter id:  Any string. A number or some text.
    - Parameter details:  Any string. The description of your logs.
    - Parameter logType:  The type of log you want to print. i.e. LogType.success or .success
     
    # Example:  Print a Success log.
     
     ````
     Printer.log.show(id:  "001", details:  "This is a Success message.", logType:  .success)
     
     Output:
     
     Printer ➞ [✅ SUCCESS] [⌚04-26-2017 16: 39: 39] [🆔 001] ➞ ✹✹This is a Success message.✹✹
     ````
     
     - Returns:  Void
     
     */
    public func show(id: String, details: String, logType lType: LogType, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  id, details:  details, logType:  lType, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    fileprivate func printerlog(id: String, details: String, logType lType: LogType, fileName: String, lineNumber: Int, functionName:  String) -> Void {
        if !self.disable {
            #if DEBUG
                self.printerlogger(id:  id, details:  details, logType:  lType, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
            #else
                if self.printOnlyIfDebugMode {
                    print("Printer can't logs as RELEASE mode is active and you have set 'printOnlyIfDebugMode' to 'true'.")
                } else {
                    self.printerlogger(id:  id, details:  details, logType:  lType, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
                }
            #endif
        }
    }
    
    fileprivate func printerlogger(id: String, details: String, logType lType: LogType, fileName: String, lineNumber: Int, functionName:  String) -> Void {
        //We are forcing completion block to print logs even before any filter checks.
        self.printerCompletion(printLog:  details, fileName:  fileName, functionName:  functionName, lineNumber:  lineNumber)
        
        if self.isLogFilterValidates(logType:  lType, fileName:  fileName) {
            if !self.simple(id:  id, details:  details, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName) {
                self.logForType(id:  id, details:  details, lType:  lType, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
            }
        }
    }
    
    //Right now, we're supporting two types of filters.
    //1. LogType Filter
    //      We can filter the logs based on its type. That's success, alert, warning, information, error.
    //2. File Filter
    //      We can filter the logs based on file. ViewController.self, or simply:  self.
    fileprivate func isLogFilterValidates(logType lType: LogType, fileName: String) -> Bool {
        var isLogTypeFilterSatisfied = true
        var isFileFilterSatisfied = true
        
        if self.isLogTypeFilterApplied() {
            if !self.checkIfFilterExist(logType:  lType) {
                isLogTypeFilterSatisfied = false
            }
        }
        
        if self.isFileFilterApplied() {
            if self.checkIfFileFilterExist(file:  fileName) {
                isFileFilterSatisfied = false
            }
        }
        
        return (isLogTypeFilterSatisfied && isFileFilterSatisfied)
    }
    
    //MARK:  Trace
    ///To print current class name, function name and line number from where trace() called.
    public func trace(fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        if !self.disable {
            #if DEBUG
                self.continueTrace(file:  fileName, line:  lineNumber, function:  functionName)
            #else
                if !printOnlyIfDebugMode {
                    self.continueTrace(file:  fileName, line:  lineNumber, function:  functionName)
                } else {
                    self.privateprinter(message:  "Printer can't trace as RELEASE mode is active and you have set 'printOnlyIfDebugMode' to 'true'.", logType:  .information)
                }
            #endif
        }
    }
    
    fileprivate func continueTrace(file: String, line: Int, function: String) -> Void {
        if self.isLogFilterValidates(logType:  .plain, fileName:  file) {
            let logTime = hideLogsTime ? "" :  "[\(self.getLogDateForFormat())] "
            print("[Trace] \(arrowSymbol) \(logTime)\(self.getFileName(name:  file)) \(self.arrowSymbol) \(function) #\(line)")
            self.addLineWithPrint()
        }
    }
    
    //MARK:  Future Logs
    ///To show a specific log after a certain time [seconds].
    public func showInFuture(id: String, details: String, logType lType: LogType, afterSeconds seconds: Double, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + seconds) {
            self.printerlog(id:  id, details:  details, logType:  lType, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
        }
    }
    
    //MARK:  Overrided **show(id: details: logType)** function to logs without ID parameter input.
    ///If you want to call the main 'show' function without providing ID parameter, you can call this 'show' function with only 'details' and 'logType'.
    ///# Example:  Print a Success log.
    ///````
    ///Printer.log.show(details:  "This is a Success message." logType: .success)
    ///````
    ///- Parameter details:  Any string. The description of your logs.
    ///- Parameter logType:  The type of log you want to print. i.e. LogType.success or .success
    ///- Returns:  Void
    public func show(details: String, logType lType: LogType, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  "", details:  details, logType:  lType, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    //MARK:  Sub functions to logs without ID parameter input.
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example:  Print a Success log.
    ///````
    ///Printer.log.success(details:  "This is a Success message.")
    ///````
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func success(details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  "", details:  details, logType:  .success, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example:  Print a Error log.
    ///````
    ///Printer.log.error(details:  "This is a Error message.")
    ///````
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func error(details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  "", details:  details, logType:  .error, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example:  Print a Warning log.
    ///````
    ///Printer.log.warning(details:  "This is a Warning message.")
    ///````
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func warning(details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  "", details:  details, logType:  .warning, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example:  Print a Information log.
    ///````
    ///Printer.log.information(details:  "This is a Information message.")
    ///````
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func information(details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  "", details:  details, logType:  .information, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example:  Print a Alert log.
    ///````
    ///Printer.log.alert(details:  "This is a Alert message.")
    ///````
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func alert(details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  "", details:  details, logType:  .alert, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    //MARK:  Sub functions to logs
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example:  Print a Success log.
    ///````
    ///Printer.log.success(id:  "001", details:  "This is a Success message.")
    ///````
    ///- Parameter id:  Any string. A number or some text.
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func success(id: String, details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  id, details:  details, logType:  .success, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example:  Print a Error log.
    ///````
    ///Printer.log.error(id:  "001", details:  "This is a Error message.")
    ///````
    ///- Parameter id:  Any string. A number or some text.
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func error(id: String, details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  id, details:  details, logType:  .error, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example:  Print a Information log.
    ///````
    ///Printer.log.information(id:  "001", details:  "This is a Information message.")
    ///````
    ///- Parameter id:  Any string. A number or some text.
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func information(id: String, details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  id, details:  details, logType:  .information, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example:  Print a Warning log.
    ///````
    ///Printer.log.warning(id:  "001", details:  "This is a Warning message.")
    ///````
    ///- Parameter id:  Any string. A number or some text.
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func warning(id: String, details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  id, details:  details, logType:  .warning, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example:  Print a Alert log.
    ///````
    ///Printer.log.alert(id:  "001", details:  "This is a Alert message.")
    ///````
    ///- Parameter id:  Any string. A number or some text.
    ///- Parameter details:  Any string. The description of your logs.
    ///- Returns:  Void
    public func alert(id: String, details: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) -> Void {
        self.printerlog(id:  id, details:  details, logType:  .alert, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
    }
    
    //MARK:  Helper to hide Emojis from the log prints.
    ///You can call this function in advance to print logs without the emojis. This is different than the 'plainLog'.
    public func hideEmojis() -> Void {
        self.successEmojiSymbol = ""
        self.errorEmojiSymbol = ""
        self.warningEmojiSymbol = ""
        self.infoEmojiSymbol = ""
        self.alertEmojiSymbol = ""
        self.watchEmojiSymbol = ""
        self.idEmojiSymbol = ""
    }
    
    //MARK:  Helper to clear Titles from the log prints.
    ///You can call this function in advance to print logs without the titles. This is different than the 'plainLog'.
    public func hideTitles() -> Void {
        self.successLogTitle = ""
        self.errorLogTitle = ""
        self.warningLogTitle = ""
        self.infoLogTitle = ""
        self.alertLogTitle = ""
    }

    //MARK:  Helpers to set custom titles for each cases
    fileprivate var _successLogTitle: String = Titles.success.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    public var successLogTitle: String {
        get {
            return _successLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _successLogTitle = newValue
            } else {
                _successLogTitle = ""
            }
        }
    }
    
    fileprivate var _errorLogTitle: String = Titles.error.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    public var errorLogTitle: String {
        get {
            return _errorLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _errorLogTitle = newValue
            } else {
                _errorLogTitle = ""
            }
        }
    }
    
    fileprivate var _warningLogTitle: String = Titles.warning.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    public var warningLogTitle: String {
        get {
            return _warningLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _warningLogTitle = newValue
            } else {
                _warningLogTitle = ""
            }
        }
    }
    
    fileprivate var _infoLogTitle: String = Titles.information.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    public var infoLogTitle: String {
        get {
            return _infoLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _infoLogTitle = newValue
            } else {
                _infoLogTitle = ""
            }
        }
    }
    
    fileprivate var _alertLogTitle: String = Titles.alert.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    public var alertLogTitle: String {
        get {
            return _alertLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _alertLogTitle = newValue
            } else {
                _alertLogTitle = ""
            }
        }
    }
    
    //MARK:  Helpers to set custom symbols in place of arrow and star
    fileprivate var _arrowSymbol: String = Symbols.arrow.rawValue
    ///You can customize the Symbols used for each logs.
    public var arrowSymbol: String {
        get {
            return _arrowSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _arrowSymbol = newValue
            }
        }
    }
    
    fileprivate var _starSymbol: String = Symbols.star.rawValue
    ///You can customize the Symbols used for each logs.
    public var starSymbol: String {
        get {
            return _starSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _starSymbol = newValue
            }
        }
    }
    
    //MARK:  Helpers to set custom emojis for each cases
    fileprivate var _successEmojiSymbol: String = Emojis.success.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var successEmojiSymbol: String {
        get {
            return _successEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _successEmojiSymbol = newValue
            } else {
                _successEmojiSymbol = ""
            }
        }
    }
    
    fileprivate var _errorEmojiSymbol: String = Emojis.error.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var errorEmojiSymbol: String {
        get {
            return _errorEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _errorEmojiSymbol = newValue
            } else {
                _errorEmojiSymbol = ""
            }
        }
    }
    
    fileprivate var _warningEmojiSymbol: String = Emojis.warning.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var warningEmojiSymbol: String {
        get {
            return _warningEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _warningEmojiSymbol = newValue
            } else {
                _warningEmojiSymbol = ""
            }
        }
    }
    
    fileprivate var _infoEmojiSymbol: String = Emojis.information.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var infoEmojiSymbol: String {
        get {
            return _infoEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _infoEmojiSymbol = newValue
            } else {
                _infoEmojiSymbol = ""
            }
        }
    }
    
    fileprivate var _alertEmojiSymbol: String = Emojis.alert.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var alertEmojiSymbol: String {
        get {
            return _alertEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _alertEmojiSymbol = newValue
            } else {
                _alertEmojiSymbol = ""
            }
        }
    }
    
    fileprivate var _watchEmojiSymbol: String = Emojis.watch.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var watchEmojiSymbol: String {
        get {
            return _watchEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _watchEmojiSymbol = newValue
            } else {
                _watchEmojiSymbol = ""
            }
        }
    }
    
    fileprivate var _idEmojiSymbol: String = Emojis.id.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    public var idEmojiSymbol: String {
        get {
            return _idEmojiSymbol
        }
        set (newValue) {
            if !newValue.isEmpty {
                _idEmojiSymbol = newValue
            } else {
                _idEmojiSymbol = ""
            }
        }
    }
    
    //MARK:  Helper to get custom date to print with a log
    fileprivate func getLogDateForFormat() -> String {
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = self.logDateFormat
        return df.string(from:  currentDate)
    }
    
    //MARK:  Main Logger
    //This is the main logger to print the logs. This will handle loggings for plain (simple) or fancy logs.
    fileprivate func logForType(id: String, details: String, lType: LogType, fileName: String, lineNumber: Int, functionName:  String) -> Void {
        
        var logTypeEmojiSymbol = ""
        var logTypeTitle = self.relativeValueForLogType(lType:  lType)
        var logDetails = details
        var isPlainType: Bool = false
        let isPrivateLog = (fileName == #file)
        
        switch lType {
        case .success:
            logTypeEmojiSymbol = self.successEmojiSymbol
        case .error:
            logTypeEmojiSymbol = self.errorEmojiSymbol
        case .warning:
            logTypeEmojiSymbol = self.warningEmojiSymbol
        case .information:
            logTypeEmojiSymbol = self.infoEmojiSymbol
        case .alert:
            logTypeEmojiSymbol = self.alertEmojiSymbol
        case .plain:
            logTypeEmojiSymbol = ""
            isPlainType = true
        }
        
        if isPlainType {
            self.continueSimple(id:  id, details:  details, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
        } else {
            logTypeTitle = self.capitalizeTitles ? logTypeTitle.uppercased() :  logTypeTitle
            logDetails = self.capitalizeDetails ? logDetails.uppercased() :  logDetails
            
            let titlePart = "\(logTypeEmojiSymbol) \(logTypeTitle)".trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines)
            let idPart = !id.isEmpty ? "\(self.idEmojiSymbol) \(id)".trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines) :  ""
            
            let titlePartOpeningSquareBracket = !titlePart.isEmpty ? "[" :  ""
            let titlePartClosingSquareBracket = !titlePart.isEmpty ? "] " :  ""
            
            let idPartOpeningSquareBracket = !idPart.isEmpty ? "[" :  ""
            let idPartClosingSquareBracket = !idPart.isEmpty ? "]" :  ""
            
            let detailsPartOpening = logDetails.isEmpty ? "" :  " \(self.arrowSymbol) \(self.starSymbol)\(self.starSymbol)"
            let detailsPartClosing = logDetails.isEmpty ? "" :  "\(self.starSymbol)\(self.starSymbol)"
            
            let logTime = self.hideLogsTime ? "" :  "\(self.getLogDateForFormat())"
            let logTimePart = self.hideLogsTime ? "" :  "[\(self.watchEmojiSymbol)\(logTime)] "
            
            let finalLog = "\(titlePartOpeningSquareBracket)\(titlePart)\(titlePartClosingSquareBracket)\(logTimePart)\(idPartOpeningSquareBracket)\(idPart)\(idPartClosingSquareBracket)\(detailsPartOpening)\(logDetails)\(detailsPartClosing)"
            
            print(finalLog)
            
            let plObj = PLog.init(id:  id, details:  details, time:  logTime, logType:  lType, file:  self.getFileName(name:  fileName), function:  functionName, line:  lineNumber)
            plObj.printableLog = finalLog

            if !isPrivateLog {
                if self.keepAutoTracing {
                    plObj.printableTrace = "[Trace] \(self.arrowSymbol) \(self.getFileName(name:  fileName)) \(self.arrowSymbol) \(functionName) #\(lineNumber)"
                    print(plObj.printableTrace)
                }
            }
            
            self.addLineWithPrint()

            if !isPrivateLog {
                self.addLogForTracking(log:  plObj)
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  notificationPrinterLogAdded), object:  nil)
            }
        }
    }
    
    //MARK:  Helper to convert full path to a file name.
    fileprivate func getFileName(name: String) -> String {
        guard !name.isEmpty else {
            return ""
        }
        return (name.components(separatedBy:  "/").last!)
    }
    
    //MARK:  Helper to add a line after each Print
    fileprivate func addLineWithPrint() -> Void {
        if self.addLineAfterEachPrint {
            print("________________________________________________________________________________________")
        }
    }
    
    //MARK:  This function is used to print the logs as plain text
    //This should be a quicker way to logs.
    fileprivate func simple(id: String, details: String, fileName: String, lineNumber: Int, functionName:  String) -> Bool {
        if self.plainLog {
            self.continueSimple(id:  id, details:  details, fileName:  fileName, lineNumber:  lineNumber, functionName:  functionName)
            return true
        }
        return false
    }
    
    //This function is calling from more than one place thus we have created a common function.
    fileprivate func continueSimple(id: String, details: String, fileName: String, lineNumber: Int, functionName:  String) -> Void {
        //`isPrivateLog` is to check whether the current log is from within the Printer or not.
        //We should not include private logs for tracing and tracking.
        let isPrivateLog = (fileName == #file)
        let idPart = id.isEmpty ? "" :  " ID \(self.arrowSymbol) "
        let detailsPart = details.isEmpty ? "" :  " Details \(self.arrowSymbol) "
        var logDetails = details.isEmpty ? "" :  details
        logDetails = self.capitalizeDetails ? logDetails.uppercased() :  logDetails
        let logTime = self.hideLogsTime ? "" :  "\(self.getLogDateForFormat())"
        let logTimePart = self.hideLogsTime ? "" :  "[\(logTime)] "
        let finalLog = "\(logTimePart)\(idPart)\(id)\(detailsPart)\(logDetails)"
        
        let plObj = PLog.init(id:  id, details:  details, time:  logTime, logType:  .plain, file:  getFileName(name:  fileName), function:  functionName, line:  lineNumber)
        plObj.printableLog = finalLog
        
        print(finalLog)
        
        if !isPrivateLog {
            if self.keepAutoTracing {
                plObj.printableTrace = "[Trace] \(self.arrowSymbol) \(self.getFileName(name:  fileName)) \(self.arrowSymbol) \(functionName) #\(lineNumber)"
                print(plObj.printableTrace)
            }
        }

        self.addLineWithPrint()
        
        if !isPrivateLog {
            self.addLogForTracking(log:  plObj)
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  notificationPrinterLogAdded), object:  nil)
        }
    }
}
