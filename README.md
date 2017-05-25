![Fancy Logo](https://github.com/hemangshah/printer/blob/master/PrinterExampleApp/PrinterExampleApp/printer-logo.png)

[![Build Status](https://travis-ci.org/hemangshah/printer.svg?branch=master)](https://travis-ci.org/hemangshah/printer)
![Swift 3.x](https://img.shields.io/badge/Swift-3.x-blue.svg) 
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)
![Platform](https://img.shields.io/badge/Platforms-iOS-red.svg)
![MadeWithLove](https://img.shields.io/badge/Made%20with%20%E2%9D%A4-India-green.svg)

## You can print following types of logs with Printer.

  - ✅ Success
  - ❌ Error
  - 🚧 Warning
  - 📣 Information
  - 🚨 Alert

> With each of the type, it will print a particular emoji and titles which will help you to easily identify what's exactly the log is. Moreover, it will looks cool too.

## Features

1.	[Different ways to print Logs](https://github.com/hemangshah/printer/#different-ways-to-print-logs)
3.	[Plain Logs](https://github.com/hemangshah/printer/#plainlog)
4.	[Tracing](https://github.com/hemangshah/printer/#tracing)
5.	[All Logs for Print](https://github.com/hemangshah/printer/#all-logs-for-print)
6.	[All Logs for Use](https://github.com/hemangshah/printer/#all-logs-for-use)
7.	[Save Logs to a file](https://github.com/hemangshah/printer/#save-logs-to-a-file)
8.	[Flush](https://github.com/hemangshah/printer/#flush)
9.	[Customize Printer](https://github.com/hemangshah/printer/#customize-printer)
10.	[Filter Logs](https://github.com/hemangshah/printer/#filter-logs-filter-by-log-types)
11.	[Disable Logs](https://github.com/hemangshah/printer/#disable-logs)
12.	[Completion Block](https://github.com/hemangshah/printer/#completion-block)
14. [Background or Foreground Logs](https://github.com/hemangshah/printer/#background-or-foreground-logs)
13.	[Shipping to AppStore?](https://github.com/hemangshah/printer/#ready-to-ship-your-app)

## Let's see what you can do with Printer.

<b>Printer has a singleton, you should always use it with it's singleton.</b>

    Printer.log.show(id: "001", details: "This is a Success message.", logType: .success)
        
<b>See the output. Isn't it cool?</b>
        
    [✅ Success] [⌚04-27-2017 10:39:26] [🆔 101] ➞ ✹✹This is a Success message.✹✹
        
<b>So here are other options you can do with Printer.</b>

    Printer.log.show(id: "002", details: "This is a Error message.", logType: .error)
    Printer.log.show(id: "003", details: "This is an Information message.", logType: .information)
    Printer.log.show(id: "004", details: "This is a Warning message.", logType: .warning)    
    Printer.log.show(id: "005", details: "This is an Alert message.", logType: .alert)

<b>Output:</b>

    [❌ Error] [⌚04-27-2017 10:41:39] [🆔 102] ➞ ✹✹This is a Error message.✹✹
    [🚧 Warning] [⌚04-27-2017 10:41:39] [🆔 103] ➞ ✹✹This is a Warning message.✹✹
    [📣 Information] [⌚04-27-2017 10:41:39] [🆔 104] ➞ ✹✹This is an Information message.✹✹
    [🚨 Alert] [⌚04-27-2017 10:41:39] [🆔 105] ➞ ✹✹This is an Alert message.✹✹

## Different ways to print logs.

<b>Don't want to specify the logType everytime? No problem, we have function for that too.</b>
    
    Printer.log.success(id: "101", details: "This is a Success message. No need to specify logType.")
    Printer.log.error(id: "102", details: "This is an Error message. No need to specify logType.")
    Printer.log.warning(id: "103", details: "This is a Warning message. No need to specify logType.")
    Printer.log.information(id: "104", details: "This is an Information message. No need to specify logType.")
    Printer.log.alert(id: "105", details: "This is an Alert message. No need to specify logType.")

<b>Don't want to specify IDs? We have taken care about that too.</b>

    Printer.log.success(details: "This is a Success message without ID.")
    Printer.log.error(details: "This is an Error message without ID.")
    Printer.log.warning(details: "This is a Warning message without ID.")
    Printer.log.information(details: "This is an Information message without ID.")
    Printer.log.alert(details: "This is an Alert message without ID.")

<b>We have overrided the 'show' function.</b>

    Printer.log.show(details: "This is a Success message.", logType: .success)
    Printer.log.show(details: "This is an Alert message.", logType: .alert)
    
<b>Show a future log.</b>

    Printer.log.showInFuture(id: "006", details: "This is a future Success message.", logType: .success, afterSeconds: 3)
    
> This will print a log after specified seconds. In this case, success log after three (<b>3</b>) seconds.

## plainLog

<b>Don't like this the fancy logs? No worries, we have a plain log option.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.

    Printer.log.plainLog = true
    
<b>Exmaple when </b>`plainLog`<b> is set to </b>`true`<b>.</b>

    [04-27-2017 10:50:30] ID ➞ 001 Details ➞ This is a Success message.
    [04-27-2017 10:50:30] ID ➞ 002 Details ➞ This is a Error message.
    [04-27-2017 10:50:30] ID ➞ 003 Details ➞ This is an Information message.
    [04-27-2017 10:50:30] ID ➞ 004 Details ➞ This is a Warning message.
    [04-27-2017 10:50:30] ID ➞ 005 Details ➞ This is an Alert message.
    
<b>We have a new</b>`.plain`<b> type added with </b>show()<b> function</b>.

    Printer.log.show(id: "001", details: "This is a Plain message.", logType: .plain)
    
> This is useful when you only want few plain logs.

> **IMPORTANT**: Any properties you're setting should be set in advance or before printing any logs to get the exact effect.

> **SUGGESTION**: You can always set all the properties to customize the **Printer** in `AppDelegate.swift` file,

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.

            //set the properties and call the specific function as per the need.

            //Printer.log.plainLog = true
            Printer.log.addLineAfterEachPrint = true
            Printer.log.capitalizeTitles = true
            Printer.log.capitalizeDetails = true
            Printer.log.printOnlyIfDebugMode = true
            
           //Applied filters to only print success and alert type logs.
           //Printer.log.filterLogs = [.success, .alert]
           
            Printer.log.onLogCompletion = { (log) in
              //print(log)
              //print(log.0)
            }

            //Printer.log.hideTitles()
            //Printer.log.hideEmojis()

            return true
        }

> This will set the properties globally and will be available for the entire app life cycle.

## Tracing

<b> Want to print file name, function name and line number?</b>

> **IMPORTANT**: Should be call everytime when you want to print a trace.

    Printer.log.trace()
    
    Printer.Trace ➞ [05-02-2017 14:58:38] ViewController.swift ➞ viewDidLoad() #40

## Auto Tracing

> **DEFAULT**: `true`
> **IMPORTANT**: `keepAutoTracing` should set to `true` before logging.

This would print same trace as if you call trace(). If you don't like it, just set `keepAutoTracing` to `false`.
    
## All Logs for Print

<b>Want to print all the logs for a different use case?</b>

> **IMPORTANT**: `keepTracking` should set to `true` before logging. Even if `keepAutoTracing` is set to `false` if you passes `showTrace` to `true`, you will see the traced info. This is helpful if you don't want to trace while logging.

    Printer.log.all(showTrace: true)
    
    [All Logs] [Success] [05-15-2017 14:28:03] Id:001 Details:This is a Success message.
    [Trace] ➞ ViewController.swift ➞ viewDidLoad() #58
    [All Logs] [Error] [05-15-2017 14:28:03] Id:002 Details:This is a Error message.
    [Trace] ➞ ViewController.swift ➞ viewDidLoad() #59
    [All Logs] [Information] [05-15-2017 14:28:03] Id:003 Details:This is an Information message.
    [Trace] ➞ ViewController.swift ➞ viewDidLoad() #60
    [All Logs] [Warning] [05-15-2017 14:28:03] Id:004 Details:This is a Warning message.
    [Trace] ➞ ViewController.swift ➞ viewDidLoad() #61
    [All Logs] [Alert] [05-15-2017 14:28:03] Id:005 Details:This is an Alert message.
    [Trace] ➞ ViewController.swift ➞ viewDidLoad() #62
    
<b>You can filter them as well.</b>

    Printer.log.all(filterLogTypes: [.alert], showTrace: true)
   
> This will only print `.alert` type tracked logs with tracing info.

    [All Logs] [Alert] [05-15-2017 14:28:03] Id:005 Details:This is an Alert message.
    [Trace] ➞ ViewController.swift ➞ viewDidLoad() #62
    
> all() function will always print plain logs. <i>No fancy things</i>.

## All Logs for Use

<b>Want to get all the logs?</b>

    //let array = Printer.log.getAllLogs()
    let array = Printer.log.getAllLogs(filterLogTypes: [.success])
    if !array.isEmpty {
        array.forEach({ (log) in
             print(log.details)
            //or do something else.
        })
    }

<b>Use cases:</b>
- To store it somewhere.
- To make API calls with log details.
- To do anything which [Printer] isn't supports.

## Save Logs to a File

<b>Want to create a log file for use? We have covered it too.</b>

    let array = Printer.log.getAllLogs()
    if !array.isEmpty {    
        Printer.log.saveLogToFile(logs: array)
    }        

> All your logs will be created in a separate file under Printer folder.

<b>Delete all Log files?</b>

    Printer.log.deleteLogFiles()
    
## Flush

<b>Want to delete all the log files and free up some space?</b>

    Printer.log.flush()

## Customize Printer

<b>You can add a line after each logs.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.
    
    Printer.log.addLineAfterEachPrint = true

<b>Example when addLineAfterEachPrint is set to </b>`true`<b>.</b>

    [✅ Success] [⌚04-27-2017 10:53:28] [🆔 001] ➞ ✹✹This is a Success message.✹✹
    ________________________________________________________________________________________
    [❌ Error] [⌚04-27-2017 10:53:28] [🆔 002] ➞ ✹✹This is a Error message.✹✹
    ________________________________________________________________________________________
    [📣 Information] [⌚04-27-2017 10:53:28] [🆔 003] ➞ ✹✹This is an Information message.✹✹
    ________________________________________________________________________________________
    [🚧 Warning] [⌚04-27-2017 10:53:28] [🆔 004] ➞ ✹✹This is a Warning message.✹✹
    ________________________________________________________________________________________
    [🚨 Alert] [⌚04-27-2017 10:53:28] [🆔 005] ➞ ✹✹This is an Alert message.✹✹
    ________________________________________________________________________________________

## Capitalize Titles & Details

<b>You can even capitalized the title and details of logs.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.

    Printer.log.capitalizeTitles = true

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.

    Printer.log.capitalizeDetails = true

<b>Example when capitalizeTitles and capitalizeDetails are set to </b>`true`<b>.</b>

    [✅ SUCCESS] [⌚04-27-2017 11:09:37] [🆔 001] ➞ ✹✹THIS IS A SUCCESS MESSAGE.✹✹

<b>Don't want to show Emojis?</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.hideEmojis()

<b>Example when</b> `hideEmojis()` <b>call.</b>

    [Success] [04-27-2017 11:08:45] [001] ➞ ✹✹This is a Success message.✹✹
    [Error] [04-27-2017 11:08:45] [002] ➞ ✹✹This is a Error message.✹✹
    [Information] [04-27-2017 11:08:45] [003] ➞ ✹✹This is an Information message.✹✹
    [Warning] [04-27-2017 11:08:45] [004] ➞ ✹✹This is a Warning message.✹✹
    [Alert] [04-27-2017 11:08:45] [005] ➞ ✹✹This is an Alert message.✹✹

<b>Don't want to show Titles?</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.hideTitles()
    
<b>Don't want to show Log Time?</b>

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.

    Printer.log.hideLogsTime = true

## Customize Emojis

<b>Don't like the Emojis which is available? Want to set your own? You can do this.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.successEmojiSymbol = "🎃"

<b>Oter properties for Emojis customization.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.errorEmojiSymbol = "<SetNew>"    
    Printer.log.warningEmojiSymbol = "<SetNew>"    
    Printer.log.infoEmojiSymbol = "<SetNew>"    
    Printer.log.alertEmojiSymbol = "<SetNew>"

## Customize Titles

<b>Don't like the Titles which is available? Want to set your own? Want to set the localize titles? You can do this.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.successLogTitle = "Hurray!!"

<b>Other properties for Titles customization.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.errorLogTitle = "<SetNew>"    
    Printer.log.warningLogTitle = "<SetNew>"    
    Printer.log.infoLogTitle = "<SetNew>"    
    Printer.log.alertLogTitle = "<SetNew>"

## Customize Symbols

<b>Don't like the Symbols which is available? Want to set your own? You can do this.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.arrowSymbol = "⇨"
    
<b>Oter properties for Symbol customization.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.starSymbol = "<SetNew>"

<b>Don't like the date format in logs? You can change it too.</b>

> **DEFAULT**: `MM-dd-yyyy HH:mm:ss`
> **IMPORTANT**: Should be call in advance.

    Printer.log.logDateFormat = "hh:mm:ss a"

<b>Example when logDateFormat is set to a different format.</b>

    [✅ Success] [⌚11:12:23 AM] [🆔 001] ➞ ✹✹This is a Success message.✹✹
   
## Filter Logs: Filter by Log Types
<b>Show specific logs with filter.</b>

    Printer.log.filterLogs = [.success, .alert]
 
> This should only print logs of the specified types. I.e. Succes and Alert. All other logs will be ignored.

## Filter Logs: Filter by File
<b>Written Printer logs everywhere? Want to Skip logging for </b> `LoginViewController.swift`<b> for security?</b>

To Skip logs for a file: `Printer.log.skipFile()`
To Add logs for a file:  `Printer.log.addFile()`

> **IMPORTANT**: You should call `addFile()` to start printing logs for the same file for which you have called `skipFile()`. This is other than the `disable` property which completely disables logging for all the files.

## Disable Logs
<b>To disable all the logs.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: You can set this anywhere and it should not print logs from where it sets.

    Printer.log.disable = true
    
## Completion Block
<b>Let you will notified in advance before any logging events.</b>

> **IMPORTANT**: This block will ignore all the filters applied for Printer, means, it will always notify you for any logs whether the log will print or not.

        Printer.log.onLogCompletion = { (log) in
            print(log)
            //print(log.0)
        }
        
Will return current log, file name, function name, and line number. You can access it with log.0, log.1 so on.

</b>Use cases:</b>

- To notify in advance before a log event.
- To print logs even if you've applied any filter. 
- To call your APIs to store log information. Only code at one place. No dependencies.

> You will not get notify if `disable` is set to `true` or `printOnlyIfDebugMode` is set to `true` and your app is in `release` mode. 

## Background or Foreground Logs

<b>Want to see when app goes to background or comes to foreground?</b>

    Printer.log.addAppEventsHandler()
    
    [📣 INFORMATION] [⌚05-17-2017 13:17:38]  ➞ ✹✹App is in foreground now.✹✹
    ________________________________________________________________________________________
    
<b>Stop logging for background or foreground events?</b>

    Printer.log.removeAppEventsHandler()
    
> This is helpful when you're checking all the logs and want to see what happended after app went to background or comes to foreground?    

## Ready to ship your app?

<b>Don't want to print the logs in RELEASE mode?</b>

> **DEFAULT**: `true`
> **IMPORTANT**: Should be call in advance.

    Printer.log.printOnlyIfDebugMode = false
    
## ToDo[s]

<b><i>[New Features]</i></b>

- [x] Filter Logs.
- [x] Disable Logs.
- [x] Manual Tracing.
- [x] Auto Tracing.
- [x] All logs - Track all the logs and print all at once.
- [x] Future Logs – A function which will print a log after a certain time.
- [x] Skipping logs for a particular file.
- [x] Delegate calls for to let you know the Printer logged.
- [x] Maintain a log file separately.
- [x] Improve README file with following: Features List for direct link to a particular point.
- [x] Log application events. Example: Background/Foreground events.
- [ ] Log Stats. Example: Total Logs. Logs from Files. Filters Applied.
- [ ] Open a ViewController to show up all the logs. Possible functions: Filter, Search, Print(!), and Share logs.

<b>Have an idea for improvements of this class?
Please open an [issue](https://github.com/hemangshah/printer/issues/new).</b>
    
## Credits

<b>[Hemang Shah](https://about.me/hemang.shah)</b>

**You can shoot me an [email](http://www.google.com/recaptcha/mailhide/d?k=01IzGihUsyfigse2G9z80rBw==&c=vU7vyAaau8BctOAIJFwHVbKfgtIqQ4QLJaL73yhnB3k=) to contact.**
   
## Licence

The MIT License (MIT)

> Read the [LICENSE](https://github.com/hemangshah/printer/blob/master/LICENSE) file for details.
