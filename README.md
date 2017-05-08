# Printer – A fancy way to print logs.

## You can print following types of logs with Printer.

  - ✅ Success
  - ❌ Error
  - 🚧 Warning
  - 📣 Information
  - 🚨 Alert

> With each of the type, it will print a particular emoji and titles which will help you to easily identify what's exactly the log is. Moreover, it will looks cool too.

## Let's see what you can do with Printer.

<b>Printer has a singleton, you should always use it with it's singleton.</b>

    Printer.log.show(id: "001", details: "This is a Success message.", logType: .success)
        
<b>See the output. Isn't it cool?</b>
        
    Printer ➞ [✅ Success] [⌚04-27-2017 10:39:26] [🆔 101] ➞ ✹✹This is a Success message.✹✹
        
<b>So here are other options you can do with Printer.</b>

    Printer.log.show(id: "002", details: "This is a Error message.", logType: .error)
    Printer.log.show(id: "003", details: "This is an Information message.", logType: .information)
    Printer.log.show(id: "004", details: "This is a Warning message.", logType: .warning)    
    Printer.log.show(id: "005", details: "This is an Alert message.", logType: .alert)

<b>Output:</b>

    Printer ➞ [❌ Error] [⌚04-27-2017 10:41:39] [🆔 102] ➞ ✹✹This is a Error message.✹✹
    Printer ➞ [🚧 Warning] [⌚04-27-2017 10:41:39] [🆔 103] ➞ ✹✹This is a Warning message.✹✹
    Printer ➞ [📣 Information] [⌚04-27-2017 10:41:39] [🆔 104] ➞ ✹✹This is an Information message.✹✹
    Printer ➞ [🚨 Alert] [⌚04-27-2017 10:41:39] [🆔 105] ➞ ✹✹This is an Alert message.✹✹

## Different ways to print logs.

<b>Don't want to specify the logType everytime? No problem, we have function for that too.</b>
    
    Printer.log.success(id: "101", details: "This is a Success message. No need to specify logType.")
    Printer.log.error(id: "102", details: "This is a Error message. No need to specify logType.")
    Printer.log.warning(id: "103", details: "This is a Warning message. No need to specify logType.")
    Printer.log.information(id: "104", details: "This is a Information message. No need to specify logType.")
    Printer.log.alert(id: "105", details: "This is a Alert message. No need to specify logType.")

<b>Don't want to specify IDs? We have taken care about that too.</b>

    Printer.log.success(details: "This is a Success message without ID.")
    Printer.log.error(details: "This is a Error message without ID.")
    Printer.log.warning(details: "This is a Warning message without ID.")
    Printer.log.information(details: "This is a Information message without ID.")
    Printer.log.alert(details: "This is a Alert message without ID.")

<b>We have overrided the 'show' function.</b>

    Printer.log.show(details: "This is a Success message.", logType: .success)
    Printer.log.show(details: "This is an Alert message.", logType: .alert)
    
<b>Show a future log.</b>

    Printer.log.showInFuture(id: "006", details: "This is a future Success message.", logType: .success, afterSeconds: 3)
    
> This will print a log after specified seconds. In this case, success log after three (3) seconds.

## plainLog

<b>Don't like this the fancy logs? No worries, we have a plain log option.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.

    Printer.log.plainLog = true
    
<b>Exmaple when </b>`plainLog`<b> is set to </b>`true`<b>.</b>

    Printer ➞ [04-27-2017 10:50:30] ID ➞ 001 Details ➞ This is a Success message.
    Printer ➞ [04-27-2017 10:50:30] ID ➞ 002 Details ➞ This is a Error message.
    Printer ➞ [04-27-2017 10:50:30] ID ➞ 003 Details ➞ This is an Information message.
    Printer ➞ [04-27-2017 10:50:30] ID ➞ 004 Details ➞ This is a Warning message.
    Printer ➞ [04-27-2017 10:50:30] ID ➞ 005 Details ➞ This is an Alert message.
    
<b>We have a new</b>`.plain`<b> type added with </b>show()<b> function</b>.

    Printer.log.show(id: "001", details: "This is a Plain message.", logType: .plain)
    
> This is useful when you only want few plain logs.

> **IMPORTANT**: Any properties you're setting should be set in advance or before printing any logs to get the exact effect.

> **SUGGESTION**: You can always set all the properties to customize the **Printer** in `AppDelegate.swift` file,

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.

            //set the properties and call the specific function as per the need.

            Printer.log.plainLog = true
            Printer.log.addLineAfterEachPrint = true
            Printer.log.capitalizeTitles = true
            Printer.log.capitalizeDetails = true
            Printer.log.printOnlyIfDebugMode = true

            Printer.log.hideTitles()
            Printer.log.hideEmojis()

            return true
        }

> This will set the properties globally and will be available for the entire app life cycle.

## Tracing

<b> Want to print file name, function name and line number?</b>

> **IMPORTANT**: Should be call everytime when you want to print a trace.

    Printer.log.trace()
    
    Printer.Trace ➞ [05-02-2017 14:58:38] ViewController.swift ➞ viewDidLoad() #40
    
