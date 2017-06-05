//
//  PrinterTableViewCell.swift
//
//
//  Created by Hemang Shah on 5/24/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

public class PrinterTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLogDetails: UILabel!
    @IBOutlet weak var lblTraceInfo: UILabel!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
