//
//  Printer.swift
//
//
//  Created by Hemang Shah on 4/26/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import Foundation

//MARK: Enumurations
///Different log cases available for print. You can use it with LogType.success or .success
enum LogType {
    case success
    case error
    case warning
    case information
    case alert
    case plain
}

//MARK: PLog
class PLog {
    
    var id:String
    var details:String
    var logType:LogType
    var time:String
    var traceInfo:String?
    
    init(id:String, details:String, time:String, logType lType:LogType) {
        self.id = id
        self.details = details
        self.time = time
        self.logType = lType
    }
}

//MARK: Printer
class Printer {

    //You can always change the Emojis here but it's not suggestible.
    //So if you want to change Emojis or everything please use the respective properties.
    private enum Emojis:String {
        case success = "✅"
        case error = "❌"
        case warning = "🚧"
        case information = "📣"
        case alert = "🚨"
        case watch = "⌚"
        case id = "🆔"
    }
    
    //You can always change the Symboles here but it's not suggestible.
    //So if you want to change Symboles or everything please use the respective properties.
    private enum Symboles:String {
        case arrow = "➞"
        case star = "✹"
    }
    
    //You can always change the Titles here but it's not suggestible.
    //So if you want to change Titles or everything please use the respective properties.
    private enum Titles:String {
        case success = "Success"
        case error = "Error"
        case warning = "Warning"
        case information = "Information"
        case alert = "Alert"
    }
    
    //MARK: Singleton
    ///Always use a Singleton to use the Printer globally with the defined settings/properties.
    static let log = Printer()
    
    //MARK: Properties
    ///Don't like emojis and formation? Set this to 'true' and it will print the plain text. DEFAULT: false
    ///You can also use show with log type: .plain to print a plain log. This is helpful when you only want to print few plain logs.
    var plainLog:Bool = false
    ///To add a line after each logs. DEFAULT: false
    var addLineAfterEachPrint:Bool = false
    ///Capitalize the titles. DEFAULT: false
    var capitalizeTitles:Bool = false
    ///Capitalize the Details. DEFAULT: false
    var capitalizeDetails:Bool = false
    ///To print logs only when app is in development. DEFAULT: true
    var printOnlyIfDebugMode:Bool = true
    ///To hide time from the logs. DEFAULT: false
    var hideLogsTime:Bool = false
    ///To disable all the logs. You can set this anywhere and it should not print logs from where it sets. DEFAULT: false
    var disable:Bool = false
    ///To keep track of all the logs. To print all the logs later. This will be ignore if 'disable' is set to 'true'.
    var keepTracking:Bool = false
    ///To keep tracing with all the logs. No need to call trace() separately if this is set to 'true'. DEFAULT: true
    var keepAutoTracing:Bool = true
    
    private var filterFiles:Array = Array<String>()
    private var arrayLogs = Array<PLog>()
    
    //MARK: Helpers to set custom date format for each logs
    ///By default, we will use the below date format to show with each logs. You can always customize it with it's property.
    private var _logDateFormat:String = "MM-dd-yyyy HH:mm:ss"
    var logDateFormat:String {
        get {
            return _logDateFormat
        }
        set (newValue) {
            if !newValue.isEmpty {
                _logDateFormat = newValue
            }
        }
    }
    
    //MARK: Filter for Logs. [Files]
    func skipFile(filename:String = #file) -> Void {
        if !checkIfFileFilterExist(file: filename) {
            filterFiles.append(filename)
        }
    }
    
    func addFile(filename:String = #file) -> Void {
        if checkIfFileFilterExist(file: filename) {
            if let index = filterFiles.index(of: filename) {
                filterFiles.remove(at: index)
            }
        }
    }
    
    private func isFileFilterApplied() -> Bool {
        return !filterFiles.isEmpty
    }
    
    private func checkIfFileFilterExist(file:String) -> Bool {
        guard filterFiles.contains(file) else {
            return false
        }
        return true
    }
    
    //MARK: Filter for Logs. [LogType]
    private var _filterLogs:Array = Array<LogType>()
    ///To logs only specific type. Please return an Array<LogType>.
    ///Printer.log.filterLogs = [.success, .alert]
    var filterLogs:Array<LogType> {
        get {
            return _filterLogs
        }
        set (newArray) {
            _filterLogs.removeAll()
            _filterLogs.append(contentsOf: newArray)
        }
    }
    
