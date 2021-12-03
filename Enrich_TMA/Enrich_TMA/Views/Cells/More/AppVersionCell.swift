//
//  AppVersionCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 07/07/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

class AppVersionCell: UITableViewCell {

    @IBOutlet weak private var lblVersionNo: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(version: String) {
        lblVersionNo.text = "Version: \(version)"
    }
}
