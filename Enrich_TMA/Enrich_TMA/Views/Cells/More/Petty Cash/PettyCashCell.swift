//
//  PettyCashCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class PettyCashCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var txtFValue: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(title: String, value: String, valueFont: UIFont) {
        lblTitle.text = title
        txtFValue.text = value
        txtFValue.font = valueFont
        txtFValue.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