    private func isLogTypeFilterApplied() -> Bool {
        return !filterLogs.isEmpty
    }
    
    private func checkIfFilterExist(logType:LogType) -> Bool {
        if filterLogs.contains(logType) {
            return true
        }
        return false
    }
    
    //MARK: Tracking of logs
    private func addLogForTracking(log:PLog) -> Void {
        if keepTracking {
            arrayLogs.append(log)
        }
    }
    
    ///To print all the tracked logs. 'keepTracking' should be set to 'true' before logging.
    func all() -> Void {
        guard arrayLogs.count > 0 else {
            information(details: "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.")
            return
        }
        for log:PLog in arrayLogs {
            guard log.logType != .plain else {
                print("Printer [All Logs] [\(log.time)] Id:\(log.id) Details:\(log.details)")
                return
            }
            print("Printer [All Logs] [\(relativeValueForLogType(lType: log.logType))] [\(log.time)] Id:\(log.id) Details:\(log.details)")
        }
    }
    
    ///To print the tracked logs based on the filter values. 'keepTracking' should be set to 'true' before logging.
    func all(filterLogTypes:Array<LogType>) -> Void {
        guard arrayLogs.count > 0 else {
            information(details: "No tracked logs. To track logs, you need to set 'keepTracking' to 'true' and 'disable' is not set to 'true'.")
            return
        }
        
        let filteredArray:Array<PLog> = arrayLogs.filter() {
            if let type = ($0 as PLog).logType as LogType! {
                return (filterLogTypes.contains(type))
            } else {
                return false
            }
        }
        
        guard filteredArray.count > 0 else {
            information(details: "No tracked logs for filter. Total tracked logs: #\(arrayLogs.count)")
            return
        }
        
        for log:PLog in filteredArray {
            print("Printer [All Logs.filtered] [\(relativeValueForLogType(lType: log.logType))] [\(log.time)] Id:\(log.id) Details:\(log.details)")
        }
    }
    
    //Code Reducing to get a log title.
    private func relativeValueForLogType(lType:LogType) -> String {
        var logTypeTitle:String = ""
        switch lType {
        case .success:
            logTypeTitle = successLogTitle
        case .error:
            logTypeTitle = errorLogTitle
        case .warning:
            logTypeTitle = warningLogTitle
        case .information:
            logTypeTitle = infoLogTitle
        case .alert:
            logTypeTitle = alertLogTitle
        case .plain:
            logTypeTitle = ""
        }
        return logTypeTitle
    }
    
    //MARK: Main function to logs
    
