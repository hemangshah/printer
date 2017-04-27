//
//  Printer.swift
//
//
//  Created by Hemang Shah on 4/26/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import Foundation

class Printer {
    
    //MARK: Enumurations
    ///Different log cases available for print. You can use it with LogType.success or .success
    enum LogType {
        case success
        case error
        case warning
        case information
        case alert
    }
    
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
    var plainLog:Bool = false
    ///To add a line after each logs. DEFAULT: false
    var addLineAfterEachPrint = false
    ///Capitalize the titles. DEFAULT: false
    var capitalizeTitles = false
    ///Capitalize the Details. DEFAULT: false
    var capitalizeDetails = false
    ///To print logs only when app is in development. DEFAULT: false
    var printOnlyIfDebugMode = true
    
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
    
    //MARK: Filter for Logs.
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
    
    private func isFilterApplied() -> Bool {
        return !filterLogs.isEmpty
    }
    
    private func checkIfFilterExist(logType:LogType) -> Bool {
        if filterLogs.contains(logType) {
            return true
        }
        return false
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
    func show(id:String, details:String, logType lType:LogType) -> Void {
        #if DEBUG
            continueShow(id: id, details: details, logType: lType)
        #else
            if !printOnlyIfDebugMode {
                continueShow(id: id, details: details, logType: lType)
            } else {
                simple(id: "", details: "Printer can't logs as RELEASE mode is active and you have set 'printOnlyIfDebugMode' to 'true'.")
            }
        #endif
    }
    
    private func continueShow(id:String, details:String, logType lType:LogType) -> Void {
        
        var isFilterSatisfied = true
        if isFilterApplied() {
            if !checkIfFilterExist(logType: lType) {
                isFilterSatisfied = false
            }
        }
        
        if isFilterSatisfied {
            if !simple(id: id, details: details) {
                logForType(id: id, details: details, lType: lType)
                addLineWithPrint()
            }
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
    func show(details:String, logType lType:LogType) -> Void {
        show(id: "", details: details, logType: lType)
    }
    
    //MARK: Sub functions to logs without ID parameter input.
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Success log.
    ///````
    ///Printer.log.success(details: "This is a Success message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func success(details:String) -> Void {
        show(id: "", details: details, logType: .success)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Error log.
    ///````
    ///Printer.log.error(details: "This is a Error message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func error(details:String) -> Void {
        show(id: "", details: details, logType: .error)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Warning log.
    ///````
    ///Printer.log.warning(details: "This is a Warning message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func warning(details:String) -> Void {
        show(id: "", details: details, logType: .warning)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Information log.
    ///````
    ///Printer.log.information(details: "This is a Information message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func information(details:String) -> Void {
        show(id: "", details: details, logType: .information)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log without providing 'ID' parameter.
    ///# Example: Print a Alert log.
    ///````
    ///Printer.log.alert(details: "This is a Alert message.")
    ///````
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func alert(details:String) -> Void {
        show(id: "", details: details, logType: .alert)
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
    func success(id:String, details:String) -> Void {
        show(id: id, details: details, logType: .success)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Error log.
    ///````
    ///Printer.log.error(id: "001", details: "This is a Error message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func error(id:String, details:String) -> Void {
        show(id: id, details: details, logType: .error)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Information log.
    ///````
    ///Printer.log.information(id: "001", details: "This is a Information message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func information(id:String, details:String) -> Void {
        show(id: id, details: details, logType: .information)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Warning log.
    ///````
    ///Printer.log.warning(id: "001", details: "This is a Warning message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func warning(id:String, details:String) -> Void {
        show(id: id, details: details, logType: .warning)
    }
    
    ///If you don't want to call the main 'show' function, you can call this sub-functions to show a specific type of log.
    ///# Example: Print a Alert log.
    ///````
    ///Printer.log.alert(id: "001", details: "This is a Alert message.")
    ///````
    ///- Parameter id: Any string. A number or some text.
    ///- Parameter details: Any string. The description of your logs.
    ///- Returns: Void
    func alert(id:String, details:String) -> Void {
        show(id: id, details: details, logType: .alert)
    }

    //MARK: Helpers to set custom titles for each cases
    private var _successLogTitle:String = Titles.success.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var successLogTitle:String {
        get {
            return _successLogTitle
        }
        set (newValue) {
            _successLogTitle = newValue
        }
    }
    
    private var _errorLogTitle:String = Titles.error.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var errorLogTitle:String {
        get {
            return _errorLogTitle
        }
        set (newValue) {
            _errorLogTitle = newValue
        }
    }
    
    private var _warningLogTitle:String = Titles.warning.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var warningLogTitle:String {
        get {
            return _warningLogTitle
        }
        set (newValue) {
            _warningLogTitle = newValue
        }
    }
    
    private var _infoLogTitle:String = Titles.information.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var infoLogTitle:String {
        get {
            return _infoLogTitle
        }
        set (newValue) {
            _infoLogTitle = newValue
        }
    }
    
    private var _alertLogTitle:String = Titles.alert.rawValue
    ///You can customize the titles for each logs, this will be helpful when you want to localize the logs as well.
    var alertLogTitle:String {
        get {
            return _alertLogTitle
        }
        set (newValue) {
            _alertLogTitle = newValue
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
            _arrowSymbole = newValue
        }
    }
    
    private var _starSymbole:String = Symboles.star.rawValue
    ///You can customize the symboles used for each logs.
    var starSymbole:String {
        get {
            return _starSymbole
        }
        set (newValue) {
            _starSymbole = newValue
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
            _successEmojiSymbole = newValue
        }
    }
    
    private var _errorEmojiSymbole:String = Emojis.error.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var errorEmojiSymbole:String {
        get {
            return _errorEmojiSymbole
        }
        set (newValue) {
            _errorEmojiSymbole = newValue
        }
    }
    
    private var _warningEmojiSymbole:String = Emojis.warning.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var warningEmojiSymbole:String {
        get {
            return _warningEmojiSymbole
        }
        set (newValue) {
            _warningEmojiSymbole = newValue
        }
    }
    
    private var _infoEmojiSymbole:String = Emojis.information.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var infoEmojiSymbole:String {
        get {
            return _infoEmojiSymbole
        }
        set (newValue) {
            _infoEmojiSymbole = newValue
        }
    }
    
    private var _alertEmojiSymbole:String = Emojis.alert.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var alertEmojiSymbole:String {
        get {
            return _alertEmojiSymbole
        }
        set (newValue) {
            _alertEmojiSymbole = newValue
        }
    }
    
    private var _watchEmojiSymbole:String = Emojis.watch.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var watchEmojiSymbole:String {
        get {
            return _watchEmojiSymbole
        }
        set (newValue) {
            _watchEmojiSymbole = newValue
        }
    }
    
    private var _idEmojiSymbole:String = Emojis.id.rawValue
    ///You can customize the emojis for each logs, this will be helpful when you want to use a different emoji for a particular log.
    var idEmojiSymbole:String {
        get {
            return _idEmojiSymbole
        }
        set (newValue) {
            _idEmojiSymbole = newValue
        }
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
    
    //MARK: Helper to get custom date to print with a log
    private func getLogDateForFormat() -> String {
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = logDateFormat
        return df.string(from: currentDate)
    }
    
    private func logForType(id:String, details:String, lType:LogType) -> Void {
        
        var logTypeEmojiSymbole = ""
        var logTypeTitle = ""
        var logDetails = details
        
        switch lType {
        case .success:
            logTypeTitle = successLogTitle
            logTypeEmojiSymbole = successEmojiSymbole
        case .error:
            logTypeTitle = errorLogTitle
            logTypeEmojiSymbole = errorEmojiSymbole
        case .warning:
            logTypeTitle = warningLogTitle
            logTypeEmojiSymbole = warningEmojiSymbole
        case .information:
            logTypeTitle = infoLogTitle
            logTypeEmojiSymbole = infoEmojiSymbole
        case .alert:
            logTypeTitle = alertLogTitle
            logTypeEmojiSymbole = alertEmojiSymbole
        }
        
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
        
        print("Printer \(arrowSymbole) \(titlePartOpeningSquareBracket)\(titlePart)\(titlePartClosingSquareBracket)[\(watchEmojiSymbole)\(getLogDateForFormat())] \(idPartOpeningSquareBracket)\(idPart)\(idPartClosingSquareBracket)\(detailsPartOpening)\(logDetails)\(detailsPartClosing)")
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
            let idPart = id.isEmpty ? "" : " ID \(arrowSymbole) "
            let detailsPart = details.isEmpty ? "" : " Details \(arrowSymbole) "
            var logDetails = details.isEmpty ? "" : details
            logDetails = capitalizeDetails ? logDetails.uppercased() : logDetails
            print("Printer \(arrowSymbole) [\(getLogDateForFormat())]\(idPart)\(id)\(detailsPart)\(logDetails)")
            addLineWithPrint()
            return true
        }
        return false
    }
}