## All Logs

<b>Want to print all the logs for a different usecase?</b>

> **IMPORTANT**: `keepTracking` should set to `true` before logging.

    Printer.log.all()
    
<b>You can filter them as well.</b>

    Printer.log.all(filterLogTypes: [.alert])
   
> This will only print `.alert` type tracked logs.

> all() function will always print plain logs. <i>No fancy things</i>.

## Customize Printer

<b>You can add a line after each logs.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: Should be call in advance.
    
    Printer.log.addLineAfterEachPrint = true

<b>Example when addLineAfterEachPrint is set to </b>`true`<b>.</b>

    Printer ➞ [✅ Success] [⌚04-27-2017 10:53:28] [🆔 001] ➞ ✹✹This is a Success message.✹✹
    ________________________________________________________________________________________
    Printer ➞ [❌ Error] [⌚04-27-2017 10:53:28] [🆔 002] ➞ ✹✹This is a Error message.✹✹
    ________________________________________________________________________________________
    Printer ➞ [📣 Information] [⌚04-27-2017 10:53:28] [🆔 003] ➞ ✹✹This is an Information message.✹✹
    ________________________________________________________________________________________
    Printer ➞ [🚧 Warning] [⌚04-27-2017 10:53:28] [🆔 004] ➞ ✹✹This is a Warning message.✹✹
    ________________________________________________________________________________________
    Printer ➞ [🚨 Alert] [⌚04-27-2017 10:53:28] [🆔 005] ➞ ✹✹This is an Alert message.✹✹
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

    Printer ➞ [✅ SUCCESS] [⌚04-27-2017 11:09:37] [🆔 001] ➞ ✹✹THIS IS A SUCCESS MESSAGE.✹✹

<b>Don't want to show Emojis?</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.hideEmojis()

<b>Example when</b> `hideEmojis()` <b>call.</b>

    Printer ➞ [Success] [04-27-2017 11:08:45] [001] ➞ ✹✹This is a Success message.✹✹
    Printer ➞ [Error] [04-27-2017 11:08:45] [002] ➞ ✹✹This is a Error message.✹✹
    Printer ➞ [Information] [04-27-2017 11:08:45] [003] ➞ ✹✹This is an Information message.✹✹
    Printer ➞ [Warning] [04-27-2017 11:08:45] [004] ➞ ✹✹This is a Warning message.✹✹
    Printer ➞ [Alert] [04-27-2017 11:08:45] [005] ➞ ✹✹This is an Alert message.✹✹

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

    Printer.log.successEmojiSymbole = "🎃"

<b>Oter properties for Emojis customization.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.errorEmojiSymbole = "<SetNew>"    
    Printer.log.warningEmojiSymbole = "<SetNew>"    
    Printer.log.infoEmojiSymbole = "<SetNew>"    
    Printer.log.alertEmojiSymbole = "<SetNew>"

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

## Customize Symboles

<b>Don't like the Symboles which is available? Want to set your own? You can do this.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.arrowSymbole = "⇨"
    
<b>Oter properties for Symbole customization.</b>

> **IMPORTANT**: Should be call in advance.

    Printer.log.starSymbole = "<SetNew>"

<b>Don't like the date format in logs? You can change it too.</b>

> **DEFAULT**: `MM-dd-yyyy HH:mm:ss`
> **IMPORTANT**: Should be call in advance.

    Printer.log.logDateFormat = "hh:mm:ss a"

<b>Example when logDateFormat is set to a different format.</b>

    Printer ➞ [✅ Success] [⌚11:12:23 AM] [🆔 001] ➞ ✹✹This is a Success message.✹✹
   
## Filter Logs
<b>Show specific logs with filter.</b>

    Printer.log.filterLogs = [.success, .alert]
 
> This should only print logs of the specified types. I.e. Succes and Alert. All other logs will be ignored.

## Disable Logs
<b>To disable all the logs.</b>

> **DEFAULT**: `false`
> **IMPORTANT**: You can set this anywhere and it should not print logs from where it sets.

    Printer.log.disable = true

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
- [x] All logs - Track all the logs and print all at once.
- [ ] Skipping logs for a particular file.
- [ ] Maintain a log file separately.
- [ ] Log application events. Example: Background/Foreground events.
- [ ] Future Logs – A function which will print a log after a certain time.

<b>Have an idea for improvements of this class? Please open an [issue](https://github.com/hemangshah/printer/issues/new).</b>
    
## Credits

<b>[Hemang Shah](https://about.me/hemang.shah)</b>

**For any queries or concerns please send me an [email](http://www.google.com/recaptcha/mailhide/d?k=01IzGihUsyfigse2G9z80rBw==&c=vU7vyAaau8BctOAIJFwHVbKfgtIqQ4QLJaL73yhnB3k=).**
   
## Licence

The MIT License (MIT)

> Read the [LICENSE](https://github.com/hemangshah/printer/blob/master/LICENSE) file for details.