    /**
    **show(id:details:logType)** is the main function to print logs on console. It has various options to print logs when requires. Different available cases includes **Success**, **Error**, **Warning**, **Information** and **Alert**.
     
    - Parameter id: Any string. A number or some text.
    - Parameter details: Any string. The description of your logs.
    - Parameter logType: The type of log you want to print. i.e. LogType.success or .success
     
    # Example: Print a Success log.
     
     ````
     Printer.log.show(id: "001", details: "This is a Success message.", logType: .success)
     
     Output: 
     
     Printer ➞ [✅ SUCCESS] [⌚04-26-2017 16:39:39] [🆔 001] ➞ ✹✹This is a Success message.✹✹
     ````
     
     - Returns: Void
     
     */
    func show(id:String, details:String, logType lType:LogType, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        printerlog(id: id, details: details, logType: lType, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    
    private func printerlog(id:String, details:String, logType lType:LogType, fileName:String, lineNumber:Int, functionName: String) -> Void {
        if !disable {
            #if DEBUG
                printerlogger(id: id, details: details, logType: lType, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
            #else
                if !printOnlyIfDebugMode {
                    printerlogger(id: id, details: details, logType: lType, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
                } else {
                    information(details: "Printer can't logs as RELEASE mode is active and you have set 'printOnlyIfDebugMode' to 'true'.")
                }
            #endif
        }
    }
    
    private func printerlogger(id:String, details:String, logType lType:LogType, fileName:String, lineNumber:Int, functionName: String) -> Void {
        if isLogFilterValidates(logType: lType, fileName: fileName) {
            if !simple(id: id, details: details) {
                logForType(id: id, details: details, lType: lType, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
            }
        }
    }
    
    //Right now, we're supporting two types of filters.
    //1. LogType Filter
    //      We can filter the logs based on its type. That's success, alert, warning, information, error.
    //2. File Filter
    //      We can filter the logs based on file. ViewController.self, or simply: self.
    private func isLogFilterValidates(logType lType:LogType, fileName:String) -> Bool {
        var isLogTypeFilterSatisfied = true
        var isFileFilterSatisfied = true
        
        if isLogTypeFilterApplied() {
            if !checkIfFilterExist(logType: lType) {
                isLogTypeFilterSatisfied = false
            }
        }
        
        if isFileFilterApplied() {
            if checkIfFileFilterExist(file: fileName) {
                isFileFilterSatisfied = false
            }
        }
        
        return (isLogTypeFilterSatisfied && isFileFilterSatisfied)
    }
    
    //MARK: Trace
    ///To print current class name, function name and line number from where trace() called.
    func trace(fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        if !disable {
            #if DEBUG
                continueTrace(file: fileName, line: lineNumber, function: functionName)
            #else
                if !printOnlyIfDebugMode {
                    continueTrace(file: fileName, line: lineNumber, function: functionName)
                } else {
                    information(details: "Printer can't trace as RELEASE mode is active and you have set 'printOnlyIfDebugMode' to 'true'.")
                }
            #endif
        }
    }
    
    private func continueTrace(file:String, line:Int, function:String) -> Void {
        if isLogFilterValidates(logType: .plain, fileName: file) {
            let logTime = hideLogsTime ? "" : "[\(getLogDateForFormat())] "
            print("Printer [Trace] \(arrowSymbole) \(logTime)\(file.components(separatedBy: "/").last!) \(arrowSymbole) \(function) #\(line)")
            addLineWithPrint()
        }
    }
    
    //MARK: Future Logs
    ///To show a specific log after a certain time [seconds].
    func showInFuture(id:String, details:String, logType lType:LogType, afterSeconds seconds:Double, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.printerlog(id: id, details: details, logType: lType, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
        }
    }
    
    //MARK: Overrided **show(id:details:logType)** function to logs without ID parameter input.
    ///If you want to call the main 'show' function without providing ID parameter, you can call this 'show' function with only 'details' and 'logType'.
    ///# Example: Print a Success log.
    ///````
    ///Printer.log.show(details: "This is a Success message." logType:.success)
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Parameter logType: The type of log you want to print. i.e. LogType.success or .success
    ///- Returns: Void
    func show(details:String, logType lType:LogType, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: "", details: details, logType: lType, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    //MARK: Sub functions to logs without ID parameter input.
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Success log.
    ///````
    ///Printer.log.success(details: "This is a Success message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func success(details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: "", details: details, logType: .success, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Error log.
    ///````
    ///Printer.log.error(details: "This is a Error message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func error(details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: "", details: details, logType: .error, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Warning log.
    ///````
    ///Printer.log.warning(details: "This is a Warning message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func warning(details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: "", details: details, logType: .warning, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Information log.
    ///````
    ///Printer.log.information(details: "This is a Information message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func information(details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: "", details: details, logType: .information, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Alert log.
    ///````
    ///Printer.log.alert(details: "This is a Alert message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func alert(details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: "", details: details, logType: .alert, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    //MARK: Sub functions to logs
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Success log.
    ///````
    ///Printer.log.success(id: "001", details: "This is a Success message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func success(id:String, details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: id, details: details, logType: .success, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Error log.
    ///````
    ///Printer.log.error(id: "001", details: "This is a Error message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func error(id:String, details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: id, details: details, logType: .error, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Information log.
    ///````
    ///Printer.log.information(id: "001", details: "This is a Information message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func information(id:String, details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: id, details: details, logType: .information, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Warning log.
    ///````
    ///Printer.log.warning(id: "001", details: "This is a Warning message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func warning(id:String, details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: id, details: details, logType: .warning, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Alert log.
    ///````
    ///Printer.log.alert(id: "001", details: "This is a Alert message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func alert(id:String, details:String, fileName:String = #file, lineNumber:Int = #line, functionName:String = #function) -> Void {
        self.printerlog(id: id, details: details, logType: .alert, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    //MARK: Helper to hide Emojis from the log prints.
    ///You can call this function in advance to print logs without the emojis. This is different than the 'plainLog'.
    func hideEmojis() -> Void {
        successEmojiSymbole = ""
        errorEmojiSymbole = ""
        warningEmojiSymbole = ""
        infoEmojiSymbole = ""
        alertEmojiSymbole = ""
        watchEmojiSymbole = ""
        idEmojiSymbole = ""
    }
    
    //MARK: Helper to clear Titles from the log prints.
    ///You can call this function in advance to print logs without the titles. This is different than the 'plainLog'.
    func hideTitles() -> Void {
        successLogTitle = ""
        errorLogTitle = ""
        warningLogTitle = ""
        infoLogTitle = ""
        alertLogTitle = ""
    }

    //MARK: Helpers to set custom titles for each cases
    private var _successLogTitle:String = Titles.success.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var successLogTitle:String {
        get {
            return _successLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _successLogTitle = newValue
            }
        }
    }
    
    private var _errorLogTitle:String = Titles.error.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var errorLogTitle:String {
        get {
            return _errorLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _errorLogTitle = newValue
            }
        }
    }
    
    private var _warningLogTitle:String = Titles.warning.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var warningLogTitle:String {
        get {
            return _warningLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _warningLogTitle = newValue
            }
        }
    }
    
    private var _infoLogTitle:String = Titles.information.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var infoLogTitle:String {
        get {
            return _infoLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _infoLogTitle = newValue
            }
        }
    }
    
    private var _alertLogTitle:String = Titles.alert.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var alertLogTitle:String {
        get {
            return _alertLogTitle
        }
        set (newValue) {
            if !newValue.isEmpty {
                _alertLogTitle = newValue
            }
        }
    }
    
    //MARK: Helpers to set custom symboles in place of arrow and star
    private var _arrowSymbole:String = Symboles.arrow.rawValue
    ///You can customize the symboles used for each logs.
    var arrowSymbole:String {
        get {
            return _arrowSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _arrowSymbole = newValue
            }
        }
    }
    
    private var _starSymbole:String = Symboles.star.rawValue
    ///You can customize the symboles used for each logs.
    var starSymbole:String {
        get {
            return _starSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _starSymbole = newValue
            }
        }
    }
    
    //MARK: Helpers to set custom emojis for each cases
    private var _successEmojiSymbole:String = Emojis.success.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var successEmojiSymbole:String {
        get {
            return _successEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _successEmojiSymbole = newValue
            }
        }
    }
    
