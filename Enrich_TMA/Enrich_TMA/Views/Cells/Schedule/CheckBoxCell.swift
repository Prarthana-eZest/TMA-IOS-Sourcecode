//
//  CheckBoxCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 09/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class CheckBoxCell: UITableViewCell {

    @IBOutlet private weak var btnCheckbox: UIButton!
    @IBOutlet private weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: CheckBoxCellModel) {
        btnCheckbox.isSelected = model.isSelected
        lblTitle.text = model.title
        lblTitle.font = model.isSelected ? UIFont(name: FontName.FuturaPTMedium.rawValue, size: 18) : UIFont(name: FontName.FuturaPTBook.rawValue, size: 18)
    }

}

struct CheckBoxCellModel {
    var title: String
    var isSelected: Bool
}
