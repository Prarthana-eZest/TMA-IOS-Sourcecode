//
//  BOMProductCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 05/12/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class BOMProductCell: UITableViewCell {

    @IBOutlet weak private var lblProductName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(title: String, isSelected: Bool) {
        self.contentView.backgroundColor = isSelected ? UIColor.white : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        lblProductName.text = title
        lblProductName.textColor = isSelected ? UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1) : UIColor.gray
        if let selectedFont = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 16), let normalFont = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16) {
            lblProductName.font = isSelected ? selectedFont : normalFont
        }

    }

}