    private var _errorEmojiSymbole:String = Emojis.error.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var errorEmojiSymbole:String {
        get {
            return _errorEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _errorEmojiSymbole = newValue
            }
        }
    }
    
    private var _warningEmojiSymbole:String = Emojis.warning.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var warningEmojiSymbole:String {
        get {
            return _warningEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _warningEmojiSymbole = newValue
            }
        }
    }
    
    private var _infoEmojiSymbole:String = Emojis.information.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var infoEmojiSymbole:String {
        get {
            return _infoEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _infoEmojiSymbole = newValue
            }
        }
    }
    
    private var _alertEmojiSymbole:String = Emojis.alert.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var alertEmojiSymbole:String {
        get {
            return _alertEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _alertEmojiSymbole = newValue
            }
        }
    }
    
    private var _watchEmojiSymbole:String = Emojis.watch.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var watchEmojiSymbole:String {
        get {
            return _watchEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _watchEmojiSymbole = newValue
            }
        }
    }
    
    private var _idEmojiSymbole:String = Emojis.id.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var idEmojiSymbole:String {
        get {
            return _idEmojiSymbole
        }
        set (newValue) {
            if !newValue.isEmpty {
                _idEmojiSymbole = newValue
            }
        }
    }
    
    //MARK: Helper to get custom date to print with a log
    private func getLogDateForFormat() -> String {
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = logDateFormat
        return df.string(from: currentDate)
    }
    
    private func logForType(id:String, details:String, lType:LogType, fileName:String, lineNumber:Int, functionName: String) -> Void {
        
        var logTypeEmojiSymbole = ""
        var logTypeTitle = relativeValueForLogType(lType: lType)
        var logDetails = details
        var isPlainType:Bool = false
        
        switch lType {
        case .success:
            logTypeEmojiSymbole = successEmojiSymbole
        case .error:
            logTypeEmojiSymbole = errorEmojiSymbole
        case .warning:
            logTypeEmojiSymbole = warningEmojiSymbole
        case .information:
            logTypeEmojiSymbole = infoEmojiSymbole
        case .alert:
            logTypeEmojiSymbole = alertEmojiSymbole
        case .plain:
            logTypeEmojiSymbole = ""
            isPlainType = true
        }
        
        if isPlainType {
            continueSimple(id: id, details: details)
        } else {
            logTypeTitle = capitalizeTitles ? logTypeTitle.uppercased() : logTypeTitle
            logDetails = capitalizeDetails ? logDetails.uppercased() : logDetails
            
            let titlePart = "\(logTypeEmojiSymbole) \(logTypeTitle)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let idPart = !id.isEmpty ? "\(idEmojiSymbole) \(id)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : ""
            
            let titlePartOpeningSquareBracket = !titlePart.isEmpty ? "[" : ""
            let titlePartClosingSquareBracket = !titlePart.isEmpty ? "] " : ""
            
            let idPartOpeningSquareBracket = !idPart.isEmpty ? "[" : ""
            let idPartClosingSquareBracket = !idPart.isEmpty ? "]" : ""
            
            let detailsPartOpening = logDetails.isEmpty ? "" : " \(arrowSymbole) \(starSymbole)\(starSymbole)"
            let detailsPartClosing = logDetails.isEmpty ? "" : "\(starSymbole)\(starSymbole)"
            
            let logTime = hideLogsTime ? "" : "\(getLogDateForFormat())"
            let logTimePart = hideLogsTime ? "" : "[\(watchEmojiSymbole)\(logTime)] "
            
            let finalLog = "Printer \(arrowSymbole) \(titlePartOpeningSquareBracket)\(titlePart)\(titlePartClosingSquareBracket)\(logTimePart)\(idPartOpeningSquareBracket)\(idPart)\(idPartClosingSquareBracket)\(detailsPartOpening)\(logDetails)\(detailsPartClosing)"
            
            print(finalLog)
            
            if keepAutoTracing {
                print("[Trace] \(arrowSymbole) \(fileName.components(separatedBy: "/").last!) \(arrowSymbole) \(functionName) #\(lineNumber)")
            }
            
            addLineWithPrint()
            
            addLogForTracking(log: PLog(id: id, details: details, time: logTime, logType: lType))
        }
    }
    
    //MARK: Helper to add a line after each Print
    private func addLineWithPrint() -> Void {
        if addLineAfterEachPrint {
            print("________________________________________________________________________________________")
        }
    }
    
    //MARK: This function is used to print the logs as plain text
    //This should be a quicker way to logs.
    private func simple(id:String, details:String) -> Bool {
        if plainLog {
            continueSimple(id: id, details: details)
            return true
        }
        return false
    }
    
    private func continueSimple(id:String, details:String) -> Void {
        let idPart = id.isEmpty ? "" : " ID \(arrowSymbole) "
        let detailsPart = details.isEmpty ? "" : " Details \(arrowSymbole) "
        var logDetails = details.isEmpty ? "" : details
        logDetails = capitalizeDetails ? logDetails.uppercased() : logDetails
        let logTime = hideLogsTime ? "" : "\(getLogDateForFormat())"
        let logTimePart = hideLogsTime ? "" : "[\(logTime)] "
        let finalLog = "Printer \(arrowSymbole) \(logTimePart)\(idPart)\(id)\(detailsPart)\(logDetails)"
        print(finalLog)
        addLogForTracking(log: PLog(id: id, details: details, time: logTime, logType: .plain))
        addLineWithPrint()
    }
}
