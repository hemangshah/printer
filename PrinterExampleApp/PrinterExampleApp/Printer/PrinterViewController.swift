//
//  PrinterViewController.swift
//
//
//  Created by Hemang Shah on 5/24/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

fileprivate extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
}

fileprivate extension NSAttributedString {
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

fileprivate let fixedCellHeight:CGFloat = 90

fileprivate let fontLogDetails = UIFont.init(name: "Verdana", size: 15)

fileprivate let printerTableViewCellIdentifier = "PrinterTableViewCellIdentifier"

public class PrinterViewController: UIViewController {
    
    fileprivate var arrayLogs = Array<PLog>()
    fileprivate var arrayFilteredLogs = Array<PLog>()
    
    fileprivate var searchActive = false
    
    @IBOutlet var tblViewLogs: UITableView!
    @IBOutlet var filtersSegment: UISegmentedControl!
    @IBOutlet var searchBarLogs: UISearchBar!
    
    //MARK: View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Setup Titles
        self.tabBarController?.navigationItem.title = "Logs"
        self.title = "Logs"
        
        //Setup SearchBar
        self.searchBarLogs.placeholder = "Search Logs"
        
        //Setup UITableView
        self.tblViewLogs.keyboardDismissMode = .onDrag
        self.tblViewLogs.tableFooterView = UIView.init()
        
        //Add filters in Segment
        filtersSegment.setTitle("All", forSegmentAt: 0)
        filtersSegment.setTitle(Printer.log.successEmojiSymbol, forSegmentAt: 1)
        filtersSegment.setTitle(Printer.log.errorEmojiSymbol, forSegmentAt: 2)
        filtersSegment.setTitle(Printer.log.infoEmojiSymbol, forSegmentAt: 3)
        filtersSegment.setTitle(Printer.log.warningEmojiSymbol, forSegmentAt: 4)
        filtersSegment.setTitle(Printer.log.alertEmojiSymbol, forSegmentAt: 5)
        filtersSegment.setTitle("Plain", forSegmentAt: 6)
        
        //Setup UISegmentController
        filtersSegment.selectedSegmentIndex = 0
        filtersSegment.tintColor = UIColor.black
        filtersSegment.layer.cornerRadius = 0.0
        filtersSegment.layer.borderColor = UIColor.black.cgColor
        filtersSegment.layer.borderWidth = 3.0
        filtersSegment.layer.masksToBounds = true
        
        //Add Done Button
        let doneBarbutton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissViewControlle))
        self.tabBarController?.navigationItem.leftBarButtonItem = doneBarbutton
        
        //Add Notifications Handler
        addNotificationHandler()
        //Update Logs
        updateViewForLogs()
    }
    
    deinit {
        removeNotificationHandler()
    }
    
    //MARK: Segnement Target
    @objc @IBAction func filterApply(segment:UISegmentedControl) -> Void {
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
    @objc fileprivate func dismissViewControlle() -> Void {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Notification Handler
    fileprivate func addNotificationHandler() -> Void {
        removeNotificationHandler()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewForLogs), name: NSNotification.Name(rawValue: notificationPrinterLogAdded), object: nil)
    }
    
    fileprivate func removeNotificationHandler() -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationPrinterLogAdded), object: nil)
    }
    
    //MARK: Fetch Logs
    @objc fileprivate func updateViewForLogs() -> Void {
        //If tracking is enabled then only we can fetch the current logs.
        fetchLogs(filter: nil)
    }
    
    fileprivate func fetchLogs(filter:Array<LogType>?) -> Void {
        arrayLogs.removeAll()
        if let filterArray = filter {
            arrayLogs.append(contentsOf: Printer.log.getAllLogs(filterLogTypes: filterArray))
        } else {
            arrayLogs.append(contentsOf: Printer.log.getAllLogs())
        }
        self.tblViewLogs.reloadData()
    }
    
    //MARK: UITable Helpers
    fileprivate func calculateHeightAtIndexPath(indexPath:IndexPath) -> CGFloat {
        let margins:CGFloat = 5.0
        let heightOfTitle:CGFloat = 30.0
        let heightOfTrace:CGFloat = 30.0
        let log:PLog = searchActive ? arrayFilteredLogs[indexPath.row] : arrayLogs[indexPath.row]
        let heightOfDetails = log.details.height(withConstrainedWidth: self.tblViewLogs.bounds.size.width, font: fontLogDetails!)
        let totalHeight = (heightOfDetails + heightOfTitle + heightOfTrace + (margins * 2.0))
        if totalHeight > fixedCellHeight {
            return totalHeight
        } else {
            return fixedCellHeight
        }
    }
    
    //MARK: Data Helpers
    fileprivate func getLogTitle(log:PLog) -> NSMutableAttributedString {
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
    
    fileprivate func getTraceInfo(log:PLog) -> String {
        let traceInfo:TraceInfo = log.traceInfo
        let file = traceInfo.fileName
        let function = traceInfo.functionName
        let line = traceInfo.lineNumber
        return "\(file) \(Printer.log.arrowSymbol) \(function) #\(line)"
    }
    
    fileprivate func createLogTitle(log:PLog) -> NSMutableAttributedString {
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
    
    fileprivate func getBoldAttributedString(value:String) -> NSAttributedString {
        let font = UIFont.init(name: "Verdana-Bold", size: 12)
        let attribute = [NSAttributedStringKey.font:font]
        let attributedString = NSAttributedString(string: value, attributes: (attribute as Any as! [NSAttributedStringKey : Any]))
        return attributedString
    }
    
    fileprivate func getLightAttributedString(value:String) -> NSAttributedString {
        let font = UIFont.init(name: "Verdana", size: 10)
        let attribute = [NSAttributedStringKey.font:font]
        let attributedString = NSAttributedString(string: value, attributes: (attribute as Any as! [NSAttributedStringKey : Any]))
        return attributedString
    }
    
    fileprivate func reloadOnSearch() -> Void {
        
        if searchBarLogs.isFirstResponder {
            self.filtersSegment.isEnabled = false
            if searchBarLogs.text!.count == 0 {
                searchActive = true
            } else {
                if !arrayFilteredLogs.isEmpty {
                    searchActive = true
                }
            }
        } else {
            if !arrayFilteredLogs.isEmpty {
                if searchBarLogs.text!.count == 0 {
                    //Clear Button Pressed on SearchBar
                    arrayFilteredLogs.removeAll()
                    searchActive = false
                } else {
                    //Search is tapped on Keyboard
                    searchActive = true
                }
            } else {
                searchActive = false
                self.filtersSegment.isEnabled = true
            }
        }
        
        tblViewLogs.reloadData()
    }
}

extension PrinterViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return arrayFilteredLogs.count
        }
        return arrayLogs.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightAtIndexPath(indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Searching.
        if searchActive {
            guard arrayFilteredLogs.count > 0 else {
                if self.searchBarLogs.text!.isEmpty {
                    return "Search"
                } else {
                    return "Search | [No Logs]"
                }
            }
            
            return "Search | [\(arrayLogs.count)] logs found."
        }
        
        //Not Searching.
        guard arrayLogs.count > 0 else {
            return "[No Logs]"
        }
        
        return "[\(arrayLogs.count)] logs found."
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PrinterTableViewCell = (tableView.dequeueReusableCell(withIdentifier: printerTableViewCellIdentifier) as! PrinterTableViewCell)
        let log:PLog = searchActive ? arrayFilteredLogs[indexPath.row] : arrayLogs[indexPath.row]
        cell.lblTitle.attributedText = getLogTitle(log: log)
        cell.lblLogDetails.text = log.details
        if Printer.log.keepAutoTracing {
            cell.lblTraceInfo.attributedText = getLightAttributedString(value:getTraceInfo(log: log))
        }
        return cell
    }
}

