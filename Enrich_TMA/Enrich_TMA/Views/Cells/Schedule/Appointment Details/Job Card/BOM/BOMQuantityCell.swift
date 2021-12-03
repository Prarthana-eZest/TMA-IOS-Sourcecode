//
//  BOMQuantityCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 05/12/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class BOMQuantityCell: UITableViewCell {

    @IBOutlet weak private var btnRadio: UIButton!
    @IBOutlet weak private var lblQuantity: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(value: String, isSelected: Bool) {
        lblQuantity.text = value
        btnRadio.isSelected = isSelected
    }

}
