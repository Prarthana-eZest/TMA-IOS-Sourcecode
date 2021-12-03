//
//  AttendanceDetailsCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 24/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class AttendanceDetailsCell: UITableViewCell {
    
    @IBOutlet weak private var lblDate: UILabel!
    @IBOutlet weak private var lblShift: UILabel!
    @IBOutlet weak private var lblPunchIn: UILabel!
    @IBOutlet weak private var lblPunchOut: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
