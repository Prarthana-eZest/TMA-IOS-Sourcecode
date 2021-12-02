//
//  ProductSpcificationCell.swift
//  EnrichSalon
//
//  Created by Harshal on 28/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ProductSpcificationCell: UITableViewCell {

    @IBOutlet weak private var lblPointText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ProductSpecificationModel) {
        self.lblPointText.text = model.point
    }
}

struct ProductSpecificationModel {
    let point: String
}
