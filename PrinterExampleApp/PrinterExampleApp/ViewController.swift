//
//  ViewController.swift
//  PrinterExampleApp
//
//  Created by Hemang Shah on 4/27/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
         Printer – A fancy way to print logs.
         
         You can print following types of logs with Printer.
         
         - Success
         - Error
         - Warning
         - Information
         - Alert
         
         With each of the type, it will print a particular emoji and titles which will help you to
         easily identify what's exactly the log is. Moreover, it will looks cool too.
         
         Let's check what you can do with Printer.
         
         It's advice you to read the README file to avail most of the features of Printer. 
        */
        
        //Printer.log.plainLog = true
        
        //To get a call back before a log prints. This completion blocks will ignore all the filters.
        Printer.log.onLogCompletion = { (log) in
            //print(log)
            //print(log.0)
        }
    
        //To Skip a file from logging.
        Printer.log.skipFile()

        //Manual Tracing
        Printer.log.trace()
        
        //To Add a file for logging.
        Printer.log.addFile()
        
        //To keep track of all the logs. You can always print all the logs by calling 'all()'.
        Printer.log.keepTracking = true
        
        //Printer.log.keepAutoTracing = false //Default: true
        
        Printer.log.show(id: "001", details: "This is a Success message.", logType: .success)
        Printer.log.show(id: "002", details: "This is a Error message.", logType: .error)
        Printer.log.show(id: "003", details: "This is an Information message.", logType: .information)
        Printer.log.show(id: "004", details: "This is a Warning message.", logType: .warning)
        Printer.log.show(id: "005", details: "This is an Alert message.", logType: .alert)
        
        Printer.log.show(details: "This is another Success message without ID", logType: .success)
        
        //Printing of a Success message without providing a log type.
        //With ID
        Printer.log.success(id: "001", details: "This is another Success message.")
        
        //Without ID
        Printer.log.success(details: "This is a Success message.")

        //Printer.log.all(showTrace: true)
        //Printer.log.all(filterLogTypes: [.success], showTrace: true)
        
//        let array = Printer.log.getAllLogs()
        let array = Printer.log.getAllLogs(filterLogTypes: [.success])
        if !array.isEmpty {
            array.forEach({ (log) in
                print(log.details)
                //or do something with logs.
            })
        }
        
        Printer.log.saveLogsToFile(logs: array)
        //Printer.log.deleteLogFiles()
        //Printer.log.flush()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