extension PrinterViewController: UITableViewDelegate {
    //MARK: Copy Options
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let log:PLog = searchActive ? arrayFilteredLogs[indexPath.row] : arrayLogs[indexPath.row]
            let pasteboard = UIPasteboard.general
            pasteboard.string = "\(log.printableLog)\n\(log.printableTrace)"
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//Added Search Functionalities to Search the logs.
/*
 
 Behaviour:
 
 Steps:
 1. User taps on the SearchBar.
 2. Filter Segments will be disable.
 3. Only search within the selected filter.
 4. On Cancel/Search button tapped, will back to selected filter.
 5. If no results found will show Search | [No Logs].
 6. Can search for ID, Details, and within Tracing Info.
 
*/
extension PrinterViewController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.reloadOnSearch()
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.reloadOnSearch()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.reloadOnSearch()
            return
        }
        
        if self.arrayLogs.count > 0 {
            self.arrayFilteredLogs = self.arrayLogs.filter({ (log) -> Bool in
                if log.details.contains(searchText) {
                    return true
                } else if log.id.contains(searchText) {
                    return true
                } else {
                    if Printer.log.keepAutoTracing {
                        if log.traceInfo.fileName.contains(searchText) {
                            return true
                        } else if log.traceInfo.functionName.contains(searchText) {
                            return true
                        } else if String(log.traceInfo.lineNumber).contains(searchText) {
                            return true
                        }
                    }
                }
                return false
            })
            
            self.reloadOnSearch()
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.arrayFilteredLogs.removeAll()
        searchBar.resignFirstResponder()
        self.reloadOnSearch()
    }
}
