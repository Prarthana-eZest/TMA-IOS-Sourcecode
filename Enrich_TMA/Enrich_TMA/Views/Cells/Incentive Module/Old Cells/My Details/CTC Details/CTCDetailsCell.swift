//
//  CTCDetailsCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 23/02/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class CTCDetailsCell: UITableViewCell {
    
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(title: String, values: String) {
        lblTitle.text = title
        lblValue.text = values
    }
    
}
