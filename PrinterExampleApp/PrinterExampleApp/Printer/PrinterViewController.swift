//
//  PrinterViewController.swift
//
//
//  Created by Hemang Shah on 5/24/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}

private extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.width
    }
}

private let fixedCellHeight:CGFloat = 90

private let fontLogDetails = UIFont.init(name: "Verdana", size: 15)

private let printerTableViewCellIdentifier = "PrinterTableViewCellIdentifier"

class PrinterViewController: UITableViewController {
    
    private var arrayLogs = Array<PLog>()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Add Filter Segment
        let items = ["All", Printer.log.successEmojiSymbol, Printer.log.errorEmojiSymbol, Printer.log.infoEmojiSymbol, Printer.log.warningEmojiSymbol, Printer.log.alertEmojiSymbol, "Plain"]
        let filtersSegment = UISegmentedControl(items: items)
        filtersSegment.selectedSegmentIndex = 0
        filtersSegment.tintColor = UIColor.black
        filtersSegment.addTarget(self, action: #selector(self.filterApply), for: UIControlEvents.valueChanged)
        let filterBarbutton = UIBarButtonItem.init(customView: filtersSegment)
        self.navigationItem.rightBarButtonItem = filterBarbutton
        
        //Add Done Button
        let doneBarbutton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissViewControlle))
        self.navigationItem.leftBarButtonItem = doneBarbutton
        
        //Add Notifications Handler
        addNotificationHandler()
        //Update Logs
        updateViewForLogs()
    }
    
    deinit {
        removeNotificationHandler()
    }
    
    //MARK: Segnement Target
    @objc private func filterApply(segment:UISegmentedControl) -> Void {
        switch segment.selectedSegmentIndex {
        case 1:
            fetchLogs(filter: [.success])
        case 2:
            fetchLogs(filter: [.error])
        case 3:
            fetchLogs(filter: [.information])
        case 4:
            fetchLogs(filter: [.warning])
        case 5:
            fetchLogs(filter: [.alert])
        case 6:
            fetchLogs(filter: [.plain])
        default:
            fetchLogs(filter: nil)
        }
    }
    
    //MARK: Dismiss View Controller
    @objc private func dismissViewControlle() -> Void {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    //MARK: Notification Handler
    private func addNotificationHandler() -> Void {
        removeNotificationHandler()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewForLogs), name: NSNotification.Name(rawValue: notificationPrinterLogAdded), object: nil)
    }
    
    private func removeNotificationHandler() -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationPrinterLogAdded), object: nil)
    }

    //MARK: Fetch Logs
    @objc private func updateViewForLogs() -> Void {
        //If tracking is enabled then only we can fetch the current logs.
        fetchLogs(filter: nil)
    }
    
    private func fetchLogs(filter:Array<LogType>?) -> Void {
        arrayLogs.removeAll()
        if let filterArray = filter {
            arrayLogs.append(contentsOf: Printer.log.getAllLogs(filterLogTypes: filterArray))
        } else {
            arrayLogs.append(contentsOf: Printer.log.getAllLogs())
        }
        self.tableView.reloadData()
    }
    
    //MARK: UITable Helpers
    private func calculateHeightAtIndexPath(indexPath:IndexPath) -> CGFloat {
        let margins:CGFloat = 5.0
        let heightOfTitle:CGFloat = 30.0
        let heightOfTrace:CGFloat = 30.0
        let log:PLog = arrayLogs[indexPath.row]
        let heightOfDetails = log.details.height(withConstrainedWidth: self.tableView.bounds.size.width, font: fontLogDetails!)
        let totalHeight = (heightOfDetails + heightOfTitle + heightOfTrace + (margins * 2.0))
        if totalHeight > fixedCellHeight {
            return totalHeight
        } else {
            return fixedCellHeight
        }
    }
    
    //MARK: UITableView Datasource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard arrayLogs.count > 0 else {
            return "Printer [No Logs]"
        }
        
        guard arrayLogs.count > 1 else {
            return "Printer [\(arrayLogs.count) Log]"
        }
        
        return "Printer [\(arrayLogs.count) Logs]"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLogs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightAtIndexPath(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> PrinterTableViewCell {
        let cell:PrinterTableViewCell = (tableView.dequeueReusableCell(withIdentifier: printerTableViewCellIdentifier) as! PrinterTableViewCell)
        let log:PLog = arrayLogs[indexPath.row]
        cell.lblTitle.attributedText = getLogTitle(log: log)
        cell.lblLogDetails.text = log.details
        cell.lblTraceInfo.attributedText = getLightAttributedString(value:getTraceInfo(log: log))
        return cell
    }
    
    //MARK: Data Helpers
    private func getLogTitle(log:PLog) -> NSMutableAttributedString {
        let title:NSMutableAttributedString = createLogTitle(log: log)
        if log.logType != .plain {
            if !log.id.isEmpty {
                title.append(NSAttributedString.init(string: (" " + Printer.log.arrowSymbol + " " + Printer.log.idEmojiSymbol + " " + log.id)))
            }
            title.append(NSAttributedString.init(string: " " + Printer.log.arrowSymbol + " " + Printer.log.watchEmojiSymbol + " " + log.time))
        } else {
            if !log.id.isEmpty {
                title.append(NSAttributedString.init(string: (" " + Printer.log.arrowSymbol + " " + "ID:" + " " + log.id)))
            }
            title.append(NSAttributedString.init(string: " " + Printer.log.arrowSymbol + " " + log.time))
        }
        return title
    }
    
    private func getTraceInfo(log:PLog) -> String {
        let traceInfo:TraceInfo = log.traceInfo
        let file = traceInfo.fileName
        let function = traceInfo.functionName
        let line = traceInfo.lineNumber
        return "\(file) \(Printer.log.arrowSymbol) \(function) #\(line)"
    }
    
    private func createLogTitle(log:PLog) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        switch log.logType {
            case .success:
                attributedString.append(NSAttributedString.init(string: (Printer.log.successEmojiSymbol + " ")))
                attributedString.append(getBoldAttributedString(value: Printer.log.successLogTitle))
                return attributedString
            case .error:
                attributedString.append(NSAttributedString.init(string: (Printer.log.errorEmojiSymbol + " ")))
                attributedString.append(getBoldAttributedString(value: Printer.log.errorLogTitle))
                return attributedString
            case .information:
                attributedString.append(NSAttributedString.init(string: (Printer.log.infoEmojiSymbol + " ")))
                attributedString.append(getBoldAttributedString(value: Printer.log.infoLogTitle))
                return attributedString
            case .warning:
                attributedString.append(NSAttributedString.init(string: (Printer.log.warningEmojiSymbol + " ")))
                attributedString.append(getBoldAttributedString(value: Printer.log.warningLogTitle))
                return attributedString
            case .alert:
                attributedString.append(NSAttributedString.init(string: (Printer.log.alertEmojiSymbol + " ")))
                attributedString.append(getBoldAttributedString(value: Printer.log.alertLogTitle))
                return attributedString
            default:
                attributedString.append(getBoldAttributedString(value: "Plain Log"))
                return attributedString
        }
    }
    
    private func getBoldAttributedString(value:String) -> NSAttributedString {
        let font = UIFont.init(name: "Verdana-Bold", size: 12)
        let attribute = [NSFontAttributeName:font]
        let attributedString = NSAttributedString(string: value, attributes: attribute as Any as? [String : Any])
        return attributedString
    }
    
    private func getLightAttributedString(value:String) -> NSAttributedString {
        let font = UIFont.init(name: "Verdana", size: 10)
        let attribute = [NSFontAttributeName:font]
        let attributedString = NSAttributedString(string: value, attributes: attribute as Any as? [String : Any])
        return attributedString
    }
}
