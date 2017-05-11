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
        */

        Printer.log.skipFile()

        //Manual Tracing
        Printer.log.trace()
        
        Printer.log.addFile()
        
        //To keep track of all the logs. You can always print all the logs by calling 'all()'.
        //Printer.log.keepTracking = true
        
        //Printer.log.keepAutoTracing = false
        
        Printer.log.show(id: "001", details: "This is a Success message.", logType: .success)
        Printer.log.show(id: "002", details: "This is a Error message.", logType: .error)
        Printer.log.show(id: "003", details: "This is an Information message.", logType: .information)
        Printer.log.show(id: "004", details: "This is a Warning message.", logType: .warning)
        Printer.log.show(id: "005", details: "This is an Alert message.", logType: .alert)
        
        //Printer.log.all()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
