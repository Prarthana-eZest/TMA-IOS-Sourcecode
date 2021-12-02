//
//  ProductCategoryCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 25/06/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ProductCategoryFrontImageCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgHairCare: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: ProductCategoryModel) {
        self.lblTitle.text = model.title
    }
}

struct ProductCategoryModel {
    let title: String
}
