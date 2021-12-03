//
//  JobCardSectionHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 12/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class JobCardSectionHeaderCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var dropDownImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(title: String, isExpanded: Bool) {
        lblTitle.text = title
        dropDownImageView.image = isExpanded ? UIImage(named: "upArrow") :  UIImage(named: "downArrow")
    }

}
