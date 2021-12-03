//
//  ListingCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 22/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class ListingCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(text: String) {
        lblTitle.text = text
    }

}
